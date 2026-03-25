import { MantineProvider } from '@mantine/core';
import { cleanup, fireEvent, render, screen, waitFor } from '@testing-library/react';
import type { ReactNode } from 'react';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';

// ---------------------------------------------------------------------------
// Mock router
// ---------------------------------------------------------------------------
vi.mock('@tanstack/react-router', async (importOriginal) => {
  const actual = await importOriginal<typeof import('@tanstack/react-router')>();
  return {
    ...actual,
    createFileRoute: () => (opts: { component: unknown }) => opts,
    useNavigate: () => vi.fn(),
    useSearch: () => ({}),
  };
});

// ---------------------------------------------------------------------------
// Mock useChaos
// ---------------------------------------------------------------------------
const mockUseChaos = vi.fn();
vi.mock('../../hooks/useChaos', () => ({
  useChaos: () => mockUseChaos(),
}));

// ---------------------------------------------------------------------------
// Mock notifications
// ---------------------------------------------------------------------------
vi.mock('@mantine/notifications', () => ({
  notifications: { show: vi.fn() },
}));

// Import components AFTER mocks
import { ChaosActionCard, ChaosPage, ChaosResultCard } from './chaos';

function wrapper({ children }: { children: ReactNode }) {
  return <MantineProvider>{children}</MantineProvider>;
}

const defaultHook = {
  lastResult: null,
  isActing: false,
  error: null,
  killCharacter: vi.fn().mockResolvedValue(undefined),
  failQuest: vi.fn().mockResolvedValue(undefined),
  destroyArtifact: vi.fn().mockResolvedValue(undefined),
  drainXp: vi.fn().mockResolvedValue(undefined),
  clearResult: vi.fn(),
};

// ---------------------------------------------------------------------------
// ChaosResultCard
// ---------------------------------------------------------------------------

describe('ChaosResultCard', () => {
  afterEach(() => {
    cleanup();
  });

  it('renders kill_character result', () => {
    render(
      <ChaosResultCard
        result={{
          type: 'kill_character',
          result: { affected: { id: 1, name: 'Boromir', status: 'fallen' } },
        }}
      />,
      { wrapper },
    );
    expect(screen.getByTestId('result-card')).toBeInTheDocument();
    expect(screen.getByTestId('result-details')).toHaveTextContent('Boromir');
    expect(screen.getByTestId('result-details')).toHaveTextContent('fallen');
  });

  it('renders fail_quest result', () => {
    render(
      <ChaosResultCard
        result={{
          type: 'fail_quest',
          result: { affected: { id: 1, title: 'Destroy the Ring', status: 'failed' } },
        }}
      />,
      { wrapper },
    );
    expect(screen.getByTestId('result-details')).toHaveTextContent('Destroy the Ring');
    expect(screen.getByTestId('result-details')).toHaveTextContent('failed');
  });

  it('renders destroy_artifact result', () => {
    render(
      <ChaosResultCard
        result={{
          type: 'destroy_artifact',
          result: { affected: { id: 1, name: 'The One Ring', artifact_type: 'ring' } },
        }}
      />,
      { wrapper },
    );
    expect(screen.getByTestId('result-details')).toHaveTextContent('The One Ring');
    expect(screen.getByTestId('result-details')).toHaveTextContent('ring');
  });

  it('renders drain_xp result', () => {
    render(
      <ChaosResultCard
        result={{
          type: 'drain_xp',
          result: { characters_affected: 4, xp_drained: 2000 },
        }}
      />,
      { wrapper },
    );
    expect(screen.getByTestId('result-details')).toHaveTextContent('4');
    expect(screen.getByTestId('result-details')).toHaveTextContent('2000');
  });
});

// ---------------------------------------------------------------------------
// ChaosActionCard
// ---------------------------------------------------------------------------

describe('ChaosActionCard', () => {
  afterEach(() => {
    cleanup();
  });

  it('renders button with correct label', () => {
    render(
      <ChaosActionCard
        title="Kill Character"
        description="desc"
        buttonLabel="Kill Character"
        buttonColor="red"
        testId="kill-btn"
        disabled={false}
        onClick={vi.fn()}
      />,
      { wrapper },
    );
    expect(screen.getByTestId('kill-btn')).toBeInTheDocument();
    expect(screen.getByTestId('kill-btn')).toHaveTextContent('Kill Character');
  });

  it('disables button when disabled=true', () => {
    render(
      <ChaosActionCard
        title="Kill Character"
        description="desc"
        buttonLabel="Kill Character"
        buttonColor="red"
        testId="kill-btn"
        disabled={true}
        onClick={vi.fn()}
      />,
      { wrapper },
    );
    expect(screen.getByTestId('kill-btn')).toBeDisabled();
  });

  it('calls onClick when clicked', () => {
    const onClick = vi.fn();
    render(
      <ChaosActionCard
        title="Kill Character"
        description="desc"
        buttonLabel="Kill Character"
        buttonColor="red"
        testId="kill-btn"
        disabled={false}
        onClick={onClick}
      />,
      { wrapper },
    );
    fireEvent.click(screen.getByTestId('kill-btn'));
    expect(onClick).toHaveBeenCalledTimes(1);
  });
});

