module Service
    class ListPricesService
  
      def retrieve
  
        sql = <<-SQL
          select rl.name as rental_location_name,
                 rt.name as rate_type_name,
                 c.code as category_code, c.name as category_name,
                 pd.id price_definition_id
          from price_definitions pd
          join category_rental_location_rate_types crlrt on pd.id = crlrt.price_definition_id
          join rental_locations rl on crlrt.rental_location_id = rl.id
          join rate_types rt on crlrt.rate_type_id = rt.id
          join categories c on crlrt.category_id = c.id;
        SQL
  
        Infraestructure::Query.run(sql)
  
      end
  
    end
  end