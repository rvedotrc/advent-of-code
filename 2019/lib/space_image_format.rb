class SpaceImageFormat

  def initialize(width:, height:, stream:)
    layers = []
    while stream != ''
      stream.length >= width * height or raise "data truncated"
      layer = height.times.map do
        row = stream[0...width]
        stream = stream[width..-1]
        row
      end
      layers << layer
    end
    @layers = layers
  end

  attr_reader :layers

  def flatten
    layers.reduce do |a, b|
      puts "a=#{a}"
      puts "b=#{b}"
      a.zip(b).map do |row_a, row_b|
        p [ row_a, row_b ]
        row_a.chars.zip(row_b.chars).map do |char_a, char_b|
          char_a == '2' ? char_b : char_a
        end.join('')
      end
    end
  end

end
