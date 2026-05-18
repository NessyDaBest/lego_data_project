WITH source AS (
    SELECT * FROM {{ source('rebrickable', 'inventory_minifigs') }}
),

renamed AS (
    SELECT
        CAST(inventory_id AS INT) AS id_inventario,
        CAST(fig_num AS VARCHAR) AS id_minifig,
        CAST(quantity AS INT) AS cantidad
    FROM source
)

SELECT * FROM renamed