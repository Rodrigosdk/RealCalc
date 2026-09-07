import 'package:flutter_bloc/flutter_bloc.dart';

class GreetingCubit extends Cubit<String> {
  GreetingCubit() : super(getGreetingByTime());

  static String getGreetingByTime([DateTime? dateTime]) {
    final hour = (dateTime ?? DateTime.now()).hour;

    if (hour >= 6 && hour < 12) {
      return 'Bom dia';
    } else if (hour >= 12 && hour < 18) {
      return 'Boa tarde';
    } else {
      return 'Boa noite';
    }
  }
}
