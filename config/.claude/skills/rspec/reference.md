# Reference

## Core Principles

- tests must be self-contained, not DRY
- tests should follow the Arrange-Act-Assert pattern

Use https://evenbetterspecs.github.io/ as reference.

### Private Methods

**NEVER** test private methods directly. Private methods should have their behavior tested indirectly via public methods.

### File Header

**NEVER** include `require "rails_helper"` - it's loaded automatically.

### Mock external dependencies

Mock external dependencies to your test subject. By external dependencies I mean code that's not the main responsibility of the subject under test.

```ruby
# code
def github_stars(repository_id)
  stars = Github.fetch_repository_stars(repository_id)
  "Stars: #{stars}"
end
```

```ruby
# ❌ WRONG - `Github.fetch_repository_stars` behavior is being tested on `github_stars` method
describe '#github_stars' do
  it 'displays the number of stars' do
    expect(subject.github_stars(1)).to eq('Stars: 10')
  end
end
```

```ruby
# ✅ CORRECT - ensure `Github.fetch_repository_stars` is invoked
describe '#github_stars' do
  it 'displays the number of stars' do
    expect(Github).to receive(:fetch_repository_stars).with(1).and_return(10)

    expect(subject.github_stars(1)).to eq('Stars: 10')
  end
end
```

### Test Behavior, Not Implementation

**Focus on WHAT the code does, not HOW it does it**:

```ruby
# ✅ CORRECT - tests behavior
it "updates assigned_to_user_id for all conversations in batch" do
  conversation = create(:conversation, assigned_to_user_id: nil)
  batch = Conversation.where(id: conversation.id)

  task.process(batch)

  expect(conversation.reload.assigned_to_user_id).to eq(user.id)
end

# ❌ WRONG - tests implementation details
it "uses raw SQL with FROM clause for efficient batch updates" do
  expect(ActiveRecord::Base.connection).to receive(:execute).with(
    include("UPDATE conversations").and(include("FROM chats"))
  )
  task.process(batch)
end
```

**Why?** Implementation can change (e.g., switching from SQL to ActiveRecord), but behavior shouldn't. Testing implementation makes tests brittle.

### Assert Exact Values, Not Types or Vague Matchers

**When inputs are deterministic, always assert the exact expected value.** Never use `be_a`, `be > 0`, or other vague matchers when you can calculate the correct answer:

```ruby
# ✅ CORRECT - asserts exact value, catches regressions
expect(result[:bad_replies_change][:direction]).to eq(:up)
expect(result[:bad_replies_change][:value]).to eq(100)

# ❌ WRONG - be_a(Hash) tells you nothing useful, a bug could return { value: 0 } and pass
expect(result[:bad_replies_change]).to be_a(Hash)

# ❌ WRONG - be > 0 hides the expected value, a bug could change 100 to 1 and pass
expect(result[:conversion_rate_change][:value]).to be > 0
```

**Why?** Vague assertions give false confidence. If the test inputs are known, the output is calculable — assert it. When a regression shifts a value from 100 to 1, `eq(100)` catches it immediately while `be > 0` silently passes.

### Merge Related Tests

**Combine tests that show opposite or complementary behaviors**:

```ruby
# ✅ CORRECT - shows complete behavior in one test
it "includes conversations with ai_reply_enabled: false and excludes ai_reply_enabled: true" do
  conversation1 = create(:conversation, ai_reply_enabled: false)
  conversation2 = create(:conversation, ai_reply_enabled: true)

  expect(task.collection).to contain_exactly(conversation1)
end

# ❌ LESS EFFICIENT - splits related behavior into separate tests
context "when ai_reply_enabled is false" do
  it "includes the conversations" do
    conversation = create(:conversation, ai_reply_enabled: false)
    # ...
  end
end

context "when ai_reply_enabled is true" do
  it "excludes the conversations" do
    conversation = create(:conversation, ai_reply_enabled: true)
    # ...
  end
end
```

**When to merge**:
- Tests showing opposite behaviors (includes/excludes, true/false)
- Tests with similar setups testing related conditions
- Tests that together tell a complete story

