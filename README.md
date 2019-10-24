# Apex Test Kit 2.0
<a href="https://githubsfdeploy.herokuapp.com">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

![](https://img.shields.io/badge/version-2.1.2-brightgreen.svg) ![](https://img.shields.io/badge/build-passing-brightgreen.svg) ![](https://img.shields.io/badge/coverage-%3E95%25-brightgreen.svg)

Apex Test Kit is a Salesforce library to help generate testing data for Apex test classes. It has the following features:

1. Generate good-looking names for username, email, phone number etc.
2. Automatically guess values for required fields and deal with uniqueness.
3. Establish arbitrary level many to many relationships.

```java
// Create 10 accounts each with 2 contacts
ATKCommand.prepare(Account.SObjectType)
    .total(10)
    .fields()
        .eval(Account.Name).index('Name-{0}')           // Name-0, Name-1, Name-2 ...
        .eval(Account.AccountNumber).fake('{{?*****}}') // alpha + 6 * alphanumeric
        .eval(Account.NumberOfEmployees).number(8, 0)   // an integer of 8 digits
        .eval(Account.Fax).phone()                      // a standard US phone format
        .eval(Account.Description).paragraphs()         // multiple line text
        .eval(Account.Industry).guess()                 // pick any from the picklist
        .eval(Account.Website).guess()                  // pick any valid url
    .end()
    .haveMany(Contact.SObjectType)
        .referenceBy(Contact.AccountId)
        .total(20)
        .fields()
            .eval(Contact.FirstName).firstName()        // pick one from ~3000 first names
            .eval(Contact.LastName).lastName()          // pick one from ~500 last names
            .eval(Contact.Birthdate).past()             // a date in past 3 years
            .eval(Contact.Email).email()                // a valid email address
            .eval(Contact.DoNotCall).value(false)       // fixed value equal to false
            .eval(Contact.Title).repeat('Mr.', 'Ms.')   // repeat 'Mr.', 'Ms.'
        .end()
    .generate();
```

Underneath, the data are automatically guessed with appropriate values according to field types, including: BOOLEAN, DATE, TIME, DATETIME, DOUBLE, INTEGER, PERCENT, CURRENCY, PICKLIST, MULTIPICKLIST, STRING, TEXTAREA, EMAIL, URL, PHONE, ADDRESS.

### Version 2.0 Highlight

* Enfore strong types rather than passing strings around as parameters, such as
  * Use sObjectType instead of sObject name string
  * Use sObjectField instead of field name string
  * Use method instead of faker generation expression
* Put functional programming into extreme. It becomes a delightful experience to code.
* Performance tuning. Have to make trade-offs between "good-looking names" and performance, and `index()` and `repeat()` keywords are introduced for performance considerations.
* ~~(v2.1.1) Decompose generation logic into reusable templates, and reuse them with the  `useTemp()` keyword.~~

### Roadmap

* Provide in-memory dummy sObject graph generation. This will have performance benefit for not triggering triggers and process builder.
* Performance tuning in two possbile directions:
  * Use sequence generation to replace the random generation, so data can be consistent
  * Add flag to switch generation logic to less "good-looking" mode.

### Caveat

1. Sometime ramdom values could bring uncertainty to test results. In such case, please specify the faker genereation expression explicitly or a fixed value.
2. The current field generation capacity is around 15000 in 15 seconds. If there are 30 generated fields (not fixed values) per record, the max record generation capacity is around 500. And consider any trigger and process builder, the actually record capacity should be less than 500. If more are created, it will hit the CPU limit.
3. If record type is activated and there are picklist values depending on them, please try to declare the picklist values in the `fields()` explicitly for that record type.

## Usage of ATKCommand

All examples in `src/classes/SampleTest.cls` can be successfully run in a clean Salesforce CRM organization. Please also reference it as more examples for how to use this library.

### 1. Setup Relationship

#### 1.1 One to Many

**Note**: the following `referenceBy()` keyword can be omitted, because there is only one Contact->Account relationship field on Contact sObject.

```java
ATKCommand.prepare(Account.SObjectType)
    .total(10)
    .haveMany(Contact.SObjectType)
        .referenceBy(Contact.AccountId)             // can be omitted
        .total(40)
    .generate();
```

#### 1.2 Many to One

```java
ATKCommand.prepare(Contact.SObjectType)
    .total(40)
    .belongTo(Account.SObjectType)
        .referenceBy(Contact.AccountId)             // can be omitted
        .total(10)
    .generate();
```

#### 1.3 Many to Many

```java
Id pricebook2Id = Test.getStandardPricebookId();

ATKCommand.ResultMap results = ATKCommand.prepare(Product2.SObjectType)
    .total(5)
    .haveMany(PricebookEntry.SObjectType)
        .referenceBy(PricebookEntry.Product2Id)     // can be omitted
        .total(5)
        .fields()
            .eval(PricebookEntry.Pricebook2Id).value(pricebook2Id)
            .eval(PricebookEntry.UseStandardPrice).value(false)
            .eval(PricebookEntry.IsActive).value(true)
        .end()
    .generate();

ATKCommand.prepare(Pricebook2.SObjectType)
    .total(5)
    .haveMany(PricebookEntry.SObjectType)
        .referenceBy(PricebookEntry.Pricebook2Id)   // can be omitted
        .total(25)
        .fields()
            .eval(PricebookEntry.UseStandardPrice).value(false)
            .eval(PricebookEntry.IsActive).value(true)
        .end()
        .belongTo(Product2.SObjectType)
            .referenceBy(PricebookEntry.Product2Id) // can be omitted
            .useList(results.get(Product2.SObjectType))
    .generate();
```

### 2. Keyword Overview

#### 2.1 Context Initialization Keywords

Each of them will start a new sObject context. And it is advised to use the following indentation for clarity.

```java
ATKCommand.prepare(A__c.SObjectType)
    .haveMany(B__c.SObjectType)
        .belongTo(C__c.SObjectType)
            .haveMany(D__c.SObjectType)
    .generate();
```

| Keyword     | Param  | Description                                                  |
| ----------- | ------ | ------------------------------------------------------------ |
| prepare()  | SObjectType | Always start chain with `prepare()` keyword. It is the root sObject to start relationship with. |
| haveMany()   | SObjectType | Establish one to many relationship between the previous working on sObject and the current sObject. |
| belongTo() | SObjectType | Establish many to one relationship between the previous working on sObject and the current sObject. |

#### 2.2 Context Decoration Keywords

Here is an example to demo the use of all entity decoration keywords. Although sounds many, for basic usage only `total()` and `fields()` will be used frequently and with occasional use of `referenceBy()`.

```java
// create 10 A, each has 2 B.
List<A__c> aList = [SELECT Id FROM A__c Limit 10];
ATKCommand.prepare(A__c.SObjectType)
    .useList(aList);
    .haveMany(B__c.SObjectType)
        .referenceBy(B__C.A_ID__c)
        .total(20)
        .fields()
           .guard(false)
           .eval(B__C.AnyField__c).guess()
           .eval(B__C.Price__c).value(12.34)
           .eval(B__C.PhoneNumber__c).phone()
           .eval(B__C.FirstName__c).firstName()
           .eval(B__C.Counter__c).value(1)
           .xref(B__C.Counter__c).add('$1.Counter__c', 1)
        .end()
    .generate();
```

| Keyword       | Param           | Description                                                  |
| ------------- | --------------- | ------------------------------------------------------------ |
| useList()     | List\<sObject\> | **Required***, only if `total()` is not used. This tells the wizard to use the previously created sObject list, rather than to create the records from scratch. |
| total()       | Integer         | **Required***, only if `useList()` is not used. It defines number of records to create for the attached sObject context. |
| referenceBy() | SObjectField    | **Optional**. Only use this keyword if there are multiple fields on the entity referencing to the same sObject types, i.e. two contact relationship fields on account. |
| also()        | Integer         | It can be used to switch back to any previous sObject context. Note: also must follow with `haveMany()` not `belongTo()` currently. |
| fields()      | N/A             | **Optional**. Start of declaring field generation logic. More will be explained in next section. |

The following is an example to demo how to use `also()` keyword:

```java
ATKCommand.prepare(A__c.SObjectType)
    .haveMany(B__c.SObjectType)
    .also() // go back 1 sObject (B) to sObject (A)
    .haveMany(C__c.SObjectType)
        .belongTo(D__c.SObjectType)
    .also(2) // go back 2 sObject (C, D) to sObject (A)
    .haveMany(E__c.SObjectType)
    .generate();
```

#### 2.3 Field Decoration Keywords

Only use `guard()`, `eval()`, `xref()`, between `fields()` and `end()` keywords. And every `fields()` must follow an `end()` at the bottom.

```java
.fields()
    .guard(false)
    .eval(ObjectA__c.Counter__c).value(1)                // Counter_c starts with 1
    .xref(ObjectA__c.Counter__c).add('$1.Counter__c', 1) // compute previous Counter_c + 1
.end()
```

| Keyword   | Param                          | Description                                                  |
| --------- | ------------------------------ | ------------------------------------------------------------ |
|         |              |                                                              |
| end()     | N/A                            | **Required***, only if `fields()` is used. End of declaring field generation logic. |
| guard()   | [Boolean]                      | **Optional**. Turn on guard for `REQUIRED_FIELD_MISSING` exceptions by implicitly guessing values for fields not defined in `eval()` and `xref()`. 80% of the time, implicit guessing is useful, so guard is tuned on by default. But you would like to disable it for sObjects having many required fields, i.e. User and Event etc. |
| eval() | SObjectField        | **Optional**. Use this keyword to tailor the field values, either to bypass validation rules, or fulfill assertion logics. |
| xref() | SObjectField | **Optional**. Use this keyword if need cross record arithmetic. More will be explained in the following section. |

#### 2.4 Eval Decoration Keywords

Users can have great control over the following keyword evaluation. Please use `index()`, `value()`, `repeat()` as the first choice, since they are more predictable and efficient.

```java
eval().fake('{!name.firstName} {{####}}'); // use two ATKFaker expressions
eval().index('Name-{0}');                  // Name-0, Name-1, Name-2 etc.
eval().value(Object value);                // any value of the field data type
eval().repeat(List<Object> values);        // a list of values of the field data type
eval().repeat(Object value1, Object value2);
eval().repeat(Object value1, Object value2, Object value3);
```

Users cannot control the following keyword evaluation, and the values are produced randomly.

```java
eval().guess()                          // guess value based on field data type
eval().userName()
eval().email()
eval().url()
eval().phone()                          // various US phone number format
eval().number(8, 0)                     // precision 8, scale 0
eval().past()                           // a date/datetime in past 3 years
eval().future()                         // a date/datetime in next 3 years
eval().between('2018-1-1', '2019-1-1')  // params are in ISO date/datetime formats
eval().firstName()                      // pick up a name from ~3000 names
eval().lastName()                       // pick up a name from ~500 names
eval().word()                           // generate 1 lorem word
eval().words()                          // generate 3 lorem words
eval().sentence()                       // generate 1 sentence with 3-10 lorm words
eval().sentences()                      // generate 2-6 sentences
eval().paragraph()                      // generate 3-6 sentences
eval().paragraphs()                     // generate 3 paragraph
```

#### 2.5 Xref Decoration Keywords

```java
xref().value('$0.StartDate')            // use the StartDate of current record
xref().add('$1.Counter__c', 1)          // add 1 from Counter__C of previous record
xref().substract('$1.Counter__c', 1)    // subsract 1 from Counter__C of previous record
xref().divide(String field, Object value)
xref().multiply(String field, Object value)
xref().addYears('$1.StartDate', 1)      // add 1 year to the StartDate of previous record
xref().addMonths(String field, Integer value)
xref().addDays(String field, Integer value)
xref().addHours(String field, Integer value)
xref().addMinutes(String field, Integer value)
xref().addSeconds(String field, Integer value)
```

With `xref()`, we can perform arithmetic calculations according to fields on previously created records. For example, we can create records with consecutive start dates and end dates as below. `$0` represents current record, `$1` represents previous one record, and so on. If field reference is `$1`, `xref()` must work with a corresponding `eval().value()`. And if field reference is `$2` and above, `xref()` must work with a corresponding `eval().repeat()`.

```java
Datetime currentDatetime = Datetime.now();
ATKCommand.prepare(Event.SObjectType)
    .total(10)
    .fields()
    	.guard(false)
        .eval(Event.DurationInMinutes).value(24 * 60)
    	.eval(Event.StartDateTime).value(currentDatetime)       // specify init value for $1
        .xref(Event.StartDateTime).addDays('$1.EndDateTime', 1)
        .xref(Event.EndDateTime)addDays('$0.StartDateTime', 1)
        .xref(Event.ActivityDateTime).value('$0.StartDateTime') // always equal to StartDate
    .end()
    .generate();
```

## Usage of ATKFaker

ATKCommand is built on top of the ATKFaker, which can also be used standalone. It is ported from [faker.js](https://github.com/marak/Faker.js/).

### 1 Interpolation

All of the following helper APIs also support Interpolation from string expressions.

#### 1.1 Symbol Interpolation

Use `{{   }}` Handlebars expression notation to interpolate symbol formats.

```java
ATKFaker.fake('{{###-###-####}}');
```

* \# - number
* ? - alpha
* \* - alphanumeric

#### 1.2 Helper Interpolation

Use `{!   }` Visualforce expression notation to interpolate helper methods. Empty parenthesis can be omitted.

```java
ATKFaker.fake('Hello {!name.firstName(male)} {!name.lastName}!'); // => 'Hello Jeff Jin!'
```



### 2 Helper APIs

All following APIs can be used in `ATKFaker.fake()` and `eval().fake()` as a helper string.

1. remove the `ATKFaker.`
2. remove the single quote for string parameter
3. remove empty parentheses optionally

#### 2.1 Name

```java
ATKFaker.name.firstName();
ATKFaker.name.lastName();
```

#### 2.2 Internet

```java
ATKFaker.internet.userName();
ATKFaker.internet.email();
ATKFaker.internet.url();
```

#### 2.3 Phone

```java
ATKFaker.phone.phoneNumber();
ATKFaker.phone.phoneNumber('1xx-xxx-xxxx');
```

#### 2.4 Random

```java
ATKFaker.random.boolean();
ATKFaker.random.number();         // => 0-999
ATKFaker.random.number(99);       // number(max) => 0-99
ATKFaker.random.number(5, 2);     // number(precesion, scale) => 123.45
ATKFaker.random.number(0, 99, 2); // number(min, max, scale) => 75.23
ATKFaker.random.arrayElements(new List<Integer> { 1, 2, 3, 4, 5 });
ATKFaker.random.arrayElements(new List<Integer> { 1, 2, 3, 4, 5 }, 3); // => {2, 4, 5}
```

#### 2.5 Lorem

```java
ATKFaker.lorem.word();
ATKFaker.lorem.words();
ATKFaker.lorem.sentence();
ATKFaker.lorem.sentences();
ATKFaker.lorem.paragraph();
ATKFaker.lorem.paragraphs();
ATKFaker.lorem.lines();
ATKFaker.lorem.text();
```

#### 2.6 Dates

```java
ATKFaker.dates.past();
ATKFaker.dates.past(3, '2018-08-13'); // date in 3 years before 2018-08-13
ATKFaker.dates.future()
ATKFaker.dates.future(3, '2018-08-13'); // date in 3 years after 2018-08-13
ATKFaker.dates.between('2017-08-13', '2018-08-13');
```

## License

MIT License
