//TODO: copyright

import 'dart:convert';

//TODO: what are the values of a site?
//TODO: need USA City List including state and zipcodes.
//TODO: need to handle PO Box...

class Address {
  static const String $separator = ":";
  final String line0;
  final String line1;

  //TODO: get city list - it should include state and zipCodes
  final String city;
  final String state;
  final String zip;
  final String country;

  //TODO: get State with abbreviations and zipCodes list
  // final USAState state;

  /// Constant Constructor
  Address(this.line0, this.line1, this.city, this.state, this.zip, this.country);

  //TODO: what synta
  String toString() => '$line0\n$line1\n$city, $state  $zip';

  static parse(String s) {
    //TODO
    var l = s.split('\n');
    var line0 = l[0];
    var line1 = l[1];
    var line2 = l[2].replaceAll("\\s+", " ");
    line2 = l[2].replaceAll(",", "");
    var l2 = line2.split(' ');
    var city = l2[0].trim();
    var state = l2[1].trim();
    var zip = l2[2].trim();
    var country = (l[3] != null) ? l[3] : "USA";
    return new Address(line0, line1, city, state, zip, country);
  }

  static Address fromJSON(String s) {
    Map json = JSON.decode(s);
    if (json['@type'] != "DART.site") throw 'Invalid Case JSON: $s';
    return new Address(
        json['line0'],
        json['line1'],
        json['city'],
        json['state'],
        json['zip'],
        json['country']);
  }
}
