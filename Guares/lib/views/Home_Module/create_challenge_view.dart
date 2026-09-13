import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:guares/models/challenge_task_model.dart';
import 'package:guares/services/firestore_service.dart';
import 'package:guares/views/Home_Module/CreateChallenge/Bloc/create_challenge_bloc.dart';
import 'package:guares/views/Home_Module/CreateChallenge/Bloc/create_challenge_event.dart';
import 'package:guares/views/Home_Module/CreateChallenge/Bloc/create_challenge_state.dart';
import 'package:guares/views/Home_Module/widgets/app_top_bar.dart';
import 'package:guares/views/repositories/create_challenge_repository.dart';

class CreateChallengeView extends StatelessWidget {
  const CreateChallengeView({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => CreateChallengeRepository(
        firestoreService: FirestoreService.instance,
      ),
      child: BlocProvider(
        create: (context) => CreateChallengeBloc(
          repository: context.read<CreateChallengeRepository>(),
        ),
        child: const _CreateChallengeBody(),
      ),
    );
  }
}

class _CreateChallengeBody extends StatefulWidget {
  const _CreateChallengeBody();

  @override
  State<_CreateChallengeBody> createState() => _CreateChallengeBodyState();
}

class _CreateChallengeBodyState extends State<_CreateChallengeBody> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController(text: '30');
  final _xpController = TextEditingController(text: '100');
  final _taskController = TextEditingController();

  final List<ChallengeTaskModel> _tasks = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _xpController.dispose();
    _taskController.dispose();
    super.dispose();
  }

  void _addTask() {
    final title = _taskController.text.trim();

    if (title.isEmpty) {
      return;
    }

    setState(() {
      _tasks.add(
        ChallengeTaskModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          displayOrder: _tasks.length,
        ),
      );

      _taskController.clear();
    });
  }

  void _removeTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_tasks.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Add at least one task.')));
      return;
    }

    context.read<CreateChallengeBloc>().add(
      CreateChallengeSubmitted(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        durationDays: int.parse(_durationController.text.trim()),
        rewardXP: int.parse(_xpController.text.trim()),
        tasks: List<ChallengeTaskModel>.from(_tasks),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<CreateChallengeBloc, CreateChallengeState>(
          listener: (context, state) {
            if (state is CreateChallengeSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Challenge created successfully!'),
                ),
              );

              _formKey.currentState?.reset();

              _titleController.clear();
              _descriptionController.clear();
              _durationController.text = '30';
              _xpController.text = '100';
              _taskController.clear();

              setState(() {
                _tasks.clear();
              });
            }

            if (state is CreateChallengeError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppTopBar(),

                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Create Challenge',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 24),

                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Challenge Title',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter a challenge title.';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter a description.';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _durationController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Duration (days)',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  final days = int.tryParse(
                                    value?.trim() ?? '',
                                  );

                                  if (days == null || days <= 0) {
                                    return 'Invalid duration.';
                                  }

                                  return null;
                                },
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: TextFormField(
                                controller: _xpController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Reward XP',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  final xp = int.tryParse(value?.trim() ?? '');

                                  if (xp == null || xp < 0) {
                                    return 'Invalid XP.';
                                  }

                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        const Text(
                          'Challenge Tasks',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _taskController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter a task',
                                  border: OutlineInputBorder(),
                                ),
                                onSubmitted: (_) => _addTask(),
                              ),
                            ),

                            const SizedBox(width: 8),

                            IconButton(
                              onPressed: _addTask,
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        if (_tasks.isEmpty) const Text('No tasks added yet.'),

                        ..._tasks.asMap().entries.map((entry) {
                          final index = entry.key;
                          final task = entry.value;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(task.title),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _removeTask(index),
                              ),
                            ),
                          );
                        }),

                        const SizedBox(height: 24),

                        BlocBuilder<CreateChallengeBloc, CreateChallengeState>(
                          builder: (context, state) {
                            final isLoading = state is CreateChallengeLoading;

                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _submit,
                                child: isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Create Challenge'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
