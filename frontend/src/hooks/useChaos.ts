import { useCallback, useState } from 'react';
import { api } from '../lib/api';
import {
  type ChaosActionResult,
  type ChaosDestroyArtifactResult,
  type ChaosDrainXpResult,
  type ChaosFailQuestResult,
  type ChaosKillResult,
  chaosDestroyArtifactResultSchema,
  chaosDrainXpResultSchema,
  chaosFailQuestResultSchema,
  chaosKillResultSchema,
} from '../schemas/chaos';

export interface UseChaosResult {
  lastResult: ChaosActionResult | null;
  isActing: boolean;
  error: string | null;
  killCharacter: () => Promise<void>;
  failQuest: () => Promise<void>;
  destroyArtifact: () => Promise<void>;
  drainXp: () => Promise<void>;
  clearResult: () => void;
}

export function useChaos(): UseChaosResult {
  const [lastResult, setLastResult] = useState<ChaosActionResult | null>(null);
  const [isActing, setIsActing] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const clearResult = useCallback(() => {
    setLastResult(null);
    setError(null);
  }, []);

  const killCharacter = useCallback(async () => {
    setIsActing(true);
    setError(null);
    try {
      const response = await api.post<unknown>('/api/v1/chaos/kill_character');
      const result = chaosKillResultSchema.parse(response.data);
      setLastResult({ type: 'kill_character', result });
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Failed to kill character');
    } finally {
      setIsActing(false);
    }
  }, []);

  const failQuest = useCallback(async () => {
    setIsActing(true);
    setError(null);
    try {
      const response = await api.post<unknown>('/api/v1/chaos/fail_quest');
      const result = chaosFailQuestResultSchema.parse(response.data);
      setLastResult({ type: 'fail_quest', result });
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Failed to fail quest');
    } finally {
      setIsActing(false);
    }
  }, []);

  const destroyArtifact = useCallback(async () => {
    setIsActing(true);
    setError(null);
    try {
      const response = await api.post<unknown>('/api/v1/chaos/destroy_artifact');
      const result = chaosDestroyArtifactResultSchema.parse(response.data);
      setLastResult({ type: 'destroy_artifact', result });
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Failed to destroy artifact');
    } finally {
      setIsActing(false);
    }
  }, []);

  const drainXp = useCallback(async () => {
    setIsActing(true);
    setError(null);
    try {
      const response = await api.post<unknown>('/api/v1/chaos/drain_xp');
      const result = chaosDrainXpResultSchema.parse(response.data);
      setLastResult({ type: 'drain_xp', result });
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Failed to drain XP');
    } finally {
      setIsActing(false);
    }
  }, []);

  return {
    lastResult,
    isActing,
    error,
    killCharacter,
    failQuest,
    destroyArtifact,
    drainXp,
    clearResult,
  };
}
