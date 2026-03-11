# Examples

**Model/Service/PORO Spec Structure**:
```ruby
RSpec.describe MyService do
  describe "#process" do
    it "processes the record" do
      record = create(:record)

      service = described_class.new(record)
      result = service.process

      expect(result).to be true
    end
  end

  describe "#validate" do
    it "validates the record" do
      record = create(:record)

      service = described_class.new(record)
      result = service.validate

      expect(result).to be true
    end
  end
end
```

**Request Spec Structure**:
```ruby
RSpec.describe Admin::TipsController, type: :request do
  describe "#index" do
    context "when admin user is signed in" do
      it "renders the index page" do
        admin = create(:user, :admin, first_name: "Eric", last_name: "Cartman")
        sign_in admin
        create(:tip, name: "Test your chat")

        get admin_tips_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include("Test your chat")
      end
    end

    context "when no user is signed in" do
      it "redirects to the sign in page" do
        get admin_tips_path

        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
```

**ViewComponent Test Structure**:
```ruby
RSpec.describe Conversations::FollowUpModalComponent, type: :component do
  describe "rendering" do
    it "renders form with all required fields and buttons" do
      chat = create(:chat)
      user = create(:user, first_name: "Eric", last_name: "Cartman")
      component = described_class.new(chat_id: chat.id, current_user_id: user.id)

      rendered = render_inline(component)

      expect(rendered.css("turbo-frame#follow-up-modal-frame")).to be_present
      expect(rendered.css("input[name='form[subject]']")).to be_present
      expect(rendered.css("input[name='form[to]']")).to be_present
      expect(rendered.css("input[name='form[cc]']")).to be_present
      expect(rendered.css("textarea[name='form[message]']")).to be_present
      expect(rendered.text).to include("Send")
      expect(rendered.text).to include("Cancel")
    end
  end
end
```
