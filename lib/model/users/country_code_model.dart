class CountryModel {
  String? country;
  String? city;
  String? state;
  CountryModel({
    this.country,
    this.city,
    this.state,
  });
  CountryModel.fromJson(Map<String, dynamic> json) {
    country = json['coutry'];
    city = json['city'];
    state = json['state'];
  }
  Map<String, dynamic> toJson() {
    return {
      'coutry': country,
      'city': city,
      'state': state,
    };
  }
}
