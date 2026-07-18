import type { ReactNode } from 'react';
import styles from './Badge.module.css';

export type BadgeVariant = 'success' | 'neutral' | 'danger' | 'info';

interface BadgeProps {
  variant?: BadgeVariant;
  /** Hex color for dynamic tags (e.g. per-skill color) — overrides variant. */
  color?: string;
  children: ReactNode;
}

export function Badge({ variant = 'neutral', color, children }: BadgeProps) {
  const style = color ? { backgroundColor: `${color}1A`, color } : undefined;

  return (
    <span className={`${styles.badge} ${color ? '' : styles[variant]}`} style={style}>
      {children}
    </span>
  );
}
