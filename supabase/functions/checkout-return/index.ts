/**
 * Página de retorno do Stripe Checkout.
 *
 * O Stripe só aceita success_url/cancel_url em http(s), então esta função
 * serve uma página mínima que devolve o usuário ao app pelo scheme
 * `avancekids://`. É pública de propósito (o Stripe redireciona o navegador
 * para cá, sem sessão) e não lê nem grava nada — quem atualiza a assinatura
 * é o webhook.
 *
 * Quando o domínio estiver no ar, basta apontar
 * EXPO_PUBLIC_CHECKOUT_SUCCESS_URL/CANCEL_URL para as páginas do site.
 */

const APP_SCHEME = "avancekids";

// Whitelist: nada do que vem na URL é interpolado sem passar por aqui.
const RESULTS = {
  sucesso: {
    deepLink: `${APP_SCHEME}://assinatura/sucesso`,
    titulo: "Pagamento confirmado",
    mensagem: "Sua assinatura está ativa. Voltando para o Avance Kids...",
  },
  cancelado: {
    deepLink: `${APP_SCHEME}://assinatura/cancelado`,
    titulo: "Pagamento cancelado",
    mensagem: "Nada foi cobrado. Voltando para o Avance Kids...",
  },
  // Volta do portal de cobrança: pode ter sido troca de cartão, consulta de
  // fatura ou cancelamento — texto neutro, o app relê o status de verdade.
  portal: {
    deepLink: `${APP_SCHEME}://assinatura/portal`,
    titulo: "Tudo certo",
    mensagem: "Voltando para o Avance Kids...",
  },
} as const;

type ResultKey = keyof typeof RESULTS;

function page({ deepLink, titulo, mensagem }: (typeof RESULTS)[ResultKey]) {
  return `<!doctype html>
<html lang="pt-BR">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>${titulo}</title>
<style>
  body{margin:0;min-height:100vh;display:flex;align-items:center;justify-content:center;
       font-family:system-ui,-apple-system,"Segoe UI",sans-serif;background:#FAFAFA;color:#3B3B3B}
  main{text-align:center;padding:32px;max-width:360px}
  h1{font-size:20px;color:#0E5DFD;margin:0 0 12px}
  p{font-size:15px;line-height:1.5;margin:0 0 24px}
  a{display:inline-block;background:#0E5DFD;color:#fff;text-decoration:none;
    padding:14px 28px;border-radius:12px;font-weight:600}
</style>
</head>
<body>
<main>
  <h1>${titulo}</h1>
  <p>${mensagem}</p>
  <a href="${deepLink}">Abrir o Avance Kids</a>
</main>
<script>location.replace(${JSON.stringify(deepLink)});</script>
</body>
</html>`;
}

Deno.serve((req: Request) => {
  const status = new URL(req.url).searchParams.get("status") ?? "";
  // hasOwn e não RESULTS[status]: chaves herdadas de Object.prototype
  // ('constructor', 'toString') passariam pelo ?? e renderizariam undefined.
  const result = Object.hasOwn(RESULTS, status) ? RESULTS[status as ResultKey] : RESULTS.sucesso;

  return new Response(page(result), {
    headers: { "Content-Type": "text/html; charset=utf-8", "Cache-Control": "no-store" },
  });
});
