module Service
  class ListRentalLocationsService

    def retrieve
      sql = <<-SQL
        select distinct
          rl.id as rental_location_id,
          rl.name as rental_location_name
        from rental_locations rl;
      SQL

      Infraestructure::Query.run(sql)
    end

  end
end