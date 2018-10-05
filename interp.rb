require "minruby"

def fizzbuzz(n)
  while n < 100
    if n % 3 == 0
      if n % 5 == 0
        p("FizzBuzz")
      else
        p("Fizz")
      end
    else
      if n % 5 == 0
        p("Buzz")
      else
        p(n)
      end
    end
    n = n + 1
  end
end

def shift
  ARGV.shift
end

# An implementation of the evaluator
def evaluate(exp, env)
  # exp: A current node of AST
  # env: An environment (explained later)

  case exp[0]

#
## Problem 1: Arithmetics
#

  when "lit"
    exp[1] # return the immediate value as is

  when "+"
    evaluate(exp[1], env) + evaluate(exp[2], env)
  when "-"
    evaluate(exp[1], env) - evaluate(exp[2], env)
  when "*"
    evaluate(exp[1], env) * evaluate(exp[2], env)
  when "/"
    evaluate(exp[1], env) / evaluate(exp[2], env)
  when "%"
    evaluate(exp[1], env) % evaluate(exp[2], env)
  when "<"
    evaluate(exp[1], env) < evaluate(exp[2], env)
  when ">"
    evaluate(exp[1], env) > evaluate(exp[2], env)
  when "=="
    evaluate(exp[1], env) == evaluate(exp[2], env)


#
## Problem 2: Statements and variables
#

  when "stmts"
    # Statements: sequential evaluation of one or more expressions.
    #
    # Advice 1: Insert `pp(exp)` and observe the AST first.
    # Advice 2: Apply `evaluate` to each child of this node.
    idx = 1
    while v = exp[idx]
      evaluate(v, env)
      idx = idx + 1
    end

  # The second argument of this method, `env`, is an "environement" that
  # keeps track of the values stored to variables.
  # It is a Hash object whose key is a variable name and whose value is a
  # value stored to the corresponded variable.

  when "var_ref"
    # Variable reference: lookup the value corresponded to the variable
    #
    # Advice: env[???]
    env[exp[1]]

  when "var_assign"
    # Variable assignment: store (or overwrite) the value to the environment
    #
    # Advice: env[???] = ???
    env[exp[1]] = evaluate(exp[2], env)


#
## Problem 3: Branchs and loops
#

  when "if"
    # Branch.  It evaluates either exp[2] or exp[3] depending upon the
    # evaluation result of exp[1],
    #
    # Advice:
    #   if ???
    #     ???
    #   else
    #     ???
    #   end
    if evaluate(exp[1], env)
      evaluate(exp[2], env)
    else
      evaluate(exp[3], env)
    end

  when "while"
    # Loop.
    while evaluate(exp[1], env)
      evaluate(exp[2], env)
    end


#
## Problem 4: Function calls
#

  when "func_call"
    # Lookup the function definition by the given function name.
    func = $function_definitions[exp[1]]

    if func.nil?
      # We couldn't find a user-defined function definition;
      # it should be a builtin function.
      # Dispatch upon the given function name, and do paticular tasks.
      case exp[1]
      when "p"
        # MinRuby's `p` method is implemented by Ruby's `p` method.
        p(evaluate(exp[2], env))
      # ... Problem 4
      when "Integer"
        Integer(evaluate(exp[2], env))
      when "fizzbuzz"
        fizzbuzz(evaluate(exp[2], env))
      when 'shift'
        shift()
      else
        raise("unknown builtin function")
      end
    else

#
## Problem 5: Function definition
#

      # (You may want to implement "func_def" first.)
      #
      # Here, we could find a user-defined function definition.
      # The variable `func` should be a value that was stored at "func_def":
      # parameter list and AST of function body.
      #
      # Function calls evaluates the AST of function body within a new scope.
      # You know, you cannot access a varible out of function.
      # Therefore, you need to create a new environment, and evaluate the
      # function body under the environment.
      #
      # Note, you can access formal parameters (*1) in function body.
      # So, the new environment must be initialized with each parameter.
      #
      # (*1) formal parameter: a variable as found in the function definition.
      # For example, `a`, `b`, and `c` are the formal parameters of
      # `def foo(a, b, c)`.
      new_env = env.dup
      arg_names = func[0]
      body = func[1]
      idx = 0
      while name = arg_names[idx]
        evaluate(['var_assign', name, exp[2 + idx]], new_env)
        idx = idx + 1
      end
      evaluate(body, new_env)
    end

  when "func_def"
    # Function definition.
    #
    # Add a new function definition to function definition list.
    # The AST of "func_def" contains function name, parameter list, and the
    # child AST of function body.
    # All you need is store them into $function_definitions.
    #
    # Advice: $function_definitions[???] = ???
    $function_definitions[exp[1]] = [exp[2], exp[3]]


#
## Problem 6: Arrays and Hashes
#

  # You don't need advices anymore, do you?
  when "ary_new"
    idx = 1
    res = []
    while v = exp[idx]
      res << evaluate(v, env)
      idx = idx + 1
    end
    res

  when "ary_ref"
    evaluate(exp[1], env)[evaluate(exp[2], env)]

  when "ary_assign"
    evaluate(exp[1], env)[evaluate(exp[2], env)] = evaluate(exp[3], env)

  when "hash_new"
    idx = 1
    res = {}
    while v = exp[idx]
      res[evaluate(v, env)] = evaluate(exp[idx+1], env)
      idx = idx + 2
    end
    res

  else
    p("error")
    pp(exp)
    raise("unknown node")
  end
end


$debug = !ENV['NO_MINRUBY_DEBUG']

def debug_p(*args)
  pp(*args) if $debug
end

if $debug
  def capt(&block)
    $stdout = StringIO.new
    block.call
    return $stdout.string
  ensure
    $stdout = STDOUT
  end
end

# `minruby_load()` == `File.read(ARGV.shift)`
# `minruby_parse(str)` parses a program text given, and returns its AST
while true
  fname = shift()
  break unless fname
  debug_p '------------------ filename', fname

  f = File.read(fname)
  $function_definitions = {}
  env = {}

  ast = minruby_parse(f)
  debug_p '--------------- ast', ast



  if $debug
    minruby_out = capt{evaluate(ast, env)}
    ruby_out = capt{eval f}
    unless minruby_out == ruby_out
      File.write('/tmp/minruby', minruby_out)
      File.write('/tmp/ruby', ruby_out)
      system 'git diff --no-index /tmp/minruby /tmp/ruby'
      raise
    end
  else
    evaluate(ast, env)
  end
end
