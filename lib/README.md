# Organização do código

```text
lib/
  main.dart                 Inicialização e tratamento de falha de startup
  app/                      MaterialApp, tema e tela de falha de startup
  core/
    services/               Inicialização do Firebase
    data/                   Referência ao documento do usuário autenticado
  features/
    auth/presentation/      Tela de login
    home/presentation/      Catálogo e navegação inicial
    geography/
      data/repositories/    Catálogo Firestore e resultados das partidas
      data/services/        Cliente HTTP do IBGE
      domain/models/        Quiz, item e pergunta
      domain/utils/         Normalização de respostas
      presentation/screens/ Partida e resumo
      presentation/delegates/ Busca de jogos
    tasks/
      data/repositories/    Persistência de tarefas
      presentation/screens/ Tela de tarefas
    categories/presentation/ Lista de categorias
  examples/calculator/      Exercício de calculadora independente do app
```

Cada funcionalidade mantém suas telas em `presentation`, o acesso a serviços
externos em `data` e os modelos/regras sem dependência de Flutter ou Firebase em
`domain`. Funcionalidades pequenas, como login e categorias, só possuem as
camadas que usam hoje.

As telas chamam repositórios; somente os repositórios conhecem as coleções do
Firestore. `core` contém apenas infraestrutura compartilhada. A composição do
aplicativo fica em `app`. Os imports entre funcionalidades usam `package:basics/`.

O ponto de entrada continua sendo `lib/main.dart`, com a mesma configuração
`--dart-define-from-file=firebase-config.json`. O exercício de calculadora pode
ser aberto separadamente com `-t lib/examples/calculator/calculator_screen.dart`.
Ele foi preservado como exercício e ainda tem operações não implementadas.
