WITH inventory_minifigs AS (
    SELECT * FROM {{ ref('stg_rebrickable__inventory_minifigs') }}
),

inventories AS (
    SELECT * FROM {{ ref('stg_rebrickable__inventories') }}
),

sets AS (
    SELECT id_set FROM {{ ref('dim_set') }}
),

joined AS (
    SELECT
        im.id_inventario,
        i.id_set,
        im.id_minifig,
        im.cantidad
    FROM inventory_minifigs im
    INNER JOIN inventories i
        ON im.id_inventario = i.id_inventario
    INNER JOIN sets s
        ON i.id_set = s.id_set
)

SELECT
    {{ dbt_utils.generate_surrogate_key([
        'id_inventario', 'id_minifig'
    ]) }}               AS id_fct_inventario_minifigs,
    id_set,
    id_minifig,
    cantidad            AS cantidad_minifiguras
FROM joined