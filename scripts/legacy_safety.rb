# The coursework server is historical source, not the public portfolio runtime.
module LegacySafety
  def self.verify!
    production = %w[APP_ENV RACK_ENV].any? { |key| ENV[key] == 'production' }
    if production || ENV.key?('VERCEL')
      abort 'The legacy Sinatra app is not approved for public deployment. Build the static portfolio with npm run build. See docs/SECURITY.md.'
    end

    testing = ENV['APP_ENV'] == 'test' && ENV['RACK_ENV'] == 'test'
    unless testing || ENV['UNICONNECT_LEGACY_LOCAL'] == '1'
      abort 'Legacy server disabled by default. Use npm run dev for the portfolio. For local historical study only, set UNICONNECT_LEGACY_LOCAL=1. Never expose it through a proxy or Funnel. See docs/SECURITY.md.'
    end
  end
end
