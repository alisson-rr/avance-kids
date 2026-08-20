/**
 * Cenários do bloqueio de reaceite dos termos
 * (apps/mobile/src/services/termsGate.ts).
 *
 * Roda com `bash scripts/test_terms_gate.sh` — sem framework: o módulo sob
 * teste não importa React nem Supabase de propósito, então compila e roda em
 * Node puro com as dependências injetadas.
 *
 * Dois grupos:
 *   A–J  decisão pura. Protegem a regra de que "não consegui verificar" nunca
 *        pode virar "já aceitou".
 *   K–R  sequenciamento do store. Protegem contra resultado atrasado
 *        sobrescrevendo o estado de outra sessão e contra suspensão que não é
 *        desfeita — os dois defeitos que passavam pela suíte anterior, que só
 *        exercitava as funções puras.
 */
import { avaliarGate, aceitarGate, criarTermsGate, type GateDeps } from '../apps/mobile/src/services/termsGate';
import type { TermsDocumentRow } from '../apps/mobile/src/types/db';

// Asserts à mão: @types/node não está instalado e não vale adicionar uma
// dependência de tipos para uma suíte deste tamanho.
const assert = {
  equal(recebido: unknown, esperado: unknown, msg = '') {
    if (recebido !== esperado) {
      throw new Error(`${msg} esperava ${JSON.stringify(esperado)}, veio ${JSON.stringify(recebido)}`);
    }
  },
  deepEqual(recebido: unknown, esperado: unknown, msg = '') {
    const a = JSON.stringify(recebido);
    const b = JSON.stringify(esperado);
    if (a !== b) throw new Error(`${msg} esperava ${b}, veio ${a}`);
  },
};

const USUARIO = 'user-1';
const OUTRO = 'user-2';

const V1: TermsDocumentRow = {
  id: 'doc-2026-08-17',
  tipo: 'termos_e_privacidade',
  versao: '2026-08-17',
  titulo: 'Termos de Uso e Política de Privacidade',
  url: null,
};

const V2: TermsDocumentRow = { ...V1, id: 'doc-2027-03-01', versao: '2027-03-01' };

/** Banco falso: `aceitos` guarda pares "usuario:documento". */
function deps(
  vigente: TermsDocumentRow | null,
  aceitos: string[],
  over: Partial<GateDeps> = {},
): GateDeps {
  return {
    documentoVigente: async () => vigente,
    temAceite: async (documentId, usuarioId) => aceitos.includes(`${usuarioId}:${documentId}`),
    registrarAceite: async (documentId) => {
      aceitos.push(`${USUARIO}:${documentId}`);
    },
    ...over,
  };
}

/** Promise que o teste resolve na hora que quiser. */
function adiada<T>() {
  let resolver!: (v: T) => void;
  let rejeitar!: (e: unknown) => void;
  const promise = new Promise<T>((res, rej) => {
    resolver = res;
    rejeitar = rej;
  });
  return { promise, resolver, rejeitar };
}

const proximoTick = () => new Promise<void>((r) => setTimeout(r, 0));

