WITH source AS (
    SELECT * FROM {{ source('maven_analytics', 'sets') }}
),

transformed AS (
    SELECT
        CAST(set_id AS VARCHAR) AS id_set,

        CAST(name AS VARCHAR) AS nombre,
        CAST(year AS INT) AS anyo_lanzamiento,

        CAST(theme AS VARCHAR) AS nombre_tema,
        CAST(COALESCE(subtheme, 'Sin subtema') AS VARCHAR) AS nombre_subtema,
        CAST(category AS VARCHAR) AS nombre_categoria,
        CAST(COALESCE(themegroup, 'Sin grupo') AS VARCHAR) AS nombre_grupo_tematico,

        CAST(COALESCE(pieces, 0) AS INT) AS piezas_totales,
        CAST(COALESCE(minifigs, 0) AS INT) AS mini_figuras_totales,
        CAST(COALESCE(agerange_min, 10) AS INT) AS edad_permitida,
        CAST(us_retailprice AS FLOAT) AS precio_usd,

        CAST(brickseturl AS VARCHAR) AS url_brickset,
        CAST(thumbnailurl AS VARCHAR) AS url_miniatura,
        CAST(imageurl AS VARCHAR) AS url_imagen

    FROM source
)

SELECT * FROM transformed