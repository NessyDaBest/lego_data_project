WITH maven_sets AS (
    SELECT
        id_set,
        nombre,
        nombre_tema,
        nombre_subtema,
        nombre_categoria,
        nombre_grupo_tematico
    FROM {{ ref('stg_maven_analytics__sets') }}
),

nuevos_sets AS (
    SELECT
        id_set,
        nombre,
        COALESCE(NULL::VARCHAR, 'No encontrado')   AS nombre_tema,
        COALESCE(NULL::VARCHAR, 'Sin subtema')     AS nombre_subtema,
        COALESCE(NULL::VARCHAR, 'Sin categorizar') AS nombre_categoria,
        COALESCE(NULL::VARCHAR, 'No encontrado')   AS nombre_grupo_tematico
    FROM {{ ref('stg_rebrickable__raw_nuevos_sets') }}
    WHERE id_set NOT IN (SELECT id_set FROM maven_sets)
)

SELECT * FROM maven_sets
UNION ALL
SELECT * FROM nuevos_sets