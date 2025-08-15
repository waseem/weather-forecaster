require 'rails_helper'

RSpec.describe "Dashboards", type: :system do
  before do
    driven_by(:rack_test)
  end

  it "shows forecast for an address" do
    visit root_path
    expect(page).to have_text("Your weather forecast")
  end

  it "shows an address input field" do
    visit root_path
    expect(page).to have_field("address")
  end
end
