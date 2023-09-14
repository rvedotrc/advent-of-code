require 'space_image_format'

RSpec.describe SpaceImageFormat do

  it 'parses the example' do
    image = SpaceImageFormat.new(stream: '123456789012', width: 3, height: 2)
    expect(image.layers).to eq([
      ['123', '456'],
      ['789', '012'],
    ])
  end

end
