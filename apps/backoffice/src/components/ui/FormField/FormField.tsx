import type { ReactNode } from 'react';
import styles from './FormField.module.css';

interface FormFieldProps {
  label: string;
  required?: boolean;
  fullWidth?: boolean;
  hint?: string;
  children: ReactNode;
}

export function FormField({ label, required, fullWidth, hint, children }: FormFieldProps) {
  return (
    <div className={`${styles.group} ${fullWidth ? styles.fullWidth : ''}`}>
      <label>
        {label}
        {required && ' *'}
      </label>
      {children}
      {hint && <span className={styles.hint}>{hint}</span>}
    </div>
  );
}