**When NOT to merge**:
- Tests for different edge cases or error conditions
- Tests that would become too complex or hard to understand

---

## Model Spec Conventions: Associations & Validations

### Use Shoulda Matcher One-Liners

For `describe "associations"` and `describe "validations"` blocks, **always use Shoulda matcher one-liners** instead of verbose manual testing:

```ruby
# ✅ CORRECT - one-liner Shoulda matchers
describe "associations" do
  it { is_expected.to belong_to(:chat) }
  it { is_expected.to belong_to(:whatsapp_campaign).optional }
  it { is_expected.to have_many(:chat_tips).dependent(:destroy) }
  it { is_expected.to have_many(:chats).through(:chat_tips) }
end

describe "validations" do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:order_total) }
  it { is_expected.to validate_numericality_of(:order_total).is_greater_than_or_equal_to(0) }

  it "validates uniqueness of order_id scoped to chat_id" do
    record = create(:purchase_record)
    expect(record).to validate_uniqueness_of(:order_id).scoped_to(:chat_id).case_insensitive
  end
end

# ❌ WRONG - verbose manual validation testing
describe "validations" do
  it "requires a name" do
    record = build(:record, name: nil)
    expect(record).not_to be_valid
    expect(record.errors[:name]).to include("can't be blank")
  end
end
```

**Key patterns:**
- Simple presence/numericality/inclusion validations → one-liner
- Uniqueness validations → set `subject { create(:factory) }` to get a persisted record, then use one-liner matcher
- Custom validations (e.g., `validate :custom_method`) → use verbose style only when no Shoulda matcher exists
- Delegations → `it { is_expected.to delegate_method(:user).to(:chat) }`

**Uniqueness validation one-liner pattern:**
```ruby
# ✅ CORRECT - subject provides persisted record for uniqueness check
describe "validations" do
  subject { create(:chat_tip) }

  it { is_expected.to validate_uniqueness_of(:tip_id).scoped_to(:chat_id) }
  it { is_expected.to validate_uniqueness_of(:order_id).scoped_to(:chat_id).case_insensitive }
end

# ❌ WRONG - verbose multi-line uniqueness test
describe "validations" do
  it "validates uniqueness of tip_id scoped to chat_id" do
    chat_tip = create(:chat_tip)
    expect(chat_tip).to validate_uniqueness_of(:tip_id).scoped_to(:chat_id)
  end
end
```

**Why `subject` is needed:** `validate_uniqueness_of` requires a persisted record to compare against. The default subject (`described_class.new`) isn't saved to the database.

### Enum Testing with `define_enum_for`

**Always use the `define_enum_for` Shoulda matcher one-liner** instead of manually checking `.statuses`:

```ruby
# ✅ CORRECT - one-liner with define_enum_for
describe "enums" do
  it { is_expected.to define_enum_for(:status).with_values(active: "active", inactive: "inactive").backed_by_column_of_type(:string) }
  it { is_expected.to define_enum_for(:rating).with_values(good: "good", bad: "bad").backed_by_column_of_type(:string).with_suffix(:rating) }
end

# ❌ WRONG - verbose manual enum hash comparison
describe "enums" do
  it "defines the expected statuses" do
    expect(described_class.statuses).to eq("active" => "active", "inactive" => "inactive")
  end
end
```

**Chaining options:**
- `.with_values(key: "value")` — validates enum values
- `.backed_by_column_of_type(:string)` — validates column type
- `.with_suffix(:suffix_name)` — validates suffix (if enum uses `_suffix`)
- `.with_prefix(:prefix_name)` — validates prefix (if enum uses `_prefix`)

**Reference files:** `spec/models/conversation_spec.rb:5`, `spec/models/appsumo/main_license_spec.rb:11`

---

## Model Spec Describe Block Ordering

### Follow the Model Declaration Order

Describe blocks in model specs should mirror the model's declaration order:

