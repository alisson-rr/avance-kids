import { z } from "https://deno.land/x/zod@v3.22.4/mod.ts";

// === Enums ===
export const ExerciseLevelEnum = z.enum(["aquisicao", "generalizacao", "manutencao"]);
export const AttemptResultEnum = z.enum(["sem_ajuda", "ajuda_parcial", "ajuda_total"]);
export const PlanStatusEnum = z.enum(["ativo", "concluido", "bloqueado"]);
export const SubscriptionPlanEnum = z.enum(["free", "premium"]);

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
export const SubmitInitialAnswersSchema = z.object({
  child_id: z.string().uuid(),
  answers: z.array(z.object({
    question_id: z.string().uuid(),
    option_id: z.string().uuid(),
  })).min(1),
});

export const SubmitScreeningAnswersSchema = z.object({
  child_id: z.string().uuid(),
  skill_id: z.string().uuid(),
  answers: z.array(z.object({
    question_id: z.string().uuid(),
    option_id: z.string().uuid(),
  })).min(1),
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
