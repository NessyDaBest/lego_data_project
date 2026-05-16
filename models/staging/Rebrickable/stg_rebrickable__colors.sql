WITH source AS (
    SELECT * FROM {{ source('rebrickable', 'colors') }}
),

renamed_and_casted AS (
    SELECT
        CAST(id AS INT) AS id_color,
        CAST(name AS VARCHAR) AS nombre_color,
        CAST(rgb AS VARCHAR) AS composicion_rgb,
        CAST(is_trans AS BOOLEAN) AS es_transparente

    FROM source
    where id_color not in (-1,9999)
)

SELECT * FROM renamed_and_casted