const casos: [string, () => Promise<void>][] = [
  // ── decisão ────────────────────────────────────────────────────────────
  ['A. usuário novo, aceite registrado no cadastro -> libera', async () => {
    const e = await avaliarGate(deps(V1, [`${USUARIO}:${V1.id}`]), USUARIO);
    assert.equal(e.tipo, 'liberado');
  }],

  ['B. conta antiga sem nenhum registro -> bloqueia pedindo a vigente', async () => {
    const e = await avaliarGate(deps(V1, []), USUARIO);
    assert.equal(e.tipo, 'pendente');
    assert.equal(e.tipo === 'pendente' && e.documento.id, V1.id);
  }],

  ['C. aceitou a versão antiga e há uma nova vigente -> bloqueia na nova', async () => {
    const e = await avaliarGate(deps(V2, [`${USUARIO}:${V1.id}`]), USUARIO);
    assert.equal(e.tipo, 'pendente');
    assert.equal(e.tipo === 'pendente' && e.documento.versao, V2.versao);
  }],

  ['D. já aceitou a vigente -> libera sem pedir nada', async () => {
    const e = await avaliarGate(deps(V2, [`${USUARIO}:${V1.id}`, `${USUARIO}:${V2.id}`]), USUARIO);
    assert.equal(e.tipo, 'liberado');
  }],

  ['E. accept-terms falha -> continua pendente, com a mensagem, nunca liberado', async () => {
    const aceitos: string[] = [];
    const d = deps(V1, aceitos, {
      registrarAceite: async () => {
        throw new Error('Edge Function retornou 500');
      },
    });
    const e = await aceitarGate(d, V1, USUARIO);
    assert.equal(e.tipo, 'pendente');
    const motivo = e.tipo === 'pendente' && e.erro instanceof Error ? e.erro.message : null;
    assert.equal(motivo, 'Edge Function retornou 500');
    assert.deepEqual(aceitos, [], 'nada pode ter sido gravado');
  }],

  ['F. reinício do app durante o bloqueio -> continua bloqueado', async () => {
    const aceitos: string[] = [];
    const d = deps(V1, aceitos);
    assert.equal((await avaliarGate(d, USUARIO)).tipo, 'pendente');
    assert.equal((await avaliarGate(d, USUARIO)).tipo, 'pendente');
    assert.equal((await aceitarGate(d, V1, USUARIO)).tipo, 'liberado');
    assert.equal((await avaliarGate(d, USUARIO)).tipo, 'liberado');
  }],

  ['G. falha ao consultar o documento -> erro, não liberado', async () => {
    const e = await avaliarGate(
      deps(V1, [], {
        documentoVigente: async () => {
          throw new Error('network request failed');
        },
      }),
      USUARIO,
    );
    assert.equal(e.tipo, 'erro');
  }],

  ['H. falha ao consultar o aceite -> erro, não liberado', async () => {
    const e = await avaliarGate(
      deps(V1, [], {
        temAceite: async () => {
          throw new Error('permission denied');
        },
      }),
      USUARIO,
    );
    assert.equal(e.tipo, 'erro');
  }],

  ['I. nenhum documento vigente -> libera (não é o mesmo que falhar)', async () => {
    const e = await avaliarGate(deps(null, []), USUARIO);
    assert.equal(e.tipo, 'liberado');
  }],

  ['J. o aceite é gravado para o documento exibido, não para "o vigente"', async () => {
    const aceitos: string[] = [];
    const d = deps(V1, aceitos);
    assert.equal((await aceitarGate(d, V1, USUARIO)).tipo, 'liberado');
    assert.deepEqual(aceitos, [`${USUARIO}:${V1.id}`]);
  }],

  ['K. aceite recusado porque a versão virou outra -> mostra o documento novo', async () => {
    // Cenário do 409 de accept-terms: a tela ficou aberta em V1 e V2 passou a
    // vigorar. Insistir em V1 deixaria o usuário preso num texto que não vale.
    const d = deps(V2, [], {
      registrarAceite: async () => {
        throw new Error('Os termos foram atualizados enquanto esta tela estava aberta.');
      },
    });
    const e = await aceitarGate(d, V1, USUARIO);
    assert.equal(e.tipo, 'pendente');
    assert.equal(e.tipo === 'pendente' && e.documento.versao, V2.versao);
  }],

  ['L. aceite de um usuário não vale para outro', async () => {
    const e = await avaliarGate(deps(V1, [`${OUTRO}:${V1.id}`]), USUARIO);
    assert.equal(e.tipo, 'pendente', 'aceite alheio não pode liberar');
  }],

  // ── sequenciamento do store ────────────────────────────────────────────
  ['M. aceite que responde depois de limpar() não reabre o bloqueio', async () => {
    const aceite = adiada<void>();
    const store = criarTermsGate(
      deps(V1, [], { registrarAceite: () => aceite.promise }),
    );

    await store.getState().avaliar(USUARIO);
    assert.equal(store.getState().estado.tipo, 'pendente');

    void store.getState().aceitar();
    await proximoTick();
    assert.equal(store.getState().enviando, true);

    // Sessão cai no meio (token revogado): o App chama limpar().
    store.getState().limpar();
    assert.equal(store.getState().estado.tipo, 'ocioso');

    aceite.rejeitar(new Error('401'));
    await proximoTick();
    await proximoTick();

    assert.equal(store.getState().estado.tipo, 'ocioso', 'resultado atrasado sobrescreveu o estado limpo');
    assert.equal(store.getState().enviando, false, 'botão ficaria travado em envio');
  }],

  ['N. aceite atrasado do usuário A não libera o app para B', async () => {
    const aceite = adiada<void>();
    const store = criarTermsGate(
      deps(V1, [], { registrarAceite: () => aceite.promise }),
    );

    await store.getState().avaliar(USUARIO);
    void store.getState().aceitar();
    await proximoTick();

    // A sai, B entra — B nunca aceitou.
    store.getState().limpar();
    await store.getState().avaliar(OUTRO);
    assert.equal(store.getState().estado.tipo, 'pendente');

    aceite.resolver();
    await proximoTick();
    await proximoTick();

    assert.equal(store.getState().estado.tipo, 'pendente', 'B entrou no app com o aceite de A');
  }],

  ['O. avaliação superada por outra não sobrescreve a mais recente', async () => {
    const primeira = adiada<TermsDocumentRow | null>();
    let chamada = 0;
    const store = criarTermsGate(
      deps(V1, [`${OUTRO}:${V1.id}`], {
        documentoVigente: () => (++chamada === 1 ? primeira.promise : Promise.resolve(V1)),
      }),
    );

    void store.getState().avaliar(USUARIO); // fica pendurada
    await proximoTick();
    await store.getState().avaliar(OUTRO); // resolve primeiro, libera
    assert.equal(store.getState().estado.tipo, 'liberado');

    primeira.resolver(V1); // a antiga responde agora
    await proximoTick();
    await proximoTick();

    assert.equal(store.getState().estado.tipo, 'liberado', 'avaliação antiga sobrescreveu a atual');
  }],

  ['P. cadastro: suspender silencia o gate e retomar(false) não repinta a tela', async () => {
    const store = criarTermsGate(deps(V1, []));

    store.getState().suspender();
    await store.getState().avaliar(USUARIO); // durante o signUp
    assert.equal(store.getState().estado.tipo, 'ocioso', 'gate apareceu no meio do cadastro');

    store.getState().retomar(false); // aceite gravado com sucesso
    await proximoTick();
    assert.equal(store.getState().estado.tipo, 'ocioso', 'reavaliou sem motivo');
  }],

  ['Q. cadastro: se o aceite falhar, retomar() bloqueia o app', async () => {
    const store = criarTermsGate(deps(V1, []));

    store.getState().suspender();
    await store.getState().avaliar(USUARIO);

    store.getState().retomar(); // aceite falhou no cadastro
    await proximoTick();
    await proximoTick();
    assert.equal(store.getState().estado.tipo, 'pendente');
  }],

  ['R. limpar() desfaz a suspensão: a conta seguinte volta a ser verificada', async () => {
    const store = criarTermsGate(deps(V1, []));

    store.getState().suspender(); // cadastro começou e não terminou
    store.getState().limpar(); // usuário voltou para o Login

    await store.getState().avaliar(OUTRO);
    assert.equal(store.getState().estado.tipo, 'pendente', 'gate ficou desligado para a conta seguinte');
  }],

  ['S. sem sessão o gate não consulta nada nem acusa pendência', async () => {
    let consultas = 0;
    const store = criarTermsGate(
      deps(V1, [], {
        documentoVigente: async () => {
          consultas++;
          return V1;
        },
      }),
    );

    await store.getState().avaliar(null);
    assert.equal(store.getState().estado.tipo, 'ocioso');
    assert.equal(consultas, 0);
  }],
];

async function main() {
  let falhou = 0;
  for (const [nome, fn] of casos) {
    try {
      await fn();
      console.log('  ok   ' + nome);
    } catch (err) {
      falhou++;
      console.log('  FALHA ' + nome);
      console.log('        ' + (err instanceof Error ? err.message : String(err)));
    }
  }
  console.log(`\n${casos.length - falhou}/${casos.length} casos passaram`);
  // Sem process.exit (exigiria @types/node): lançar já devolve código != 0.
  if (falhou > 0) throw new Error(`${falhou} caso(s) do gate de termos falharam`);
}

void main();
