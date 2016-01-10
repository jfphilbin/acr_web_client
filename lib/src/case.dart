//TODO: copyright

//TODO: what are the values of a case?

class Case {
  static const String $separator = ":";
  static final Regex idFormat = "";
  final String id;

  //max length?
  //TODO: what is format of case id?
  final String name;

  //max length 16


  const Case._(this.id, this.name);

  //TODO: what syntax
  String toString() => '$id:$name';

  //TODO: define projects
  const foo = const Case._("0001-xyz", "foo");

  static Project parse(String s) {
    List<String> l = s.split($separator);
    return new Project(l[0], l[1]);
  }
}
