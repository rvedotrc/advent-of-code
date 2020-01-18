require 'machine'
require 'weakref'

class Network

  def initialize(program, number_of_hosts)
    @program = program
    @number_of_hosts = number_of_hosts

    @hosts = (0..49).map do |address|
      Network::Host.new(program, address, self)
    end

    @nat = NAT.new
  end

  attr_reader :hosts, :nat

  def run
    threads = hosts.map do |host|
      Thread.new { host.run }
    end

    nat_run

    threads.map(&:kill)
  end

  def send_packet(from:, to:, packet:)
    @last_tx_time = Time.now
    puts "#{from}->#{to} #{packet.inspect}"

    if @hosts[to]
      @hosts[to].packet_queue.push(packet)
    elsif to == 255
      nat.receive(packet)
    else
      raise
    end
  end

  def nat_run
    while true
      sleep 0.1

      if @last_tx_time.nil? or @last_tx_time > Time.now - 1
        # puts "recent tx"
        next
      end

      unless @hosts.all? { |host| host.packet_queue.empty? }
        # puts "packets in queues"
        next
      end

      packet = nat.last_packet
      puts "Network is idle, last NAT packet is #{packet.inspect}"
      packet or raise

      if @last_nat_nudge and packet[1] == @last_nat_nudge[1]
        puts "Same as Y last time!"
        return
      end

      send_packet(from: 255, to: 0, packet: packet)
      @last_nat_nudge = packet.dup
    end
  end

  class NAT
    def initialize
      @mutex = Mutex.new
      @last_packet = nil
    end

    def receive(packet)
      puts "NAT received #{packet.inspect}"
      @mutex.synchronize do
        @last_packet = packet.dup
      end
    end

    attr_reader :last_packet
  end

  class PacketQueue
    def initialize
      @queue = []
      @mutex = Mutex.new
    end

    def push(packet)
      @mutex.synchronize do
        @queue.push(packet.dup)
      end
    end

    def empty?
      @mutex.synchronize do
        @queue.empty?
      end
    end

    def shift
      @mutex.synchronize do
        @queue.shift # can be nil
      end
    end
  end

  class Host

    def initialize(program, address, network)
      @address = address
      @input_buffer = [address]
      @packet_queue = Network::PacketQueue.new
      @network = WeakRef.new(network)
      @output_buffer = []

      @machine = Machine.new(
        program.dup,
        on_input: method(:on_input),
        on_output: method(:on_output),
      )
    end

    attr_reader :address, :input_buffer, :packet_queue, :network, :output_buffer, :machine

    def run
      machine.run
    end

    def on_input
      unless input_buffer.empty?
        # puts "#{address} read #{input_buffer.first}"
        return input_buffer.shift
      end

      packet = packet_queue.shift
      unless packet
        # puts "#{address} read -1 packet queue empty"
        sleep 0.1
        return -1
      end

      # puts "#{address} next packet is #{packet.inspect}"
      input_buffer.concat(packet)
      # puts "#{address} read #{input_buffer.first}"
      input_buffer.shift
    end

    def on_output(n)
      # puts "#{address} write #{n}"
      output_buffer << n

      while output_buffer.length >= 3
        target_address, x, y = output_buffer.shift(3)
        network.send_packet(from: address, to: target_address, packet: [x, y])
      end
    end

  end

end
