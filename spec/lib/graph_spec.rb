require 'spec_helper'

describe Graph do
  let(:subject) { described_class.new('data.txt', false) }

  let(:node_a) { Node.new(['A', 'B', 10]) }
  let(:node_b) { Node.new(['C', 'E', 4]) }
  let(:node_c) { Node.new(['B', 'E', 7]) }
  let(:node_d) { Node.new(['E', 'C', 3]) }
  let(:node_e) { Node.new(['D', 'A', 3]) }

  describe '#initialize' do
    let(:nodes) { [ Node.new(['A', 'B', 5]), Node.new(['B', 'C', 4]), Node.new(['C', 'D', 8]), \
    Node.new(['D', 'C', 8]), Node.new(['D', 'E', 6]), Node.new(['A', 'D', 5]), \
    Node.new(['C', 'E', 2]), Node.new(['E', 'B', 3]), Node.new(['A', 'E', 7])] }

    it { expect(subject.nodes[0].start_point).to eq nodes[0].start_point}
    it { expect(subject.nodes[4].end_point).to eq nodes[4].end_point }
    it { expect(subject.nodes.last.weight).to eq nodes.last.weight }
  end

  describe '.distance' do
    it { expect(subject.distance('A-B-C')).to eq 9 }
    it { expect(subject.distance('A-D')).to eq 5 }
    it { expect(subject.distance('A-D-C')).to eq 13 }
    it { expect(subject.distance('A-E-B-C-D')).to eq 22 }
    it { expect(subject.distance('A-E-B-C-d')).to eq 22 }
    it { expect(subject.distance('A-E-D')).to eq 'NO SUCH ROUTE' }
    it { expect { subject.distance('A-E-5') }.to raise_exception(ArgumentError) }
  end

  context 'routes and distances' do
    before { @subject ||= described_class.new('data.txt') }

    it 'return valid results' do
      expect(@subject.routes_for('C', 'C', stops: 3).count).to eq 2
      expect(@subject.routes_for('A', 'C', stops: 4, strong: true).count).to eq 3

      expect(@subject.shortest_route_distance_for('A', 'C')).to eq 9
      expect(@subject.shortest_route_distance_for('B', 'B')).to eq 9

      expect(@subject.routes_with_less_distance('C', 'C', 30).count).to eq 7
    end
  end

  describe '#connected?' do
    it { expect(described_class.connected?(node_a, node_c)).to be_truthy }
    it { expect(described_class.connected?(node_c, node_a)).to be_falsey }
    it { expect(described_class.connected?(node_a, node_b)).to be_falsey }
    it { expect(described_class.connected?(node_b, node_a)).to be_falsey }
    it { expect { described_class.connected?('adfgads', node_a) }.to raise_exception(ArgumentError) }
  end

  describe '#route?' do
    it { expect(described_class.route?([node_a, node_c])).to be_truthy }
    it { expect(described_class.route?([node_a, node_c, node_d])).to be_truthy }
    it { expect(described_class.route?([node_a, node_c, node_b])).to be_falsey }
    it { expect(described_class.route?([node_a, node_d, node_b])).to be_falsey }
    it { expect(described_class.route?([node_a])).to be_truthy }
    it { expect { described_class.route?(node_a) }.to raise_exception(ArgumentError) }
    it { expect { described_class.route?([node_a, 'AV5']) }.to raise_exception(ArgumentError) }
  end

  describe '#distance' do
    it { expect(described_class.distance([node_a, node_c])).to eq 17 }
    it { expect(described_class.distance([node_a, node_c, node_d])).to eq 20 }
    it { expect(described_class.distance([node_a, node_b])).to eq  'NO SUCH ROUTE'}
    it { expect(described_class.distance([node_a, node_c, node_d, node_b])).to eq 24 }
    it { expect(described_class.distance([node_a, node_c, node_d, node_b, node_e])).to eq 'NO SUCH ROUTE' }
  end
end
