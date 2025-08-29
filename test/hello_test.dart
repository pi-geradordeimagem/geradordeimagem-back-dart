import 'package:geradordeimagem_back_dart/services/hello_service.dart';
import 'package:test/test.dart';

void main() {
  group('HelloService', () {
    final service = HelloService();

    test('sayHello returns Hello World', () {
      expect(service.sayHello(), equals('Hello World!'));
    });

    test('sayHelloToName returns Hello and the name inserted', () {
      expect(service.sayHelloToName('Matheus'), equals('Hello Matheus!'));
      expect(service.sayHelloToName('Maria'), equals('Hello Maria!'));
    });
  });

}
