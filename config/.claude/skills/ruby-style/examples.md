# Examples

## Always return ActiveSupport::StringInquirer instead of a plain symbol

When working in a Rails project, return ActiveSupport::StringInquirer instead of a plain symbol:

```ruby
# bad
# verbose comparison: `Foo.new.embedding_provider == :openai`
class Foo
  def embedding_provider = :openai
end

# good
# more elegant comparison: Foo.new.embedding_provider.openai?
class Foo
  def embedding_provider = 'openai'.inquiry
end
```

## Use descriptive variable names
```ruby
# bad
u = User.new(name: 'John')
fps = FinancialServiceProvider.last

# good
user = User.new(name: 'John')
financial_service_provider = FinancialServiceProvider.last
```

The only exception for this rule is index:

```
# good
[1,2,3].map { |i| i*2 }
[1,2,3].map { |index| i*2 }
```

## Line length
Lines should contain no more than 112 chars and arguments should be aligned as such:

```ruby
# bad
allow(RubyLLM).to receive(:embed).with("Hello world", model: model_version, provider: :azure_embeddings, assume_model_exists: true).and_return(embedding_response)

# okish
allow(RubyLLM).to receive(:embed)
  .with("hello", model: "text-embedding-3-small", provider: :azure_embeddings, assume_model_exists: true)
  .and_return(embedding_response)

# good
allow(RubyLLM).to(
  receive(:embed)
    .with(
      "Hello world",
      model: model_version,
      provider: :azure_embeddings,
      assume_model_exists: true
    )
    .and_return(embedding_response)
)
```
