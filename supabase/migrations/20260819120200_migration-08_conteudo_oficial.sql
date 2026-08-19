-- ============================================================
-- migration-08: conteúdo oficial dos Programas ABA
--
-- GERADO POR scripts/import_programas.py — NÃO EDITAR À MÃO.
-- Fonte: AvanceKids-DOCUMENTACAO/LOGICA-ATUALIZADA/Programas_ABA_Completo_F01A_a_F06A_17_colunas.xlsx
--        (aba "Consolidado", 450 linhas, 150 códigos x 3 níveis)
--
-- O que esta migration faz:
--   1. adiciona `programa_aba` e `funcao` em exercises — as duas colunas da
--      planilha oficial que não tinham destino no schema;
--   2. aposenta as atividades genéricas semeadas por migration-03
--      (o próprio arquivo se declara "Conteúdo genérico de MVP");
--   3. insere 378 atividades oficiais (126 códigos x 3 níveis).
--
-- O que esta migration NÃO faz:
--   * não altera generate-activity-plan, check_exercise_completion,
--     resolve_age_bracket nem qualquer regra de recomendação/progressão;
--   * não coloca em `exercises` os 24 códigos de triagem AT
--     (F01AT001..F06AT004) — são os Programas Básicos de
--     Engajamento e vão para `screening_programs` na migration-10, sem
--     habilidade e sem vínculo com plano: o conteúdo existe, a regra de
--     disparo continua pendente de definição da cliente;
--   * não marca nenhuma atividade como premium (todas entram como 'free',
--     igual ao seed anterior).
--
-- Compatibilidade com dados existentes:
--   As atividades antigas ainda referenciadas por algum activity_plans são
--   arquivadas em vez de removidas, para não violar a FK e não apagar o
--   histórico de nenhuma criança. Crianças que já tinham plano continuam
--   apontando para a atividade antiga (arquivada) e só passam a ver o
--   conteúdo oficial ao refazer a triagem, que regera o plano.
-- ============================================================

-- ── 1. Colunas novas ────────────────────────────────────────
ALTER TABLE exercises ADD COLUMN IF NOT EXISTS programa_aba TEXT;
ALTER TABLE exercises ADD COLUMN IF NOT EXISTS funcao TEXT;

COMMENT ON COLUMN exercises.programa_aba IS 'Nome do programa ABA na planilha oficial (coluna "Programa ABA").';
COMMENT ON COLUMN exercises.funcao IS 'Função comportamental alvo na planilha oficial (coluna "Função").';

-- ── 2. Aposentar o conteúdo placeholder ─────────────────────
-- O seed de migration-03 gerava o código como `<faixa>-<SKI>-<n>` (ex.:
-- 'F01A-COM-01'); o código oficial não tem hífen (ex.: 'F01AC001'). O padrão
-- com hífen isola exatamente as linhas do placeholder.
DELETE FROM exercises
WHERE codigo ~ '^F0[1-6]A-'
  AND NOT EXISTS (SELECT 1 FROM activity_plans ap WHERE ap.exercise_id = exercises.id);

UPDATE exercises SET status = 'arquivado'
WHERE codigo ~ '^F0[1-6]A-' AND status <> 'arquivado';

