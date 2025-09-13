class StepManager {
  constructor() {
    this.currentStep = 1;
    this.totalSteps = 5;
    this.filters = {
      selectedRentalLocation: '',
      selectedRateType: '',
      selectedSeasonDefinition: '',
      selectedSeason: '',
      selectedUnit: ''
    };
  }

  getCurrentStep() {
    return this.currentStep;
  }

  getTotalSteps() {
    return this.totalSteps;
  }

  getFilters() {
    return { ...this.filters };
  }

  updateFilter(filterName, value) {
    this.filters[filterName] = value;
  }

  resetFilters() {
    this.filters = {
      selectedRentalLocation: '',
      selectedRateType: '',
      selectedSeasonDefinition: '',
      selectedSeason: '',
      selectedUnit: ''
    };
  }

  resetDependentFilters(changedFilter) {
    switch (changedFilter) {
      case 'selectedRentalLocation':
        this.filters.selectedRateType = '';
        this.filters.selectedSeasonDefinition = '';
        this.filters.selectedSeason = '';
        this.filters.selectedUnit = '';
        break;
      case 'selectedRateType':
        this.filters.selectedSeasonDefinition = '';
        this.filters.selectedSeason = '';
        this.filters.selectedUnit = '';
        break;
      case 'selectedSeasonDefinition':
        this.filters.selectedSeason = '';
        this.filters.selectedUnit = '';
        break;
      case 'selectedSeason':
        this.filters.selectedUnit = '';
        break;
    }
  }

  isNextDisabled() {
    switch (this.currentStep) {
      case 1: 
        return !this.filters.selectedRentalLocation;
      case 2: 
        return !this.filters.selectedRateType;
      case 3: 
        return !this.filters.selectedSeasonDefinition;
      case 4: 
        return this.filters.selectedSeasonDefinition !== 'none' && !this.filters.selectedSeason;
      case 5: 
        return !this.filters.selectedUnit;
      default: 
        return true;
    }
  }

  nextStep() {
    if (this.currentStep < this.totalSteps) {
      this.currentStep++;
      return true;
    }
    return false;
  }

  previousStep() {
    if (this.currentStep > 1) {
      this.currentStep--;
      return true;
    }
    return false;
  }

  jumpToStep(step) {
    if (step >= 1 && step <= this.totalSteps) {
      this.currentStep = step;
    }
  }

  resetToFirstStep() {
    this.currentStep = 1;
  }

  getCompletedSelections(data) {
    const selections = [
      { 
        label: 'Rental Location', 
        value: this.getSelectedName(data.rentalLocations, this.filters.selectedRentalLocation), 
        step: 1 
      },
      { 
        label: 'Rate Type', 
        value: this.getSelectedName(data.rateTypes, this.filters.selectedRateType), 
        step: 2 
      },
      { 
        label: 'Season Definition', 
        value: this.getSelectedName(data.seasonDefinitions, this.filters.selectedSeasonDefinition) || 
               (this.filters.selectedSeasonDefinition === 'none' ? 'Sin Temporadas' : undefined), 
        step: 3 
      },
      { 
        label: 'Season', 
        value: this.getSelectedName(data.seasons, this.filters.selectedSeason), 
        step: 4 
      },
      { 
        label: 'Unit', 
        value: this.getSelectedName(data.units, this.filters.selectedUnit), 
        step: 5 
      },
    ];
    
    return selections.filter(s => s.step < this.currentStep);
  }

  getSelectedName(dataArray, selectedId) {
    if (!selectedId || !dataArray) return null;
    const item = dataArray.find(item => item.id.toString() === selectedId);
    return item ? item.name : null;
  }

  isReadyForSubmission() {
    return this.filters.selectedRentalLocation && 
           this.filters.selectedRateType && 
           this.filters.selectedUnit;
  }
}

window.StepManager = StepManager;