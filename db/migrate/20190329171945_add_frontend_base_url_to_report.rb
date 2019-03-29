class AddFrontendBaseUrlToReport < ActiveRecord::Migration[5.0]
  def change
    add_column :reports, :frontend_base_url, :string
  end
end