```ruby
RSpec.describe MyModel, type: :model do
  # 1. Associations (one-liners)
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:items).dependent(:destroy) }
  end

  # 2. Enums (one-liner with define_enum_for)
  describe "enums" do
    it { is_expected.to define_enum_for(:status).with_values(pending: "pending", active: "active").backed_by_column_of_type(:string) }
  end

  # 3. Validations (one-liners where possible)
  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
  end

  # 4. Delegations
  describe "delegations" do
    it { is_expected.to delegate_method(:name).to(:user) }
  end

  # 5. Callbacks
  describe "callbacks" do
    # ...
  end

  # 6. Scopes
  describe "scopes" do
    # ...
  end

  # 7. Instance methods (last)
  describe "#method_name" do
    # ...
  end
end
```

**Key rule:** Structural declarations (enums, associations, validations, scopes) come before behavioral tests (instance/class methods).

---

## RSpec Structure

### Describe Blocks

**For instance methods** - use `#method_name`:
```ruby
RSpec.describe User do
  describe "#full_name" do
    # tests for instance method
  end
end
```

**For class methods** - use `.method_name`:
```ruby
RSpec.describe UserService do
  describe ".call" do
    # tests for class method
  end
end
```

**For request specs** - use action style (not routes):
```ruby
# ✅ CORRECT - full route-path style with HTTP verb
RSpec.describe Admin::TipsController, type: :request do
  describe "#index" do
    # tests for the index page
  end

  describe "#create" do
    # tests for creating
  end

  describe "#update" do
    # tests for updating
  end

  describe "#destroy" do
    # tests for destroying
  end
end

# ❌ WRONG - controller action style
RSpec.describe Admin::TipsController, type: :request do
  describe "GET #index" do  # Don't use method + action
    # tests
  end

  describe "PATCH /admin/tips/:id" do  # Don't use route
    # tests
  end
end
```

### Context Blocks

Always start with "when":
```ruby
context "when user is authenticated" do
  # tests
end

context "when email is invalid" do
  # tests
end

context "when URL has trailing slash" do
  # tests
end
```

### It Blocks

Should read naturally when combined with describe/context:
```ruby
describe "#full_name" do
  context "when first and last name are present" do
    it "returns concatenated name" do
      # test
    end
  end
end
# Reads as: "#full_name when first and last name are present returns concatenated name"
```

---

## Complete Test Example

```ruby
RSpec.describe UrlAccessibilityService do
  describe "#call" do
    context "when URL is invalid" do
      it "returns false for nil URL" do
        result = described_class.call(url: nil)

        expect(result).to be false
      end

      it "returns false for empty string URL" do
        # ACT
        result = described_class.call(url: "")

        # ASSERT
        expect(result).to be false
      end
    end

    context "when URL is accessible" do
      it "returns true for successful GET request" do
        # ARRANGE
        # Note: Addressable adds trailing slash, so stub must include it
        stub_request(:get, "https://southparkshop.com/")
          .to_return(status: 200)

        # ACT
        result = described_class.call(url: "southparkshop.com")

        # ASSERT
        expect(result).to be true
      end
    end
  end
end
```

---

## Arrange-Act-Assert Pattern

### Three Sections (with blank lines between)

```ruby
it "processes the order" do
  # Arrange - set up test data
  user = create(:user, first_name: "Stan", last_name: "Marsh")
  order = create(:order, user: user)

  # Act - execute the code under test
  result = described_class.call(order: order)

  # Assert - verify the outcome
  expect(result).to be true
  expect(order.reload.status).to eq("processed")
end
```

### When to Skip Comments
For simple tests, arrange/act/assert are obvious:
```ruby
it "returns false for nil URL" do
  result = described_class.call(url: nil)

  expect(result).to be false
end
```

---

## Using `described_class`

**ALWAYS** use `described_class` instead of repeating the class name:

```ruby
# ✅ CORRECT
RSpec.describe UserService do
  it "calls the service" do
    result = described_class.call(user: user)
  end
end

# ❌ WRONG
RSpec.describe UserService do
  it "calls the service" do
    result = UserService.call(user: user)  # Don't repeat class name
  end
end
```

---

## Service Object Testing

For services that use `.call` class method:

```ruby
# ✅ CORRECT - matches actual usage
result = described_class.call(url: "example.com")

# ❌ WRONG - don't use .new.call in tests
result = described_class.new(url: "example.com").call
```

---

## Test Doubles

