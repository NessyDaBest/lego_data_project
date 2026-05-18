WITH stg_colores AS (
    SELECT
        id_color,
        nombre_color,
        composicion_rgb,
        es_transparente
    FROM {{ ref('stg_rebrickable__colors') }} 
)

SELECT * FROM stg_colores