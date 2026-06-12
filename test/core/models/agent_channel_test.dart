import 'package:flutter_test/flutter_test.dart';
import 'package:Kelivo/core/models/agent_channel.dart';

void main() {
  group('ChannelType', () {
    test('values are complete', () {
      expect(ChannelType.values.length, 6);
      expect(ChannelType.telegram, isA<ChannelType>());
      expect(ChannelType.discord, isA<ChannelType>());
      expect(ChannelType.slack, isA<ChannelType>());
      expect(ChannelType.email, isA<ChannelType>());
      expect(ChannelType.webhook, isA<ChannelType>());
      expect(ChannelType.webWidget, isA<ChannelType>());
    });

    test('toJson/fromJson round-trip', () {
      for (final type in ChannelType.values) {
        expect(ChannelType.fromJson(type.toJson()), type);
      }
    });

    test('fromJson returns default for unknown', () {
      expect(ChannelType.fromJson('unknown'), ChannelType.telegram);
    });
  });

  group('AgentChannel', () {
    test('constructor sets default values', () {
      final now = DateTime.now(); // ignore: unused_local_variable
      final channel = AgentChannel(
        id: 'ch-1',
        name: 'My Bot',
        agentId: 'agent-1',
        workspaceId: 'ws-1',
        type: ChannelType.telegram,
      );

      expect(channel.id, 'ch-1');
      expect(channel.name, 'My Bot');
      expect(channel.agentId, 'agent-1');
      expect(channel.workspaceId, 'ws-1');
      expect(channel.type, ChannelType.telegram);
      expect(channel.enabled, isTrue);
      expect(channel.configJson, '{}');
      expect(channel.config, isEmpty);
      expect(channel.createdAt, isNotNull);
      expect(channel.updatedAt, isNotNull);
    });

    test('constructor with all fields', () {
      final now = DateTime.now();
      final channel = AgentChannel(
        id: 'ch-2',
        name: 'Email Bot',
        agentId: 'agent-1',
        workspaceId: 'ws-1',
        type: ChannelType.email,
        configJson: '{"smtpHost":"smtp.example.com"}',
        enabled: false,
        createdAt: now,
        updatedAt: now,
      );

      expect(channel.name, 'Email Bot');
      expect(channel.type, ChannelType.email);
      expect(channel.configJson, '{"smtpHost":"smtp.example.com"}');
      expect(channel.config['smtpHost'], 'smtp.example.com');
      expect(channel.enabled, isFalse);
      expect(channel.createdAt, now);
      expect(channel.updatedAt, now);
    });

    test('copyWith preserves values unless overridden', () {
      final channel = AgentChannel(
        id: 'ch-1',
        name: 'My Bot',
        agentId: 'agent-1',
        workspaceId: 'ws-1',
        type: ChannelType.telegram,
        configJson: '{"key":"val"}',
      );

      final copied = channel.copyWith(name: 'Updated');
      expect(copied.id, 'ch-1');
      expect(copied.name, 'Updated');
      expect(copied.agentId, 'agent-1');
      expect(copied.type, ChannelType.telegram);
      expect(copied.configJson, '{"key":"val"}');
      expect(copied.enabled, isTrue);
    });

    test('copyWith clears name when flag set', () {
      final channel = AgentChannel(
        id: 'ch-1',
        name: 'My Bot',
        agentId: 'agent-1',
        workspaceId: 'ws-1',
        type: ChannelType.telegram,
      );

      final copied = channel.copyWith(clearName: true);
      expect(copied.name, '');
    });

    test('copyWith clears config when flag set', () {
      final channel = AgentChannel(
        id: 'ch-1',
        name: 'My Bot',
        agentId: 'agent-1',
        workspaceId: 'ws-1',
        type: ChannelType.telegram,
        configJson: '{"key":"val"}',
      );

      final copied = channel.copyWith(clearConfig: true);
      expect(copied.configJson, '{}');
    });

    test('toJson/fromJson round-trip with all fields', () {
      final channel = AgentChannel(
        id: 'ch-1',
        name: 'Slack Bot',
        agentId: 'agent-2',
        workspaceId: 'ws-1',
        type: ChannelType.slack,
        configJson: '{"botToken":"xoxb-xxx","channelId":"C123"}',
        enabled: false,
      );

      final json = channel.toJson();
      final decoded = AgentChannel.fromJson(json);

      expect(decoded.id, channel.id);
      expect(decoded.name, channel.name);
      expect(decoded.agentId, channel.agentId);
      expect(decoded.workspaceId, channel.workspaceId);
      expect(decoded.type, channel.type);
      expect(decoded.configJson, channel.configJson);
      expect(decoded.enabled, channel.enabled);
    });

    test('toJson omits optional configJson when empty', () {
      final channel = AgentChannel(
        id: 'ch-1',
        name: 'My Bot',
        agentId: 'agent-1',
        workspaceId: 'ws-1',
        type: ChannelType.telegram,
      );

      final json = channel.toJson();
      expect(json.containsKey('configJson'), false);
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'id': 'ch-1',
        'name': 'My Bot',
        'agentId': 'agent-1',
        'workspaceId': 'ws-1',
        'type': 'discord',
        'createdAt': 1000000,
        'updatedAt': 1000000,
      };

      final channel = AgentChannel.fromJson(json);
      expect(channel.id, 'ch-1');
      expect(channel.type, ChannelType.discord);
      expect(channel.configJson, '{}');
      expect(channel.enabled, isTrue);
    });

    test('config getter parses JSON', () {
      final channel = AgentChannel(
        id: 'ch-1',
        name: 'Config Bot',
        agentId: 'agent-1',
        workspaceId: 'ws-1',
        type: ChannelType.webhook,
        configJson: '{"url":"https://hook.example.com","method":"POST"}',
      );

      expect(channel.config['url'], 'https://hook.example.com');
      expect(channel.config['method'], 'POST');
    });

    test('config getter handles invalid JSON gracefully', () {
      final channel = AgentChannel(
        id: 'ch-1',
        name: 'Bad Config',
        agentId: 'agent-1',
        workspaceId: 'ws-1',
        type: ChannelType.webhook,
        configJson: 'not-json',
      );

      expect(channel.config, isEmpty);
    });

    test('encodeList/decodeList round-trip', () {
      final channels = [
        AgentChannel(
          id: 'ch-1',
          name: 'Telegram Bot',
          agentId: 'agent-1',
          workspaceId: 'ws-1',
          type: ChannelType.telegram,
        ),
        AgentChannel(
          id: 'ch-2',
          name: 'Discord Bot',
          agentId: 'agent-2',
          workspaceId: 'ws-2',
          type: ChannelType.discord,
          configJson: '{"botToken":"abc"}',
        ),
      ];

      final encoded = AgentChannel.encodeList(channels);
      final decoded = AgentChannel.decodeList(encoded);

      expect(decoded.length, 2);
      expect(decoded[0].id, 'ch-1');
      expect(decoded[0].type, ChannelType.telegram);
      expect(decoded[1].type, ChannelType.discord);
      expect(decoded[1].config['botToken'], 'abc');
    });

    test('decodeList handles invalid JSON', () {
      final decoded = AgentChannel.decodeList('');
      expect(decoded, isEmpty);
    });
  });
}
