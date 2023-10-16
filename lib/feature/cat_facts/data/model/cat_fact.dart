import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class CatFact {
  @HiveField(0)
  final String fact;
  @HiveField(1)
  final int length;

  CatFact({required this.fact, required this.length});

  factory CatFact.fromJson(Map<String, dynamic> json) {
    return CatFact(
      fact: json['fact']?.toString() ?? '',
      length: int.tryParse(json['length']?.toString() ?? '0') ?? 0,
    );
  }

  String get factName => fact.substring(0, fact.length > 20 ? 20 : fact.length);
}

class CatFactAdapter extends TypeAdapter<CatFact> {
  @override
  final typeId = 0;

  @override
  CatFact read(BinaryReader reader) {
    return CatFact(
      fact: reader.readString(),
      length: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, CatFact obj) {
    writer.writeString(obj.fact);
    writer.writeInt(obj.length);
  }
}
