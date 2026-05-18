WITH source AS (
    SELECT * FROM {{ source('rebrickable', 'inventory_parts') }}
),

renamed AS (
    SELECT
        CAST(inventory_id AS INT) AS id_inventario,
        CAST(part_num AS VARCHAR) AS id_pieza,
        CAST(color_id AS INT) AS id_color,
        CAST(quantity AS INT) AS cantidad,
        CAST(is_spare AS BOOLEAN) AS es_repuesto
    FROM source
),
filtrado AS (
    SELECT * FROM renamed
    WHERE id_color NOT IN (-1, 9999)
)

SELECT * FROM filtrado