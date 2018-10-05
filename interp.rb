# frozen_string_literal: true

require "minruby"
require './fizzbuzz'

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

#
## Problem 2: Statements and variables
#


  # The second argument of this method, `env`, is an "environement" that
  # keeps track of the values stored to variables.
  # It is a Hash object whose key is a variable name and whose value is a
  # value stored to the corresponded variable.

  when "var_ref"
    # Variable reference: lookup the value corresponded to the variable
    #
    # Advice: env[???]
    env[exp[1]]

  when "ary_ref"
    evaluate(exp[1], env)[evaluate(exp[2], env)]

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
      exp[3] && evaluate(exp[3], env)
    end



#
## Problem 4: Function calls
#

  when "func_call"
    # Lookup the function definition by the given function name.
    func = function_definitions()[exp[1]]

    if func
      new_env = {}
      idx = 0
      while name = func[0][idx]
        v = evaluate(exp[2 + idx], env)
        new_env[name] = v
        idx += 1
      end
      evaluate(func[1], new_env)
    else
      # We couldn't find a user-defined function definition;
      # it should be a builtin function.
      # Dispatch upon the given function name, and do paticular tasks.
      case exp[1]
      when "p"
        # MinRuby's `p` method is implemented by Ruby's `p` method.
        p(evaluate(exp[2], env))
      # ... Problem 4
      when 'function_definitions'
        function_definitions()
      when "Integer"
        Integer(evaluate(exp[2], env))
      when "fizzbuzz"
        fizzbuzz(evaluate(exp[2], env))
      when 'require'
        nil
      when 'minruby_parse'
        minruby_parse(evaluate(exp[2], env))
      when 'minruby_load'
        minruby_load()
      # when 'pp_str'
      #   pp_str(evaluate(exp[2], env))
      else
        raise("unknown builtin function: " + exp[1])
      end
    end

  when "func_def"
    # Function definition.
    #
    # Add a new function definition to function definition list.
    # The AST of "func_def" contains function name, parameter list, and the
    # child AST of function body.
    # All you need is store them into $function_definitions().
    #
    # Advice: $function_definitions()[???] = ???
    function_definitions()[exp[1]] = [exp[2], exp[3]]


#
## Problem 6: Arrays and Hashes
#

  # You don't need advices anymore, do you?


  when "ary_assign"
    evaluate(exp[1], env)[evaluate(exp[2], env)] = evaluate(exp[3], env)

  when 'case'
    v = evaluate(exp[1], env)
    res = nil
    not_done = true
    idx = 0
    while not_done && (w = exp[2][idx])
      if evaluate(w[0], env) == v
        not_done = false
        res = evaluate(w[1], env)
      end
      idx += 1
    end

    if not_done
      evaluate(exp[3], env)
    else
      res
    end
  when "stmts"
    # Statements: sequential evaluation of one or more expressions.
    #
    # Advice 1: Insert `pp(exp)` and observe the AST first.
    # Advice 2: Apply `evaluate` to each child of this node.
    idx = 1
    res = nil
    while v = exp[idx]
      res = evaluate(v, env)
      idx += 1
    end
    res

  when 'opassign' # support only plus
    env[exp[2]] = evaluate(exp[3], env) + env[exp[2]]
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
  when "&&"
    evaluate(exp[1], env) && evaluate(exp[2], env)
  when "||"
    evaluate(exp[1], env) || evaluate(exp[2], env)

  when "hash_new"
    idx = 1
    res = {}
    while v = exp[idx]
      res[evaluate(v, env)] = evaluate(exp[idx+1], env)
      idx += 2
    end
    res
  when "ary_new"
    idx = 1
    res = []
    while v = exp[idx]
      res[idx-1] = evaluate(v, env)
      idx += 1
    end
    res


  when "while"
    # Loop.
    while evaluate(exp[1], env)
      evaluate(exp[2], env)
    end

  else
    p exp
    raise("unknown node" + pp_str(exp))
  end
end


# if $debug
#   def capt(&block)
#     $stdout = StringIO.new
#     block.call
#     return $stdout.string
#   ensure
#     $stdout = STDOUT
#   end
# end
# 
# def debug
#   while true
#     fname = shift()
#     break unless fname
#     pp '------------------ filename', fname
# 
#     f = File.read(fname)
#     $function_definitions() = {}
#     env = {}
# 
#     ast = minruby_parse(f)
#     pp '--------------- ast', ast
# 
# 
# 
#     minruby_out = capt{evaluate(ast, env)}
#     ruby_out = capt{eval f}
#     unless minruby_out == ruby_out
#       File.write('/tmp/minruby', minruby_out)
#       File.write('/tmp/ruby', ruby_out)
#       system 'git diff --no-index /tmp/minruby /tmp/ruby'
#       raise
#     end
#   end
# end

# def main
#   idx = 1
#   while fname = ARGV[idx]
#     f = File.read(fname)
#     $function_definitions() = {}
#     env = {}
# 
#     ast = minruby_parse(f)
# 
#     evaluate(ast, env)
# 
#     idx = idx + 1
#   end
# end
# 
# main()

evaluate(minruby_parse(minruby_load()), {})
