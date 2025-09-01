Rails.application.routes.draw do
  post "/payments", to: "payments#create"
end
