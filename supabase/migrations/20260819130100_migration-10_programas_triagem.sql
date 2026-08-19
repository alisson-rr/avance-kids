-- ============================================================
-- migration-10: Programas Básicos de Engajamento (códigos AT)
--
-- GERADO POR scripts/import_programas.py — NÃO EDITAR À MÃO.
-- Fonte: AvanceKids-DOCUMENTACAO/LOGICA-ATUALIZADA/Programas_ABA_Completo_F01A_a_F06A_17_colunas.xlsx
--        (aba "Consolidado", mesmas 17 colunas dos demais programas)
--
-- POR QUE UMA TABELA SEPARADA E NÃO `exercises`
--
-- Os 24 códigos AT (F01AT001..F06AT004) têm as 17 colunas
-- preenchidas, exatamente como os 126 códigos do
-- checklist: são programas completos e precisam existir no banco.
--
-- Só que `exercises.skill_id` é NOT NULL REFERENCES skills(id) e o catálogo
-- tem exatamente 5 habilidades (baseline.sql:877 — comunicacao, social,
-- cognitiva, motora, funcional), espelhadas em HabilidadeKey no app. Inserir
-- AT ali exigiria decidir a habilidade de cada programa, e a coluna "Função"
-- não resolve: "Atenção conjunta" aparece tanto em AC quanto em AG na própria
-- planilha. Pior: toda linha de `exercises` é elegível para
-- generate-activity-plan, então o conteúdo entraria no plano da criança sem
-- que a regra de disparo estivesse definida.
--
-- Esta tabela guarda o conteúdo SEM skill_id, SEM `plano` e SEM qualquer
-- vínculo com activity_plans. Consequência: os dados passam a existir e podem
-- ser revisados no backoffice; a decisão de QUANDO usá-los (gatilho da
-- Triagem Inicial, rebaixamento de faixa) continua pendente da cliente e não
-- é antecipada por nenhuma linha deste arquivo.
--
-- Quando a regra for definida, o vínculo com a habilidade e com o plano entra
-- em uma migration nova; nada aqui precisa ser reescrito.
-- ============================================================

CREATE TABLE IF NOT EXISTS screening_programs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  codigo TEXT NOT NULL,
  age_bracket_id UUID NOT NULL REFERENCES age_brackets(id),
  titulo TEXT NOT NULL,
  nivel exercise_level NOT NULL,
  ordem INTEGER NOT NULL,

  -- Mesmas colunas de conteúdo de `exercises`, na mesma ordem da planilha.
  programa_aba TEXT,
  funcao TEXT,
  objetivo TEXT,
  procedimento TEXT,
  materiais TEXT,
  recursos_extras TEXT,
  frequencia TEXT,
  brincadeiras TEXT,
  hierarquia_dicas TEXT,
  resposta_esperada TEXT,
  procedimento_correcao TEXT,
  criterio_avanco TEXT,
  registro_dados TEXT,
  reforcos TEXT,

  status record_status NOT NULL DEFAULT 'ativo',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  CONSTRAINT uq_screening_programs_codigo_nivel UNIQUE (codigo, nivel)
);

COMMENT ON TABLE screening_programs IS
  'Programas Básicos de Engajamento (códigos AT) da planilha oficial. Conteúdo armazenado sem habilidade e sem vínculo com plano: a regra de utilização depende de definição da cliente.';
COMMENT ON COLUMN screening_programs.ordem IS
  'Sequência do código dentro da faixa (F01AT001 -> 1). Mesmo valor nos três níveis.';

CREATE INDEX IF NOT EXISTS idx_screening_programs_faixa
  ON screening_programs (age_bracket_id, ordem, nivel);

DROP TRIGGER IF EXISTS trg_screening_programs_updated_at ON screening_programs;
CREATE TRIGGER trg_screening_programs_updated_at
  BEFORE UPDATE ON screening_programs
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- RLS: só admin, por enquanto. O app não tem tela para este conteúdo porque
-- não há regra de quando exibi-lo; abrir a leitura para `authenticated` antes
-- disso entregaria conteúdo sem contexto. A policy de leitura do app entra
-- junto com a regra.
ALTER TABLE screening_programs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins manage screening programs"
  ON screening_programs FOR ALL
  TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- ── Conteúdo oficial ────────────────────────────────────────
