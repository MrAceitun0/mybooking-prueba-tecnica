class ResultsDisplay {
  constructor() {
    this.amounts = [1, 2, 4, 8, 15, 30];
  }

  displayVehicles(vehicles, data, filters) {
    const tableBody = document.getElementById('vehicles-table-body');
    tableBody.innerHTML = '';

    if (vehicles.length === 0) {
      this.showNoVehiclesMessage();
      return;
    }

    this.displayAppliedFilters(data, filters);

    vehicles.forEach(vehicle => {
      const row = this.createVehicleRow(vehicle);
      tableBody.appendChild(row);
    });

    this.showVehiclesTable();
  }

  createVehicleRow(vehicle) {
    const row = document.createElement('tr');
    
    const categoryCell = document.createElement('th');
    categoryCell.scope = 'row';
    categoryCell.textContent = vehicle.name;
    row.appendChild(categoryCell);

    this.amounts.forEach(amount => {
      const cell = this.createPriceCell(vehicle, amount);
      row.appendChild(cell);
    });

    return row;
  }

  createPriceCell(vehicle, amount) {
    const cell = document.createElement('td');
    cell.className = 'text-right';
    
    const priceForAmount = vehicle.prices.find(price => price.amount === amount);
    
    if (priceForAmount) {
      cell.textContent = `${parseFloat(priceForAmount.price).toFixed(2)}€`;
    } else {
      cell.textContent = '-';
    }
    
    return cell;
  }

  displayAppliedFilters(data, filters) {
    const appliedFiltersContainer = document.getElementById('applied-filters');
    appliedFiltersContainer.innerHTML = '';

    const filterConfigs = [
      {
        key: 'selectedRentalLocation',
        dataKey: 'rentalLocations',
        label: 'Sucursal',
        colorClass: 'primary'
      },
      {
        key: 'selectedRateType',
        dataKey: 'rateTypes',
        label: 'Tipo de Tarifa',
        colorClass: 'success'
      },
      {
        key: 'selectedSeasonDefinition',
        dataKey: 'seasonDefinitions',
        label: 'Grupo de Temporadas',
        colorClass: 'warning',
        specialValue: 'none',
        specialLabel: 'Sin Temporadas',
        specialColorClass: 'secondary'
      },
      {
        key: 'selectedSeason',
        dataKey: 'seasons',
        label: 'Temporada',
        colorClass: 'info'
      },
      {
        key: 'selectedUnit',
        dataKey: 'units',
        label: 'Unidad',
        colorClass: 'dark'
      }
    ];

    filterConfigs.forEach(config => {
      const filterValue = filters[config.key];
      if (filterValue) {
        const filterDiv = this.createFilterBadge(config, filterValue, data);
        if (filterDiv) {
          appliedFiltersContainer.appendChild(filterDiv);
        }
      }
    });
  }

  createFilterBadge(config, filterValue, data) {
    let displayValue = '';
    let colorClass = config.colorClass;

    if (config.specialValue && filterValue === config.specialValue) {
      displayValue = config.specialLabel;
      colorClass = config.specialColorClass;
    } else {
      const dataArray = data[config.dataKey];
      if (dataArray) {
        const item = dataArray.find(item => item.id.toString() === filterValue);
        if (item) {
          displayValue = item.name;
        } else {
          return null; 
        }
      } else {
        return null; 
      }
    }

    const col = document.createElement('div');
    col.className = 'col-md-6 col-lg-4 mb-2';
    
    col.innerHTML = `
      <div class="d-flex align-items-center">
        <span class="badge bg-${colorClass} me-2">${config.label}</span>
        <span class="text-muted">${displayValue}</span>
      </div>
    `;
    
    return col;
  }

  showNoVehiclesMessage() {
    const noVehicles = document.getElementById('no-vehicles-message');
    if (noVehicles) {
      noVehicles.classList.remove('d-none');
    }
  }

  hideNoVehiclesMessage() {
    const noVehicles = document.getElementById('no-vehicles-message');
    if (noVehicles) {
      noVehicles.classList.add('d-none');
    }
  }

  showVehiclesTable() {
    const tableContainer = document.getElementById('vehicles-table-container');
    if (tableContainer) {
      tableContainer.classList.remove('d-none');
    }
  }

  hideVehiclesTable() {
    const tableContainer = document.getElementById('vehicles-table-container');
    if (tableContainer) {
      tableContainer.classList.add('d-none');
    }
  }

  clearVehiclesTable() {
    const tableBody = document.getElementById('vehicles-table-body');
    if (tableBody) {
      tableBody.innerHTML = '';
    }
    this.hideVehiclesTable();
    this.hideNoVehiclesMessage();
  }
}

window.ResultsDisplay = ResultsDisplay;