class ReposModel {
  final reposName;
  final reposDesc;
  final reposLink;

  ReposModel({
    this.reposName,
    this.reposDesc,
    this.reposLink
  });

  factory ReposModel.fromJson(final json) {
    return ReposModel(
      reposName: json["name"],
      reposDesc: json["description"] == null ? 'No description' : json["description"],
      reposLink: json["html_url"]
    );
  }
}