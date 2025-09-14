# Mybooking - Interview test

## Prerequesites

- Ruby 3.3.0
- MySQL or MariaDB

## Database

The file prueba_tecnica.sql is a dump of the db to be used.

## Preparing the environment
```
bundle install
````

Create an .env file at project root with the following variables

```ruby
COOKIE_SECRET="THE-COOKIE-SECRET"
DATABASE_URL="mysql://user:password@host:port/prueba_tecnica?encoding=UTF-8-MB4"
TEST_DATABASE_URL="mysql://user:password@host:port/prueba_tecnica_test?encoding=UTF-8-MB4"
```

## Running the application

```
bundle exec rackup
```

Then, you can open the browser and check

http://localhost:9292
http://localhost:9292/api/sample

## Running tests

The project uses rspec as testing library

Run all tests:
````
bundle exec rspec spec --format documentation
````

Run all unit tests:
````
bundle exec rspec spec/unit --format documentation
````

Run all E2E tests:
````
bundle exec rspec spec/e2e --format documentation
````

Run specific module:
````
bundle exec rspec spec/[module_name] --format documentation
````

Run specific file:
````
bundle exec rspec spec/[path_to_file] --format documentation
````

Tests can also be executed via Rake in Command Line - check Rakefile for all test execution options
````
rake test:unit
````

## Import Prices
The service allows to import vehicle prices massively via CSV files

Use the following command in zsh:
````
rake "import:prices[path/to/your/file.csv]"
````

CSV file must have the following clumnds
````
category_code,rental_location_name,rate_type_name,season_name,units,price,time_measurement
````

### Column Descriptions:

- **category_code**: category code for the vehicle - must exist in database
- **rental_location_name**: string - must exist in database
- **rate_type_name**: must exist in database - e.g. Estandard, Premium...
- **season_name**: can be empty - e.g. Alta, Baja, Media...
- **units**: amount of time - must be a positive integer
- **price**: positive float number
- **time_measurement**: e.g. 1=meses, 2=días, 3=horas, 4=minutos

### Ejemplo de CSV:

````
category_code,rental_location_name,rate_type_name,season_name,units,price,time_measurement
A,Barcelona,Estándar,Alta,1,60.00,2
A,Barcelona,Estándar,Alta,2,55.00,2
A,Barcelona,Estándar,Media,4,35.00,2
B,Barcelona,Estándar,Media-Baja,8,50.00,2
C,Barcelona,Estándar,,1,110.00,2
A,Menorca,Estándar,Baja,15,35.00,2
A1,Barcelona,Estándar,Alta,8,35.00,2
````

## Details

This is a sample application for Mybooking technical interview. 
It's a Ruby Sinatra webapp that uses bootstrap 5.0 as the css framework.

## Debugging

Install the extension rdbg and use this as lauch.json

````
{
    // Use IntelliSense para saber los atributos posibles.
    // Mantenga el puntero para ver las descripciones de los existentes atributos.
    // Para más información, visite: https://go.microsoft.com/fwlink/?linkid=830387
    "version": "0.2.0",
    "configurations": [
        {
            "type": "rdbg", // "rdbg" is the type of the debugger
            "name": "Debug Ruby Sinatra",
            "request": "attach",
            "debugPort": "1235",  // The same port as in the config.ru file
            "localfs": true       // To be able to debug the local files using breakpoints
        }
    ]
}
````

