import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { RegisterChildSchema } from "../_shared/schemas.ts";
import { getUser } from "../_shared/auth.ts";
import { jsonResponse, errorResponse, corsHeaders } from "../_shared/response.ts";

serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const { supabase, user } = await getUser(req);
    const body = RegisterChildSchema.parse(await req.json());

    // Calcular idade biológica em meses
    const birthDate = new Date(body.data_nascimento);
    const now = new Date();
    const idadeMeses = (now.getFullYear() - birthDate.getFullYear()) * 12
      + (now.getMonth() - birthDate.getMonth());

    const { data, error } = await supabase
      .from("children")
      .insert({
        user_id: user.id,
        nome: body.nome,
        data_nascimento: body.data_nascimento,
        genero: body.genero,
        cpf: body.cpf,
        condicoes: body.condicoes,
        idade_biologica_meses: Math.max(12, idadeMeses),
      })
      .select()
      .single();

    if (error) return errorResponse(error.message, 500);

    return jsonResponse({ child: data }, 201);
  } catch (err) {
    if (err instanceof Error && err.message === "Unauthorized") {
      return errorResponse("Não autorizado", 401);
    }
    return errorResponse(err.message, 400);
  }
});
