# Login com Google — configuração final

O aplicativo usa o OAuth hospedado pelo Supabase. Não é necessária uma "chave
de API": precisamos de um **OAuth Client ID** e um **OAuth Client Secret**.
Nenhum segredo do Google vai no APK ou no arquivo `apps/mobile/.env`.

## 1. Google Cloud Console

No projeto da cliente:

1. Abra **Google Auth Platform → Branding**, informe nome do app, e-mail de
   suporte e contato do desenvolvedor.
2. Em **Audience**, escolha `External`. Enquanto estiver em teste, cadastre os
   e-mails que farão a homologação; para liberar aos clientes, publique o app.
3. Em **Clients**, crie um **OAuth Client ID** do tipo **Web application**.
4. Em **Authorized redirect URIs**, adicione:

   ```text
   https://aqfwquamrcutpobqkaot.supabase.co/auth/v1/callback
   ```

5. Guarde o **Client ID** e o **Client Secret**.

Se a tela de consentimento estiver em modo de teste, adicione os e-mails que
farão a homologação como usuários de teste.

## 2. Supabase

No projeto `aqfwquamrcutpobqkaot`:

1. Abra **Authentication → Sign In / Providers → Google**.
2. Ative o provedor e cole o Client ID e o Client Secret.
3. Abra **Authentication → URL Configuration**.
4. Adicione esta Redirect URL permitida:

   ```text
   avancekids://auth/callback
   ```

O `Client Secret` fica somente no Supabase. Não enviar nem gravar esse valor no
repositório, no Linear ou em variáveis `EXPO_PUBLIC_*`.

## 3. Validação

Depois da configuração, gere o novo APK e valide:

- conta Google existente entra sem duplicar o usuário;
- conta Google nova passa pelo aceite dos termos;
- cancelar o seletor do Google volta para o login sem travar;
- sair e entrar novamente restaura o mesmo perfil.

O esquema nativo `avancekids` e o callback já estão implementados no app versão
`1.0.1` (`versionCode` 2).
