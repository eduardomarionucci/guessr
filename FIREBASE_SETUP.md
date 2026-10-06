# Connect Firebase

1. In Firebase Console, select your project and open Project settings > Your apps.
   Register an app for the platform you run, if necessary.
2. Copy `firebase-config.example.json` to `firebase-config.json`. Fill in the
   FirebaseOptions values for that registered app. Use the appId and apiKey for
   the target platform; for web these are in the displayed firebaseConfig object.
   Never include a service account private key.
3. Enable Authentication > Sign-in method > Anonymous.
4. Open Firestore Database > Rules, paste `firestore.rules`, and click Publish.
   Alternatively: `firebase deploy --only firestore:rules --project YOUR_PROJECT_ID`.
5. From the `basics` directory:

```powershell
flutter pub get
flutter run --dart-define-from-file=firebase-config.json
```

Tasks are stored under `users/{uid}/tasks`, scores under `users/{uid}/games`.
Each anonymous session can access only its own data. The email/password form
is still a demonstration, not Firebase email/password authentication. Clearing
app data loses access to the anonymous session; permanent accounts are needed
for sharing data between devices. No existing Supabase data was migrated.

Documentation: https://firebase.google.com/docs/flutter/setup

## Jogos de geografia e API do IBGE

Na primeira abertura, o aplicativo cria `estados-do-brasil` e `regioes-do-brasil`
em `users/{uid}/quizzes`. Capitais são lidas do documento compartilhado
`quiz_catalog/capitais-do-brasil`. As partidas leem os documentos do Firestore, incluindo título,
tempo, pistas e respostas. A lista inicial só prepara documentos ausentes; nunca
substitui um jogo editado no console.

UFs e regiões são obtidas de
https://servicodados.ibge.gov.br/api/v1/localidades/estados?orderBy=nome.
As capitais são um objeto no Firestore, importado pelo script em `tools/firestore`: a API de localidades não
marca os municípios como capitais. O jogo de UFs inclui os 26 estados e o DF.

Publique as regras atualizadas para permitir leitura autenticada de `quiz_catalog`. A coleção dos jogos pessoais pertence ao usuário,
coberta por `users/{userId}/{document=**}`. Confirme que `firestore.rules` foi
publicado e o login anônimo está habilitado. A primeira carga requer conexão
com IBGE e Firestore; depois, o catálogo vem do Firestore. Cada sessão anônima
tem seus próprios jogos de estados e regiões. Para editar esses jogos, abra
`users → uid → quizzes → jogo → items`.
Para editar capitais, abra `quiz_catalog → capitais-do-brasil → capitals`.

Cada item tem `answer`, `clue` e `aliases` (lista opcional). O jogo aceita respostas
sem acentos, diferenças de maiúsculas e espaços extras. A pontuação fica em
`users/{uid}/games`, com `quiz` indicando o jogo. As respostas são visíveis ao
cliente, portanto esta estrutura é adequada a aprendizado, não a um ranking
competitivo com proteção contra fraude.


Para importar o objeto de capitais no banco, consulte
[tools/firestore/README.md](tools/firestore/README.md). O app não cria esse
objeto automaticamente; a importação requer credenciais administrativas.

O documento `quiz_catalog/capitais-do-brasil` foi criado no projeto `quiz-db89d`
em 5 de outubro de 2026, e as regras de leitura do catálogo foram publicadas.
Para esse projeto, não é necessário executar novamente a importação inicial.