-- ── 3. Conteúdo oficial ─────────────────────────────────────
WITH oficial(
  skill_key, faixa_codigo, codigo, titulo, nivel, ordem,
  programa_aba, funcao, objetivo, procedimento, materiais,
  recursos_extras, frequencia, brincadeiras, hierarquia_dicas,
  resposta_esperada, procedimento_correcao, criterio_avanco,
  registro_dados, reforcos
) AS (
  VALUES
    ('cognitiva', 'F01A', 'F01AG001', 'Olha para o que você aponta', 'aquisicao', 1, 'Atenção conjunta com estímulo visual', 'Atenção conjunta', 'Ensinar/desenvolver a habilidade de olha para o que você aponta com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Olha para o que você aponta”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Olha para o que você aponta”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Olha para o que você aponta” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F01A', 'F01AG001', 'Olha para o que você aponta', 'generalizacao', 1, 'Atenção conjunta com estímulo visual', 'Atenção conjunta', 'Generalizar a habilidade de olha para o que você aponta para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Olha para o que você aponta”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Olha para o que você aponta” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F01A', 'F01AG001', 'Olha para o que você aponta', 'manutencao', 1, 'Atenção conjunta com estímulo visual', 'Atenção conjunta', 'Manter a habilidade de olha para o que você aponta de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Olha para o que você aponta”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Olha para o que você aponta” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F01A', 'F01AG002', 'Explora brinquedos com curiosidade', 'aquisicao', 2, 'Estímulo ao comportamento exploratório', 'Exploração', 'Ensinar/desenvolver a habilidade de explora brinquedos com curiosidade com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Explora brinquedos com curiosidade”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Explora brinquedos com curiosidade”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Explora brinquedos com curiosidade” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F01A', 'F01AG002', 'Explora brinquedos com curiosidade', 'generalizacao', 2, 'Estímulo ao comportamento exploratório', 'Exploração', 'Generalizar a habilidade de explora brinquedos com curiosidade para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Explora brinquedos com curiosidade”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Explora brinquedos com curiosidade” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F01A', 'F01AG002', 'Explora brinquedos com curiosidade', 'manutencao', 2, 'Estímulo ao comportamento exploratório', 'Exploração', 'Manter a habilidade de explora brinquedos com curiosidade de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Explora brinquedos com curiosidade”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Explora brinquedos com curiosidade” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F01A', 'F01AG003', 'Coloca objetos dentro de potes', 'aquisicao', 3, 'Combinações simples com reforço', 'Combinação', 'Ensinar/desenvolver a habilidade de coloca objetos dentro de potes com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Coloca objetos dentro de potes”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Brinquedos/objetos adequados à habilidade; modelos simples.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Coloca objetos dentro de potes”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Coloca objetos dentro de potes” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F01A', 'F01AG003', 'Coloca objetos dentro de potes', 'generalizacao', 3, 'Combinações simples com reforço', 'Combinação', 'Generalizar a habilidade de coloca objetos dentro de potes para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Brinquedos/objetos adequados à habilidade; modelos simples.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Coloca objetos dentro de potes”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Coloca objetos dentro de potes” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F01A', 'F01AG003', 'Coloca objetos dentro de potes', 'manutencao', 3, 'Combinações simples com reforço', 'Combinação', 'Manter a habilidade de coloca objetos dentro de potes de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Brinquedos/objetos adequados à habilidade; modelos simples.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Coloca objetos dentro de potes”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Coloca objetos dentro de potes” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F01A', 'F01AG004', 'Rabisca com giz ou lápis grosso', 'aquisicao', 4, 'Introdução ao uso de lápis', 'Motricidade fina', 'Ensinar/desenvolver a habilidade de rabisca com giz ou lápis grosso com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Rabisca com giz ou lápis grosso”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Papel; lápis/giz adequado à idade; modelos visuais.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Rabisca com giz ou lápis grosso”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Rabisca com giz ou lápis grosso” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F01A', 'F01AG004', 'Rabisca com giz ou lápis grosso', 'generalizacao', 4, 'Introdução ao uso de lápis', 'Motricidade fina', 'Generalizar a habilidade de rabisca com giz ou lápis grosso para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Papel; lápis/giz adequado à idade; modelos visuais.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Rabisca com giz ou lápis grosso”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Rabisca com giz ou lápis grosso” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F01A', 'F01AG004', 'Rabisca com giz ou lápis grosso', 'manutencao', 4, 'Introdução ao uso de lápis', 'Motricidade fina', 'Manter a habilidade de rabisca com giz ou lápis grosso de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Papel; lápis/giz adequado à idade; modelos visuais.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Rabisca com giz ou lápis grosso”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Rabisca com giz ou lápis grosso” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F01A', 'F01AC001', 'Olha quando chamado pelo nome', 'aquisicao', 1, 'Contato visual com nome', 'Atenção conjunta', 'Ensinar/desenvolver a habilidade de olha quando chamado pelo nome com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Olha quando chamado pelo nome”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Olha quando chamado pelo nome”.', '1. Física: não utilizar para forçar contato visual.
2. Gestual: orientar suavemente para o interlocutor/estímulo.
3. Visual: posicionar o estímulo relevante no campo visual.
4. Verbal: lembrete curto, quando necessário.
5. I = Independente.', 'A criança realiza “Olha quando chamado pelo nome” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Não segurar o rosto nem exigir olhar fixo contínuo; valorizar orientação funcional ao interlocutor.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F01A', 'F01AC001', 'Olha quando chamado pelo nome', 'generalizacao', 1, 'Contato visual com nome', 'Atenção conjunta', 'Generalizar a habilidade de olha quando chamado pelo nome para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Olha quando chamado pelo nome”.', '1. Física: não utilizar para forçar contato visual.
2. Gestual: orientar suavemente para o interlocutor/estímulo.
3. Visual: posicionar o estímulo relevante no campo visual.
4. Verbal: lembrete curto, quando necessário.
5. I = Independente.', 'A criança realiza “Olha quando chamado pelo nome” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Não segurar o rosto nem exigir olhar fixo contínuo; valorizar orientação funcional ao interlocutor.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F01A', 'F01AC001', 'Olha quando chamado pelo nome', 'manutencao', 1, 'Contato visual com nome', 'Atenção conjunta', 'Manter a habilidade de olha quando chamado pelo nome de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Olha quando chamado pelo nome”.', '1. Física: não utilizar para forçar contato visual.
2. Gestual: orientar suavemente para o interlocutor/estímulo.
3. Visual: posicionar o estímulo relevante no campo visual.
4. Verbal: lembrete curto, quando necessário.
5. I = Independente.', 'A criança mantém “Olha quando chamado pelo nome” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Não segurar o rosto nem exigir olhar fixo contínuo; valorizar orientação funcional ao interlocutor.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F01A', 'F01AC002', 'Olha para você quando brincam juntos', 'aquisicao', 2, 'Reforço natural de contato visual', 'Atenção conjunta', 'Ensinar/desenvolver a habilidade de olha para você quando brincam juntos com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Olha para você quando brincam juntos”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Olha para você quando brincam juntos”.', '1. Física: não utilizar para forçar contato visual.
2. Gestual: orientar suavemente para o interlocutor/estímulo.
3. Visual: posicionar o estímulo relevante no campo visual.
4. Verbal: lembrete curto, quando necessário.
5. I = Independente.', 'A criança realiza “Olha para você quando brincam juntos” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Não segurar o rosto nem exigir olhar fixo contínuo; valorizar orientação funcional ao interlocutor.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F01A', 'F01AC002', 'Olha para você quando brincam juntos', 'generalizacao', 2, 'Reforço natural de contato visual', 'Atenção conjunta', 'Generalizar a habilidade de olha para você quando brincam juntos para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Olha para você quando brincam juntos”.', '1. Física: não utilizar para forçar contato visual.
2. Gestual: orientar suavemente para o interlocutor/estímulo.
3. Visual: posicionar o estímulo relevante no campo visual.
4. Verbal: lembrete curto, quando necessário.
5. I = Independente.', 'A criança realiza “Olha para você quando brincam juntos” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Não segurar o rosto nem exigir olhar fixo contínuo; valorizar orientação funcional ao interlocutor.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F01A', 'F01AC002', 'Olha para você quando brincam juntos', 'manutencao', 2, 'Reforço natural de contato visual', 'Atenção conjunta', 'Manter a habilidade de olha para você quando brincam juntos de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Olha para você quando brincam juntos”.', '1. Física: não utilizar para forçar contato visual.
2. Gestual: orientar suavemente para o interlocutor/estímulo.
3. Visual: posicionar o estímulo relevante no campo visual.
4. Verbal: lembrete curto, quando necessário.
5. I = Independente.', 'A criança mantém “Olha para você quando brincam juntos” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Não segurar o rosto nem exigir olhar fixo contínuo; valorizar orientação funcional ao interlocutor.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F01A', 'F01AC003', 'Estende a mão para pegar o que deseja', 'aquisicao', 3, 'Solicitação por aproximação', 'Comunicação funcional', 'Ensinar/desenvolver a habilidade de estende a mão para pegar o que deseja com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Estende a mão para pegar o que deseja”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Estende a mão para pegar o que deseja”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Estende a mão para pegar o que deseja” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F01A', 'F01AC003', 'Estende a mão para pegar o que deseja', 'generalizacao', 3, 'Solicitação por aproximação', 'Comunicação funcional', 'Generalizar a habilidade de estende a mão para pegar o que deseja para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Estende a mão para pegar o que deseja”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Estende a mão para pegar o que deseja” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F01A', 'F01AC003', 'Estende a mão para pegar o que deseja', 'manutencao', 3, 'Solicitação por aproximação', 'Comunicação funcional', 'Manter a habilidade de estende a mão para pegar o que deseja de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Estende a mão para pegar o que deseja”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Estende a mão para pegar o que deseja” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F01A', 'F01AC004', 'Emite sons quando quer algo', 'aquisicao', 4, 'Mandos vocais simples', 'Expressiva', 'Ensinar/desenvolver a habilidade de emite sons quando quer algo com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Emite sons quando quer algo”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Emite sons quando quer algo”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Emite sons quando quer algo” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F01A', 'F01AC004', 'Emite sons quando quer algo', 'generalizacao', 4, 'Mandos vocais simples', 'Expressiva', 'Generalizar a habilidade de emite sons quando quer algo para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Emite sons quando quer algo”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Emite sons quando quer algo” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F01A', 'F01AC004', 'Emite sons quando quer algo', 'manutencao', 4, 'Mandos vocais simples', 'Expressiva', 'Manter a habilidade de emite sons quando quer algo de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Emite sons quando quer algo”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Emite sons quando quer algo” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F01A', 'F01AC005', 'Entende comandos simples', 'aquisicao', 5, 'Compreensão de instruções de 1 passo', 'Receptiva', 'Ensinar/desenvolver a habilidade de entende comandos simples com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Entende comandos simples”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Entende comandos simples”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Entende comandos simples” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F01A', 'F01AC005', 'Entende comandos simples', 'generalizacao', 5, 'Compreensão de instruções de 1 passo', 'Receptiva', 'Generalizar a habilidade de entende comandos simples para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Entende comandos simples”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Entende comandos simples” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F01A', 'F01AC005', 'Entende comandos simples', 'manutencao', 5, 'Compreensão de instruções de 1 passo', 'Receptiva', 'Manter a habilidade de entende comandos simples de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Entende comandos simples”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Entende comandos simples” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F01A', 'F01AF001', 'Come alimentos sólidos amassados', 'aquisicao', 1, 'Aceitação alimentar inicial', 'Alimentação', 'Ensinar/desenvolver a habilidade de come alimentos sólidos amassados com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Come alimentos sólidos amassados”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Alimentos habituais e/ou alvo; utensílios adequados; mesa/cadeira.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Treinar na rotina natural; 1–3 oportunidades/dia, sem transformar toda a rotina em sessão.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Come alimentos sólidos amassados”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Come alimentos sólidos amassados” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Não forçar ingestão; diante de recusa intensa, engasgos, dor ou dificuldade alimentar persistente, interromper e buscar avaliação profissional.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F01A', 'F01AF001', 'Come alimentos sólidos amassados', 'generalizacao', 1, 'Aceitação alimentar inicial', 'Alimentação', 'Generalizar a habilidade de come alimentos sólidos amassados para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Alimentos habituais e/ou alvo; utensílios adequados; mesa/cadeira.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Come alimentos sólidos amassados”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Come alimentos sólidos amassados” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Não forçar ingestão; diante de recusa intensa, engasgos, dor ou dificuldade alimentar persistente, interromper e buscar avaliação profissional.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F01A', 'F01AF001', 'Come alimentos sólidos amassados', 'manutencao', 1, 'Aceitação alimentar inicial', 'Alimentação', 'Manter a habilidade de come alimentos sólidos amassados de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Alimentos habituais e/ou alvo; utensílios adequados; mesa/cadeira.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Come alimentos sólidos amassados”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Come alimentos sólidos amassados” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Não forçar ingestão; diante de recusa intensa, engasgos, dor ou dificuldade alimentar persistente, interromper e buscar avaliação profissional.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F01A', 'F01AF002', 'Tolera limpeza do rosto/mãos', 'aquisicao', 2, 'Dessensibilização com reforço', 'Higiene', 'Ensinar/desenvolver a habilidade de tolera limpeza do rosto/mãos com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Tolera limpeza do rosto/mãos”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Itens reais da rotina de higiene; apoio visual opcional.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Treinar na rotina natural; 1–3 oportunidades/dia, sem transformar toda a rotina em sessão.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Tolera limpeza do rosto/mãos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Tolera limpeza do rosto/mãos” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F01A', 'F01AF002', 'Tolera limpeza do rosto/mãos', 'generalizacao', 2, 'Dessensibilização com reforço', 'Higiene', 'Generalizar a habilidade de tolera limpeza do rosto/mãos para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Itens reais da rotina de higiene; apoio visual opcional.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Tolera limpeza do rosto/mãos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Tolera limpeza do rosto/mãos” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F01A', 'F01AF002', 'Tolera limpeza do rosto/mãos', 'manutencao', 2, 'Dessensibilização com reforço', 'Higiene', 'Manter a habilidade de tolera limpeza do rosto/mãos de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Itens reais da rotina de higiene; apoio visual opcional.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Tolera limpeza do rosto/mãos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Tolera limpeza do rosto/mãos” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F01A', 'F01AF003', 'Estende os braços ao vestir', 'aquisicao', 3, 'Participação no vestir', 'Vestuário', 'Ensinar/desenvolver a habilidade de estende os braços ao vestir com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Estende os braços ao vestir”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Roupas da criança; espelho opcional; sequência visual opcional.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Treinar na rotina natural; 1–3 oportunidades/dia, sem transformar toda a rotina em sessão.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Estende os braços ao vestir”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Estende os braços ao vestir” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F01A', 'F01AF003', 'Estende os braços ao vestir', 'generalizacao', 3, 'Participação no vestir', 'Vestuário', 'Generalizar a habilidade de estende os braços ao vestir para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Roupas da criança; espelho opcional; sequência visual opcional.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Estende os braços ao vestir”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Estende os braços ao vestir” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F01A', 'F01AF003', 'Estende os braços ao vestir', 'manutencao', 3, 'Participação no vestir', 'Vestuário', 'Manter a habilidade de estende os braços ao vestir de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Roupas da criança; espelho opcional; sequência visual opcional.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Estende os braços ao vestir”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Estende os braços ao vestir” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F01A', 'F01AF004', 'Mostra incômodo com fralda suja', 'aquisicao', 4, 'Sinalização pré-desfralde', 'Banheiro', 'Ensinar/desenvolver a habilidade de mostra incômodo com fralda suja com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Mostra incômodo com fralda suja”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Itens reais da rotina de banheiro; apoio visual opcional; roupas fáceis de manejar.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Treinar na rotina natural; 1–3 oportunidades/dia, sem transformar toda a rotina em sessão.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Mostra incômodo com fralda suja”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Mostra incômodo com fralda suja” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F01A', 'F01AF004', 'Mostra incômodo com fralda suja', 'generalizacao', 4, 'Sinalização pré-desfralde', 'Banheiro', 'Generalizar a habilidade de mostra incômodo com fralda suja para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Itens reais da rotina de banheiro; apoio visual opcional; roupas fáceis de manejar.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Mostra incômodo com fralda suja”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Mostra incômodo com fralda suja” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F01A', 'F01AF004', 'Mostra incômodo com fralda suja', 'manutencao', 4, 'Sinalização pré-desfralde', 'Banheiro', 'Manter a habilidade de mostra incômodo com fralda suja de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Itens reais da rotina de banheiro; apoio visual opcional; roupas fáceis de manejar.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Mostra incômodo com fralda suja”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Mostra incômodo com fralda suja” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F01A', 'F01AM001', 'Senta sozinho sem apoio', 'aquisicao', 1, 'Estabilidade postural sentada', 'Motora global', 'Ensinar/desenvolver a habilidade de senta sozinho sem apoio com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Senta sozinho sem apoio”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas, respeitando segurança e fadiga.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Senta sozinho sem apoio”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Senta sozinho sem apoio” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F01A', 'F01AM001', 'Senta sozinho sem apoio', 'generalizacao', 1, 'Estabilidade postural sentada', 'Motora global', 'Generalizar a habilidade de senta sozinho sem apoio para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Senta sozinho sem apoio”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Senta sozinho sem apoio” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F01A', 'F01AM001', 'Senta sozinho sem apoio', 'manutencao', 1, 'Estabilidade postural sentada', 'Motora global', 'Manter a habilidade de senta sozinho sem apoio de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Senta sozinho sem apoio”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Senta sozinho sem apoio” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F01A', 'F01AM002', 'Engatinha ou anda com apoio', 'aquisicao', 2, 'Estímulo à locomoção com reforço', 'Motora global', 'Ensinar/desenvolver a habilidade de engatinha ou anda com apoio com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Engatinha ou anda com apoio”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas, respeitando segurança e fadiga.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Engatinha ou anda com apoio”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Engatinha ou anda com apoio” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F01A', 'F01AM002', 'Engatinha ou anda com apoio', 'generalizacao', 2, 'Estímulo à locomoção com reforço', 'Motora global', 'Generalizar a habilidade de engatinha ou anda com apoio para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Engatinha ou anda com apoio”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Engatinha ou anda com apoio” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F01A', 'F01AM002', 'Engatinha ou anda com apoio', 'manutencao', 2, 'Estímulo à locomoção com reforço', 'Motora global', 'Manter a habilidade de engatinha ou anda com apoio de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Engatinha ou anda com apoio”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Engatinha ou anda com apoio” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F01A', 'F01AM003', 'Coloca peças grandes em recipientes', 'aquisicao', 3, 'Coordenação olho-mão', 'Motora fina', 'Ensinar/desenvolver a habilidade de coloca peças grandes em recipientes com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Coloca peças grandes em recipientes”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas, respeitando segurança e fadiga.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Coloca peças grandes em recipientes”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Coloca peças grandes em recipientes” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F01A', 'F01AM003', 'Coloca peças grandes em recipientes', 'generalizacao', 3, 'Coordenação olho-mão', 'Motora fina', 'Generalizar a habilidade de coloca peças grandes em recipientes para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Coloca peças grandes em recipientes”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Coloca peças grandes em recipientes” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F01A', 'F01AM003', 'Coloca peças grandes em recipientes', 'manutencao', 3, 'Coordenação olho-mão', 'Motora fina', 'Manter a habilidade de coloca peças grandes em recipientes de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Coloca peças grandes em recipientes”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Coloca peças grandes em recipientes” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F01A', 'F01AM004', 'Rola bola quando você pede', 'aquisicao', 4, 'Interação com bola com reforço social', 'Bola', 'Ensinar/desenvolver a habilidade de rola bola quando você pede com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Rola bola quando você pede”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Bola adequada à idade; alvo/cones opcionais; espaço seguro.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas, respeitando segurança e fadiga.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Rola bola quando você pede”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Rola bola quando você pede” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F01A', 'F01AM004', 'Rola bola quando você pede', 'generalizacao', 4, 'Interação com bola com reforço social', 'Bola', 'Generalizar a habilidade de rola bola quando você pede para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Bola adequada à idade; alvo/cones opcionais; espaço seguro.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Rola bola quando você pede”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Rola bola quando você pede” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F01A', 'F01AM004', 'Rola bola quando você pede', 'manutencao', 4, 'Interação com bola com reforço social', 'Bola', 'Manter a habilidade de rola bola quando você pede de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Bola adequada à idade; alvo/cones opcionais; espaço seguro.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Rola bola quando você pede”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Rola bola quando você pede” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F01A', 'F01AS001', 'Imita movimentos simples', 'aquisicao', 1, 'Imitação motora simples', 'Imitação', 'Ensinar/desenvolver a habilidade de imita movimentos simples com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Imita movimentos simples”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Imita movimentos simples”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Imita movimentos simples” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F01A', 'F01AS001', 'Imita movimentos simples', 'generalizacao', 1, 'Imitação motora simples', 'Imitação', 'Generalizar a habilidade de imita movimentos simples para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Imita movimentos simples”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Imita movimentos simples” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F01A', 'F01AS001', 'Imita movimentos simples', 'manutencao', 1, 'Imitação motora simples', 'Imitação', 'Manter a habilidade de imita movimentos simples de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Imita movimentos simples”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Imita movimentos simples” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F01A', 'F01AS002', 'Participa de brincadeiras de “cadê/achou”', 'aquisicao', 2, 'Jogos sociais com alternância', 'Brincar', 'Ensinar/desenvolver a habilidade de participa de brincadeiras de “cadê/achou” com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Participa de brincadeiras de “cadê/achou””.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Participa de brincadeiras de “cadê/achou””.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Participa de brincadeiras de “cadê/achou”” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F01A', 'F01AS002', 'Participa de brincadeiras de “cadê/achou”', 'generalizacao', 2, 'Jogos sociais com alternância', 'Brincar', 'Generalizar a habilidade de participa de brincadeiras de “cadê/achou” para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Participa de brincadeiras de “cadê/achou””.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Participa de brincadeiras de “cadê/achou”” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F01A', 'F01AS002', 'Participa de brincadeiras de “cadê/achou”', 'manutencao', 2, 'Jogos sociais com alternância', 'Brincar', 'Manter a habilidade de participa de brincadeiras de “cadê/achou” de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Participa de brincadeiras de “cadê/achou””.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Participa de brincadeiras de “cadê/achou”” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F01A', 'F01AS003', 'Permanece sentado com brinquedo por 1 minuto', 'aquisicao', 3, 'Tolerância com reforço', 'Tolerância', 'Ensinar/desenvolver a habilidade de permanece sentado com brinquedo por 1 minuto com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Permanece sentado com brinquedo por 1 minuto”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Permanece sentado com brinquedo por 1 minuto”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Permanece sentado com brinquedo por 1 minuto” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F01A', 'F01AS003', 'Permanece sentado com brinquedo por 1 minuto', 'generalizacao', 3, 'Tolerância com reforço', 'Tolerância', 'Generalizar a habilidade de permanece sentado com brinquedo por 1 minuto para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Permanece sentado com brinquedo por 1 minuto”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Permanece sentado com brinquedo por 1 minuto” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F01A', 'F01AS003', 'Permanece sentado com brinquedo por 1 minuto', 'manutencao', 3, 'Tolerância com reforço', 'Tolerância', 'Manter a habilidade de permanece sentado com brinquedo por 1 minuto de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Permanece sentado com brinquedo por 1 minuto”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Permanece sentado com brinquedo por 1 minuto” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F01A', 'F01AS004', 'Sorri ou reage ao seu sorriso', 'aquisicao', 4, 'Reforçamento de interação social', 'Resposta emocional', 'Ensinar/desenvolver a habilidade de sorri ou reage ao seu sorriso com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Sorri ou reage ao seu sorriso”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Sorri ou reage ao seu sorriso”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Sorri ou reage ao seu sorriso” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F01A', 'F01AS004', 'Sorri ou reage ao seu sorriso', 'generalizacao', 4, 'Reforçamento de interação social', 'Resposta emocional', 'Generalizar a habilidade de sorri ou reage ao seu sorriso para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Sorri ou reage ao seu sorriso”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Sorri ou reage ao seu sorriso” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F01A', 'F01AS004', 'Sorri ou reage ao seu sorriso', 'manutencao', 4, 'Reforçamento de interação social', 'Resposta emocional', 'Manter a habilidade de sorri ou reage ao seu sorriso de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Sorri ou reage ao seu sorriso”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Sorri ou reage ao seu sorriso” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F02A', 'F02AG001', 'Mostra algo interessante para alguém', 'aquisicao', 1, 'Atenção compartilhada com reforço', 'Atenção conjunta', 'Ensinar/desenvolver a habilidade de mostra algo interessante para alguém com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Mostra algo interessante para alguém”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Mostra algo interessante para alguém”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Mostra algo interessante para alguém” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F02A', 'F02AG001', 'Mostra algo interessante para alguém', 'generalizacao', 1, 'Atenção compartilhada com reforço', 'Atenção conjunta', 'Generalizar a habilidade de mostra algo interessante para alguém para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Mostra algo interessante para alguém”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Mostra algo interessante para alguém” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F02A', 'F02AG001', 'Mostra algo interessante para alguém', 'manutencao', 1, 'Atenção compartilhada com reforço', 'Atenção conjunta', 'Manter a habilidade de mostra algo interessante para alguém de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Mostra algo interessante para alguém”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Mostra algo interessante para alguém” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F02A', 'F02AG002', 'Abre recipientes por curiosidade', 'aquisicao', 2, 'Exploração de objetos com reforço social', 'Exploratória', 'Ensinar/desenvolver a habilidade de abre recipientes por curiosidade com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Abre recipientes por curiosidade”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Abre recipientes por curiosidade”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Abre recipientes por curiosidade” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F02A', 'F02AG002', 'Abre recipientes por curiosidade', 'generalizacao', 2, 'Exploração de objetos com reforço social', 'Exploratória', 'Generalizar a habilidade de abre recipientes por curiosidade para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Abre recipientes por curiosidade”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Abre recipientes por curiosidade” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F02A', 'F02AG002', 'Abre recipientes por curiosidade', 'manutencao', 2, 'Exploração de objetos com reforço social', 'Exploratória', 'Manter a habilidade de abre recipientes por curiosidade de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Abre recipientes por curiosidade”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Abre recipientes por curiosidade” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F02A', 'F02AG003', 'Emparelha objetos ou figuras iguais', 'aquisicao', 3, 'Pareamento por identidade', 'Combinação', 'Ensinar/desenvolver a habilidade de emparelha objetos ou figuras iguais com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Emparelha objetos ou figuras iguais”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Brinquedos/objetos adequados à habilidade; modelos simples.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Emparelha objetos ou figuras iguais”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Emparelha objetos ou figuras iguais” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F02A', 'F02AG003', 'Emparelha objetos ou figuras iguais', 'generalizacao', 3, 'Pareamento por identidade', 'Combinação', 'Generalizar a habilidade de emparelha objetos ou figuras iguais para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Brinquedos/objetos adequados à habilidade; modelos simples.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Emparelha objetos ou figuras iguais”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Emparelha objetos ou figuras iguais” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F02A', 'F02AG003', 'Emparelha objetos ou figuras iguais', 'manutencao', 3, 'Pareamento por identidade', 'Combinação', 'Manter a habilidade de emparelha objetos ou figuras iguais de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Brinquedos/objetos adequados à habilidade; modelos simples.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Emparelha objetos ou figuras iguais”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Emparelha objetos ou figuras iguais” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F02A', 'F02AG004', 'Rabisca com mais controle', 'aquisicao', 4, 'Treino de traçado com lápis grosso', 'Uso do lápis', 'Ensinar/desenvolver a habilidade de rabisca com mais controle com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Rabisca com mais controle”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Rabisca com mais controle”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Rabisca com mais controle” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F02A', 'F02AG004', 'Rabisca com mais controle', 'generalizacao', 4, 'Treino de traçado com lápis grosso', 'Uso do lápis', 'Generalizar a habilidade de rabisca com mais controle para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Rabisca com mais controle”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Rabisca com mais controle” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F02A', 'F02AG004', 'Rabisca com mais controle', 'manutencao', 4, 'Treino de traçado com lápis grosso', 'Uso do lápis', 'Manter a habilidade de rabisca com mais controle de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Rabisca com mais controle”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Rabisca com mais controle” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F02A', 'F02AC001', 'Alterna o olhar entre objeto e pessoa', 'aquisicao', 1, 'Alternância de atenção compartilhada', 'Atenção conjunta', 'Ensinar/desenvolver a habilidade de alterna o olhar entre objeto e pessoa com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Alterna o olhar entre objeto e pessoa”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Brinquedos/objetos adequados à habilidade; modelos simples.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Alterna o olhar entre objeto e pessoa”.', '1. Física: não utilizar para forçar contato visual.
2. Gestual: orientar suavemente para o interlocutor/estímulo.
3. Visual: posicionar o estímulo relevante no campo visual.
4. Verbal: lembrete curto, quando necessário.
5. I = Independente.', 'A criança realiza “Alterna o olhar entre objeto e pessoa” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Não segurar o rosto nem exigir olhar fixo contínuo; valorizar orientação funcional ao interlocutor.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F02A', 'F02AC001', 'Alterna o olhar entre objeto e pessoa', 'generalizacao', 1, 'Alternância de atenção compartilhada', 'Atenção conjunta', 'Generalizar a habilidade de alterna o olhar entre objeto e pessoa para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Brinquedos/objetos adequados à habilidade; modelos simples.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Alterna o olhar entre objeto e pessoa”.', '1. Física: não utilizar para forçar contato visual.
2. Gestual: orientar suavemente para o interlocutor/estímulo.
3. Visual: posicionar o estímulo relevante no campo visual.
4. Verbal: lembrete curto, quando necessário.
5. I = Independente.', 'A criança realiza “Alterna o olhar entre objeto e pessoa” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Não segurar o rosto nem exigir olhar fixo contínuo; valorizar orientação funcional ao interlocutor.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F02A', 'F02AC001', 'Alterna o olhar entre objeto e pessoa', 'manutencao', 1, 'Alternância de atenção compartilhada', 'Atenção conjunta', 'Manter a habilidade de alterna o olhar entre objeto e pessoa de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Brinquedos/objetos adequados à habilidade; modelos simples.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Alterna o olhar entre objeto e pessoa”.', '1. Física: não utilizar para forçar contato visual.
2. Gestual: orientar suavemente para o interlocutor/estímulo.
3. Visual: posicionar o estímulo relevante no campo visual.
4. Verbal: lembrete curto, quando necessário.
5. I = Independente.', 'A criança mantém “Alterna o olhar entre objeto e pessoa” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Não segurar o rosto nem exigir olhar fixo contínuo; valorizar orientação funcional ao interlocutor.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F02A', 'F02AC002', 'Aponta a 30 cm de distância', 'aquisicao', 2, 'Apontar funcional com fading de distância', 'Comunicação funcional', 'Ensinar/desenvolver a habilidade de aponta a 30 cm de distância com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Aponta a 30 cm de distância”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Aponta a 30 cm de distância”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Aponta a 30 cm de distância” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F02A', 'F02AC002', 'Aponta a 30 cm de distância', 'generalizacao', 2, 'Apontar funcional com fading de distância', 'Comunicação funcional', 'Generalizar a habilidade de aponta a 30 cm de distância para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Aponta a 30 cm de distância”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Aponta a 30 cm de distância” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F02A', 'F02AC002', 'Aponta a 30 cm de distância', 'manutencao', 2, 'Apontar funcional com fading de distância', 'Comunicação funcional', 'Manter a habilidade de aponta a 30 cm de distância de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Aponta a 30 cm de distância”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Aponta a 30 cm de distância” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F02A', 'F02AC003', 'Imita sons de animais, carros etc.', 'aquisicao', 3, 'Imitação vocal com reforço diferencial', 'Expressiva', 'Ensinar/desenvolver a habilidade de imita sons de animais, carros etc. com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Imita sons de animais, carros etc.”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Imita sons de animais, carros etc.”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Imita sons de animais, carros etc.” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F02A', 'F02AC003', 'Imita sons de animais, carros etc.', 'generalizacao', 3, 'Imitação vocal com reforço diferencial', 'Expressiva', 'Generalizar a habilidade de imita sons de animais, carros etc. para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Imita sons de animais, carros etc.”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Imita sons de animais, carros etc.” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F02A', 'F02AC003', 'Imita sons de animais, carros etc.', 'manutencao', 3, 'Imitação vocal com reforço diferencial', 'Expressiva', 'Manter a habilidade de imita sons de animais, carros etc. de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Imita sons de animais, carros etc.”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Imita sons de animais, carros etc.” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F02A', 'F02AC004', 'Identifica objetos comuns', 'aquisicao', 4, 'Tato com objetos do cotidiano', 'Receptiva', 'Ensinar/desenvolver a habilidade de identifica objetos comuns com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Identifica objetos comuns”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Brinquedos/objetos adequados à habilidade; modelos simples.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Identifica objetos comuns”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Identifica objetos comuns” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F02A', 'F02AC004', 'Identifica objetos comuns', 'generalizacao', 4, 'Tato com objetos do cotidiano', 'Receptiva', 'Generalizar a habilidade de identifica objetos comuns para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Brinquedos/objetos adequados à habilidade; modelos simples.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Identifica objetos comuns”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Identifica objetos comuns” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F02A', 'F02AC004', 'Identifica objetos comuns', 'manutencao', 4, 'Tato com objetos do cotidiano', 'Receptiva', 'Manter a habilidade de identifica objetos comuns de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Brinquedos/objetos adequados à habilidade; modelos simples.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Identifica objetos comuns”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Identifica objetos comuns” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F02A', 'F02AC005', 'Segue instruções de 2 passos', 'aquisicao', 5, 'Instruções com sequência e fading', 'Receptiva', 'Ensinar/desenvolver a habilidade de segue instruções de 2 passos com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Segue instruções de 2 passos”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Segue instruções de 2 passos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Segue instruções de 2 passos” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F02A', 'F02AC005', 'Segue instruções de 2 passos', 'generalizacao', 5, 'Instruções com sequência e fading', 'Receptiva', 'Generalizar a habilidade de segue instruções de 2 passos para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Segue instruções de 2 passos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Segue instruções de 2 passos” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F02A', 'F02AC005', 'Segue instruções de 2 passos', 'manutencao', 5, 'Instruções com sequência e fading', 'Receptiva', 'Manter a habilidade de segue instruções de 2 passos de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Segue instruções de 2 passos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Segue instruções de 2 passos” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F02A', 'F02AF001', 'Come sozinho com colher', 'aquisicao', 1, 'Alimentação independente com modelagem', 'Alimentação', 'Ensinar/desenvolver a habilidade de come sozinho com colher com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Come sozinho com colher”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Alimentos habituais e/ou alvo; utensílios adequados; mesa/cadeira.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Treinar na rotina natural; 1–3 oportunidades/dia, sem transformar toda a rotina em sessão.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Come sozinho com colher”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Come sozinho com colher” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Não forçar ingestão; diante de recusa intensa, engasgos, dor ou dificuldade alimentar persistente, interromper e buscar avaliação profissional.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F02A', 'F02AF001', 'Come sozinho com colher', 'generalizacao', 1, 'Alimentação independente com modelagem', 'Alimentação', 'Generalizar a habilidade de come sozinho com colher para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Alimentos habituais e/ou alvo; utensílios adequados; mesa/cadeira.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Come sozinho com colher”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Come sozinho com colher” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Não forçar ingestão; diante de recusa intensa, engasgos, dor ou dificuldade alimentar persistente, interromper e buscar avaliação profissional.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F02A', 'F02AF001', 'Come sozinho com colher', 'manutencao', 1, 'Alimentação independente com modelagem', 'Alimentação', 'Manter a habilidade de come sozinho com colher de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Alimentos habituais e/ou alvo; utensílios adequados; mesa/cadeira.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Come sozinho com colher”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Come sozinho com colher” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Não forçar ingestão; diante de recusa intensa, engasgos, dor ou dificuldade alimentar persistente, interromper e buscar avaliação profissional.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F02A', 'F02AF002', 'Lava mãos com ajuda leve', 'aquisicao', 2, 'Treino de rotina com modelagem', 'Higiene', 'Ensinar/desenvolver a habilidade de lava mãos com ajuda leve com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Lava mãos com ajuda leve”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Itens reais da rotina de higiene; apoio visual opcional.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Treinar na rotina natural; 1–3 oportunidades/dia, sem transformar toda a rotina em sessão.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Lava mãos com ajuda leve”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Lava mãos com ajuda leve” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F02A', 'F02AF002', 'Lava mãos com ajuda leve', 'generalizacao', 2, 'Treino de rotina com modelagem', 'Higiene', 'Generalizar a habilidade de lava mãos com ajuda leve para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Itens reais da rotina de higiene; apoio visual opcional.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Lava mãos com ajuda leve”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Lava mãos com ajuda leve” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F02A', 'F02AF002', 'Lava mãos com ajuda leve', 'manutencao', 2, 'Treino de rotina com modelagem', 'Higiene', 'Manter a habilidade de lava mãos com ajuda leve de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Itens reais da rotina de higiene; apoio visual opcional.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Lava mãos com ajuda leve”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Lava mãos com ajuda leve” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F02A', 'F02AF003', 'Tenta vestir sapato ou camiseta', 'aquisicao', 3, 'Participação na troca de roupas', 'Vestuário', 'Ensinar/desenvolver a habilidade de tenta vestir sapato ou camiseta com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Tenta vestir sapato ou camiseta”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Roupas da criança; espelho opcional; sequência visual opcional.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Treinar na rotina natural; 1–3 oportunidades/dia, sem transformar toda a rotina em sessão.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Tenta vestir sapato ou camiseta”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Tenta vestir sapato ou camiseta” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F02A', 'F02AF003', 'Tenta vestir sapato ou camiseta', 'generalizacao', 3, 'Participação na troca de roupas', 'Vestuário', 'Generalizar a habilidade de tenta vestir sapato ou camiseta para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Roupas da criança; espelho opcional; sequência visual opcional.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Tenta vestir sapato ou camiseta”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Tenta vestir sapato ou camiseta” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F02A', 'F02AF003', 'Tenta vestir sapato ou camiseta', 'manutencao', 3, 'Participação na troca de roupas', 'Vestuário', 'Manter a habilidade de tenta vestir sapato ou camiseta de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Roupas da criança; espelho opcional; sequência visual opcional.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Tenta vestir sapato ou camiseta”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Tenta vestir sapato ou camiseta” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F02A', 'F02AF004', 'Avisa que está com vontade', 'aquisicao', 4, 'Comunicação pré-desfralde com reforço', 'Banheiro', 'Ensinar/desenvolver a habilidade de avisa que está com vontade com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Avisa que está com vontade”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Treinar na rotina natural; 1–3 oportunidades/dia, sem transformar toda a rotina em sessão.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Avisa que está com vontade”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Avisa que está com vontade” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F02A', 'F02AF004', 'Avisa que está com vontade', 'generalizacao', 4, 'Comunicação pré-desfralde com reforço', 'Banheiro', 'Generalizar a habilidade de avisa que está com vontade para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Avisa que está com vontade”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Avisa que está com vontade” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F02A', 'F02AF004', 'Avisa que está com vontade', 'manutencao', 4, 'Comunicação pré-desfralde com reforço', 'Banheiro', 'Manter a habilidade de avisa que está com vontade de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Avisa que está com vontade”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Avisa que está com vontade” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F02A', 'F02AM001', 'Sobe escadas com apoio', 'aquisicao', 1, 'Motricidade com reforço e segurança', 'Motora global', 'Ensinar/desenvolver a habilidade de sobe escadas com apoio com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Sobe escadas com apoio”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas, respeitando segurança e fadiga.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Sobe escadas com apoio”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Sobe escadas com apoio” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F02A', 'F02AM001', 'Sobe escadas com apoio', 'generalizacao', 1, 'Motricidade com reforço e segurança', 'Motora global', 'Generalizar a habilidade de sobe escadas com apoio para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Sobe escadas com apoio”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Sobe escadas com apoio” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F02A', 'F02AM001', 'Sobe escadas com apoio', 'manutencao', 1, 'Motricidade com reforço e segurança', 'Motora global', 'Manter a habilidade de sobe escadas com apoio de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Sobe escadas com apoio”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Sobe escadas com apoio” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F02A', 'F02AM002', 'Encaixa peças em sequência', 'aquisicao', 2, 'Coordenação olho-mão com modelos', 'Motora fina', 'Ensinar/desenvolver a habilidade de encaixa peças em sequência com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Encaixa peças em sequência”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas, respeitando segurança e fadiga.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Encaixa peças em sequência”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Encaixa peças em sequência” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F02A', 'F02AM002', 'Encaixa peças em sequência', 'generalizacao', 2, 'Coordenação olho-mão com modelos', 'Motora fina', 'Generalizar a habilidade de encaixa peças em sequência para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Encaixa peças em sequência”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Encaixa peças em sequência” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F02A', 'F02AM002', 'Encaixa peças em sequência', 'manutencao', 2, 'Coordenação olho-mão com modelos', 'Motora fina', 'Manter a habilidade de encaixa peças em sequência de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Encaixa peças em sequência”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Encaixa peças em sequência” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F02A', 'F02AM003', 'Vira páginas de livro', 'aquisicao', 3, 'Manipulação funcional de livros', 'Objeto', 'Ensinar/desenvolver a habilidade de vira páginas de livro com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Vira páginas de livro”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas, respeitando segurança e fadiga.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Vira páginas de livro”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Vira páginas de livro” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F02A', 'F02AM003', 'Vira páginas de livro', 'generalizacao', 3, 'Manipulação funcional de livros', 'Objeto', 'Generalizar a habilidade de vira páginas de livro para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Vira páginas de livro”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Vira páginas de livro” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F02A', 'F02AM003', 'Vira páginas de livro', 'manutencao', 3, 'Manipulação funcional de livros', 'Objeto', 'Manter a habilidade de vira páginas de livro de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Vira páginas de livro”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Vira páginas de livro” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F02A', 'F02AM004', 'Chuta bola grande com direção', 'aquisicao', 4, 'Coordenação com reforço social', 'Bola', 'Ensinar/desenvolver a habilidade de chuta bola grande com direção com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Chuta bola grande com direção”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Bola adequada à idade; alvo/cones opcionais; espaço seguro.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas, respeitando segurança e fadiga.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Chuta bola grande com direção”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Chuta bola grande com direção” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F02A', 'F02AM004', 'Chuta bola grande com direção', 'generalizacao', 4, 'Coordenação com reforço social', 'Bola', 'Generalizar a habilidade de chuta bola grande com direção para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Bola adequada à idade; alvo/cones opcionais; espaço seguro.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Chuta bola grande com direção”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Chuta bola grande com direção” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F02A', 'F02AM004', 'Chuta bola grande com direção', 'manutencao', 4, 'Coordenação com reforço social', 'Bola', 'Manter a habilidade de chuta bola grande com direção de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Bola adequada à idade; alvo/cones opcionais; espaço seguro.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Chuta bola grande com direção”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Chuta bola grande com direção” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F02A', 'F02AS001', 'Imita ações com brinquedos', 'aquisicao', 1, 'Imitação com brinquedos e gestos', 'Imitação', 'Ensinar/desenvolver a habilidade de imita ações com brinquedos com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Imita ações com brinquedos”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Imita ações com brinquedos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Imita ações com brinquedos” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F02A', 'F02AS001', 'Imita ações com brinquedos', 'generalizacao', 1, 'Imitação com brinquedos e gestos', 'Imitação', 'Generalizar a habilidade de imita ações com brinquedos para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Imita ações com brinquedos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Imita ações com brinquedos” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F02A', 'F02AS001', 'Imita ações com brinquedos', 'manutencao', 1, 'Imitação com brinquedos e gestos', 'Imitação', 'Manter a habilidade de imita ações com brinquedos de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Imita ações com brinquedos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Imita ações com brinquedos” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F02A', 'F02AS002', 'Participa de brincadeira com turnos', 'aquisicao', 2, 'Alternância em brincadeiras simples', 'Brincar', 'Ensinar/desenvolver a habilidade de participa de brincadeira com turnos com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Participa de brincadeira com turnos”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Participa de brincadeira com turnos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Participa de brincadeira com turnos” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F02A', 'F02AS002', 'Participa de brincadeira com turnos', 'generalizacao', 2, 'Alternância em brincadeiras simples', 'Brincar', 'Generalizar a habilidade de participa de brincadeira com turnos para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Participa de brincadeira com turnos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Participa de brincadeira com turnos” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F02A', 'F02AS002', 'Participa de brincadeira com turnos', 'manutencao', 2, 'Alternância em brincadeiras simples', 'Brincar', 'Manter a habilidade de participa de brincadeira com turnos de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Participa de brincadeira com turnos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Participa de brincadeira com turnos” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F02A', 'F02AS003', 'Espera por reforço por 30 segundos', 'aquisicao', 3, 'Atraso de reforço com reforçamento positivo', 'Tolerância', 'Ensinar/desenvolver a habilidade de espera por reforço por 30 segundos com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Espera por reforço por 30 segundos”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Espera por reforço por 30 segundos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Espera por reforço por 30 segundos” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F02A', 'F02AS003', 'Espera por reforço por 30 segundos', 'generalizacao', 3, 'Atraso de reforço com reforçamento positivo', 'Tolerância', 'Generalizar a habilidade de espera por reforço por 30 segundos para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Espera por reforço por 30 segundos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Espera por reforço por 30 segundos” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F02A', 'F02AS003', 'Espera por reforço por 30 segundos', 'manutencao', 3, 'Atraso de reforço com reforçamento positivo', 'Tolerância', 'Manter a habilidade de espera por reforço por 30 segundos de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Espera por reforço por 30 segundos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Espera por reforço por 30 segundos” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F02A', 'F02AS004', 'Demonstra quando está triste ou bravo', 'aquisicao', 4, 'Nomeação e imitação de emoções básicas', 'Resposta emocional', 'Ensinar/desenvolver a habilidade de demonstra quando está triste ou bravo com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Demonstra quando está triste ou bravo”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Demonstra quando está triste ou bravo”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Demonstra quando está triste ou bravo” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F02A', 'F02AS004', 'Demonstra quando está triste ou bravo', 'generalizacao', 4, 'Nomeação e imitação de emoções básicas', 'Resposta emocional', 'Generalizar a habilidade de demonstra quando está triste ou bravo para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Demonstra quando está triste ou bravo”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Demonstra quando está triste ou bravo” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F02A', 'F02AS004', 'Demonstra quando está triste ou bravo', 'manutencao', 4, 'Nomeação e imitação de emoções básicas', 'Resposta emocional', 'Manter a habilidade de demonstra quando está triste ou bravo de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Demonstra quando está triste ou bravo”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Demonstra quando está triste ou bravo” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F03A', 'F03AG001', 'Mostra algo a outra pessoa', 'aquisicao', 1, 'Atenção compartilhada com reforço social', 'Atenção conjunta', 'Ensinar/desenvolver a habilidade de mostra algo a outra pessoa com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Mostra algo a outra pessoa”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Mostra algo a outra pessoa”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Mostra algo a outra pessoa” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F03A', 'F03AG001', 'Mostra algo a outra pessoa', 'generalizacao', 1, 'Atenção compartilhada com reforço social', 'Atenção conjunta', 'Generalizar a habilidade de mostra algo a outra pessoa para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Mostra algo a outra pessoa”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Mostra algo a outra pessoa” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F03A', 'F03AG001', 'Mostra algo a outra pessoa', 'manutencao', 1, 'Atenção compartilhada com reforço social', 'Atenção conjunta', 'Manter a habilidade de mostra algo a outra pessoa de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Mostra algo a outra pessoa”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Mostra algo a outra pessoa” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F03A', 'F03AG002', 'Brinca com tintas, areia ou massinha', 'aquisicao', 2, 'Estímulo sensorial com materiais variados', 'Exploratória', 'Ensinar/desenvolver a habilidade de brinca com tintas, areia ou massinha com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Brinca com tintas, areia ou massinha”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Brinca com tintas, areia ou massinha”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Brinca com tintas, areia ou massinha” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F03A', 'F03AG002', 'Brinca com tintas, areia ou massinha', 'generalizacao', 2, 'Estímulo sensorial com materiais variados', 'Exploratória', 'Generalizar a habilidade de brinca com tintas, areia ou massinha para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Brinca com tintas, areia ou massinha”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Brinca com tintas, areia ou massinha” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F03A', 'F03AG002', 'Brinca com tintas, areia ou massinha', 'manutencao', 2, 'Estímulo sensorial com materiais variados', 'Exploratória', 'Manter a habilidade de brinca com tintas, areia ou massinha de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Brinca com tintas, areia ou massinha”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Brinca com tintas, areia ou massinha” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F03A', 'F03AG003', 'Agrupa por categoria', 'aquisicao', 3, 'Classificação de itens por semelhança', 'Combinação', 'Ensinar/desenvolver a habilidade de agrupa por categoria com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Agrupa por categoria”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Agrupa por categoria”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Agrupa por categoria” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F03A', 'F03AG003', 'Agrupa por categoria', 'generalizacao', 3, 'Classificação de itens por semelhança', 'Combinação', 'Generalizar a habilidade de agrupa por categoria para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Agrupa por categoria”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Agrupa por categoria” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F03A', 'F03AG003', 'Agrupa por categoria', 'manutencao', 3, 'Classificação de itens por semelhança', 'Combinação', 'Manter a habilidade de agrupa por categoria de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Agrupa por categoria”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Agrupa por categoria” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F03A', 'F03AG004', 'Copia linhas verticais e horizontais', 'aquisicao', 4, 'Modelagem motora com reforço', 'Uso do lápis', 'Ensinar/desenvolver a habilidade de copia linhas verticais e horizontais com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Copia linhas verticais e horizontais”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Copia linhas verticais e horizontais”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Copia linhas verticais e horizontais” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F03A', 'F03AG004', 'Copia linhas verticais e horizontais', 'generalizacao', 4, 'Modelagem motora com reforço', 'Uso do lápis', 'Generalizar a habilidade de copia linhas verticais e horizontais para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Copia linhas verticais e horizontais”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Copia linhas verticais e horizontais” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F03A', 'F03AG004', 'Copia linhas verticais e horizontais', 'manutencao', 4, 'Modelagem motora com reforço', 'Uso do lápis', 'Manter a habilidade de copia linhas verticais e horizontais de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Copia linhas verticais e horizontais”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Copia linhas verticais e horizontais” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F03A', 'F03AC001', 'Alterna o olhar com pessoa e objeto', 'aquisicao', 1, 'Alternância de foco em contexto social', 'Atenção conjunta', 'Ensinar/desenvolver a habilidade de alterna o olhar com pessoa e objeto com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Alterna o olhar com pessoa e objeto”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Brinquedos/objetos adequados à habilidade; modelos simples.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Alterna o olhar com pessoa e objeto”.', '1. Física: não utilizar para forçar contato visual.
2. Gestual: orientar suavemente para o interlocutor/estímulo.
3. Visual: posicionar o estímulo relevante no campo visual.
4. Verbal: lembrete curto, quando necessário.
5. I = Independente.', 'A criança realiza “Alterna o olhar com pessoa e objeto” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Não segurar o rosto nem exigir olhar fixo contínuo; valorizar orientação funcional ao interlocutor.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F03A', 'F03AC001', 'Alterna o olhar com pessoa e objeto', 'generalizacao', 1, 'Alternância de foco em contexto social', 'Atenção conjunta', 'Generalizar a habilidade de alterna o olhar com pessoa e objeto para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Brinquedos/objetos adequados à habilidade; modelos simples.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Alterna o olhar com pessoa e objeto”.', '1. Física: não utilizar para forçar contato visual.
2. Gestual: orientar suavemente para o interlocutor/estímulo.
3. Visual: posicionar o estímulo relevante no campo visual.
4. Verbal: lembrete curto, quando necessário.
5. I = Independente.', 'A criança realiza “Alterna o olhar com pessoa e objeto” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Não segurar o rosto nem exigir olhar fixo contínuo; valorizar orientação funcional ao interlocutor.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F03A', 'F03AC001', 'Alterna o olhar com pessoa e objeto', 'manutencao', 1, 'Alternância de foco em contexto social', 'Atenção conjunta', 'Manter a habilidade de alterna o olhar com pessoa e objeto de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Brinquedos/objetos adequados à habilidade; modelos simples.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Alterna o olhar com pessoa e objeto”.', '1. Física: não utilizar para forçar contato visual.
2. Gestual: orientar suavemente para o interlocutor/estímulo.
3. Visual: posicionar o estímulo relevante no campo visual.
4. Verbal: lembrete curto, quando necessário.
5. I = Independente.', 'A criança mantém “Alterna o olhar com pessoa e objeto” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Não segurar o rosto nem exigir olhar fixo contínuo; valorizar orientação funcional ao interlocutor.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F03A', 'F03AC002', 'Usa gestos sociais espontâneos', 'aquisicao', 2, 'Ensino de gestos funcionais', 'Comunicação funcional', 'Ensinar/desenvolver a habilidade de usa gestos sociais espontâneos com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Usa gestos sociais espontâneos”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Usa gestos sociais espontâneos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Usa gestos sociais espontâneos” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F03A', 'F03AC002', 'Usa gestos sociais espontâneos', 'generalizacao', 2, 'Ensino de gestos funcionais', 'Comunicação funcional', 'Generalizar a habilidade de usa gestos sociais espontâneos para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Usa gestos sociais espontâneos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Usa gestos sociais espontâneos” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F03A', 'F03AC002', 'Usa gestos sociais espontâneos', 'manutencao', 2, 'Ensino de gestos funcionais', 'Comunicação funcional', 'Manter a habilidade de usa gestos sociais espontâneos de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Usa gestos sociais espontâneos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Usa gestos sociais espontâneos” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F03A', 'F03AC003', 'Pede brinquedos ou alimentos favoritos', 'aquisicao', 3, 'Mandos generalizados com reforço natural', 'Expressiva', 'Ensinar/desenvolver a habilidade de pede brinquedos ou alimentos favoritos com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Pede brinquedos ou alimentos favoritos”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Alimentos habituais e/ou alvo; utensílios adequados; mesa/cadeira.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Pede brinquedos ou alimentos favoritos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Pede brinquedos ou alimentos favoritos” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Não forçar ingestão; diante de recusa intensa, engasgos, dor ou dificuldade alimentar persistente, interromper e buscar avaliação profissional.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F03A', 'F03AC003', 'Pede brinquedos ou alimentos favoritos', 'generalizacao', 3, 'Mandos generalizados com reforço natural', 'Expressiva', 'Generalizar a habilidade de pede brinquedos ou alimentos favoritos para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Alimentos habituais e/ou alvo; utensílios adequados; mesa/cadeira.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Pede brinquedos ou alimentos favoritos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Pede brinquedos ou alimentos favoritos” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Não forçar ingestão; diante de recusa intensa, engasgos, dor ou dificuldade alimentar persistente, interromper e buscar avaliação profissional.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F03A', 'F03AC003', 'Pede brinquedos ou alimentos favoritos', 'manutencao', 3, 'Mandos generalizados com reforço natural', 'Expressiva', 'Manter a habilidade de pede brinquedos ou alimentos favoritos de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Alimentos habituais e/ou alvo; utensílios adequados; mesa/cadeira.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Pede brinquedos ou alimentos favoritos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Pede brinquedos ou alimentos favoritos” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Não forçar ingestão; diante de recusa intensa, engasgos, dor ou dificuldade alimentar persistente, interromper e buscar avaliação profissional.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F03A', 'F03AC004', 'Identifica partes do corpo', 'aquisicao', 4, 'Tato com partes do corpo', 'Receptiva', 'Ensinar/desenvolver a habilidade de identifica partes do corpo com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Identifica partes do corpo”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Identifica partes do corpo”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Identifica partes do corpo” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F03A', 'F03AC004', 'Identifica partes do corpo', 'generalizacao', 4, 'Tato com partes do corpo', 'Receptiva', 'Generalizar a habilidade de identifica partes do corpo para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Identifica partes do corpo”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Identifica partes do corpo” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F03A', 'F03AC004', 'Identifica partes do corpo', 'manutencao', 4, 'Tato com partes do corpo', 'Receptiva', 'Manter a habilidade de identifica partes do corpo de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Identifica partes do corpo”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Identifica partes do corpo” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F03A', 'F03AC005', 'Responde a perguntas simples', 'aquisicao', 5, 'Respostas a mandos simples', 'Receptiva', 'Ensinar/desenvolver a habilidade de responde a perguntas simples com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Responde a perguntas simples”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Responde a perguntas simples”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Responde a perguntas simples” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F03A', 'F03AC005', 'Responde a perguntas simples', 'generalizacao', 5, 'Respostas a mandos simples', 'Receptiva', 'Generalizar a habilidade de responde a perguntas simples para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Responde a perguntas simples”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Responde a perguntas simples” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F03A', 'F03AC005', 'Responde a perguntas simples', 'manutencao', 5, 'Respostas a mandos simples', 'Receptiva', 'Manter a habilidade de responde a perguntas simples de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Responde a perguntas simples”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Responde a perguntas simples” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F03A', 'F03AF001', 'Aceita alimentos variados', 'aquisicao', 1, 'Dessensibilização alimentar com reforço', 'Alimentação', 'Ensinar/desenvolver a habilidade de aceita alimentos variados com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Aceita alimentos variados”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Alimentos habituais e/ou alvo; utensílios adequados; mesa/cadeira.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Treinar na rotina natural; 1–3 oportunidades/dia, sem transformar toda a rotina em sessão.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Aceita alimentos variados”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Aceita alimentos variados” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Não forçar ingestão; diante de recusa intensa, engasgos, dor ou dificuldade alimentar persistente, interromper e buscar avaliação profissional.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F03A', 'F03AF001', 'Aceita alimentos variados', 'generalizacao', 1, 'Dessensibilização alimentar com reforço', 'Alimentação', 'Generalizar a habilidade de aceita alimentos variados para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Alimentos habituais e/ou alvo; utensílios adequados; mesa/cadeira.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Aceita alimentos variados”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Aceita alimentos variados” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Não forçar ingestão; diante de recusa intensa, engasgos, dor ou dificuldade alimentar persistente, interromper e buscar avaliação profissional.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F03A', 'F03AF001', 'Aceita alimentos variados', 'manutencao', 1, 'Dessensibilização alimentar com reforço', 'Alimentação', 'Manter a habilidade de aceita alimentos variados de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Alimentos habituais e/ou alvo; utensílios adequados; mesa/cadeira.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Aceita alimentos variados”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Aceita alimentos variados” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Não forçar ingestão; diante de recusa intensa, engasgos, dor ou dificuldade alimentar persistente, interromper e buscar avaliação profissional.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F03A', 'F03AF002', 'Lava as mãos com supervisão leve', 'aquisicao', 2, 'Rotina de higiene com fading de ajuda', 'Higiene', 'Ensinar/desenvolver a habilidade de lava as mãos com supervisão leve com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Lava as mãos com supervisão leve”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Itens reais da rotina de higiene; apoio visual opcional.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Treinar na rotina natural; 1–3 oportunidades/dia, sem transformar toda a rotina em sessão.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Lava as mãos com supervisão leve”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Lava as mãos com supervisão leve” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F03A', 'F03AF002', 'Lava as mãos com supervisão leve', 'generalizacao', 2, 'Rotina de higiene com fading de ajuda', 'Higiene', 'Generalizar a habilidade de lava as mãos com supervisão leve para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Itens reais da rotina de higiene; apoio visual opcional.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Lava as mãos com supervisão leve”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Lava as mãos com supervisão leve” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F03A', 'F03AF002', 'Lava as mãos com supervisão leve', 'manutencao', 2, 'Rotina de higiene com fading de ajuda', 'Higiene', 'Manter a habilidade de lava as mãos com supervisão leve de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Itens reais da rotina de higiene; apoio visual opcional.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Lava as mãos com supervisão leve”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Lava as mãos com supervisão leve” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F03A', 'F03AF003', 'Retira camisa e calça com apoio verbal', 'aquisicao', 3, 'Modelagem de sequência de vestir e despir', 'Vestuário', 'Ensinar/desenvolver a habilidade de retira camisa e calça com apoio verbal com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Retira camisa e calça com apoio verbal”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Treinar na rotina natural; 1–3 oportunidades/dia, sem transformar toda a rotina em sessão.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Retira camisa e calça com apoio verbal”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Retira camisa e calça com apoio verbal” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F03A', 'F03AF003', 'Retira camisa e calça com apoio verbal', 'generalizacao', 3, 'Modelagem de sequência de vestir e despir', 'Vestuário', 'Generalizar a habilidade de retira camisa e calça com apoio verbal para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Retira camisa e calça com apoio verbal”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Retira camisa e calça com apoio verbal” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F03A', 'F03AF003', 'Retira camisa e calça com apoio verbal', 'manutencao', 3, 'Modelagem de sequência de vestir e despir', 'Vestuário', 'Manter a habilidade de retira camisa e calça com apoio verbal de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Retira camisa e calça com apoio verbal”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Retira camisa e calça com apoio verbal” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F03A', 'F03AF004', 'Usa penico com apoio', 'aquisicao', 4, 'Treino de desfralde com apoio e reforço', 'Banheiro', 'Ensinar/desenvolver a habilidade de usa penico com apoio com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Usa penico com apoio”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Itens reais da rotina de banheiro; apoio visual opcional; roupas fáceis de manejar.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Treinar na rotina natural; 1–3 oportunidades/dia, sem transformar toda a rotina em sessão.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Usa penico com apoio”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Usa penico com apoio” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Evitar punição, vergonha ou permanência forçada no vaso/penico.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F03A', 'F03AF004', 'Usa penico com apoio', 'generalizacao', 4, 'Treino de desfralde com apoio e reforço', 'Banheiro', 'Generalizar a habilidade de usa penico com apoio para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Itens reais da rotina de banheiro; apoio visual opcional; roupas fáceis de manejar.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Usa penico com apoio”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Usa penico com apoio” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Evitar punição, vergonha ou permanência forçada no vaso/penico.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F03A', 'F03AF004', 'Usa penico com apoio', 'manutencao', 4, 'Treino de desfralde com apoio e reforço', 'Banheiro', 'Manter a habilidade de usa penico com apoio de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Itens reais da rotina de banheiro; apoio visual opcional; roupas fáceis de manejar.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Usa penico com apoio”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Usa penico com apoio” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Evitar punição, vergonha ou permanência forçada no vaso/penico.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F03A', 'F03AM001', 'Corre com equilíbrio', 'aquisicao', 1, 'Treino motor amplo com reforço funcional', 'Motora global', 'Ensinar/desenvolver a habilidade de corre com equilíbrio com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Corre com equilíbrio”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas, respeitando segurança e fadiga.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Corre com equilíbrio”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Corre com equilíbrio” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F03A', 'F03AM001', 'Corre com equilíbrio', 'generalizacao', 1, 'Treino motor amplo com reforço funcional', 'Motora global', 'Generalizar a habilidade de corre com equilíbrio para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Corre com equilíbrio”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Corre com equilíbrio” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F03A', 'F03AM001', 'Corre com equilíbrio', 'manutencao', 1, 'Treino motor amplo com reforço funcional', 'Motora global', 'Manter a habilidade de corre com equilíbrio de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Corre com equilíbrio”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Corre com equilíbrio” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F03A', 'F03AM002', 'Usa pinça para pegar objetos pequenos', 'aquisicao', 2, 'Coordenação motora fina com reforço', 'Motora fina', 'Ensinar/desenvolver a habilidade de usa pinça para pegar objetos pequenos com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Usa pinça para pegar objetos pequenos”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Brinquedos/objetos adequados à habilidade; modelos simples.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas, respeitando segurança e fadiga.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Usa pinça para pegar objetos pequenos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Usa pinça para pegar objetos pequenos” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F03A', 'F03AM002', 'Usa pinça para pegar objetos pequenos', 'generalizacao', 2, 'Coordenação motora fina com reforço', 'Motora fina', 'Generalizar a habilidade de usa pinça para pegar objetos pequenos para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Brinquedos/objetos adequados à habilidade; modelos simples.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Usa pinça para pegar objetos pequenos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Usa pinça para pegar objetos pequenos” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F03A', 'F03AM002', 'Usa pinça para pegar objetos pequenos', 'manutencao', 2, 'Coordenação motora fina com reforço', 'Motora fina', 'Manter a habilidade de usa pinça para pegar objetos pequenos de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Brinquedos/objetos adequados à habilidade; modelos simples.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Usa pinça para pegar objetos pequenos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Usa pinça para pegar objetos pequenos” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F03A', 'F03AM003', 'Faz torre com 6 blocos', 'aquisicao', 3, 'Construção com blocos com reforço diferencial', 'Objeto', 'Ensinar/desenvolver a habilidade de faz torre com 6 blocos com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Faz torre com 6 blocos”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Brinquedos/objetos adequados à habilidade; modelos simples.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas, respeitando segurança e fadiga.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Faz torre com 6 blocos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Faz torre com 6 blocos” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F03A', 'F03AM003', 'Faz torre com 6 blocos', 'generalizacao', 3, 'Construção com blocos com reforço diferencial', 'Objeto', 'Generalizar a habilidade de faz torre com 6 blocos para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Brinquedos/objetos adequados à habilidade; modelos simples.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Faz torre com 6 blocos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Faz torre com 6 blocos” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F03A', 'F03AM003', 'Faz torre com 6 blocos', 'manutencao', 3, 'Construção com blocos com reforço diferencial', 'Objeto', 'Manter a habilidade de faz torre com 6 blocos de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Brinquedos/objetos adequados à habilidade; modelos simples.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Faz torre com 6 blocos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Faz torre com 6 blocos” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F03A', 'F03AM004', 'Joga bola a uma distância de 2 metros', 'aquisicao', 4, 'Coordenação de arremesso com reforço social', 'Bola', 'Ensinar/desenvolver a habilidade de joga bola a uma distância de 2 metros com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Joga bola a uma distância de 2 metros”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Bola adequada à idade; alvo/cones opcionais; espaço seguro.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas, respeitando segurança e fadiga.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Joga bola a uma distância de 2 metros”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Joga bola a uma distância de 2 metros” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F03A', 'F03AM004', 'Joga bola a uma distância de 2 metros', 'generalizacao', 4, 'Coordenação de arremesso com reforço social', 'Bola', 'Generalizar a habilidade de joga bola a uma distância de 2 metros para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Bola adequada à idade; alvo/cones opcionais; espaço seguro.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Joga bola a uma distância de 2 metros”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Joga bola a uma distância de 2 metros” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F03A', 'F03AM004', 'Joga bola a uma distância de 2 metros', 'manutencao', 4, 'Coordenação de arremesso com reforço social', 'Bola', 'Manter a habilidade de joga bola a uma distância de 2 metros de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Bola adequada à idade; alvo/cones opcionais; espaço seguro.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Joga bola a uma distância de 2 metros”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Joga bola a uma distância de 2 metros” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F03A', 'F03AS001', 'Imita 3 ações em sequência', 'aquisicao', 1, 'Sequência de imitação motora com reforço', 'Imitação', 'Ensinar/desenvolver a habilidade de imita 3 ações em sequência com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Imita 3 ações em sequência”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Imita 3 ações em sequência”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Imita 3 ações em sequência” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F03A', 'F03AS001', 'Imita 3 ações em sequência', 'generalizacao', 1, 'Sequência de imitação motora com reforço', 'Imitação', 'Generalizar a habilidade de imita 3 ações em sequência para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Imita 3 ações em sequência”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Imita 3 ações em sequência” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F03A', 'F03AS001', 'Imita 3 ações em sequência', 'manutencao', 1, 'Sequência de imitação motora com reforço', 'Imitação', 'Manter a habilidade de imita 3 ações em sequência de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Imita 3 ações em sequência”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Imita 3 ações em sequência” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F03A', 'F03AS002', 'Brinca de faz-de-conta simples', 'aquisicao', 2, 'Jogos simbólicos com bonecos', 'Brincar', 'Ensinar/desenvolver a habilidade de brinca de faz-de-conta simples com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Brinca de faz-de-conta simples”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Brinca de faz-de-conta simples”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Brinca de faz-de-conta simples” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F03A', 'F03AS002', 'Brinca de faz-de-conta simples', 'generalizacao', 2, 'Jogos simbólicos com bonecos', 'Brincar', 'Generalizar a habilidade de brinca de faz-de-conta simples para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Brinca de faz-de-conta simples”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Brinca de faz-de-conta simples” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F03A', 'F03AS002', 'Brinca de faz-de-conta simples', 'manutencao', 2, 'Jogos simbólicos com bonecos', 'Brincar', 'Manter a habilidade de brinca de faz-de-conta simples de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Brinca de faz-de-conta simples”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Brinca de faz-de-conta simples” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F03A', 'F03AS003', 'Aguarda 2 minutos', 'aquisicao', 3, 'Extensão gradual de tempo de espera', 'Tolerância', 'Ensinar/desenvolver a habilidade de aguarda 2 minutos com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Aguarda 2 minutos”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Aguarda 2 minutos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Aguarda 2 minutos” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F03A', 'F03AS003', 'Aguarda 2 minutos', 'generalizacao', 3, 'Extensão gradual de tempo de espera', 'Tolerância', 'Generalizar a habilidade de aguarda 2 minutos para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Aguarda 2 minutos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Aguarda 2 minutos” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F03A', 'F03AS003', 'Aguarda 2 minutos', 'manutencao', 3, 'Extensão gradual de tempo de espera', 'Tolerância', 'Manter a habilidade de aguarda 2 minutos de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Aguarda 2 minutos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Aguarda 2 minutos” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F03A', 'F03AS004', 'Nomeia emoções básicas', 'aquisicao', 4, 'Ensino de nomeação de emoções', 'Resposta emocional', 'Ensinar/desenvolver a habilidade de nomeia emoções básicas com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Nomeia emoções básicas”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Nomeia emoções básicas”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Nomeia emoções básicas” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F03A', 'F03AS004', 'Nomeia emoções básicas', 'generalizacao', 4, 'Ensino de nomeação de emoções', 'Resposta emocional', 'Generalizar a habilidade de nomeia emoções básicas para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Nomeia emoções básicas”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Nomeia emoções básicas” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F03A', 'F03AS004', 'Nomeia emoções básicas', 'manutencao', 4, 'Ensino de nomeação de emoções', 'Resposta emocional', 'Manter a habilidade de nomeia emoções básicas de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Nomeia emoções básicas”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Nomeia emoções básicas” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F04A', 'F04AG001', 'Participa de atividades coletivas com atenção', 'aquisicao', 1, 'Engajamento em grupo com estímulo auditivo', 'Atenção conjunta', 'Ensinar/desenvolver a habilidade de participa de atividades coletivas com atenção com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Participa de atividades coletivas com atenção”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Participa de atividades coletivas com atenção”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Participa de atividades coletivas com atenção” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F04A', 'F04AG001', 'Participa de atividades coletivas com atenção', 'generalizacao', 1, 'Engajamento em grupo com estímulo auditivo', 'Atenção conjunta', 'Generalizar a habilidade de participa de atividades coletivas com atenção para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Participa de atividades coletivas com atenção”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Participa de atividades coletivas com atenção” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F04A', 'F04AG001', 'Participa de atividades coletivas com atenção', 'manutencao', 1, 'Engajamento em grupo com estímulo auditivo', 'Atenção conjunta', 'Manter a habilidade de participa de atividades coletivas com atenção de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Participa de atividades coletivas com atenção”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Participa de atividades coletivas com atenção” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F04A', 'F04AG002', 'Usa objetos de forma simbólica ou criativa', 'aquisicao', 2, 'Jogo simbólico com objetos variados', 'Exploração', 'Ensinar/desenvolver a habilidade de usa objetos de forma simbólica ou criativa com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Usa objetos de forma simbólica ou criativa”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Brinquedos/objetos adequados à habilidade; modelos simples.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Usa objetos de forma simbólica ou criativa”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Usa objetos de forma simbólica ou criativa” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F04A', 'F04AG002', 'Usa objetos de forma simbólica ou criativa', 'generalizacao', 2, 'Jogo simbólico com objetos variados', 'Exploração', 'Generalizar a habilidade de usa objetos de forma simbólica ou criativa para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Brinquedos/objetos adequados à habilidade; modelos simples.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Usa objetos de forma simbólica ou criativa”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Usa objetos de forma simbólica ou criativa” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F04A', 'F04AG002', 'Usa objetos de forma simbólica ou criativa', 'manutencao', 2, 'Jogo simbólico com objetos variados', 'Exploração', 'Manter a habilidade de usa objetos de forma simbólica ou criativa de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Brinquedos/objetos adequados à habilidade; modelos simples.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Usa objetos de forma simbólica ou criativa”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Usa objetos de forma simbólica ou criativa” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F04A', 'F04AG003', 'Emparelha palavra escrita com imagem', 'aquisicao', 3, 'Leitura funcional com pareamento', 'Combinação', 'Ensinar/desenvolver a habilidade de emparelha palavra escrita com imagem com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Emparelha palavra escrita com imagem”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Emparelha palavra escrita com imagem”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Emparelha palavra escrita com imagem” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F04A', 'F04AG003', 'Emparelha palavra escrita com imagem', 'generalizacao', 3, 'Leitura funcional com pareamento', 'Combinação', 'Generalizar a habilidade de emparelha palavra escrita com imagem para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Emparelha palavra escrita com imagem”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Emparelha palavra escrita com imagem” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F04A', 'F04AG003', 'Emparelha palavra escrita com imagem', 'manutencao', 3, 'Leitura funcional com pareamento', 'Combinação', 'Manter a habilidade de emparelha palavra escrita com imagem de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Emparelha palavra escrita com imagem”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Emparelha palavra escrita com imagem” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F04A', 'F04AG004', 'Desenha formas básicas', 'aquisicao', 4, 'Ensino de traçados e formas básicas', 'Uso do lápis', 'Ensinar/desenvolver a habilidade de desenha formas básicas com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Desenha formas básicas”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Desenha formas básicas”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Desenha formas básicas” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F04A', 'F04AG004', 'Desenha formas básicas', 'generalizacao', 4, 'Ensino de traçados e formas básicas', 'Uso do lápis', 'Generalizar a habilidade de desenha formas básicas para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Desenha formas básicas”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Desenha formas básicas” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F04A', 'F04AG004', 'Desenha formas básicas', 'manutencao', 4, 'Ensino de traçados e formas básicas', 'Uso do lápis', 'Manter a habilidade de desenha formas básicas de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Desenha formas básicas”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Desenha formas básicas” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F04A', 'F04AC001', 'Alterna o olhar com mais de uma pessoa', 'aquisicao', 1, 'Alternância social com turnos visuais', 'Atenção conjunta', 'Ensinar/desenvolver a habilidade de alterna o olhar com mais de uma pessoa com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Alterna o olhar com mais de uma pessoa”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Alterna o olhar com mais de uma pessoa”.', '1. Física: não utilizar para forçar contato visual.
2. Gestual: orientar suavemente para o interlocutor/estímulo.
3. Visual: posicionar o estímulo relevante no campo visual.
4. Verbal: lembrete curto, quando necessário.
5. I = Independente.', 'A criança realiza “Alterna o olhar com mais de uma pessoa” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Não segurar o rosto nem exigir olhar fixo contínuo; valorizar orientação funcional ao interlocutor.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F04A', 'F04AC001', 'Alterna o olhar com mais de uma pessoa', 'generalizacao', 1, 'Alternância social com turnos visuais', 'Atenção conjunta', 'Generalizar a habilidade de alterna o olhar com mais de uma pessoa para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Alterna o olhar com mais de uma pessoa”.', '1. Física: não utilizar para forçar contato visual.
2. Gestual: orientar suavemente para o interlocutor/estímulo.
3. Visual: posicionar o estímulo relevante no campo visual.
4. Verbal: lembrete curto, quando necessário.
5. I = Independente.', 'A criança realiza “Alterna o olhar com mais de uma pessoa” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Não segurar o rosto nem exigir olhar fixo contínuo; valorizar orientação funcional ao interlocutor.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F04A', 'F04AC001', 'Alterna o olhar com mais de uma pessoa', 'manutencao', 1, 'Alternância social com turnos visuais', 'Atenção conjunta', 'Manter a habilidade de alterna o olhar com mais de uma pessoa de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Alterna o olhar com mais de uma pessoa”.', '1. Física: não utilizar para forçar contato visual.
2. Gestual: orientar suavemente para o interlocutor/estímulo.
3. Visual: posicionar o estímulo relevante no campo visual.
4. Verbal: lembrete curto, quando necessário.
5. I = Independente.', 'A criança mantém “Alterna o olhar com mais de uma pessoa” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Não segurar o rosto nem exigir olhar fixo contínuo; valorizar orientação funcional ao interlocutor.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F04A', 'F04AC002', 'Usa PECS, gestos ou desenhos para pedir', 'aquisicao', 2, 'PECS Fase IV+ (frases e sentimentos)', 'Comunicação alternativa', 'Ensinar/desenvolver a habilidade de usa pecs, gestos ou desenhos para pedir com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Usa PECS, gestos ou desenhos para pedir”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Sistema de CAA já utilizado; figuras/símbolos; itens e atividades motivadoras.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Usa PECS, gestos ou desenhos para pedir”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Usa PECS, gestos ou desenhos para pedir” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F04A', 'F04AC002', 'Usa PECS, gestos ou desenhos para pedir', 'generalizacao', 2, 'PECS Fase IV+ (frases e sentimentos)', 'Comunicação alternativa', 'Generalizar a habilidade de usa pecs, gestos ou desenhos para pedir para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Sistema de CAA já utilizado; figuras/símbolos; itens e atividades motivadoras.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Usa PECS, gestos ou desenhos para pedir”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Usa PECS, gestos ou desenhos para pedir” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F04A', 'F04AC002', 'Usa PECS, gestos ou desenhos para pedir', 'manutencao', 2, 'PECS Fase IV+ (frases e sentimentos)', 'Comunicação alternativa', 'Manter a habilidade de usa pecs, gestos ou desenhos para pedir de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Sistema de CAA já utilizado; figuras/símbolos; itens e atividades motivadoras.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Usa PECS, gestos ou desenhos para pedir”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Usa PECS, gestos ou desenhos para pedir” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F04A', 'F04AC003', 'Nomeia objetos, pessoas e figuras com clareza', 'aquisicao', 3, 'Tato expandido com generalização', 'Expressiva', 'Ensinar/desenvolver a habilidade de nomeia objetos, pessoas e figuras com clareza com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Nomeia objetos, pessoas e figuras com clareza”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Brinquedos/objetos adequados à habilidade; modelos simples.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Nomeia objetos, pessoas e figuras com clareza”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Nomeia objetos, pessoas e figuras com clareza” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F04A', 'F04AC003', 'Nomeia objetos, pessoas e figuras com clareza', 'generalizacao', 3, 'Tato expandido com generalização', 'Expressiva', 'Generalizar a habilidade de nomeia objetos, pessoas e figuras com clareza para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Brinquedos/objetos adequados à habilidade; modelos simples.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Nomeia objetos, pessoas e figuras com clareza”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Nomeia objetos, pessoas e figuras com clareza” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F04A', 'F04AC003', 'Nomeia objetos, pessoas e figuras com clareza', 'manutencao', 3, 'Tato expandido com generalização', 'Expressiva', 'Manter a habilidade de nomeia objetos, pessoas e figuras com clareza de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Brinquedos/objetos adequados à habilidade; modelos simples.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Nomeia objetos, pessoas e figuras com clareza”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Nomeia objetos, pessoas e figuras com clareza” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F04A', 'F04AC004', 'Responde a perguntas como “qual é a sua cor preferida?”', 'aquisicao', 4, 'Mandos intraverbais simples', 'Receptiva', 'Ensinar/desenvolver a habilidade de responde a perguntas como “qual é a sua cor preferida?” com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Responde a perguntas como “qual é a sua cor preferida?””.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Responde a perguntas como “qual é a sua cor preferida?””.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Responde a perguntas como “qual é a sua cor preferida?”” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F04A', 'F04AC004', 'Responde a perguntas como “qual é a sua cor preferida?”', 'generalizacao', 4, 'Mandos intraverbais simples', 'Receptiva', 'Generalizar a habilidade de responde a perguntas como “qual é a sua cor preferida?” para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Responde a perguntas como “qual é a sua cor preferida?””.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Responde a perguntas como “qual é a sua cor preferida?”” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F04A', 'F04AC004', 'Responde a perguntas como “qual é a sua cor preferida?”', 'manutencao', 4, 'Mandos intraverbais simples', 'Receptiva', 'Manter a habilidade de responde a perguntas como “qual é a sua cor preferida?” de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Responde a perguntas como “qual é a sua cor preferida?””.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Responde a perguntas como “qual é a sua cor preferida?”” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F04A', 'F04AC005', 'Segue comandos com 3 passos', 'aquisicao', 5, 'Sequência de instruções com suporte visual', 'Receptiva', 'Ensinar/desenvolver a habilidade de segue comandos com 3 passos com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Segue comandos com 3 passos”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Segue comandos com 3 passos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Segue comandos com 3 passos” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F04A', 'F04AC005', 'Segue comandos com 3 passos', 'generalizacao', 5, 'Sequência de instruções com suporte visual', 'Receptiva', 'Generalizar a habilidade de segue comandos com 3 passos para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Segue comandos com 3 passos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Segue comandos com 3 passos” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F04A', 'F04AC005', 'Segue comandos com 3 passos', 'manutencao', 5, 'Sequência de instruções com suporte visual', 'Receptiva', 'Manter a habilidade de segue comandos com 3 passos de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Segue comandos com 3 passos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Segue comandos com 3 passos” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F04A', 'F04AF001', 'Aceita diferentes texturas e cores', 'aquisicao', 1, 'Expansão alimentar com dessensibilização', 'Alimentação', 'Ensinar/desenvolver a habilidade de aceita diferentes texturas e cores com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Aceita diferentes texturas e cores”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Treinar na rotina natural; 1–3 oportunidades/dia, sem transformar toda a rotina em sessão.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Aceita diferentes texturas e cores”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Aceita diferentes texturas e cores” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F04A', 'F04AF001', 'Aceita diferentes texturas e cores', 'generalizacao', 1, 'Expansão alimentar com dessensibilização', 'Alimentação', 'Generalizar a habilidade de aceita diferentes texturas e cores para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Aceita diferentes texturas e cores”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Aceita diferentes texturas e cores” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F04A', 'F04AF001', 'Aceita diferentes texturas e cores', 'manutencao', 1, 'Expansão alimentar com dessensibilização', 'Alimentação', 'Manter a habilidade de aceita diferentes texturas e cores de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Aceita diferentes texturas e cores”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Aceita diferentes texturas e cores” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F04A', 'F04AF002', 'Lava o rosto e as mãos sozinho', 'aquisicao', 2, 'Treino de rotina com independência parcial', 'Higiene', 'Ensinar/desenvolver a habilidade de lava o rosto e as mãos sozinho com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Lava o rosto e as mãos sozinho”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Itens reais da rotina de higiene; apoio visual opcional.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Treinar na rotina natural; 1–3 oportunidades/dia, sem transformar toda a rotina em sessão.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Lava o rosto e as mãos sozinho”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Lava o rosto e as mãos sozinho” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F04A', 'F04AF002', 'Lava o rosto e as mãos sozinho', 'generalizacao', 2, 'Treino de rotina com independência parcial', 'Higiene', 'Generalizar a habilidade de lava o rosto e as mãos sozinho para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Itens reais da rotina de higiene; apoio visual opcional.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Lava o rosto e as mãos sozinho”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Lava o rosto e as mãos sozinho” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F04A', 'F04AF002', 'Lava o rosto e as mãos sozinho', 'manutencao', 2, 'Treino de rotina com independência parcial', 'Higiene', 'Manter a habilidade de lava o rosto e as mãos sozinho de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Itens reais da rotina de higiene; apoio visual opcional.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Lava o rosto e as mãos sozinho”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Lava o rosto e as mãos sozinho” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F04A', 'F04AF003', 'Veste calça e camiseta sozinho', 'aquisicao', 3, 'Treino de sequência de vestir com fading', 'Vestuário', 'Ensinar/desenvolver a habilidade de veste calça e camiseta sozinho com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Veste calça e camiseta sozinho”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Roupas da criança; espelho opcional; sequência visual opcional.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Treinar na rotina natural; 1–3 oportunidades/dia, sem transformar toda a rotina em sessão.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Veste calça e camiseta sozinho”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Veste calça e camiseta sozinho” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F04A', 'F04AF003', 'Veste calça e camiseta sozinho', 'generalizacao', 3, 'Treino de sequência de vestir com fading', 'Vestuário', 'Generalizar a habilidade de veste calça e camiseta sozinho para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Roupas da criança; espelho opcional; sequência visual opcional.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Veste calça e camiseta sozinho”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Veste calça e camiseta sozinho” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F04A', 'F04AF003', 'Veste calça e camiseta sozinho', 'manutencao', 3, 'Treino de sequência de vestir com fading', 'Vestuário', 'Manter a habilidade de veste calça e camiseta sozinho de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Roupas da criança; espelho opcional; sequência visual opcional.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Veste calça e camiseta sozinho”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Veste calça e camiseta sozinho” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F04A', 'F04AF004', 'Usa o banheiro e faz higiene com pouca ajuda', 'aquisicao', 4, 'Desfralde com reforço e independência gradual', 'Banheiro', 'Ensinar/desenvolver a habilidade de usa o banheiro e faz higiene com pouca ajuda com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Usa o banheiro e faz higiene com pouca ajuda”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Itens reais da rotina de higiene; apoio visual opcional.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Treinar na rotina natural; 1–3 oportunidades/dia, sem transformar toda a rotina em sessão.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Usa o banheiro e faz higiene com pouca ajuda”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Usa o banheiro e faz higiene com pouca ajuda” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Evitar punição, vergonha ou permanência forçada no vaso/penico.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F04A', 'F04AF004', 'Usa o banheiro e faz higiene com pouca ajuda', 'generalizacao', 4, 'Desfralde com reforço e independência gradual', 'Banheiro', 'Generalizar a habilidade de usa o banheiro e faz higiene com pouca ajuda para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Itens reais da rotina de higiene; apoio visual opcional.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Usa o banheiro e faz higiene com pouca ajuda”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Usa o banheiro e faz higiene com pouca ajuda” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Evitar punição, vergonha ou permanência forçada no vaso/penico.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F04A', 'F04AF004', 'Usa o banheiro e faz higiene com pouca ajuda', 'manutencao', 4, 'Desfralde com reforço e independência gradual', 'Banheiro', 'Manter a habilidade de usa o banheiro e faz higiene com pouca ajuda de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Itens reais da rotina de higiene; apoio visual opcional.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Usa o banheiro e faz higiene com pouca ajuda”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Usa o banheiro e faz higiene com pouca ajuda” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Evitar punição, vergonha ou permanência forçada no vaso/penico.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F04A', 'F04AM001', 'Pula de uma altura de 20 cm com equilíbrio', 'aquisicao', 1, 'Coordenação motora ampla com desafio', 'Motora global', 'Ensinar/desenvolver a habilidade de pula de uma altura de 20 cm com equilíbrio com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Pula de uma altura de 20 cm com equilíbrio”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas, respeitando segurança e fadiga.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Pula de uma altura de 20 cm com equilíbrio”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Pula de uma altura de 20 cm com equilíbrio” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F04A', 'F04AM001', 'Pula de uma altura de 20 cm com equilíbrio', 'generalizacao', 1, 'Coordenação motora ampla com desafio', 'Motora global', 'Generalizar a habilidade de pula de uma altura de 20 cm com equilíbrio para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Pula de uma altura de 20 cm com equilíbrio”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Pula de uma altura de 20 cm com equilíbrio” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F04A', 'F04AM001', 'Pula de uma altura de 20 cm com equilíbrio', 'manutencao', 1, 'Coordenação motora ampla com desafio', 'Motora global', 'Manter a habilidade de pula de uma altura de 20 cm com equilíbrio de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Pula de uma altura de 20 cm com equilíbrio”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Pula de uma altura de 20 cm com equilíbrio” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F04A', 'F04AM002', 'Recorta com tesoura', 'aquisicao', 2, 'Coordenação olho-mão com ferramenta', 'Motora fina', 'Ensinar/desenvolver a habilidade de recorta com tesoura com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Recorta com tesoura”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Tesoura infantil sem ponta; papel; linhas/formas simples.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas, respeitando segurança e fadiga.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Recorta com tesoura”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Recorta com tesoura” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F04A', 'F04AM002', 'Recorta com tesoura', 'generalizacao', 2, 'Coordenação olho-mão com ferramenta', 'Motora fina', 'Generalizar a habilidade de recorta com tesoura para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Tesoura infantil sem ponta; papel; linhas/formas simples.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Recorta com tesoura”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Recorta com tesoura” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F04A', 'F04AM002', 'Recorta com tesoura', 'manutencao', 2, 'Coordenação olho-mão com ferramenta', 'Motora fina', 'Manter a habilidade de recorta com tesoura de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Tesoura infantil sem ponta; papel; linhas/formas simples.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Recorta com tesoura”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Recorta com tesoura” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F04A', 'F04AM003', 'Segue pontilhado com lápis', 'aquisicao', 3, 'Visomotor com reforço positivo', 'Objeto', 'Ensinar/desenvolver a habilidade de segue pontilhado com lápis com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Segue pontilhado com lápis”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Papel; lápis/giz adequado à idade; modelos visuais.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas, respeitando segurança e fadiga.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Segue pontilhado com lápis”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Segue pontilhado com lápis” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F04A', 'F04AM003', 'Segue pontilhado com lápis', 'generalizacao', 3, 'Visomotor com reforço positivo', 'Objeto', 'Generalizar a habilidade de segue pontilhado com lápis para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Papel; lápis/giz adequado à idade; modelos visuais.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Segue pontilhado com lápis”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Segue pontilhado com lápis” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F04A', 'F04AM003', 'Segue pontilhado com lápis', 'manutencao', 3, 'Visomotor com reforço positivo', 'Objeto', 'Manter a habilidade de segue pontilhado com lápis de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Papel; lápis/giz adequado à idade; modelos visuais.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Segue pontilhado com lápis”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Segue pontilhado com lápis” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F04A', 'F04AM004', 'Chuta com direção para o alvo', 'aquisicao', 4, 'Treino de pontaria com bola', 'Bola', 'Ensinar/desenvolver a habilidade de chuta com direção para o alvo com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Chuta com direção para o alvo”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Bola adequada à idade; alvo/cones opcionais; espaço seguro.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas, respeitando segurança e fadiga.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Chuta com direção para o alvo”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Chuta com direção para o alvo” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F04A', 'F04AM004', 'Chuta com direção para o alvo', 'generalizacao', 4, 'Treino de pontaria com bola', 'Bola', 'Generalizar a habilidade de chuta com direção para o alvo para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Bola adequada à idade; alvo/cones opcionais; espaço seguro.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Chuta com direção para o alvo”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Chuta com direção para o alvo” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F04A', 'F04AM004', 'Chuta com direção para o alvo', 'manutencao', 4, 'Treino de pontaria com bola', 'Bola', 'Manter a habilidade de chuta com direção para o alvo de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Bola adequada à idade; alvo/cones opcionais; espaço seguro.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Chuta com direção para o alvo”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Chuta com direção para o alvo” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F04A', 'F04AS001', 'Aprende nova atividade por observação', 'aquisicao', 1, 'Aprendizagem vicária com reforço social', 'Imitação', 'Ensinar/desenvolver a habilidade de aprende nova atividade por observação com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Aprende nova atividade por observação”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Aprende nova atividade por observação”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Aprende nova atividade por observação” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F04A', 'F04AS001', 'Aprende nova atividade por observação', 'generalizacao', 1, 'Aprendizagem vicária com reforço social', 'Imitação', 'Generalizar a habilidade de aprende nova atividade por observação para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Aprende nova atividade por observação”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Aprende nova atividade por observação” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F04A', 'F04AS001', 'Aprende nova atividade por observação', 'manutencao', 1, 'Aprendizagem vicária com reforço social', 'Imitação', 'Manter a habilidade de aprende nova atividade por observação de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Aprende nova atividade por observação”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Aprende nova atividade por observação” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F04A', 'F04AS002', 'Participa de brincadeiras simbólicas complexas', 'aquisicao', 2, 'Jogos de representação avançada', 'Brincar', 'Ensinar/desenvolver a habilidade de participa de brincadeiras simbólicas complexas com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Participa de brincadeiras simbólicas complexas”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Participa de brincadeiras simbólicas complexas”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Participa de brincadeiras simbólicas complexas” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F04A', 'F04AS002', 'Participa de brincadeiras simbólicas complexas', 'generalizacao', 2, 'Jogos de representação avançada', 'Brincar', 'Generalizar a habilidade de participa de brincadeiras simbólicas complexas para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Participa de brincadeiras simbólicas complexas”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Participa de brincadeiras simbólicas complexas” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F04A', 'F04AS002', 'Participa de brincadeiras simbólicas complexas', 'manutencao', 2, 'Jogos de representação avançada', 'Brincar', 'Manter a habilidade de participa de brincadeiras simbólicas complexas de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Participa de brincadeiras simbólicas complexas”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Participa de brincadeiras simbólicas complexas” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F04A', 'F04AS003', 'Aguarda em fila por pelo menos 5 minutos', 'aquisicao', 3, 'Tolerância prolongada com reforço social', 'Tolerância', 'Ensinar/desenvolver a habilidade de aguarda em fila por pelo menos 5 minutos com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Aguarda em fila por pelo menos 5 minutos”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Aguarda em fila por pelo menos 5 minutos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Aguarda em fila por pelo menos 5 minutos” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F04A', 'F04AS003', 'Aguarda em fila por pelo menos 5 minutos', 'generalizacao', 3, 'Tolerância prolongada com reforço social', 'Tolerância', 'Generalizar a habilidade de aguarda em fila por pelo menos 5 minutos para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Aguarda em fila por pelo menos 5 minutos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Aguarda em fila por pelo menos 5 minutos” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F04A', 'F04AS003', 'Aguarda em fila por pelo menos 5 minutos', 'manutencao', 3, 'Tolerância prolongada com reforço social', 'Tolerância', 'Manter a habilidade de aguarda em fila por pelo menos 5 minutos de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Aguarda em fila por pelo menos 5 minutos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Aguarda em fila por pelo menos 5 minutos” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F04A', 'F04AS004', 'Reconhece e nomeia emoções próprias e dos outros', 'aquisicao', 4, 'Nomeação e empatia emocional', 'Resposta emocional', 'Ensinar/desenvolver a habilidade de reconhece e nomeia emoções próprias e dos outros com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Reconhece e nomeia emoções próprias e dos outros”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Reconhece e nomeia emoções próprias e dos outros”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Reconhece e nomeia emoções próprias e dos outros” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F04A', 'F04AS004', 'Reconhece e nomeia emoções próprias e dos outros', 'generalizacao', 4, 'Nomeação e empatia emocional', 'Resposta emocional', 'Generalizar a habilidade de reconhece e nomeia emoções próprias e dos outros para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Reconhece e nomeia emoções próprias e dos outros”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Reconhece e nomeia emoções próprias e dos outros” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F04A', 'F04AS004', 'Reconhece e nomeia emoções próprias e dos outros', 'manutencao', 4, 'Nomeação e empatia emocional', 'Resposta emocional', 'Manter a habilidade de reconhece e nomeia emoções próprias e dos outros de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Reconhece e nomeia emoções próprias e dos outros”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Reconhece e nomeia emoções próprias e dos outros” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F05A', 'F05AG001', 'Mantém atenção em atividades coletivas', 'aquisicao', 1, 'Participação com atenção dividida', 'Atenção conjunta', 'Ensinar/desenvolver a habilidade de mantém atenção em atividades coletivas com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Mantém atenção em atividades coletivas”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Mantém atenção em atividades coletivas”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Mantém atenção em atividades coletivas” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F05A', 'F05AG001', 'Mantém atenção em atividades coletivas', 'generalizacao', 1, 'Participação com atenção dividida', 'Atenção conjunta', 'Generalizar a habilidade de mantém atenção em atividades coletivas para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Mantém atenção em atividades coletivas”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Mantém atenção em atividades coletivas” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F05A', 'F05AG001', 'Mantém atenção em atividades coletivas', 'manutencao', 1, 'Participação com atenção dividida', 'Atenção conjunta', 'Manter a habilidade de mantém atenção em atividades coletivas de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Mantém atenção em atividades coletivas”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Mantém atenção em atividades coletivas” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F05A', 'F05AG002', 'Investiga como objetos funcionam', 'aquisicao', 2, 'Solução de problemas e descoberta com reforço', 'Exploração', 'Ensinar/desenvolver a habilidade de investiga como objetos funcionam com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Investiga como objetos funcionam”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Brinquedos/objetos adequados à habilidade; modelos simples.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Investiga como objetos funcionam”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Investiga como objetos funcionam” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F05A', 'F05AG002', 'Investiga como objetos funcionam', 'generalizacao', 2, 'Solução de problemas e descoberta com reforço', 'Exploração', 'Generalizar a habilidade de investiga como objetos funcionam para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Brinquedos/objetos adequados à habilidade; modelos simples.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Investiga como objetos funcionam”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Investiga como objetos funcionam” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F05A', 'F05AG002', 'Investiga como objetos funcionam', 'manutencao', 2, 'Solução de problemas e descoberta com reforço', 'Exploração', 'Manter a habilidade de investiga como objetos funcionam de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Brinquedos/objetos adequados à habilidade; modelos simples.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Investiga como objetos funcionam”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Investiga como objetos funcionam” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F05A', 'F05AG003', 'Agrupa objetos por categoria lógica', 'aquisicao', 3, 'Classificação funcional', 'Combinação', 'Ensinar/desenvolver a habilidade de agrupa objetos por categoria lógica com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Agrupa objetos por categoria lógica”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Brinquedos/objetos adequados à habilidade; modelos simples.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Agrupa objetos por categoria lógica”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Agrupa objetos por categoria lógica” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F05A', 'F05AG003', 'Agrupa objetos por categoria lógica', 'generalizacao', 3, 'Classificação funcional', 'Combinação', 'Generalizar a habilidade de agrupa objetos por categoria lógica para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Brinquedos/objetos adequados à habilidade; modelos simples.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Agrupa objetos por categoria lógica”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Agrupa objetos por categoria lógica” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F05A', 'F05AG003', 'Agrupa objetos por categoria lógica', 'manutencao', 3, 'Classificação funcional', 'Combinação', 'Manter a habilidade de agrupa objetos por categoria lógica de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Brinquedos/objetos adequados à habilidade; modelos simples.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Agrupa objetos por categoria lógica”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Agrupa objetos por categoria lógica” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F05A', 'F05AG004', 'Copia palavras e frases curtas', 'aquisicao', 4, 'Escrita funcional com treino de letra', 'Uso do lápis', 'Ensinar/desenvolver a habilidade de copia palavras e frases curtas com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Copia palavras e frases curtas”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Copia palavras e frases curtas”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Copia palavras e frases curtas” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F05A', 'F05AG004', 'Copia palavras e frases curtas', 'generalizacao', 4, 'Escrita funcional com treino de letra', 'Uso do lápis', 'Generalizar a habilidade de copia palavras e frases curtas para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Copia palavras e frases curtas”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Copia palavras e frases curtas” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F05A', 'F05AG004', 'Copia palavras e frases curtas', 'manutencao', 4, 'Escrita funcional com treino de letra', 'Uso do lápis', 'Manter a habilidade de copia palavras e frases curtas de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Copia palavras e frases curtas”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Copia palavras e frases curtas” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F05A', 'F05AC001', 'Mantém contato visual durante conversa', 'aquisicao', 1, 'Contato visual com manutenção em conversa', 'Atenção conjunta', 'Ensinar/desenvolver a habilidade de mantém contato visual durante conversa com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Mantém contato visual durante conversa”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Mantém contato visual durante conversa”.', '1. Física: não utilizar para forçar contato visual.
2. Gestual: orientar suavemente para o interlocutor/estímulo.
3. Visual: posicionar o estímulo relevante no campo visual.
4. Verbal: lembrete curto, quando necessário.
5. I = Independente.', 'A criança realiza “Mantém contato visual durante conversa” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Não segurar o rosto nem exigir olhar fixo contínuo; valorizar orientação funcional ao interlocutor.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F05A', 'F05AC001', 'Mantém contato visual durante conversa', 'generalizacao', 1, 'Contato visual com manutenção em conversa', 'Atenção conjunta', 'Generalizar a habilidade de mantém contato visual durante conversa para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Mantém contato visual durante conversa”.', '1. Física: não utilizar para forçar contato visual.
2. Gestual: orientar suavemente para o interlocutor/estímulo.
3. Visual: posicionar o estímulo relevante no campo visual.
4. Verbal: lembrete curto, quando necessário.
5. I = Independente.', 'A criança realiza “Mantém contato visual durante conversa” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Não segurar o rosto nem exigir olhar fixo contínuo; valorizar orientação funcional ao interlocutor.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F05A', 'F05AC001', 'Mantém contato visual durante conversa', 'manutencao', 1, 'Contato visual com manutenção em conversa', 'Atenção conjunta', 'Manter a habilidade de mantém contato visual durante conversa de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Mantém contato visual durante conversa”.', '1. Física: não utilizar para forçar contato visual.
2. Gestual: orientar suavemente para o interlocutor/estímulo.
3. Visual: posicionar o estímulo relevante no campo visual.
4. Verbal: lembrete curto, quando necessário.
5. I = Independente.', 'A criança mantém “Mantém contato visual durante conversa” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Não segurar o rosto nem exigir olhar fixo contínuo; valorizar orientação funcional ao interlocutor.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F05A', 'F05AC002', 'Usa figuras, escrita ou CAA para se expressar', 'aquisicao', 2, 'PECS frases + escrita funcional', 'Comunicação alternativa', 'Ensinar/desenvolver a habilidade de usa figuras, escrita ou caa para se expressar com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Usa figuras, escrita ou CAA para se expressar”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Sistema de CAA já utilizado; figuras/símbolos; itens e atividades motivadoras.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Usa figuras, escrita ou CAA para se expressar”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Usa figuras, escrita ou CAA para se expressar” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F05A', 'F05AC002', 'Usa figuras, escrita ou CAA para se expressar', 'generalizacao', 2, 'PECS frases + escrita funcional', 'Comunicação alternativa', 'Generalizar a habilidade de usa figuras, escrita ou caa para se expressar para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Sistema de CAA já utilizado; figuras/símbolos; itens e atividades motivadoras.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Usa figuras, escrita ou CAA para se expressar”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Usa figuras, escrita ou CAA para se expressar” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F05A', 'F05AC002', 'Usa figuras, escrita ou CAA para se expressar', 'manutencao', 2, 'PECS frases + escrita funcional', 'Comunicação alternativa', 'Manter a habilidade de usa figuras, escrita ou caa para se expressar de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Sistema de CAA já utilizado; figuras/símbolos; itens e atividades motivadoras.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Usa figuras, escrita ou CAA para se expressar”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Usa figuras, escrita ou CAA para se expressar” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F05A', 'F05AC003', 'Participa de conversas simples', 'aquisicao', 3, 'Ensino de turnos verbais', 'Expressiva', 'Ensinar/desenvolver a habilidade de participa de conversas simples com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Participa de conversas simples”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Participa de conversas simples”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Participa de conversas simples” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F05A', 'F05AC003', 'Participa de conversas simples', 'generalizacao', 3, 'Ensino de turnos verbais', 'Expressiva', 'Generalizar a habilidade de participa de conversas simples para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Participa de conversas simples”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Participa de conversas simples” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F05A', 'F05AC003', 'Participa de conversas simples', 'manutencao', 3, 'Ensino de turnos verbais', 'Expressiva', 'Manter a habilidade de participa de conversas simples de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Participa de conversas simples”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Participa de conversas simples” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F05A', 'F05AC004', 'Compreende perguntas do tipo “por quê?”', 'aquisicao', 4, 'Respostas abertas com reforço', 'Receptiva', 'Ensinar/desenvolver a habilidade de compreende perguntas do tipo “por quê?” com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Compreende perguntas do tipo “por quê?””.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Compreende perguntas do tipo “por quê?””.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Compreende perguntas do tipo “por quê?”” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F05A', 'F05AC004', 'Compreende perguntas do tipo “por quê?”', 'generalizacao', 4, 'Respostas abertas com reforço', 'Receptiva', 'Generalizar a habilidade de compreende perguntas do tipo “por quê?” para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Compreende perguntas do tipo “por quê?””.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Compreende perguntas do tipo “por quê?”” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F05A', 'F05AC004', 'Compreende perguntas do tipo “por quê?”', 'manutencao', 4, 'Respostas abertas com reforço', 'Receptiva', 'Manter a habilidade de compreende perguntas do tipo “por quê?” de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Compreende perguntas do tipo “por quê?””.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Compreende perguntas do tipo “por quê?”” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F05A', 'F05AC005', 'Entende instruções escolares comuns', 'aquisicao', 5, 'Rotinas acadêmicas com instruções visuais', 'Receptiva', 'Ensinar/desenvolver a habilidade de entende instruções escolares comuns com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Entende instruções escolares comuns”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Entende instruções escolares comuns”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Entende instruções escolares comuns” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F05A', 'F05AC005', 'Entende instruções escolares comuns', 'generalizacao', 5, 'Rotinas acadêmicas com instruções visuais', 'Receptiva', 'Generalizar a habilidade de entende instruções escolares comuns para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Entende instruções escolares comuns”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Entende instruções escolares comuns” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F05A', 'F05AC005', 'Entende instruções escolares comuns', 'manutencao', 5, 'Rotinas acadêmicas com instruções visuais', 'Receptiva', 'Manter a habilidade de entende instruções escolares comuns de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Entende instruções escolares comuns”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Entende instruções escolares comuns” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F05A', 'F05AF001', 'Serve-se com talheres e autonomia', 'aquisicao', 1, 'Rotina de alimentação funcional', 'Alimentação', 'Ensinar/desenvolver a habilidade de serve-se com talheres e autonomia com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Serve-se com talheres e autonomia”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Alimentos habituais e/ou alvo; utensílios adequados; mesa/cadeira.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Treinar na rotina natural; 1–3 oportunidades/dia, sem transformar toda a rotina em sessão.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Serve-se com talheres e autonomia”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Serve-se com talheres e autonomia” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F05A', 'F05AF001', 'Serve-se com talheres e autonomia', 'generalizacao', 1, 'Rotina de alimentação funcional', 'Alimentação', 'Generalizar a habilidade de serve-se com talheres e autonomia para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Alimentos habituais e/ou alvo; utensílios adequados; mesa/cadeira.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Serve-se com talheres e autonomia”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Serve-se com talheres e autonomia” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F05A', 'F05AF001', 'Serve-se com talheres e autonomia', 'manutencao', 1, 'Rotina de alimentação funcional', 'Alimentação', 'Manter a habilidade de serve-se com talheres e autonomia de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Alimentos habituais e/ou alvo; utensílios adequados; mesa/cadeira.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Serve-se com talheres e autonomia”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Serve-se com talheres e autonomia” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F05A', 'F05AF002', 'Escova os dentes com supervisão leve', 'aquisicao', 2, 'Higiene com fading e reforço', 'Higiene', 'Ensinar/desenvolver a habilidade de escova os dentes com supervisão leve com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Escova os dentes com supervisão leve”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Itens reais da rotina de higiene; apoio visual opcional.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Treinar na rotina natural; 1–3 oportunidades/dia, sem transformar toda a rotina em sessão.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Escova os dentes com supervisão leve”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Escova os dentes com supervisão leve” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F05A', 'F05AF002', 'Escova os dentes com supervisão leve', 'generalizacao', 2, 'Higiene com fading e reforço', 'Higiene', 'Generalizar a habilidade de escova os dentes com supervisão leve para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Itens reais da rotina de higiene; apoio visual opcional.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Escova os dentes com supervisão leve”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Escova os dentes com supervisão leve” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F05A', 'F05AF002', 'Escova os dentes com supervisão leve', 'manutencao', 2, 'Higiene com fading e reforço', 'Higiene', 'Manter a habilidade de escova os dentes com supervisão leve de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Itens reais da rotina de higiene; apoio visual opcional.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Escova os dentes com supervisão leve”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Escova os dentes com supervisão leve” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F05A', 'F05AF003', 'Veste-se e guarda a roupa', 'aquisicao', 3, 'Sequência funcional de vestir e guardar roupas', 'Vestuário', 'Ensinar/desenvolver a habilidade de veste-se e guarda a roupa com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Veste-se e guarda a roupa”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Roupas da criança; espelho opcional; sequência visual opcional.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Treinar na rotina natural; 1–3 oportunidades/dia, sem transformar toda a rotina em sessão.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Veste-se e guarda a roupa”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Veste-se e guarda a roupa” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F05A', 'F05AF003', 'Veste-se e guarda a roupa', 'generalizacao', 3, 'Sequência funcional de vestir e guardar roupas', 'Vestuário', 'Generalizar a habilidade de veste-se e guarda a roupa para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Roupas da criança; espelho opcional; sequência visual opcional.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Veste-se e guarda a roupa”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Veste-se e guarda a roupa” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F05A', 'F05AF003', 'Veste-se e guarda a roupa', 'manutencao', 3, 'Sequência funcional de vestir e guardar roupas', 'Vestuário', 'Manter a habilidade de veste-se e guarda a roupa de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Roupas da criança; espelho opcional; sequência visual opcional.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Veste-se e guarda a roupa”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Veste-se e guarda a roupa” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F05A', 'F05AF004', 'Usa o banheiro sem ajuda', 'aquisicao', 4, 'Rotina completa de banheiro com reforço natural', 'Banheiro', 'Ensinar/desenvolver a habilidade de usa o banheiro sem ajuda com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Usa o banheiro sem ajuda”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Itens reais da rotina de banheiro; apoio visual opcional; roupas fáceis de manejar.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Treinar na rotina natural; 1–3 oportunidades/dia, sem transformar toda a rotina em sessão.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Usa o banheiro sem ajuda”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Usa o banheiro sem ajuda” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Evitar punição, vergonha ou permanência forçada no vaso/penico.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F05A', 'F05AF004', 'Usa o banheiro sem ajuda', 'generalizacao', 4, 'Rotina completa de banheiro com reforço natural', 'Banheiro', 'Generalizar a habilidade de usa o banheiro sem ajuda para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Itens reais da rotina de banheiro; apoio visual opcional; roupas fáceis de manejar.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Usa o banheiro sem ajuda”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Usa o banheiro sem ajuda” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Evitar punição, vergonha ou permanência forçada no vaso/penico.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F05A', 'F05AF004', 'Usa o banheiro sem ajuda', 'manutencao', 4, 'Rotina completa de banheiro com reforço natural', 'Banheiro', 'Manter a habilidade de usa o banheiro sem ajuda de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Itens reais da rotina de banheiro; apoio visual opcional; roupas fáceis de manejar.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Usa o banheiro sem ajuda”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Usa o banheiro sem ajuda” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Evitar punição, vergonha ou permanência forçada no vaso/penico.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F05A', 'F05AM001', 'Corre, salta e se equilibra com segurança', 'aquisicao', 1, 'Coordenação motora ampla com reforço social', 'Global', 'Ensinar/desenvolver a habilidade de corre, salta e se equilibra com segurança com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Corre, salta e se equilibra com segurança”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas, respeitando segurança e fadiga.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Corre, salta e se equilibra com segurança”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Corre, salta e se equilibra com segurança” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F05A', 'F05AM001', 'Corre, salta e se equilibra com segurança', 'generalizacao', 1, 'Coordenação motora ampla com reforço social', 'Global', 'Generalizar a habilidade de corre, salta e se equilibra com segurança para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Corre, salta e se equilibra com segurança”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Corre, salta e se equilibra com segurança” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F05A', 'F05AM001', 'Corre, salta e se equilibra com segurança', 'manutencao', 1, 'Coordenação motora ampla com reforço social', 'Global', 'Manter a habilidade de corre, salta e se equilibra com segurança de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Corre, salta e se equilibra com segurança”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Corre, salta e se equilibra com segurança” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F05A', 'F05AM002', 'Recorta formas simples com tesoura', 'aquisicao', 2, 'Coordenação fina com modelos', 'Fino', 'Ensinar/desenvolver a habilidade de recorta formas simples com tesoura com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Recorta formas simples com tesoura”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Tesoura infantil sem ponta; papel; linhas/formas simples.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas, respeitando segurança e fadiga.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Recorta formas simples com tesoura”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Recorta formas simples com tesoura” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F05A', 'F05AM002', 'Recorta formas simples com tesoura', 'generalizacao', 2, 'Coordenação fina com modelos', 'Fino', 'Generalizar a habilidade de recorta formas simples com tesoura para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Tesoura infantil sem ponta; papel; linhas/formas simples.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Recorta formas simples com tesoura”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Recorta formas simples com tesoura” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F05A', 'F05AM002', 'Recorta formas simples com tesoura', 'manutencao', 2, 'Coordenação fina com modelos', 'Fino', 'Manter a habilidade de recorta formas simples com tesoura de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Tesoura infantil sem ponta; papel; linhas/formas simples.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Recorta formas simples com tesoura”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Recorta formas simples com tesoura” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F05A', 'F05AM003', 'Copia padrões com blocos, palitos ou LEGO', 'aquisicao', 3, 'Construção com blocos guiada', 'Objeto', 'Ensinar/desenvolver a habilidade de copia padrões com blocos, palitos ou lego com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Copia padrões com blocos, palitos ou LEGO”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Brinquedos/objetos adequados à habilidade; modelos simples.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas, respeitando segurança e fadiga.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Copia padrões com blocos, palitos ou LEGO”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Copia padrões com blocos, palitos ou LEGO” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F05A', 'F05AM003', 'Copia padrões com blocos, palitos ou LEGO', 'generalizacao', 3, 'Construção com blocos guiada', 'Objeto', 'Generalizar a habilidade de copia padrões com blocos, palitos ou lego para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Brinquedos/objetos adequados à habilidade; modelos simples.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Copia padrões com blocos, palitos ou LEGO”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Copia padrões com blocos, palitos ou LEGO” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F05A', 'F05AM003', 'Copia padrões com blocos, palitos ou LEGO', 'manutencao', 3, 'Construção com blocos guiada', 'Objeto', 'Manter a habilidade de copia padrões com blocos, palitos ou lego de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Brinquedos/objetos adequados à habilidade; modelos simples.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Copia padrões com blocos, palitos ou LEGO”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Copia padrões com blocos, palitos ou LEGO” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F05A', 'F05AM004', 'Participa de jogos com bola', 'aquisicao', 4, 'Coordenação em jogos coletivos com regras', 'Bola', 'Ensinar/desenvolver a habilidade de participa de jogos com bola com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Participa de jogos com bola”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Bola adequada à idade; alvo/cones opcionais; espaço seguro.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas, respeitando segurança e fadiga.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Participa de jogos com bola”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Participa de jogos com bola” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F05A', 'F05AM004', 'Participa de jogos com bola', 'generalizacao', 4, 'Coordenação em jogos coletivos com regras', 'Bola', 'Generalizar a habilidade de participa de jogos com bola para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Bola adequada à idade; alvo/cones opcionais; espaço seguro.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Participa de jogos com bola”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Participa de jogos com bola” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F05A', 'F05AM004', 'Participa de jogos com bola', 'manutencao', 4, 'Coordenação em jogos coletivos com regras', 'Bola', 'Manter a habilidade de participa de jogos com bola de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Bola adequada à idade; alvo/cones opcionais; espaço seguro.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Participa de jogos com bola”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Participa de jogos com bola” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F05A', 'F05AS001', 'Imita comportamentos sociais observados', 'aquisicao', 1, 'Modelos sociais com reforço natural', 'Imitação', 'Ensinar/desenvolver a habilidade de imita comportamentos sociais observados com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Imita comportamentos sociais observados”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Imita comportamentos sociais observados”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Imita comportamentos sociais observados” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F05A', 'F05AS001', 'Imita comportamentos sociais observados', 'generalizacao', 1, 'Modelos sociais com reforço natural', 'Imitação', 'Generalizar a habilidade de imita comportamentos sociais observados para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Imita comportamentos sociais observados”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Imita comportamentos sociais observados” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F05A', 'F05AS001', 'Imita comportamentos sociais observados', 'manutencao', 1, 'Modelos sociais com reforço natural', 'Imitação', 'Manter a habilidade de imita comportamentos sociais observados de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Imita comportamentos sociais observados”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Imita comportamentos sociais observados” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F05A', 'F05AS002', 'Participa de jogos com regras simples', 'aquisicao', 2, 'Ensino de regras sociais e turnos', 'Brincar', 'Ensinar/desenvolver a habilidade de participa de jogos com regras simples com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Participa de jogos com regras simples”.
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
    ('social', 'F05A', 'F05AS002', 'Participa de jogos com regras simples', 'generalizacao', 2, 'Ensino de regras sociais e turnos', 'Brincar', 'Generalizar a habilidade de participa de jogos com regras simples para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
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
    ('social', 'F05A', 'F05AS002', 'Participa de jogos com regras simples', 'manutencao', 2, 'Ensino de regras sociais e turnos', 'Brincar', 'Manter a habilidade de participa de jogos com regras simples de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
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
    ('social', 'F05A', 'F05AS003', 'Lida com frustração em jogos', 'aquisicao', 3, 'Tolerância com reforço diferencial', 'Tolerância', 'Ensinar/desenvolver a habilidade de lida com frustração em jogos com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Lida com frustração em jogos”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Papel; lápis/giz adequado à idade; modelos visuais.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Lida com frustração em jogos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Lida com frustração em jogos” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F05A', 'F05AS003', 'Lida com frustração em jogos', 'generalizacao', 3, 'Tolerância com reforço diferencial', 'Tolerância', 'Generalizar a habilidade de lida com frustração em jogos para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Papel; lápis/giz adequado à idade; modelos visuais.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Lida com frustração em jogos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Lida com frustração em jogos” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F05A', 'F05AS003', 'Lida com frustração em jogos', 'manutencao', 3, 'Tolerância com reforço diferencial', 'Tolerância', 'Manter a habilidade de lida com frustração em jogos de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Papel; lápis/giz adequado à idade; modelos visuais.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Lida com frustração em jogos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Lida com frustração em jogos” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F05A', 'F05AS004', 'Reconhece e regula emoções básicas', 'aquisicao', 4, 'Treino de autorregulação emocional', 'Resposta emocional', 'Ensinar/desenvolver a habilidade de reconhece e regula emoções básicas com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Reconhece e regula emoções básicas”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Reconhece e regula emoções básicas”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Reconhece e regula emoções básicas” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F05A', 'F05AS004', 'Reconhece e regula emoções básicas', 'generalizacao', 4, 'Treino de autorregulação emocional', 'Resposta emocional', 'Generalizar a habilidade de reconhece e regula emoções básicas para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Reconhece e regula emoções básicas”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Reconhece e regula emoções básicas” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F05A', 'F05AS004', 'Reconhece e regula emoções básicas', 'manutencao', 4, 'Treino de autorregulação emocional', 'Resposta emocional', 'Manter a habilidade de reconhece e regula emoções básicas de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Reconhece e regula emoções básicas”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Reconhece e regula emoções básicas” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F06A', 'F06AG001', 'Mantém atenção em atividades em grupo', 'aquisicao', 1, 'Participação prolongada com foco compartilhado', 'Atenção conjunta', 'Ensinar/desenvolver a habilidade de mantém atenção em atividades em grupo com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Mantém atenção em atividades em grupo”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Mantém atenção em atividades em grupo”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Mantém atenção em atividades em grupo” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F06A', 'F06AG001', 'Mantém atenção em atividades em grupo', 'generalizacao', 1, 'Participação prolongada com foco compartilhado', 'Atenção conjunta', 'Generalizar a habilidade de mantém atenção em atividades em grupo para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Mantém atenção em atividades em grupo”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Mantém atenção em atividades em grupo” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F06A', 'F06AG001', 'Mantém atenção em atividades em grupo', 'manutencao', 1, 'Participação prolongada com foco compartilhado', 'Atenção conjunta', 'Manter a habilidade de mantém atenção em atividades em grupo de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Mantém atenção em atividades em grupo”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Mantém atenção em atividades em grupo” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F06A', 'F06AG002', 'Faz perguntas e investiga temas do interesse', 'aquisicao', 2, 'Estímulo à curiosidade e pergunta funcional', 'Exploração', 'Ensinar/desenvolver a habilidade de faz perguntas e investiga temas do interesse com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Faz perguntas e investiga temas do interesse”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Faz perguntas e investiga temas do interesse”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Faz perguntas e investiga temas do interesse” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F06A', 'F06AG002', 'Faz perguntas e investiga temas do interesse', 'generalizacao', 2, 'Estímulo à curiosidade e pergunta funcional', 'Exploração', 'Generalizar a habilidade de faz perguntas e investiga temas do interesse para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Faz perguntas e investiga temas do interesse”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Faz perguntas e investiga temas do interesse” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F06A', 'F06AG002', 'Faz perguntas e investiga temas do interesse', 'manutencao', 2, 'Estímulo à curiosidade e pergunta funcional', 'Exploração', 'Manter a habilidade de faz perguntas e investiga temas do interesse de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Faz perguntas e investiga temas do interesse”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Faz perguntas e investiga temas do interesse” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F06A', 'F06AG003', 'Agrupa conceitos por lógica', 'aquisicao', 3, 'Classificação semântica e funcional', 'Combinação', 'Ensinar/desenvolver a habilidade de agrupa conceitos por lógica com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Agrupa conceitos por lógica”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Agrupa conceitos por lógica”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Agrupa conceitos por lógica” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F06A', 'F06AG003', 'Agrupa conceitos por lógica', 'generalizacao', 3, 'Classificação semântica e funcional', 'Combinação', 'Generalizar a habilidade de agrupa conceitos por lógica para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Agrupa conceitos por lógica”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Agrupa conceitos por lógica” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F06A', 'F06AG003', 'Agrupa conceitos por lógica', 'manutencao', 3, 'Classificação semântica e funcional', 'Combinação', 'Manter a habilidade de agrupa conceitos por lógica de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Agrupa conceitos por lógica”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Agrupa conceitos por lógica” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F06A', 'F06AG004', 'Escreve frases completas com letra legível', 'aquisicao', 4, 'Escrita funcional para uso escolar e pessoal', 'Uso do lápis', 'Ensinar/desenvolver a habilidade de escreve frases completas com letra legível com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Escreve frases completas com letra legível”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Papel; lápis/giz adequado à idade; modelos visuais.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Escreve frases completas com letra legível”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Escreve frases completas com letra legível” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F06A', 'F06AG004', 'Escreve frases completas com letra legível', 'generalizacao', 4, 'Escrita funcional para uso escolar e pessoal', 'Uso do lápis', 'Generalizar a habilidade de escreve frases completas com letra legível para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Papel; lápis/giz adequado à idade; modelos visuais.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Escreve frases completas com letra legível”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Escreve frases completas com letra legível” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('cognitiva', 'F06A', 'F06AG004', 'Escreve frases completas com letra legível', 'manutencao', 4, 'Escrita funcional para uso escolar e pessoal', 'Uso do lápis', 'Manter a habilidade de escreve frases completas com letra legível de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Papel; lápis/giz adequado à idade; modelos visuais.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Escreve frases completas com letra legível”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Escreve frases completas com letra legível” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F06A', 'F06AC001', 'Mantém contato visual durante diálogo longo', 'aquisicao', 1, 'Contato visual com manutenção em conversa', 'Atenção conjunta', 'Ensinar/desenvolver a habilidade de mantém contato visual durante diálogo longo com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Mantém contato visual durante diálogo longo”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Mantém contato visual durante diálogo longo”.', '1. Física: não utilizar para forçar contato visual.
2. Gestual: orientar suavemente para o interlocutor/estímulo.
3. Visual: posicionar o estímulo relevante no campo visual.
4. Verbal: lembrete curto, quando necessário.
5. I = Independente.', 'A criança realiza “Mantém contato visual durante diálogo longo” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Não segurar o rosto nem exigir olhar fixo contínuo; valorizar orientação funcional ao interlocutor.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F06A', 'F06AC001', 'Mantém contato visual durante diálogo longo', 'generalizacao', 1, 'Contato visual com manutenção em conversa', 'Atenção conjunta', 'Generalizar a habilidade de mantém contato visual durante diálogo longo para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Mantém contato visual durante diálogo longo”.', '1. Física: não utilizar para forçar contato visual.
2. Gestual: orientar suavemente para o interlocutor/estímulo.
3. Visual: posicionar o estímulo relevante no campo visual.
4. Verbal: lembrete curto, quando necessário.
5. I = Independente.', 'A criança realiza “Mantém contato visual durante diálogo longo” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Não segurar o rosto nem exigir olhar fixo contínuo; valorizar orientação funcional ao interlocutor.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F06A', 'F06AC001', 'Mantém contato visual durante diálogo longo', 'manutencao', 1, 'Contato visual com manutenção em conversa', 'Atenção conjunta', 'Manter a habilidade de mantém contato visual durante diálogo longo de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Mantém contato visual durante diálogo longo”.', '1. Física: não utilizar para forçar contato visual.
2. Gestual: orientar suavemente para o interlocutor/estímulo.
3. Visual: posicionar o estímulo relevante no campo visual.
4. Verbal: lembrete curto, quando necessário.
5. I = Independente.', 'A criança mantém “Mantém contato visual durante diálogo longo” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Não segurar o rosto nem exigir olhar fixo contínuo; valorizar orientação funcional ao interlocutor.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F06A', 'F06AC002', 'Usa escrita, imagens ou CAA para se comunicar', 'aquisicao', 2, 'PECS avançado / escrita funcional / apps de CAA', 'Comunicação alternativa', 'Ensinar/desenvolver a habilidade de usa escrita, imagens ou caa para se comunicar com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Usa escrita, imagens ou CAA para se comunicar”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Sistema de CAA já utilizado; figuras/símbolos; itens e atividades motivadoras.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Usa escrita, imagens ou CAA para se comunicar”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Usa escrita, imagens ou CAA para se comunicar” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F06A', 'F06AC002', 'Usa escrita, imagens ou CAA para se comunicar', 'generalizacao', 2, 'PECS avançado / escrita funcional / apps de CAA', 'Comunicação alternativa', 'Generalizar a habilidade de usa escrita, imagens ou caa para se comunicar para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Sistema de CAA já utilizado; figuras/símbolos; itens e atividades motivadoras.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Usa escrita, imagens ou CAA para se comunicar”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Usa escrita, imagens ou CAA para se comunicar” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F06A', 'F06AC002', 'Usa escrita, imagens ou CAA para se comunicar', 'manutencao', 2, 'PECS avançado / escrita funcional / apps de CAA', 'Comunicação alternativa', 'Manter a habilidade de usa escrita, imagens ou caa para se comunicar de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Sistema de CAA já utilizado; figuras/símbolos; itens e atividades motivadoras.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Usa escrita, imagens ou CAA para se comunicar”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Usa escrita, imagens ou CAA para se comunicar” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F06A', 'F06AC003', 'Participa de conversas com múltiplas trocas', 'aquisicao', 3, 'Ensino de intraverbais e turnos conversacionais', 'Expressiva', 'Ensinar/desenvolver a habilidade de participa de conversas com múltiplas trocas com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Participa de conversas com múltiplas trocas”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Participa de conversas com múltiplas trocas”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Participa de conversas com múltiplas trocas” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F06A', 'F06AC003', 'Participa de conversas com múltiplas trocas', 'generalizacao', 3, 'Ensino de intraverbais e turnos conversacionais', 'Expressiva', 'Generalizar a habilidade de participa de conversas com múltiplas trocas para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Participa de conversas com múltiplas trocas”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Participa de conversas com múltiplas trocas” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F06A', 'F06AC003', 'Participa de conversas com múltiplas trocas', 'manutencao', 3, 'Ensino de intraverbais e turnos conversacionais', 'Expressiva', 'Manter a habilidade de participa de conversas com múltiplas trocas de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Participa de conversas com múltiplas trocas”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Participa de conversas com múltiplas trocas” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F06A', 'F06AC004', 'Segue comandos em sequência', 'aquisicao', 4, 'Instruções de 3 passos com apoio visual', 'Receptiva', 'Ensinar/desenvolver a habilidade de segue comandos em sequência com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Segue comandos em sequência”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Segue comandos em sequência”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Segue comandos em sequência” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F06A', 'F06AC004', 'Segue comandos em sequência', 'generalizacao', 4, 'Instruções de 3 passos com apoio visual', 'Receptiva', 'Generalizar a habilidade de segue comandos em sequência para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Segue comandos em sequência”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Segue comandos em sequência” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F06A', 'F06AC004', 'Segue comandos em sequência', 'manutencao', 4, 'Instruções de 3 passos com apoio visual', 'Receptiva', 'Manter a habilidade de segue comandos em sequência de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Segue comandos em sequência”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Segue comandos em sequência” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F06A', 'F06AC005', 'Entende explicações como “isso é perigoso porque...”', 'aquisicao', 5, 'Ensino de relações de causa e consequência', 'Receptiva', 'Ensinar/desenvolver a habilidade de entende explicações como “isso é perigoso porque...” com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Entende explicações como “isso é perigoso porque...””.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Entende explicações como “isso é perigoso porque...””.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Entende explicações como “isso é perigoso porque...”” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F06A', 'F06AC005', 'Entende explicações como “isso é perigoso porque...”', 'generalizacao', 5, 'Ensino de relações de causa e consequência', 'Receptiva', 'Generalizar a habilidade de entende explicações como “isso é perigoso porque...” para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Entende explicações como “isso é perigoso porque...””.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Entende explicações como “isso é perigoso porque...”” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('comunicacao', 'F06A', 'F06AC005', 'Entende explicações como “isso é perigoso porque...”', 'manutencao', 5, 'Ensino de relações de causa e consequência', 'Receptiva', 'Manter a habilidade de entende explicações como “isso é perigoso porque...” de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Entende explicações como “isso é perigoso porque...””.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Entende explicações como “isso é perigoso porque...”” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F06A', 'F06AF001', 'Prepara um lanche simples', 'aquisicao', 1, 'Rotina funcional com autonomia', 'Alimentação', 'Ensinar/desenvolver a habilidade de prepara um lanche simples com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Prepara um lanche simples”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Alimentos habituais e/ou alvo; utensílios adequados; mesa/cadeira.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Treinar na rotina natural; 1–3 oportunidades/dia, sem transformar toda a rotina em sessão.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Prepara um lanche simples”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Prepara um lanche simples” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F06A', 'F06AF001', 'Prepara um lanche simples', 'generalizacao', 1, 'Rotina funcional com autonomia', 'Alimentação', 'Generalizar a habilidade de prepara um lanche simples para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Alimentos habituais e/ou alvo; utensílios adequados; mesa/cadeira.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Prepara um lanche simples”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Prepara um lanche simples” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F06A', 'F06AF001', 'Prepara um lanche simples', 'manutencao', 1, 'Rotina funcional com autonomia', 'Alimentação', 'Manter a habilidade de prepara um lanche simples de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Alimentos habituais e/ou alvo; utensílios adequados; mesa/cadeira.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Prepara um lanche simples”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Prepara um lanche simples” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F06A', 'F06AF002', 'Cuida da higiene com independência', 'aquisicao', 2, 'Treino de sequência de higiene completa', 'Higiene', 'Ensinar/desenvolver a habilidade de cuida da higiene com independência com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Cuida da higiene com independência”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Itens reais da rotina de higiene; apoio visual opcional.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Treinar na rotina natural; 1–3 oportunidades/dia, sem transformar toda a rotina em sessão.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Cuida da higiene com independência”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Cuida da higiene com independência” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F06A', 'F06AF002', 'Cuida da higiene com independência', 'generalizacao', 2, 'Treino de sequência de higiene completa', 'Higiene', 'Generalizar a habilidade de cuida da higiene com independência para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Itens reais da rotina de higiene; apoio visual opcional.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Cuida da higiene com independência”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Cuida da higiene com independência” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F06A', 'F06AF002', 'Cuida da higiene com independência', 'manutencao', 2, 'Treino de sequência de higiene completa', 'Higiene', 'Manter a habilidade de cuida da higiene com independência de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Itens reais da rotina de higiene; apoio visual opcional.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Cuida da higiene com independência”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Cuida da higiene com independência” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F06A', 'F06AF003', 'Escolhe roupa adequada ao clima/situação', 'aquisicao', 3, 'Tomada de decisão funcional sobre vestuário', 'Vestuário', 'Ensinar/desenvolver a habilidade de escolhe roupa adequada ao clima/situação com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Escolhe roupa adequada ao clima/situação”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Roupas da criança; espelho opcional; sequência visual opcional.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Treinar na rotina natural; 1–3 oportunidades/dia, sem transformar toda a rotina em sessão.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Escolhe roupa adequada ao clima/situação”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Escolhe roupa adequada ao clima/situação” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F06A', 'F06AF003', 'Escolhe roupa adequada ao clima/situação', 'generalizacao', 3, 'Tomada de decisão funcional sobre vestuário', 'Vestuário', 'Generalizar a habilidade de escolhe roupa adequada ao clima/situação para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Roupas da criança; espelho opcional; sequência visual opcional.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Escolhe roupa adequada ao clima/situação”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Escolhe roupa adequada ao clima/situação” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F06A', 'F06AF003', 'Escolhe roupa adequada ao clima/situação', 'manutencao', 3, 'Tomada de decisão funcional sobre vestuário', 'Vestuário', 'Manter a habilidade de escolhe roupa adequada ao clima/situação de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Roupas da criança; espelho opcional; sequência visual opcional.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Escolhe roupa adequada ao clima/situação”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Escolhe roupa adequada ao clima/situação” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F06A', 'F06AF004', 'Usa o banheiro fora de casa com autonomia', 'aquisicao', 4, 'Generalização da rotina de banheiro', 'Banheiro', 'Ensinar/desenvolver a habilidade de usa o banheiro fora de casa com autonomia com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Usa o banheiro fora de casa com autonomia”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Itens reais da rotina de banheiro; apoio visual opcional; roupas fáceis de manejar.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Treinar na rotina natural; 1–3 oportunidades/dia, sem transformar toda a rotina em sessão.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Usa o banheiro fora de casa com autonomia”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Usa o banheiro fora de casa com autonomia” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Evitar punição, vergonha ou permanência forçada no vaso/penico.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F06A', 'F06AF004', 'Usa o banheiro fora de casa com autonomia', 'generalizacao', 4, 'Generalização da rotina de banheiro', 'Banheiro', 'Generalizar a habilidade de usa o banheiro fora de casa com autonomia para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Itens reais da rotina de banheiro; apoio visual opcional; roupas fáceis de manejar.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Usa o banheiro fora de casa com autonomia”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Usa o banheiro fora de casa com autonomia” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Evitar punição, vergonha ou permanência forçada no vaso/penico.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('funcional', 'F06A', 'F06AF004', 'Usa o banheiro fora de casa com autonomia', 'manutencao', 4, 'Generalização da rotina de banheiro', 'Banheiro', 'Manter a habilidade de usa o banheiro fora de casa com autonomia de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Itens reais da rotina de banheiro; apoio visual opcional; roupas fáceis de manejar.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Usa o banheiro fora de casa com autonomia”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Usa o banheiro fora de casa com autonomia” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda. Evitar punição, vergonha ou permanência forçada no vaso/penico.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F06A', 'F06AM001', 'Participa de esportes com coordenação', 'aquisicao', 1, 'Coordenação motora ampla em grupo', 'Global', 'Ensinar/desenvolver a habilidade de participa de esportes com coordenação com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Participa de esportes com coordenação”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas, respeitando segurança e fadiga.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Participa de esportes com coordenação”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Participa de esportes com coordenação” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F06A', 'F06AM001', 'Participa de esportes com coordenação', 'generalizacao', 1, 'Coordenação motora ampla em grupo', 'Global', 'Generalizar a habilidade de participa de esportes com coordenação para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Participa de esportes com coordenação”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Participa de esportes com coordenação” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F06A', 'F06AM001', 'Participa de esportes com coordenação', 'manutencao', 1, 'Coordenação motora ampla em grupo', 'Global', 'Manter a habilidade de participa de esportes com coordenação de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Participa de esportes com coordenação”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Participa de esportes com coordenação” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F06A', 'F06AM002', 'Usa materiais escolares com precisão', 'aquisicao', 2, 'Motricidade fina acadêmica', 'Fino', 'Ensinar/desenvolver a habilidade de usa materiais escolares com precisão com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Usa materiais escolares com precisão”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas, respeitando segurança e fadiga.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Usa materiais escolares com precisão”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Usa materiais escolares com precisão” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F06A', 'F06AM002', 'Usa materiais escolares com precisão', 'generalizacao', 2, 'Motricidade fina acadêmica', 'Fino', 'Generalizar a habilidade de usa materiais escolares com precisão para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Usa materiais escolares com precisão”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Usa materiais escolares com precisão” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F06A', 'F06AM002', 'Usa materiais escolares com precisão', 'manutencao', 2, 'Motricidade fina acadêmica', 'Fino', 'Manter a habilidade de usa materiais escolares com precisão de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Usa materiais escolares com precisão”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Usa materiais escolares com precisão” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F06A', 'F06AM003', 'Planeja e constrói com materiais simples', 'aquisicao', 3, 'Planejamento motor e construção funcional', 'Objeto', 'Ensinar/desenvolver a habilidade de planeja e constrói com materiais simples com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Planeja e constrói com materiais simples”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas, respeitando segurança e fadiga.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Planeja e constrói com materiais simples”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Planeja e constrói com materiais simples” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F06A', 'F06AM003', 'Planeja e constrói com materiais simples', 'generalizacao', 3, 'Planejamento motor e construção funcional', 'Objeto', 'Generalizar a habilidade de planeja e constrói com materiais simples para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Planeja e constrói com materiais simples”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Planeja e constrói com materiais simples” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F06A', 'F06AM003', 'Planeja e constrói com materiais simples', 'manutencao', 3, 'Planejamento motor e construção funcional', 'Objeto', 'Manter a habilidade de planeja e constrói com materiais simples de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Planeja e constrói com materiais simples”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Planeja e constrói com materiais simples” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F06A', 'F06AM004', 'Coordena ações em jogos com bola', 'aquisicao', 4, 'Coordenação motora social em jogos', 'Bola', 'Ensinar/desenvolver a habilidade de coordena ações em jogos com bola com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Coordena ações em jogos com bola”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Bola adequada à idade; alvo/cones opcionais; espaço seguro.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas, respeitando segurança e fadiga.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Coordena ações em jogos com bola”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Coordena ações em jogos com bola” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F06A', 'F06AM004', 'Coordena ações em jogos com bola', 'generalizacao', 4, 'Coordenação motora social em jogos', 'Bola', 'Generalizar a habilidade de coordena ações em jogos com bola para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Bola adequada à idade; alvo/cones opcionais; espaço seguro.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Coordena ações em jogos com bola”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Coordena ações em jogos com bola” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('motora', 'F06A', 'F06AM004', 'Coordena ações em jogos com bola', 'manutencao', 4, 'Coordenação motora social em jogos', 'Bola', 'Manter a habilidade de coordena ações em jogos com bola de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Bola adequada à idade; alvo/cones opcionais; espaço seguro.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Coordena ações em jogos com bola”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Coordena ações em jogos com bola” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F06A', 'F06AS001', 'Adota comportamentos observados socialmente', 'aquisicao', 1, 'Aprendizagem por modelagem social', 'Imitação', 'Ensinar/desenvolver a habilidade de adota comportamentos observados socialmente com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Adota comportamentos observados socialmente”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Adota comportamentos observados socialmente”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Adota comportamentos observados socialmente” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F06A', 'F06AS001', 'Adota comportamentos observados socialmente', 'generalizacao', 1, 'Aprendizagem por modelagem social', 'Imitação', 'Generalizar a habilidade de adota comportamentos observados socialmente para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Adota comportamentos observados socialmente”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Adota comportamentos observados socialmente” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F06A', 'F06AS001', 'Adota comportamentos observados socialmente', 'manutencao', 1, 'Aprendizagem por modelagem social', 'Imitação', 'Manter a habilidade de adota comportamentos observados socialmente de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Adota comportamentos observados socialmente”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Adota comportamentos observados socialmente” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F06A', 'F06AS002', 'Participa de jogos com regras estruturadas', 'aquisicao', 2, 'Ensino de regras e comportamento em grupo', 'Brincar', 'Ensinar/desenvolver a habilidade de participa de jogos com regras estruturadas com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Participa de jogos com regras estruturadas”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Participa de jogos com regras estruturadas”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Participa de jogos com regras estruturadas” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F06A', 'F06AS002', 'Participa de jogos com regras estruturadas', 'generalizacao', 2, 'Ensino de regras e comportamento em grupo', 'Brincar', 'Generalizar a habilidade de participa de jogos com regras estruturadas para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Participa de jogos com regras estruturadas”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Participa de jogos com regras estruturadas” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F06A', 'F06AS002', 'Participa de jogos com regras estruturadas', 'manutencao', 2, 'Ensino de regras e comportamento em grupo', 'Brincar', 'Manter a habilidade de participa de jogos com regras estruturadas de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Participa de jogos com regras estruturadas”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Participa de jogos com regras estruturadas” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F06A', 'F06AS003', 'Lida com derrotas ou mudanças de planos', 'aquisicao', 3, 'Reforçamento diferencial e treino de flexibilidade', 'Tolerância', 'Ensinar/desenvolver a habilidade de lida com derrotas ou mudanças de planos com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Lida com derrotas ou mudanças de planos”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Lida com derrotas ou mudanças de planos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Lida com derrotas ou mudanças de planos” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F06A', 'F06AS003', 'Lida com derrotas ou mudanças de planos', 'generalizacao', 3, 'Reforçamento diferencial e treino de flexibilidade', 'Tolerância', 'Generalizar a habilidade de lida com derrotas ou mudanças de planos para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Lida com derrotas ou mudanças de planos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Lida com derrotas ou mudanças de planos” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F06A', 'F06AS003', 'Lida com derrotas ou mudanças de planos', 'manutencao', 3, 'Reforçamento diferencial e treino de flexibilidade', 'Tolerância', 'Manter a habilidade de lida com derrotas ou mudanças de planos de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Lida com derrotas ou mudanças de planos”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Lida com derrotas ou mudanças de planos” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F06A', 'F06AS004', 'Reconhece e expressa emoções complexas', 'aquisicao', 4, 'Repertório verbal para emoções sociais', 'Resposta emocional', 'Ensinar/desenvolver a habilidade de reconhece e expressa emoções complexas com apoio planejado, aumentando gradualmente a independência.', '1) Organize uma oportunidade clara para “Reconhece e expressa emoções complexas”.
2) Dê a instrução ou apresente a situação e aguarde alguns segundos.
3) Se necessário, ofereça a menor dica eficaz.
4) Reforce imediatamente a resposta correta/participação.
5) Repita em oportunidades curtas e faça fading das ajudas conforme o desempenho.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', '1–2 sessões/dia; 6–10 oportunidades curtas.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Reconhece e expressa emoções complexas”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Reconhece e expressa emoções complexas” conforme o alvo definido, com redução progressiva das ajudas.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das oportunidades forem independentes por 2 dias consecutivos (mín. 10 oportunidades/dia quando aplicável).', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F06A', 'F06AS004', 'Reconhece e expressa emoções complexas', 'generalizacao', 4, 'Repertório verbal para emoções sociais', 'Resposta emocional', 'Generalizar a habilidade de reconhece e expressa emoções complexas para diferentes pessoas, materiais, ambientes e situações.', '1) Pratique a mesma habilidade com pessoas, materiais e locais diferentes.
2) Varie exemplos sem aumentar muitas dificuldades ao mesmo tempo.
3) Priorize respostas independentes e reduza gradualmente as dicas.
4) Use consequências naturais e reforço social.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Praticar diariamente em contextos variados; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Reconhece e expressa emoções complexas”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança realiza “Reconhece e expressa emoções complexas” em diferentes contextos, com pessoas/materiais variados e pouca ou nenhuma ajuda.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Avança quando ≥80% das respostas forem independentes em pelo menos 3 contextos/pessoas/materiais diferentes.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.'),
    ('social', 'F06A', 'F06AS004', 'Reconhece e expressa emoções complexas', 'manutencao', 4, 'Repertório verbal para emoções sociais', 'Resposta emocional', 'Manter a habilidade de reconhece e expressa emoções complexas de forma funcional e independente nas rotinas naturais.', '1) Crie oportunidades naturais sem avisar que é treino.
2) Observe a resposta independente.
3) Reforce principalmente com consequências naturais/intermitentes.
4) Se houver queda consistente, retome temporariamente apoio do nível anterior.', 'Materiais do cotidiano relacionados à habilidade; itens/atividades de interesse da criança.', 'Adulto/cuidador; ambiente seguro; instruções curtas; apoio visual quando útil; reforçadores individualizados.', 'Observação/treino 1x por semana; 5–8 oportunidades naturais.', 'Transformar a habilidade em situações lúdicas e naturais: missão do dia, faz-de-conta, escolha de atividades, jogos de turno ou desafios curtos relacionados a “Reconhece e expressa emoções complexas”.', '1. F = Física: ajuda motora somente quando necessária e segura.
2. G = Gestual: apontar/sinalizar a ação ou item.
3. V = Visual: modelo, figura, sequência ou demonstração.
4. VR = Verbal: instrução/pista curta.
5. I = Independente.
Use a menor ajuda eficaz e faça fading progressivo.', 'A criança mantém “Reconhece e expressa emoções complexas” espontaneamente ou quando a situação natural exige, sem ajuda frequente.', 'Se não responder ou errar, mantenha tom neutro, reduza a dificuldade, ofereça a menor dica eficaz e reapresente uma nova oportunidade. Reforce a resposta correta e retire gradualmente a ajuda.', 'Considerar mantida quando ≥70% das oportunidades ocorrerem de forma independente por 4 semanas.', 'Use a escala funcional:
A = Nunca ou raramente (1 em 5 vezes)
B = Pouca frequência (2–3 em 5 vezes)
C = Muito frequentemente (4–5 em 5 vezes)
NV = Não verificado

