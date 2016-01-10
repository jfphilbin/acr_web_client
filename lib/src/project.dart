//TODO: copyright


class Project {
  static const String $separator = ":";
  final Uuid uuid;

  //TODO: what is format of id?
  final String id;
  final String name;

  // max length 64
  final String longName;

  //max length 256
  final String abbr;

  //max length 16
  final Disease disease;

  //TODO: Disease code table
  final Date startDate;
  final Date endDate;
  final int targetAccrual;
  final Status status;

  //TODO: Status code table
  final bool includesImages;
  Date modified;


  const Project._(this.id, this.name);

  //TODO: what syntax
  String toString() => '$id:$name';

  //TODO: define projects
  const foo = const Project._("0001-xyz", "foo");

  static Project parse(String s) {
    List<String> l = s.split($separator);
    return new Project(l[0], l[1]);
  }
}
