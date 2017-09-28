# with_resources: Add "with" statement in your Ruby script

```ruby
# gem install with_resources

require "with_resources"

WithResourecs.with(->(){
    sock = TCPSocket.open("dest.example.com", port)
    httpclient = MyHTTPClient.new(sock) 
}) do |sock, httpclient|
    # ...
    # httpclient.close # will be called automatically
    # sock.close
end

require "with_resources/toplevel"

using WithResources::TopLevel
# it makes "with" available in this file

with(->(){ a = One.new; b = Another.new(a) }) do |a, b|
    # ...
end

# or enable everywhere! (DANGER!)
require "with_resources/kernel_ext"
```

This gem provides a feature to allocate/release resource objects safely.
This feature is widely known as 'try-with-resources' (Java), 'with' statement (Python), 'using' statement (C#) and many others.

`WithResources.with` method does:

* accept a lambda argument to allocate resources
* accept a block to be called
* release allocated resources automatically after block is processed in reverse order of allocated order

All allocated resources will be released even when any errors are raised in block, in `obj.close` or in allocating another resources.

### Disclosure

This library is a kind of PoC to introduce safe resource allocation in Ruby world. Take care about using this library in your production environment.

## API

* `WithResources.with(lambda_to_allocate, release_method: :close, &block)`

All values assigned into local variable in `lambda_to_allocate` will be passed to `block` as block arguments. (Don't re-assign values into same local variable, neither undefine local variable, in that labmda.)

It can accept `release_method` keyword argument to specify the method name to release resources. The specified method will be called in release stage, without any arguments. It's impossible to specify different method names for resources.

### Introduce `with` to top-level namespace

Top level `with` is available via 2 different ways. One is using Refinements, another is modifying `Kernel` in open-class way.

```ruby
require "with_resources/toplevel"
using WithResources::TopLevel

with(->(){ r = create_resource() }) do |r|
    # ...
end
```

Refinements is a feature of Ruby to apply Module modification in just a file (by `using` statement).
`using WithResources::TopLevel` introduces top level `with` in safer way than modifying `Kernel`.

```ruby
require "with_resource/kernel_ext"

# now, "with" is available everywhere...
```

Requiring `with_resource/kernel_ext` modifies `Kernel` module globally to add `with`. It's not recommended in most cases.

## Performance

Because of some magical hacks, `with` has performance overhead.

The benchmark score below shows the difference of performances between standard `begin-ensure` and `with` (elasped seconds by 10,000 times). Benchmark script is available at `misc/bench.rb`.

```
       user     system      total        real
begin  0.040000   0.000000   0.040000 (  0.037753)
with   1.400000   0.010000   1.410000 (  1.423388)
```

It's not so huge overhead in actual application, but it might be better to use `with` in heavy loops.

* * * * *

## Authors

* Satoshi Tagomori <tagomoris@gmail.com>

## License

MIT (See License.txt)
