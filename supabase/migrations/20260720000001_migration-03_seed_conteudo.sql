-- migration-03: seed de conteúdo para o fluxo E2E.
-- Perguntas iniciais (5 por faixa), triagem (4 por habilidade por faixa),
-- atividades ABA (aquisição/generalização/manutenção por habilidade por faixa),
-- brincadeiras e artigos. Conteúdo genérico de MVP — refinar via backoffice.
-- Skills e age_brackets já foram seedados no baseline (migration-01).

-- ============================================================
-- 1. PERGUNTAS INICIAIS (mesmas 5 para toda faixa etária)
-- ============================================================

WITH t(skill_key, ordem, texto) AS (
  VALUES
    ('comunicacao', 1, 'A criança olha ou responde quando é chamada pelo nome?'),
    ('social',      2, 'A criança demonstra interesse por outras pessoas e busca interação?'),
    ('cognitiva',   3, 'A criança explora brinquedos e objetos com curiosidade?'),
    ('motora',      4, 'A criança manipula objetos pequenos com as mãos sem grande dificuldade?'),
    ('funcional',   5, 'A criança participa de rotinas simples do dia a dia (comer, vestir, guardar)?')
)
INSERT INTO questions (kind, skill_id, age_bracket_id, texto, ordem)
SELECT 'inicial'::question_kind, s.id, b.id, t.texto, t.ordem
FROM t
JOIN skills s ON s.key = t.skill_key
CROSS JOIN age_brackets b;

-- ============================================================
-- 2. PERGUNTAS DE TRIAGEM (4 por habilidade, para toda faixa)
-- ============================================================

WITH t(skill_key, ordem, texto) AS (
  VALUES
    ('comunicacao', 1, 'A criança usa gestos (apontar, acenar) para se comunicar?'),
    ('comunicacao', 2, 'A criança tenta imitar sons ou palavras?'),
    ('comunicacao', 3, 'A criança compreende instruções simples como "me dá" ou "vem cá"?'),
    ('comunicacao', 4, 'A criança expressa o que quer usando palavras ou vocalizações?'),
    ('social',      1, 'A criança mantém contato visual durante interações?'),
    ('social',      2, 'A criança brinca junto ou próxima de outras crianças?'),
    ('social',      3, 'A criança imita gestos ou expressões de outras pessoas?'),
    ('social',      4, 'A criança compartilha objetos ou mostra coisas para os adultos?'),
    ('cognitiva',   1, 'A criança encontra objetos escondidos durante brincadeiras?'),
    ('cognitiva',   2, 'A criança agrupa objetos por cor, forma ou tamanho?'),
    ('cognitiva',   3, 'A criança resolve problemas simples, como alcançar um brinquedo com apoio?'),
    ('cognitiva',   4, 'A criança mantém atenção em uma atividade por alguns minutos?'),
    ('motora',      1, 'A criança empilha blocos ou encaixa peças?'),
    ('motora',      2, 'A criança segura lápis ou giz e faz rabiscos?'),
    ('motora',      3, 'A criança corre, pula ou sobe pequenos obstáculos com equilíbrio?'),
    ('motora',      4, 'A criança usa talheres ou copo sem ajuda?'),
    ('funcional',   1, 'A criança ajuda a vestir-se ou a tirar peças de roupa?'),
    ('funcional',   2, 'A criança avisa ou demonstra quando precisa usar o banheiro (conforme a idade)?'),
    ('funcional',   3, 'A criança guarda brinquedos quando solicitada?'),
    ('funcional',   4, 'A criança se alimenta sozinha (conforme a idade)?')
)
INSERT INTO questions (kind, skill_id, age_bracket_id, texto, ordem)
SELECT 'triagem'::question_kind, s.id, b.id, t.texto, t.ordem
FROM t
JOIN skills s ON s.key = t.skill_key
CROSS JOIN age_brackets b;

-- ============================================================
-- 3. ATIVIDADES (exercises) — 3 níveis por habilidade, por faixa
-- ============================================================

