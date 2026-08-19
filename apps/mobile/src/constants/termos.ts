/**
 * Texto oficial dos Termos de Uso e Política de Privacidade.
 *
 * Transcrição fiel de AvanceKids-DOCUMENTACAO/Termos_e_Privacidade_Avance_Kids_Final.pdf
 * (sha256 2952dfd4…a484e), o mesmo arquivo semeado em `terms_documents` pela
 * migration-06. Substitui o Lorem ipsum que estava no TermsModal.
 *
 * O texto vem embutido no app de propósito: o modal aparece no cadastro, antes
 * de existir sessão, e precisa funcionar offline. A VERSÃO, porém, é sempre a
 * do servidor (`terms_documents.vigente`) — o app não decide qual documento
 * está valendo. `TERMOS_VERSAO_EMBUTIDA` existe só para detectar quando o
 * servidor publicou uma versão mais nova que este binário e avisar o usuário.
 */

export const TERMOS_VERSAO_EMBUTIDA = '2026-08-17';

export const TERMOS_TITULO = 'Termos de Uso e Política de Privacidade — Avance Kids';

export interface SecaoTermos {
  titulo?: string;
  paragrafos?: string[];
  itens?: string[];
}

export const TERMOS_SECOES: SecaoTermos[] = [
  {
    paragrafos: [
      'Bem-vindo ao Avance Kids. Este documento contém as regras de uso do aplicativo e as diretrizes sobre como coletamos, utilizamos e protegemos as suas informações e, principalmente, as informações de saúde do menor sob sua responsabilidade, em estrita conformidade com a Lei Geral de Proteção de Dados Pessoais (LGPD – Lei nº 13.709/2018) e o Código de Defesa do Consumidor.',
    ],
  },
  {
    titulo: '1. Visão Geral e Público-Alvo',
    paragrafos: [
      'O Avance Kids é uma plataforma voltada a pais e responsáveis legais.',
      'Ao criar uma conta, o usuário declara, sob as penas da lei, ser o pai, mãe ou responsável legal (detentor do poder familiar ou da guarda) do menor cujos dados serão cadastrados na plataforma, possuindo plena legitimidade e autorização legal para representá-lo e consentir com o tratamento de seus dados pessoais e de saúde.',
    ],
  },
  {
    titulo: '2. Coleta de Dados e Finalidades',
    paragrafos: [
      'Para o funcionamento adequado e personalização da plataforma, coletamos as seguintes categorias de dados:',
    ],
    itens: [
      'Dados do Responsável Legal: Nome completo, CPF, e-mail, telefone e dados de faturamento (utilizados para criação da conta, autenticação, suporte, emissão de notas fiscais e comunicação).',
      'Dados da Criança: Nome ou apelido, data de nascimento, foto de perfil e informações sensíveis de saúde e desenvolvimento (como laudos ou indicativos de Autismo/TEA, TDAH e outras condições).',
      'Finalidade do Tratamento: Os dados de saúde do menor são utilizados exclusivamente, sob o ecossistema do Avance Kids, para adaptar trilhas de desenvolvimento, gerar relatórios, sugerir conteúdos educacionais e recomendar serviços, profissionais e produtos adequados ao perfil da criança diretamente ao painel do responsável.',
    ],
  },
  {
    titulo: '3. Consentimento Expresso (Dados de Menores e Dados Sensíveis)',
    paragrafos: [
      'Ao aceitar estes Termos no ato do cadastro, o Responsável Legal concede seu consentimento livre, informado, inequívoco e destacado (conforme exigem os arts. 11 e 14 da LGPD) para o processamento dos dados pessoais e sensíveis da criança para as finalidades descritas neste documento.',
    ],
  },
  {
    titulo: '4. Monetização, Marketplace e Funcionalidades Comerciais',
    paragrafos: [
      'A plataforma oferece os seguintes serviços e modelos de negócios voltados ao responsável legal:',
    ],
    itens: [
      'Marketplace de Especialistas: Facilitamos a conexão entre os responsáveis e profissionais de saúde e educação (terapeutas, psicopedagogos, médicos). O Avance Kids atua estritamente como intermediador tecnológico. O profissional de saúde é o único responsável técnico e civil pela conduta, atendimento e diagnóstico realizados.',
      'E-commerce e Afiliados: O aplicativo pode sugerir e comercializar produtos, materiais adaptados, livros ou cursos adequados às necessidades da criança.',
      'Conteúdos Patrocinados: O aplicativo pode exibir artigos, cursos ou trilhas patrocinadas por marcas ou instituições parceiras no painel do responsável. Tais conteúdos serão devidamente sinalizados e não haverá repasse de dados individuais dos usuários aos patrocinadores.',
      'Acesso Compartilhado (B2B): Funcionalidades que permitam a escolas, clínicas ou profissionais acessarem o perfil e os relatórios da criança só ocorrerão mediante autorização expressa e ativa (opt-in) do Responsável Legal dentro do aplicativo.',
    ],
  },
  {
    titulo: '5. Processamento Financeiro e Pagamentos',
    paragrafos: [
      'O Avance Kids poderá processar pagamentos de assinaturas, produtos ou serviços do Marketplace de duas formas:',
    ],
    itens: [
      'Plataformas de Terceiros e Gateways: Pagamentos via cartão de crédito, PIX ou boleto realizados fora do ecossistema das lojas de aplicativos são processados por gateways certificados e seguros (PCI-DSS). O Avance Kids não armazena dados críticos de cartões. Dados cadastrais do Responsável (Nome, CPF e e-mail) serão compartilhados com o gateway apenas para conclusão da transação e prevenção a fraudes. Cancelamentos seguirão o prazo de arrependimento (7 dias) do Código de Defesa do Consumidor.',
      'Compras Nativas (In-App Purchases): Compras realizadas diretamente via Apple App Store ou Google Play Store estão sujeitas aos termos e às políticas de cancelamento e reembolso dessas respectivas empresas. O gerenciamento destas assinaturas deve ser feito no painel do dispositivo do usuário.',
    ],
  },
  {
    titulo: '6. Compartilhamento de Dados e Ferramentas de Análise (Analytics/Marketing)',
    itens: [
      'Não Compartilhamento Comercial: É expressamente vedada a venda, o aluguel ou o compartilhamento de diagnósticos, dados de saúde ou dados pessoais da criança com terceiros para fins de criação de perfis de publicidade externa (data brokers).',
      'Ferramentas de Desempenho e Tráfego: Utilizamos ferramentas de tecnologia de terceiros (como Google Ads, Meta Pixel, Firebase) exclusivamente para analisar métricas de uso gerais do aplicativo (ex: telas acessadas) e mensurar eventos de conversão (ex: cadastro efetuado) para nossas próprias campanhas de marketing. Nenhuma informação de saúde ou dado pessoal do menor é anexada, compartilhada ou enviada a essas plataformas de rastreamento de anúncios.',
    ],
  },
  {
    titulo: '7. Uso de Dados Anonimizados e Estatísticos',
    paragrafos: [
      'Em conformidade com o art. 12 da LGPD, o Avance Kids poderá consolidar, anonimizar e agregar os dados inseridos na plataforma de modo que não seja mais possível a identificação direta ou indireta de nenhuma criança ou família. Estes dados estatísticos poderão ser utilizados para fins de pesquisa científica, publicações acadêmicas, relatórios de mercado (EdTech/HealthTech) e aprimoramento de algoritmos pedagógicos.',
    ],
  },
  {
    titulo: '8. Isenção de Responsabilidade Médica',
    paragrafos: [
      'Os conteúdos, algoritmos de recomendação, relatórios e sugestões disponibilizados no Avance Kids possuem caráter puramente informativo, de apoio pedagógico e de acompanhamento rotineiro. O uso do aplicativo não substitui, em hipótese alguma, consultas, diagnósticos, acompanhamentos ou tratamentos conduzidos por médicos, psicólogos ou terapeutas qualificados.',
    ],
  },
  {
    titulo: '9. Armazenamento, Segurança e Direitos do Titular',
    paragrafos: [
      'As informações são armazenadas em servidores em nuvem de alta confiabilidade, utilizando criptografia no trânsito e em repouso. O Responsável Legal, como titular dos dados, possui os seguintes direitos a qualquer momento:',
    ],
    itens: [
      'Acessar, alterar ou atualizar os dados de seu perfil e os da criança.',
      'Exportar um relatório com as informações mantidas pela plataforma.',
      'Revogar o consentimento ou solicitar a exclusão definitiva da conta, hipótese em que todos os dados pessoais e de saúde vinculados serão apagados dos nossos servidores (salvo obrigações legais de retenção de registros financeiros ou logs de acesso).',
    ],
  },
  {
    paragrafos: [
      'As solicitações podem ser feitas diretamente pelas configurações da conta no aplicativo ou através do e-mail de suporte institucional.',
    ],
  },
];