// ---------------------------------------------------------------------------
// ChaosPage
// ---------------------------------------------------------------------------

describe('ChaosPage', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  afterEach(() => {
    cleanup();
  });

  it('renders page title', () => {
    mockUseChaos.mockReturnValue(defaultHook);
    render(<ChaosPage />, { wrapper });
    expect(screen.getByText('CHAOS PANEL')).toBeInTheDocument();
  });

  it('renders all 4 action buttons', () => {
    mockUseChaos.mockReturnValue(defaultHook);
    render(<ChaosPage />, { wrapper });
    expect(screen.getByTestId('kill-character-button')).toBeInTheDocument();
    expect(screen.getByTestId('fail-quest-button')).toBeInTheDocument();
    expect(screen.getByTestId('destroy-artifact-button')).toBeInTheDocument();
    expect(screen.getByTestId('drain-xp-button')).toBeInTheDocument();
  });

  it('disables all buttons while isActing', () => {
    mockUseChaos.mockReturnValue({ ...defaultHook, isActing: true });
    render(<ChaosPage />, { wrapper });
    expect(screen.getByTestId('kill-character-button')).toBeDisabled();
    expect(screen.getByTestId('fail-quest-button')).toBeDisabled();
    expect(screen.getByTestId('destroy-artifact-button')).toBeDisabled();
    expect(screen.getByTestId('drain-xp-button')).toBeDisabled();
  });

  it('shows error alert on error', () => {
    mockUseChaos.mockReturnValue({ ...defaultHook, error: 'No eligible characters to kill' });
    render(<ChaosPage />, { wrapper });
    expect(screen.getByTestId('error-alert')).toBeInTheDocument();
    expect(screen.getByText('No eligible characters to kill')).toBeInTheDocument();
  });

  it('does not show error alert without error', () => {
    mockUseChaos.mockReturnValue(defaultHook);
    render(<ChaosPage />, { wrapper });
    expect(screen.queryByTestId('error-alert')).not.toBeInTheDocument();
  });

  it('shows result card when lastResult is set', () => {
    mockUseChaos.mockReturnValue({
      ...defaultHook,
      lastResult: {
        type: 'kill_character',
        result: { affected: { id: 1, name: 'Boromir', status: 'fallen' } },
      },
    });
    render(<ChaosPage />, { wrapper });
    expect(screen.getByTestId('result-card')).toBeInTheDocument();
  });

  it('does not show result card without lastResult', () => {
    mockUseChaos.mockReturnValue(defaultHook);
    render(<ChaosPage />, { wrapper });
    expect(screen.queryByTestId('result-card')).not.toBeInTheDocument();
  });

  it('calls killCharacter when kill button is clicked', async () => {
    const killCharacter = vi.fn().mockResolvedValue(undefined);
    mockUseChaos.mockReturnValue({ ...defaultHook, killCharacter });
    render(<ChaosPage />, { wrapper });
    fireEvent.click(screen.getByTestId('kill-character-button'));
    await waitFor(() => {
      expect(killCharacter).toHaveBeenCalledTimes(1);
    });
  });

  it('calls failQuest when fail-quest button is clicked', async () => {
    const failQuest = vi.fn().mockResolvedValue(undefined);
    mockUseChaos.mockReturnValue({ ...defaultHook, failQuest });
    render(<ChaosPage />, { wrapper });
    fireEvent.click(screen.getByTestId('fail-quest-button'));
    await waitFor(() => {
      expect(failQuest).toHaveBeenCalledTimes(1);
    });
  });

  it('calls destroyArtifact when destroy button is clicked', async () => {
    const destroyArtifact = vi.fn().mockResolvedValue(undefined);
    mockUseChaos.mockReturnValue({ ...defaultHook, destroyArtifact });
    render(<ChaosPage />, { wrapper });
    fireEvent.click(screen.getByTestId('destroy-artifact-button'));
    await waitFor(() => {
      expect(destroyArtifact).toHaveBeenCalledTimes(1);
    });
  });

  it('calls drainXp when drain-xp button is clicked', async () => {
    const drainXp = vi.fn().mockResolvedValue(undefined);
    mockUseChaos.mockReturnValue({ ...defaultHook, drainXp });
    render(<ChaosPage />, { wrapper });
    fireEvent.click(screen.getByTestId('drain-xp-button'));
    await waitFor(() => {
      expect(drainXp).toHaveBeenCalledTimes(1);
    });
  });
});
