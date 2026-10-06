# Importar capitais para o Firestore

O aplicativo lê o documento compartilhado `quiz_catalog/capitais-do-brasil`.
O campo `capitals` é um objeto/mapa UF → capital; `states` é UF → nome da UF.
Título, descrição, dica e duração também ficam nesse documento. O Flutter não
contém a lista de capitais nem uma cópia de fallback. Alterações no documento
são lidas ao atualizar o catálogo ou iniciar uma partida.

`capitals.json` é somente o arquivo inicial de importação administrativa. Ele
não é um asset do app. O script busca nomes das UFs no IBGE e cria o documento.
Ele não sobrescreve um documento existente.

1. Publique as regras atualizadas de `../../firestore.rules` no Console Firebase.
   Usuários autenticados podem ler `quiz_catalog`, mas não gravar nele.
2. Configure credenciais administrativas locais. Se tiver Google Cloud CLI:

```powershell
gcloud auth application-default login
```

A conta precisa de acesso de gravação ao Firestore desse projeto. Alternativamente,
configure `GOOGLE_APPLICATION_CREDENTIALS` com o caminho de um arquivo de conta de
serviço local, mantido fora do projeto. Nunca envie esse arquivo ao chat nem ao app.
3. Nesta pasta, execute:

```powershell
npm install
npm run import
```

O projeto de destino vem de `../../firebase-config.json`. Depois, execute o app
normalmente e atualize o catálogo. No console, você pode editar o objeto `capitals`
sem modificar código nem importar novamente.

Jogos pessoais antigos de capitais ficam preservados em `users/{uid}/quizzes`,
mas o app passa a usar somente o documento compartilhado. Os jogos de estados e
regiões continuam em `users/{uid}/quizzes`.

O importador usa Firebase Admin com Application Default Credentials:
https://firebase.google.com/docs/admin/setup
