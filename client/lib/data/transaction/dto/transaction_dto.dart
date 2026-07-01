import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_dto.freezed.dart';
part 'transaction_dto.g.dart';

@Freezed(fromJson: true, toJson: false)
abstract class TransactionDto with _$TransactionDto {
  const factory TransactionDto({
    required int id,
    String? type,
    String? status,
    String? amount,
    String? currency,
    String? authorizedAt,
    String? merchantName,
  }) = _TransactionDto;

  factory TransactionDto.fromJson(Map<String, dynamic> json) => _$TransactionDtoFromJson(json);
}
