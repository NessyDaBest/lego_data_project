WITH source AS (
    SELECT * FROM {{ source('rebrickable', 'inventories') }}
),

renamed AS (
    SELECT
        CAST(id AS INT) AS id_inventario,
        CAST(version AS INT) AS version,
        CAST(set_num AS VARCHAR) AS id_set
    FROM source
)

SELECT * FROM renamed