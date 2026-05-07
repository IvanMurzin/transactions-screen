import 'package:injectable/injectable.dart';

import 'package:template_app/core/types/result.dart';
import 'package:template_app/domain/subscription/entity/subscription_entity.dart';
import 'package:template_app/domain/subscription/repository/i_subscription_repository.dart';

@injectable
class RefreshSubscriptionUseCase {
  RefreshSubscriptionUseCase(this._repository);

  final ISubscriptionRepository _repository;

  Future<Result<SubscriptionEntity>> call() => _repository.refresh();
}
