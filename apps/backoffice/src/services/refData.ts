import { supabase } from '../lib/supabase';
import type { HabilidadeKey, AgeBracketCode } from '../constants/aba';

// skills e age_brackets são seedados pela migração e mudam raramente;
// carregamos uma vez por sessão e traduzimos UUID <-> slug/código do frontend.

export interface SkillRef {
  id: string;
  key: HabilidadeKey;
  nome: string;
  corHex: string;
}

export interface BracketRef {
  id: string;
  codigo: AgeBracketCode;
  nome: string;
}

export interface RefData {
  skills: SkillRef[];
  brackets: BracketRef[];
  skillIdByKey: (key: HabilidadeKey) => string;
  skillKeyById: (id: string) => HabilidadeKey;
  bracketIdByCode: (codigo: AgeBracketCode) => string;
  bracketCodeById: (id: string) => AgeBracketCode;
}

let cache: Promise<RefData> | null = null;

async function load(): Promise<RefData> {
  const [skillsRes, bracketsRes] = await Promise.all([
    supabase.from('skills').select('id, key, nome, cor_hex').order('ordem'),
    supabase.from('age_brackets').select('id, codigo, nome').order('ordem'),
  ]);

  if (skillsRes.error) throw new Error(skillsRes.error.message);
  if (bracketsRes.error) throw new Error(bracketsRes.error.message);

  const skills: SkillRef[] = (skillsRes.data ?? []).map((s) => ({
    id: s.id,
    key: s.key as HabilidadeKey,
    nome: s.nome,
    corHex: s.cor_hex,
  }));
  const brackets: BracketRef[] = (bracketsRes.data ?? []).map((b) => ({
    id: b.id,
    codigo: b.codigo as AgeBracketCode,
    nome: b.nome,
  }));

  const skillByKey = new Map(skills.map((s) => [s.key, s.id]));
  const skillById = new Map(skills.map((s) => [s.id, s.key]));
  const bracketByCode = new Map(brackets.map((b) => [b.codigo, b.id]));
  const bracketById = new Map(brackets.map((b) => [b.id, b.codigo]));

  function required<K, V>(map: Map<K, V>, key: K, what: string): V {
    const value = map.get(key);
    if (value === undefined) throw new Error(`${what} não encontrado: ${String(key)}`);
    return value;
  }

  return {
    skills,
    brackets,
    skillIdByKey: (key) => required(skillByKey, key, 'Habilidade'),
    skillKeyById: (id) => required(skillById, id, 'Habilidade'),
    bracketIdByCode: (codigo) => required(bracketByCode, codigo, 'Faixa etária'),
    bracketCodeById: (id) => required(bracketById, id, 'Faixa etária'),
  };
}

export function getRefData(): Promise<RefData> {
  if (!cache) {
    cache = load().catch((err) => {
      cache = null; // permite tentar de novo após falha de rede
      throw err;
    });
  }
  return cache;
}
