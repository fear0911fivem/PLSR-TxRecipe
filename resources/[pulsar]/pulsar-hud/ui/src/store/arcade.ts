import { create } from 'zustand'

interface TeamScore {
  current: number
  max: number
}

interface MatchInfo {
  matchEnd: number
  matchLabel: string
}

interface ArcadeState {
  showing: boolean
  matchInfo: MatchInfo
  team1: TeamScore
  team2: TeamScore
}

export const useArcadeStore = create<ArcadeState>()(() => ({
  showing: false,
  matchInfo: { matchEnd: 0, matchLabel: '' },
  team1: { current: 0, max: 25 },
  team2: { current: 0, max: 25 },
}))

export const arcadeHandlers: Record<string, (payload: Record<string, unknown>) => void> = {
  ARCADE_START_MATCH: (p) => useArcadeStore.setState({
    matchInfo: { matchEnd: p.end as number, matchLabel: p.gamemode as string },
    team1: { current: 0, max: p.objectiveMax as number },
    team2: { current: 0, max: p.objectiveMax as number },
  }),
  TEAM_1_ADD_OBJ: (p) => useArcadeStore.setState((s) => ({
    team1: { ...s.team1, current: s.team1.current + (p.amt as number) },
  })),
  TEAM_2_ADD_OBJ: (p) => useArcadeStore.setState((s) => ({
    team2: { ...s.team2, current: s.team2.current + (p.amt as number) },
  })),
}
