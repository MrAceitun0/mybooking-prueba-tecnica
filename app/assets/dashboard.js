document.addEventListener('DOMContentLoaded', function() {
    
    $('select[name="rental_location"]').select2({
        theme: 'bootstrap-5'
    });
    $('select[name="rate_type"]').select2({
        theme: 'bootstrap-5'
    });
    $('select[name="season_definition_id"]').select2({
        theme: 'bootstrap-5'
    });
    $('select[name="season_id"]').select2({
        theme: 'bootstrap-5'
    });

    $('select[name="rate_type_id"], select[name="season_definition_id"], select[name="season_id"], select[name="duration_id"], .btn-primary').prop('disabled', true);

    $('#prices_table').dataTable({
        paging: true,
        searching: false,
        info: true
    });
});