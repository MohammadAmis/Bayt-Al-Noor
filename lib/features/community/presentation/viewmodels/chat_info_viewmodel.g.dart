// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_info_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatInfoViewModelHash() => r'2a2a8a966b8f379c5484bb77dfac05208e9d17b1';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$ChatInfoViewModel
    extends BuildlessAutoDisposeNotifier<ChatInfoState> {
  late final String chatId;
  late final String initialName;

  ChatInfoState build(
    String chatId, {
    required String initialName,
  });
}

/// See also [ChatInfoViewModel].
@ProviderFor(ChatInfoViewModel)
const chatInfoViewModelProvider = ChatInfoViewModelFamily();

/// See also [ChatInfoViewModel].
class ChatInfoViewModelFamily extends Family<ChatInfoState> {
  /// See also [ChatInfoViewModel].
  const ChatInfoViewModelFamily();

  /// See also [ChatInfoViewModel].
  ChatInfoViewModelProvider call(
    String chatId, {
    required String initialName,
  }) {
    return ChatInfoViewModelProvider(
      chatId,
      initialName: initialName,
    );
  }

  @override
  ChatInfoViewModelProvider getProviderOverride(
    covariant ChatInfoViewModelProvider provider,
  ) {
    return call(
      provider.chatId,
      initialName: provider.initialName,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'chatInfoViewModelProvider';
}

/// See also [ChatInfoViewModel].
class ChatInfoViewModelProvider
    extends AutoDisposeNotifierProviderImpl<ChatInfoViewModel, ChatInfoState> {
  /// See also [ChatInfoViewModel].
  ChatInfoViewModelProvider(
    String chatId, {
    required String initialName,
  }) : this._internal(
          () => ChatInfoViewModel()
            ..chatId = chatId
            ..initialName = initialName,
          from: chatInfoViewModelProvider,
          name: r'chatInfoViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$chatInfoViewModelHash,
          dependencies: ChatInfoViewModelFamily._dependencies,
          allTransitiveDependencies:
              ChatInfoViewModelFamily._allTransitiveDependencies,
          chatId: chatId,
          initialName: initialName,
        );

  ChatInfoViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.chatId,
    required this.initialName,
  }) : super.internal();

  final String chatId;
  final String initialName;

  @override
  ChatInfoState runNotifierBuild(
    covariant ChatInfoViewModel notifier,
  ) {
    return notifier.build(
      chatId,
      initialName: initialName,
    );
  }

  @override
  Override overrideWith(ChatInfoViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChatInfoViewModelProvider._internal(
        () => create()
          ..chatId = chatId
          ..initialName = initialName,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        chatId: chatId,
        initialName: initialName,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<ChatInfoViewModel, ChatInfoState>
      createElement() {
    return _ChatInfoViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatInfoViewModelProvider &&
        other.chatId == chatId &&
        other.initialName == initialName;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, chatId.hashCode);
    hash = _SystemHash.combine(hash, initialName.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChatInfoViewModelRef on AutoDisposeNotifierProviderRef<ChatInfoState> {
  /// The parameter `chatId` of this provider.
  String get chatId;

  /// The parameter `initialName` of this provider.
  String get initialName;
}

class _ChatInfoViewModelProviderElement
    extends AutoDisposeNotifierProviderElement<ChatInfoViewModel, ChatInfoState>
    with ChatInfoViewModelRef {
  _ChatInfoViewModelProviderElement(super.provider);

  @override
  String get chatId => (origin as ChatInfoViewModelProvider).chatId;
  @override
  String get initialName => (origin as ChatInfoViewModelProvider).initialName;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
