import os
import pandas as pd

# -----------------------------
# 1. FUNCIÓN PARA LEER UN CLUB
# -----------------------------
def cargar_jugadores(ruta_carpeta):
    """
    Lee todos los CSV de una carpeta y devuelve un conjunto de jugadores únicos.
    """
    jugadores = set()

    for archivo in os.listdir(ruta_carpeta):
        if archivo.endswith(".csv"):
            ruta = os.path.join(ruta_carpeta, archivo)
            df = pd.read_csv(ruta)

            # Añadimos jugadores al conjunto (set elimina duplicados automáticamente)
            jugadores.update(df["jugador"].dropna().astype(str))

    return jugadores


# -----------------------------
# 2. CARGA DE DATOS
# -----------------------------
club_a = cargar_jugadores("./atletico")
club_b = cargar_jugadores("./barcelona")


# -----------------------------
# 3. ANÁLISIS BÁSICO
# -----------------------------
print("Jugadores únicos Club A:", len(club_a))
print("Jugadores únicos Club B:", len(club_b))

print("\nListado Club A (ordenado):")
print(sorted(club_a))

print("\nListado Club B (ordenado):")
print(sorted(club_b))


# -----------------------------
# 4. OPERACIONES DE CONJUNTOS
# -----------------------------

# Unión
union = club_a | club_b
print("\nUNIÓN:", len(union))

# Intersección
interseccion = club_a & club_b
print("\nINTERSECCIÓN:", len(interseccion))
print(sorted(interseccion))

# Diferencia A - B
solo_a = club_a - club_b
print("\nSOLO CLUB A:", len(solo_a))

# Diferencia B - A
solo_b = club_b - club_a
print("\nSOLO CLUB B:", len(solo_b))

# Diferencia simétrica
diferencia_simetrica = club_a ^ club_b
print("\nDIFERENCIA SIMÉTRICA:", len(diferencia_simetrica))

# Complemento de la intersección respecto al universo
complemento_interseccion = union - interseccion
print("\nCOMPLEMENTO INTERSECCIÓN:", len(complemento_interseccion))


# -----------------------------
# 5. ANÁLISIS FINAL
# -----------------------------

# porcentaje que ha jugado en ambos clubes
porcentaje_ambos = (len(interseccion) / len(union)) * 100
print(f"\n% jugadores en ambos clubes: {porcentaje_ambos:.2f}%")

# club con más jugadores exclusivos
if len(solo_a) > len(solo_b):
    print("\nClub A tiene más jugadores exclusivos")
elif len(solo_b) > len(solo_a):
    print("\nClub B tiene más jugadores exclusivos")
else:
    print("\nAmbos clubes tienen el mismo número de jugadores exclusivos")