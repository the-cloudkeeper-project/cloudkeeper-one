require 'securerandom'

module Cloudkeeper
  module One
    module ApplianceActions
      module Utils
        module ImageDownload
          def download_image(uri, username, password)
            return generate_url uri, username, password if Cloudkeeper::One::Settings[:'opennebula-allow-remote-source']

            filename = generate_filename
            retrieve_image URI.parse(uri), username, password, filename

            filename
          rescue URI::InvalidURIError => ex
            raise Cloudkeeper::One::Errors::NetworkConnectionError, ex
          end

          private

          def retrieve_image(uri, username, password, filename)
            logger.debug "Downloading image from #{uri.inspect} (username: #{username}, password: #{password})"
            use_ssl = uri.scheme == 'https'
            Net::HTTP.start(uri.host, uri.port, use_ssl: use_ssl) do |http|
              request = Net::HTTP::Get.new(uri)
              request.basic_auth username, password

              http.request(request) do |response|
                response.value
                open(filename, 'w') { |file| response.read_body { |chunk| file.write(chunk) } }
              end
            end
            logger.debug "Image stored into #{filename}"
          rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, Errno::ECONNREFUSED, Net::HTTPBadResponse,
                 Net::HTTPHeaderSyntaxError, EOFError, Net::HTTPServerException, Net::HTTPRetriableError => ex
            raise Cloudkeeper::One::Errors::NetworkConnectionError, ex
          end

          def generate_filename
            File.join(Cloudkeeper::One::Settings[:'appliances-tmp-dir'], SecureRandom.uuid)
          end

          def generate_url(uri, username, password)
            url = URI.parse(uri)
            url.user = username
            url.password = password

            logger.debug "Generating remote source URL: #{url.to_s.inspect}"
            url.to_s
          end
        end
      end
    end
  end
end
