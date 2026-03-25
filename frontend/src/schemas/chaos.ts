import { z } from 'zod';

// ---------------------------------------------------------------------------
// Chaos injection result schemas
// ---------------------------------------------------------------------------

export const chaosKillResultSchema = z.object({
  affected: z.object({
    id: z.number(),
    name: z.string(),
    status: z.string(),
  }),
});

export const chaosFailQuestResultSchema = z.object({
  affected: z.object({
    id: z.number(),
    title: z.string(),
    status: z.string(),
  }),
});

export const chaosDestroyArtifactResultSchema = z.object({
  affected: z.object({
    id: z.number(),
    name: z.string(),
    artifact_type: z.string(),
  }),
});

export const chaosDrainXpResultSchema = z.object({
  characters_affected: z.number(),
  xp_drained: z.number(),
});

export type ChaosKillResult = z.infer<typeof chaosKillResultSchema>;
export type ChaosFailQuestResult = z.infer<typeof chaosFailQuestResultSchema>;
export type ChaosDestroyArtifactResult = z.infer<typeof chaosDestroyArtifactResultSchema>;
export type ChaosDrainXpResult = z.infer<typeof chaosDrainXpResultSchema>;

export type ChaosActionResult =
  | { type: 'kill_character'; result: ChaosKillResult }
  | { type: 'fail_quest'; result: ChaosFailQuestResult }
  | { type: 'destroy_artifact'; result: ChaosDestroyArtifactResult }
  | { type: 'drain_xp'; result: ChaosDrainXpResult };
