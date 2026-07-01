import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:transaction_screen/data/transaction/dto/transaction_dto.dart';

part 'transactions_response_dto.freezed.dart';
part 'transactions_response_dto.g.dart';

@Freezed(fromJson: true, toJson: false)
abstract class TransactionsResponseDto with _$TransactionsResponseDto {
  const factory TransactionsResponseDto({
    @Default(0) int count,
    String? next,
    String? previous,
    @Default(<TransactionDto>[]) List<TransactionDto> results,
  }) = _TransactionsResponseDto;

  factory TransactionsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TransactionsResponseDtoFromJson(json);
}
