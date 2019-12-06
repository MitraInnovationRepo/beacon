class Dealdata {
  final String shopName;
  final int discount;
  final String cat;
  final String photoUrl;

  // DealData(this.shopName, this.discount, this.cat, this.photoUrl);

  Dealdata.fromJson(Map<String, dynamic> json)
      : shopName = json['shopName'],
        discount = json['discount'],
        cat = json['cat'],
        photoUrl = json['photoUrl'];
}