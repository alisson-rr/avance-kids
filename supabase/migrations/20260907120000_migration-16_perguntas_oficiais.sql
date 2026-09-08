-- ============================================================
-- Perguntas oficiais do checklist
--
-- GERADO POR scripts/import_perguntas.py — NÃO EDITAR À MÃO.
-- Fonte: AvanceKids-DOCUMENTACAO/LOGICA-ATUALIZADA/2026.08.18_Logica App para exercícios.docx
--        (150 perguntas oficiais validadas)
--
-- As perguntas anteriores são arquivadas, não apagadas: respostas já
-- registradas continuam apontando para os mesmos IDs.
-- ============================================================

-- Confere as referências antes de alterar qualquer pergunta. Uma diferença
-- entre a planilha e o banco aborta a migration inteira.
DO $$
DECLARE
  v_faixas INTEGER;
  v_skills INTEGER;
BEGIN
  SELECT count(*) INTO v_faixas
  FROM age_brackets
  WHERE codigo = ANY(ARRAY['F01A', 'F02A', 'F03A', 'F04A', 'F05A', 'F06A']::text[]);

  IF v_faixas <> 6 THEN
    RAISE EXCEPTION 'esperava 6 faixas da planilha em age_brackets, encontrei %', v_faixas;
  END IF;

  SELECT count(*) INTO v_skills
  FROM skills
  WHERE key = ANY(ARRAY['cognitiva', 'comunicacao', 'funcional', 'motora', 'social']::text[]);

  IF v_skills <> 5 THEN
    RAISE EXCEPTION 'esperava 5 habilidades da planilha em skills, encontrei %', v_skills;
  END IF;
END $$;

-- Preserva as perguntas e as respostas antigas, mas deixa somente o conteúdo
-- oficial novo visível para próximas avaliações.
UPDATE questions
SET status = 'arquivado'
WHERE status = 'ativo';

