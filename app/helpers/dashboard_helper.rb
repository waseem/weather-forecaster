module DashboardHelper
  def retrieve_address(geocoded, address)
    geocoded&.address || address
  end
end
