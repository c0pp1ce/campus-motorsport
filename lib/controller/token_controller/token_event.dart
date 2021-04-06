abstract class TokenEvent {}

class SetToken extends TokenEvent {
  String token;

  SetToken(this.token);
}

class DeleteToken extends TokenEvent {}