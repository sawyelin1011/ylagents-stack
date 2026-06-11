import 'dart:convert';
import '../../models/agent.dart';
import '../../models/agent_team.dart';
import '../../models/execution_trace.dart';

/// Represents a message passed between agents during orchestration.
class AgentMessage {
  final String fromAgentId;
  final String fromAgentName;
  final String toAgentId;
  final String toAgentName;
  final MessageType type;
  final String content;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;

  const AgentMessage({
    required this.fromAgentId,
    required this.fromAgentName,
    required this.toAgentId,
    required this.toAgentName,
    required this.type,
    required this.content,
    this.metadata,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Types of messages exchanged in agent communication.
enum MessageType {
  /// A task assignment from Lead → Manager or Manager → Worker
  taskAssignment,

  /// A result report from Worker → Manager or Manager → Lead
  resultReport,

  /// Status update during execution
  statusUpdate,

  /// Error notification
  error,

  /// Approval request
  approvalRequest,

  /// Approval response
  approvalResponse;

  String toJson() => name;
  static MessageType fromJson(String value) {
    return MessageType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MessageType.statusUpdate,
    );
  }
}

/// Defines the communication protocol and routing rules for agent messaging.
///
/// Architecture:
/// ```
/// User
///   │
///   ▼
/// Lead Agent ──► Manager Agent ──► Worker Agent 1
///   │                                  │
///   └──────────────────────────────────┘ (results flow back up)
/// ```
///
/// Rules:
/// - Workers never communicate directly with each other
/// - Workers communicate only with their Manager
/// - Manager communicates with Lead and Workers
/// - Lead communicates only with Manager (or Workers directly in simple cases)
class AgentCommunication {
  /// Build an execution step representing a message exchange between agents.
  ExecutionStep buildMessageStep({
    required AgentMessage message,
    required StepStatus status,
  }) {
    final iconType = switch (message.type) {
      MessageType.taskAssignment => StepType.delegate,
      MessageType.resultReport => StepType.execute,
      MessageType.statusUpdate => StepType.execute,
      MessageType.error => StepType.execute,
      MessageType.approvalRequest => StepType.delegate,
      MessageType.approvalResponse => StepType.execute,
    };

    return ExecutionStep(
      id: '${message.fromAgentId}-${message.timestamp.millisecondsSinceEpoch}',
      type: iconType,
      status: status,
      description: message.content.substring(
        0,
        message.content.length > 120 ? 120 : message.content.length,
      ),
      agentId: message.fromAgentId,
      result: message.content,
      completedAt: message.timestamp,
    );
  }

  /// Create a task assignment message from an agent to another.
  AgentMessage createTaskAssignment({
    required String fromAgentId,
    required String fromAgentName,
    required String toAgentId,
    required String toAgentName,
    required String taskDescription,
    Map<String, dynamic>? metadata,
  }) {
    return AgentMessage(
      fromAgentId: fromAgentId,
      fromAgentName: fromAgentName,
      toAgentId: toAgentId,
      toAgentName: toAgentName,
      type: MessageType.taskAssignment,
      content: taskDescription,
      metadata: metadata,
    );
  }

  /// Create a result report message.
  AgentMessage createResultReport({
    required String fromAgentId,
    required String fromAgentName,
    required String toAgentId,
    required String toAgentName,
    required String result,
    bool success = true,
  }) {
    return AgentMessage(
      fromAgentId: fromAgentId,
      fromAgentName: fromAgentName,
      toAgentId: toAgentId,
      toAgentName: toAgentName,
      type: success ? MessageType.resultReport : MessageType.error,
      content: success
          ? result
          : 'Error: ${result.substring(0, result.length > 200 ? 200 : result.length)}',
    );
  }

  /// Format the communication flow as a human-readable trace.
  String formatCommunicationTrace(List<AgentMessage> messages) {
    final buffer = StringBuffer();
    for (final msg in messages) {
      buffer.writeln(
        '[${msg.timestamp.toIso8601String()}] '
        '${msg.fromAgentName} → ${msg.toAgentName}: '
        '${msg.type.name}',
      );
    }
    return buffer.toString();
  }
}