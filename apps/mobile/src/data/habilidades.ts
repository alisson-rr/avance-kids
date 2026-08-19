export type HabilidadeKey = 
  | 'comunicacao' 
  | 'social' 
  | 'cognitiva' 
  | 'motora' 
  | 'funcional';

export interface HabilidadeStyle {
  background: string;
  tagBackground: string;
  textColor: string;
  image: any;
}

// textColor e usado como cor de TEXTO sobre tagBackground (fundo claro) e como
// preenchimento da barra de progresso. Os tons originais do Figma ficavam entre
// 1.5:1 e 3.1:1 de contraste — abaixo do minimo legivel. Foram escurecidos
// mantendo a mesma familia de cor; `background` (faixa colorida) segue igual.
export const HABILIDADE_STYLES: Record<HabilidadeKey, HabilidadeStyle> = {
  comunicacao: {
    background: '#FFCF4D', // Header BG
    tagBackground: '#FFF5E2',
    textColor: '#8A5A00',
    image: require('../../assets/Comunicacao.png'),
  },
  social: {
    background: '#82C302', // Verde (Header BG)
    tagBackground: '#F6FAED',
    textColor: '#4F7000',
    image: require('../../assets/Social.png'),
  },
  cognitiva: {
    background: '#9F67FF', // Roxo (Header BG)
    tagBackground: '#ECE1FF', // Solid light purple
    textColor: '#6B33CC',
    image: require('../../assets/Cognitiva.png'),
  },
  motora: {
    background: '#FF8E25', // Laranja (Header BG)
    tagBackground: '#FFE7D7', // Solid light orange
    textColor: '#A34E00',
    image: require('../../assets/Coordenacao.png'),
  },
  funcional: {
    background: '#FE6D94', // Rosa (Header BG)
    tagBackground: '#FFE2EA', // Solid light pink
    textColor: '#B8244B',
    image: require('../../assets/Funcional.png'),
  }
};

export interface Habilidade {
  id: number;
  key: HabilidadeKey;
  title: string;
  totalPerguntas: number;
}

export const HABILIDADES: Habilidade[] = [
  { id: 1, key: 'comunicacao', title: 'Comunicação', totalPerguntas: 5 },
  { id: 2, key: 'social', title: 'Social', totalPerguntas: 4 },
  { id: 3, key: 'cognitiva', title: 'Cognitiva', totalPerguntas: 4 },
  { id: 4, key: 'motora', title: 'Coordenação motora', totalPerguntas: 4 },
  { id: 5, key: 'funcional', title: 'Funcional', totalPerguntas: 4 },
];

// Cores das tags de habilidade usadas nos cards de atividade (plano e histórico)
// Mesmas cores de fundo do Figma; texto escurecido para ficar legivel (>= 4.5:1).
export const SKILL_COLORS: Record<string, { text: string; bg: string }> = {
  'Comunicação':         { text: '#8A5A00', bg: '#FFF5E2' },
  'Social':              { text: '#4F7000', bg: 'rgba(167, 213, 77, 0.1)' },
  'Cognitiva':           { text: '#6B33CC', bg: 'rgba(159, 103, 255, 0.2)' },
  'Coordenação motora':  { text: '#A34E00', bg: 'rgba(253, 137, 54, 0.2)' },
};

export const getSkillColor = (skill: string) =>
  SKILL_COLORS[skill] || { text: '#0E5DFD', bg: '#EEF4FF' };

export const MOCK_PERGUNTAS = [
  {
    id: 1,
    question: 'Seu filho(a) olha quando você o chama pelo nome?',
    options: [
      'Quase nunca faz, mesmo com ajuda',
      'Faz às vezes ou com ajuda',
      'Faz quase sempre, com autonomia',
      'Não observei essa situação ainda',
    ],
  },
  {
    id: 2,
    question: 'Seu filho(a) aponta para objetos que deseja?',
    options: [
      'Ainda não faz esse gesto',
      'Faz com ajuda ou raramente',
      'Faz com frequência e autonomia',
      'Não observei essa situação ainda',
    ],
  },
  {
    id: 3,
    question: 'Seu filho(a) consegue brincar junto com outras crianças?',
    options: [
      'Prefere brincar sozinho(a)',
      'Às vezes interage, com incentivo',
      'Brinca bem com outras crianças',
      'Não observei essa situação ainda',
    ],
  },
  {
    id: 4,
    question: 'Seu filho(a) imita gestos ou expressões de outras pessoas?',
    options: [
      'Raramente ou nunca imita',
      'Imita com ajuda ou às vezes',
      'Imita com facilidade e espontaneidade',
      'Não observei essa situação ainda',
    ],
  },
  {
    id: 5,
    question: 'Seu filho(a) demonstra interesse por outras pessoas?',
    options: [
      'Raramente ou nunca demonstra',
      'Demonstra com ajuda ou às vezes',
      'Demonstra com facilidade e espontaneidade',
      'Não observei essa situação ainda',
    ],
  },
];
