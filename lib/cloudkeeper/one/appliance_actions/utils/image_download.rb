require 'securerandom'

module Cloudkeeper
  module One
    module ApplianceActions
      module Utils
        module ImageDownload
          def download_image(uri, username, password)
            logger.debug "Downloading image from #{uri.inspect} (username: #{username}, password: #{password})"
            filename = generate_filename
            retrieve_image URI.parse(uri), username, password, filename

            logger.debug "Image stored into #{filename}"
            filename
          rescue URI::InvalidURIError => ex
            raise Cloudkeeper::One::Errors::NetworkConnectionError, ex
          end

          private

          def retrieve_image(uri, username, password, filename)
            Net::HTTP.start(uri.host, uri.port) do |http|
              request = Net::HTTP::Get.new(uri)
              request.basic_auth username, password

              http.request(request) do |response|
                response.value
                open(filename, 'w') { |file| response.read_body { |chunk| file.write(chunk) } }
              end
            end
          rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, Errno::ECONNREFUSED, Net::HTTPBadResponse,
                 Net::HTTPHeaderSyntaxError, EOFError, Net::HTTPServerException => ex
            raise Cloudkeeper::One::Errors::NetworkConnectionError, ex
          end

          def generate_filename
            File.join(Cloudkeeper::One::Settings[:'appliances-tmp-dir'], SecureRandom.uuid)
          end
        end
      end
    end
  end
end
