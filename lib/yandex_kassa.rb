require 'yandex_kassa/version'

# Yandex.Kassa deposition sdk
module YandexKassa
  class Deposition
    include OpenSSL

    attr_accessor :agent_id

    # Create a new instance
    #
    #=== Parameters
    # * +host+ - string Only Host and Port
    # * +cert+ - string
    # * +private_key+ - string
    # * +deposit_cert+ - string
    #
    #     yandex_kassa = YandexKassa.new('host:port', 'adp.cer', 'private.key', 'deposit.cer')
    #
    def initialize(host, cert, private_key, deposit_cert)
      @prefix = "https://#{host}/webservice/deposition/api/"
      @cert = X509::Certificate.new(File.read(cert))
      @private_key = PKey::RSA.new(File.read(private_key))
      @deposit_cert = X509::Certificate.new(File.read(deposit_cert))
    end

    # Test Deposition
    # @link https://tech.yandex.ru/money/doc/payment-solution/payout/payments-docpage/
    #     response = yandex_kassa.test_deposition({
    #        dstAccount: '123455',
    #        clientOrderId: 123,
    #        amount: 100.0,
    #        currency: 10643,
    #        agentId: 234,
    #        contract: 'test'
    #     })
    def test_deposition(params)
      request('testDeposition', params)
    end

    # Test Deposition
    # @link https://tech.yandex.ru/money/doc/payment-solution/payout/payments-docpage/
    #     response = yandex_kassa.make_deposition({
    #        dstAccount: '123455',
    #        clientOrderId: 123,
    #        amount: 100.0,
    #        currency: 10643,
    #        agentId: 234,
    #        contract: 'test'
    #     })
    def make_deposition(params)
      request('makeDeposition', params)
    end

    private

    # Request with params
    #
    #     response = yandex_kassa.request('testDeposition', {
    #        dstAccount: '123455',
    #        clientOrderId: 123,
    #        amount: 100.0,
    #        currency: 10643,
    #        agentId: 234,
    #        contract: 'test'
    #     })
    def request(method, params)

      # Add params
      default_params = {
          requestDT: Time.now.iso8601,
          agentId: agent_id,
      }
      params = params.reverse_merge(default_params)

      #Setup http request
      uri = URI.parse(@prefix + method)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.cert = @cert
      http.key = @private_key
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      # Request initialize
      request = Net::HTTP::Post.new(uri.path)
      request.body = sign_data(xml_header(method, params))
      request.content_type = 'application/pkcs7-mime'

      # Make request
      response = http.request(request)

      # Parsing
      parse_response(method, response.body)
    end

    # Sign +data+ with certificate
    #
    #=== Parameters
    # * +data+ - string
    #
    #     signed_data = yandex_kassa.sign_data('xml string')
    #
    def sign_data(data)
      OpenSSL::PKCS7::sign(@cert, @private_key, data, [], PKCS7::NOCERTS).to_pem
    end

    def xml_header(method, params)
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?><#{method}Request " + (params.map {|m| "#{m[0]}=\"#{m[1]}\""}.join(' ')) + '/>'
    end

    # Response parsing
    def parse_response(method, data)

      # Initialize store cert
      cert_store = OpenSSL::X509::Store.new
      cert_store.add_cert(@cert)

      # Parse response
      signature = OpenSSL::PKCS7.new(data)

      # Decrypt data
      signature.verify([@deposit_cert], cert_store, nil, OpenSSL::PKCS7::NOVERIFY)

      # Parse xml
      hash = Hash.from_xml(signature.data)
      hash["#{method}Response"]
    end
  end
end
