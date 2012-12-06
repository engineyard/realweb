sleep 1
run lambda { |env| [200, { 'Content-Type' => 'text/html' }, ['Hello World']] }
