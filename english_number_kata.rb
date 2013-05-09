require 'test/unit'

module EnglishEncoding
  MaxDecimal = 999999999

  SimpleFactors = [ 90,  80,  70,  60,   50,    40,  30,
      20,   19,   18,   17,  16,  15,  14,   13,    12,  11,
      10,    9,    8,    7,   6,   5,   4,    3,     2,   1
  ]

  SimpleGlyphs = ["ninety", "eighty", "seventy", "sixty", "fifty", "forty", "thirty",
      "twenty", "nineteen", "eighteen", "seventeen", "sixteen", "fifteen", "fourteen", "thirteen", "twelve", "eleven",
      "ten", "nine", "eight", "seven", "six", "five", "four", "three", "two", "one" 
  ]

  def encode(decimal)
    # restrict range of input to 0 .. MaxDecimal
    exceeds_range = "Only numbers in the range ( 0 .. #{MaxDecimal} ) are supported"
    raise "Cannot convert (#{decimal}): #{exceeds_range}" unless (decimal <= MaxDecimal && decimal >= 0)

    if decimal == 0
      return "zero"
    end

    # table of translation factors for each glyph in the subset of the words supported
    factors = [ 100000000, 1000000, 100000,   1000, 100, SimpleFactors].flatten
    glyphs  = [ "hundred million", "million", "hundred thousand",    "thousand", "hundred", SimpleGlyphs ].flatten

    and_glyph = ""

    # factorise decimal representation into words
    result = []
    factors.each_with_index{|numeral,index|
      decimal,order = factorise(decimal,numeral)
      next unless order > 0

        glyph = glyphs[index]
        result << case glyph
        when /(hundred million)|(million)|(hundred thousand)|(hundred)|(thousand)/
          and_glyph = glyph
          "#{simple_encode(order,SimpleFactors,SimpleGlyphs)} #{glyph}"
        else
          glyph
        end
    }

    # will need to tweak output slightly
    output = result.join(" ")
    return output if and_glyph == ""
    tweak_output( output, and_glyph)
  end

