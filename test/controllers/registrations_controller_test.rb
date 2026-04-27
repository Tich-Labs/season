require "test_helper"

# M1 — Sign Up
class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "GET /registration/new renders sign-up form" do
    get new_registration_path
    assert_response :success
  end

  test "POST /registration with valid params signs in and redirects" do
    post registration_path, params: {
      email: "newuser@example.com",
      password: "securepassword1",
      password_confirmation: "securepassword1"
    }
    assert_response :redirect
  end

  test "POST /registration creates a User record" do
    assert_difference("User.count", 1) do
      post registration_path, params: {
        email: "newuser2@example.com",
        password: "securepassword1",
        password_confirmation: "securepassword1"
      }
    end
  end

  test "POST /registration with duplicate email renders 422" do
    post registration_path, params: {
      email: users(:alice).email,
      password: "securepassword1",
      password_confirmation: "securepassword1"
    }
    assert_response :unprocessable_entity
  end

  test "POST /registration with blank email renders 422" do
    post registration_path, params: {email: "", password: "securepassword1"}
    assert_response :unprocessable_entity
  end

  test "GET /registration/new redirects to calendar when already signed in" do
    sign_in_as(users(:alice))
    get new_registration_path
    assert_response :redirect
  end
end
