require 'spec_helper'

describe Node do
  before do
    @node_a = described_class.new(['A', 'B', 10])
    @node_b = described_class.new(['C', 'E', 4])
    @node_c = described_class.new(['B', 'E', 7])
    @node_d = described_class.new(['E', 'C', 3])
    @node_e = described_class.new(['D', 'A', 3])
  end

  describe '#initialize' do
    it { expect { described_class.new([1, 'A', '15']) }.to raise_exception(ArgumentError) }
    it { expect { described_class.new(['A', 2, '15']) }.to raise_exception(ArgumentError) }
    it { expect { described_class.new(['C', 'A', '15']) }.to_not raise_exception }
    it { expect { described_class.new(['C', 'A', 15]) }.to_not raise_exception }
  end
end
