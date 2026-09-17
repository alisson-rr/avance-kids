import { useEffect, useState } from 'react';
import { Save } from 'lucide-react';
import { FormField, MediaThumb } from '../components/ui';
import { fetchHowToAnswer, saveHowToAnswer, type HowToAnswer } from '../services/howToAnswer';
import { youtubeId } from '../utils/youtube';
import styles from '../styles/crudLayout.module.css';

export function HowToAnswerScreen() {
  const [form, setForm] = useState<HowToAnswer>({ texto: '', videoUrl: '' });
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);
  const [saveError, setSaveError] = useState<string | null>(null);
  const [saved, setSaved] = useState(false);

  useEffect(() => {
    fetchHowToAnswer()
      .then(setForm)
      .catch((err) => setLoadError(err instanceof Error ? err.message : 'Falha ao carregar o conteúdo.'))
      .finally(() => setLoading(false));
  }, []);

  function update(key: keyof HowToAnswer, value: string) {
    setForm((prev) => ({ ...prev, [key]: value }));
    setSaved(false);
  }

  async function handleSave() {
    if (saving) return;
    setSaving(true);
    setSaveError(null);
    setSaved(false);
    try {
      await saveHowToAnswer(form);
      setSaved(true);
    } catch (err) {
      setSaveError(err instanceof Error ? err.message : 'Falha ao salvar.');
    } finally {
      setSaving(false);
    }
  }

  const error = loadError ?? saveError;

  return (
    <div className={styles.container}>
      <div className={styles.header}>
        <div>
          <h1 className={styles.title}>Como responder</h1>
          <p className={styles.subtitle}>
            Ajuda exibida no aplicativo ao registrar as repetições de qualquer atividade. Se os dois campos ficarem
            vazios, a opção não aparece.
          </p>
        </div>
        {/* Sem carga bem-sucedida, salvar gravaria campos vazios por cima do conteúdo atual. */}
        <button
          className={styles.primaryButton}
          onClick={handleSave}
          type="button"
          disabled={saving || loading || loadError !== null}
        >
          <Save size={20} />
          <span>{saving ? 'Salvando...' : 'Salvar'}</span>
        </button>
      </div>

      {error && (
        <p role="alert" className={styles.errorBanner}>
          {error}
        </p>
      )}
      {saved && (
        <p role="status" className={styles.successBanner}>
          Alterações salvas.
        </p>
      )}

      {loadError === null && (
        <div className={styles.formCard}>
          <div className={styles.formContent}>
            {loading ? (
              <p className={styles.subtitle}>Carregando...</p>
            ) : (
              <div className={styles.gridContainer}>
                <FormField label="Link do vídeo (YouTube)">
                  <input type="url" value={form.videoUrl} onChange={(e) => update('videoUrl', e.target.value)} />
                  {youtubeId(form.videoUrl) && (
                    <>
                      <MediaThumb size="large" mediaType="video" url={form.videoUrl} />
                      <span className={styles.previewNote}>Pré-visualização apenas demonstrativa</span>
                    </>
                  )}
                </FormField>

                <FormField label="Texto" fullWidth>
                  <textarea
                    rows={8}
                    maxLength={5000}
                    value={form.texto}
                    onChange={(e) => update('texto', e.target.value)}
                  />
                </FormField>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
