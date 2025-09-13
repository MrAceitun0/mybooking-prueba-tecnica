class ApiService {
  constructor() {
    this.baseUrl = '';
  }

  async fetchData(url) {
    const response = await fetch(url);
    if (!response.ok) {
      if (response.status === 404) {
        return [];
      }
      throw new Error(`Failed to fetch data: ${response.statusText}`);
    }
    return response.json();
  }

  async getRentalLocations() {
    return this.fetchData('/api/rental-locations');
  }

  async getRateTypes(rentalLocationId) {
    return this.fetchData(`/api/rate-types?rental-location-id=${rentalLocationId}`);
  }

  async getSeasonDefinitions(rentalLocationId, rateTypeId) {
    return this.fetchData(`/api/season-definitions?rental-location-id=${rentalLocationId}&rate-type-id=${rateTypeId}`);
  }

  async getSeasons(seasonDefinitionId) {
    return this.fetchData(`/api/seasons?season-definition-id=${seasonDefinitionId}`);
  }

  async getVehicles(filters) {
    const params = new URLSearchParams({
      'rental-location-id': filters.selectedRentalLocation,
      'rate-type-id': filters.selectedRateType,
      'unit-id': filters.selectedUnit
    });
    
    if (filters.selectedSeasonDefinition && filters.selectedSeasonDefinition !== 'none') {
      params.append('season-definition-id', filters.selectedSeasonDefinition);
    }
    
    if (filters.selectedSeason) {
      params.append('season-id', filters.selectedSeason);
    }
    
    return this.fetchData(`/api/vehicles?${params.toString()}`);
  }

  async getUnits() {
    return [
      { id: 1, name: 'Meses' },
      { id: 2, name: 'Días' },
      { id: 3, name: 'Horas' },
      { id: 4, name: 'Minutos' }
    ];
  }
}

window.ApiService = ApiService;