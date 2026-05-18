WITH stg_piezas AS (
    SELECT
        id_pieza,
        nombre_pieza,
        material_pieza,
        id_categoria
    FROM {{ ref('stg_rebrickable__parts') }}
),

stg_categorias AS (
    SELECT
        id_categoria,
        nombre_categoria AS nombre_categoria_pieza
    FROM {{ ref('stg_rebrickable__part_categories') }}
),

piezas_desnormalizadas AS (
    SELECT
        p.id_pieza,
        p.nombre_pieza,
        p.material_pieza,
        COALESCE(c.nombre_categoria_pieza, 'Sin Categoría') AS nombre_categoria_pieza
    FROM stg_piezas p
    LEFT JOIN stg_categorias c 
        ON p.id_categoria = c.id_categoria
)

SELECT * FROM piezas_desnormalizadas