WITH oficial(kind, skill_key, faixa_codigo, ordem, texto) AS (
  VALUES
    ('inicial', 'comunicacao', 'F01A', 1, 'Seu filho(a) olha quando você o chama pelo nome?'),
    ('inicial', 'comunicacao', 'F01A', 3, 'Aponta para objetos ou tenta alcançar o que quer?'),
    ('inicial', 'comunicacao', 'F01A', 4, 'Entende “dá aqui” ou “vem cá”?'),
    ('inicial', 'motora', 'F01A', 2, 'Ele(a) consegue sentar no chão sem apoio das mãos?'),
    ('inicial', 'comunicacao', 'F02A', 1, 'Seu filho(a) aponta para mostrar ou pedir algo?'),
    ('inicial', 'comunicacao', 'F02A', 3, 'Responde a comandos como “pega o brinquedo” ou “dá aqui”?'),
    ('inicial', 'social', 'F02A', 2, 'Ele(a) imita bater palmas, dar tchau, ou ações com brinquedos?'),
    ('inicial', 'social', 'F02A', 4, 'Brinca com você de “minha vez/sua vez”?'),
    ('inicial', 'comunicacao', 'F03A', 1, 'Seu filho(a) já pede brinquedos ou alimentos com palavras ou gestos?'),
    ('inicial', 'comunicacao', 'F03A', 4, 'Segue instruções como “pega o carrinho e senta”?'),
    ('inicial', 'social', 'F03A', 2, 'Ele(a) faz ações como “dar comida” e “pôr para dormir” com bonecos?'),
    ('inicial', 'social', 'F03A', 3, 'Consegue esperar sua vez numa brincadeira?'),
    ('inicial', 'comunicacao', 'F04A', 1, 'Usa palavras, gestos ou figuras para expressar o que deseja?'),
    ('inicial', 'comunicacao', 'F04A', 4, '“Pega o caderno, abre e põe na mesa” — ele compreende?'),
    ('inicial', 'social', 'F04A', 2, 'Faz ações como “dar comida e colocar na cama” com bonecos?'),
    ('inicial', 'social', 'F04A', 3, 'Consegue aguardar com calma em atividades com outras crianças?'),
    ('inicial', 'comunicacao', 'F05A', 1, 'Ex: “guarda o brinquedo, pega o tênis e senta” – ele compreende?'),
    ('inicial', 'comunicacao', 'F05A', 4, 'Diz o que quer ou sente com palavras, figuras ou escrita?'),
    ('inicial', 'funcional', 'F05A', 3, 'Vai ao banheiro, se limpa e dá descarga com autonomia?'),
    ('inicial', 'social', 'F05A', 2, 'Joga dominó, pega-pega ou esconde-esconde respeitando turnos e regras?'),
    ('inicial', 'comunicacao', 'F06A', 1, '“Guarda o livro, pega a garrafa e fecha a mochila” – ele consegue?'),
    ('inicial', 'comunicacao', 'F06A', 4, 'Usa palavras, escrita ou tecnologia para se expressar com clareza?'),
    ('inicial', 'funcional', 'F06A', 3, 'Usa banheiro público sem ajuda e cuida da higiene pessoal?'),
    ('inicial', 'social', 'F06A', 2, 'Joga UNO, futebol ou jogos de tabuleiro respeitando as regras?'),
    ('triagem', 'cognitiva', 'F01A', 1, 'Se você aponta um brinquedo, ele olha?'),
    ('triagem', 'cognitiva', 'F01A', 2, 'Ele mexe nos brinquedos para ver o que fazem?'),
    ('triagem', 'cognitiva', 'F01A', 3, 'Ele brinca de colocar coisas dentro de caixas?'),
    ('triagem', 'cognitiva', 'F01A', 4, 'Já tentou desenhar com lápis ou giz?'),
    ('triagem', 'comunicacao', 'F01A', 1, 'Ele vira o rosto quando você o chama?'),
    ('triagem', 'comunicacao', 'F01A', 2, 'Ele te olha durante uma brincadeira?'),
    ('triagem', 'comunicacao', 'F01A', 3, 'Ele tenta alcançar o que quer, mesmo sem falar?'),
    ('triagem', 'comunicacao', 'F01A', 4, 'Ele faz sons para pedir ou chamar atenção?'),
    ('triagem', 'comunicacao', 'F01A', 5, 'Se você disser “dá aqui”, ele entende?'),
    ('triagem', 'funcional', 'F01A', 1, 'Já aceita comidinhas mais consistentes?'),
    ('triagem', 'funcional', 'F01A', 2, 'Deixa limpar o rosto ou lavar as mãos?'),
    ('triagem', 'funcional', 'F01A', 3, 'Ele ajuda a vestir esticando os braços?'),
    ('triagem', 'funcional', 'F01A', 4, 'Reclama ou se incomoda com cocô/xixi?'),
    ('triagem', 'motora', 'F01A', 1, 'Ele se senta no chão sem usar as mãos?'),
    ('triagem', 'motora', 'F01A', 2, 'Ele se locomove sozinho, mesmo que com apoio?'),
    ('triagem', 'motora', 'F01A', 3, 'Ele consegue encaixar peças ou blocos?'),
    ('triagem', 'motora', 'F01A', 4, 'Se você rolar a bola, ele rola de volta?'),
    ('triagem', 'social', 'F01A', 1, 'Ele imita você batendo palmas ou dando tchau?'),
    ('triagem', 'social', 'F01A', 2, 'Gosta de brincar de esconder o rosto e aparecer?'),
    ('triagem', 'social', 'F01A', 3, 'Ele fica sentado brincando por um tempinho?'),
    ('triagem', 'social', 'F01A', 4, 'Ele sorri de volta quando você sorri para ele?'),
    ('triagem', 'cognitiva', 'F02A', 1, 'Chama você para ver algo que ele achou?'),
    ('triagem', 'cognitiva', 'F02A', 2, 'Abre potes ou caixas para ver o que tem dentro?'),
    ('triagem', 'cognitiva', 'F02A', 3, 'Junta animais com animais, blocos iguais, etc.?'),
    ('triagem', 'cognitiva', 'F02A', 4, 'Faz riscos circulares ou linhas mais firmes?'),
    ('triagem', 'comunicacao', 'F02A', 1, 'Mostra algo e te olha em seguida?'),
    ('triagem', 'comunicacao', 'F02A', 2, 'Aponta para algo que deseja à distância?'),
    ('triagem', 'comunicacao', 'F02A', 3, 'Emite sons imitando o que escuta?'),
    ('triagem', 'comunicacao', 'F02A', 4, 'Se você disser “onde está a bola?”, ele mostra?'),
    ('triagem', 'comunicacao', 'F02A', 5, 'Ex: “Pega o carrinho e dá pra mamãe”?'),
    ('triagem', 'funcional', 'F02A', 1, 'Usa colher para comer sem derramar muito?'),
    ('triagem', 'funcional', 'F02A', 2, 'Deixa lavar as mãos ou tenta lavar com você?'),
    ('triagem', 'funcional', 'F02A', 3, 'Ajuda colocando as mãos ou pés na roupa?'),
    ('triagem', 'funcional', 'F02A', 4, 'Diz ou sinaliza que quer fazer xixi/cocô?'),
    ('triagem', 'motora', 'F02A', 1, 'Usa corrimão para subir degraus?'),
    ('triagem', 'motora', 'F02A', 2, 'Faz torre de blocos ou jogos de encaixe?'),
    ('triagem', 'motora', 'F02A', 3, 'Folheia um livro com cuidado?'),
    ('triagem', 'motora', 'F02A', 4, 'Tenta chutar a bola quando você pede?'),
    ('triagem', 'social', 'F02A', 1, 'Faz de conta que dá comida pra boneco?'),
    ('triagem', 'social', 'F02A', 2, 'Troca turnos com você (minha vez/sua vez)?'),
    ('triagem', 'social', 'F02A', 3, 'Aguarda para receber algo que quer?'),
    ('triagem', 'social', 'F02A', 4, 'Você percebe quando ele está chateado?'),
    ('triagem', 'cognitiva', 'F03A', 1, 'Chama você para ver algo interessante?'),
    ('triagem', 'cognitiva', 'F03A', 2, 'Toca e manipula diferentes materiais com curiosidade?'),
    ('triagem', 'cognitiva', 'F03A', 3, 'Junta frutas com frutas, animais com animais, etc.?'),
    ('triagem', 'cognitiva', 'F03A', 4, 'Consegue copiar traços que você desenha?'),
    ('triagem', 'comunicacao', 'F03A', 1, 'Olha para o brinquedo e depois para você?'),
    ('triagem', 'comunicacao', 'F03A', 2, 'Dá tchau, faz “vem”, acena “não” espontaneamente?'),
    ('triagem', 'comunicacao', 'F03A', 3, 'Usa palavras ou sinais para pedir o que quer?'),
    ('triagem', 'comunicacao', 'F03A', 4, 'Mostra o nariz, a boca, a barriga quando você pede?'),
    ('triagem', 'comunicacao', 'F03A', 5, 'Quando você pergunta “o que você quer?”, ele responde?'),
    ('triagem', 'funcional', 'F03A', 1, 'Come frutas, legumes ou novas texturas sem grandes recusas?'),
    ('triagem', 'funcional', 'F03A', 2, 'Vai ao banheiro ou pia e tenta lavar as mãos com ajuda verbal?'),
    ('triagem', 'funcional', 'F03A', 3, 'Quando você pede, ele tenta tirar a roupa?'),
    ('triagem', 'funcional', 'F03A', 4, 'Senta no penico e faz xixi/cocô com ajuda?'),
    ('triagem', 'motora', 'F03A', 1, 'Corre sem tropeçar ou cair com frequência?'),
    ('triagem', 'motora', 'F03A', 2, 'Pega arroz, miçangas ou tampinhas com o polegar e o indicador?'),
    ('triagem', 'motora', 'F03A', 3, 'Empilha vários blocos com controle e intenção?'),
    ('triagem', 'motora', 'F03A', 4, 'Arremessa a bola para frente quando você pede?'),
    ('triagem', 'social', 'F03A', 1, 'Você faz 3 gestos e ele repete todos?'),
    ('triagem', 'social', 'F03A', 2, 'Finge dar comida, colocar pra dormir, etc.?'),
    ('triagem', 'social', 'F03A', 3, 'Aguenta esperar sua vez numa brincadeira estruturada?'),
    ('triagem', 'social', 'F03A', 4, 'Diz que está feliz, triste, bravo quando perguntado?'),
    ('triagem', 'cognitiva', 'F04A', 1, 'Presta atenção quando um adulto fala para o grupo?'),
    ('triagem', 'cognitiva', 'F04A', 2, 'Usa uma caixa como casa, ou um copo como tambor?'),
    ('triagem', 'cognitiva', 'F04A', 3, 'Junta a palavra “bola” com o desenho da bola?'),
    ('triagem', 'cognitiva', 'F04A', 4, 'Faz círculos, quadrados ou “pessoas” simples no papel?'),
    ('triagem', 'comunicacao', 'F04A', 1, 'Olha para você, depois para outra pessoa, em interações sociais?'),
    ('triagem', 'comunicacao', 'F04A', 2, 'Usa figuras para expressar desejos ou sentimentos?'),
    ('triagem', 'comunicacao', 'F04A', 3, 'Fala o nome das coisas do dia a dia sem ajuda?'),
    ('triagem', 'comunicacao', 'F04A', 4, 'Entende e responde perguntas simples sobre preferências?'),
    ('triagem', 'comunicacao', 'F04A', 5, 'Ex: “pega o livro, senta e abre na página”?'),
    ('triagem', 'funcional', 'F04A', 1, 'Come coisas variadas sem recusar por cor ou textura?'),
    ('triagem', 'funcional', 'F04A', 2, 'Consegue realizar essa rotina sem ajuda física?'),
    ('triagem', 'funcional', 'F04A', 3, 'Coloca a roupa com orientação mínima?'),
    ('triagem', 'funcional', 'F04A', 4, 'Vai ao vaso, se limpa e dá descarga com pouca supervisão?'),
    ('triagem', 'motora', 'F04A', 1, 'Pula do sofá ou degrau sem cair?'),
    ('triagem', 'motora', 'F04A', 2, 'Consegue cortar uma linha ou forma simples com tesoura sem ponta?'),
    ('triagem', 'motora', 'F04A', 3, 'Traça dentro da linha pontilhada?'),
    ('triagem', 'motora', 'F04A', 4, 'Consegue acertar o gol ou alvo ao chutar?'),
    ('triagem', 'social', 'F04A', 1, 'Vê alguém fazer e tenta imitar (sem instrução direta)?'),
    ('triagem', 'social', 'F04A', 2, 'Faz de conta que vai ao médico, supermercado, etc.?'),
    ('triagem', 'social', 'F04A', 3, 'Espera com paciência sua vez com outras crianças?'),
    ('triagem', 'social', 'F04A', 4, 'Consegue dizer se está bravo, ansioso, ou se alguém está triste?'),
    ('triagem', 'cognitiva', 'F05A', 1, 'Permanece engajado numa roda de conversa ou brincadeira em grupo?'),
    ('triagem', 'cognitiva', 'F05A', 2, 'Gosta de desmontar, explorar, testar como as coisas funcionam?'),
    ('triagem', 'cognitiva', 'F05A', 3, 'Junta frutas com frutas, roupas com roupas, etc.?'),
    ('triagem', 'cognitiva', 'F05A', 4, 'Copia do quadro ou de um caderno com letra legível?'),
    ('triagem', 'comunicacao', 'F05A', 1, 'Olha nos olhos enquanto fala ou escuta?'),
    ('triagem', 'comunicacao', 'F05A', 2, 'Usa imagens, escrita ou símbolos para se comunicar?'),
    ('triagem', 'comunicacao', 'F05A', 3, 'Responde e também faz perguntas numa conversa curta?'),
    ('triagem', 'comunicacao', 'F05A', 4, 'Consegue explicar algo quando você pergunta o motivo?'),
    ('triagem', 'comunicacao', 'F05A', 5, '“Abre o caderno”, “pega o lápis” – ele compreende?'),
    ('triagem', 'funcional', 'F05A', 1, 'Pega comida, corta com colher e come sozinho?'),
    ('triagem', 'funcional', 'F05A', 2, 'Faz os movimentos principais e lembra da rotina com apoio verbal?'),
    ('triagem', 'funcional', 'F05A', 3, 'Escolhe roupa, veste e guarda depois do uso?'),
    ('triagem', 'funcional', 'F05A', 4, 'Vai, se limpa, dá descarga e lava as mãos sozinho?'),
    ('triagem', 'motora', 'F05A', 1, 'Corre e pula sem se desequilibrar?'),
    ('triagem', 'motora', 'F05A', 2, 'Recorta círculo, quadrado ou figuras simples?'),
    ('triagem', 'motora', 'F05A', 3, 'Consegue montar figuras ou modelos com orientação?'),
    ('triagem', 'motora', 'F05A', 4, 'Consegue chutar, lançar ou segurar a bola de forma coordenada?'),
    ('triagem', 'social', 'F05A', 1, 'Vê outras crianças cumprimentando e imita?'),
    ('triagem', 'social', 'F05A', 2, 'Joga jogos de tabuleiro ou pega-pega com regras básicas?'),
    ('triagem', 'social', 'F05A', 3, 'Aceita perder ou esperar, mesmo ficando chateado?'),
    ('triagem', 'social', 'F05A', 4, 'Fala o que está sentindo e se acalma com orientação?'),
    ('triagem', 'cognitiva', 'F06A', 1, 'Fica engajado em rodas de conversa, dinâmicas ou trabalhos em grupo?'),
    ('triagem', 'cognitiva', 'F06A', 2, 'Quer saber como funciona, pergunta “por quê” e busca descobrir?'),
    ('triagem', 'cognitiva', 'F06A', 3, 'Junta palavras por função ou categoria (ex: meios de transporte, emoções)?'),
    ('triagem', 'cognitiva', 'F06A', 4, 'Consegue copiar e escrever com clareza?'),
    ('triagem', 'comunicacao', 'F06A', 1, 'Olha nos olhos enquanto conversa com alguém?'),
    ('triagem', 'comunicacao', 'F06A', 2, 'Escreve bilhetes, usa símbolos ou tecnologia para pedir ou contar algo?'),
    ('triagem', 'comunicacao', 'F06A', 3, 'Consegue manter um diálogo com perguntas e respostas?'),
    ('triagem', 'comunicacao', 'F06A', 4, '“Pega o caderno, escreve a data e senta” – ele realiza?'),
    ('triagem', 'comunicacao', 'F06A', 5, 'Compreende relações de causa e consequência simples?'),
    ('triagem', 'funcional', 'F06A', 1, 'Faz um sanduíche, pega iogurte, usa copo e colher sem ajuda?'),
    ('triagem', 'funcional', 'F06A', 2, 'Toma banho, escova os dentes, lava mãos e rosto sem ajuda constante?'),
    ('triagem', 'funcional', 'F06A', 3, 'Veste casaco quando está frio, roupa leve no calor, roupa correta para escola?'),
    ('triagem', 'funcional', 'F06A', 4, 'Vai ao banheiro público e realiza higiene com independência?'),
    ('triagem', 'motora', 'F06A', 1, 'Corre, chuta, salta e participa de jogos com regras corporais?'),
    ('triagem', 'motora', 'F06A', 2, 'Recorta, desenha, escreve ou pinta com boa coordenação?'),
    ('triagem', 'motora', 'F06A', 3, 'Monta estruturas com LEGO, papelão, palitos ou outros?'),
    ('triagem', 'motora', 'F06A', 4, 'Joga futebol, queimada ou vôlei com outros, respeitando o turno?'),
    ('triagem', 'social', 'F06A', 1, 'Vê como outras pessoas se comportam e imita em situações semelhantes?'),
    ('triagem', 'social', 'F06A', 2, 'Joga damas, futebol, jogos de tabuleiro com regras fixas?'),
    ('triagem', 'social', 'F06A', 3, 'Consegue aceitar perder, mudar de atividade ou adiar o que quer?'),
    ('triagem', 'social', 'F06A', 4, 'Diz que está frustrado, ansioso, orgulhoso, com vergonha, etc.?')
)
INSERT INTO questions (kind, skill_id, age_bracket_id, texto, ordem, status)
SELECT
  o.kind::question_kind,
  s.id,
  b.id,
  o.texto,
  o.ordem,
  'ativo'::record_status
FROM oficial o
JOIN skills s ON s.key = o.skill_key
JOIN age_brackets b ON b.codigo = o.faixa_codigo;

-- Se algum JOIN perder uma linha, a exceção faz a migration falhar em vez de
-- deixar um checklist incompleto.
DO $$
DECLARE
  v_total INTEGER;
BEGIN
  SELECT count(*) INTO v_total
  FROM questions
  WHERE status = 'ativo';

  IF v_total <> 150 THEN
    RAISE EXCEPTION 'esperava 150 perguntas oficiais ativas, encontrei %', v_total;
  END IF;
END $$;
