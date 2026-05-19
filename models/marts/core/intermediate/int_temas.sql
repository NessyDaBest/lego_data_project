WITH temas_maven AS (
    SELECT DISTINCT
        nombre_tema,
        nombre_grupo_tematico
    FROM {{ ref('stg_maven_analytics__sets') }}
    WHERE nombre_tema != 'Sin grupo'
),

temas_rebrickable AS (
    SELECT DISTINCT
        nombre_tema,
        'No encontrado' AS nombre_grupo_tematico
    FROM {{ ref('stg_rebrickable__raw_nuevos_sets') }}
    WHERE nombre_tema IS NOT NULL
    AND nombre_tema NOT IN (SELECT nombre_tema FROM temas_maven)
),

todos_temas AS (
    SELECT * FROM temas_maven
    UNION ALL
    SELECT * FROM temas_rebrickable
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['nombre_tema']) }} AS id_tema,
    nombre_tema,
    nombre_grupo_tematico
FROM todos_temas