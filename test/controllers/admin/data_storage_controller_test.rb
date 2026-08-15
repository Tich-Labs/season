require "test_helper"

class Admin::DataStorageControllerTest < ActionDispatch::IntegrationTest
  def setup
    @admin = User.create!(
      email: "gdpradmin@example.com", name: "GDPR Admin", password: "password123", password_confirmation: "password123",
      admin: true
    ).tap(&:confirm)
  end

  test "GET /admin/data_storage redirects to sign in when not authenticated" do
    get admin_data_storage_path
    assert_redirected_to new_session_path
  end

  test "GET /admin/data_storage redirects a non-admin user to root" do
    sign_in_as(users(:alice))
    get admin_data_storage_path
    assert_redirected_to root_path
  end

  test "GET /admin/data_storage renders for an admin" do
    sign_in_as(@admin)
    get admin_data_storage_path
    assert_response :success
    assert_match(/Data Storage Report/, response.body)
    assert_match(/Server —/, response.body)
    assert_match(/User's device/, response.body)
  end

  test "report lists Devise columns, app-owned columns, and related data tables" do
    sign_in_as(@admin)
    get admin_data_storage_path
    assert_response :success
    assert_match(/encrypted_password/, response.body)
    assert_match(/reset_password_token/, response.body)
    assert_match(/confirmation_token/, response.body)
    assert_match(/encrypted_password<\/code> is a bcrypt hash/, response.body)
    assert_match(/onboarding_completed/, response.body)
    assert_match(/last_period_start/, response.body)
    assert_match(/notification_preferences/, response.body)
    assert_match(/Cycle entries/, response.body)
    assert_match(/Symptom logs/, response.body)
    assert_match(/Superpower logs/, response.body)
    assert_match(/dependent: :destroy/, response.body)
    assert_match(/_season_session/, response.body)
    assert_match(/remember_user_token/, response.body)
    assert_match(/holiday_country/, response.body)
    assert_match(/season-v2-v1/, response.body)
  end

  test "report surfaces live counts for related tables" do
    sign_in_as(@admin)
    CycleEntry.create!(user: @admin, date: Time.zone.today, phase: "menstrual")
    get admin_data_storage_path
    assert_response :success
    assert_match(/Cycle entries/, response.body)
    assert_match(/<td class="py-2 pr-4 text-right text-xs text-gray-600">1<\/td>/, response.body)
  end
end
