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
      .inParentheses((b) {
        return b.where('isRoot').where('isIndex');
      })
      .first()
      .project(projection)
      .build();

  print(query.query);
  // *[_type == "page" && language == "en-US" && (isRoot && isIndex)][0]{language, blocks[]{..., image{_type, "url": asset->url, "info": asset->metadata{...dimensions}}, cardItems[]{..., image{_type, "url": asset->url, "info": asset->metadata{...dimensions}}}, userHighlightCards[]->{..., image{_type, "url": asset->url, "info": asset->metadata{...dimensions}}}, logos[]{_type, "url": asset->url}}}
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
