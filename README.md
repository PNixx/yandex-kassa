# YandexKassa

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'yandex-kassa'
```

And then execute:

	$ bundle

Or install it yourself as:

	$ gem install yandex-kassa

## Usage

	# Initialize
	yandex_kassa = YandexKassa::Deposition.new('demo.yamoney.ru:9094', "my.cer", "private.key", "deposit.cer")
	
	request_params = {
			dstAccount: '410039303350',
			clientOrderId: 123,
			amount: amount,
			currency: 10643,
			agentId: 234,
			contract: 'payment_event'
	}
	
	# Test request
	response = yandex_kassa.test_deposition(request_params)
	
	# Make deposition
	response = yandex_kassa.make_deposition(request_params)


