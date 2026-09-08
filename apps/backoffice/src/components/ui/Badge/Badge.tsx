import type { ReactNode } from 'react';
import styles from './Badge.module.css';

export type BadgeVariant = 'success' | 'neutral' | 'danger' | 'info';

interface BadgeProps {
  variant?: BadgeVariant;
  /** Hex color for dynamic tags (e.g. per-skill color) — overrides variant. */
  color?: string;
  backgroundColor?: string;
  children: ReactNode;
}

export function Badge({ variant = 'neutral', color, backgroundColor, children }: BadgeProps) {
  const customColor = Boolean(color || backgroundColor);
  const style = customColor
    ? { backgroundColor: backgroundColor ?? `${color}1A`, color }
    : undefined;

  return (
    <span className={`${styles.badge} ${customColor ? '' : styles[variant]}`} style={style}>
      {children}
    </span>
  );
}
