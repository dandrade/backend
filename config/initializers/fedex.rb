FEDEX_CREDENTIALS = YAML.load_file("#{Rails.root.to_s}/config/fedex_credentials.yml")[Rails.env]