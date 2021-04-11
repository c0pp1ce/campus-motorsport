/// Model for the login email.
///
/// [email] cannot be empty or null.
class Email {
  String _email;


  Email(String email) : _email = email {
    this.email = email;
  }

  set email(String email) {
    email = email.toLowerCase().trim();
    if(email.isEmpty) {
      throw FormatException("Email cannot be empty.");
    }
    _email = email;
  }

  String get email => _email;
}