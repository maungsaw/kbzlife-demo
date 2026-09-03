/// FR-10 §2: Main Folder → Sub-Folder → File (3-level structure only).
enum ResourceNodeType { mainFolder, subFolder, file }

enum ResourceFileKind { pdf, doc, xls, image, video }

class ResourceNode {
  const ResourceNode({
    required this.id,
    required this.name,
    required this.type,
    this.children = const [],
    this.fileKind,
    this.sizeLabel,
  });

  final String id;
  final String name;
  final ResourceNodeType type;
  final List<ResourceNode> children;
  final ResourceFileKind? fileKind;
  final String? sizeLabel;
}
