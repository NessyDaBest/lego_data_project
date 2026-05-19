WITH categorias AS (
    SELECT DISTINCT
        nombre_categoria
    FROM {{ ref('stg_maven_analytics__sets') }}
    WHERE nombre_categoria IS NOT NULL
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['nombre_categoria']) }} AS id_categoria,
    nombre_categoria
FROM categorias