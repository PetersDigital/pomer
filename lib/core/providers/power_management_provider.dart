import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pomer/core/services/power_management_service.dart';

part 'power_management_provider.g.dart';

@Riverpod(keepAlive: true)
PowerManagementService powerManagementService(Ref ref) {
  return PowerManagementService();
}