### Naming Test Doubles

**No `_double` suffix** — name it like the thing it represents:

```ruby
# ✅ CORRECT - simple, descriptive names
service = instance_double(SomeService)
client = instance_double(ShopifyAPI::Clients::Graphql::Admin)
response = instance_double(ShopifyAPI::Clients::HttpResponse, body: response_body)

# ❌ WRONG - suffix adds noise
service_double = instance_double(SomeService)
```

**Use short, generic names** — `client` not `graphql_client`, `response` not `api_response`. The `instance_double` class already provides context about what type it is.

### Using `instance_double`

**ALWAYS** use `instance_double(ClassName)` instead of bare `double()` — for **every** test double, not just service objects:

```ruby
# ✅ CORRECT - type-safe
service = instance_double(EmailService, send_email: true)

# ❌ WRONG - no type checking
service = double(send_email: true)
```

### Raw Response & Error Doubles

**Use `instance_double(Faraday::Response)` for HTTP/API response objects** — including raw responses from gems like RubyLLM, and response objects passed to error constructors:

```ruby
# ✅ CORRECT - verifies success? and body exist on Faraday::Response
raw_response = instance_double(Faraday::Response, success?: true, body: { "citations" => [...] })

faraday_response = instance_double(Faraday::Response, body: '{"error": {"type": "invalid_request"}}')
error = RubyLLM::BadRequestError.new(faraday_response)

# ❌ WRONG - bare double has no type verification
raw_response = double(success?: true, body: { "citations" => [...] })
faraday_response = double(body: '{"error": {"type": "invalid_request"}}')
```

**Why:** If the gem changes its response interface (renames `body`, removes `success?`), `instance_double` fails immediately. A bare `double` silently passes with stale assumptions.

### API Response Doubles

**Use `instance_double` instead of `OpenStruct`** for stubbing API responses:

```ruby
# ✅ CORRECT - type-safe, verifies body is a real method
response_body = { "data" => { "shop" => { "plan" => { "shopifyPlus" => true } } } }
response = instance_double(ShopifyAPI::Clients::HttpResponse, body: response_body)

# ❌ WRONG - OpenStruct allows any method, no type checking
response = OpenStruct.new(body: { "data" => { ... } })
```

**Why:** `instance_double` catches typos and API changes at test time — if the response class doesn't have a `body` method, the test fails immediately. `OpenStruct` silently accepts anything.

---

## HTTP Request Stubbing

### WebMock Stubs

**IMPORTANT**: `Addressable::URI.heuristic_parse(...).display_uri` adds a trailing slash!

```ruby
# ✅ CORRECT - includes trailing slash
stub_request(:get, "https://example.com/")
  .to_return(status: 200, body: "content")

# ❌ WRONG - missing trailing slash
stub_request(:get, "https://example.com")  # Won't match!
```

### Full Example

```ruby
it "fetches the page content" do
  # Note the trailing slash in the stub URL
  stub_request(:get, "https://southparkshop.com/")
    .to_return(status: 200, body: "<html>Content</html>")

  result = PageFetcher.call(url: "southparkshop.com")

  expect(result).to be_present
end
```

---

## Factory Bot

### Using Factories

```ruby
# Create and save to database
user = create(:user, first_name: "Stan")

# Build without saving
user = build(:user, first_name: "Stan")

# Build without saving, stub associations
user = build_stubbed(:user, first_name: "Stan")
```

### When to Use Each

- **`create`**: When you need database persistence
- **`build`**: When you need validation but not persistence
- **`build_stubbed`**: Fastest - when database persistence isn't required

### Shorthand Keyword Syntax in Factories

**Use Ruby 3.1+ shorthand** when the variable name matches the keyword:

```ruby
# ✅ CORRECT - shorthand when variable name matches
chat = create(:chat)
user = create(:user)
chat_tip = create(:chat_tip, chat:, tip:, status: "pending")

# ❌ WRONG - redundant when names match
chat_tip = create(:chat_tip, chat: chat, tip: tip, status: "pending")
```

This applies to all factory calls: `create`, `build`, `build_stubbed`, and service/method calls in tests.

### Factory Attributes

