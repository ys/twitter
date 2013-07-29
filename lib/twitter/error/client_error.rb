require 'twitter/error'

module Twitter
  class Error
    # Raised when Twitter returns a 4xx HTTP status code or there's an error in Faraday
    class ClientError < Twitter::Error

      attr_reader :code

      # Create a new error from an HTTP environment
      #
      # @param response [Hash]
      # @return [Twitter::Error]
      def self.from_response(response={})
        error, code = parse_error(response[:body])
        new(error, response[:response_headers], code)
      end

      # Initializes a new ClientError object
      #
      # @param exception [Exception, String]
      # @param response_headers [Hash]
      # @param code [Integer]
      # @return [Twitter::ClientError]
      def initialize(exception=$!, response_headers={}, code=nil)
        @code = code
        super(exception, response_headers)
      end

    private

      def self.parse_error(body)
        if body.nil?
          ['', nil]
        elsif body[:error]
          [body[:error], nil]
        elsif body[:errors]
          first = Array(body[:errors]).first
          if first.is_a?(Hash)
            [first[:message].chomp, first[:code]]
          else
            [first.chomp, nil]
          end
        end
      end

    end
  end
end
