// Copyright (c) 2015, Open DICOMweb Project. All rights reserved. 
// Use of this source code is governed by the open source license 
// that can be found in the LICENSE file.
// Please see the AUTHORS file for details.
library user;

///
//TODO merge with TriadId

/// The [User] of [this] [Client].  It is a singleton class whose fields are [final],
/// and cannot be modified. There can only be one [User] logged-in to a Client.
class User {
  final String _domain;      // ATI,
  final String _username;    // username
  final String _authToken;
  final String _commandGuid;
  static User _user;

  static String get domain => _user._domain;
  static String get username => _user._username;
  static String get authToken => _user._authToken;
  static String get commandGuid => _user._commandGuid;
  static User   get user => _user;

  // Private Constructor
  User._(this._domain, this._username, this._authToken, this._commandGuid);

  // [factory] used to make singleton.  Can only be called once.
  factory User(domain, username, authToken, commandGuid) {
    if (_user == null) {
      _user = new User._(domain, username, authToken, commandGuid);
      return _user;
    } else {
      throw "Invalid User: only one user can be created per client.";
    }
  }

  //TODO: what should this be?
  String toString() => '$_domain:$_username';
}
