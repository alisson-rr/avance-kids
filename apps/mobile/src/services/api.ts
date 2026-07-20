import { supabase } from '../lib/supabase';

/**
 * Invoca uma Edge Function e converte o erro no formato `{ error }` que
 * todas as functions do projeto retornam (_shared/response.ts) em Error
 * com mensagem legível para Alert.
 */
export async function invokeFunction<T>(name: string, body: Record<string, unknown>): Promise<T> {
  const { data, error } = await supabase.functions.invoke(name, { body });

  if (error) {
    let message = error.message || 'Não foi possível completar a operação.';
    const context = (error as { context?: unknown }).context;
    if (context instanceof Response) {
      try {
        const payload = await context.json();
        if (payload?.error) message = payload.error;
      } catch {
        // corpo não-JSON: mantém a mensagem original
      }
    }
    throw new Error(message);
  }

  return data as T;
}

/** Mensagem segura para Alert a partir de um erro desconhecido. */
export function errorMessage(err: unknown): string {
  return err instanceof Error ? err.message : 'Ocorreu um erro inesperado.';
}
