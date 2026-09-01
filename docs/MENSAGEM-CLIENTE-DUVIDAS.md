# Mensagem para a cliente — pontos em aberto

Texto pronto para copiar e enviar. Sem termo técnico de propósito.
Referências internas ficam em [DEPENDENCIAS-E-PENDENCIAS.md](DEPENDENCIAS-E-PENDENCIAS.md)
seção 6 e **não** vão na mensagem.

---

Oi, tudo bem?

Já implementamos tudo o que você respondeu: a ordem das três etapas, as faixas
etárias corrigidas, o "não verifiquei" que não conta mais contra a criança, o
rebaixamento automático de faixa e a Generalização em 3 dias diferentes.

Antes de seguir, tem um ponto para você validar e três dúvidas.

**Como está funcionando hoje**

1. A família cadastra a criança e o app define a faixa etária pela idade dela.
2. A criança responde as **perguntas iniciais** da faixa. Se tiver 2 ou mais
   respostas "quase nunca", ela desce uma faixa automaticamente, sem perguntar
   nada à família, e responde as perguntas da faixa de baixo. Se acontecer de
   novo, desce de novo — até a faixa mais nova, que é o limite.
3. Depois vêm as **perguntas de cada habilidade**: Comunicação, Social,
   Cognitiva, Coordenação Motora e Funcional. Quando a família responde "ainda
   não verifiquei", aquela resposta fica de fora da conta — não pesa como se a
   criança não soubesse fazer.
4. Com isso o app monta o **plano**: para cada habilidade, todas as atividades
   daquela faixa, na ordem dos códigos.
5. Cada atividade passa por **três etapas, sempre nessa ordem**:
   - **Aquisição** — a criança aprende a fazer. Conclui com 8 acertos sem ajuda
     em 10 tentativas.
   - **Generalização** — a criança faz em situações diferentes. Conclui com 8
     acertos em 10, em **3 dias diferentes**.
   - **Manutenção** — a criança continua fazendo depois de aprendido. Conclui
     com 8 acertos em 10.
6. Terminou a Manutenção, a próxima atividade é liberada.

---

**1. Confirma se está certo assim?**

Dentro de uma habilidade, a criança pega a **primeira atividade e vai até o fim
dela** — Aquisição, depois Generalização, depois Manutenção. Só quando termina
as três etapas é que a segunda atividade começa. E assim por diante, uma
atividade por vez, na ordem dos códigos.

É assim que está montado hoje. Se a ideia for outra — por exemplo, fazer a
Aquisição de todas as atividades da habilidade antes de começar qualquer
Generalização — é só avisar que a gente ajusta.

---

**2. O CPF da criança deve continuar sendo pedido no cadastro?**

---

**3. Os Programas Básicos de Engajamento são as "Brincadeiras" da tela inicial?**

Na planilha vieram 24 programas com código terminado em **AT** (F01AT001 até
F06AT004), os "Programas Básicos de Engajamento da Triagem Inicial" — contato
visual, atender pelo nome, permanecer sentado, esse tipo de coisa.

Na tela inicial do app existe uma seção separada chamada **"Brincadeiras
educativas"**, que hoje está com conteúdo de exemplo. Nosso entendimento é que
esses 24 programas são justamente o que deveria estar ali. Está certo?

Se estiver, faltam duas coisas para a gente publicar:

- **É acesso livre?** Ou seja: qualquer família vê todas as brincadeiras,
  independente da idade da criança e do que ela respondeu na triagem?
- **Todas são gratuitas**, ou algumas entram no plano pago?

---

**4. Quem exclui a conta e se cadastra de novo pode ganhar outro teste grátis?**

Hoje pode: exclui a conta, cadastra de novo com o mesmo e-mail e recebe outros
15 dias.

Dá para bloquear — o sistema já guarda um registro das contas excluídas que
permite reconhecer que aquela pessoa já usou o teste, sem guardar o e-mail
dela. É uma alteração pequena.

O ponto a decidir é de negócio: quem excluiu a conta por engano e voltou
também ficaria sem o teste. Bloqueia ou deixa liberado?

---

Qualquer dúvida, é só chamar!
