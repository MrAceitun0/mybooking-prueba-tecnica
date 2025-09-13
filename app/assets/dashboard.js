class PricingDashboard {
  constructor() {
    this.apiService = new ApiService();
    this.uiManager = new UIManager();
    this.stepManager = new StepManager();
    this.resultsDisplay = new ResultsDisplay();
    
    this.data = {
      rentalLocations: [],
      rateTypes: [],
      seasonDefinitions: [],
      seasons: [],
      units: []
    };
    
    this.init();
  }

  async init() {
    this.loadEvents();
    await this.loadInitialData();
  }

  loadEvents() {
    const events = [
      ['rental-location', 'change', (e) => this.onFilterChange('rentalLocation', e.target.value)],
      ['rate-type', 'change', (e) => this.onFilterChange('rateType', e.target.value)],
      ['season-definition', 'change', (e) => this.onFilterChange('seasonDefinition', e.target.value)],
      ['season', 'change', (e) => this.onFilterChange('season', e.target.value)],
      ['unit', 'change', (e) => this.onFilterChange('unit', e.target.value)],
      ['next-btn', 'click', () => this.navigateStep(1)],
      ['back-btn', 'click', () => this.navigateStep(-1)],
      ['reset-btn', 'click', () => this.reset()],
      ['submit-btn', 'click', () => this.searchVehicles()]
    ];

    events.forEach(([id, event, handler]) => {
      document.getElementById(id).addEventListener(event, handler);
    });
  }

  async loadInitialData() {
    await this.loadData('rental-locations', async () => {
      const [rentalLocations, units] = await Promise.all([
        this.apiService.getRentalLocations(),
        this.apiService.getUnits()
      ]);
      
      this.data.rentalLocations = rentalLocations;
      this.data.units = units;
      this.uiManager.populateSelect('rental-location', rentalLocations);
    });
  }

  async onFilterChange(filterType, value) {
    const filterMap = {
      rentalLocation: 'selectedRentalLocation',
      rateType: 'selectedRateType', 
      seasonDefinition: 'selectedSeasonDefinition',
      season: 'selectedSeason',
      unit: 'selectedUnit'
    };

    const filterName = filterMap[filterType];
    this.stepManager.updateFilter(filterName, value);
    this.stepManager.resetDependentFilters(filterName);
    this.clearDependentSelects(filterType);
    this.disableSubmit();

    if (!value) {
      this.refreshUI();
      return;
    }

    await this.loadFilterData(filterType, value);
  }

  async loadFilterData(filterType, value) {
    const loaders = {
      rentalLocation: () => this.loadRateTypes(value),
      rateType: () => this.loadSeasonDefinitions(value),
      seasonDefinition: () => this.loadSeasons(value),
      season: () => this.jumpToUnitStep(),
      unit: () => this.enableSubmit()
    };

    const loader = loaders[filterType];
    if (loader) await loader();
  }

  async loadRateTypes(rentalLocationId) {
    await this.loadData('rateTypes', async () => {
      const rateTypes = await this.apiService.getRateTypes(rentalLocationId);
      this.data.rateTypes = rateTypes;
      this.uiManager.populateSelect('rate-type', rateTypes);
      this.advanceStepIf(1);
    });
  }

  async loadSeasonDefinitions(rateTypeId) {
    const { selectedRentalLocation } = this.stepManager.getFilters();
    if (!selectedRentalLocation) return;

    await this.loadData('seasonDefinitions', async () => {
      const seasonDefinitions = await this.apiService.getSeasonDefinitions(selectedRentalLocation, rateTypeId);
      this.data.seasonDefinitions = seasonDefinitions;
      this.uiManager.populateSelect('season-definition', seasonDefinitions);
      this.advanceStepIf(2);
    });
  }

  async loadSeasons(seasonDefinitionId) {
    if (seasonDefinitionId === 'none') {
      this.jumpToUnitStep();
      return;
    }

    await this.loadData('seasons', async () => {
      const seasons = await this.apiService.getSeasons(seasonDefinitionId);
      this.data.seasons = seasons;
      this.uiManager.populateSelect('season', seasons);
      this.advanceStepIf(3);
    });
  }

  jumpToUnitStep() {
    this.stepManager.jumpToStep(5);
    this.uiManager.populateSelect('unit', this.data.units);
    this.refreshUI();
  }

  enableSubmit() {
    this.uiManager.elements.submitBtn.disabled = false;
  }

  disableSubmit() {
    this.uiManager.elements.submitBtn.disabled = true;
  }

  clearDependentSelects(filterType) {
    const clearMap = {
      rentalLocation: ['rate-type', 'season-definition', 'season', 'unit'],
      rateType: ['season-definition', 'season', 'unit'],
      seasonDefinition: ['season', 'unit'],
      season: ['unit'],
      unit: []
    };

    clearMap[filterType]?.forEach(selectId => {
      this.uiManager.clearSelect(selectId);
    });

    if (filterType === 'rentalLocation') {
      this.data.rateTypes = [];
      this.data.seasonDefinitions = [];
    } else if (filterType === 'rateType') {
      this.data.seasonDefinitions = [];
    } else if (filterType === 'seasonDefinition') {
      this.data.seasons = [];
    }
  }

  async loadData(loadingType, dataLoader) {
    try {
      this.uiManager.setLoading(loadingType, true);
      await dataLoader();
      this.uiManager.hideError();
    } catch (err) {
      this.uiManager.showError(err.message || `Failed to load ${loadingType}`);
    } finally {
      this.uiManager.setLoading(loadingType, false);
    }
  }

  advanceStepIf(expectedStep) {
    if (this.stepManager.getCurrentStep() === expectedStep) {
      this.stepManager.nextStep();
      this.refreshUI();
    }
  }

  navigateStep(direction) {
    const moved = direction > 0 ? this.stepManager.nextStep() : this.stepManager.previousStep();
    if (moved) this.refreshUI();
  }

  async searchVehicles() {
    console.log('Searching vehicles with filters:', this.stepManager.getFilters());
    
    this.uiManager.showResultsSection();
    this.uiManager.showLoading();
    this.resultsDisplay.hideNoVehiclesMessage();
    this.resultsDisplay.hideVehiclesTable();
    
    try {
      const vehicles = await this.apiService.getVehicles(this.stepManager.getFilters());
      this.resultsDisplay.displayVehicles(vehicles, this.data, this.stepManager.getFilters());
    } catch (err) {
      console.error('Error fetching vehicles:', err);
      if (err.message.includes('404')) {
        this.resultsDisplay.showNoVehiclesMessage();
      } else {
        this.uiManager.showError(err.message || 'Error al buscar vehículos');
      }
    } finally {
      this.uiManager.hideLoading();
    }
  }

  reset() {
    this.stepManager.resetToFirstStep();
    this.stepManager.resetFilters();
    this.data.rateTypes = [];
    this.data.seasonDefinitions = [];
    this.refreshUI();
    this.uiManager.clearAllSelects();
    this.uiManager.hideError();
    this.resultsDisplay.clearVehiclesTable();
    this.uiManager.hideResultsSection();
    this.init();
  }

  refreshUI() {
    const currentStep = this.stepManager.getCurrentStep();
    const totalSteps = this.stepManager.getTotalSteps();
    
    this.uiManager.updateStepProgress(currentStep, totalSteps);
    this.uiManager.updateStepVisibility(currentStep, totalSteps);
    this.uiManager.updateButtonStates(currentStep, totalSteps, this.stepManager.isNextDisabled());
    
    const completedSelections = this.stepManager.getCompletedSelections(this.data);
    this.uiManager.updateCompletedSelections(completedSelections);
  }
}

document.addEventListener('DOMContentLoaded', () => {
  new PricingDashboard();
});