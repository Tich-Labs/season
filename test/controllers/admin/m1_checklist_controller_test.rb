require "test_helper"

class Admin::M1ChecklistControllerTest < ActionDispatch::IntegrationTest
  def setup
    @admin = User.create!(
      email: "m1admin@example.com", name: "M1 Admin", password: "password123", password_confirmation: "password123",
      admin: true
    ).tap(&:confirm)
  end

  test "GET /admin/m1_checklist redirects to sign in when not authenticated" do
    get admin_m1_checklist_path
    assert_redirected_to new_session_path
  end

  test "GET /admin/m1_checklist redirects a non-admin user to root" do
    sign_in_as(users(:alice))
    get admin_m1_checklist_path
    assert_redirected_to root_path
  end

  test "GET /admin/m1_checklist renders for an admin" do
    sign_in_as(@admin)
    get admin_m1_checklist_path
    assert_response :success
    assert_select "[data-controller='m1-checklist']"
    assert_match(/M1 — Signing In &amp; Onboarding/, response.body)
  end

  test "GET /admin/m1_checklist includes all onboarding steps as checkboxes" do
    sign_in_as(@admin)
    get admin_m1_checklist_path
    assert_response :success
    assert_select "[data-m1-checklist-target='checkbox']", minimum: 20
    assert_match(/Step 1 \(Name\)/, response.body)
    assert_match(/Step 10 \(Food preferences\)/, response.body)
    assert_match(/\/onboarding\/finish/, response.body)
  end

  test "POST /admin/m1_checklist/toggle saves a check for the current admin" do
    sign_in_as(@admin)
    assert_difference "M1ChecklistCheck.count", 1 do
      post admin_m1_checklist_toggle_path, params: {item_key: "ob_step1", checked: "1"}, as: :json
    end
    assert_response :success
    body = response.parsed_body
    assert body["ok"]
    assert body["checked"]
    assert_equal 1, body["done"]
    assert_equal 39, body["total"]
    check = M1ChecklistCheck.find_by!(user: @admin, item_key: "ob_step1")
    assert_not_nil check.checked_at
  end

  test "POST /admin/m1_checklist/toggle removes a check when unchecked" do
    sign_in_as(@admin)
    post admin_m1_checklist_toggle_path, params: {item_key: "ob_step2", checked: "1"}, as: :json
    assert_difference "M1ChecklistCheck.count", -1 do
      post admin_m1_checklist_toggle_path, params: {item_key: "ob_step2", checked: "0"}, as: :json
    end
    assert_response :success
    assert response.parsed_body["ok"]
  end

  test "POST /admin/m1_checklist/toggle rejects an unknown item key" do
    sign_in_as(@admin)
    post admin_m1_checklist_toggle_path, params: {item_key: "nope", checked: "1"}, as: :json
    assert_response :unprocessable_entity
  end

  test "POST /admin/m1_checklist/toggle requires authentication" do
    post admin_m1_checklist_toggle_path, params: {item_key: "ob_step1", checked: "1"}, as: :json
    assert_redirected_to new_session_path
  end

  test "GET /admin/m1_checklist shows checked state and tester attribution" do
    sign_in_as(@admin)
    M1ChecklistCheck.create!(user: @admin, item_key: "ob_step3", checked_at: Time.current)
    other = users(:alice)
    other.update!(admin: true)
    M1ChecklistCheck.create!(user: other, item_key: "ob_step3", checked_at: Time.current)

    get admin_m1_checklist_path
    assert_response :success
    item = Nokogiri::HTML(response.body).at("input[data-item='ob_step3']")
    assert_not_nil item
    assert_equal "checked", item["checked"]
    assert_match(/verified by/, response.body)
  end

  test "POST /admin/m1_checklist/reset clears only the current admin's checks" do
    sign_in_as(@admin)
    M1ChecklistCheck.create!(user: @admin, item_key: "ob_step4", checked_at: Time.current)
    other = users(:alice)
    other.update!(admin: true)
    M1ChecklistCheck.create!(user: other, item_key: "ob_step4", checked_at: Time.current)

    post admin_m1_checklist_reset_path, as: :json
    assert_response :success
    assert_equal 0, M1ChecklistCheck.where(user: @admin).count
    assert_equal 1, M1ChecklistCheck.where(user: other).count
  end
end
