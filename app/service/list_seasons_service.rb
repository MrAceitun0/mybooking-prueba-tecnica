module Service
  class ListSeasonsService

    def retrieve
      sql = <<-SQL
        select
          s.id as season_id,
          s.name as season_name
        from seasons s;
      SQL

      Infraestructure::Query.run(sql)
    end

  end
end