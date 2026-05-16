-- tests/assert_anyo_lanzamiento_valido.sql
-- Este test fallará si encuentra algún set con un año anterior a 1949

SELECT 
    id_set, 
    nombre, 
    anyo_lanzamiento
FROM {{ ref('stg_maven_analytics__sets') }}
WHERE anyo_lanzamiento < 1949