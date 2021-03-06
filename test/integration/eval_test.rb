require 'test_helper'

include Beaker

class EvalTest < Minitest::Test
  pass_files = [
    ['./test/integration/files/eval_simple.txt', 'simple'],
    ['./test/integration/files/eval_math.txt', 'math'],
    ['./test/integration/files/eval_number.txt', 'number'],
    ['./test/integration/files/eval_array.txt', 'array'],
    ['./test/integration/files/eval_bool.txt', 'bool'],
    ['./test/integration/files/eval_text.txt', 'text'],
    ['./test/integration/files/eval_location.txt', 'location'],
    ['./test/integration/files/eval_time.txt', 'time']
  ]

  fail_files = [
    ['./test/integration/files/eval_fail.txt', 'fail']
  ]

  pass_files.each do |f|
    path = f[0]
    name = f[1]
    load_eval_test(path).each.with_index do |x, i|
      define_method("test_eval_#{name}_#{i}") do
        curr_env = Environment.new(false, @env)
        src, res, type = x
        lex = Lexer.lex(src)
        parse = Parser.parse(src, lex)
        ev = parse.evaluate(curr_env)
        assert_same_evaluation(src, ev, res)
        assert_same_type(src, ev, type)
      end
    end
  end

  fail_files.each do |f|
    path = f[0]
    name = f[1]
    load_eval_test(path).each.with_index do |x, i|
      define_method("test_eval_#{name}_#{i}") do
        curr_env = Environment.new(false, @env)
        src, res = x
        begin
          lex = Lexer.lex(src)
          parse = Parser.parse(src, lex)
          error = ''
          parse.evaluate(curr_env)
        rescue => e
          error = e.to_s
        end
        assert_same_error(src, error, unescape(res))
      end
    end
  end

  def setup
    Beaker.stdlib.add '*', NumberType.new(1)

    @env = Environment.new(true, Beaker.stdlib)
    Beaker.add_test_vars(@env)
  end
end