**CRITICAL**: Only use attributes that actually exist on the model!

```ruby
# ❌ WRONG - Chat model doesn't have a 'name' attribute
chat = create(:chat, name: "Stan's Shop")

# ✅ CORRECT - Use only real attributes
chat = create(:chat)
chat = create(:chat, widget_color: "#FF5733")
```

**Before using factory attributes:**
1. Check the model schema or factory definition
2. Don't assume attributes exist based on other models
3. Remove unnecessary attributes - factories provide sensible defaults

### Use Faker for Dynamic Factory Data

**When creating or updating factories, use Faker to generate realistic, unique data instead of hardcoded strings.** This matches the existing convention across the codebase (see `page`, `lead`, `embedding`, `purchase_record` factories).

```ruby
# ✅ CORRECT - dynamic Faker data
factory :tip do
  name { Faker::Lorem.sentence(word_count: 3) }
  description { Faker::Lorem.paragraph }
  benefits { Array.new(2) { Faker::Lorem.sentence(word_count: 3) } }
  article_url { Faker::Internet.url }
  platforms { ["shopify", "shopify_plus"] }
end

# ❌ WRONG - hardcoded static strings
factory :tip do
  name { "Test your chat" }
  description { "Send a test message to see how your AI chatbot responds." }
  article_url { "https://docs.zipchat.ai/getting-started/test-chat" }
end
```

**Common Faker generators for factories:**
- Names/titles: `Faker::Lorem.sentence(word_count: 3)`
- Text/descriptions: `Faker::Lorem.paragraph`
- URLs: `Faker::Internet.url`
- Emails: `Faker::Internet.email`
- Numbers: `Faker::Number.number(digits: 5)`
- Alphanumeric tokens: `Faker::Alphanumeric.alphanumeric(number: 20)`

**When hardcoded values ARE appropriate:**
- Enum values, status strings (`"pending"`, `"shopify"`)
- Boolean flags
- Structured config (JSON schemas, platform arrays)
- Values that must match specific formats not well-served by Faker

### Don't Override Attributes Just for Readability

**Only override factory attributes when the value affects behavior or is asserted on.** Use descriptive variable names instead of decorative attribute overrides:

```ruby
# ✅ CORRECT - variable names convey purpose, no unnecessary overrides
shopify_tip = create(:tip, :shopify_only)
create(:tip, :shopify_plus_only)

# ❌ WRONG - name: overrides are never asserted on or used in logic
shopify_tip = create(:tip, :shopify_only, name: "Shopify tip")
create(:tip, :shopify_plus_only, name: "Plus-only tip")

# ✅ CORRECT - override IS needed because the test asserts on it
tip = create(:tip, name: "Stan's Tip")
expect(result.name).to eq("Stan's Tip")

# ✅ CORRECT - override IS needed because it affects behavior
chat = create(:chat, platform_type: "shopify")
```

**Rule of thumb:** If you remove a factory attribute override and the test still passes with the same meaning, the override was unnecessary.

---

## Turbo Stream Testing

Test Turbo Stream responses:

```ruby
it "responds with turbo stream format" do
  post conversation_path, params: { message: "Hello" }

  expect(response.media_type).to eq("text/vnd.turbo-stream.html")
end
```

---

## ViewComponent Testing

### Basic Component Test Structure

```ruby
RSpec.describe Conversations::ChatAvatarComponent, type: :component do
  describe "rendering" do
    it "renders avatar with correct classes" do
      chat = create(:chat)
      component = described_class.new(chat:, size: :md)

      rendered = render_inline(component)

      expect(rendered.css("div.rounded-full")).to be_present
    end
  end
end
```

### Consolidate Similar Field Tests

**IMPORTANT**: Don't create separate tests for each form field. Group them together!

