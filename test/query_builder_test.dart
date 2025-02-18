import 'package:flutter_test/flutter_test.dart';
import 'package:sanity_query_builder/sanity_query_builder.dart';

void main() {
  group('SanityQueryBuilder Tests', () {
    test('Basic Type Query', () {
      final query = SanityQueryBuilder().type('post').build();

      expect(query.query, '*[_type == \$p0]');
      expect(query.params, {'p0': 'post'});
    });

    test('Slug Query', () {
      final query = SanityQueryBuilder().slug('my-post').build();

      expect(query.query, '*[slug.current == \$p0]');
      expect(query.params, {'p0': 'my-post'});
    });

    test('Where Condition with Parameter', () {
      final query = SanityQueryBuilder().where('age', '>=', 18).build();

      expect(query.query, '*[age >= \$p0]');
      expect(query.params, {'p0': 18});
    });

    test('Where Raw Condition', () {
      final query = SanityQueryBuilder()
          .whereRaw('(role == "admin" || role == "editor")')
          .build();

      expect(query.query, '*[(role == "admin" || role == "editor")]');
      expect(query.params, {});
    });

    test('Projection with Nested Fields', () {
      final query = SanityQueryBuilder().project({
        'title': true,
        'author': {
          'name': true,
          'role': true,
        },
      }).build();

      expect(query.query, '*{title, author->{name, role}}');
      expect(query.params, {});
    });

    test('Order by Field', () {
      final query = SanityQueryBuilder().order('price', 'desc').build();

      expect(query.query, '* | order(price desc)');
      expect(query.params, {});
    });

    test('Range for Pagination', () {
      final query = SanityQueryBuilder().range(0, 9).build();

      expect(query.query, '*[0..9]');
      expect(query.params, {});
    });

    test('Mutation (Count)', () {
      final query = SanityQueryBuilder().mutate('count').build();

      expect(query.query, '* | count()');
      expect(query.params, {});
    });

    test('Custom Parameter', () {
      final query = SanityQueryBuilder()
          .param('tag', 'dart')
          .whereRaw('tags contains \$tag')
          .build();

      expect(query.query, '*[tags contains \$tag]');
      expect(query.params, {'tag': 'dart'});
    });

    test('Complex Query with All Features', () {
      final query = SanityQueryBuilder()
          .type('post')
          .where('publishedAt', '<=', '2023-01-01')
          .whereRaw('(category == "tech" || category == "news")')
          .project({
            'title': true,
            'author': {
              'name': true,
            },
            'comments[]': {
              'text': true,
            },
          })
          .order('publishedAt', 'desc')
          .range(0, 9)
          .mutate('count')
          .build();

      expect(query.query,
          '*[_type == \$p0 && publishedAt <= \$p1 && (category == "tech" || category == "news")]{title, author->{name}, comments[]->{text}} | order(publishedAt desc)[0..9] | count()');
      expect(query.params, {
        'p0': 'post',
        'p1': '2023-01-01',
      });
    });

    test('Array Projection', () {
      final query = SanityQueryBuilder().project({
        'title': true,
        'comments[]': {
          'text': true,
          'author': {
            'name': true,
          },
        },
      }).build();

      expect(query.query, '*{title, comments[]->{text, author->{name}}}');
      expect(query.params, {});
    });

    test('Multiple Where Conditions', () {
      final query = SanityQueryBuilder()
          .where('age', '>=', 18)
          .where('role', '==', 'admin')
          .build();

      expect(query.query, '*[age >= \$p0 && role == \$p1]');
      expect(query.params, {'p0': 18, 'p1': 'admin'});
    });

    test('Empty Query', () {
      final query = SanityQueryBuilder().build();

      expect(query.query, '*');
      expect(query.params, {});
    });

    test('Projection with Array and Nested Fields', () {
      final query = SanityQueryBuilder().project({
        'title': true,
        'tags[]': true,
        'author': {
          'name': true,
          'profile': {
            'image': true,
          },
        },
      }).build();

      expect(query.query, '*{title, tags[], author->{name, profile->{image}}}');
      expect(query.params, {});
    });

    test('Multiple Mutations', () {
      final query =
          SanityQueryBuilder().mutate('count').mutate('reverse').build();

      expect(query.query, '* | count() | reverse()');
      expect(query.params, {});
    });

    test('Combined Range and Order', () {
      final query =
          SanityQueryBuilder().order('createdAt', 'asc').range(10, 19).build();

      expect(query.query, '* | order(createdAt asc)[10..19]');
      expect(query.params, {});
    });
  });
}
