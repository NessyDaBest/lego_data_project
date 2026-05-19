WITH stg_minifiguras AS (
    SELECT
        id_minifig,
        nombre_minifig,
        numero_piezas,
        url_imagen
    FROM {{ ref('stg_rebrickable__minifigs') }}
)

SELECT * FROM stg_minifiguras