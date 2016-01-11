//TODO: add ACR copyright

//TODO make this a static singleton
class Triad {
  static const wcfAtiServiceUrlLeaf = "TriadInterimWebService.svc";
  static const wcfTriadAcreditServiceUrlLeaf = "TriadAcreditService.svc";
  static const wcfTriadApplicationServiceUrlLeaf = "TriadApplicationService.svc";
  static const wcfAuditTrailUrlLeaf = "TriadAuditService.svc";
  static Triad _triad;
  final String baseUrl;



  static String get wcfAtiServiceUrl => _triad.baseUrl + wcfAtiServiceUrlLeaf;
  static String get wcfTriadAcreditServiceUrl => _triad.baseUrl + wcfTriadAcreditServiceUrlLeaf;
  static String get wcfTriadApplicationServiceUrl => _triad.baseUrl + wcfTriadApplicationServiceUrlLeaf;
  static String get wcfAuditTrailUrl => _triad.baseUrl + wcfAuditTrailUrlLeaf;

  Triad._(this.baseUrl);

  // [factory] used to make singleton.  Can only be called once.
  factory Triad(String baseUrl) {
    if (_triad == null) {
      _triad = new Triad._(baseUrl);
      return _triad;
    } else {
      throw "Invalid User: only one user can be created per client.";
    }
  }

  /// Initializes the [Triad] singleton
  static void initialize(String baseUrl) {
    if(_triad == null) {
      _triad = new Triad._(baseUrl);
    } else {
      throw "Invalid User: only one user can be created per client.";
    }
  }
}



