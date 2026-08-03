import 'package:quran_one/app/bootstrap.dart';
import 'package:quran_one/app/flavour.dart';

void main() => bootstrap(
      flavour: Flavour.prod,
      config: const AppConfig.fromEnvironment(),
    );
