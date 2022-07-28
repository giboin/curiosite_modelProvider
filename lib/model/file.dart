class File{
  late final String name;
  late final String absolutePath;
  late final bool isFile;

  File({required this.name, required this.absolutePath, required this.isFile});

  File.fromJSON(dynamic json) {
     name=json['name'];
     absolutePath=json['absolutePath'];
     isFile=json['isFile'];
  }
}