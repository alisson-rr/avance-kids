import { useRef } from 'react';
import { ImagePlus, X } from 'lucide-react';
import styles from './ImageUploadField.module.css';

interface ImageUploadFieldProps {
  /** Data URL of the selected image, or empty string when none is set. */
  value: string;
  onChange: (dataUrl: string) => void;
}

export function ImageUploadField({ value, onChange }: ImageUploadFieldProps) {
  const inputRef = useRef<HTMLInputElement>(null);

  function handleFile(file: File | undefined) {
    if (!file || !file.type.startsWith('image/')) return;
    const reader = new FileReader();
    reader.onload = () => onChange(reader.result as string);
    reader.readAsDataURL(file);
  }

  return (
    <div className={styles.wrapper}>
      <input
        ref={inputRef}
        type="file"
        accept="image/*"
        className={styles.hiddenInput}
        onChange={(e) => handleFile(e.target.files?.[0])}
      />

      {value ? (
        <div className={styles.preview}>
          <img src={value} alt="Pré-visualização" className={styles.previewImage} />
          <div className={styles.previewActions}>
            <button type="button" className={styles.linkBtn} onClick={() => inputRef.current?.click()}>
              Trocar imagem
            </button>
            <button type="button" className={styles.removeBtn} onClick={() => onChange('')} title="Remover imagem">
              <X size={16} />
            </button>
          </div>
        </div>
      ) : (
        <button type="button" className={styles.dropzone} onClick={() => inputRef.current?.click()}>
          <ImagePlus size={24} />
          <span>Selecionar imagem</span>
        </button>
      )}
    </div>
  );
}
