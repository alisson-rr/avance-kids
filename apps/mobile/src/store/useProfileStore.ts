import { create } from 'zustand';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { fetchProfile } from '../services/auth';
import { listChildren } from '../services/children';
import { supabase } from '../lib/supabase';
import type { ChildRow } from '../types/db';
import { fromIsoDate } from '../utils/formatters';

export interface Child {
  id: string;
  name: string;
  /** ISO (aaaa-mm-dd), como no banco. Converter com fromIsoDate para exibir. */
  birthDate: string;
  gender: string;
  cpf: string;
  disorders: string[];
  avatarUrl: string;
  isActive: boolean;
  triagemCompleta: boolean;
  idadeBiologicaMeses: number | null;
  idadeGeralMeses: number | null;
}

const ACTIVE_CHILD_KEY = '@avancekids/activeChildId';

function mapChild(row: ChildRow, activeId: string | null, index: number): Child {
  return {
    id: row.id,
    name: row.nome,
    birthDate: row.data_nascimento,
    gender: row.genero ?? '',
    cpf: row.cpf ?? '',
    disorders: Array.isArray(row.condicoes) ? row.condicoes : [],
    avatarUrl: row.avatar_url ?? '',
    isActive: activeId ? row.id === activeId : index === 0,
    triagemCompleta: row.triagem_completa,
    idadeBiologicaMeses: row.idade_biologica_meses,
    idadeGeralMeses: row.idade_geral_meses,
  };
}

export interface ProfileStore {
  loaded: boolean;
  parentName: string;
  parentEmail: string;
  /** BR (dd/mm/aaaa), pronto para os inputs com maskDate. */
  parentBirthDate: string;
  parentGender: string;
  parentCpf: string;
  parentPhone: string;
  parentAvatarUrl: string;
  children: Child[];
  /** Carrega perfil + filhos do Supabase (chamar com sessão ativa). */
  loadAll: () => Promise<void>;
  refreshChildren: () => Promise<void>;
  setParentData: (data: Partial<ProfileStore>) => void;
  setActiveChild: (id: string) => void;
  updateChild: (id: string, data: Partial<Child>) => void;
  reset: () => void;
}

const EMPTY_STATE = {
  loaded: false,
  parentName: '',
  parentEmail: '',
  parentBirthDate: '',
  parentGender: '',
  parentCpf: '',
  parentPhone: '',
  parentAvatarUrl: '',
  children: [] as Child[],
};

export const useProfileStore = create<ProfileStore>((set, get) => ({
  ...EMPTY_STATE,

  loadAll: async () => {
    const [{ data: userData }, profile, childRows, activeId] = await Promise.all([
      supabase.auth.getUser(),
      fetchProfile(),
      listChildren(),
      AsyncStorage.getItem(ACTIVE_CHILD_KEY),
    ]);

    const validActiveId = childRows.some((c) => c.id === activeId) ? activeId : null;

    set({
      loaded: true,
      parentName: profile?.nome ?? '',
      parentEmail: userData.user?.email ?? '',
      parentBirthDate: fromIsoDate(profile?.data_nascimento),
      parentGender: profile?.genero ?? '',
      parentCpf: profile?.cpf ?? '',
      parentPhone: profile?.telefone ?? '',
      parentAvatarUrl: profile?.avatar_url ?? '',
      children: childRows.map((row, i) => mapChild(row, validActiveId, i)),
    });
  },

  refreshChildren: async () => {
    const childRows = await listChildren();
    const currentActive = get().children.find((c) => c.isActive)?.id ?? null;
    const validActiveId = childRows.some((c) => c.id === currentActive) ? currentActive : null;
    set({ children: childRows.map((row, i) => mapChild(row, validActiveId, i)) });
  },

  setParentData: (data) => set((state) => ({ ...state, ...data })),

  setActiveChild: (id) => {
    AsyncStorage.setItem(ACTIVE_CHILD_KEY, id).catch(() => {});
    set((state) => ({
      children: state.children.map((child) => ({ ...child, isActive: child.id === id })),
    }));
  },

  updateChild: (id, data) =>
    set((state) => ({
      children: state.children.map((child) =>
        child.id === id ? { ...child, ...data } : child,
      ),
    })),

  reset: () => set({ ...EMPTY_STATE }),
}));

export const selectActiveChild = (state: ProfileStore): Child | undefined =>
  state.children.find((c) => c.isActive) ?? state.children[0];
