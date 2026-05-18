WITH maven_sets AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['id_set']) }} AS id_fct_catalogo,
        id_set,
        anyo_lanzamiento,
        piezas_totales,
        mini_figuras_totales,
        precio_usd,
        edad_permitida,
        url_imagen,
        'maven_analytics'                                  AS fuente
    FROM {{ ref('stg_maven_analytics__sets') }}
),

nuevos_sets AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['id_set']) }} AS id_fct_catalogo,
        id_set,
        anyo_lanzamiento,
        piezas_totales,
        mini_figuras_totales,
        precio_usd,
        edad_permitida,
        url_imagen,
        'rebrickable'                                      AS fuente
    FROM {{ ref('stg_rebrickable__raw_nuevos_sets') }}
    WHERE id_set NOT IN (SELECT id_set FROM maven_sets)
)

SELECT * FROM maven_sets
UNION ALL
SELECT * FROM nuevos_sets