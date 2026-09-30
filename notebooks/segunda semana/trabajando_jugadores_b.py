import os
import pandas as pd
from collections import defaultdict
import networkx as nx
import matplotlib.pyplot as plt

# relación: jugador -> lista de (club, temporada)
relacion = defaultdict(list)

def cargar_relacion(ruta, club):

    for archivo in os.listdir(ruta):
        if archivo.endswith(".csv"):

            # Extraemos temporada del nombre del fichero
            temporada = archivo.replace(".csv", "")

            df = pd.read_csv(os.path.join(ruta, archivo))

            for jugador in df["jugador"].dropna():
                relacion[jugador].append((club, temporada))

    print(dict(relacion))

cargar_relacion("../../datasets/atletico", "Club A")
cargar_relacion("../../datasets/barcelona", "Club B")

tabla = []

for jugador, valores in relacion.items():
    for club, temporada in valores:
        tabla.append([jugador, club, temporada])

df_relacion = pd.DataFrame(tabla, columns=["Jugador", "Club", "Temporada"])

print(df_relacion.head())

print(dict(relacion))

G = nx.Graph()

for jugador, valores in relacion.items():
    for club, temporada in valores:
        G.add_node(jugador, type="jugador")
        G.add_node(club, type="club")
        G.add_node(temporada, type="temporada")

        G.add_edge(jugador, club)
        G.add_edge(jugador, temporada)

plt.figure(figsize=(10,6))
nx.draw(G, with_labels=True, node_size=1500)
plt.show()

from collections import Counter

contador_temporadas = Counter()

for jugador, valores in relacion.items():
    temporadas = set([v[1] for v in valores])
    contador_temporadas[jugador] = len(temporadas)

# máximo
max_temporadas = max(contador_temporadas.values())

jugadores_top = [j for j, v in contador_temporadas.items() if v == max_temporadas]

print("Jugadores con más temporadas:", jugadores_top)
print("Número de temporadas:", max_temporadas)

club_a_rel = 0
club_b_rel = 0

for jugador, valores in relacion.items():
    for club, temporada in valores:
        if club == "Club A":
            club_a_rel += 1
        elif club == "Club B":
            club_b_rel += 1

print("Relaciones Club A:", club_a_rel)
print("Relaciones Club B:", club_b_rel)

if club_a_rel > club_b_rel:
    print("Club A es más denso")
elif club_b_rel > club_a_rel:
    print("Club B es más denso")
else:
    print("Ambos tienen la misma densidad")