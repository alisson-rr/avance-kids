import { useEffect, useRef } from 'react';
import { useEditor, EditorContent } from '@tiptap/react';
import StarterKit from '@tiptap/starter-kit';
import Link from '@tiptap/extension-link';
import Image from '@tiptap/extension-image';
import TextAlign from '@tiptap/extension-text-align';
import {
  Bold,
  Italic,
  List,
  ListOrdered,
  AlignLeft,
  AlignCenter,
  AlignRight,
  Link as LinkIcon,
  ImagePlus,
} from 'lucide-react';
import styles from './RichTextEditor.module.css';

interface RichTextEditorProps {
  value: string;
  onChange: (html: string) => void;
}

export function RichTextEditor({ value, onChange }: RichTextEditorProps) {
  const fileInputRef = useRef<HTMLInputElement>(null);

  const editor = useEditor({
    extensions: [
      StarterKit,
      Link.configure({ openOnClick: false, autolink: true }),
      Image,
      TextAlign.configure({ types: ['heading', 'paragraph'] }),
    ],
    content: value,
    onUpdate: ({ editor }) => onChange(editor.getHTML()),
  });

  // Keep the editor in sync when `value` changes from outside (e.g. switching which row is being edited).
  useEffect(() => {
    if (!editor) return;
    if (value !== editor.getHTML()) {
      editor.commands.setContent(value, { emitUpdate: false });
    }
  }, [value, editor]);

  function setLink() {
    if (!editor) return;
    const previousUrl = editor.getAttributes('link').href as string | undefined;
    const url = window.prompt('URL do link:', previousUrl ?? '');
    if (url === null) return;
    if (url === '') {
      editor.chain().focus().extendMarkRange('link').unsetLink().run();
      return;
    }
    editor.chain().focus().extendMarkRange('link').setLink({ href: url }).run();
  }

  function handleImageFile(file: File | undefined) {
    if (!file || !file.type.startsWith('image/') || !editor) return;
    const reader = new FileReader();
    reader.onload = () => {
      editor.chain().focus().setImage({ src: reader.result as string }).run();
    };
    reader.readAsDataURL(file);
  }

  if (!editor) return null;

  return (
    <div className={styles.wrapper}>
      <div className={styles.toolbar}>
        <button
          type="button"
          className={editor.isActive('bold') ? styles.toolBtnActive : styles.toolBtn}
          onClick={() => editor.chain().focus().toggleBold().run()}
          title="Negrito"
        >
          <Bold size={16} />
        </button>
        <button
          type="button"
          className={editor.isActive('italic') ? styles.toolBtnActive : styles.toolBtn}
          onClick={() => editor.chain().focus().toggleItalic().run()}
          title="Itálico"
        >
          <Italic size={16} />
        </button>

        <span className={styles.divider} />

        <button
          type="button"
          className={editor.isActive('bulletList') ? styles.toolBtnActive : styles.toolBtn}
          onClick={() => editor.chain().focus().toggleBulletList().run()}
          title="Lista com marcadores"
        >
          <List size={16} />
        </button>
        <button
          type="button"
          className={editor.isActive('orderedList') ? styles.toolBtnActive : styles.toolBtn}
          onClick={() => editor.chain().focus().toggleOrderedList().run()}
          title="Lista numerada"
        >
          <ListOrdered size={16} />
        </button>

        <span className={styles.divider} />

        <button
          type="button"
          className={editor.isActive({ textAlign: 'left' }) ? styles.toolBtnActive : styles.toolBtn}
          onClick={() => editor.chain().focus().setTextAlign('left').run()}
          title="Alinhar à esquerda"
        >
          <AlignLeft size={16} />
        </button>
        <button
          type="button"
          className={editor.isActive({ textAlign: 'center' }) ? styles.toolBtnActive : styles.toolBtn}
          onClick={() => editor.chain().focus().setTextAlign('center').run()}
          title="Centralizar"
        >
          <AlignCenter size={16} />
        </button>
        <button
          type="button"
          className={editor.isActive({ textAlign: 'right' }) ? styles.toolBtnActive : styles.toolBtn}
          onClick={() => editor.chain().focus().setTextAlign('right').run()}
          title="Alinhar à direita"
        >
          <AlignRight size={16} />
        </button>

        <span className={styles.divider} />

        <button
          type="button"
          className={editor.isActive('link') ? styles.toolBtnActive : styles.toolBtn}
          onClick={setLink}
          title="Link"
        >
          <LinkIcon size={16} />
        </button>
        <button type="button" className={styles.toolBtn} onClick={() => fileInputRef.current?.click()} title="Inserir imagem">
          <ImagePlus size={16} />
        </button>
        <input
          ref={fileInputRef}
          type="file"
          accept="image/*"
          className={styles.hiddenInput}
          onChange={(e) => handleImageFile(e.target.files?.[0])}
        />
      </div>

      <EditorContent editor={editor} className={styles.content} />
    </div>
  );
}
