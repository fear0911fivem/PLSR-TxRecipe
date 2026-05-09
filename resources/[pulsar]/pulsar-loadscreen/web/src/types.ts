export interface HandoverData {
  name?: string;
  priority?: number;
  priorityMessage?: string;
  [key: string]: unknown;
}

export interface LoadingState {
  completed: Record<string, boolean>;
  currentStage: string | null;
}

declare global {
  interface Window {
    nuiHandoverData?: HandoverData;
  }
}
