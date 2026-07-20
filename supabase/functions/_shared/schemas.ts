import { z } from "npm:zod@3.22.4";

// === Enums (espelham os tipos do banco e do frontend) ===
export const ExerciseLevelEnum = z.enum(["aquisicao", "generalizacao", "manutencao"]);
export const AttemptResultEnum = z.enum(["sem_ajuda", "ajuda_parcial", "ajuda_total"]);
export const PlanStatusEnum = z.enum(["ativo", "concluido", "bloqueado"]);
export const SubscriptionPlanEnum = z.enum(["free", "premium"]);
export const QuestionKindEnum = z.enum(["inicial", "triagem"]);
export const AdminRoleEnum = z.enum(["admin", "super_admin"]);

// === Cadastro ===
export const RegisterUserSchema = z.object({
  nome: z.string().min(2).max(200),
  data_nascimento: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
  genero: z.string().optional(),
  cpf: z.string().regex(/^\d{11}$/),
  telefone: z.string().optional(),
  termos_aceitos: z.literal(true),
});

export const RegisterChildSchema = z.object({
  nome: z.string().min(1).max(200),
  data_nascimento: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
  genero: z.string().optional(),
  cpf: z.string().regex(/^\d{11}$/).optional(),
  condicoes: z.array(z.string()).default([]),
});

// === Respostas ===
// Escala fixa (ANSWER_SCALE): 0 = Nunca/Não observei, 1 = Às vezes, 2 = Sempre.
// "Não observei" envia valor_numerico = 0 com nao_observado = true.
export const AnswerItemSchema = z.object({
  question_id: z.string().uuid(),
  valor_numerico: z.number().int().min(0).max(2),
  nao_observado: z.boolean().default(false),
});

export const SubmitInitialAnswersSchema = z.object({
  child_id: z.string().uuid(),
  answers: z.array(AnswerItemSchema).min(1),
});

export const SubmitScreeningAnswersSchema = z.object({
  child_id: z.string().uuid(),
  skill_id: z.string().uuid(),
  answers: z.array(AnswerItemSchema).min(1),
});

// === Exercícios ===
export const RegisterAttemptSchema = z.object({
  session_id: z.string().uuid(),
  plan_id: z.string().uuid(),
  repeticao_numero: z.number().int().min(1).max(10),
  resultado: AttemptResultEnum,
});

export const StartSessionSchema = z.object({
  plan_id: z.string().uuid(),
});

// === Stripe ===
export const CreateCheckoutSchema = z.object({
  price_id: z.string().min(1),
  success_url: z.string().url(),
  cancel_url: z.string().url(),
});

// === Admin ===
export const CreateAdminUserSchema = z.object({
  nome: z.string().min(2).max(200),
  email: z.string().email(),
  password: z.string().min(8),
  role: AdminRoleEnum.default("admin"),
});
