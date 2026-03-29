// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$statisticsTasksStreamHash() =>
    r'2a71eb5a1361fa125d585d38910246174cab7e3c';

/// See also [statisticsTasksStream].
@ProviderFor(statisticsTasksStream)
final statisticsTasksStreamProvider = StreamProvider<List<Task>>.internal(
  statisticsTasksStream,
  name: r'statisticsTasksStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$statisticsTasksStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StatisticsTasksStreamRef = StreamProviderRef<List<Task>>;
String _$rawSessionsQueryHash() => r'4faacbded80cad782f113a2b395ac9fc51f17b06';

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

/// See also [rawSessionsQuery].
@ProviderFor(rawSessionsQuery)
const rawSessionsQueryProvider = RawSessionsQueryFamily();

/// See also [rawSessionsQuery].
class RawSessionsQueryFamily extends Family<AsyncValue<List<TypedResult>>> {
  /// See also [rawSessionsQuery].
  const RawSessionsQueryFamily();

  /// See also [rawSessionsQuery].
  RawSessionsQueryProvider call({
    bool requireTaskJoin = false,
  }) {
    return RawSessionsQueryProvider(
      requireTaskJoin: requireTaskJoin,
    );
  }

  @override
  RawSessionsQueryProvider getProviderOverride(
    covariant RawSessionsQueryProvider provider,
  ) {
    return call(
      requireTaskJoin: provider.requireTaskJoin,
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
  String? get name => r'rawSessionsQueryProvider';
}

/// See also [rawSessionsQuery].
class RawSessionsQueryProvider extends FutureProvider<List<TypedResult>> {
  /// See also [rawSessionsQuery].
  RawSessionsQueryProvider({
    bool requireTaskJoin = false,
  }) : this._internal(
          (ref) => rawSessionsQuery(
            ref as RawSessionsQueryRef,
            requireTaskJoin: requireTaskJoin,
          ),
          from: rawSessionsQueryProvider,
          name: r'rawSessionsQueryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$rawSessionsQueryHash,
          dependencies: RawSessionsQueryFamily._dependencies,
          allTransitiveDependencies:
              RawSessionsQueryFamily._allTransitiveDependencies,
          requireTaskJoin: requireTaskJoin,
        );

  RawSessionsQueryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.requireTaskJoin,
  }) : super.internal();

  final bool requireTaskJoin;

  @override
  Override overrideWith(
    FutureOr<List<TypedResult>> Function(RawSessionsQueryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RawSessionsQueryProvider._internal(
        (ref) => create(ref as RawSessionsQueryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        requireTaskJoin: requireTaskJoin,
      ),
    );
  }

  @override
  FutureProviderElement<List<TypedResult>> createElement() {
    return _RawSessionsQueryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RawSessionsQueryProvider &&
        other.requireTaskJoin == requireTaskJoin;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, requireTaskJoin.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RawSessionsQueryRef on FutureProviderRef<List<TypedResult>> {
  /// The parameter `requireTaskJoin` of this provider.
  bool get requireTaskJoin;
}

class _RawSessionsQueryProviderElement
    extends FutureProviderElement<List<TypedResult>> with RawSessionsQueryRef {
  _RawSessionsQueryProviderElement(super.provider);

  @override
  bool get requireTaskJoin =>
      (origin as RawSessionsQueryProvider).requireTaskJoin;
}

String _$sessionsByDateRangeHash() =>
    r'd468a4f7857c8fbd86ea52a96ebb2a10d78d35ca';

/// See also [sessionsByDateRange].
@ProviderFor(sessionsByDateRange)
final sessionsByDateRangeProvider = FutureProvider<List<Session>>.internal(
  sessionsByDateRange,
  name: r'sessionsByDateRangeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionsByDateRangeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SessionsByDateRangeRef = FutureProviderRef<List<Session>>;
String _$summaryStatsHash() => r'bef3242d1f0400cd3f076937b40695c1fa43bcb5';

/// See also [summaryStats].
@ProviderFor(summaryStats)
final summaryStatsProvider = FutureProvider<SummaryStats>.internal(
  summaryStats,
  name: r'summaryStatsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$summaryStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SummaryStatsRef = FutureProviderRef<SummaryStats>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
