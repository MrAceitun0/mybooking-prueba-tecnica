class UIManager {
  constructor() {
    this.elements = {
      rentalLocation: document.getElementById('rental-location'),
      rateType: document.getElementById('rate-type'),
      seasonDefinition: document.getElementById('season-definition'),
      season: document.getElementById('season'),
      unit: document.getElementById('unit'),
      
      nextBtn: document.getElementById('next-btn'),
      backBtn: document.getElementById('back-btn'),
      resetBtn: document.getElementById('reset-btn'),
      submitBtn: document.getElementById('submit-btn'),
      
      stepTitle: document.getElementById('step-title'),
      progressBar: document.getElementById('progress-bar'),
      
      resultsSection: document.getElementById('results-section'),
      loadingResults: document.getElementById('loading-results'),
      noVehiclesMessage: document.getElementById('no-vehicles-message'),
      vehiclesTableContainer: document.getElementById('vehicles-table-container'),
      vehiclesTableBody: document.getElementById('vehicles-table-body'),
      appliedFilters: document.getElementById('applied-filters'),
      
      errorAlert: document.getElementById('error-alert'),
      errorMessage: document.getElementById('error-message'),
      
      completedSelections: document.getElementById('completed-selections'),
      selectionsBadges: document.getElementById('selections-badges')
    };
  }

  updateStepProgress(currentStep, totalSteps) {
    const stepTitles = [
      'Selecciona una sucursal',
      'Selecciona un tipo de tarifa', 
      'Selecciona un grupo de temporadas',
      'Selecciona una temporada',
      'Selecciona una unidad'
    ];
    
    this.elements.stepTitle.textContent = stepTitles[currentStep - 1];
    
    const progress = (currentStep / totalSteps) * 100;
    this.elements.progressBar.style.width = `${progress}%`;
    this.elements.progressBar.setAttribute('aria-valuenow', currentStep);
  }

  updateStepVisibility(currentStep, totalSteps) {
    for (let i = 1; i <= totalSteps; i++) {
      const stepElement = document.getElementById(`step-${i}`);
      if (i === currentStep) {
        stepElement.classList.remove('d-none');
      } else {
        stepElement.classList.add('d-none');
      }
    }
  }

  updateButtonStates(currentStep, totalSteps, isNextDisabled) {
    this.elements.backBtn.disabled = currentStep === 1;
    
    if (currentStep < totalSteps) {
      this.elements.nextBtn.classList.remove('d-none');
      this.elements.submitBtn.classList.add('d-none');
      this.elements.nextBtn.disabled = isNextDisabled;
    } else {
      this.elements.nextBtn.classList.add('d-none');
      this.elements.submitBtn.classList.remove('d-none');
      this.elements.submitBtn.disabled = isNextDisabled;
    }
  }

  populateSelect(selectId, data, currentValue = '') {
    const select = document.getElementById(selectId);
    select.innerHTML = `<option value="">Select a ${selectId.replace('-', ' ')}</option>`;
    
    if (selectId === 'season-definition') {
      select.innerHTML += '<option value="none">Sin Temporadas</option>';
    }
    
    data.forEach(item => {
      const option = document.createElement('option');
      option.value = item.id.toString();
      option.textContent = item.name;
      select.appendChild(option);
    });
    
    if (currentValue) {
      select.value = currentValue;
    }
  }

  clearSelect(selectId) {
    const select = document.getElementById(selectId);
    select.innerHTML = `<option value="">Select a ${selectId.replace('-', ' ')}</option>`;
    if (selectId === 'season-definition') {
      select.innerHTML += '<option value="none">Sin Temporadas</option>';
    }
    select.value = '';
  }

  clearAllSelects() {
    ['rental-location', 'rate-type', 'season-definition', 'season', 'unit'].forEach(selectId => {
      this.clearSelect(selectId);
    });
  }

  setLoading(dataType, isLoading) {
    const loadingElement = document.getElementById(`${dataType.replace(/([A-Z])/g, '-$1').toLowerCase()}-loading`);
    if (loadingElement) {
      if (isLoading) {
        loadingElement.classList.remove('d-none');
      } else {
        loadingElement.classList.add('d-none');
      }
    }
  }

  showError(message) {
    this.elements.errorMessage.textContent = message;
    this.elements.errorAlert.classList.remove('d-none');
  }

  hideError() {
    this.elements.errorAlert.classList.add('d-none');
  }

  showResultsSection() {
    this.elements.resultsSection.classList.remove('d-none');
  }

  hideResultsSection() {
    this.elements.resultsSection.classList.add('d-none');
  }

  showLoading() {
    this.elements.loadingResults.classList.remove('d-none');
  }

  hideLoading() {
    this.elements.loadingResults.classList.add('d-none');
  }

  showNoVehiclesMessage() {
    this.elements.noVehiclesMessage.classList.remove('d-none');
  }

  hideNoVehiclesMessage() {
    this.elements.noVehiclesMessage.classList.add('d-none');
  }

  showVehiclesTable() {
    this.elements.vehiclesTableContainer.classList.remove('d-none');
  }

  hideVehiclesTable() {
    this.elements.vehiclesTableContainer.classList.add('d-none');
  }

  updateCompletedSelections(selections) {
    const completedSelections = selections.filter(s => s.value);
    
    if (completedSelections.length > 0) {
      this.elements.completedSelections.classList.remove('d-none');
      this.elements.selectionsBadges.innerHTML = completedSelections.map(selection => 
        `<span class="badge bg-secondary"><strong>${selection.label}:</strong> ${selection.value}</span>`
      ).join('');
    } else {
      this.elements.completedSelections.classList.add('d-none');
    }
  }
}

window.UIManager = UIManager;