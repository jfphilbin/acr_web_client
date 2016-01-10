//TODO: copyright

//TODO: what are the values of a site?

class Address {
  static const String $separator = ":";
  final String line0;
  final String line1;

  //TODO: get city list
  final USACity city;

  //TODO: get State with abbreviations and zipCodes list
  final USAState state;

  //TODO: use State
  final ZipCode zipCode;

  /// Constant Constructor
  const Address._(this.street0, this.street1, this.city, this.state, this.zipCode);

  //TODO: what syntax
  String toString() => '$line0\n$line1\n$city, ${state.abbr}  $zipCode';

  //TODO: needed
  const foo = const Address._("0001-xyz", "foo");

  static Address parse(String s) {
    List<String> l = s.split("\n");
    String line2 = l[2];
    String city = line2.fir

    return new Address(l[0], l[1],);
  }

}
