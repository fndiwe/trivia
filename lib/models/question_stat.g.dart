// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_stat.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetQuestionStatCollection on Isar {
  IsarCollection<QuestionStat> get questionStats => this.collection();
}

const QuestionStatSchema = CollectionSchema(
  name: r'QuestionStat',
  id: 4752692621136555130,
  properties: {
    r'lastAnsweredAt': PropertySchema(
      id: 0,
      name: r'lastAnsweredAt',
      type: IsarType.dateTime,
    ),
    r'question': PropertySchema(
      id: 1,
      name: r'question',
      type: IsarType.string,
    ),
    r'timesCorrect': PropertySchema(
      id: 2,
      name: r'timesCorrect',
      type: IsarType.long,
    ),
    r'timesShown': PropertySchema(
      id: 3,
      name: r'timesShown',
      type: IsarType.long,
    ),
  },
  estimateSize: _questionStatEstimateSize,
  serialize: _questionStatSerialize,
  deserialize: _questionStatDeserialize,
  deserializeProp: _questionStatDeserializeProp,
  idName: r'id',
  indexes: {
    r'question': IndexSchema(
      id: -953778862691381243,
      name: r'question',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'question',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _questionStatGetId,
  getLinks: _questionStatGetLinks,
  attach: _questionStatAttach,
  version: '3.1.0+1',
);

int _questionStatEstimateSize(
  QuestionStat object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.question.length * 3;
  return bytesCount;
}

void _questionStatSerialize(
  QuestionStat object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.lastAnsweredAt);
  writer.writeString(offsets[1], object.question);
  writer.writeLong(offsets[2], object.timesCorrect);
  writer.writeLong(offsets[3], object.timesShown);
}

QuestionStat _questionStatDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = QuestionStat(
    lastAnsweredAt: reader.readDateTimeOrNull(offsets[0]),
    question: reader.readString(offsets[1]),
    timesCorrect: reader.readLongOrNull(offsets[2]) ?? 0,
    timesShown: reader.readLongOrNull(offsets[3]) ?? 0,
  );
  object.id = id;
  return object;
}

P _questionStatDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 3:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _questionStatGetId(QuestionStat object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _questionStatGetLinks(QuestionStat object) {
  return [];
}

void _questionStatAttach(
  IsarCollection<dynamic> col,
  Id id,
  QuestionStat object,
) {
  object.id = id;
}

extension QuestionStatByIndex on IsarCollection<QuestionStat> {
  Future<QuestionStat?> getByQuestion(String question) {
    return getByIndex(r'question', [question]);
  }

  QuestionStat? getByQuestionSync(String question) {
    return getByIndexSync(r'question', [question]);
  }

  Future<bool> deleteByQuestion(String question) {
    return deleteByIndex(r'question', [question]);
  }

  bool deleteByQuestionSync(String question) {
    return deleteByIndexSync(r'question', [question]);
  }

  Future<List<QuestionStat?>> getAllByQuestion(List<String> questionValues) {
    final values = questionValues.map((e) => [e]).toList();
    return getAllByIndex(r'question', values);
  }

  List<QuestionStat?> getAllByQuestionSync(List<String> questionValues) {
    final values = questionValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'question', values);
  }

  Future<int> deleteAllByQuestion(List<String> questionValues) {
    final values = questionValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'question', values);
  }

  int deleteAllByQuestionSync(List<String> questionValues) {
    final values = questionValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'question', values);
  }

  Future<Id> putByQuestion(QuestionStat object) {
    return putByIndex(r'question', object);
  }

  Id putByQuestionSync(QuestionStat object, {bool saveLinks = true}) {
    return putByIndexSync(r'question', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByQuestion(List<QuestionStat> objects) {
    return putAllByIndex(r'question', objects);
  }

  List<Id> putAllByQuestionSync(
    List<QuestionStat> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'question', objects, saveLinks: saveLinks);
  }
}

