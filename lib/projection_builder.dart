import 'package:sanity_query_builder/sanity_query_builder.dart';

class ProjectionBuilder {
  final Map<String, dynamic> _projection = {};

  ProjectionBuilder field(String name) {
    _projection[name] = null;
    return this;
  }

  ProjectionBuilder spread() {
    _projection['...'] = null;
    return this;
  }

  ProjectionBuilder alias(String alias, String expression) {
    _projection[alias] = expression;
    return this;
  }

  ProjectionBuilder array(
    String fieldName,
    ProjectionBuilder Function(ProjectionBuilder) builder,
  ) {
    _projection['$fieldName[]'] = builder(ProjectionBuilder())._projection;
    return this;
  }

  ProjectionBuilder reference(
    String fieldName,
    ProjectionBuilder Function(ProjectionBuilder) builder,
  ) {
    _projection['$fieldName->'] = builder(ProjectionBuilder())._projection;
    return this;
  }

  ProjectionBuilder arrayReference(
    String fieldName,
    ProjectionBuilder Function(ProjectionBuilder) builder,
  ) {
    _projection['$fieldName[]->'] = builder(ProjectionBuilder())._projection;
    return this;
  }

  ProjectionBuilder object(
    String fieldName,
    ProjectionBuilder Function(ProjectionBuilder) builder,
  ) {
    _projection[fieldName] = builder(ProjectionBuilder())._projection;
    return this;
  }

  ProjectionBuilder query(
    String fieldName,
    SanityQueryBuilder query,
  ) {
    _projection[fieldName] = query.build().query;
    return this;
  }

  ProjectionBuilder rawQuery(
    String fieldName,
    String query,
  ) {
    _projection[fieldName] = query;
    return this;
  }

  Map<String, dynamic> build() {
    return _projection;
  }
}