WITH t(skill_key, seq, nivel, titulo, objetivo, procedimento, materiais) AS (
  VALUES
    ('comunicacao', 1, 'aquisicao',     'Imitar sons e palavras simples',
     'Desenvolver a imitação vocal como base da comunicação verbal.',
     'Sente-se de frente para a criança, produza um som ou palavra simples (ex.: "má", "au au") e aguarde a tentativa de imitação. Reforce imediatamente qualquer aproximação do som.',
     'Brinquedos sonoros, cartões de animais.'),
    ('comunicacao', 2, 'generalizacao', 'Usar palavras em situações novas',
     'Generalizar as palavras aprendidas para novos contextos e pessoas.',
     'Durante rotinas diferentes (refeição, banho, passeio), crie oportunidades para a criança usar as palavras treinadas com outras pessoas da família.',
     'Objetos do cotidiano relacionados às palavras treinadas.'),
    ('comunicacao', 3, 'manutencao',    'Revisão das palavras aprendidas',
     'Manter no repertório as palavras já dominadas.',
     'Revise as palavras dominadas em brincadeiras curtas ao longo da semana, intercalando com palavras novas para manter o interesse.',
     'Lista de palavras dominadas, cartões ilustrados.'),

    ('social', 1, 'aquisicao',     'Contato visual ao ser chamado',
     'Estabelecer contato visual em resposta ao nome.',
     'Chame o nome da criança em ambiente sem distrações; quando ela olhar, reforce com elogio e um item preferido. Aumente aos poucos a distância e as distrações.',
     'Itens preferidos da criança.'),
    ('social', 2, 'generalizacao', 'Brincadeiras de troca de turno',
     'Generalizar a interação social para brincadeiras com alternância.',
     'Brinque de passar a bola ou empilhar peças alternando turnos ("minha vez, sua vez"), incluindo irmãos ou colegas na brincadeira.',
     'Bola, blocos ou jogo de encaixe.'),
    ('social', 3, 'manutencao',    'Manter interações espontâneas',
     'Manter e ampliar interações sociais espontâneas.',
     'Crie oportunidades diárias de brincadeira conjunta e observe as interações espontâneas, reforçando cada iniciativa da criança.',
     'Brinquedos de interesse da criança.'),

    ('cognitiva', 1, 'aquisicao',     'Parear objetos iguais',
     'Desenvolver a habilidade de parear objetos idênticos.',
     'Apresente dois pares de objetos; entregue um item e peça "coloca com o igual". Ajude fisicamente se necessário e reduza a ajuda aos poucos.',
     'Pares de objetos ou figuras idênticas.'),
    ('cognitiva', 2, 'generalizacao', 'Categorizar por cor e forma',
     'Generalizar o pareamento para categorias como cor, forma e tamanho.',
     'Peça para a criança separar objetos variados em grupos por cor ou forma, trocando os materiais a cada sessão para evitar memorização.',
     'Blocos coloridos, figuras geométricas.'),
    ('cognitiva', 3, 'manutencao',    'Pareamento nas rotinas da casa',
     'Manter as habilidades de pareamento e categorização.',
     'Inclua o pareamento em tarefas rápidas da rotina: guardar talheres, separar roupas por cor, organizar brinquedos por tipo.',
     'Objetos da rotina da casa.'),

    ('motora', 1, 'aquisicao',     'Empilhar blocos',
     'Desenvolver a coordenação motora fina empilhando blocos.',
     'Demonstre empilhando 2 blocos e entregue os blocos à criança, incentivando-a a empilhar. Aumente a torre gradualmente conforme o sucesso.',
     'Blocos de encaixe ou de madeira.'),
    ('motora', 2, 'generalizacao', 'Encaixes e traçados',
     'Generalizar a coordenação fina para encaixes e traçados.',
     'Alterne atividades de encaixar peças, enfiar contas grandes em um cordão e rabiscar com giz em papel grande.',
     'Jogo de encaixe, contas grandes, giz de cera.'),
    ('motora', 3, 'manutencao',    'Circuito motor da semana',
     'Manter as habilidades motoras adquiridas.',
     'Monte um circuito curto misturando empilhar, encaixar e traçar, comemorando cada etapa concluída.',
     'Materiais das atividades anteriores.'),

    ('funcional', 1, 'aquisicao',     'Guardar brinquedos com ajuda',
     'Introduzir a rotina de guardar os brinquedos após o uso.',
     'Ao final da brincadeira, cante uma música de "hora de guardar" e guarde os brinquedos junto com a criança, diminuindo a ajuda a cada dia.',
     'Caixa ou cesto de brinquedos.'),
    ('funcional', 2, 'generalizacao', 'Participar de rotinas da casa',
     'Generalizar a participação para outras rotinas do dia a dia.',
     'Inclua a criança em pequenas tarefas: levar o prato à pia, colocar a roupa no cesto, sempre com instruções curtas e reforço imediato.',
     'Itens das rotinas diárias.'),
    ('funcional', 3, 'manutencao',    'Rotinas com autonomia',
     'Manter a participação autônoma nas rotinas diárias.',
     'Use um quadro visual de rotinas e deixe a criança marcar as tarefas concluídas do dia, revisando juntos ao final.',
     'Quadro de rotina visual com figuras.')
)
INSERT INTO exercises (
  skill_id, age_bracket_id, codigo, titulo, media_type, nivel, ordem, plano, status,
  objetivo, procedimento, materiais, frequencia, brincadeiras, hierarquia_dicas,
  resposta_esperada, procedimento_correcao, criterio_avanco, registro_dados, reforcos
)
SELECT
  s.id,
  b.id,
  b.codigo || '-' || upper(substr(s.key, 1, 3)) || '-' || lpad(t.seq::text, 2, '0'),
  t.titulo,
  'imagem'::media_type,
  t.nivel::exercise_level,
  t.seq,
  'free'::subscription_plan,
  'ativo'::record_status,
  t.objetivo,
  t.procedimento,
  t.materiais,
  '3 a 5 vezes por semana',
  'Transforme em brincadeira: use músicas, contagem e comemoração a cada acerto.',
  'Ajuda física total → ajuda física parcial → dica gestual → dica verbal → independente',
  'A criança realiza a ação alvo com cada vez menos ajuda.',
  'Se errar, retome com a menor ajuda necessária e reforce a tentativa.',
  '8 de 10 tentativas sem ajuda registradas no app.',
  'Registre cada repetição no app ao final de cada tentativa.',
  'Elogios entusiasmados, palmas e acesso breve a um item preferido.'
