# Tarot Cotidiano Native

App nativa para iPhone y Android hecha con React Native y Expo.

## Que incluye

- Carta diaria revelable con estetica de tarot nocturno.
- 12 categorias: Animo, Foco, Calma, Disciplina, Autoestima, Gratitud, Valentia, Habitos, Creatividad, Resiliencia, Relaciones y Energia.
- 36 cartas originales con mensaje y pregunta de reflexion.
- Cartas guardadas.
- Compartir con el panel nativo del movil.
- Notificacion local diaria con hora configurable.
- Boton para probar notificacion.

## Probar

Instala dependencias:

```powershell
npm install
```

Arranca Expo:

```powershell
npm start
```

## Compilar

Android:

```powershell
npm run prebuild:android
npm run android
```

iOS requiere macOS para generar y compilar el proyecto nativo:

```powershell
npm run prebuild:ios
npm run ios
```
