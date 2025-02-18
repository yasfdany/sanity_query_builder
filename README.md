# **Sanity Query Builder for Flutter**

A powerful and flexible query builder for constructing GROQ queries for Sanity.io in Flutter applications. This package simplifies the process of building complex queries with support for filtering, projections, ordering, pagination, and mutations.

## **Features**

* **Type-safe query building**: Easily construct GROQ queries with a fluent API.  
* **Filtering**: Add conditions to your queries with `where` and `whereRaw`.  
* **Projections**: Select specific fields and nested documents.  
* **Ordering**: Sort results by one or more fields.  
* **Pagination**: Limit results using `range`.  
* **Mutations**: Apply GROQ mutations like `count` or `reverse`.  
* **Custom Parameters**: Add reusable parameters to your queries.

## **Installation**

Add the package to your `pubspec.yaml`:  

```
dependencies:  
  sanity_query_builder: latest
```

Then run:  
```
flutter pub get
```

## **Usage**

### **Basic Query**

```
import 'package:sanity_query_builder/sanity_query_builder.dart';

final query = SanityQueryBuilder()  
  .type('post')  
  .where('publishedAt', '<=', '2023-01-01')  
  .project({  
    'title': true,  
    'author': {  
      'name': true,  
    },  
  })  
  .build();

print(query.query); // *[[_type == $p0 && publishedAt <= $p1]]{title, author->{name}}  
print(query.params); // {p0: 'post', p1: '2023-01-01'}
```

### **Pagination and Sorting**

```
final query = SanityQueryBuilder()  
  .type('product')  
  .order('price', 'desc')  
  .range(0, 9)  
  .project({  
    'name': true,  
    'price': true,  
  })  
  .build();

print(query.query); // *[[_type == $p0]]{name, price} | order(price desc) [0..9]  
print(query.params); // {p0: 'product'}
```

### **Complex Query with Mutations**

``` 
final query = SanityQueryBuilder()  
  .type('order')  
  .where('status', '==', 'completed')  
  .mutate('count')  
  .build();

print(query.query); // *[[_type == $p0 && status == $p1]] | count()  
print(query.params); // {p0: 'order', p1: 'completed'}
```

## **API Reference**

### **SanityQueryBuilder**

#### **Methods**

| Method | Description |
| :---- | :---- |
| `type(String type)` | Filters documents by the specified type. |
| `slug(String slug)` | Filters documents by the specified slug. |
| `where(String field, String operator, dynamic value)` | Adds a filter condition. |
| `whereRaw(String condition)` | Adds a raw filter condition. |
| `project(Map<String, dynamic> projection)` | Sets the projection for the query. |
| `order(String field, [String direction = 'asc'])` | Adds an order specification. |
| `range(int start, int end)` | Sets the range for pagination. |
| `mutate(String function)` | Adds a mutation function. |
| `param(String name, dynamic value)` | Adds a custom parameter. |
| `build()` | Builds the query and returns a `SanityQuery` object. |