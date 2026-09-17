export interface CsvColumn<T> {
  header: string;
  value: (row: T) => string | number | null | undefined;
}

function cell(value: string | number | null | undefined): string {
  if (value === null || value === undefined) return '';
  if (typeof value === 'number') return String(value);
  // Evita que o Excel execute o texto como fórmula.
  const text = /^[=+\-@\t\r]/.test(value) ? `'${value}` : value;
  return /[;,"\r\n]|^\s|\s$/.test(text) ? `"${text.replaceAll('"', '""')}"` : text;
}

export function toCsv<T>(columns: CsvColumn<T>[], rows: T[]): string {
  const lines = [
    columns.map((column) => cell(column.header)),
    ...rows.map((row) => columns.map((column) => cell(column.value(row)))),
  ].map((cells) => cells.join(';'));
  // ';' + BOM é o que o Excel em pt-BR abre em colunas e com acentos.
  return `${String.fromCharCode(0xfeff)}${lines.join('\r\n')}\r\n`;
}

export function downloadCsv(fileBase: string, csv: string): void {
  const now = new Date();
  const date = [
    now.getFullYear(),
    String(now.getMonth() + 1).padStart(2, '0'),
    String(now.getDate()).padStart(2, '0'),
  ].join('-');

  const url = URL.createObjectURL(new Blob([csv], { type: 'text/csv;charset=utf-8' }));
  const link = document.createElement('a');
  link.href = url;
  link.download = `${fileBase}_${date}.csv`;
  document.body.appendChild(link);
  link.click();
  link.remove();
  setTimeout(() => URL.revokeObjectURL(url), 0);
}
