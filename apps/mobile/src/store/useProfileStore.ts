import { create } from 'zustand';

export interface Child {
  id: string;
  name: string;
  birthDate: string;
  gender: string;
  cpf: string;
  disorders: string[];
  isActive: boolean;
}

export interface ProfileStore {
  parentName: string;
  parentEmail: string;
  parentBirthDate: string;
  parentGender: string;
  parentCpf: string;
  parentPhone: string;
  children: Child[];
  setParentData: (data: Partial<ProfileStore>) => void;
  setActiveChild: (id: string) => void;
  updateChild: (id: string, data: Partial<Child>) => void;
}

export const useProfileStore = create<ProfileStore>((set) => ({
  parentName: 'Pedro Almeida',
  parentEmail: 'pedro@example.com',
  parentBirthDate: '1990-01-01',
  parentGender: 'Masculino',
  parentCpf: '123.456.789-00',
  parentPhone: '(11) 99999-9999',
  children: [
    { 
      id: '1', 
      name: 'Joãozinho', 
      birthDate: '2019-05-10', 
      gender: 'Masculino',
      cpf: '111.111.111-11',
      disorders: ['TDAH'],
      isActive: true 
    },
    { 
      id: '2', 
      name: 'Mariazinha', 
      birthDate: '2021-02-15', 
      gender: 'Feminino',
      cpf: '222.222.222-22',
      disorders: [],
      isActive: false 
    },
  ],
  setParentData: (data) => set((state) => ({ ...state, ...data })),
  setActiveChild: (id) => set((state) => ({
    children: state.children.map(child => ({
      ...child,
      isActive: child.id === id
    }))
  })),
  updateChild: (id, data) => set((state) => ({
    children: state.children.map(child => 
      child.id === id ? { ...child, ...data } : child
    )
  }))
}));
