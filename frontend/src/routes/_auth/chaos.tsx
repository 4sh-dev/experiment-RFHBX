import {
  Alert,
  Badge,
  Button,
  Card,
  Container,
  Group,
  SimpleGrid,
  Stack,
  Text,
  Title,
} from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { createFileRoute } from '@tanstack/react-router';
import { type ChaosActionResult, useChaos } from '../../hooks/useChaos';

export const Route = createFileRoute('/_auth/chaos')({
  component: ChaosPage,
});

// ---------------------------------------------------------------------------
// Result display
// ---------------------------------------------------------------------------

function formatResult(result: ChaosActionResult): { label: string; details: string } {
  switch (result.type) {
    case 'kill_character':
      return {
        label: 'Character killed',
        details: `${result.result.affected.name} is now ${result.result.affected.status}`,
      };
    case 'fail_quest':
      return {
        label: 'Quest failed',
        details: `"${result.result.affected.title}" — status: ${result.result.affected.status}`,
      };
    case 'destroy_artifact':
      return {
        label: 'Artifact destroyed',
        details: `${result.result.affected.name} (${result.result.affected.artifact_type}) has been obliterated`,
      };
    case 'drain_xp':
      return {
        label: 'XP drained',
        details: `${result.result.characters_affected} character(s) lost ${result.result.xp_drained} XP total`,
      };
  }
}

interface ResultCardProps {
  result: ChaosActionResult;
}

export function ChaosResultCard({ result }: ResultCardProps) {
  const { label, details } = formatResult(result);
  return (
    <Card shadow="sm" padding="md" radius="md" withBorder data-testid="result-card">
      <Group gap="sm" align="center">
        <Badge color="red" variant="filled" size="lg">
          CHAOS APPLIED
        </Badge>
        <Text fw={600}>{label}</Text>
      </Group>
      <Text mt="xs" c="dimmed" size="sm" data-testid="result-details">
        {details}
      </Text>
    </Card>
  );
}

// ---------------------------------------------------------------------------
// Chaos action card
// ---------------------------------------------------------------------------

interface ActionCardProps {
  title: string;
  description: string;
  buttonLabel: string;
  buttonColor: string;
  testId: string;
  disabled: boolean;
  onClick: () => void;
}

export function ChaosActionCard({
  title,
  description,
  buttonLabel,
  buttonColor,
  testId,
  disabled,
  onClick,
}: ActionCardProps) {
  return (
    <Card shadow="sm" padding="md" radius="md" withBorder>
      <Stack gap="sm">
        <Title order={5}>{title}</Title>
        <Text size="sm" c="dimmed">
          {description}
        </Text>
        <Button
          color={buttonColor}
          disabled={disabled}
          onClick={onClick}
          data-testid={testId}
          fullWidth
        >
          {buttonLabel}
        </Button>
      </Stack>
    </Card>
  );
}

// ---------------------------------------------------------------------------
// Page component
// ---------------------------------------------------------------------------

export function ChaosPage() {
  const { lastResult, isActing, error, killCharacter, failQuest, destroyArtifact, drainXp } =
    useChaos();

  async function handleKillCharacter() {
    await killCharacter();
    notifications.show({
      title: 'Chaos injected',
      message: 'A character has been slain.',
      color: 'red',
    });
  }

  async function handleFailQuest() {
    await failQuest();
    notifications.show({
      title: 'Chaos injected',
      message: 'A quest has been failed.',
      color: 'red',
    });
  }

  async function handleDestroyArtifact() {
    await destroyArtifact();
    notifications.show({
      title: 'Chaos injected',
      message: 'An artifact has been destroyed.',
      color: 'red',
    });
  }

  async function handleDrainXp() {
    await drainXp();
    notifications.show({
      title: 'Chaos injected',
      message: 'XP has been drained from the fellowship.',
      color: 'orange',
    });
  }

  return (
    <Container size="md">
      <Title order={2} mb="xs">
        CHAOS PANEL
      </Title>
      <Text c="dimmed" mb="md" size="sm">
        Inject failure scenarios for disaster recovery training. All actions are irreversible.
      </Text>

      {error && (
        <Alert color="red" title="Chaos injection failed" mb="md" data-testid="error-alert">
          {error}
        </Alert>
      )}

      {lastResult && (
        <Stack mb="md">
          <ChaosResultCard result={lastResult} />
        </Stack>
      )}

      <SimpleGrid cols={{ base: 1, sm: 2 }} spacing="md">
        <ChaosActionCard
          title="Kill Character"
          description="Sets a random non-fallen character to fallen, removing them from active service."
          buttonLabel="Kill Character"
          buttonColor="red"
          testId="kill-character-button"
          disabled={isActing}
          onClick={handleKillCharacter}
        />

        <ChaosActionCard
          title="Fail Quest"
          description="Fails a random active quest and returns its surviving members to idle."
          buttonLabel="Fail Quest"
          buttonColor="orange"
          testId="fail-quest-button"
          disabled={isActing}
          onClick={handleFailQuest}
        />

        <ChaosActionCard
          title="Destroy Artifact"
          description="Permanently destroys a random artifact — gone from the world forever."
          buttonLabel="Destroy Artifact"
          buttonColor="grape"
          testId="destroy-artifact-button"
          disabled={isActing}
          onClick={handleDestroyArtifact}
        />

        <ChaosActionCard
          title="Drain XP"
          description="Drains 50% XP from all non-fallen characters across the fellowship."
          buttonLabel="Drain XP"
          buttonColor="yellow"
          testId="drain-xp-button"
          disabled={isActing}
          onClick={handleDrainXp}
        />
      </SimpleGrid>
    </Container>
  );
}
