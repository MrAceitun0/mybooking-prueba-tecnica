document.addEventListener('DOMContentLoaded', function() {
    
    const $rental_location_dropdown = $('select[name="rental_location_dropdown"]').select2({theme: 'bootstrap-5'});
    const $rate_type_dropdown  = $('select[name="rate_type_dropdown"]').select2({theme: 'bootstrap-5'});
    const $season_definition_dropdown  = $('select[name="season_definition_dropdown"]').select2({theme: 'bootstrap-5'});
    const $season_dropdown  = $('select[name="season_dropdown"]').select2({theme: 'bootstrap-5'});
    const $duration_dropdown  = $('select[name="duration_dropdown"]').select2({theme: 'bootstrap-5'});

    [$rate_type_dropdown,$season_definition_dropdown,$season_dropdown,$duration_dropdown]
        .forEach($el => $el.prop('disabled', true));
  
    fetch('/api/rental-locations')
        .then(result => result.json())
        .then(data => {
          fillOptions($rental_location_dropdown, data, 'Seleccione sucursal');
          $rental_location_dropdown.prop('disabled', false);
    });

    function fillOptions($select, rows, placeholder) {
        $select.empty().append(`<option value="">${placeholder}</option>`);
        rows.forEach(r => $select.append(`<option value="${r.id}">${r.name}</option>`));
        $select.trigger('change.select2');
      }

    function resetDownstream(selects) {
        selects.forEach($element => {
            $element.prop('disabled', true);
            $element.find('option:not(:first)').remove();
            $element.trigger('change.select2');
        });
        $duration_dropdown.prop('disabled', true);
    }

    $rental_location_dropdown.on('change', function() {
        selectedRentalLocationId = $(this).val();
        if (!selectedRentalLocationId) {
            resetDownstream([$rate_type_dropdown, $season_definition_dropdown, $season_dropdown]);
            return;
        }
    
        fetch(`/api/rate-types?rental-location-id=${selectedRentalLocationId}`)
          .then(result => result.json())
          .then(data => {
            fillOptions($rate_type_dropdown, data, 'Seleccione tipo de tarifa');
            $rate_type_dropdown.prop('disabled', false);
        });
    });
    
    $rate_type_dropdown.on('change', function() {
        if (!$(this).val()) {
            resetDownstream([$season_definition_dropdown, $season_dropdown]);
            return;
        }
    
        fetch(`/api/season-definitions`)
          .then(result => result.json())
          .then(data => {
            const seasonDefinitionsWithPlaceholder = data.map(x => ({
              id: x.season_definition_id,
              name: x.season_definition_name || 'Tarifas sin temporadas'
            }));
            fillOptionsWithExtras($season_definition_dropdown, seasonDefinitionsWithPlaceholder, 'Seleccione grupo de temporadas');
            $season_definition_dropdown.prop('disabled', false);
        });
    });

    $season_definition_dropdown.on('change', function() {
        if (!$(this).val()) {
            resetDownstream([$season_dropdown]);
            return;
        }

        fetch('/api/seasons')
          .then(result => result.json())
          .then(data => {
            fillOptions($season_dropdown, data, 'season_id', 'season_name', 'Seleccione temporada');
            $season_dropdown.prop('disabled', false);
        });
    });

    $season_dropdown.on('change', function() {
        if (!$(this).val()) {
            resetDownstream([$season_dropdown]);
            return;
        }
        $duration_dropdown.prop('disabled', false);
    });

    $('#prices_table').dataTable({
        paging: false,
        searching: false,
        info: false
    });
});