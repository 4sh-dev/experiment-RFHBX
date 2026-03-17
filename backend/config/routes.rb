# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    get "health", to: "health#show"
  end
end
