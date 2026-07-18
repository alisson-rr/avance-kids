import { Plus, Trash2 } from 'lucide-react';
import type { QuestionOption } from '../../../types/common';
import styles from './OptionListEditor.module.css';

interface OptionListEditorProps {
  options: QuestionOption[];
  onChange: (options: QuestionOption[]) => void;
}

const VALOR_LABELS: Record<number, string> = {
  0: '0 · Nunca / Não observei',
  1: '1 · Às vezes',
  2: '2 · Sempre',
};

export function OptionListEditor({ options, onChange }: OptionListEditorProps) {
  function updateOption(id: number, patch: Partial<QuestionOption>) {
    onChange(options.map((o) => (o.id === id ? { ...o, ...patch } : o)));
  }

  function addOption() {
    const nextId = Math.max(0, ...options.map((o) => o.id)) + 1;
    onChange([...options, { id: nextId, texto: '', valorNumerico: 1 }]);
  }

  function removeOption(id: number) {
    onChange(options.filter((o) => o.id !== id));
  }

  return (
    <div className={styles.wrapper}>
      {options.map((opt, idx) => (
        <div key={opt.id} className={styles.row}>
          <span className={styles.index}>{idx + 1}</span>
          <input
            type="text"
            className={styles.textInput}
            placeholder="Texto da opção..."
            value={opt.texto}
            onChange={(e) => updateOption(opt.id, { texto: e.target.value })}
          />
          <select
            className={styles.valueSelect}
            value={opt.valorNumerico}
            onChange={(e) => updateOption(opt.id, { valorNumerico: Number(e.target.value) })}
          >
            {Object.entries(VALOR_LABELS).map(([value, label]) => (
              <option key={value} value={value}>
                {label}
              </option>
            ))}
          </select>
          <button
            type="button"
            className={styles.removeBtn}
            onClick={() => removeOption(opt.id)}
            title="Remover opção"
          >
            <Trash2 size={16} />
          </button>
        </div>
      ))}
      <button type="button" className={styles.addBtn} onClick={addOption}>
        <Plus size={16} />
        <span>Adicionar opção</span>
      </button>
    </div>
  );
}
