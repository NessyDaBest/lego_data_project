with 

source as (

    select * from {{ source('rebrickable', 'minifigs') }}

),

renamed as (

    select
        CAST(fig_num AS VARCHAR) AS id_minifig,
        CAST(name AS VARCHAR) AS nombre_minifig,
        CAST(num_parts AS INT) AS numero_piezas,
        CAST(img_url AS VARCHAR) AS url_imagen

    from source

)

select * from renamed