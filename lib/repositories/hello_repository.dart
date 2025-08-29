class HelloRepository {

  String fetchHello() {
    return 'Hello World!';
  }

  String fetchHelloByName(String name) {
    return 'Hello $name!';
  }
}
