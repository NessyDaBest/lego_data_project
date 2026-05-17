{% snapshot sets_snapshot_check %}
{{
    config(
      target_database="LEGO_" ~ env_var('DBT_ENVIRONMENTS', 'FAIL') ~ "_SILVER_DB",
      target_schema='snapshots',
      unique_key='id_set',
      strategy='check',
      check_cols=['precio_usd', 'nombre']
    )
}}

SELECT 
    id_set,
    nombre,
    precio_usd,
    anyo_lanzamiento
FROM {{ ref('stg_maven_analytics__sets') }}

{% endsnapshot %}