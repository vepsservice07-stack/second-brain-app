#!/bin/bash
set -e

echo "======================================"
echo "Fixing Routes File"
echo "======================================"

cd ~/Code/second-brain-app/second-brain-rails

echo ""
echo "Backing up current routes..."
cp config/routes.rb config/routes.rb.backup

echo ""
echo "Fixing routes.rb structure..."

cat > config/routes.rb << 'RUBY'
Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root "notes#index"
  
  resources :notes do
    resources :interactions, only: [:create, :index]
    
    member do
      get 'time_machine'
      get 'at_sequence/:sequence', to: 'time_machine#show', as: 'at_sequence'
      get 'structure_suggestions'
      post 'apply_structure'
      get 'semantic_field'
    end
  end
  
  resources :tags, only: [:index, :show]
  resources :causal_links, only: [:index, :show]
end
RUBY

echo "✓ Fixed routes.rb"

echo ""
echo "Verifying routes..."
bin/rails routes > /dev/null 2>&1 && echo "✓ Routes valid" || echo "⚠ Routes may have issues"

echo ""
echo "======================================"
echo "✓ Routes file fixed!"
echo "======================================"
echo ""