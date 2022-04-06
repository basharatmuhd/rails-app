class Api::V1::UploadController < Api::ApiController

  def s3_access
    policy_date = Time.now.utc.strftime("%Y%m%d")
    x_amz_date  = Time.now.utc.strftime("%Y%m%dT%H%M%SZ")
    x_amz_credential = "#{ENV["AWS_ACCESS_KEY_ID"]}/#{policy_date}/#{ENV['AWS_REGION']}/s3/aws4_request"
    encoded_policy = s3_upload_policy(x_amz_credential, x_amz_date)

    render json: {
      bucket: ENV["AWS_BUCKET"],
      s3_region_endpoint: get_s3_region_endpoint(ENV['AWS_REGION']),
      x_amz_algorithm: 'AWS4-HMAC-SHA256',
      x_amz_credential: x_amz_credential,
      x_amz_date: x_amz_date,
      x_amz_signature: s3_upload_signature(policy_date, encoded_policy),
      policy: encoded_policy
      # session_token: @session_token
    }
  end

  protected

  def get_s3_region_endpoint(region_name)
    case region_name
    when "us-east-1"
      "s3.amazonaws.com"
    else
      "s3-#{region_name}.amazonaws.com"
    end
end

  def s3_upload_policy(x_amz_credential, x_amz_date)
    Base64.encode64(policy_data(x_amz_credential, x_amz_date).to_json).gsub("\n", "")
  end

  def policy_data(x_amz_credential, x_amz_date)
    {
      "expiration" => 1.hour.from_now.utc.xmlschema,
      "conditions" => [
        {"bucket" => ENV["AWS_BUCKET"]},
        ["starts-with", "$key", ""],
        {"acl" => "public-read"},
        {"x-amz-algorithm" => 'AWS4-HMAC-SHA256'},
        {"x-amz-credential" => x_amz_credential},
        {"x-amz-date" => x_amz_date},
        ["content-length-range", 0, 2000 * 1024 * 1024]
      ] + security_token
    }
  end

  def s3_upload_signature(policy_date, encoded_policy)
    OpenSSL::HMAC.hexdigest('sha256', signature_key(policy_date), encoded_policy)
  end

  def signature_key(policy_date)
    #AWS Signature Version 4
    k_date = OpenSSL::HMAC.digest('sha256', "AWS4" + ENV["AWS_SECRET_ACCESS_KEY"], policy_date)
    k_region = OpenSSL::HMAC.digest('sha256', k_date, ENV['AWS_REGION'])
    k_service = OpenSSL::HMAC.digest('sha256', k_region, "s3")
    k_signing = OpenSSL::HMAC.digest('sha256', k_service, "aws4_request")
    k_signing
  end

  def security_token
    if @session_token
      [ { "x-amz-security-token" => @session_token } ]
    else
      []
    end
  end
end
