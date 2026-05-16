with 

source as (

    select * from {{ source('rebrickable', 'parts') }}

),

renamed as (

    select
        CAST(part_num AS VARCHAR) AS id_pieza ,
        CAST(name AS VARCHAR) AS nombre_pieza,
        CAST(part_cat_id AS INT) AS id_categoria,
        CAST(part_material AS VARCHAR) AS material_pieza

    from source

)

select * from renamed