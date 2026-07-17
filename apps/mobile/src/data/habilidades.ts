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

export const HABILIDADE_STYLES: Record<HabilidadeKey, HabilidadeStyle> = {
  comunicacao: {
    background: '#FFCF4D', // Header BG
    tagBackground: '#FFF5E2',
    textColor: '#FFBE25',
    image: require('../../assets/Comunicacao.png'),
  },
  social: {
    background: '#82C302', // Verde (Header BG)
    tagBackground: '#F6FAED',
    textColor: '#82C302',
    image: require('../../assets/Social.png'),
  },
  cognitiva: {
    background: '#9F67FF', // Roxo (Header BG)
    tagBackground: '#ECE1FF', // Solid light purple
    textColor: '#9F67FF',
    image: require('../../assets/Cognitiva.png'),
  },
  motora: {
    background: '#FF8E25', // Laranja (Header BG)
    tagBackground: '#FFE7D7', // Solid light orange
    textColor: '#FD8936',
    image: require('../../assets/Coordenacao.png'),
  },
  funcional: {
    background: '#FE6D94', // Rosa (Header BG)
    tagBackground: '#FFE2EA', // Solid light pink
    textColor: '#FE6D94',
    image: require('../../assets/Funcional.png'),
  }
};

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
