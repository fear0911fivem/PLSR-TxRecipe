export interface Building {
  buildingName: string;
  label: string;
  count: number;
}

export interface SelectResult {
  success: boolean;
  message?: string;
  apartmentId?: number;
  roomLabel?: number | string;
  buildingName?: string;
  floor?: number | string;
}

export type NuiAction =
  | { action: 'show'; buildings: Building[] }
  | { action: 'hide' };
