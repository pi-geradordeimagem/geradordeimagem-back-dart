import 'package:geradordeimagem_back_dart/repositories/hello_repository.dart';

class HelloService {
  final repo = HelloRepository();
  
  String sayHello() {
    return repo.fetchHello();
  }

  String sayHelloToName(String name) {
    return repo.fetchHelloByName(name);
  }
}
