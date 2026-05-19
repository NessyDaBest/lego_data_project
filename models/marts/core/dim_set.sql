WITH maven_sets AS (
    SELECT
        s.id_set,
        s.nombre,
        t.nombre_tema,
        t.nombre_grupo_tematico,
        COALESCE(st.nombre_subtema, 'Sin subtema')   AS nombre_subtema,
        c.nombre_categoria
    FROM {{ ref('stg_maven_analytics__sets') }} s
    LEFT JOIN {{ ref('int_temas') }} t
        ON s.nombre_tema = t.nombre_tema
    LEFT JOIN {{ ref('int_subtemas') }} st
        ON s.nombre_subtema = st.nombre_subtema
        AND s.nombre_tema = st.nombre_tema
    LEFT JOIN {{ ref('int_categorias') }} c
        ON s.nombre_categoria = c.nombre_categoria
),

nuevos_sets AS (
    SELECT
        id_set,
        nombre,
        COALESCE(nombre_tema, 'No encontrado')  AS nombre_tema,
        'No encontrado'                          AS nombre_grupo_tematico,
        'Sin subtema'                            AS nombre_subtema,
        'Sin categorizar'                        AS nombre_categoria
    FROM {{ ref('stg_rebrickable__raw_nuevos_sets') }}
    WHERE id_set NOT IN (SELECT id_set FROM maven_sets)
)

SELECT * FROM maven_sets
UNION ALL
SELECT * FROM nuevos_sets