# Ashen Souls MVP (Bloque 7)

## Requisitos
- Flutter SDK estable (3.24+ recomendado)
- Android SDK para build Android
- Proyecto Supabase con el schema MVP

## Configuración rápida
1. Este repositorio ya deja los valores de este proyecto en `.env.example`.
2. Crea `.env` con esos valores:
   ```bash
   cp .env.example .env
   ```

## Ejecutar en debug
```bash
flutter pub get
flutter run
```

## Build Android (release)
```bash
flutter pub get
flutter build apk --release
```

## Nota Supabase
El MVP asume tablas y RPC ya disponibles, incluyendo (mínimo):
- `characters`, `character_stats`, `inventory_items`
- `world_progress`, `character_quest_states`, `quests_catalog`
- `nodes_catalog`, `enemies_catalog`, `bosses_catalog`
- RPC: `create_character_mvp`, `level_up_character`
- Opcionales con fallback: `set_character_bloodstain`, `recover_bloodstain_souls`

## Flujo MVP recomendado
1. Login/registro
2. Crear personaje
3. Hub → NPCs / Inventario / Equipo / Hoguera / Herrero / Quests
4. Mapa → Encounter → Combate
5. Victoria o Muerte → recuperación/respawn
6. Progresión: level up + mejoras de herrero + quests

## Checklist manual final MVP
- [ ] 1. Registro / login correcto
- [ ] 2. Sesión persistente tras reiniciar app
- [ ] 3. Carga de personaje activo al entrar
- [ ] 4. Creación de personaje sin errores
- [ ] 5. Hub carga datos y acciones principales
- [ ] 6. NPC dialogue abre desde hub/mapa
- [ ] 7. Quest log muestra quest, estado, stage y recompensa
- [ ] 8. Inventario carga items y estados vacíos
- [ ] 9. Equipo abre y vuelve al flujo
- [ ] 10. Hoguera restaura HP/stamina/estus
- [ ] 11. Mapa muestra nodo actual y conexiones
- [ ] 12. Encounter carga por nodo y permite pelear/retirarse
- [ ] 13. Combate normal funciona y consume recursos
- [ ] 14. Combate boss llega a resolución sin bloquearse
- [ ] 15. Victoria concede almas y retorna a mapa
- [ ] 16. Muerte envía a pantalla de derrota y respawn
- [ ] 17. Bloodstain se genera al morir
- [ ] 18. Recuperación de almas en nodo de bloodstain
- [ ] 19. Level up valida almas y sube atributo
- [ ] 20. Herrero valida materiales y mejora arma
- [ ] 21. Reward de jefe (almas/item/flag) aplicado
- [ ] 22. Navegación completa sin rutas rotas

## Pendientes reales para v1.1
- Tests unitarios para controllers/repositorios críticos
- Integración automatizada de rutas clave (GoRouter)
- Mensajería de errores aún más granular por código Supabase
- Balance fino por telemetría real (daño, souls, coste)