```ruby
# ✅ CORRECT - one test for all fields
it "renders form with all required fields and buttons" do
  rendered = render_inline(component)

  expect(rendered.css("input[name='form[subject]']")).to be_present
  expect(rendered.css("input[name='form[to]']")).to be_present
  expect(rendered.css("input[name='form[cc]']")).to be_present
  expect(rendered.css("textarea[name='form[message]']")).to be_present
  expect(rendered.text).to include("Send")
  expect(rendered.text).to include("Cancel")
end

# ❌ WRONG - separate test for each field (too verbose)
it "renders form with subject field" do
  rendered = render_inline(component)
  expect(rendered.css("input[name='form[subject]']")).to be_present
end

it "renders form with to field" do
  rendered = render_inline(component)
  expect(rendered.css("input[name='form[to]']")).to be_present
end

it "renders form with cc field" do
  rendered = render_inline(component)
  expect(rendered.css("input[name='form[cc]']")).to be_present
end
# ... (too many repeated tests)
```

**When to consolidate:**
- Multiple form fields in the same form
- Similar UI elements (buttons, links, etc.)
- Related attributes on the same element

**Benefits:**
- Fewer test runs = faster test suite
- Single `render_inline` call instead of multiple
- Easier to maintain
- Follows the pattern in `lead_collection_component_spec.rb`

### Consolidate Visual Element Tests in the Same Context

Try to consolidate as much as you can in a single test. In most of the cases each `describe`/`context` should only have one `it` block.

Use a different `context` if you need to create a different test case.

```ruby
# ✅ CORRECT - one test for visual elements in the same context
describe "rendering" do
  it "renders modal with email signature form and signature explanation" do
    email_domain = create(:email_domain, :zipchat, :active)
    chat = email_domain.chat
    component = described_class.new(chat:)

    rendered = render_inline(component)

    expect(rendered.text).to include("Email setup")
    expect(rendered.text).to include(email_domain.email_address)
    expect(rendered.css("textarea")).to be_present
    expect(rendered.text).to include("This is the default signature when your AI Agent sends emails")
  end
end

# ❌ WRONG - many tests for visual elements in the same context
describe "rendering" do
  it "renders modal with email signature form" do
    email_domain = create(:email_domain, :zipchat, :active)
    chat = email_domain.chat
    component = described_class.new(chat:)

    rendered = render_inline(component)

    expect(rendered.text).to include("Email setup")
    expect(rendered.text).to include(email_domain.email_address)
    expect(rendered.css("textarea")).to be_present
  end

  it "renders banner with signature explanation" do
    email_domain = create(:email_domain, :zipchat, :active)
    chat = email_domain.chat
    component = described_class.new(chat:)

    rendered = render_inline(component)

    expect(rendered.text).to include("This is the default signature when your AI Agent sends emails")
  end
end
```

### Testing Conditional Rendering

```ruby
describe "#render?" do
  context "when user is present" do
    it "returns true" do
      component = described_class.new(user: user, chat: chat)

      expect(component.render?).to be true
    end
  end

  context "when user is nil" do
    it "does not render anything" do
      component = described_class.new(user: nil, chat: chat)
      rendered = render_inline(component)

      expect(rendered.to_s).to be_empty
    end
  end
end
```

### Testing Component Variants

Use contexts for different size/style variants:

```ruby
describe "rendering" do
  context "when size is :sm" do
    it "renders with small size classes" do
      component = described_class.new(chat:, size: :sm)

      rendered = render_inline(component)

      expect(rendered.css("div.h-6.w-6")).to be_present
    end
  end

  context "when size is :lg" do
    it "renders with large size classes" do
      component = described_class.new(chat:, size: :lg)

      rendered = render_inline(component)

      expect(rendered.css("div.h-16.w-16")).to be_present
    end
  end
end
```

### Testing With Active Storage

```ruby
describe "rendering with photo attached" do
  it "renders cloudinary image with correct size" do
    chat.photo.attach(
      io: StringIO.new("fake image content"),
      filename: "shop-logo.jpg",
      content_type: "image/jpeg"
    )

    rendered = render_inline(component)

    expect(rendered.css("img.rounded-full")).to be_present
  end
end

describe "rendering without photo" do
  it "renders fallback avatar initial" do
    rendered = render_inline(component)

    expect(rendered.css("div.rounded-full")).to be_present
    expect(rendered.text).to include(chat.avatar_initial)
  end
end
```

### CSS Selector Tips

