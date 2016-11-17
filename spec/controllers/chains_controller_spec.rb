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

RSpec.describe ChainsController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # Chain. As you add validations to Chain, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    { hashtag: '#superhashtag' }
  }

  let(:invalid_attributes) {
    { hashtag: nil }
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # ChainsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "assigns all chains as @chains" do
      chain = Chain.create! valid_attributes
      get :index, params: {}, session: valid_session
      expect(assigns(:chains)).to eq([chain])
    end
  end

  describe "GET #show" do
    it "assigns the requested chain as @chain" do
      chain = Chain.create! valid_attributes
      get :show, params: {:id => chain.to_param}, session: valid_session
      expect(assigns(:chain)).to eq(chain)
    end
  end

  describe "GET #new" do
    it "assigns a new chain as @chain" do
      get :new, params: {}, session: valid_session
      expect(assigns(:chain)).to be_a_new(Chain)
    end
  end

  describe "GET #edit" do
    it "assigns the requested chain as @chain" do
      chain = Chain.create! valid_attributes
      get :edit, params: {:id => chain.to_param}, session: valid_session
      expect(assigns(:chain)).to eq(chain)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Chain" do
        expect {
          post :create, params: {:chain => valid_attributes}, session: valid_session
        }.to change(Chain, :count).by(1)
      end

      it "assigns a newly created chain as @chain" do
        post :create, params: {:chain => valid_attributes}, session: valid_session
        expect(assigns(:chain)).to be_a(Chain)
        expect(assigns(:chain)).to be_persisted
      end

      it "redirects to the created chain" do
        post :create, params: {:chain => valid_attributes}, session: valid_session
        expect(response).to redirect_to(Chain.last)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved chain as @chain" do
        post :create, params: {:chain => invalid_attributes}, session: valid_session
        expect(assigns(:chain)).to be_a_new(Chain)
      end

      it "re-renders the 'new' template" do
        post :create, params: {:chain => invalid_attributes}, session: valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        { hashtag: '#itsanewhashtag' }
      }

      it "updates the requested chain" do
        chain = Chain.create! valid_attributes
        put :update, params: {:id => chain.to_param, :chain => new_attributes}, session: valid_session
        chain.reload
        expect(chain.hashtag).to eq '#itsanewhashtag'
      end

      it "assigns the requested chain as @chain" do
        chain = Chain.create! valid_attributes
        put :update, params: {:id => chain.to_param, :chain => valid_attributes}, session: valid_session
        expect(assigns(:chain)).to eq(chain)
      end

      it "redirects to the chain" do
        chain = Chain.create! valid_attributes
        put :update, params: {:id => chain.to_param, :chain => valid_attributes}, session: valid_session
        expect(response).to redirect_to(chain)
      end
    end

    context "with invalid params" do
      it "assigns the chain as @chain" do
        chain = Chain.create! valid_attributes
        put :update, params: {:id => chain.to_param, :chain => invalid_attributes}, session: valid_session
        expect(assigns(:chain)).to eq(chain)
      end

      it "re-renders the 'edit' template" do
        chain = Chain.create! valid_attributes
        put :update, params: {:id => chain.to_param, :chain => invalid_attributes}, session: valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested chain" do
      chain = Chain.create! valid_attributes
      expect {
        delete :destroy, params: {:id => chain.to_param}, session: valid_session
      }.to change(Chain, :count).by(-1)
    end

    it "redirects to the chains list" do
      chain = Chain.create! valid_attributes
      delete :destroy, params: {:id => chain.to_param}, session: valid_session
      expect(response).to redirect_to(chains_url)
    end
  end

end
