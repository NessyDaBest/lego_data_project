WITH inventory_parts AS (
    SELECT * FROM {{ ref('stg_rebrickable__inventory_parts') }}
),

inventories AS (
    SELECT * FROM {{ ref('stg_rebrickable__inventories') }}
),

sets AS (
    SELECT id_set FROM {{ ref('dim_set') }}
),

joined AS (
    SELECT
        ip.id_inventario,
        i.id_set,
        ip.id_pieza,
        ip.id_color,
        ip.cantidad,
        ip.es_repuesto
    FROM inventory_parts ip
    INNER JOIN inventories i
        ON ip.id_inventario = i.id_inventario
    INNER JOIN sets s
        ON i.id_set = s.id_set
)

SELECT
    {{ dbt_utils.generate_surrogate_key([
        'id_inventario', 'id_pieza', 'id_color', 'es_repuesto'
    ]) }}           AS id_fct_inventario_piezas,
    id_set,
    id_pieza,
    id_color,
    cantidad        AS cantidad_piezas,
    es_repuesto
FROM joined