import 'package:real_calc/core/seed_works/result.dart';
import 'package:real_calc/core/seed_works/error.dart';


// Interface para simular requisições HTTP
abstract class Network {
  // Simulação de uma requisição GET
  // Aqui você pode implementar a lógica real de requisição HTTP
  // e retornar um Result<T> com sucesso ou falha.  
  Future<Result<ErrorMessages, T>> get<T>(String url);
  
  // Simulação de uma requisição POST
  // Aqui você pode implementar a lógica real de requisição HTTP
  // e retornar um Result<T> com sucesso ou falha.
  Future<Result<ErrorMessages, T>> post<T>(String url, Map<String, dynamic> body);
  
  // Simulação de uma requisição PUT
  // Aqui você pode implementar a lógica real de requisição HTTP
  // e retornar um Result<T> com sucesso ou falha.
  Future<Result<ErrorMessages, T>> put<T>(String url, Map<String, dynamic> body);

  // Simulação de uma requisição DELETE
  // Aqui você pode implementar a lógica real de requisição HTTP
  // e retornar um Result<T> com sucesso ou falha.
  Future<Result<ErrorMessages, T>> delete<T>(String url);
}