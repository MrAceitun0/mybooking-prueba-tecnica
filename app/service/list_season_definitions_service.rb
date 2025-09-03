module Service
  class ListSeasonDefinitionsService

    def retrieve
      sql = <<-SQL
        select distinct
          sd.id as season_definition_id,
          sd.name as season_definition_name
        from season_definitions sd;
      SQL

      Infraestructure::Query.run(sql)
    end

  end
end
