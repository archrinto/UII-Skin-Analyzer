import '../models/deteksi_model.dart';

class JSONResult {
  DeteksiObjek? deteksiObjek;

  JSONResult({this.deteksiObjek});

  JSONResult.fromJson(Map<String, dynamic> json) {
    deteksiObjek = json['deteksi_objek'] != null ? DeteksiObjek.fromJson(json['deteksi_objek']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (deteksiObjek != null) {
      data['deteksi_objek'] = deteksiObjek!.toJson();
    }
    return data;
  }
}

class DeteksiObjek {
  List<DeteksiModel>? jerawat;
  List<DeteksiModel>? keriput;
  List<DeteksiModel>? kemerahan;
  List<DeteksiModel>? bercakHitam;

  DeteksiObjek({this.jerawat, this.keriput, this.kemerahan, this.bercakHitam});

  DeteksiObjek.fromJson(Map<String, dynamic> json) {
    if (json['jerawat'] != null) {
      jerawat = <DeteksiModel>[];
      json['jerawat'].forEach((v) {
        jerawat!.add(DeteksiModel.fromJson(v));
      });
    }

    if (json['keriput'] != null) {
      keriput = <DeteksiModel>[];
      json['keriput'].forEach((v) {
        keriput!.add(DeteksiModel.fromJson(v));
      });
    }

    if (json['kemerahan'] != null) {
      kemerahan = <DeteksiModel>[];
      json['kemerahan'].forEach((v) {
        kemerahan!.add(DeteksiModel.fromJson(v));
      });
    }

    if (json['bintik_hitam'] != null) {
      bercakHitam = <DeteksiModel>[];
      json['bintik_hitam'].forEach((v) {
        bercakHitam!.add(DeteksiModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (jerawat != null) {
      data['jerawat'] = jerawat!.map((v) => v.toJson()).toList();
    }

    if (keriput != null) {
      data['keriput'] = keriput!.map((v) => v.toJson()).toList();
    }

    if (kemerahan != null) {
      data['kemerahan'] = kemerahan!.map((v) => v.toJson()).toList();
    }

    if (bercakHitam != null) {
      data['bintik_hitam'] = bercakHitam!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}
