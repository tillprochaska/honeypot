require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe TextComponentsController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # TextComponent. As you add validations to TextComponent, be sure to
  # adjust the attributes here as well.
  let(:report) { create(:report) }
  let(:valid_attributes) {
    { heading: 'A heading', report_id: report.id }
  }

  let(:invalid_attributes) {
    { heading: nil  }
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # TextComponentsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "assigns all text_components as @text_components" do
      text_component = TextComponent.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:text_components)).to eq([text_component])
    end
  end

  describe "GET #show" do
    it "assigns the requested text_component as @text_component" do
      text_component = TextComponent.create! valid_attributes
      get :show, {:id => text_component.to_param}, valid_session
      expect(assigns(:text_component)).to eq(text_component)
    end
  end

  describe "GET #new" do
    it "assigns a new text_component as @text_component" do
      get :new, {}, valid_session
      expect(assigns(:text_component)).to be_a_new(TextComponent)
    end
  end

  describe "GET #edit" do
    it "assigns the requested text_component as @text_component" do
      text_component = TextComponent.create! valid_attributes
      get :edit, {:id => text_component.to_param}, valid_session
      expect(assigns(:text_component)).to eq(text_component)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new TextComponent" do
        expect {
          post :create, {:text_component => valid_attributes}, valid_session
        }.to change(TextComponent, :count).by(1)
      end

      it "assigns a newly created text_component as @text_component" do
        post :create, {:text_component => valid_attributes}, valid_session
        expect(assigns(:text_component)).to be_a(TextComponent)
        expect(assigns(:text_component)).to be_persisted
      end

      it "redirects to the created text_component" do
        post :create, {:text_component => valid_attributes}, valid_session
        expect(response).to redirect_to(TextComponent.last)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved text_component as @text_component" do
        post :create, {:text_component => invalid_attributes}, valid_session
        expect(assigns(:text_component)).to be_a_new(TextComponent)
      end

      it "re-renders the 'new' template" do
        post :create, {:text_component => invalid_attributes}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        { heading: 'A new heading', main_part: 'Plus a main part' }
      }

      it "updates the requested text_component" do
        text_component = TextComponent.create! valid_attributes
        put :update, {:id => text_component.to_param, :text_component => new_attributes}, valid_session
        text_component.reload
        expect(text_component.heading).to eq 'A new heading'
        expect(text_component.main_part).to eq 'Plus a main part'
      end

      it "assigns the requested text_component as @text_component" do
        text_component = TextComponent.create! valid_attributes
        put :update, {:id => text_component.to_param, :text_component => valid_attributes}, valid_session
        expect(assigns(:text_component)).to eq(text_component)
      end

      it "redirects to the text_component" do
        text_component = TextComponent.create! valid_attributes
        put :update, {:id => text_component.to_param, :text_component => valid_attributes}, valid_session
        expect(response).to redirect_to(text_component)
      end
    end

    context "with invalid params" do
      it "assigns the text_component as @text_component" do
        text_component = TextComponent.create! valid_attributes
        put :update, {:id => text_component.to_param, :text_component => invalid_attributes}, valid_session
        expect(assigns(:text_component)).to eq(text_component)
      end

      it "re-renders the 'edit' template" do
        text_component = TextComponent.create! valid_attributes
        put :update, {:id => text_component.to_param, :text_component => invalid_attributes}, valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested text_component" do
      text_component = TextComponent.create! valid_attributes
      expect {
        delete :destroy, {:id => text_component.to_param}, valid_session
      }.to change(TextComponent, :count).by(-1)
    end

    it "redirects to the text_components list" do
      text_component = TextComponent.create! valid_attributes
      delete :destroy, {:id => text_component.to_param}, valid_session
      expect(response).to redirect_to(text_components_url)
    end
  end

end