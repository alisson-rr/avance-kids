import { useCallback, useEffect, useState } from 'react';

/**
 * Lista carregada do Supabase com estado de loading/erro e refresh manual.
 * `fetcher` deve ser estável (função de módulo) para não relançar o efeito.
 */
export function useEntityList<T>(fetcher: () => Promise<T[]>) {
  const [rows, setRows] = useState<T[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const refresh = useCallback(async () => {
    setError(null);
    try {
      setRows(await fetcher());
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Falha ao carregar dados.');
    } finally {
      setLoading(false);
    }
  }, [fetcher]);

  useEffect(() => {
    void refresh();
  }, [refresh]);

  return { rows, loading, error, refresh };
}
