//TODO: copyright

//TODO: what are the values of a site?

class Site {
  static const String $separator = ":";
  final Uuid uuid;
  final String id;

  //max length 16
  final String name;

  //max length 256
  final String ctepId;

  //TODO: should this be a code
  final String idSource;

  // NRDR, CTEP, DART, etc.

  /// The CTMS [Group] that claimed the [Site]
  final Group group;

  //TODO: create code table

  /// The parent [Site] of this [Site]
  final Site parent;

  /// The CTEP ID of the parent [Site]
  final Address address;

  /// Constant Constructor
  const Site._(this.id, this.name);

  //TODO: what syntax
  String toString() => '$id:$name';

  //TODO: define projects
  const foo = const Site._("0001-xyz", "foo");

  static Project parse(String s) {
    List<String> l = s.split($separator);
    return new Project(l[0], l[1]);
  }

}
