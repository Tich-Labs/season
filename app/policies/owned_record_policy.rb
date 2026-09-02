# Shared behavior for the small set of per-user records a user can look up
# by id (calendar events, symptom logs, superpower logs, notifications):
# every action is allowed only when the record belongs to the current user.
#
# Controllers already scope their lookups through `current_user.assoc.find`,
# so `record` here can never actually belong to someone else in practice —
# this is deliberate defense-in-depth, not a fix for a live IDOR. Its value
# is systematic: a future action that forgets to scope its lookup, but still
# calls `authorize`, is caught here instead of leaking another user's data.
class OwnedRecordPolicy < ApplicationPolicy
  def show? = owner?

  def create? = owner?

  def new? = create?

  def update? = owner?

  def destroy? = owner?

  private

  def owner?
    record.user_id == user&.id
  end
end
