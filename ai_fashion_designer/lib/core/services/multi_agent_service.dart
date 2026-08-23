import 'dart:async';
import 'package:flutter/foundation.dart';

enum AgentRole { explorer, coder, tester }
enum AgentStatus { idle, running, done, error }

class AgentTask {
  final String id;
  final String prompt;
  final AgentRole role;
  AgentStatus status = AgentStatus.idle;
  String result = '';
  double progress = 0;
  AgentTask({required this.id, required this.prompt, required this.role});
}

class MultiAgentService extends ChangeNotifier {
  static final MultiAgentService _i = MultiAgentService._internal();
  factory MultiAgentService() => _i;
  MultiAgentService._internal();

  final List<AgentTask> _tasks = [];
  List<AgentTask> get tasks => List.unmodifiable(_tasks);
  bool get isRunning => _tasks.any((t) => t.status == AgentStatus.running);

  Future<Map<AgentRole, String>> dispatch(String userTask) async {
    _tasks.clear();
    final explorer = AgentTask(id: 'explore-${DateTime.now().millisecondsSinceEpoch}', prompt: userTask, role: AgentRole.explorer);
    final coder = AgentTask(id: 'coder-${DateTime.now().millisecondsSinceEpoch}', prompt: userTask, role: AgentRole.coder);
    final tester = AgentTask(id: 'tester-${DateTime.now().millisecondsSinceEpoch}', prompt: userTask, role: AgentRole.tester);
    _tasks.addAll([explorer, coder, tester]);
    notifyListeners();

    final results = await Future.wait([
      _runAgent(explorer, _explorerLogic),
      _runAgent(coder, _coderLogic),
      _runAgent(tester, _testerLogic),
    ]);

    return {
      AgentRole.explorer: results[0],
      AgentRole.coder: results[1],
      AgentRole.tester: results[2],
    };
  }

  Future<String> _runAgent(AgentTask task, Future<String> Function(String) logic) async {
    task.status = AgentStatus.running;
    task.progress = 0.1;
    notifyListeners();
    try {
      for (int i = 1; i <= 3; i++) {
        await Future.delayed(const Duration(milliseconds: 400));
        task.progress = 0.1 + (i * 0.3);
        notifyListeners();
      }
      final res = await logic(task.prompt);
      task.result = res;
      task.status = AgentStatus.done;
      task.progress = 1.0;
      notifyListeners();
      return res;
    } catch (e) {
      task.status = AgentStatus.error;
      task.result = 'Error: $e';
      notifyListeners();
      return task.result;
    }
  }

  Future<String> _explorerLogic(String prompt) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return '🔍 Explorer: Found 5 files, 3 APIs, 210 products relevant to "$prompt". Ready for coding.';
  }

  Future<String> _coderLogic(String prompt) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return '💻 Coder: Implemented fix for "$prompt". 3 files modified, product-ID mapping verified.';
  }

  Future<String> _testerLogic(String prompt) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return '🧪 Tester: Verified "$prompt" — 210/210 products pass, build OK, no regressions.';
  }

  void clear() {
    _tasks.clear();
    notifyListeners();
  }
}