extension QuestionStatQueryWhereSort
    on QueryBuilder<QuestionStat, QuestionStat, QWhere> {
  QueryBuilder<QuestionStat, QuestionStat, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension QuestionStatQueryWhere
    on QueryBuilder<QuestionStat, QuestionStat, QWhereClause> {
  QueryBuilder<QuestionStat, QuestionStat, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterWhereClause> questionEqualTo(
    String question,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'question', value: [question]),
      );
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterWhereClause>
  questionNotEqualTo(String question) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'question',
                lower: [],
                upper: [question],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'question',
                lower: [question],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'question',
                lower: [question],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'question',
                lower: [],
                upper: [question],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension QuestionStatQueryFilter
    on QueryBuilder<QuestionStat, QuestionStat, QFilterCondition> {
  QueryBuilder<QuestionStat, QuestionStat, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterFilterCondition>
  lastAnsweredAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastAnsweredAt'),
      );
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterFilterCondition>
  lastAnsweredAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastAnsweredAt'),
      );
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterFilterCondition>
  lastAnsweredAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastAnsweredAt', value: value),
      );
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterFilterCondition>
  lastAnsweredAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastAnsweredAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterFilterCondition>
  lastAnsweredAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastAnsweredAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterFilterCondition>
  lastAnsweredAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastAnsweredAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterFilterCondition>
  questionEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'question',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterFilterCondition>
  questionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'question',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterFilterCondition>
  questionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'question',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterFilterCondition>
  questionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'question',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterFilterCondition>
  questionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'question',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterFilterCondition>
  questionEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'question',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterFilterCondition>
  questionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'question',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterFilterCondition>
  questionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'question',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterFilterCondition>
  questionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'question', value: ''),
      );
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterFilterCondition>
  questionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'question', value: ''),
      );
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterFilterCondition>
  timesCorrectEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'timesCorrect', value: value),
      );
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterFilterCondition>
  timesCorrectGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'timesCorrect',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterFilterCondition>
  timesCorrectLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'timesCorrect',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterFilterCondition>
  timesCorrectBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'timesCorrect',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterFilterCondition>
  timesShownEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'timesShown', value: value),
      );
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterFilterCondition>
  timesShownGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'timesShown',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterFilterCondition>
  timesShownLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'timesShown',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterFilterCondition>
  timesShownBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'timesShown',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension QuestionStatQueryObject
    on QueryBuilder<QuestionStat, QuestionStat, QFilterCondition> {}

extension QuestionStatQueryLinks
    on QueryBuilder<QuestionStat, QuestionStat, QFilterCondition> {}

extension QuestionStatQuerySortBy
    on QueryBuilder<QuestionStat, QuestionStat, QSortBy> {
  QueryBuilder<QuestionStat, QuestionStat, QAfterSortBy>
  sortByLastAnsweredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAnsweredAt', Sort.asc);
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterSortBy>
  sortByLastAnsweredAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAnsweredAt', Sort.desc);
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterSortBy> sortByQuestion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'question', Sort.asc);
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterSortBy> sortByQuestionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'question', Sort.desc);
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterSortBy> sortByTimesCorrect() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timesCorrect', Sort.asc);
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterSortBy>
  sortByTimesCorrectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timesCorrect', Sort.desc);
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterSortBy> sortByTimesShown() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timesShown', Sort.asc);
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterSortBy>
  sortByTimesShownDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timesShown', Sort.desc);
    });
  }
}

extension QuestionStatQuerySortThenBy
    on QueryBuilder<QuestionStat, QuestionStat, QSortThenBy> {
  QueryBuilder<QuestionStat, QuestionStat, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterSortBy>
  thenByLastAnsweredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAnsweredAt', Sort.asc);
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterSortBy>
  thenByLastAnsweredAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAnsweredAt', Sort.desc);
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterSortBy> thenByQuestion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'question', Sort.asc);
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterSortBy> thenByQuestionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'question', Sort.desc);
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterSortBy> thenByTimesCorrect() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timesCorrect', Sort.asc);
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterSortBy>
  thenByTimesCorrectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timesCorrect', Sort.desc);
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterSortBy> thenByTimesShown() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timesShown', Sort.asc);
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QAfterSortBy>
  thenByTimesShownDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timesShown', Sort.desc);
    });
  }
}

extension QuestionStatQueryWhereDistinct
    on QueryBuilder<QuestionStat, QuestionStat, QDistinct> {
  QueryBuilder<QuestionStat, QuestionStat, QDistinct>
  distinctByLastAnsweredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastAnsweredAt');
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QDistinct> distinctByQuestion({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'question', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QDistinct> distinctByTimesCorrect() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timesCorrect');
    });
  }

  QueryBuilder<QuestionStat, QuestionStat, QDistinct> distinctByTimesShown() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timesShown');
    });
  }
}

extension QuestionStatQueryProperty
    on QueryBuilder<QuestionStat, QuestionStat, QQueryProperty> {
  QueryBuilder<QuestionStat, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<QuestionStat, DateTime?, QQueryOperations>
  lastAnsweredAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastAnsweredAt');
    });
  }

  QueryBuilder<QuestionStat, String, QQueryOperations> questionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'question');
    });
  }

  QueryBuilder<QuestionStat, int, QQueryOperations> timesCorrectProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timesCorrect');
    });
  }

  QueryBuilder<QuestionStat, int, QQueryOperations> timesShownProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timesShown');
    });
  }
}
