# frozen_string_literal: true

# Emails an Android beta tester their self-serve access instructions. Used only
# when the Google Play Developer API isn't configured, so the Google Group +
# Play links are the only way in. Google has no API to add members to a consumer
# group and group → Play access can take a while to propagate, so emailing the
# links means the tester isn't left on the confirmation page waiting.
class BetaInviteMailer < ApplicationMailer
  def android_group_links(beta_tester)
    @beta_tester = beta_tester
    @group_link = ENV["GOOGLE_PLAY_GROUP_URL"].presence
    @play_link = ENV["GOOGLE_PLAY_OPEN_TESTING_URL"].presence

    mail(to: beta_tester.email, subject: t(".subject"))
  end
end
