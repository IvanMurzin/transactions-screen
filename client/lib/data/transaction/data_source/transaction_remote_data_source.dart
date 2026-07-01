import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'package:transaction_screen/data/transaction/dto/transactions_response_dto.dart';

@lazySingleton
class TransactionRemoteDataSource {
  TransactionRemoteDataSource(this._dio);

  static const String _url = 'https://hiring-pi-snowy.vercel.app/karta/transaction/';

  final Dio _dio;

  Future<TransactionsResponseDto> fetchTransactions({required int page, required int limit}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      _url,
      queryParameters: {'page': page, 'limit': limit},
    );

    final data = response.data;
    if (data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Empty transactions response',
      );
    }

    return TransactionsResponseDto.fromJson(data);
  }
}
