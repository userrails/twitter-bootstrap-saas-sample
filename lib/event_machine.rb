# require "rubygems"
# require "amqp"

# EventMachine.run do
#   connection = AMQP.connect(:host => '127.0.0.1')
#   puts "Connected to AMQP broker. Running #{AMQP::VERSION} version of the gem..."

#   channel  = AMQP::Channel.new(connection)
#   queue    = channel.queue("amqpgem.examples.helloworld", :auto_delete => true)
#   exchange = channel.direct("")

#   queue.subscribe do |payload|
#     puts "Received a message: #{payload}. Disconnecting..."
#     connection.close { EventMachine.stop }
#   end

#   exchange.publish "Hello, world!", :routing_key => queue.name
# end

#!/usr/bin/env ruby
# encoding: utf-8

# require "rubygems"
# require "amqp"

# AMQP.start("amqp://127.0.0.1:5672") do |connection|
#   channel  = AMQP::Channel.new(connection)
#   exchange = channel.fanout("nba.scores")

#   channel.queue("joe", :auto_delete => true).bind(exchange).subscribe do |payload|
#     puts "#{payload} => shiv"
#   end

#   channel.queue("aaron", :auto_delete => true).bind(exchange).subscribe do |payload|
#     puts "#{payload} => siv"
#   end

#   channel.queue("bob", :auto_delete => true).bind(exchange).subscribe do |payload|
#     puts "#{payload} => rajj"
#   end

#   exchange.publish("BOS 101, NYK 89").publish("ORL 85, ALT 88")

#   # disconnect & exit after 2 seconds
#   EventMachine.add_timer(10) do
#     exchange.delete

#     connection.close { EventMachine.stop }
#   end
# end

#!/usr/bin/env ruby
# encoding: utf-8

require "rubygems"
require "amqp"

EventMachine.run do
  AMQP.connect do |connection|
    channel  = AMQP::Channel.new(connection)
    # topic exchange name can be any string
    exchange = channel.topic("weathr", :auto_delete => true)

    # Subscribers.
    channel.queue("", :exclusive => true) do |queue|
      queue.bind(exchange, :routing_key => "americas.north.#").subscribe do |headers, payload|
        puts "An update for North America: #{payload}, routing key is #{headers.routing_key}"
      end
    end
    channel.queue("americas.south").bind(exchange, :routing_key => "americas.south.#").subscribe do |headers, payload|
      puts "An update for South America: #{payload}, routing key is #{headers.routing_key}"
    end
    channel.queue("us.california").bind(exchange, :routing_key => "americas.north.us.ca.*").subscribe do |headers, payload|
      puts "An update for US/California: #{payload}, routing key is #{headers.routing_key}"
    end
    channel.queue("us.tx.austin").bind(exchange, :routing_key => "#.tx.austin").subscribe do |headers, payload|
      puts "An update for Austin, TX: #{payload}, routing key is #{headers.routing_key}"
    end
    channel.queue("it.rome").bind(exchange, :routing_key => "europe.italy.rome").subscribe do |headers, payload|
      puts "An update for Rome, Italy: #{payload}, routing key is #{headers.routing_key}"
    end
    channel.queue("asia.hk").bind(exchange, :routing_key => "asia.southeast.hk.#").subscribe do |headers, payload|
      puts "An update for Hong Kong: #{payload}, routing key is #{headers.routing_key}"
    end

    EventMachine.add_timer(1) do
      exchange.publish("San Diego update", :routing_key => "americas.north.us.ca.sandiego").
        publish("Berkeley update",         :routing_key => "americas.north.us.ca.berkeley").
        publish("San Francisco update",    :routing_key => "americas.north.us.ca.sanfrancisco").
        publish("New York update",         :routing_key => "americas.north.us.ny.newyork").
        publish("São Paolo update",        :routing_key => "americas.south.brazil.saopaolo").
        publish("Hong Kong update",        :routing_key => "asia.southeast.hk.hongkong").
        publish("Kyoto update",            :routing_key => "asia.southeast.japan.kyoto").
        publish("Shanghai update",         :routing_key => "asia.southeast.prc.shanghai").
        publish("Rome update",             :routing_key => "europe.italy.roma").
        publish("Paris update",            :routing_key => "europe.france.paris")
    end


    show_stopper = Proc.new {
      connection.close { EventMachine.stop }
    }

    EventMachine.add_timer(2, show_stopper)
  end
end
