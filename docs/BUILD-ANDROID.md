# Build Android (APK) — Avance Kids

App Expo SDK 57 / React Native 0.86 em `apps/mobile`.

## Pré-requisitos (já presentes nesta máquina)

- JDK 17 (Temurin) — `JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-17.0.17.10-hotspot`
- Android SDK com `platforms/android-36`, `build-tools/36.0.0`, `ndk/27.x`
- `ANDROID_HOME` **não** está definido; o caminho do SDK vem de `android/local.properties`

## Identidade do app

Definida em [apps/mobile/app.json](../apps/mobile/app.json):

- `android.package`: `br.com.avancekids.app` — **permanente** depois da primeira publicação na Play Store
- `android.versionCode`: incrementar a cada envio para a Play Store
- `version` (versionName): visível ao usuário

## Assinatura

Keystore de release em `apps/mobile/credentials/avancekids-release.keystore`
(git-ignorado, nunca versionado):

- alias: `avancekids`
- algoritmo: RSA 4096, formato PKCS12, validade 10.000 dias
- titular do certificado: `CN=Avance Kids, O=Avance Kids, C=BR`
- SHA-256: `E0:D4:D8:E6:AF:00:8A:DA:50:7F:FF:36:D7:D0:C4:67:84:E2:65:B9:05:20:D9:CB:1A:8C:A8:D2:69:32:6C:4D`
- senha do store e da chave: **fora do repositório** — está apenas em
  `apps/mobile/android/gradle.properties` (git-ignorado pela regra `/android`).
  Copie para o gerenciador de senhas da equipe.

> **Guarde um backup do arquivo e da senha fora do git.** Perder o keystore
> significa não conseguir mais publicar atualizações do app na Play Store sob o
> mesmo package (a menos que o Play App Signing esteja ativo).

Se preferir que o certificado leve a razão social da empresa em vez de
`O=Avance Kids`, gere outro keystore **antes do primeiro envio à Play Store** —
depois disso a chave fica presa ao package.

As credenciais são lidas por `android/gradle.properties` (`AVANCEKIDS_STORE_FILE`,
`AVANCEKIDS_STORE_PASSWORD`, `AVANCEKIDS_KEY_ALIAS`, `AVANCEKIDS_KEY_PASSWORD`) e
consumidas pelo `signingConfigs.release` em `android/app/build.gradle`. Sem essas
propriedades, o Gradle cai no keystore de debug.

### Keystore anterior: comprometido e substituído

O keystore de release **antigo** e a senha dele **estiveram versionados** neste
repositório:

| O quê | Onde entrou | Onde saiu do índice |
| --- | --- | --- |
| `apps/mobile/credentials/avancekids-release.keystore` | commit `77a3f5b` | commit `b9a0cde` |
| senha em texto puro nesta página | commit `b79e403` | commit `b9a0cde` |

O que foi feito nesta branch de integração:

1. **Keystore novo gerado** (o descrito acima). O app ainda não foi publicado,
   então a troca não custou nada. O antigo está permanentemente comprometido e
   **não deve ser usado para assinar nenhuma versão**.
2. **Histórico local reescrito** para remover o arquivo e a senha de todos os
   commits — procedimento em [SEGURANCA-KEYSTORE.md](SEGURANCA-KEYSTORE.md).
3. `.gitignore` na raiz passou a barrar `*.keystore`, `*.jks`, `*.p12`, `.env` e
   afins em qualquer diretório do monorepo, não só em `apps/mobile/`.

**Ainda pendente e fora do alcance desta branch:** o `origin` (GitHub) continua
com o histórico antigo até alguém fazer o push forçado descrito no documento de
procedimento. Enquanto isso, considere o keystore antigo como público.

## Limite de 260 caracteres no Windows

O build C++ (codegen da New Architecture) estoura o `MAX_PATH` a partir do caminho
real do projeto. A compilação **falha** com
`ninja: error: Stat(...): Filename longer than 260 characters`.

Contorno: mapear um drive virtual encurtando o caminho, e buildar de lá.

```powershell
subst K: C:\Users\Alisson\CascadeProjects\avance-kids-code\apps
```

Detalhes:

- O `subst` **não sobrevive a reboot** — refazer quando necessário (`subst K: /D` remove).
- Mapear direto para `...\apps\mobile` **não funciona**: o autolinking do Expo não
  encontra o `package.json` quando ele está na raiz de um drive. Por isso o mapeamento
  aponta um nível acima e o projeto fica em `K:\mobile`.

## Gerar o APK

```powershell
subst K: C:\Users\Alisson\CascadeProjects\avance-kids-code\apps   # se ainda não mapeado
Set-Location K:\mobile\android
.\gradlew assembleRelease
```

Saída: `K:\mobile\android\app\build\outputs\apk\release\app-release.apk`
(≈10 min no primeiro build; incrementais são bem mais rápidos).

Cópia versionada por conveniência: `apps/mobile/dist/AvanceKids-<versão>.apk`.

## Instalar no dispositivo

```powershell
& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" install -r apps\mobile\dist\AvanceKids-1.0.0.apk
```

Ou copiar o `.apk` para o aparelho e instalar manualmente (exige permitir
"fontes desconhecidas").

## Variáveis de ambiente embutidas

As `EXPO_PUBLIC_*` de `apps/mobile/.env` são **compiladas dentro do bundle** no
momento do build — inclusive a `EXPO_PUBLIC_SUPABASE_ANON_KEY`. Trocar o `.env`
exige rebuildar. Nunca colocar chave de service role ou secret do Stripe ali.

## Regenerar a pasta nativa

`android/` é git-ignorado e gerado por `npx expo prebuild --platform android`.

Rodar `expo prebuild --clean` **sobrescreve** `android/app/build.gradle`,
`android/gradle.properties` e `android/local.properties`, apagando a configuração
de assinatura e o `sdk.dir`. Depois de um `--clean`, reaplicar:

1. `local.properties` com `sdk.dir=C\:\\Users\\Alisson\\AppData\\Local\\Android\\Sdk`
2. o bloco `signingConfigs.release` em `app/build.gradle`
3. as quatro propriedades `AVANCEKIDS_*` em `gradle.properties`

(Alternativa mais robusta a longo prazo: mover isso para um config plugin do Expo.)

## Notas

- O APK tem ~93 MB por ser universal (`arm64-v8a`, `armeabi-v7a`, `x86`, `x86_64`).
  Para reduzir, habilitar splits por ABI ou gerar um `.aab` (`./gradlew bundleRelease`),
  que é o formato exigido pela Play Store.
- `minSdkVersion` 24, `targetSdkVersion` 36.
- Build na nuvem via EAS (`npx eas-cli build -p android --profile preview`) é uma
  alternativa que dispensa toolchain local e o problema de `MAX_PATH`, mas exige
  conta Expo e `eas.json`.
