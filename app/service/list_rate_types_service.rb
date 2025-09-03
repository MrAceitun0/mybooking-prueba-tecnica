module Service
  class ListRateTypesService

    def retrieve
      sql = <<-SQL
        select distinct
          rt.id as rate_type_id,
          rt.name as rate_type_name
        from rate_types rt;
      SQL

      Infraestructure::Query.run(sql)
    end

  end
end
