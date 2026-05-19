WITH grupos AS (
    SELECT DISTINCT
        nombre_grupo_tematico
    FROM {{ ref('stg_maven_analytics__sets') }}
    WHERE nombre_grupo_tematico != 'Sin grupo'
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['nombre_grupo_tematico']) }} AS id_grupo_tematico,
    nombre_grupo_tematico
FROM grupos