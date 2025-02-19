# Sanity Query Builder

The Query Builder library provides a fluent interface to help you build complex queries programmatically. It breaks down the query creation process into modular parts that let you combine filters, projections, sorting, slicing, mutations, and parameter binding in a natural, chainable way.

## Key Concepts

- **Query**: The complete statement you send for execution. It includes filters, ordering, range selections, projections, and any additional modifications.
- **Projection**: Specifies which fields (and nested sub-fields) to return as part of the query result.
- **Filters**: Conditions that limit the query results to documents that meet certain criteria.
- **Ordering**: Determines the sort order of the query results.
- **Range / Indexing**: Used for pagination or selecting a subset of the results.
- **Mutations**: Functions applied to the results or documents, if your query requires any transformation.
- **Parameters**: Dynamic values that are bound to the query at execution time.

## Features

- **Fluent API**: Easily chain method calls to construct queries.
- **Flexible Filtering**: Add simple filters, complex grouped filters (using parentheses), or raw conditions.
- **Detailed Projections**: Define exactly which fields to include, with support for nested objects, arrays, and references.
- **Ordering and Slicing**: Specify sort orders and limit the result set through ranges or direct indexing.
- **Dynamic Parameters**: Bind variables to your query to handle dynamic values.
- **Mutations**: Optionally apply functions to manipulate or transform the data.

## Usage

### 1. Building Projections

Projections let you select the fields and nested objects to return. You can specify individual fields, alias expressions, arrays, references, and nested objects.

```dart
final projection = ProjectionBuilder()
    .field('title')
    .field('slug')
    .object('author', (pb) => pb
        .field('name')
        .field('profileImage')
    )
    .array('comments', (pb) => pb
        .field('text')
        .object('user', (subPb) => subPb.field('username'))
    )
    .spread() // Include all other fields that aren't explicitly defined.
    .build();
```

### 2. Constructing the Query

You can build a complete query by combining filters, ordering, range selection, mutations, and the projection. The query builder lets you:

- **Filter Documents**: Use conditions such as type, specific field values, and even group conditions using parentheses.
- **Order Results**: Define how the results should be sorted.
- **Select Ranges**: Limit the result set to a specific index range or a single document.
- **Bind Parameters**: Attach dynamic values to your query.

```dart
final query = SanityQueryBuilder()
    .type('post')  // Filter by document type.
    .where('published', '==', true) // Only include published posts.
    .inParentheses((qb) => qb
        .where('rating', '>=', 4)
        .orWhere('views', '>', 1000)) // Grouped filters for rating or views.
    .project(projection) // Attach the projection built earlier.
    .order('date', 'desc') // Sort by date in descending order.
    .range(0, 10) // Limit to the first 10 documents.
    .param('customParam', 'example') // Bind any custom parameter if needed.
    .build();

print('Query: ${query.query}');
print('Params: ${query.params}');
```

### 3. Executing the Query

The result of the build process is a `SanityQuery` object that contains:

- **query**: The complete query string.
- **params**: A map of any bound parameters.

You can then pass these to your data-fetching function to execute the query against your dataset.