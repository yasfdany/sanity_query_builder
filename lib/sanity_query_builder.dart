import 'package:sanity_query_builder/sanity_query.dart';

class SanityQueryBuilder {
  final List<String> _filters = [];
  final List<String> _orderSpecs = [];
  final List<String> _mutations = [];

  final Map<String, dynamic> _params = {};
  Map<String, dynamic>? _projection;

  int? _start;
  int? _end;
  int? _index;

  /// Sets the type filter for the query.
  ///
  /// [type] - The type to filter by.
  SanityQueryBuilder type(String type) => where('_type', '==', type);

  /// Sets the slug filter for the query.
  ///
  /// [slug] - The slug to filter by.
  SanityQueryBuilder slug(String slug) => where('slug.current', '==', slug);

  /// Wrap the query in parentheses.
  ///
  /// [builder] - The builder function to wrap in parentheses.
  SanityQueryBuilder inParentheses(
    SanityQueryBuilder Function(SanityQueryBuilder) builder,
  ) {
    final innerBuilder = SanityQueryBuilder();
    final innerFilters = builder(innerBuilder)._filters;
    if (innerFilters.isNotEmpty) {
      _filters.add('(');
      _filters.addAll(innerFilters);
      _filters.add(')');
    }
    return this;
  }

  /// Adds a filter condition to the query.
  ///
  /// [field] - The field to filter.
  /// [operator] - The operator to use for the filter.
  /// [value] - The value to filter by.
  SanityQueryBuilder where(String field, [String? operator, dynamic value]) {
    if (operator == null || value == null) {
      _filters.add(" && $field");
    } else {
      _filters.add(
        " && $field $operator ${value is String ? '"$value"' : value}",
      );
    }
    return this;
  }

  /// Adds an 'or' filter condition to the query.
  ///
  /// [field] - The field to filter.
  /// [operator] - The operator to use for the filter.
  /// [value] - The value to filter by.
  SanityQueryBuilder orWhere(String field, [String? operator, dynamic value]) {
    if (operator == null || value == null) {
      _filters.add(" || $field");
    } else {
      _filters.add(
        " || $field $operator ${value is String ? '"$value"' : value}",
      );
    }
    return this;
  }

  /// Adds a raw filter condition to the query.
  ///
  /// [condition] - The raw condition to add.
  SanityQueryBuilder whereRaw(String condition) {
    _filters.add(condition);
    return this;
  }

  /// Sets the projection for the query.
  ///
  /// [projection] - The projection map.
  SanityQueryBuilder project(Map<String, dynamic> projection) {
    _projection = projection;
    return this;
  }

  /// Adds an order specification to the query.
  ///
  /// [field] - The field to order by.
  /// [direction] - The direction of the order (default is 'asc').
  SanityQueryBuilder order(String field, [String direction = 'asc']) {
    _orderSpecs.add('$field $direction');
    return this;
  }

  SanityQueryBuilder get(int index) {
    _index = index;
    return this;
  }

  SanityQueryBuilder first() {
    get(0);
    return this;
  }

  /// Sets the range for the query.
  ///
  /// [start] - The start index.
  /// [end] - The end index.
  SanityQueryBuilder range(int start, int end) {
    _start = start;
    _end = end;
    return this;
  }

  /// Adds a mutation function to the query.
  ///
  /// [function] - The mutation function to add.
  SanityQueryBuilder mutate(String function) {
    _mutations.add('$function()');
    return this;
  }

  /// Adds a parameter to the query.
  ///
  /// [name] - The name of the parameter.
  /// [value] - The value of the parameter.
  SanityQueryBuilder param(String name, dynamic value) {
    _params[name] = value;
    return this;
  }

  /// Builds the Sanity query.
  ///
  /// Returns a [SanityQuery] object containing the constructed query and parameters.
  SanityQuery build() {
    final queryParts = <String>['*'];

    if (_filters.isNotEmpty) {
      queryParts.add('[${_filters.join('')}]'
          .replaceAll('[ && ', '[')
          .replaceAll('( && ', ' && (')
          .replaceAll('[ || ', '[')
          .replaceAll('( || ', ' || ('));
    }

    if (_orderSpecs.isNotEmpty) {
      queryParts.add(' | order(${_orderSpecs.join(', ')})');
    }

    if (_mutations.isNotEmpty) {
      queryParts.add(' | ${_mutations.join(' | ')}');
    }

    if (_start != null && _end != null) {
      queryParts.add('[$_start..$_end]');
    } else if (_index != null) {
      queryParts.add('[$_index]');
    }

    if (_projection != null) {
      queryParts.add('{${_buildProjection(_projection!)}}');
    }

    return SanityQuery(
      query: queryParts.join(''),
      params: _params,
    );
  }

  String _buildProjection(Map<String, dynamic> projection) {
    return projection.entries.map((entry) {
      final key = entry.key;
      final value = entry.value;

      if (key == '...') return '...';

      if (value is Map<String, dynamic>) {
        final isArray = key.contains('[]');
        final isReference = key.contains('->');
        final cleanKey = key.replaceAll(RegExp(r'\[\]|->'), '');
        final modifiers = [
          if (isArray) '[]',
          if (isReference) '->',
        ].join();

        return '$cleanKey$modifiers{${_buildProjection(value)}}';
      }

      if (value is String) return '"$key": $value';

      return key;
    }).join(', ');
  }
}
