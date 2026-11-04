import { create } from 'zustand';

// Stub for ephemeral client-only state; server data belongs in TanStack Query.
type AppState = { ready: boolean; setReady: (ready: boolean) => void };

export const useAppStore = create<AppState>((set) => ({
  ready: false,
  setReady: (ready) => set({ ready }),
}));
