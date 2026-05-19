WITH subtemas AS (
    SELECT DISTINCT
        nombre_subtema,
        nombre_tema
    FROM {{ ref('stg_maven_analytics__sets') }}
    WHERE nombre_subtema != 'Sin subtema'
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['nombre_subtema', 'nombre_tema']) }} AS id_subtema,
    nombre_subtema,
    nombre_tema
FROM subtemas