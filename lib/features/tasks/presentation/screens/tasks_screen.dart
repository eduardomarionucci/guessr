import 'package:flutter/material.dart';
import 'package:basics/features/tasks/data/repositories/tasks_repository.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});
  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _controller = TextEditingController();
  final _store = TasksRepository();
  late final Stream<List<Map<String, dynamic>>> _tasks = _store.watchTasks();
  bool _saving = false;

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível salvar a alteração.')),
        );
      }
    }
  }

  Future<void> _add() async {
    final title = _controller.text.trim();
    if (title.isEmpty || _saving) return;
    setState(() => _saving = true);
    await _run(() async {
      await _store.addTask(title);
      if (mounted && _controller.text.trim() == title) _controller.clear();
    });
    if (mounted) setState(() => _saving = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('TODO LIST'), centerTitle: true),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(labelText: 'Nova tarefa'),
                  onSubmitted: (_) => _add(),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _saving ? null : _add,
                child: const Icon(Icons.add),
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _tasks,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Não foi possível carregar as tarefas.'),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final tasks = snapshot.data!;
                if (tasks.isEmpty) {
                  return const Center(child: Text('Nenhuma tarefa.'));
                }
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final data = task;
                    return CheckboxListTile(
                      title: Text(data['title'] as String),
                      value: data['completed'] == true,
                      onChanged: (value) => _run(
                        () => _store.updateTask(
                          task['id'] as String,
                          value ?? false,
                        ),
                      ),
                      secondary: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () =>
                            _run(() => _store.deleteTask(task['id'] as String)),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
