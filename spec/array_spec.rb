require_relative '../scripts/SaveTabs'

RSpec.describe 'example' do
  let(:save_tabs) { Nautilus::SaveTabs.new }
  it 'unwrap' do
    property_of do
      len = integer(1..128)
      remain = integer(1..128)
      [len, remain, array(len) { string }]
    end.check(900) do |(len, remain, arr)|
      expect(save_tabs
          .unwrap_around(arr.take_wrapped_around(len + remain),
                         arr.take_wrapped_around(-(len + remain))))
        .to eql arr
    end
  end
end
