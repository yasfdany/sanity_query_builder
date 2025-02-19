import 'package:sanity_query_builder/projection_builder.dart';
import 'package:sanity_query_builder/sanity_query_builder.dart';

void main() {
  final projection = ProjectionBuilder()
      .field('language')
      .array('blocks', _blockProjection)
      .build();
  final query = SanityQueryBuilder()
      .type('page')
      .where('language', '==', 'en-US')
      .where('isRoot')
      .where('isIndex')
      .first()
      .project(projection)
      .build();
  print(query.query);
}

ProjectionBuilder _blockProjection(ProjectionBuilder b) {
  return b
      .spread()
      .object('image', _imageProjection)
      .array('cardItems', _cardProjection)
      .arrayReference('userHighlightCards', _cardProjection)
      .array('logos', _logosProjection);
}

ProjectionBuilder _imageProjection(ProjectionBuilder b) {
  return b
      .field('_type')
      .alias('url', 'asset->url')
      .alias('info', 'asset->metadata{...dimensions}');
}

ProjectionBuilder _cardProjection(ProjectionBuilder b) {
  return b.spread().object('image', _imageProjection);
}

ProjectionBuilder _logosProjection(ProjectionBuilder b) {
  return b.field('_type').alias('url', 'asset->url');
}
