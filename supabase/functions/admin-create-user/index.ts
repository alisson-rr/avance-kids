import { CreateAdminUserSchema } from "../_shared/schemas.ts";
import { getUser, getServiceClient } from "../_shared/auth.ts";
import { jsonResponse, errorResponse, corsHeaders } from "../_shared/response.ts";

// Cria um usuário admin do backoffice: só super_admins podem chamar.
// Precisa da Auth Admin API (service_role), por isso é uma Edge Function
// e não um insert direto do client.
Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const { user } = await getUser(req);
    const serviceClient = getServiceClient();

    const { data: caller } = await serviceClient
      .from("admin_users")
      .select("role, status")
      .eq("id", user.id)
      .maybeSingle();

    if (!caller || caller.status !== "ativo" || caller.role !== "super_admin") {
      return errorResponse("Acesso negado", 403);
    }

    const body = CreateAdminUserSchema.parse(await req.json());

    const { data: created, error: createErr } = await serviceClient.auth.admin.createUser({
      email: body.email,
      password: body.password,
      email_confirm: true,
      user_metadata: { nome: body.nome },
    });

    if (createErr || !created.user) {
      return errorResponse(createErr?.message ?? "Falha ao criar usuário no Auth", 400);
    }

    const { data: adminRow, error: insertErr } = await serviceClient
      .from("admin_users")
      .insert({
        id: created.user.id,
        nome: body.nome,
        email: body.email,
        role: body.role,
      })
      .select()
      .single();

    if (insertErr) {
      // Não deixar usuário Auth órfão se o insert do admin falhar
      await serviceClient.auth.admin.deleteUser(created.user.id);
      return errorResponse(insertErr.message, 500);
    }

    return jsonResponse({ admin: adminRow }, 201);
  } catch (err) {
    if (err instanceof Error && err.message === "Unauthorized") {
      return errorResponse("Não autorizado", 401);
    }
    return errorResponse(err.message, 400);
  }
});
