import 'dart:convert';

UserPrac userPracFromJson(String str) => UserPrac.fromJson(json.decode(str));

String userPracToJson(UserPrac data) => json.encode(data.toJson());

class UserPrac {
  String page;
  String memId;
  String conCd;
  String spBookCd;
  String spPracIdx;

  UserPrac({
    this.page,
    this.memId,
    this.conCd,
    this.spBookCd,
    this.spPracIdx,
  });

  factory UserPrac.fromJson(Map<String, dynamic> json) => UserPrac(
    page: json["page"],
    memId: json["mem_id"],
    conCd: json["con_cd"],
    spBookCd: json["spBookCD"],
    spPracIdx: json["spPracIDX"],
  );

  Map<String, dynamic> toJson() => {
    "page": page,
    "mem_id": memId,
    "con_cd": conCd,
    "spBookCD": spBookCd,
    "spPracIDX": spPracIdx,
  };

  String get getspBookCd => spBookCd;

  void set getspBookCd(String val) {
    this.spBookCd = val;
  }
}

var userPrac = UserPrac();