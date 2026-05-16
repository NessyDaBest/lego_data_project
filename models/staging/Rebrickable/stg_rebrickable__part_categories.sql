with 

source as (

    select * from {{ source('rebrickable', 'part_categories') }}

),

renamed as (

    select
        CAST(id AS int) AS id_categoria,
        CAST(name AS VARCHAR) AS nombre_categoria

    from source

)

select * from renamed