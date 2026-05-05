// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'garden_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$gardenRepositoryHash() => r'ef5b808fd850e7b89afaa380c2e5e10816d8a52d';

/// See also [gardenRepository].
@ProviderFor(gardenRepository)
final gardenRepositoryProvider = AutoDisposeProvider<GardenRepository>.internal(
  gardenRepository,
  name: r'gardenRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$gardenRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GardenRepositoryRef = AutoDisposeProviderRef<GardenRepository>;
String _$userGardenHash() => r'd7db085628410f6369d552eb5ad9b5aa583e1635';

/// See also [userGarden].
@ProviderFor(userGarden)
final userGardenProvider =
    AutoDisposeStreamProvider<List<UserGardenItem>>.internal(
  userGarden,
  name: r'userGardenProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$userGardenHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserGardenRef = AutoDisposeStreamProviderRef<List<UserGardenItem>>;
String _$plantCatalogHash() => r'aab922c1c266ccf448dbc846b2a4d814f44dbed1';

/// See also [plantCatalog].
@ProviderFor(plantCatalog)
final plantCatalogProvider =
    AutoDisposeFutureProvider<List<PlantCatalogItem>>.internal(
  plantCatalog,
  name: r'plantCatalogProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$plantCatalogHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PlantCatalogRef = AutoDisposeFutureProviderRef<List<PlantCatalogItem>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
