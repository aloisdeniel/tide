abstract class ServerClient {
  const ServerClient();
  Future<int> getValue();
}

class MockServerClient extends ServerClient {
  const MockServerClient();
  Future<int> getValue() async {
    await Future.delayed(const Duration(seconds: 2));
    return 128;
  }
}