```ruby
# Check for element presence
expect(rendered.css("div.class-name")).to be_present

# Check for specific attributes
expect(rendered.css("input[name='field_name']")).to be_present
expect(rendered.css("button[type='submit']")).to be_present

# Check for data attributes
expect(rendered.css("[data-controller='name']")).to be_present
expect(rendered.css("img[data-page-target='preview']")).to be_present

# Check inline styles
div = rendered.css("div.rounded-full").first
expect(div["style"]).to include("background-color: #FF5733")

# Check text content
expect(rendered.text).to include("Expected Text")
```

---

## Let vs Let!

### `let` - Lazy Evaluation
Evaluated when first referenced:
```ruby
let(:user) { create(:user) }  # Not created until used
```

### `let!` - Eager Evaluation
Evaluated before each test:
```ruby
let!(:user) { create(:user) }  # Created before every test
```

**IMPORTANT**: Never use `let`/`let`, prefer local variables instead.

```ruby
# ✅ GOOD
describe "#call" do
  it "processes the user" do
    user = create(:user, first_name: "Stan")

    result = described_class.call(user: user)

    expect(result).to be true
  end
end

# ❌ BAD
describe "#call" do
  let(:user) { create(:user, first_name: "Stan") }

  it "processes the user" do
    result = UserProcessor.call(user: user)
    expect(result).to be true
  end
end
```

**IMPORTANT**: avoid using `before`, repeat the setup in each test case.

### Request Specs with Authentication

**IMPORTANT**: For request specs requiring authentication, use this pattern:

```ruby
# ✅ CORRECT
RSpec.describe Polaris::UsersController, type: :request do
  describe "#update" do
    it "updates the user" do
      user = create(:user, :onboarded, :owner, first_name: "John", last_name: "Oliver")
      sign_in user

      patch user_path, params: { user: { full_name: "Ayrton Senna" } }

      expect(response).to have_http_status(:success)
      expect(user.reload.full_name).to eq('Ayrton Senna')
    end
  end
end

# ❌ WRONG - using let variables and route in description
RSpec.describe Polaris::UsersController, type: :request do
  let(:user) { create(:user, :onboarded, :owner) }
  describe "PATCH /update" do
    it "updates the user" do
      sign_in user
      patch user_path, params: { user: { full_name: "Kyle" } }
    end
  end
end
```

---

## Memoization in Tests

Use memoization (`||=`) **only** for expensive operations:

```ruby
# ✅ CORRECT - expensive parsing operation
def parsed_json
  @parsed_json ||= JSON.parse(large_file_content)
end

# ❌ WRONG - simple getter doesn't need memoization
def user_name
  @user_name ||= user.name  # Overkill
end

# ✅ BETTER - just call it directly
def user_name
  user.name
end
```

---

## Expectations

### No Change Matcher

Avoid using the `change` matcher as much as possible since it adds unnecessary noise to tests:

```ruby
# ❌ WRONG - change matcher adds noise to the test
describe "#destroy" do
  it "destroys the localisation and redirects to index" do
    admin = create(:user, :admin)
    sign_in admin
    localisation = create(:localisation)

    expect do
      delete admin_localisation_path(localisation)
    end.to change(Localisation, :count).by(-1)

    expect(response).to redirect_to(admin_localisations_path)
  end
end
```

```ruby
# ✅ CORRECT - easy to understand the ACT part of the test
describe "#destroy" do
  it "destroys the localisation and redirects to index" do
    admin = create(:user, :admin)
    sign_in admin
    localisation = create(:localisation)

    delete admin_localisation_path(localisation)

    expect(response).to redirect_to(admin_localisations_path)
    expect(Localisation.count).to eq(0)
  end
end
```

### No Custom Failure Messages

**NEVER** pass a second string argument to matchers as a custom failure message. This pattern is not used in the codebase and adds noise:

```ruby
# ❌ WRONG - custom failure message string
expect(video).to be_valid, "Expected #{url} to be valid"
expect(result).to eq(expected_id), "Expected #{url} to extract ID #{expected_id}"

# ✅ CORRECT - standard matcher, no custom message
expect(video).to be_valid
expect(result).to eq(expected_id)
```

