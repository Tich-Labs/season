require "test_helper"

class Settings::LanguageControllerTest < ActionDispatch::IntegrationTest
  def setup
    @alice = users(:alice)
    sign_in_as(@alice)
  end

  test "GET /settings/language returns 200" do
    get settings_language_path
    assert_response :success
  end

  test "GET /settings/language requires authentication" do
    delete session_path
    get settings_language_path
    assert_redirected_to new_session_path
  end

  # Settings::LanguageController is a namespaced controller, so
  # controller_name alone returns "language", not "settings" — it used to
  # miss the dark header + generic "Settings" title every sibling settings
  # page gets, and render its own redundant in-page header instead.
  test "GET /settings/language gets the same dark header as sibling settings pages" do
    get settings_language_path
    assert_match(/bg-brand-primary/, response.body)
    assert_match(">Settings<", response.body)
  end

  # Every settings page/sub-page gets the centred calendar FAB (bg-brand-field,
  # aria-label "Go to calendar") instead of the "+" or the default bottom-right
  # calendar FAB (aria-label "Back to calendar").
  test "GET /settings/language shows only the centred calendar FAB" do
    get settings_language_path
    assert_no_match(/quick-actions#open/, response.body)
    assert_no_match(/Back to calendar/, response.body)
    assert_match(/Go to calendar/, response.body)
  end

  # Two real entry points — the main settings menu, and the "EN" pill on
  # /calendar — so back must reflect the real referer.
  test "back link reflects the settings menu as referer" do
    get settings_language_path, headers: {"HTTP_REFERER" => edit_settings_url}
    assert_match %r{href="/settings/edit"}, response.body
  end

  test "back link reflects calendar as referer" do
    get settings_language_path, headers: {"HTTP_REFERER" => user_root_url}
    assert_match %r{href="/calendar"}, response.body
  end

  test "back link falls back to the settings menu with no referer" do
    get settings_language_path
    assert_match %r{href="/settings/edit"}, response.body
  end

  test "PATCH /settings/language updates the user's language" do
    patch settings_language_path, params: {user: {language: "de"}}
    assert_redirected_to edit_settings_path
    assert_equal "de", @alice.reload.language
  end

  test "PATCH /settings/language with an invalid language shows an error" do
    patch settings_language_path, params: {user: {language: "xx"}}
    assert_redirected_to edit_settings_path
    assert_not_nil flash[:alert]
  end
end
