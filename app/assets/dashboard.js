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
    this.setupEventListeners();
    await this.loadInitialData();
  }

  setupEventListeners() {
    this.uiManager.elements.rentalLocation.addEventListener('change', (e) => {
      this.handleRentalLocationChange(e.target.value);
    });

    this.uiManager.elements.rateType.addEventListener('change', (e) => {
      this.handleRateTypeChange(e.target.value);
    });

    this.uiManager.elements.seasonDefinition.addEventListener('change', (e) => {
      this.handleSeasonDefinitionChange(e.target.value);
    });

    this.uiManager.elements.season.addEventListener('change', (e) => {
      this.handleSeasonChange(e.target.value);
    });

    this.uiManager.elements.unit.addEventListener('change', (e) => {
      this.handleUnitChange(e.target.value);
    });

    this.uiManager.elements.nextBtn.addEventListener('click', () => {
      this.handleNextStep();
    });

    this.uiManager.elements.backBtn.addEventListener('click', () => {
      this.handlePreviousStep();
    });

    this.uiManager.elements.resetBtn.addEventListener('click', () => {
      this.handleReset();
    });

    this.uiManager.elements.submitBtn.addEventListener('click', () => {
      this.handleSubmit();
    });
  }

  async loadInitialData() {
    try {
      this.uiManager.setLoading('rental-locations', true);
      const [rentalLocationsData, unitsData] = await Promise.all([
        this.apiService.getRentalLocations(),
        this.apiService.getUnits()
      ]);
      
      this.data.rentalLocations = rentalLocationsData;
      this.data.units = unitsData;
      
      this.uiManager.populateSelect('rental-location', rentalLocationsData);
      this.uiManager.hideError();
    } catch (err) {
      this.uiManager.showError(err.message || 'Failed to load initial data');
    } finally {
      this.uiManager.setLoading('rental-locations', false);
    }
  }

  async handleRentalLocationChange(rentalLocationId) {
    this.stepManager.updateFilter('selectedRentalLocation', rentalLocationId);
    this.stepManager.resetDependentFilters('selectedRentalLocation');
    
    this.data.rateTypes = [];
    this.data.seasonDefinitions = [];
    
    this.uiManager.clearSelect('rate-type');
    this.uiManager.clearSelect('season-definition');
    this.uiManager.clearSelect('season');
    this.uiManager.clearSelect('unit');
    
    if (!rentalLocationId) {
      this.updateStep();
      return;
    }
    
    try {
      this.uiManager.setLoading('rateTypes', true);
      const rateTypesData = await this.apiService.getRateTypes(rentalLocationId);
      this.data.rateTypes = rateTypesData;
      this.uiManager.populateSelect('rate-type', rateTypesData);
      this.uiManager.hideError();
      
      if (this.stepManager.getCurrentStep() === 1) {
        this.stepManager.nextStep();
        this.updateStep();
      }
    } catch (err) {
      this.uiManager.showError(err.message || 'Failed to load rate types');
    } finally {
      this.uiManager.setLoading('rateTypes', false);
    }
  }

  async handleRateTypeChange(rateTypeId) {
    this.stepManager.updateFilter('selectedRateType', rateTypeId);
    this.stepManager.resetDependentFilters('selectedRateType');
    
    this.data.seasonDefinitions = [];
    
    this.uiManager.clearSelect('season-definition');
    this.uiManager.clearSelect('season');
    this.uiManager.clearSelect('unit');
    
    this.uiManager.elements.submitBtn.disabled = true;
    
    if (!rateTypeId || !this.stepManager.getFilters().selectedRentalLocation) {
      this.updateStep();
      return;
    }
    
    try {
      this.uiManager.setLoading('seasonDefinitions', true);
      const seasonDefinitionsData = await this.apiService.getSeasonDefinitions(
        this.stepManager.getFilters().selectedRentalLocation, 
        rateTypeId
      );
      this.data.seasonDefinitions = seasonDefinitionsData;
      this.uiManager.populateSelect('season-definition', seasonDefinitionsData);
      this.uiManager.hideError();
      
      if (this.stepManager.getCurrentStep() === 2) {
        this.stepManager.nextStep();
        this.updateStep();
      }
    } catch (err) {
      this.uiManager.showError(err.message || 'Failed to load season definitions');
    } finally {
      this.uiManager.setLoading('seasonDefinitions', false);
    }
  }

  async handleSeasonDefinitionChange(seasonDefinitionId) {
    this.stepManager.updateFilter('selectedSeasonDefinition', seasonDefinitionId);
    this.stepManager.resetDependentFilters('selectedSeasonDefinition');
    
    this.data.seasons = [];
    this.uiManager.clearSelect('season');
    
    this.uiManager.elements.submitBtn.disabled = true;
    
    if (!seasonDefinitionId || seasonDefinitionId === 'none') {
      if (this.stepManager.getCurrentStep() === 3) {
        this.stepManager.jumpToStep(5);
        this.updateStep();
        this.uiManager.populateSelect('unit', this.data.units);
      }
      return;
    }
    
    try {
      this.uiManager.setLoading('seasons', true);
      const seasonsData = await this.apiService.getSeasons(seasonDefinitionId);
      this.data.seasons = seasonsData;
      this.uiManager.populateSelect('season', seasonsData);
      this.uiManager.hideError();
      
      if (this.stepManager.getCurrentStep() === 3) {
        this.stepManager.nextStep();
        this.updateStep();
      }
    } catch (err) {
      this.uiManager.showError(err.message || 'Failed to load seasons');
    } finally {
      this.uiManager.setLoading('seasons', false);
    }
  }

  handleSeasonChange(seasonId) {
    this.stepManager.updateFilter('selectedSeason', seasonId);
    this.stepManager.resetDependentFilters('selectedSeason');
    
    this.uiManager.elements.submitBtn.disabled = true;
    
    if (this.stepManager.getCurrentStep() === 4) {
      this.stepManager.nextStep();
      this.updateStep();
      this.uiManager.populateSelect('unit', this.data.units);
    }
  }

  handleUnitChange(unitId) {
    this.stepManager.updateFilter('selectedUnit', unitId);
    
    if (unitId) {
      this.uiManager.elements.submitBtn.disabled = false;
    }
  }

  handleNextStep() {
    if (this.stepManager.nextStep()) {
      this.updateStep();
    }
  }

  handlePreviousStep() {
    if (this.stepManager.previousStep()) {
      this.updateStep();
    }
  }

  handleReset() {
    this.stepManager.resetToFirstStep();
    this.stepManager.resetFilters();
    this.data.rateTypes = [];
    this.data.seasonDefinitions = [];
    this.updateStep();
    this.uiManager.clearAllSelects();
    this.uiManager.hideError();
    this.resultsDisplay.clearVehiclesTable();
    this.uiManager.hideResultsSection();
    this.init();
  }

  async handleSubmit() {
    console.log('Pricing search submitted with filters:', this.stepManager.getFilters());
    
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

  updateStep() {
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