require 'rails_helper'

RSpec.describe ProductsController, type: :controller do
  describe 'GET #index' do
    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe 'POST #create' do
    context 'when URLs are valid' do
      let(:valid_urls) { "https://oz.by/entertainment/\nhttps://oz.by/souvenir/" }
      let(:products_data) { [{ oz_id: 1, price: 100 }, { oz_id: 2, price: 200 }] }

      before do
        allow(ProductScraper).to receive(:call).and_return(products_data)
        post :create, params: { urls: valid_urls }
      end

      it 'creates category links' do
        expect(CategoryLink.count).to eq(2)
      end

      it 'saves products' do
        expect(Product.count).to eq(2)
      end

      it 'saves price history' do
        expect(PriceHistory.count).to eq(2)
      end

      it 'sets a success flash message' do
        expect(flash[:success]).to be_present
      end

      it 'redirects to root path' do
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when URLs are invalid' do
      let(:invalid_urls) { 'http://invalid-url.com' }

      before do
        post :create, params: { urls: invalid_urls }
      end

      it 'does not create category links' do
        expect(CategoryLink.count).to eq(0)
      end

      it 'sets an error flash message' do
        expect(flash[:error]).to be_present
      end

      it 'renders the index template with unprocessable content status' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET #statistics' do
    let(:product) { create(:product) }
    let(:start_date) { Faker::Date.between_except(from: 1.year.ago, to: 1.year.from_now, excepted: Time.zone.today) }
    let(:end_date) { Faker::Date.between_except(from: 1.year.ago, to: 1.year.from_now, excepted: Time.zone.today) }

    context 'when format is HTML' do
      it 'renders the statistics template' do
        get :statistics,
            params: { info: product.link, start_date:, end_date: }
        expect(response).to render_template(:statistics)
      end
    end

    context 'when format is Turbo Stream' do
      before do
        get :statistics,
            params: { info: product.link, format: :turbo_stream, start_date:, end_date: }
      end

      it 'responds with turbo stream format' do
        expect(response.content_type).to eq('text/vnd.turbo-stream.html; charset=utf-8')
      end

      it 'assigns the correct variables' do
        expect(assigns(:info)).to eq(product.link)
      end
    end
  end
end
