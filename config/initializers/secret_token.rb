PageProcessor::Application.config.secret_token = if Rails.env.development? or Rails.env.test?
  "it was the nbest of times, it was the worst of times" # meets minimum requirement of 30 chars long
else
  ENV['SECRET_TOKEN']
end