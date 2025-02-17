/**
 * Apex Test Kit
 */
public with sharing class ATKFaker {
    public static Map<String, ATKReflect.IValueProvider> helpers { get; set; }
    public static Internet internet { get; set; }
    public static Phone phone { get; set; }
    public static Name name { get; set; }
    public static Lorem lorem { get; set; }
    public static DateHelper dates { get; set; }
    public static Finance finance { get; set; }
    public static Random random { get; set; }
    public static Helper helper { get; set; }
    @TestVisible
    private static NumberArithmeticHelper numbers { get; set; }
    @TestVisible
    private static ValueArithmeticHelper value { get; set; }

    @TestVisible
    private static ATKFakerDefinition definition = new ATKFakerDefinition();

    static {
        internet = new Internet();
        phone = new Phone();
        random = new Random();
        finance = new Finance();
        lorem = new Lorem();
        dates = new DateHelper();
        name = new Name();
        helper = new Helper();
        numbers = new NumberArithmeticHelper();
        value = new ValueArithmeticHelper();

        helpers = new Map<String, ATKReflect.IValueProvider>();
        helpers.put('internet', internet);
        helpers.put('phone', phone);
        helpers.put('random', random);
        helpers.put('finance', finance);
        helpers.put('lorem', lorem);
        helpers.put('dates', dates);
        helpers.put('name', name);
        helpers.put('helper', helper);
        helpers.put('numbers', numbers);
        helpers.put('value', value);
    }

    public static Object fake(String input) {
        ATKReflect.IMethodEval methodGroup = ATKReflect.METHOD_PARSER.parse(input);
        return methodGroup.evaluate(helpers);
    }

    /**
     * PROVIDERS
     */
    @TestVisible
    public class Helper implements ATKReflect.IValueProvider {
        public Object call(String method, List<Object> params) {
            Object param0;
            if (params != null) {
                if (params.size() > 0) {
                    param0 = params.get(0);
                }
            }
            Object output;
            switch on method {
                when 'replaceSymbols' {
                    output = replaceSymbols(ATKCommon.CONVERTER.toString(param0));
                }
                when else {

                }
            }
            return output;
        }

        public Object randomize(List<Object> elements) {
            elements = elements == null ? new List<Object> { 'a', 'b', 'c' } : elements;
            return random.arrayElement(elements);
        }

        public String slugify(String input) {
            if (input == null) {
                input = '';
            }
            return input.replaceAll(' ', '-')
                .replaceAll('[^\\w\\.\\-]+', '')
                .replaceAll('--+', '-');
        }

        public String replaceSymbolsWithNumber(String input) {
            return replaceSymbolsWithNumber(input, null);
        }

        public String replaceSymbolsWithNumber(String input, String symbol) {
            input = input == null ? '' : input;
            symbol = symbol == null ? '#' : symbol;
            Integer numberSignChar = symbol.charAt(0);
            Integer exclamationChar = '!'.charAt(0);
            Integer[] chars = input.getChars();

            ATKCommon.StringBuilder builder = new ATKCommon.StringBuilder();
            for (Integer i = 0; i < chars.size(); i++) {
                if (chars[i] == numberSignChar) {
                    builder.append(String.valueOf(random.number(0, 9, 0)));
                } else if (chars[i] == exclamationChar) {
                    builder.append(String.valueOf(random.number(2, 9, 0)));
                } else {
                    builder.append(String.fromCharArray(new Integer[]{chars[i]}));
                }
            }
            return builder.toString();
        }

        public String replaceSymbols(String input) {
            input = input == null ? '' : input;
            Integer numberSignChar = '#'.charAt(0);
            Integer questionMarkChar = '?'.charAt(0);
            Integer asteriskChar = '*'.charAt(0);

            Integer[] chars = input.getChars();
            ATKCommon.StringBuilder builder = new ATKCommon.StringBuilder();
            List<String> alphaList = definition.get(ATKFakerDefinition.FAKER_SYMBOL_ALPHA);
            for (Integer i = 0; i < chars.size(); i++) {
                if (chars[i] == numberSignChar) {
                    builder.append(random.number(0, 9, 0));
                } else if (chars[i] == questionMarkChar) {
                    builder.append((String)random.arrayElement(alphaList));
                } else if (chars[i] == asteriskChar) {
                    builder.append(random.boolean() ?
                        (String)random.arrayElement(alphaList) :
                        String.valueOf(random.number(0, 9, 0)));
                } else {
                    builder.append(String.fromCharArray(new Integer[]{chars[i]}));
                }
            }
            return builder.toString();
        }
    }

    public class Random implements ATKReflect.IValueProvider {
        private Integer RANDOM_NUMBER_CACHE_SIZE = -1; // disable random number cache
        private List<Double> randomNumberCache = new List<Double>();
        private Integer randomNumberIndex = 0;

        public Object call(String method, List<Object> params) {
            Object param0;
            Object param1;
            Object param2;
            if (params != null) {
                if (params.size() > 0) {
                    param0 = params.get(0);
                }
                if (params.size() > 1) {
                    param1 = params.get(1);
                }
                if (params.size() > 2) {
                    param2 = params.get(2);
                }
            }

            Object output;
            switch on method {
                when 'boolean' {
                    output = boolean();
                }
                when 'number' {
                    if (params != null) {
                        if (params.size() == 1) {
                            Decimal max = ATKCommon.CONVERTER.toDecimal(param0);
                            output = number(max);
                        } else if (params.size() == 2) {
                            Integer precision = ATKCommon.CONVERTER.toInteger(param0);
                            Integer scale = ATKCommon.CONVERTER.toInteger(param1);
                            output = number(precision, scale);
                        } else {
                            Decimal min = ATKCommon.CONVERTER.toDecimal(param0);
                            Decimal max = ATKCommon.CONVERTER.toDecimal(param1);
                            Integer scale = ATKCommon.CONVERTER.toInteger(param2);
                            output = number(min, max, scale);
                        }
                    }
                    else {
                        output = number(null, null, null);
                    }
                }
                when 'arrayElement' {
                    output = arrayElement(params);
                }
                when 'arrayElements' {
                    output = arrayElements(params, null);
                }
                when else {

                }
            }
            return output;
        }

        private Double random() {
            Double randomNumber;
            if (RANDOM_NUMBER_CACHE_SIZE == -1) {
                randomNumber = Math.random();
            } else if (randomNumberCache.size() == RANDOM_NUMBER_CACHE_SIZE) {
                if (randomNumberIndex == RANDOM_NUMBER_CACHE_SIZE) {
                    randomNumberIndex = 0;
                }
                randomNumber = randomNumberCache[randomNumberIndex];
                ++randomNumberIndex;
            } else {
                randomNumber = Math.random();
                randomNumberCache.add(randomNumber);
            }
            return randomNumber;
        }

        public Boolean boolean() {
            return random() > 0.5;
        }

        public Decimal number() {
            return number(null, null, null);
        }

        public Decimal number(Decimal max) {
            return number(null, max, null);
        }

        public Decimal number(Integer precision, Integer scale) {
            scale = scale == null ? 0 : scale;
            precision = precision == null ? 3 + scale : precision;

            if (precision < scale || precision == 0) {
                return 0;
            }

            Double random = random();
            Integer integralPart = (Integer)Decimal.valueOf((random * (precision - scale))).round();
            Integer decimalPart = (scale == 0) ? 0 : (Integer)Decimal.valueOf(random() * scale).round();
            Integer newPrecision = integralPart + decimalPart;

            if (newPrecision < decimalPart || newPrecision == 0) {
                return 0;
            }

            Decimal value = Decimal.valueOf(
                ((Math.pow(10, newPrecision) -1) * random()).round()
            ).divide(Math.pow(10, decimalPart), decimalPart);

            // System.debug('precision(' + precision
            //     + '), scale(' + scale
            //     + '), random(' + random
            //     + '), integralPart(' + integralPart
            //     + '), decimalPart(' + decimalPart
            //     + '), ValueArithmeticHelper(' + value
            //     + ')');
            return value;
        }

        public Decimal number(Decimal min, Decimal max, Integer scale) {
            min = min == null ? 0 : min;
            max = max == null ? 999 : max;
            scale = scale == null ? max.scale() : scale;

            Decimal delta = Decimal.valueOf(
                ((max - min) * random() * Math.pow(10, scale)).round(System.RoundingMode.DOWN)
            ).divide(Math.pow(10, scale), scale);
            return min + delta;
        }

        public Object arrayElement(List<Object> elements) {
            if (elements == null || elements.size() == 0) {
                return null;
            }

            Integer index = Integer.valueOf(number(0, elements.size() - 1, 0));
            return elements.get(index);
        }

        public List<Object> arrayElements(List<Object> elements) {
            return arrayElements(elements, null);
        }

        public List<Object> arrayElements(List<Object> elements, Integer count) {
            if (elements == null || elements.size() == 0) {
                return new List<Object>();
            }

            if (count == null) {
                count = Integer.valueOf(random.number(1, elements.size(), 0));
            } else if (count > elements.size()) {
                count = elements.size();
            } else if (count < 0) {
                count = 0;
            }

            List<Object> cloneElements = elements.clone();
            Integer countToRemove = cloneElements.size() - count;
            for (Integer i = 0; i < countToRemove; i++) {
                Integer indexToRemove = Integer.valueOf(random.number(cloneElements.size() - 1));
                cloneElements.remove(indexToRemove);
            }
            return cloneElements;
        }
    }

    public class DateHelper extends DateArithmeticHelper implements ATKReflect.IValueProvider {
        public override Object call(String method, List<Object> params) {
            Object param0;
            Object param1;
            if (params != null) {
                if (params.size() > 0) {
                    param0 = params.get(0);
                }
                if (params.size() > 1) {
                    param1 = params.get(1);
                }
            }

            Object output;
            switch on method {
                when 'past' {
                    Integer years = ATKCommon.CONVERTER.toInteger(param0);
                    String dt = ATKCommon.CONVERTER.toString(param1);
                    output = past(years, dt);
                }
                when 'future' {
                    Integer years = ATKCommon.CONVERTER.toInteger(param0);
                    String dt = ATKCommon.CONVERTER.toString(param1);
                    output = future(years, dt);
                }
                when 'between' {
                    String dt1 = ATKCommon.CONVERTER.toString(param0);
                    String dt2 = ATKCommon.CONVERTER.toString(param1);
                    output = between(dt1, dt2);
                }
                when else {
                    output = super.call(method, params);
                }
            }
            return output;
        }

        public Datetime past() {
            return past(null, null);
        }

        public Datetime past(Integer years, String refDate) {
            Datetime d = ATKCommon.CONVERTER.toDatetime(refDate);
            d = d == null ? Datetime.now() : d;
            years = years == null ? 1 : years;
            return d.addSeconds(-Integer.valueOf(random.number(1, years * 365 * 24 * 3600, 0)));
        }

        public Datetime future() {
            return future(null, null);
        }

        public Datetime future(Integer years, String refDate) {
            Datetime d = ATKCommon.CONVERTER.toDatetime(refDate);
            d = d == null ? Datetime.now() : d;
            years = years == null ? 1 : years;
            return d.addSeconds(Integer.valueOf(random.number(1, years * 365 * 24 * 3600, 0)));
        }

        public Datetime between(String fo, String to) {
            Datetime fromDatetime = ATKCommon.CONVERTER.toDatetime(fo);
            Datetime toDatetime = ATKCommon.CONVERTER.toDatetime(to);
            Integer dateOffset = Integer.valueOf(random.number(toDatetime.getTime() - fromDatetime.getTime())/1000);
            return fromDatetime.addSeconds(dateOffset);
        }
    }

    public class Internet implements ATKReflect.IValueProvider {
        public Object call(String method, List<Object> params) {
            Object output;
            switch on method {
                when 'userName' {
                    output = userName();
                }
                when 'email' {
                    output = email();
                }
                when 'url' {
                    output = url();
                }
                when else {

                }
            }
            return output;
        }

        public String userName() {
            String firstName = name.firstName();
            String lastName = name.lastName();
            String result = firstName
                + (String)random.arrayElement(definition.get(ATKFakerDefinition.FAKER_INTERNET_USERNAME_PUNCTUATION))
                + lastName
                + random.number(99, 999, 0);
            result = result.replaceAll('\'', '');
            result = result.replaceAll(' ', '');
            return result;
        }

        public String email() {
            List<String> providerList = definition.get(ATKFakerDefinition.FAKER_INTERNET_FREEEMAIL);
            String provider = (String)random.arrayElement(providerList);
        	return helper.slugify(internet.userName()) + '@' + provider;
        }

        public String url() {
        	return 'https://' + domainName();
        }

        private String domainName() {
            return domainWord() + '.' + domainSuffix();
        }

        private String domainWord() {
            return name.firstName().replaceAll('[\\~#&*{}/:<>?|\\\"\']', '').toLowerCase();
        }

        private String domainSuffix() {
            List<String> domainSuffixList = definition.get(ATKFakerDefinition.FAKER_INTERNET_DOMAINSUFFIX);
            return (String)random.arrayElement(domainSuffixList);
        }
    }

    public class Phone implements ATKReflect.IValueProvider {
        public Object call(String method, List<Object> params) {
            Object param0;
            if (params != null) {
                if (params.size() > 0) {
                    param0 = params.get(0);
                }
            }

            Object output;
            switch on method {
                when 'phoneNumber' {
                    output = phoneNumber(
                        ATKCommon.CONVERTER.toString(param0)
                    );
                }
                when else {

                }
            }
            return output;
        }

        public String phoneNumber() {
            return phoneNumber(null);
        }

        public String phoneNumber(String format) {
            format = format == null ? phoneFormat() : format;
        	return helper.replaceSymbolsWithNumber(format);
        }

        private String phoneFormat() {
            List<String> formats = definition.get(ATKFakerDefinition.FAKER_PHONE_FORMATS);
            return (String)random.arrayElement(formats);
        }
    }

    public class Name implements ATKReflect.IValueProvider {
        public Object call(String method, List<Object> params) {
            Object output;
            switch on method {
                when 'firstName' {
                    output = firstName();
                }
                when 'lastName' {
                    output = lastName();
                }
                when else {

                }
            }
            return output;
        }

        public String firstName() {
            list<String> nameList = definition.get(ATKFakerDefinition.FAKER_NAME_FIRSTNAME);
            return (String)random.arrayElement(nameList);
        }

        public String lastName() {
            return (String)random.arrayElement(definition.get(ATKFakerDefinition.FAKER_NAME_LASTNAME));
        }
    }

    public class Finance implements ATKReflect.IValueProvider {
        public Object call(String method, List<Object> params) {
            Object param0;
            Object param1;
            if (params != null) {
                if (params.size() > 0) {
                    param0 = params.get(0);
                }
                if (params.size() > 1) {
                    param1 = params.get(1);
                }
            }

            Object output;
            switch on method {
                when 'amount' {
                    Integer precision = ATKCommon.CONVERTER.toInteger(param0);
                    Integer scale = ATKCommon.CONVERTER.toInteger(param1);
                    output = amount(precision, scale);
                }
                when else {

                }
            }
            return output;
        }

        public Decimal amount() {
            return amount(null, null);
        }

        public Decimal amount(Integer precision, Integer scale) {
        	return random.number(precision, scale);
        }
    }

    public class Lorem implements ATKReflect.IValueProvider {
        public Object call(String method, List<Object> params) {
            Object param0;
            Object param1;
            if (params != null) {
                if (params.size() > 0) {
                    param0 = params.get(0);
                }
                if (params.size() > 1) {
                    param1 = params.get(1);
                }
            }

            Object output;
            Integer count = ATKCommon.CONVERTER.toInteger(param0);
            String separator = ATKCommon.CONVERTER.toString(param1);
            switch on method {
                when 'word' {
                    output = word();
                }
                when 'words' {
                    output = words(count);
                }
                when 'sentence' {
                    output = sentence(count);
                }
                when 'sentences' {
                    output = sentences(count, separator);
                }
                when 'paragraph' {
                    output = paragraph(count);
                }
                when 'paragraphs' {
                    output = paragraphs(count, separator);
                }
                when 'lines' {
                    output = words(count);
                }
                when 'text' {
                    output = words(count);
                }
                when else {

                }
            }
            return output;
        }

        public String word() {
            List<String> words = definition.get(ATKFakerDefinition.FAKER_LOREM_WORDS);
        	return (String)random.arrayElement(words);
        }

        public String words() {
            return words(null);
        }

        public String words(Integer count) {
            return buildWords(count).toString();
        }

        ATKCommon.StringBuilder buildWords(Integer count) {
            count = count == null ? 3 : count;
            ATKCommon.StringBuilder builder = new ATKCommon.StringBuilder();
            for (Integer i = 0; i < count; ) {
                builder.append(word());
                i++;
                if (i != count) {
                    builder.append(' ');
                }
            }
        	return builder;
        }

        public String sentence() {
            return sentence(null);
        }

        public String sentence(Integer count) {
            return buildSentence(count).toString();
        }

        ATKCommon.StringBuilder buildSentence(Integer count) {
            count = count == null ? Integer.valueOf(random.number(3, 10, 0)) : count;
            ATKCommon.StringBuilder builder = buildWords(count);
            String firstWord = builder.getIndex(0);
            builder.setIndex(0, firstWord.substring(1));
            builder.addIndex(0, firstWord.substring(0, 1).toUpperCase());
            builder.append('.');
            return builder;
        }

        public String sentences() {
            return sentences(null, null);
        }

        public String sentences(Integer count) {
            return sentences(count, null);
        }

        public String sentences(Integer count, String separator) {
            return buildSentences(count, separator).toString();
        }

        ATKCommon.StringBuilder buildSentences(Integer count, String separator) {
            count = count == null ? Integer.valueOf(random.number(2, 6, 0)) : count;
            separator = separator == null ? ' ' : separator;

            ATKCommon.StringBuilder builder = new ATKCommon.StringBuilder();
            for (Integer i = 0; i < count;) {
                builder.append(buildSentence(null));
                i++;
                if (i != count) {
                    builder.append(separator);
                }
            }
            return builder;
        }

        public String paragraph() {
            return paragraph(null);
        }

        public String paragraph(Integer count) {
            return buildParagraph(count).toString();
        }

        ATKCommon.StringBuilder buildParagraph(Integer count) {
            count = count == null? 3 : count;
            return buildSentences(count + Integer.valueOf(random.number(0, 3, 2)), null);
        }

        public String paragraphs() {
            return paragraphs(null, null);
        }

        public String paragraphs(Integer count, String separator) {
            return buildParagraphs(count, separator).toString();
        }

        ATKCommon.StringBuilder buildParagraphs(Integer count, String separator) {
            separator = separator == null ? '\n \r' : separator;
            count = count == null ? 3 : count;

            ATKCommon.StringBuilder builder = new ATKCommon.StringBuilder();
            for (Integer i = 0; i < count;) {
                builder.append(buildParagraph(null));
                i++;
                if (i != count) {
                    builder.append(separator);
                }
            }
            return builder;
        }

        public String lines() {
            return lines(null);
        }

        public String lines(Integer count) {
            return buildLines(count).toString();
        }

        ATKCommon.StringBuilder buildLines(Integer count) {
            count = count == null ? Integer.valueOf(random.number(1, 5, 0)) : count;
            return buildSentences(count, '\n');
        }

        public String text() {
            List<String> methodList = new List<String> {
                'word', 'words',
                'sentence', 'sentences',
                'paragraph', 'paragraphs',
                'lines'};
            String method = (String)random.arrayElement(methodList);
            return (String)call(method, null);
        }
    }

    public class Address implements ATKReflect.IValueProvider {
        public Object call(String method, List<Object> params) {
            Object output;
            switch on method {
                when 'city' {
                }
                when else {

                }
            }
            return output;
        }
    }

    /*
     * Arithmetic Provider
     */
    private virtual class ValueArithmeticHelper implements ATKReflect.IValueProvider {
        public virtual Object call(String method, List<Object> params) {
            Object param0;
            if (params != null) {
                if (params.size() > 0) {
                    param0 = params.get(0);
                }
            }

            Object output;
            switch on method {
                when 'get' {
                    output = param0;
                }
                when else {

                }
            }
            return output;
        }
    }

    @TestVisible
    private virtual class NumberArithmeticHelper implements ATKReflect.IValueProvider {
        public virtual Object call(String method, List<Object> params) {
            Object param0;
            Object param1;
            if (params != null) {
                if (params.size() > 0) {
                    param0 = params.get(0);
                }
                if (params.size() > 1) {
                    param1 = params.get(1);
                }
            }

            Object output;
            Decimal a = ATKCommon.CONVERTER.toDecimal(param0);
            Decimal b = ATKCommon.CONVERTER.toDecimal(param1);
            switch on method {
                when 'add' {
                    output = add(a, b);
                }
                when 'subtract' {
                    output = subtract(a, b);
                }
                when 'divide' {
                    output = divide(a, b);
                }
                when 'multiply' {
                    output = multiply(a, b);
                }
                when else {

                }
            }
            return output;
        }

        @TestVisible
        private Decimal add(Decimal a, Decimal b) {
            if (a == null || b == null) {
                return null;
            }
            return a + b;
        }

        @TestVisible
        private Decimal subtract(Decimal a, Decimal b) {
            if (a == null || b == null) {
                return null;
            }
            return a - b;
        }

        @TestVisible
        private Decimal divide(Decimal a, Decimal b) {
            if (a == null || b == null) {
                return null;
            }
            return a / b;
        }

        @TestVisible
        private Decimal multiply(Decimal a, Decimal b) {
            if (a == null || b == null) {
                return null;
            }
            return a * b;
        }
    }

    private virtual class DateArithmeticHelper implements ATKReflect.IValueProvider {
        public virtual Object call(String method, List<Object> params) {
            Object param0;
            Object param1;
            if (params != null) {
                if (params.size() > 0) {
                    param0 = params.get(0);
                }
                if (params.size() > 1) {
                    param1 = params.get(1);
                }
            }

            Object output;
            if (param0 instanceOf Date) {
                Date dt = ATKCommon.CONVERTER.toDate(param0);
                Integer add = ATKCommon.CONVERTER.toInteger(param1);
                switch on method {
                    when 'addDays' {
                        output = addDays(dt, add);
                    }
                    when 'addMonths' {
                        output = addMonths(dt, add);
                    }
                    when 'addYears' {
                        output = addYears(dt, add);
                    }
                    when else {

                    }
                }
            } else {
                Datetime dt = ATKCommon.CONVERTER.toDatetime(param0);
                Integer add = ATKCommon.CONVERTER.toInteger(param1);
                switch on method {
                    when 'addDays' {
                        output = addDays(dt, add);
                    }
                    when 'addHours' {
                        output = addHours(dt, add);
                    }
                    when 'addMinutes' {
                        output = addMinutes(dt, add);
                    }
                    when 'addMonths' {
                        output = addMonths(dt, add);
                    }
                    when 'addSeconds' {
                        output = addSeconds(dt, add);
                    }
                    when 'addYears' {
                        output = addYears(dt, add);
                    }
                    when else {

                    }
                }
            }
            return output;
        }

        @TestVisible
        private Date addYears(Date dt, Integer additionalYears) {
            if (dt == null) {
                return null;
            }
            return dt.addYears(additionalYears);
        }

        @TestVisible
        private Date addMonths(Date dt, Integer additionalMonths) {
            if (dt == null) {
                return null;
            }
            return dt.addMonths(additionalMonths);
        }

        @TestVisible
        private Date addDays(Date dt, Integer additionalDays) {
            if (dt == null) {
                return null;
            }
            return dt.addDays(additionalDays);
        }

        @TestVisible
        private Datetime addYears(Datetime dt, Integer additionalYears) {
            if (dt == null) {
                return null;
            }
            return dt.addYears(additionalYears);
        }

        @TestVisible
        private Datetime addMonths(Datetime dt, Integer additionalMonths) {
            if (dt == null) {
                return null;
            }
            return dt.addMonths(additionalMonths);
        }

        @TestVisible
        private Datetime addDays(Datetime dt, Integer additionalDays) {
            if (dt == null) {
                return null;
            }
            return dt.addDays(additionalDays);
        }

        @TestVisible
        private Datetime addHours(Datetime dt, Integer additionalHours) {
            if (dt == null) {
                return null;
            }
            return dt.addHours(additionalHours);
        }

        @TestVisible
        private Datetime addMinutes(Datetime dt, Integer additionalMinutes) {
            if (dt == null) {
                return null;
            }
            return dt.addMinutes(additionalMinutes);
        }

        @TestVisible
        private Datetime addSeconds(Datetime dt, Integer additionalSeconds) {
            if (dt == null) {
                return null;
            }
            return dt.addSeconds(additionalSeconds);
        }
    }
}
