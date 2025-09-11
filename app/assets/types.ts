export interface RentalLocation {
  id: number;
  name: string;
}

export interface RateType {
  id: number;
  name: string;
}

export interface SeasonDefinition {
  id: number;
  name: string;
}

export interface Season {
  id: number;
  name: string;
  season_definition_id: number;
}

export type Unit = { id: number; name: string }; 

export interface PricingFilters {
  selectedRentalLocation: string;
  selectedRateType: string;
  selectedSeasonDefinition: string;
  selectedSeason: string;
  selectedUnit: string;
}

export interface LoadingStates {
  isLoadingBranches: boolean;
  isLoadingRateTypes: boolean;
  isLoadingSeasonDefinitions: boolean;
  isLoadingSeasons: boolean;
  isLoadingUnits: boolean;
}
