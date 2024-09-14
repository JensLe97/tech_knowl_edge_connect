import 'package:envied/envied.dart';
part 'env.g.dart';

@Envied(path: ".env")
final class Env {
  @EnviedField(varName: 'OPENAI_API_KEY', obfuscate: true) // the .env variable.
  static final String openaiApiKey = _Env.openaiApiKey;
}
