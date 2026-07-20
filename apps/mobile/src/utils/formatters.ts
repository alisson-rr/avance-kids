export const maskCpf = (value: string) => {
  return value
    .replace(/\D/g, '')
    .replace(/(\d{3})(\d)/, '$1.$2')
    .replace(/(\d{3})(\d)/, '$1.$2')
    .replace(/(\d{3})(\d{1,2})/, '$1-$2')
    .replace(/(-\d{2})\d+?$/, '$1');
};

export const maskDate = (value: string) => {
  return value
    .replace(/\D/g, '')
    .replace(/(\d{2})(\d)/, '$1/$2')
    .replace(/(\d{2})(\d)/, '$1/$2')
    .replace(/(\/\d{4})\d+?$/, '$1');
};

export const maskPhone = (value: string) => {
  return value
    .replace(/\D/g, '')
    .replace(/(\d{2})(\d)/, '($1) $2')
    .replace(/(\d{5})(\d)/, '$1-$2')
    .replace(/(-\d{4})\d+?$/, '$1');
};

export const digitsOnly = (value: string) => value.replace(/\D/g, '');

/** dd/mm/aaaa -> aaaa-mm-dd (formato do banco). Retorna null se inválida. */
export const toIsoDate = (br: string): string | null => {
  const m = br.match(/^(\d{2})\/(\d{2})\/(\d{4})$/);
  if (!m) return null;
  const [, dd, mm, yyyy] = m;
  const date = new Date(Number(yyyy), Number(mm) - 1, Number(dd));
  const valid =
    date.getFullYear() === Number(yyyy) &&
    date.getMonth() === Number(mm) - 1 &&
    date.getDate() === Number(dd);
  return valid ? `${yyyy}-${mm}-${dd}` : null;
};

/** aaaa-mm-dd -> dd/mm/aaaa (exibição). */
export const fromIsoDate = (iso: string | null | undefined): string => {
  if (!iso) return '';
  const m = iso.match(/^(\d{4})-(\d{2})-(\d{2})/);
  return m ? `${m[3]}/${m[2]}/${m[1]}` : iso;
};

/** aaaa-mm-dd -> "4 anos e 2 meses" (ou "8 meses" abaixo de 1 ano). */
export const formatAgeFromIso = (iso: string | null | undefined): string => {
  if (!iso) return '';
  const birth = new Date(`${iso}T12:00:00`);
  if (Number.isNaN(birth.getTime())) return '';
  const now = new Date();
  let months =
    (now.getFullYear() - birth.getFullYear()) * 12 + (now.getMonth() - birth.getMonth());
  if (now.getDate() < birth.getDate()) months -= 1;
  months = Math.max(0, months);
  const anos = Math.floor(months / 12);
  const meses = months % 12;
  if (anos === 0) return `${meses} ${meses === 1 ? 'mês' : 'meses'}`;
  const anosLabel = `${anos} ${anos === 1 ? 'ano' : 'anos'}`;
  return meses > 0 ? `${anosLabel} e ${meses} ${meses === 1 ? 'mês' : 'meses'}` : anosLabel;
};
