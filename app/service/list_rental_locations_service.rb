module Service
  class ListRentalLocationsService

    def retrieve
      sql = <<-SQL
        select distinct
          rl.id as rental_location_id,
          rl.name as rental_location_name
        from rental_locations rl
        join category_rental_location_rate_types crlrt on crlrt.rental_location_id = rl.id
        order by rl.name;
      SQL

      Infraestructure::Query.run(sql)
    end

  end
end