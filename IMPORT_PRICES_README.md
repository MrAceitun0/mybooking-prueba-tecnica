# Importación Masiva de Precios

Este sistema permite importar precios masivamente desde archivos CSV.

## Formato del CSV

El archivo CSV debe tener las siguientes columnas:

```csv
category_code,rental_location_name,rate_type_name,season_name,units,price,time_measurement
```

### Descripción de columnas:

- **category_code**: Código de la categoría (vehículo) - debe existir en la base de datos
- **rental_location_name**: Nombre de la ubicación de alquiler - debe existir en la base de datos
- **rate_type_name**: Nombre del tipo de tarifa - debe existir en la base de datos - p.e. Estandard, Premium...
- **season_name**: Nombre de la temporada (opcional, puede estar vacío) - p.e. Alta, Baja, Media...
- **units**: Cantidad de unidades de tiempo (número entero positivo)
- **price**: Precio (número decimal no negativo)
- **time_measurement**: Medida de tiempo (1=meses, 2=días, 3=horas, 4=minutos) 

### Ejemplo de CSV:

```csv
category_code,rental_location_name,rate_type_name,season_name,units,price,time_measurement
A,Barcelona,Estándar,Alta,1,60.00,2
A,Barcelona,Estándar,Alta,2,55.00,2
A,Barcelona,Estándar,Media,4,35.00,2
B,Barcelona,Estándar,Media-Baja,8,50.00,2
C,Barcelona,Estándar,,1,110.00,2
A,Menorca,Estándar,Baja,15,35.00,2
A1,Barcelona,Estándar,Alta,8,35.00,2
```

## Uso

### Importar desde archivo CSV:

```zsh
rake "import:prices[path/to/your/file.csv]"
```