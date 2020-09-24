class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  self.pluralize_table_names = false

  def self.signed_url(file_name, method, service_name, expires, region_name = nil, bucket = nil)
    return nil if file_name.nil?

    time_now = Time.now.utc
    amzdate = time_now.strftime('%Y%m%dT%H%M%SZ')
    datestamp = time_now.strftime('%Y%m%d')

    algorithm = 'AWS4-HMAC-SHA256'

    access_key = ENV['AWS_ACCESS_KEY_ID']
    secret_key = ENV['AWS_SECRET_ACCESS_KEY']

    signed_headers = 'host'
    canonical_headers = "host:#{bucket}\n"

    scope = "#{datestamp}/#{region_name}/#{service_name}/aws4_request"

    canonical_querystring = "X-Amz-Algorithm=#{CGI.escape(algorithm)}" \
                          "&X-Amz-Credential=#{CGI.escape("#{access_key}/#{scope}")}" \
                          "&X-Amz-Date=#{CGI.escape(amzdate)}" \
                          "&X-Amz-Expires=#{expires.to_i}" \
                          "&X-Amz-SignedHeaders=#{CGI.escape(signed_headers)}"

    canonical_request = [method,
                         "/#{file_name}",
                         canonical_querystring,
                         canonical_headers,
                         signed_headers,
                         'UNSIGNED-PAYLOAD'].join("\n")

    string_to_sign = [algorithm,
                      amzdate,
                      scope,
                      OpenSSL::Digest.new('sha256').hexdigest(canonical_request)].join("\n")

    signature_key = get_signature_key(secret_key,
                                      datestamp,
                                      region_name,
                                      service_name)

    signature = OpenSSL::HMAC.hexdigest('sha256', signature_key, string_to_sign)

    "https://#{bucket}/#{file_name}?#{canonical_querystring}&X-Amz-Signature=#{signature}"
  end

  def self.get_signature_key(key, date_stamp, region_name, service_name)
    k_date = OpenSSL::HMAC.digest('sha256', 'AWS4' + key, date_stamp)
    k_region = OpenSSL::HMAC.digest('sha256', k_date, region_name)
    k_service = OpenSSL::HMAC.digest('sha256', k_region, service_name)
    k_signing = OpenSSL::HMAC.digest('sha256', k_service, 'aws4_request')

    k_signing
  end

  def self.cloudfront_signed_url(url, resource, exp, policy_path)
    configure = policy("#{url}/*", exp, policy_path)

    "#{url}/#{resource}" \
    "?Policy=#{safe_base64(configure + "\n")}" \
    "&Signature=#{signature(configure, File.dirname(File.dirname(__dir__)) + "/pk-#{ENV['KEY_PAIR_ID']}.pem")}" \
    "&Key-Pair-Id=#{ENV['KEY_PAIR_ID']}"
  end

  def self.policy(url, exp, path)
    File.open(path, 'w') do |file|
      file.puts('{' \
            '"Statement":[{' \
            "\"Resource\":\"#{url}\"," \
            '"Condition":{' \
            '"DateLessThan":{' \
            "\"AWS:EpochTime\":#{exp}" \
            '}}}]}')
    end
    File.read(path).delete("\t", "\n", "\r")
  end

  def self.safe_base64(data)
    Base64.strict_encode64(data).tr('+=/', '-_~')
  end

  def self.signature(data, key_path)
    digest = OpenSSL::Digest::SHA1.new
    key = OpenSSL::PKey::RSA.new(File.read(key_path))
    safe_base64(key.sign(digest, data + "\n"))
  end

end