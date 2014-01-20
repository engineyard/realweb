app = Rack::Builder.new do
  map '/real_thing' do
    run lambda { |env| [200, { 'Content-Type' => 'text/html'}, ['Hello World']] }
  end

  run lambda { |env| [302, { 'Content-Type' => 'text/html', 'Location' => '/real_thing' }, ['Redirecting to /real_thing']] }
end

run app