**Why:** RSpec's default failure messages already include the expected vs actual values. Custom messages add inconsistency and are not used anywhere else in the codebase. If a test fails inside a loop, the test name and matcher output provide enough context.

### Prefer Specific Matchers

```ruby
# ✅ CORRECT - specific matchers
expect(result).to be true
expect(result).to be false
expect(result).to be_nil
expect(array).to be_empty
expect(value).to eq(10)

# ❌ LESS CLEAR - generic matchers
expect(result).to be_truthy
expect(result).to be_falsey
```

### Multiple Expectations

Group related expectations in a single test for performance:

```ruby
it "updates the user profile" do
  user = create(:user, first_name: "Stan")

  result = UpdateProfile.call(user: user, first_name: "Kyle")

  expect(result).to be true
  expect(user.reload.first_name).to eq("Kyle")
  expect(user.updated_at).to be > 1.minute.ago
end
```

### Collection Assertions: `eq`, `contain_exactly`, and `include`

**CRITICAL**: Never use `include`/`not_to include` for collection assertions. Always use `eq` or `contain_exactly`:

| Matcher | Use when | Checks order? | Checks exact set? |
|---------|----------|---------------|-------------------|
| `eq` | Collection has a defined order | Yes | Yes |
| `contain_exactly` | Collection has no guaranteed order | No | Yes |

```ruby
# ✅ CORRECT - ordered collection (query objects with .order scope)
expect(described_class.call(scope, status, user)).to eq([newer, older])

# ✅ CORRECT - unordered collection (maintenance task collections, scopes without order)
expect(task.collection).to contain_exactly(eligible_record)

# ❌ WRONG - include only checks presence, misses extra/missing records
expect(result).to include(conversation)
expect(collection_ids).to include(record.id)
expect(collection_ids).not_to include(excluded.id)
```

**Why never `include` for collections:**
- `include` allows extra unexpected records to sneak through
- `include`/`not_to include` pairs are verbose and test less
- `contain_exactly` catches both missing AND unexpected records in one assertion

**When `include` IS appropriate:**
- Testing string content: `expect(response.body).to include("Test your chat")`
- Testing rendered HTML: `expect(rendered.text).to include("Send")`
- NOT for testing which records are in a collection

**CRITICAL REMINDER**: Every time you write `expect(result).to include(...)` on a collection, STOP and replace with `eq` (if ordered) or `contain_exactly` (if unordered).

---

## Checklist

Before considering tests complete:

- [ ] NO `require "rails_helper"`
- [ ] Used `describe` with `.method` or `#method` for services/models
- [ ] Used `describe` with full action style (`"#show"`) for request specs (NOT `"GET /:id"`)
- [ ] Used `context "when ..."`
- [ ] Used `described_class` instead of class name
- [ ] **NEVER** use `let`/`let!` and `before` constructs
- [ ] Blank lines between arrange/act/assert (if not obvious)
- [ ] No `_double` suffix on test doubles
- [ ] **All doubles use `instance_double(ClassName)`** — never bare `double()`
- [ ] **Exact value assertions** — used `eq(expected)` not `be_a(Hash)`, `be > 0`, or other vague matchers
- [ ] WebMock stubs include trailing slash (if using Addressable)
- [ ] Tests are self-contained and readable
- [ ] Only testing critical scenarios (not overdoing it)
- [ ] Testing behavior, NOT implementation details
- [ ] Related tests merged where appropriate
- [ ] No change matcher
- [ ] **No custom failure messages** on matchers (no second string argument like `be_valid, "message"`)
- [ ] **For collections**: Used `eq` (ordered) or `contain_exactly` (unordered), NEVER `include`/`not_to include`
- [ ] **For components**: Consolidated similar field tests into single tests
- [ ] **For components**: Configured Cloudinary in `before` block if testing image uploads
- [ ] **For factories**: Used Faker for dynamic data (names, descriptions, URLs, emails) — no hardcoded strings
- [ ] **For factories**: Only used attributes that exist on the model
- [ ] **For factories**: No decorative attribute overrides (only override when asserted on or behavior-affecting)
- [ ] **RAN THE TESTS** to verify they pass

---

