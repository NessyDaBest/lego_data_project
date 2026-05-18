{{ config(
    materialized='incremental',
    unique_key='id_set',
    incremental_strategy='merge'
) }}

WITH source AS (
    SELECT * FROM {{ source('rebrickable', 'raw_nuevos_sets') }}

    {% if is_incremental() %}
        WHERE loaded_at > (SELECT MAX(loaded_at) FROM {{ this }})
    {% endif %}
)

SELECT
    CAST(set_num AS VARCHAR)AS id_set,
    TRIM(CAST(name AS VARCHAR))AS nombre,
    CAST(year AS INT)AS anyo_lanzamiento,
    CAST(theme_id AS INT)AS id_tema_rebrickable,
    CAST(COALESCE(NULLIF(num_parts, 0), 0) AS INT)AS piezas_totales,
    CAST(COALESCE(num_minifigs, 0) AS INT)AS mini_figuras_totales,
    CAST(10 AS INT) AS edad_permitida,
    CAST(precio_usd AS FLOAT)AS precio_usd,
    CAST(set_img_url AS VARCHAR) AS url_imagen,
    CAST(loaded_at AS TIMESTAMP_TZ) AS loaded_at

FROM source