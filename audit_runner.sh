#!/bin/bash
# Season App Audit Runner
# Version: 1.0 (2026-05-06)
# Updated: 2026-05-06 08:56

APP_PATH="/Users/tichlabs/Documents/onlyCode/season-temp"
SKILLS_FILE="$APP_PATH/docs/audit_skills.md"

echo "======================================"
echo "  Season App Audit Runner"
echo "  Based on codebase chapters (ch01-ch10)"
echo "======================================"
echo ""

# Function to run a specific audit
run_audit() {
    local chapter=$1
    echo "Running Chapter $chapter Audit..."
    echo "--------------------------------------"
    
    case $chapter in
        1)
            echo "Checking Chapter 1: Foundation"
            cd "$APP_PATH" || exit
            echo "- Ruby version:" && cat .ruby-version
            echo "- Rails version:" && grep "rails" Gemfile
            echo "- Database:" && grep "adapter" config/database.yml | head -1
            echo "- Rubocop check:" && bundle exec rubocop --format simple 2>&1 | tail -5
            ;;
        2)
            echo "Checking Chapter 2: Core Features"
            echo "- Models:" && ls -1 app/models/*.rb | wc -l
            echo "- Controllers:" && ls -1 app/controllers/*.rb | wc -l
            echo "- Routes defined:" && grep -c "resource\|get\|post" config/routes.rb
            ;;
        3)
            echo "Checking Chapter 3: Views & Styling"
            echo "- Checking inline styles:" && grep -r 'style="' app/views/ 2>/dev/null | grep -v "phase_colour" | wc -l
            echo "- Checking brand classes:" && grep -r "text-brand-primary" app/views/ 2>/dev/null | wc -l
            echo "- Checking i18n:" && grep -r "t(" app/views/ 2>/dev/null | wc -l
            ;;
        4)
            echo "Checking Chapter 4: Authentication"
            echo "- Authentication concern:" && ls -1 app/controllers/concerns/authentication.rb 2>/dev/null && echo "✅ Exists" || echo "❌ Missing"
            echo "- Devise config:" && ls -1 config/initializers/devise.rb 2>/dev/null && echo "✅ Exists" || echo "❌ Missing"
            echo "- OmniAuth:" && grep "omniauth" config/initializers/devise.rb 2>/dev/null && echo "✅ Configured" || echo "⚠️ Not found"
            ;;
        5)
            echo "Checking Chapter 5: Mobile PWA"
            echo "- PWA manifest:" && ls -1 public/manifest.json app/views/pwa/manifest.json 2>/dev/null | head -1
            echo "- Viewport meta:" && grep "viewport" app/views/layouts/application.html.erb 2>/dev/null && echo "✅ Present" || echo "❌ Missing"
            echo "- Mobile container:" && grep "max-w-app" app/views/layouts/application.html.erb 2>/dev/null && echo "✅ Present" || echo "❌ Missing"
            ;;
        6)
            echo "Checking Chapter 6: Advanced Features"
            echo "- Jobs:" && ls -1 app/jobs/*.rb 2>/dev/null | wc -l
            echo "- Services:" && ls -1 app/services/*.rb 2>/dev/null | wc -l
            echo "- Solid Queue:" && grep "solid_queue" Gemfile 2>/dev/null && echo "✅ Present" || echo "❌ Missing"
            ;;
        8)
            echo "Checking Chapter 8: Integration"
            echo "- Resend:" && grep "resend" Gemfile 2>/dev/null && echo "✅ Present" || echo "❌ Missing"
            echo "- Sentry:" && grep "sentry" Gemfile 2>/dev/null && echo "✅ Present" || echo "⚠️ Missing"
            echo "- Stripe:" && grep "stripe" Gemfile 2>/dev/null && echo "✅ Wired" || echo "❌ Missing"
            ;;
        9)
            echo "Checking Chapter 9: Testing"
            cd "$APP_PATH" || exit
            echo "- Running tests:" && bin/rails test 2>&1 | tail -3
            echo "- Test files:" && find test/ -name "*.rb" 2>/dev/null | wc -l
            ;;
        10)
            echo "Checking Chapter 10: Production"
            echo "- Render build:" && ls -1 bin/render-build.sh 2>/dev/null && echo "✅ Exists" || echo "❌ Missing"
            echo "- Config hosts:" && grep "config.hosts" config/environments/production.rb 2>/dev/null && echo "✅ Set" || echo "⚠️ Not set (TODO)"
            echo "- CSP:" && grep "content_security_policy" config/environments/production.rb 2>/dev/null && echo "✅ Configured" || echo "⚠️ Not enforced"
            ;;
        *)
            echo "Unknown chapter: $chapter"
            ;;
    esac
    echo ""
}

# Main logic
case $1 in
    chapter1|1)
        run_audit 1
        ;;
    chapter2|2)
        run_audit 2
        ;;
    chapter3|3)
        run_audit 3
        ;;
    chapter4|4)
        run_audit 4
        ;;
    chapter5|5)
        run_audit 5
        ;;
    chapter6|6)
        run_audit 6
        ;;
    chapter8|8)
        run_audit 8
        ;;
    chapter9|9)
        run_audit 9
        ;;
    chapter10|10)
        run_audit 10
        ;;
    all)
        echo "Running all chapter audits..."
        for ch in 1 2 3 4 5 6 8 9 10; do
            run_audit $ch
            echo ""
        done
        ;;
    security)
        echo "Running Security Audit..."
        echo "--------------------------------------"
        cd "$APP_PATH" || exit
        echo "- Sessions controller:" && ls app/controllers/sessions_controller.rb && echo "✅"
        echo "- Rate limiting:" && ls config/initializers/rack_attack.rb 2>/dev/null && echo "✅ Rack::Attack configured" || echo "⚠️ Missing (HIGH priority)"
        echo "- CSP:" && grep "content_security_policy" config/environments/production.rb && echo "✅" || echo "⚠️ Not enforced"
        echo "- Config hosts:" && grep "config.hosts" config/environments/production.rb && echo "✅" || echo "⚠️ Commented out"
        echo "- Devise paranoid:" && grep "paranoid" config/initializers/devise.rb 2>/dev/null && echo "✅" || echo "⚠️ Not set (MEDIUM priority)"
        ;;
    pre-launch|prelaunch)
        echo "Running Pre-Launch Checklist..."
        echo "--------------------------------------"
        echo "From README.md 'What's Left Before Launch':"
        echo ""
        echo "HIGH Priority:"
        echo "- OAuth credentials on Render: ⚠️  TODO (set in dashboard)"
        echo "- Config.hosts: ⚠️  TODO (uncomment in production.rb)"
        echo "- Rack::Attack: ⚠️  TODO (add to login endpoints)"
        echo "- config.load_defaults 8.1: ⚠️  TODO (run bin/rails app:update)"
        echo ""
        echo "MEDIUM Priority:"
        echo "- Devise paranoid: ⚠️  TODO (config.paranoid = true)"
        echo "- CSP enforcement: ⚠️  TODO (flip report_only to false)"
        echo "- Active Storage S3: ⚠️  TODO (switch from local disk)"
        echo "- Sentry DSN: ⚠️  TODO (set on Render)"
        echo ""
        echo "LOW Priority:"
        echo "- Stripe paywall: ⚠️  Post-launch"
        ;;
    *)
        echo "Usage: $0 [chapter|all|security|pre-launch]"
        echo ""
        echo "Examples:"
        echo "  $0 chapter1     # Audit Chapter 1"
        echo "  $0 3            # Audit Chapter 3"
        echo "  $0 all          # Run all chapter audits"
        echo "  $0 security      # Run security audit"
        echo "  $0 pre-launch   # Check pre-launch items"
        echo ""
        echo "Based on: /Users/tichlabs/Documents/codebase/code/ (ch01_00 to ch10_68)"
        ;;
esac

echo ""
echo "======================================"
echo "  Audit complete"
echo "  Full checklist: $APP_PATH/audit_checklist.md"
echo "  Skills: $APP_PATH/audit_skills.md"
echo "======================================"