WITH triagem(
  faixa_codigo, codigo, titulo, nivel, ordem,
  programa_aba, funcao, objetivo, procedimento, materiais,
  recursos_extras, frequencia, brincadeiras, hierarquia_dicas,
  resposta_esperada, procedimento_correcao, criterio_avanco,
  registro_dados, reforcos
) AS (
  VALUES
    ('F01A', 'F01AT001', 'Responde ao nome', 'aquisicao', 1, 'Contato visual com nome', 'Atenção conjunta', 'Ensinar/desenvolver a habilidade de responde ao nome com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Responde ao nome”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Responde ao nome”.', '1. Física: não utilizar para forçar contato visual.
2. Gestual: orientar suavemente para o interlocutor/estímulo.
3. Visual: posicionar o estímulo relevante no campo visual.
4. Verbal: lembrete curto, quando necessário.
5. I = Independente.', 'A criança realiza “Responde ao nome” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Não segurar o rosto nem exigir olhar fixo contínuo; valorizar orientação funcional ao interlocutor.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F01A', 'F01AT001', 'Responde ao nome', 'generalizacao', 1, 'Contato visual com nome', 'Atenção conjunta', 'Generalizar a habilidade de responde ao nome para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Responde ao nome”.', '1. Física: não utilizar para forçar contato visual.
2. Gestual: orientar suavemente para o interlocutor/estímulo.
3. Visual: posicionar o estímulo relevante no campo visual.
4. Verbal: lembrete curto, quando necessário.
5. I = Independente.', 'A criança realiza “Responde ao nome” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Não segurar o rosto nem exigir olhar fixo contínuo; valorizar orientação funcional ao interlocutor.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F01A', 'F01AT001', 'Responde ao nome', 'manutencao', 1, 'Contato visual com nome', 'Atenção conjunta', 'Manter a habilidade de responde ao nome de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Responde ao nome”.', '1. Física: não utilizar para forçar contato visual.
2. Gestual: orientar suavemente para o interlocutor/estímulo.
3. Visual: posicionar o estímulo relevante no campo visual.
4. Verbal: lembrete curto, quando necessário.
5. I = Independente.', 'A criança mantém “Responde ao nome” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Não segurar o rosto nem exigir olhar fixo contínuo; valorizar orientação funcional ao interlocutor.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F01A', 'F01AT002', 'Senta-se sem apoio', 'aquisicao', 2, 'Estabilidade postural sentada', 'Motora global', 'Ensinar/desenvolver a habilidade de senta-se sem apoio com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Senta-se sem apoio”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Senta-se sem apoio”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Senta-se sem apoio” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F01A', 'F01AT002', 'Senta-se sem apoio', 'generalizacao', 2, 'Estabilidade postural sentada', 'Motora global', 'Generalizar a habilidade de senta-se sem apoio para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Senta-se sem apoio”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Senta-se sem apoio” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F01A', 'F01AT002', 'Senta-se sem apoio', 'manutencao', 2, 'Estabilidade postural sentada', 'Motora global', 'Manter a habilidade de senta-se sem apoio de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Senta-se sem apoio”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Senta-se sem apoio” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F01A', 'F01AT003', 'Aponta ou tenta pegar o que deseja', 'aquisicao', 3, 'Solicitação por aproximação', 'Comunicação funcional', 'Ensinar/desenvolver a habilidade de aponta ou tenta pegar o que deseja com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Aponta ou tenta pegar o que deseja”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Aponta ou tenta pegar o que deseja”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Aponta ou tenta pegar o que deseja” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F01A', 'F01AT003', 'Aponta ou tenta pegar o que deseja', 'generalizacao', 3, 'Solicitação por aproximação', 'Comunicação funcional', 'Generalizar a habilidade de aponta ou tenta pegar o que deseja para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Aponta ou tenta pegar o que deseja”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Aponta ou tenta pegar o que deseja” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F01A', 'F01AT003', 'Aponta ou tenta pegar o que deseja', 'manutencao', 3, 'Solicitação por aproximação', 'Comunicação funcional', 'Manter a habilidade de aponta ou tenta pegar o que deseja de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Aponta ou tenta pegar o que deseja”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Aponta ou tenta pegar o que deseja” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F01A', 'F01AT004', 'Segue instruções simples', 'aquisicao', 4, 'Comandos simples com objetos', 'Linguagem receptiva', 'Ensinar/desenvolver a habilidade de segue instruções simples com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Segue instruções simples”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Segue instruções simples”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Segue instruções simples” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F01A', 'F01AT004', 'Segue instruções simples', 'generalizacao', 4, 'Comandos simples com objetos', 'Linguagem receptiva', 'Generalizar a habilidade de segue instruções simples para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Segue instruções simples”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Segue instruções simples” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F01A', 'F01AT004', 'Segue instruções simples', 'manutencao', 4, 'Comandos simples com objetos', 'Linguagem receptiva', 'Manter a habilidade de segue instruções simples de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Segue instruções simples”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Segue instruções simples” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F02A', 'F02AT001', 'Aponta para o que deseja', 'aquisicao', 1, 'Comunicação funcional em situações naturais', 'Comunicação funcional', 'Ensinar/desenvolver a habilidade de aponta para o que deseja com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Aponta para o que deseja”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Aponta para o que deseja”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Aponta para o que deseja” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F02A', 'F02AT001', 'Aponta para o que deseja', 'generalizacao', 1, 'Comunicação funcional em situações naturais', 'Comunicação funcional', 'Generalizar a habilidade de aponta para o que deseja para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Aponta para o que deseja”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Aponta para o que deseja” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F02A', 'F02AT001', 'Aponta para o que deseja', 'manutencao', 1, 'Comunicação funcional em situações naturais', 'Comunicação funcional', 'Manter a habilidade de aponta para o que deseja de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Aponta para o que deseja”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Aponta para o que deseja” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F02A', 'F02AT002', 'Imita gestos simples', 'aquisicao', 2, 'Imitação funcional com modelagem', 'Imitação', 'Ensinar/desenvolver a habilidade de imita gestos simples com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Imita gestos simples”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Imita gestos simples”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Imita gestos simples” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F02A', 'F02AT002', 'Imita gestos simples', 'generalizacao', 2, 'Imitação funcional com modelagem', 'Imitação', 'Generalizar a habilidade de imita gestos simples para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Imita gestos simples”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Imita gestos simples” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F02A', 'F02AT002', 'Imita gestos simples', 'manutencao', 2, 'Imitação funcional com modelagem', 'Imitação', 'Manter a habilidade de imita gestos simples de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Imita gestos simples”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Imita gestos simples” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F02A', 'F02AT003', 'Segue instruções de 1 a 2 passos', 'aquisicao', 3, 'Treino funcional de seguimento de instruções', 'Linguagem receptiva', 'Ensinar/desenvolver a habilidade de segue instruções de 1 a 2 passos com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Segue instruções de 1 a 2 passos”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Segue instruções de 1 a 2 passos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Segue instruções de 1 a 2 passos” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F02A', 'F02AT003', 'Segue instruções de 1 a 2 passos', 'generalizacao', 3, 'Treino funcional de seguimento de instruções', 'Linguagem receptiva', 'Generalizar a habilidade de segue instruções de 1 a 2 passos para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Segue instruções de 1 a 2 passos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Segue instruções de 1 a 2 passos” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F02A', 'F02AT003', 'Segue instruções de 1 a 2 passos', 'manutencao', 3, 'Treino funcional de seguimento de instruções', 'Linguagem receptiva', 'Manter a habilidade de segue instruções de 1 a 2 passos de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Segue instruções de 1 a 2 passos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Segue instruções de 1 a 2 passos” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F02A', 'F02AT004', 'Participa de brincadeira com turnos simples', 'aquisicao', 4, 'Participação em brincadeiras e jogos com regras', 'Brincar', 'Ensinar/desenvolver a habilidade de participa de brincadeira com turnos simples com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Participa de brincadeira com turnos simples”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Participa de brincadeira com turnos simples”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Participa de brincadeira com turnos simples” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F02A', 'F02AT004', 'Participa de brincadeira com turnos simples', 'generalizacao', 4, 'Participação em brincadeiras e jogos com regras', 'Brincar', 'Generalizar a habilidade de participa de brincadeira com turnos simples para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Participa de brincadeira com turnos simples”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Participa de brincadeira com turnos simples” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F02A', 'F02AT004', 'Participa de brincadeira com turnos simples', 'manutencao', 4, 'Participação em brincadeiras e jogos com regras', 'Brincar', 'Manter a habilidade de participa de brincadeira com turnos simples de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Participa de brincadeira com turnos simples”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Participa de brincadeira com turnos simples” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F03A', 'F03AT001', 'Pede o que quer com palavras ou gestos', 'aquisicao', 1, 'Comunicação funcional em situações naturais', 'Comunicação funcional', 'Ensinar/desenvolver a habilidade de pede o que quer com palavras ou gestos com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Pede o que quer com palavras ou gestos”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Pede o que quer com palavras ou gestos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Pede o que quer com palavras ou gestos” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F03A', 'F03AT001', 'Pede o que quer com palavras ou gestos', 'generalizacao', 1, 'Comunicação funcional em situações naturais', 'Comunicação funcional', 'Generalizar a habilidade de pede o que quer com palavras ou gestos para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Pede o que quer com palavras ou gestos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Pede o que quer com palavras ou gestos” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F03A', 'F03AT001', 'Pede o que quer com palavras ou gestos', 'manutencao', 1, 'Comunicação funcional em situações naturais', 'Comunicação funcional', 'Manter a habilidade de pede o que quer com palavras ou gestos de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Pede o que quer com palavras ou gestos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Pede o que quer com palavras ou gestos” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F03A', 'F03AT002', 'Imita sequências simples com brinquedos', 'aquisicao', 2, 'Imitação funcional com modelagem', 'Imitação', 'Ensinar/desenvolver a habilidade de imita sequências simples com brinquedos com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Imita sequências simples com brinquedos”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Imita sequências simples com brinquedos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Imita sequências simples com brinquedos” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F03A', 'F03AT002', 'Imita sequências simples com brinquedos', 'generalizacao', 2, 'Imitação funcional com modelagem', 'Imitação', 'Generalizar a habilidade de imita sequências simples com brinquedos para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Imita sequências simples com brinquedos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Imita sequências simples com brinquedos” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F03A', 'F03AT002', 'Imita sequências simples com brinquedos', 'manutencao', 2, 'Imitação funcional com modelagem', 'Imitação', 'Manter a habilidade de imita sequências simples com brinquedos de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Imita sequências simples com brinquedos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Imita sequências simples com brinquedos” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F03A', 'F03AT003', 'Aguarda a vez por pelo menos 1 minuto', 'aquisicao', 3, 'Treino gradual de espera e tolerância', 'Tolerância', 'Ensinar/desenvolver a habilidade de aguarda a vez por pelo menos 1 minuto com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Aguarda a vez por pelo menos 1 minuto”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Aguarda a vez por pelo menos 1 minuto”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Aguarda a vez por pelo menos 1 minuto” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F03A', 'F03AT003', 'Aguarda a vez por pelo menos 1 minuto', 'generalizacao', 3, 'Treino gradual de espera e tolerância', 'Tolerância', 'Generalizar a habilidade de aguarda a vez por pelo menos 1 minuto para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Aguarda a vez por pelo menos 1 minuto”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Aguarda a vez por pelo menos 1 minuto” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F03A', 'F03AT003', 'Aguarda a vez por pelo menos 1 minuto', 'manutencao', 3, 'Treino gradual de espera e tolerância', 'Tolerância', 'Manter a habilidade de aguarda a vez por pelo menos 1 minuto de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Aguarda a vez por pelo menos 1 minuto”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Aguarda a vez por pelo menos 1 minuto” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F03A', 'F03AT004', 'Entende comandos com 2 passos', 'aquisicao', 4, 'Treino funcional de seguimento de instruções', 'Linguagem receptiva', 'Ensinar/desenvolver a habilidade de entende comandos com 2 passos com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Entende comandos com 2 passos”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Entende comandos com 2 passos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Entende comandos com 2 passos” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F03A', 'F03AT004', 'Entende comandos com 2 passos', 'generalizacao', 4, 'Treino funcional de seguimento de instruções', 'Linguagem receptiva', 'Generalizar a habilidade de entende comandos com 2 passos para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Entende comandos com 2 passos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Entende comandos com 2 passos” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F03A', 'F03AT004', 'Entende comandos com 2 passos', 'manutencao', 4, 'Treino funcional de seguimento de instruções', 'Linguagem receptiva', 'Manter a habilidade de entende comandos com 2 passos de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Entende comandos com 2 passos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Entende comandos com 2 passos” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F04A', 'F04AT001', 'Pede o que quer com palavras ou figuras', 'aquisicao', 1, 'Comunicação funcional em situações naturais', 'Comunicação funcional', 'Ensinar/desenvolver a habilidade de pede o que quer com palavras ou figuras com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Pede o que quer com palavras ou figuras”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Sistema de CAA já utilizado; figuras/símbolos; itens e atividades motivadoras.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Pede o que quer com palavras ou figuras”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Pede o que quer com palavras ou figuras” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F04A', 'F04AT001', 'Pede o que quer com palavras ou figuras', 'generalizacao', 1, 'Comunicação funcional em situações naturais', 'Comunicação funcional', 'Generalizar a habilidade de pede o que quer com palavras ou figuras para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Sistema de CAA já utilizado; figuras/símbolos; itens e atividades motivadoras.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Pede o que quer com palavras ou figuras”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Pede o que quer com palavras ou figuras” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F04A', 'F04AT001', 'Pede o que quer com palavras ou figuras', 'manutencao', 1, 'Comunicação funcional em situações naturais', 'Comunicação funcional', 'Manter a habilidade de pede o que quer com palavras ou figuras de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Sistema de CAA já utilizado; figuras/símbolos; itens e atividades motivadoras.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Pede o que quer com palavras ou figuras”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Pede o que quer com palavras ou figuras” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F04A', 'F04AT002', 'Imita sequências com brinquedos', 'aquisicao', 2, 'Imitação funcional com modelagem', 'Imitação', 'Ensinar/desenvolver a habilidade de imita sequências com brinquedos com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Imita sequências com brinquedos”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Imita sequências com brinquedos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Imita sequências com brinquedos” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F04A', 'F04AT002', 'Imita sequências com brinquedos', 'generalizacao', 2, 'Imitação funcional com modelagem', 'Imitação', 'Generalizar a habilidade de imita sequências com brinquedos para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Imita sequências com brinquedos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Imita sequências com brinquedos” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F04A', 'F04AT002', 'Imita sequências com brinquedos', 'manutencao', 2, 'Imitação funcional com modelagem', 'Imitação', 'Manter a habilidade de imita sequências com brinquedos de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Imita sequências com brinquedos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Imita sequências com brinquedos” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F04A', 'F04AT003', 'Espera sua vez por pelo menos 1 minuto', 'aquisicao', 3, 'Treino gradual de espera e tolerância', 'Tolerância', 'Ensinar/desenvolver a habilidade de espera sua vez por pelo menos 1 minuto com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Espera sua vez por pelo menos 1 minuto”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Espera sua vez por pelo menos 1 minuto”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Espera sua vez por pelo menos 1 minuto” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F04A', 'F04AT003', 'Espera sua vez por pelo menos 1 minuto', 'generalizacao', 3, 'Treino gradual de espera e tolerância', 'Tolerância', 'Generalizar a habilidade de espera sua vez por pelo menos 1 minuto para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Espera sua vez por pelo menos 1 minuto”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Espera sua vez por pelo menos 1 minuto” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F04A', 'F04AT003', 'Espera sua vez por pelo menos 1 minuto', 'manutencao', 3, 'Treino gradual de espera e tolerância', 'Tolerância', 'Manter a habilidade de espera sua vez por pelo menos 1 minuto de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Espera sua vez por pelo menos 1 minuto”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Espera sua vez por pelo menos 1 minuto” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F04A', 'F04AT004', 'Entende comandos com 3 passos', 'aquisicao', 4, 'Treino funcional de seguimento de instruções', 'Linguagem receptiva', 'Ensinar/desenvolver a habilidade de entende comandos com 3 passos com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Entende comandos com 3 passos”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Entende comandos com 3 passos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Entende comandos com 3 passos” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F04A', 'F04AT004', 'Entende comandos com 3 passos', 'generalizacao', 4, 'Treino funcional de seguimento de instruções', 'Linguagem receptiva', 'Generalizar a habilidade de entende comandos com 3 passos para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Entende comandos com 3 passos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Entende comandos com 3 passos” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F04A', 'F04AT004', 'Entende comandos com 3 passos', 'manutencao', 4, 'Treino funcional de seguimento de instruções', 'Linguagem receptiva', 'Manter a habilidade de entende comandos com 3 passos de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Entende comandos com 3 passos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Entende comandos com 3 passos” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F05A', 'F05AT001', 'Compreende instruções com 3 passos', 'aquisicao', 1, 'Treino funcional de seguimento de instruções', 'Linguagem receptiva', 'Ensinar/desenvolver a habilidade de compreende instruções com 3 passos com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Compreende instruções com 3 passos”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Compreende instruções com 3 passos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Compreende instruções com 3 passos” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F05A', 'F05AT001', 'Compreende instruções com 3 passos', 'generalizacao', 1, 'Treino funcional de seguimento de instruções', 'Linguagem receptiva', 'Generalizar a habilidade de compreende instruções com 3 passos para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Compreende instruções com 3 passos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Compreende instruções com 3 passos” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F05A', 'F05AT001', 'Compreende instruções com 3 passos', 'manutencao', 1, 'Treino funcional de seguimento de instruções', 'Linguagem receptiva', 'Manter a habilidade de compreende instruções com 3 passos de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Compreende instruções com 3 passos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Compreende instruções com 3 passos” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F05A', 'F05AT002', 'Participa de jogos com regras simples', 'aquisicao', 2, 'Participação em brincadeiras e jogos com regras', 'Brincar com regras', 'Ensinar/desenvolver a habilidade de participa de jogos com regras simples com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Participa de jogos com regras simples”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Participa de jogos com regras simples”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Participa de jogos com regras simples” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F05A', 'F05AT002', 'Participa de jogos com regras simples', 'generalizacao', 2, 'Participação em brincadeiras e jogos com regras', 'Brincar com regras', 'Generalizar a habilidade de participa de jogos com regras simples para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Participa de jogos com regras simples”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Participa de jogos com regras simples” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F05A', 'F05AT002', 'Participa de jogos com regras simples', 'manutencao', 2, 'Participação em brincadeiras e jogos com regras', 'Brincar com regras', 'Manter a habilidade de participa de jogos com regras simples de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Participa de jogos com regras simples”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Participa de jogos com regras simples” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F05A', 'F05AT003', 'Usa o banheiro e realiza higiene sem ajuda constante', 'aquisicao', 3, 'Rotina funcional de banheiro', 'Funcional', 'Ensinar/desenvolver a habilidade de usa o banheiro e realiza higiene sem ajuda constante com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Usa o banheiro e realiza higiene sem ajuda constante”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Itens reais da rotina de higiene; apoio visual opcional.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Usa o banheiro e realiza higiene sem ajuda constante”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Usa o banheiro e realiza higiene sem ajuda constante” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Evitar punição, vergonha ou permanência forçada no vaso/penico.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F05A', 'F05AT003', 'Usa o banheiro e realiza higiene sem ajuda constante', 'generalizacao', 3, 'Rotina funcional de banheiro', 'Funcional', 'Generalizar a habilidade de usa o banheiro e realiza higiene sem ajuda constante para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Itens reais da rotina de higiene; apoio visual opcional.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Usa o banheiro e realiza higiene sem ajuda constante”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Usa o banheiro e realiza higiene sem ajuda constante” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Evitar punição, vergonha ou permanência forçada no vaso/penico.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F05A', 'F05AT003', 'Usa o banheiro e realiza higiene sem ajuda constante', 'manutencao', 3, 'Rotina funcional de banheiro', 'Funcional', 'Manter a habilidade de usa o banheiro e realiza higiene sem ajuda constante de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Itens reais da rotina de higiene; apoio visual opcional.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Usa o banheiro e realiza higiene sem ajuda constante”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Usa o banheiro e realiza higiene sem ajuda constante” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Evitar punição, vergonha ou permanência forçada no vaso/penico.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F05A', 'F05AT004', 'Expressa desejos ou sentimentos com clareza', 'aquisicao', 4, 'Comunicação funcional em situações naturais', 'Comunicação funcional', 'Ensinar/desenvolver a habilidade de expressa desejos ou sentimentos com clareza com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Expressa desejos ou sentimentos com clareza”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Expressa desejos ou sentimentos com clareza”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Expressa desejos ou sentimentos com clareza” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F05A', 'F05AT004', 'Expressa desejos ou sentimentos com clareza', 'generalizacao', 4, 'Comunicação funcional em situações naturais', 'Comunicação funcional', 'Generalizar a habilidade de expressa desejos ou sentimentos com clareza para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Expressa desejos ou sentimentos com clareza”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Expressa desejos ou sentimentos com clareza” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F05A', 'F05AT004', 'Expressa desejos ou sentimentos com clareza', 'manutencao', 4, 'Comunicação funcional em situações naturais', 'Comunicação funcional', 'Manter a habilidade de expressa desejos ou sentimentos com clareza de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Expressa desejos ou sentimentos com clareza”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Expressa desejos ou sentimentos com clareza” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F06A', 'F06AT001', 'Segue instruções de 3 ou mais passos', 'aquisicao', 1, 'Treino funcional de seguimento de instruções', 'Linguagem receptiva', 'Ensinar/desenvolver a habilidade de segue instruções de 3 ou mais passos com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Segue instruções de 3 ou mais passos”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Segue instruções de 3 ou mais passos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Segue instruções de 3 ou mais passos” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F06A', 'F06AT001', 'Segue instruções de 3 ou mais passos', 'generalizacao', 1, 'Treino funcional de seguimento de instruções', 'Linguagem receptiva', 'Generalizar a habilidade de segue instruções de 3 ou mais passos para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Segue instruções de 3 ou mais passos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Segue instruções de 3 ou mais passos” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F06A', 'F06AT001', 'Segue instruções de 3 ou mais passos', 'manutencao', 1, 'Treino funcional de seguimento de instruções', 'Linguagem receptiva', 'Manter a habilidade de segue instruções de 3 ou mais passos de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Segue instruções de 3 ou mais passos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Segue instruções de 3 ou mais passos” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F06A', 'F06AT002', 'Participa de jogos com regras e turnos', 'aquisicao', 2, 'Participação em brincadeiras e jogos com regras', 'Brincar com regras', 'Ensinar/desenvolver a habilidade de participa de jogos com regras e turnos com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Participa de jogos com regras e turnos”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Participa de jogos com regras e turnos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Participa de jogos com regras e turnos” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F06A', 'F06AT002', 'Participa de jogos com regras e turnos', 'generalizacao', 2, 'Participação em brincadeiras e jogos com regras', 'Brincar com regras', 'Generalizar a habilidade de participa de jogos com regras e turnos para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Participa de jogos com regras e turnos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Participa de jogos com regras e turnos” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F06A', 'F06AT002', 'Participa de jogos com regras e turnos', 'manutencao', 2, 'Participação em brincadeiras e jogos com regras', 'Brincar com regras', 'Manter a habilidade de participa de jogos com regras e turnos de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Participa de jogos com regras e turnos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Participa de jogos com regras e turnos” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F06A', 'F06AT003', 'Usa o banheiro e realiza higiene mesmo fora de casa', 'aquisicao', 3, 'Rotina funcional de banheiro', 'Funcional', 'Ensinar/desenvolver a habilidade de usa o banheiro e realiza higiene mesmo fora de casa com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Usa o banheiro e realiza higiene mesmo fora de casa”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Itens reais da rotina de higiene; apoio visual opcional.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Usa o banheiro e realiza higiene mesmo fora de casa”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Usa o banheiro e realiza higiene mesmo fora de casa” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Evitar punição, vergonha ou permanência forçada no vaso/penico.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F06A', 'F06AT003', 'Usa o banheiro e realiza higiene mesmo fora de casa', 'generalizacao', 3, 'Rotina funcional de banheiro', 'Funcional', 'Generalizar a habilidade de usa o banheiro e realiza higiene mesmo fora de casa para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Itens reais da rotina de higiene; apoio visual opcional.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Usa o banheiro e realiza higiene mesmo fora de casa”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Usa o banheiro e realiza higiene mesmo fora de casa” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Evitar punição, vergonha ou permanência forçada no vaso/penico.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F06A', 'F06AT003', 'Usa o banheiro e realiza higiene mesmo fora de casa', 'manutencao', 3, 'Rotina funcional de banheiro', 'Funcional', 'Manter a habilidade de usa o banheiro e realiza higiene mesmo fora de casa de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Itens reais da rotina de higiene; apoio visual opcional.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Usa o banheiro e realiza higiene mesmo fora de casa”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Usa o banheiro e realiza higiene mesmo fora de casa” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Evitar punição, vergonha ou permanência forçada no vaso/penico.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F06A', 'F06AT004', 'Expressa sentimentos e faz pedidos com clareza', 'aquisicao', 4, 'Comunicação funcional em situações naturais', 'Comunicação funcional', 'Ensinar/desenvolver a habilidade de expressa sentimentos e faz pedidos com clareza com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Expressa sentimentos e faz pedidos com clareza”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Expressa sentimentos e faz pedidos com clareza”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Expressa sentimentos e faz pedidos com clareza” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F06A', 'F06AT004', 'Expressa sentimentos e faz pedidos com clareza', 'generalizacao', 4, 'Comunicação funcional em situações naturais', 'Comunicação funcional', 'Generalizar a habilidade de expressa sentimentos e faz pedidos com clareza para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Expressa sentimentos e faz pedidos com clareza”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Expressa sentimentos e faz pedidos com clareza” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('F06A', 'F06AT004', 'Expressa sentimentos e faz pedidos com clareza', 'manutencao', 4, 'Comunicação funcional em situações naturais', 'Comunicação funcional', 'Manter a habilidade de expressa sentimentos e faz pedidos com clareza de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Expressa sentimentos e faz pedidos com clareza”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Expressa sentimentos e faz pedidos com clareza” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.')
)
INSERT INTO screening_programs (
  codigo, age_bracket_id, titulo, nivel, ordem,
  programa_aba, funcao, objetivo, procedimento, materiais, recursos_extras,
  frequencia, brincadeiras, hierarquia_dicas, resposta_esperada,
  procedimento_correcao, criterio_avanco, registro_dados, reforcos
)
SELECT
  t.codigo,
  b.id,
  t.titulo,
  t.nivel::exercise_level,
  t.ordem,
  t.programa_aba, t.funcao, t.objetivo, t.procedimento, t.materiais,
  t.recursos_extras, t.frequencia, t.brincadeiras, t.hierarquia_dicas,
  t.resposta_esperada, t.procedimento_correcao, t.criterio_avanco,
  t.registro_dados, t.reforcos
FROM triagem t
JOIN age_brackets b ON b.codigo = t.faixa_codigo
ON CONFLICT (codigo, nivel) DO NOTHING;

-- ── Conferência ─────────────────────────────────────────────
DO $$
DECLARE
  v_total INTEGER;
  v_vinculo INTEGER;
BEGIN
  SELECT count(*) INTO v_total FROM screening_programs;
  IF v_total <> 72 THEN
    RAISE EXCEPTION 'esperava 72 programas de triagem, encontrei %', v_total;
  END IF;

  -- Nenhum código AT pode ter vazado para `exercises`: é lá que
  -- generate-activity-plan procura conteúdo para a criança.
  SELECT count(*) INTO v_vinculo FROM exercises WHERE codigo ~ '^F0[1-6]AT[0-9]{3}$';
  IF v_vinculo <> 0 THEN
    RAISE EXCEPTION 'códigos AT não podem estar em exercises (achei %)', v_vinculo;
  END IF;
END $$;
