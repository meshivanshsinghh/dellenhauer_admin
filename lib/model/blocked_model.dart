class BlockedModel {
  List<Numbers>? numbers;

  BlockedModel({this.numbers});

  BlockedModel.fromJson(Map<String, dynamic> json) {
    if (json['numbers'] != null) {
      numbers = <Numbers>[];
      json['numbers'].forEach((v) {
        numbers!.add(new Numbers.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.numbers != null) {
      data['numbers'] = this.numbers!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Numbers {
  String? number;
  int? createdAt;

  Numbers({this.number, this.createdAt});

  Numbers.fromJson(Map<String, dynamic> json) {
    number = json['number'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['number'] = this.number;
    data['createdAt'] = this.createdAt;
    return data;
  }
}