FROM t
JOIN skills s ON s.key = t.skill_key
CROSS JOIN age_brackets b;

-- ============================================================
-- 4. BRINCADEIRAS (plays)
-- ============================================================

INSERT INTO plays (titulo, descricao, instrucoes, media_type, plano) VALUES
  ('Caça ao tesouro sensorial',
   'Esconda objetos de texturas diferentes pela sala e explorem juntos cada descoberta.',
   'Esconda de 4 a 6 objetos de texturas variadas (macio, áspero, liso). Peça para a criança encontrar um por vez, nomeie a textura encontrada e comemorem juntos.',
   'imagem', 'free'),
  ('Quem imita primeiro?',
   'Brincadeira de imitação de sons e gestos para estimular comunicação e atenção.',
   'Faça um gesto ou som engraçado e incentive a criança a imitar. Depois inverta os papéis: ela cria e você imita. Comece com gestos simples e aumente a complexidade.',
   'imagem', 'free'),
  ('Circuito de almofadas',
   'Percurso simples em casa para pular, equilibrar e engatinhar.',
   'Monte um caminho com almofadas e travesseiros. Demonstre o percurso (pular, engatinhar, equilibrar) e faça junto com a criança, celebrando cada travessia.',
   'imagem', 'free'),
  ('Panela vira tambor',
   'Exploração musical com utensílios seguros da cozinha.',
   'Ofereça panelas, potes e colheres de pau. Alternem ritmos rápidos e lentos, altos e baixos. Cante músicas conhecidas acompanhando o ritmo.',
   'imagem', 'premium');

-- ============================================================
-- 5. ARTIGOS (articles)
-- ============================================================

INSERT INTO articles (titulo, corpo, plano) VALUES
  ('Como criar uma rotina previsível em casa',
   'Crianças em desenvolvimento — especialmente as atípicas — se beneficiam muito de rotinas previsíveis. Saber o que vem a seguir reduz a ansiedade e abre espaço para o aprendizado.' || E'\n\n' ||
   'Comece definindo horários consistentes para as principais atividades: acordar, refeições, brincadeiras e sono. Use apoios visuais (fotos ou desenhos das atividades) em um quadro na altura da criança e revise a sequência do dia junto com ela pela manhã.' || E'\n\n' ||
   'Mudanças acontecem — e tudo bem. Quando a rotina precisar mudar, avise a criança com antecedência e mostre no quadro o que será diferente. A previsibilidade não está na rigidez, mas na comunicação.',
   'free'),
  ('Reforço positivo: o segredo do aprendizado',
   'O reforço positivo é a base do ensino estruturado: quando um comportamento é seguido de algo bom, ele tende a se repetir. É assim que novas habilidades se fortalecem.' || E'\n\n' ||
   'O reforço deve vir imediatamente após o comportamento desejado — segundos importam. Pode ser um elogio entusiasmado, palmas, cócegas ou acesso breve a um brinquedo preferido. Descubra o que motiva a sua criança: cada uma tem seus próprios interesses.' || E'\n\n' ||
   'Atenção: reforce a tentativa, não apenas o acerto perfeito. Aproximações sucessivas do comportamento alvo merecem celebração, pois são elas que constroem o caminho do aprendizado.',
   'free'),
  ('Brincar é coisa séria: o papel do brincar no desenvolvimento',
   'Para a criança, brincar não é passatempo — é a principal ferramenta de aprendizado. É no brincar que ela pratica comunicação, interação social, resolução de problemas e coordenação motora.' || E'\n\n' ||
   'Reserve momentos diários de brincadeira livre, sem objetivos ou correções, seguindo o interesse da criança. Sente-se no chão, imite o que ela faz e espere que ela inicie interações. Esse "seguir a criança" fortalece o vínculo e a motivação.' || E'\n\n' ||
   'As atividades estruturadas do plano são importantes, mas o brincar espontâneo é onde as habilidades treinadas ganham vida. Equilibre os dois e observe a evolução acontecer.',
   'premium');
