WITH stg_maven_sets AS (
    SELECT
        id_set, 
        nombre,
        nombre_tema,
        nombre_subtema,
        nombre_categoria,
        nombre_grupo_tematico
        
    FROM {{ ref('stg_maven_analytics__sets') }}
)

SELECT * FROM stg_maven_sets