Registre também o tipo de ajuda em cada oportunidade:
F = Física | G = Gestual | V = Visual | VR = Verbal | I = Independente.
Anote acertos, contexto e observações relevantes.', 'Elogio específico; atenção positiva; continuidade da brincadeira/atividade; escolha; acesso breve a item ou atividade preferida; consequências naturais da habilidade.')
)
INSERT INTO exercises (
  skill_id, age_bracket_id, codigo, titulo, media_type, nivel, ordem, plano, status,
  programa_aba, funcao, objetivo, procedimento, materiais, recursos_extras,
  frequencia, brincadeiras, hierarquia_dicas, resposta_esperada,
  procedimento_correcao, criterio_avanco, registro_dados, reforcos
)
SELECT
  s.id,
  b.id,
  o.codigo,
  o.titulo,
  'imagem'::media_type,
  o.nivel::exercise_level,
  o.ordem,
  'free'::subscription_plan,
  'ativo'::record_status,
  o.programa_aba, o.funcao, o.objetivo, o.procedimento, o.materiais,
  o.recursos_extras, o.frequencia, o.brincadeiras, o.hierarquia_dicas,
  o.resposta_esperada, o.procedimento_correcao, o.criterio_avanco,
  o.registro_dados, o.reforcos
FROM oficial o
JOIN skills s ON s.key = o.skill_key
JOIN age_brackets b ON b.codigo = o.faixa_codigo;

-- ── 4. Trava de duplicidade ─────────────────────────────────
-- `exercises` não tinha nenhuma restrição de unicidade, então reaplicar um
-- importador duplicaria a trilha inteira da criança em silêncio. Índice
-- parcial porque `codigo` é opcional para atividades criadas pelo backoffice.
CREATE UNIQUE INDEX IF NOT EXISTS uq_exercises_codigo_nivel
  ON exercises (codigo, nivel) WHERE codigo IS NOT NULL;

-- ── 5. Conferência ──────────────────────────────────────────
-- Falha a migration inteira se o JOIN tiver perdido linha (skill.key ou
-- age_brackets.codigo divergente do esperado) — melhor não aplicar do que
-- aplicar pela metade.
DO $$
DECLARE
  v_total INTEGER;
BEGIN
  SELECT count(*) INTO v_total FROM exercises WHERE codigo ~ '^F0[1-6]A[CSGMF]\d{3}$';
  IF v_total <> 378 THEN
    RAISE EXCEPTION 'esperava 378 atividades oficiais, encontrei %', v_total;
  END IF;
END $$;
