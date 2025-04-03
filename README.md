# Cosmopatate

## Doing
quand je gather les ressources au début du programme, je sérialise la ressource en suivant sa création. À cause de ça, il n'y a aucune garantie que une ID de ressource existe au moment de la serialisation car elle peut tomber après dans l'ordre de gathering des ressources. Il faut séparer le truc en 2 étapes, d'abord le gathering et la lecture du header, puis la serialisation. Peut-être que la dite serialisation peut être faite au load de la ressource d'ailleurs, ce serait peut-être plus pertinent.
