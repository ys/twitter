require 'helper'

describe Twitter::Error::ClientError do

  before do
    @client = Twitter::Client.new
  end

  Twitter::Error::ClientError.errors.each do |status, exception|
    [nil, "error", "errors"].each do |body|
      context "when HTTP status is #{status} and body is #{body.inspect}" do
        before do
          body_message = '{"' + body + '":"Client Error"}' unless body.nil?
          stub_get("/1.1/statuses/user_timeline.json").with(:query => {:screen_name => "sferik"}).to_return(:status => status, :body => body_message)
        end
        it "raises #{exception.name}" do
          expect{@client.user_timeline("sferik")}.to raise_error exception
        end
      end
    end
    context "when HTTP status is #{status} and body is errors" do
      context "when errors is an array of hashes" do
        [nil, 187].each do |error_code|
          context "when error coder is #{error_code.inspect}" do
            before do
              if error_code.nil?
                body_message = '{"errors":[{"message":"Client Error"}]}'
              else
                body_message = '{"errors":[{"message":"Client Error","code": ' + error_code.to_s + ' }]}'
              end
              stub_get("/1.1/statuses/user_timeline.json").with(:query => {:screen_name => "sferik"}).to_return(:status => status, :body => body_message)
            end
            it "raises #{exception.name}" do
              expect{@client.user_timeline("sferik")}.to raise_error { |error|
                expect(error.code).to eq error_code
              }
            end
          end
        end
      end
    end
  end

end
