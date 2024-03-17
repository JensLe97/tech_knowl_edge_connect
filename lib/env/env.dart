import 'package:envied/envied.dart';
part 'env.g.dart';

@Envied(path: ".env", useConstantCase: true)
final class Env {
  @EnviedField(varName: 'OPENAI_API_KEY', obfuscate: true) // the .env variable.
  static final String openApiKey = _Env.openApiKey;
}
