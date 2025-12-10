#!/bin/bash
set -e

echo "======================================"
echo "🌙 Adding Dark Mode Toggle"
echo "======================================"
echo ""

cd ~/Code/second-brain-app/second-brain-rails

# Step 1: Update the layout with dark mode support
echo "Step 1: Adding dark mode CSS and toggle..."
echo "======================================"

cat > app/views/layouts/application.html.erb << 'HTML'
<!DOCTYPE html>
<html>
  <head>
    <title>Second Brain · Think Clearly</title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <meta name="turbo-visit-control" content="reload">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
    <%= javascript_importmap_tags %>
    
    <style>
      /* ============================================ */
      /* THE THERAPIST AESTHETIC - DESIGN SYSTEM */
      /* ============================================ */
      
      :root {
        /* Primary: Warm, calming blue-grey */
        --color-primary: #5B7C99;
        --color-primary-light: #7B9CB9;
        --color-primary-dark: #3B5C79;
        
        /* Accent: Soft gold for important moments */
        --color-accent: #D4A574;
        --color-accent-light: #E8C9A1;
        
        /* Light mode */
        --color-bg: #F8F7F5;
        --color-bg-elevated: #FFFFFF;
        --color-text: #2C3E50;
        --color-text-subtle: #7F8C99;
        --color-border: rgba(91, 124, 153, 0.15);
        
        /* States */
        --color-success: #6B9080;
        --color-warning: #D4A574;
        --color-error: #C17767;
        
        /* Shadows: Soft and subtle */
        --shadow-sm: 0 2px 8px rgba(91, 124, 153, 0.08);
        --shadow-md: 0 4px 16px rgba(91, 124, 153, 0.12);
        --shadow-lg: 0 8px 32px rgba(91, 124, 153, 0.16);
        
        /* Transitions */
        --ease-smooth: cubic-bezier(0.4, 0, 0.2, 1);
      }
      
      /* ============================================ */
      /* DARK MODE - Warm, not harsh */
      /* ============================================ */
      
      [data-theme="dark"] {
        --color-bg: #1a1a1a;
        --color-bg-elevated: #2a2a2a;
        --color-text: #e8e6e3;
        --color-text-subtle: #a8a6a3;
        --color-border: rgba(255, 255, 255, 0.1);
        
        /* Slightly muted colors for dark mode */
        --color-primary: #7B9CB9;
        --color-accent: #E8C9A1;
        
        /* Softer shadows for dark mode */
        --shadow-sm: 0 2px 8px rgba(0, 0, 0, 0.3);
        --shadow-md: 0 4px 16px rgba(0, 0, 0, 0.4);
        --shadow-lg: 0 8px 32px rgba(0, 0, 0, 0.5);
      }
      
      /* ============================================ */
      /* RESET & BASE */
      /* ============================================ */
      
      * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
      }
      
      body {
        font-family: 'Inter', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
        font-size: 16px;
        line-height: 1.6;
        color: var(--color-text);
        background: var(--color-bg);
        -webkit-font-smoothing: antialiased;
        -moz-osx-font-smoothing: grayscale;
        transition: background-color 0.3s var(--ease-smooth), color 0.3s var(--ease-smooth);
      }
      
      h1, h2, h3, h4, h5, h6 {
        font-family: 'Crimson Pro', Georgia, serif;
        font-weight: 600;
        color: var(--color-text);
        line-height: 1.2;
      }
      
      h1 { font-size: 2.5rem; margin-bottom: 1rem; }
      h2 { font-size: 2rem; margin-bottom: 0.875rem; }
      h3 { font-size: 1.5rem; margin-bottom: 0.75rem; }
      
      /* ============================================ */
      /* DARK MODE TOGGLE - Elegant moon/sun icon */
      /* ============================================ */
      
      .theme-toggle {
        background: transparent;
        border: 2px solid var(--color-border);
        color: var(--color-text);
        width: 40px;
        height: 40px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        transition: all 0.3s var(--ease-smooth);
        font-size: 1.2rem;
      }
      
      .theme-toggle:hover {
        background: var(--color-bg);
        border-color: var(--color-primary);
        transform: rotate(20deg);
      }
      
      /* ============================================ */
      /* NAVBAR - Calm, spacious, minimal */
      /* ============================================ */
      
      .navbar {
        background: var(--color-bg-elevated);
        border-bottom: 1px solid var(--color-border);
        padding: 1.5rem 2rem;
        position: sticky;
        top: 0;
        z-index: 100;
        backdrop-filter: blur(10px);
        transition: all 0.3s var(--ease-smooth);
      }
      
      .navbar-container {
        max-width: 1400px;
        margin: 0 auto;
        display: flex;
        justify-content: space-between;
        align-items: center;
      }
      
      .navbar-brand {
        font-family: 'Crimson Pro', Georgia, serif;
        font-size: 1.5rem;
        font-weight: 600;
        color: var(--color-primary);
        text-decoration: none;
        letter-spacing: -0.02em;
        transition: color 0.3s var(--ease-smooth);
      }
      
      .navbar-brand:hover {
        color: var(--color-primary-dark);
      }
      
      .navbar-links {
        display: flex;
        gap: 2rem;
        align-items: center;
      }
      
      .navbar-links a {
        color: var(--color-text-subtle);
        text-decoration: none;
        font-size: 0.9rem;
        font-weight: 500;
        transition: color 0.3s var(--ease-smooth);
        position: relative;
      }
      
      .navbar-links a:hover {
        color: var(--color-primary);
      }
      
      .navbar-links a::after {
        content: '';
        position: absolute;
        bottom: -4px;
        left: 0;
        width: 0;
        height: 2px;
        background: var(--color-accent);
        transition: width 0.3s var(--ease-smooth);
      }
      
      .navbar-links a:hover::after {
        width: 100%;
      }
      
      /* ============================================ */
      /* NOTICES & ALERTS - Gentle, non-intrusive */
      /* ============================================ */
      
      .notice, .alert {
        padding: 1rem 2rem;
        margin: 0;
        font-size: 0.95rem;
        animation: slideDown 0.4s var(--ease-smooth);
      }
      
      @keyframes slideDown {
        from {
          opacity: 0;
          transform: translateY(-10px);
        }
        to {
          opacity: 1;
          transform: translateY(0);
        }
      }
      
      .notice {
        background: rgba(107, 144, 128, 0.15);
        color: var(--color-success);
        border-left: 3px solid var(--color-success);
      }
      
      .alert {
        background: rgba(193, 119, 103, 0.15);
        color: var(--color-error);
        border-left: 3px solid var(--color-error);
      }
      
      /* ============================================ */
      /* CONTAINER - Breathing room */
      /* ============================================ */
      
      .container {
        max-width: 900px;
        margin: 0 auto;
        padding: 3rem 2rem;
      }
      
      .container-wide {
        max-width: 1200px;
        margin: 0 auto;
        padding: 3rem 2rem;
      }
      
      /* ============================================ */
      /* CARDS - Soft, elevated, warm */
      /* ============================================ */
      
      .card {
        background: var(--color-bg-elevated);
        border-radius: 12px;
        padding: 2rem;
        box-shadow: var(--shadow-sm);
        transition: all 0.3s var(--ease-smooth);
        border: 1px solid var(--color-border);
      }
      
      .card:hover {
        box-shadow: var(--shadow-md);
        transform: translateY(-2px);
      }
      
      .card-title {
        margin-bottom: 0.5rem;
        color: var(--color-text);
      }
      
      .card-subtitle {
        color: var(--color-text-subtle);
        font-size: 0.9rem;
        margin-bottom: 1rem;
      }
      
      /* ============================================ */
      /* BUTTONS - Warm, inviting, gentle */
      /* ============================================ */
      
      .btn {
        display: inline-block;
        padding: 0.75rem 1.5rem;
        border-radius: 8px;
        text-decoration: none;
        font-weight: 500;
        font-size: 0.95rem;
        transition: all 0.3s var(--ease-smooth);
        cursor: pointer;
        border: none;
      }
      
      .btn-primary {
        background: var(--color-primary);
        color: white;
      }
      
      .btn-primary:hover {
        background: var(--color-primary-dark);
        transform: translateY(-1px);
        box-shadow: var(--shadow-md);
      }
      
      .btn-accent {
        background: var(--color-accent);
        color: white;
      }
      
      .btn-accent:hover {
        background: #C89564;
        transform: translateY(-1px);
        box-shadow: var(--shadow-md);
      }
      
      .btn-secondary {
        background: rgba(91, 124, 153, 0.15);
        color: var(--color-primary);
      }
      
      .btn-secondary:hover {
        background: rgba(91, 124, 153, 0.25);
      }
      
      .btn-ghost {
        background: transparent;
        color: var(--color-text-subtle);
        border: 1px solid var(--color-border);
      }
      
      .btn-ghost:hover {
        background: var(--color-bg);
        border-color: var(--color-primary);
        color: var(--color-primary);
      }
      
      /* ============================================ */
      /* FORMS - Clean, spacious, approachable */
      /* ============================================ */
      
      .form-group {
        margin-bottom: 1.5rem;
      }
      
      .form-label {
        display: block;
        margin-bottom: 0.5rem;
        font-weight: 500;
        color: var(--color-text);
        font-size: 0.95rem;
      }
      
      .form-input {
        width: 100%;
        padding: 0.875rem 1rem;
        border: 2px solid var(--color-border);
        border-radius: 8px;
        font-size: 1rem;
        font-family: inherit;
        color: var(--color-text);
        background: var(--color-bg-elevated);
        transition: all 0.3s var(--ease-smooth);
      }
      
      .form-input:focus {
        outline: none;
        border-color: var(--color-primary);
        box-shadow: 0 0 0 3px rgba(91, 124, 153, 0.15);
      }
      
      .form-textarea {
        min-height: 200px;
        resize: vertical;
      }
      
      /* ============================================ */
      /* UTILITIES */
      /* ============================================ */
      
      .text-subtle {
        color: var(--color-text-subtle);
        font-size: 0.9rem;
      }
      
      .text-center {
        text-align: center;
      }
      
      .mb-1 { margin-bottom: 0.5rem; }
      .mb-2 { margin-bottom: 1rem; }
      .mb-3 { margin-bottom: 1.5rem; }
      .mb-4 { margin-bottom: 2rem; }
      
      .mt-1 { margin-top: 0.5rem; }
      .mt-2 { margin-top: 1rem; }
      .mt-3 { margin-top: 1.5rem; }
      .mt-4 { margin-top: 2rem; }
      
      .flex {
        display: flex;
      }
      
      .flex-between {
        display: flex;
        justify-content: space-between;
        align-items: center;
      }
      
      .flex-center {
        display: flex;
        justify-content: center;
        align-items: center;
      }
      
      .gap-1 { gap: 0.5rem; }
      .gap-2 { gap: 1rem; }
      .gap-3 { gap: 1.5rem; }
      
      /* ============================================ */
      /* MOBILE RESPONSIVE */
      /* ============================================ */
      
      @media (max-width: 768px) {
        .navbar {
          padding: 1rem;
        }
        
        .navbar-links {
          gap: 1rem;
        }
        
        .navbar-links a {
          font-size: 0.85rem;
        }
        
        .container, .container-wide {
          padding: 2rem 1rem;
        }
        
        h1 { font-size: 2rem; }
        h2 { font-size: 1.5rem; }
        h3 { font-size: 1.25rem; }
        
        .card {
          padding: 1.5rem;
        }
      }
    </style>
    
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Crimson+Pro:wght@400;600&family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
    
    <!-- Dark Mode Script -->
    <script>
      // Load theme preference on page load
      (function() {
        const theme = localStorage.getItem('theme') || 'light';
        document.documentElement.setAttribute('data-theme', theme);
      })();
      
      // Toggle theme function
      function toggleTheme() {
        const html = document.documentElement;
        const currentTheme = html.getAttribute('data-theme') || 'light';
        const newTheme = currentTheme === 'light' ? 'dark' : 'light';
        
        html.setAttribute('data-theme', newTheme);
        localStorage.setItem('theme', newTheme);
        
        // Update icon
        const icon = document.querySelector('.theme-toggle');
        icon.textContent = newTheme === 'light' ? '🌙' : '☀️';
      }
    </script>
  </head>

  <body>
    <nav class="navbar">
      <div class="navbar-container">
        <div>
          <%= link_to "Second Brain", root_path, class: "navbar-brand" %>
        </div>
        
        <div class="navbar-links">
          <% if user_signed_in? %>
            <%= link_to "Notes", notes_path %>
            <%= link_to "Profile", profile_path %>
            <button class="theme-toggle" onclick="toggleTheme()" title="Toggle dark mode">
              <span id="theme-icon">🌙</span>
            </button>
            <%= link_to "Sign Out", destroy_user_session_path, data: { turbo_method: :delete } %>
          <% else %>
            <button class="theme-toggle" onclick="toggleTheme()" title="Toggle dark mode">
              <span id="theme-icon">🌙</span>
            </button>
            <%= link_to "Sign In", new_user_session_path %>
            <%= link_to "Sign Up", new_user_registration_path, class: "btn btn-primary", style: "padding: 0.5rem 1rem;" %>
          <% end %>
        </div>
      </div>
    </nav>
    
    <% if notice %>
      <div class="notice"><%= notice %></div>
    <% end %>
    
    <% if alert %>
      <div class="alert"><%= alert %></div>
    <% end %>

    <%= yield %>
    
    <script>
      // Set initial icon based on current theme
      document.addEventListener('DOMContentLoaded', function() {
        const currentTheme = document.documentElement.getAttribute('data-theme') || 'light';
        const icon = document.getElementById('theme-icon');
        if (icon) {
          icon.textContent = currentTheme === 'light' ? '🌙' : '☀️';
        }
      });
    </script>
  </body>
</html>
HTML

echo "✓ Dark mode added to layout"

echo ""
echo "======================================"
echo "✅ Dark Mode Complete!"
echo "======================================"
echo ""
echo "What's new:"
echo "  🌙 Dark mode toggle button in navbar"
echo "  🎨 Warm dark theme (not harsh black)"
echo "  💾 Preference saved in localStorage"
echo "  ✨ Smooth transition between modes"
echo ""
echo "Dark mode colors:"
echo "  • Background: #1a1a1a (warm black)"
echo "  • Cards: #2a2a2a (elevated dark)"
echo "  • Text: #e8e6e3 (warm white)"
echo "  • Accents: Slightly muted for comfort"
echo ""
echo "Refresh your browser and click the 🌙 icon!"
echo ""