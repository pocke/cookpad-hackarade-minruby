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

def pp_str(obj)
  obj.pretty_inspect
end

$function_definitions = {}

def function_definitions
  $function_definitions
end