private

  def factorise(decimal,numeral)
      order   = decimal / numeral
      decimal = decimal % numeral
      return [decimal,order]
  end

  def simple_encode(decimal,factors,glyphs)
    result = []
    factors.each_with_index{|numeral,index|
      decimal,order = factorise(decimal,numeral)
      next unless order > 0
        glyph = glyphs[index]
        result << glyph
    }
    result.join(" ")
  end

   # add the special case of and following mentions of hundred/thousand/hundred thousand/millions
   def tweak_output(raw,and_glyph)
    output = raw
    output = output.gsub(/#{and_glyph} /,"#{and_glyph} and ")
    output = output.gsub(/hundred and thousand/,"hundred and")
    output = output.gsub(/hundred million and/,"hundred and")
    output = output.gsub(/and million/,"and")
    output
  end

end

class TestEnglishEncoding < Test::Unit::TestCase
  def setup
     @tester = Object.new
     @tester.instance_eval do
        class << self
          include EnglishEncoding
        end
     end
  end

  # check boundry conditions - too large and too small
  def test_restrictions_are_enforced_when_input_is_too_small
    input = -1
    message = assert_raise(RuntimeError){ @tester.encode(input) }
    assert_match(
      message,
      %r{Cannot convert \(#{input}\): Only numbers in the range \( 0 .. #{EnglishEncoding::MaxDecimal} \) are supported},
      "Checking restriction on size of input failed when given small input"
    )
  end

  # check boundry conditions - too large and too small
  def test_restrictions_are_enforced_when_input_is_too_large
    input = EnglishEncoding::MaxDecimal+1
    message = assert_raise(RuntimeError){ @tester.encode(input) }
    assert_match(
      message,
      %r{Cannot convert \(#{input}\): Only numbers in the range \( 0 .. #{EnglishEncoding::MaxDecimal} \) are supported},
      "Checking restriction on size of input failed when given large input"
    )
  end

  # check special case of zero
  def test_0_equals_zero
    expected = "zero"
    input    =  0
    assert_equal(
      expected,
      @tester.encode(input),
      "expected that 0 should encode as zero"
    )
  end

  # check basic numbers
  def test_units
    testcases = {
      "zero"      => 0,
      "one"       => 1,
      "two"       => 2,
      "three"     => 3,
      "four"      => 4,
      "five"      => 5,
      "six"       => 6,
      "seven"     => 7,
      "eight"     => 8,
      "nine"      => 9,
      "ten"       => 10,
    }
    evaluate testcases
  end

  def test_teens
    testcases = {
      "eleven"    => 11,
      "twelve"    => 12,
      "thirteen"  => 13,
      "fourteen"  => 14,
      "fifteen"   => 15,
      "sixteen"   => 16,
      "seventeen" => 17,
      "eighteen"  => 18,
      "nineteen"  => 19,
    }
    evaluate testcases
  end

  def test_twenties
    testcases = {
      "twenty"        => 20,
      "twenty one"    => 21,
      "twenty two"    => 22,
      "twenty three"  => 23,
      "twenty four"   => 24,
      "twenty five"   => 25,
      "twenty six"    => 26,
      "twenty seven"  => 27,
      "twenty eight"  => 28,
      "twenty nine"   => 29,
    }
    evaluate testcases
  end

  def test_thirties
    testcases = {
      "thirty"        => 30,
      "thirty one"    => 31,
      "thirty two"    => 32,
      "thirty three"  => 33,
      "thirty four"   => 34,
      "thirty five"   => 35,
      "thirty six"    => 36,
      "thirty seven"  => 37,
      "thirty eight"  => 38,
      "thirty nine"   => 39,
    }
    evaluate testcases
  end

  def test_forties
    testcases = {
      "forty"        => 40,
      "forty one"    => 41,
      "forty two"    => 42,
      "forty three"  => 43,
      "forty four"   => 44,
      "forty five"   => 45,
      "forty six"    => 46,
      "forty seven"  => 47,
      "forty eight"  => 48,
      "forty nine"   => 49,
    }
    evaluate testcases
  end

  def test_fifties
    testcases = {
      "fifty"        => 50,
      "fifty one"    => 51,
      "fifty two"    => 52,
      "fifty three"  => 53,
      "fifty four"   => 54,
      "fifty five"   => 55,
      "fifty six"    => 56,
      "fifty seven"  => 57,
      "fifty eight"  => 58,
      "fifty nine"   => 59,
    }
    evaluate testcases
  end

  def test_sixties
    testcases = {
      "sixty"        => 60,
      "sixty one"    => 61,
      "sixty two"    => 62,
      "sixty three"  => 63,
      "sixty four"   => 64,
      "sixty five"   => 65,
      "sixty six"    => 66,
      "sixty seven"  => 67,
      "sixty eight"  => 68,
      "sixty nine"   => 69,
    }
    evaluate testcases
  end

  def test_seventies
    testcases = {
      "seventy"        => 70,
      "seventy one"    => 71,
      "seventy two"    => 72,
      "seventy three"  => 73,
      "seventy four"   => 74,
      "seventy five"   => 75,
      "seventy six"    => 76,
      "seventy seven"  => 77,
      "seventy eight"  => 78,
      "seventy nine"   => 79,
    }
    evaluate testcases
  end

  def test_eighties
    testcases = {
      "eighty"        => 80,
      "eighty one"    => 81,
      "eighty two"    => 82,
      "eighty three"  => 83,
      "eighty four"   => 84,
      "eighty five"   => 85,
      "eighty six"    => 86,
      "eighty seven"  => 87,
      "eighty eight"  => 88,
      "eighty nine"   => 89,
    }
    evaluate testcases
  end

  def test_nineties
    testcases = {
      "ninety"        => 90,
      "ninety one"    => 91,
      "ninety two"    => 92,
      "ninety three"  => 93,
      "ninety four"   => 94,
      "ninety five"   => 95,
      "ninety six"    => 96,
      "ninety seven"  => 97,
      "ninety eight"  => 98,
      "ninety nine"   => 99,
    }
    evaluate testcases
  end

  def test_hundred_units
    testcases = {
      "one hundred"             => 100,
      "one hundred and one"     => 101,
      "one hundred and two"     => 102,
      "one hundred and three"   => 103,
      "one hundred and four"    => 104,
      "one hundred and five"    => 105,
      "one hundred and six"     => 106,
      "one hundred and seven"   => 107,
      "one hundred and eight"   => 108,
      "one hundred and nine"    => 109,
     }
    evaluate testcases
  end

  def test_hundred_tens
    testcases = {
      "one hundred and ten"      => 110,
      "one hundred and eleven"   => 111,
      "one hundred and twelve"   => 112,
      "one hundred and thirteen" => 113,
      "one hundred and fourteen" => 114,
      "one hundred and fifteen"  => 115,
      "one hundred and sixteen"  => 116,
      "one hundred and seventeen"=> 117,
      "one hundred and eighteen" => 118,
      "one hundred and nineteen" => 119,
     }
    evaluate testcases
  end

  def test_hundreds_range
    testcases = {
      "one hundred and twenty"   => 120,
      "one hundred and fifty one"=> 151,
      "one hundred and ninety nine"   => 199,
      "two hundred and twenty"   => 220,
      "three hundred and fifty one"=> 351,
      "four hundred and ninety nine"   => 499,
      "nine hundred and ninety nine"   => 999,
     }
    evaluate testcases
  end

  def test_thousands_units
    testcases = {
      "one thousand"                         => 1000,
      "one thousand one hundred and one"     => 1101,
      "one thousand and one"                 => 1001,
      "one thousand and ten"                 => 1010,
      "one thousand five hundred and ten"    => 1510,
      "three thousand seven hundred"         => 3700,
      "ten thousand five hundred and ten"    => 10510,
      "five thousand seven hundred and eighty one" => 5781,
      "forty five thousand seven hundred and eighty one"    => 45781,
      "one hundred thousand"                 => 100000,
      "one hundred thousand and one"         => 100001,
      "five hundred thousand and one"        => 500001,
      "nine hundred and forty five thousand seven hundred and eighty one"        => 945781,
     }
    evaluate testcases
  end

  def test_millions
    testcases = {
      "one million"                          => 1000000,
      "one million and one"                  => 1000001,
      "fifty six million nine hundred and forty five thousand seven hundred and eighty one" => 56945781,
      "one hundred and twenty six million and ten" => 126000010,
      "nine hundred and ninety nine million nine hundred and ninety nine thousand nine hundred and ninety seven"               => 999999997,
      "nine hundred and ninety nine million nine hundred and ninety nine thousand nine hundred and ninety eight"               => 999999998,
      "nine hundred and ninety nine million nine hundred and ninety nine thousand nine hundred and ninety nine"               => 999999999,
     }
    evaluate testcases
  end

  def evaluate(testcases)
   testcases.each do |expected,input|
      assert_equal(
        expected,
        @tester.encode(input),
        "expected that #{input} should encode as #{expected}"
      )
    end
  end
end
