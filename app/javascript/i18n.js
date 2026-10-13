// Client-side translation lookup.
//
// Stimulus controllers that need to show user-facing text read it from
// window.I18n, which application.html.erb renders from the `js` namespace of
// config/locales/*.yml. Keys are looked up with dot notation and %{name}
// placeholders are interpolated, mirroring Rails' I18n.t so a single source of
// truth (the locale files) covers both server- and client-rendered strings.

function dict () {
  return (typeof window !== 'undefined' && window.I18n) ? window.I18n : {}
}

function lookup (key) {
  return key.split('.').reduce((obj, part) => (obj == null ? undefined : obj[part]), dict())
}

export function t (key, vars) {
  const value = lookup(key)
  if (typeof value !== 'string') return key
  if (!vars) return value
  return value.replace(/%\{(\w+)\}/g, (match, name) => (
    Object.prototype.hasOwnProperty.call(vars, name) ? vars[name] : match
  ))
}

export function tArray (key) {
  const value = lookup(key)
  return Array.isArray(value) ? value : []
}

export default t
