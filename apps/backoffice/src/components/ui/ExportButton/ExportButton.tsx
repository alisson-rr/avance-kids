import { useState } from 'react';
import { Download } from 'lucide-react';
import { downloadCsv, toCsv, type CsvColumn } from '../../../utils/csv';
import styles from './ExportButton.module.css';

export interface ExportButtonProps<T> {
  fileBase: string;
  load: () => Promise<T[]>;
  columns: CsvColumn<T>[];
}

export function ExportButton<T>({ fileBase, load, columns }: ExportButtonProps<T>) {
  const [exporting, setExporting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleExport() {
    if (exporting) return;
    setExporting(true);
    setError(null);
    try {
      const rows = await load();
      downloadCsv(fileBase, toCsv(columns, rows));
    } catch (err) {
      setError(err instanceof Error ? err.message : 'erro inesperado');
    } finally {
      setExporting(false);
    }
  }

  return (
    <div className={styles.wrapper}>
      <button
        type="button"
        className={styles.button}
        onClick={handleExport}
        disabled={exporting}
        aria-busy={exporting}
      >
        <Download size={18} />
        <span>{exporting ? 'Exportando...' : 'Exportar'}</span>
      </button>
      {error && (
        <p role="alert" className={styles.error}>
          Não foi possível exportar: {error}. Tente novamente.
        </p>
      )}
    </div>
  );
}
