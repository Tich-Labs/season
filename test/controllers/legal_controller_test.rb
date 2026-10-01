# frozen_string_literal: true

require "test_helper"

class LegalControllerTest < ActionDispatch::IntegrationTest
  test "GET /legal/terms renders the English terms" do
    get legal_path(type: "terms", locale: "en")
    assert_response :success
    assert_match "Terms of Participation", response.body
  end

  test "GET /legal/privacy renders the English privacy notice" do
    get legal_path(type: "privacy", locale: "en")
    assert_response :success
    assert_match "Privacy Notice", response.body
  end

  test "GET /legal/terms renders German when German is requested" do
    get legal_path(type: "terms", locale: "de")
    assert_response :success
    assert_match "Teilnahmebedingungen", response.body
  end

  test "GET /legal/privacy renders German when German is requested" do
    get legal_path(type: "privacy", locale: "de")
    assert_response :success
    assert_match "Datenschutzhinweise", response.body
  end

  test "legal pages are noindex" do
    get legal_path(type: "terms", locale: "en")
    assert_equal "noindex, nofollow", response.headers["X-Robots-Tag"]
  end

  test "legal pages do not render the funnel progress bar" do
    get legal_path(type: "terms", locale: "en")
    assert_no_match(/beta-steps/, response.body)
  end

  test "legal page links back into the funnel" do
    get legal_path(type: "terms", locale: "en")
    assert_match beta_path(locale: "en"), response.body
  end

  test "legacy /terms path still resolves" do
    get terms_path
    assert_response :success
  end

  test "legacy /privacy path still resolves" do
    get privacy_path
    assert_response :success
  end

  test "an unknown legal type does not resolve to a legal page" do
    get "/legal/cookies"
    assert_response :not_found
  end

  test "content hashes differ between locales" do
    en = Legal::Content.find(type: "terms", locale: "en")
    de = Legal::Content.find(type: "terms", locale: "de")
    assert_not_equal en.body_sha256, de.body_sha256
  end

  test "content hash is stable across calls" do
    content = Legal::Content.find(type: "privacy", locale: "en")
    assert_equal content.body_sha256, content.body_sha256
  end

  test "an invalid locale is rejected" do
    assert_raises(ArgumentError) do
      Legal::Content.new(type: "terms", locale: "fr")
    end
  end

  test "an invalid type is rejected" do
    assert_raises(ArgumentError) do
      Legal::Content.new(type: "cookies", locale: "en")
    end
  end

  # The person who taps the privacy notice on the registration screen must come
  # back to the registration screen, not be dumped on step 1 with an empty form.
  test "the back link returns to the step the document was opened from" do
    get legal_path(type: "privacy", locale: "en", from: "register")
    assert_response :success
    assert_select ".beta-legal__back a[href=?]", beta_register_path(locale: "en")
    assert_select ".beta-legal__back a[href=?]", beta_consent_path(locale: "en"), count: 0
  end

  test "the consent screen's back link returns to the consent step" do
    get legal_path(type: "privacy", locale: "en", from: "consent")
    assert_select ".beta-legal__back a[href=?]", beta_consent_path(locale: "en")
  end

  test "an unknown or missing from param falls back to the first step" do
    get legal_path(type: "privacy", locale: "en")
    assert_select ".beta-legal__back a[href=?]", beta_consent_path(locale: "en")

    get legal_path(type: "privacy", locale: "en", from: "https://evil.test")
    assert_response :success
    assert_select ".beta-legal__back a[href=?]", beta_consent_path(locale: "en")
  end

  # The authored files are whole HTML documents, but only their body is served.
  # Rendering the whole file nested a second <html>/<body> inside the layout
  # and printed the heading twice.
  test "the served body has no document scaffolding and no duplicate heading" do
    Legal::Content::TYPES.product(Legal::Content::LANGUAGES).each do |type, locale|
      body = Legal::Content.find(type: type, locale: locale).body

      assert_no_match(/<html|<head|<body|<title/i, body, "#{type}.#{locale} leaks document tags")
      assert_no_match(/<h1/i, body, "#{type}.#{locale} still carries its own h1")
      assert_predicate body.strip, :present?
    end
  end

  test "the legal page shows the heading exactly once" do
    get legal_path(type: "terms", locale: "en")
    assert_select "h1", 1
    assert_select "h1", text: "Terms of Participation"
    assert_select "h4", 6
  end

  # The prototype placeholder note ("Abridged for this prototype", "the German
  # versions are binding") is gone; the full-text link is an unbuilt slot.
  test "the prototype placeholder note is gone from every document" do
    Legal::Content::TYPES.product(Legal::Content::LANGUAGES).each do |type, locale|
      body = Legal::Content.find(type: type, locale: locale).body

      # NB: "die deutsche Fassung ist verbindlich" in terms.de is real contract
      # text in the body and must stay — only the prototype note is removed.
      assert_no_match(/Abridged|Kurzfassung|insert full text|Volltext einfügen/i, body, "#{type}.#{locale}")
      assert_no_match(/convenience translation/i, body, "#{type}.#{locale}")
      assert_no_match(/class="note"/, body, "#{type}.#{locale}")
    end
  end

  test "the full-text link is a non-navigable placeholder" do
    get legal_path(type: "terms", locale: "en")
    assert_select ".beta-legal__full .beta-link--pending", text: "Read full version"
    assert_select ".beta-legal__full a", count: 0

    get legal_path(type: "terms", locale: "de")
    assert_select ".beta-legal__full .beta-link--pending", text: "Vollständige Version lesen"
  end
end
