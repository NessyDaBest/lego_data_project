import os
import sys
import requests
import pandas as pd
from snowflake.connector import connect
from datetime import datetime, timezone
from dotenv import load_dotenv

# ── Carga de variables de entorno ────────────────────────
load_dotenv()

REBRICKABLE_API_KEY = os.environ.get("REBRICKABLE_API_KEY")
BASE_URL = "https://rebrickable.com/api/v3/lego/sets/"

SF_CONFIG = {
    "account":   os.environ.get("SF_ACCOUNT"),
    "user":      os.environ.get("SF_USER"),
    "password":  os.environ.get("SF_PASSWORD"),
    "warehouse": os.environ.get("SF_WAREHOUSE"),
    "database":  os.environ.get("SF_DATABASE"),
    "schema":    os.environ.get("SF_SCHEMA"),
}

# ── Extracción de temas de Rebrickable ───────────────────
def fetch_themes() -> dict:
    """
    Devuelve un diccionario {theme_id: nombre_tema} con todos
    los temas de Rebrickable.
    """
    headers = {"Authorization": f"key {REBRICKABLE_API_KEY}"}
    params  = {"page_size": 1000}
    url     = "https://rebrickable.com/api/v3/lego/themes/"
    themes  = {}

    while url:
        response = requests.get(url, headers=headers, params=params)
        response.raise_for_status()
        data = response.json()
        for t in data["results"]:
            themes[t["id"]] = t["name"]
        url    = data.get("next")
        params = {}

    print(f"   Temas cargados: {len(themes)}")
    return themes

# ── Extracción paginada hasta encontrar sets nuevos ──────
def fetch_nuevos_sets(min_year: int, max_year: int, limit: int, existing: set) -> list[dict]:
    """
    Pagina por la API de Rebrickable hasta encontrar `limit` sets
    que no estén ya en Snowflake. Si se agotan las páginas sin
    encontrar suficientes, devuelve los que haya encontrado.
    """
    if not REBRICKABLE_API_KEY:
        raise ValueError("REBRICKABLE_API_KEY no está definida en credentials.env")

    headers = {"Authorization": f"key {REBRICKABLE_API_KEY}"}
    params  = {
        "min_year":  min_year,
        "max_year":  max_year,
        "page_size": 100,
        "ordering":  "year"
    }

    nuevos       = []
    pagina       = 1
    total_vistos = 0
    url          = BASE_URL

    while url and len(nuevos) < limit:
        print(f"   Consultando página {pagina}...")
        response = requests.get(url, headers=headers, params=params)
        response.raise_for_status()
        data    = response.json()
        results = data.get("results", [])
        total_vistos += len(results)

        for s in results:
            if s["set_num"] not in existing:
                nuevos.append(s)
            if len(nuevos) == limit:
                break

        url    = data.get("next")
        params = {}
        pagina += 1

    print(f"   Sets revisados: {total_vistos} | Sets nuevos encontrados: {len(nuevos)}")
    return nuevos


# ── Obtener set_num ya existentes en Snowflake ───────────
def get_existing_sets(cur) -> set:
    try:
        cur.execute("SELECT set_num FROM RAW_NUEVOS_SETS")
        return {row[0] for row in cur.fetchall()}
    except Exception:
        return set()


# ── Carga a Snowflake ────────────────────────────────────
def load_to_snowflake(sets: list[dict], themes: dict) -> None:
    if not sets:
        print("ℹ️  No se encontraron sets nuevos para cargar.")
        return

    loaded_at = datetime.now(timezone.utc).isoformat()

    df = pd.DataFrame(sets)[[
        "set_num", "name", "year", "theme_id", "num_parts", "set_img_url"
    ]]

    # Resuelve theme_id a nombre del tema
    df["nombre_tema"] = df["theme_id"].map(themes).fillna("No encontrado")
    df.drop(columns=["theme_id"], inplace=True)

    df["num_minifigs"] = None
    df["precio_usd"]   = None
    df["loaded_at"]    = loaded_at

    # Reordena columnas
    df = df[[
        "set_num", "name", "year", "nombre_tema",
        "num_parts", "num_minifigs", "precio_usd",
        "set_img_url", "loaded_at"
    ]]

    conn = connect(**SF_CONFIG)
    cur  = conn.cursor()

    cur.execute("""
        CREATE TABLE IF NOT EXISTS RAW_NUEVOS_SETS (
            set_num      VARCHAR,
            name         VARCHAR,
            year         NUMBER,
            nombre_tema  VARCHAR,
            num_parts    NUMBER,
            num_minifigs NUMBER,
            precio_usd   FLOAT,
            set_img_url  VARCHAR,
            loaded_at    TIMESTAMP_TZ
        )
    """)

    rows = [
        tuple(
            None if (isinstance(v, float) and pd.isna(v)) else v
            for v in row
        )
        for row in df.itertuples(index=False)
    ]

    cur.executemany("""
        INSERT INTO RAW_NUEVOS_SETS
            (set_num, name, year, nombre_tema, num_parts,
             num_minifigs, precio_usd, set_img_url, loaded_at)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
    """, rows)

    conn.commit()
    cur.close()
    conn.close()

    print(f"✅ {len(rows)} sets nuevos cargados en Snowflake")
    print(f"   Años:      {int(df['year'].min())}–{int(df['year'].max())}")
    print(f"   loaded_at: {loaded_at}")


# ── Main ─────────────────────────────────────────────────
if __name__ == "__main__":
    year  = int(sys.argv[1]) if len(sys.argv) > 1 else 2023
    limit = int(sys.argv[2]) if len(sys.argv) > 2 else 10

    print(f"🚀 Iniciando extracción | año: {year} | límite: {limit} sets nuevos")

    # Conexión temporal solo para consultar existentes
    conn_check = connect(**SF_CONFIG)
    cur_check  = conn_check.cursor()
    existing   = get_existing_sets(cur_check)
    cur_check.close()
    conn_check.close()

    print(f"   Sets ya en Snowflake: {len(existing)}")

    # Carga el diccionario de temas antes de extraer sets
    print("   Cargando temas de Rebrickable...")
    themes = fetch_themes()

    sets = fetch_nuevos_sets(
        min_year=year,
        max_year=year,
        limit=limit,
        existing=existing
    )

    if not sets:
        print(f"ℹ️  No quedan sets nuevos de {year} por cargar. Prueba con otro año.")
    else:
        load_to_snowflake(sets, themes)