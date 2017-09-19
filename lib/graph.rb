require_relative 'node'

# Class Graph represents actions for directed graph data structure
class Graph
  attr_accessor :nodes

  NO_ROUTE = 'NO SUCH ROUTE'.freeze
  # This restriction is made to avoid too many duplicate nodes in routes
  MAX_NODES_REPEAT = 4

  Route = Struct.new(:nodes, :finalized) do
    # If the routre is finalized that means this route
    # cannot be proceed as a start part of a new route
    def finalized?
      finalized
    end
  end

  def initialize(data_file, with_map = true)
    graph_data = File.read(data_file).split(',').map(&:strip).map(&:chars)
    # TODO: Perform this tasks as a delayed job
    populate_nodes(graph_data)
    calculate_map if with_map
  end

  # TODO: Save map to file and implement method to restore map from dump file
  # TODO: Implement method to calculate part map for given start node or start point on the fly
  def calculate_map
    puts "Mapping routes..."

    @map = nodes.map { |node| Route.new([node], false) }
    @map.each do |route|
      mapper(route)
    end

    puts "Done!\n----------"
  end

  # Map is valid if every of its' routes is a valid route
  def map_valid?
    map.each do |route|
      return false unless self.class.route?(route)
    end

    true
  end

  # Input nodes should be in format A-B-C, where A, B, C are stop points of route
  # It's allowed to give a point in lower case format like A-B-c
  def distance(points)
    raise ArgumentError unless points =~ /\A([A-Za-z]-)*[A-Za-z]\z/
    points = points&.split('-').map(&:upcase)

    nodes_to_check = []

    (0..(points.count - 2)).each do |i|
      node = find_node(points[i], points[i + 1])
      nodes_to_check << node if node
    end

    # Count of nodes to check should not ne less then potentail nodes from input points.
    # If so it means that there is no route for some part of input.
    return NO_ROUTE unless nodes_to_check.count == (points.count - 1)
    self.class.distance(nodes_to_check)
  end

  def routes_for(start_at, end_at, options = {})
    @map.clone.keep_if do |route|
      (route.nodes.first.start_point == start_at and \
        route.nodes.last.end_point == end_at) and \
        (
          if options[:stops]
            (options[:strong] ? route.nodes.count == options[:stops] : route.nodes.count <= options[:stops])
          else
            true
          end
        )
    end
  end

  def shortest_route_distance_for(start_at, end_at)
    routes = routes_for(start_at, end_at)
    routes.map { |r| r.nodes.map(&:weight).sum }.min
  end

  def routes_with_less_distance(start_at, end_at, distance)
    routes = routes_for(start_at, end_at)
    routes.keep_if { |r| r.nodes.map(&:weight).sum < distance }
  end

  private

  def find_node(start_point, end_point)
    nodes.each do |node|
      return node if node.start_point == start_point and node.end_point == end_point
    end
    nil
  end

  def populate_nodes(graph_data)
    puts 'Populating nodes from data file'
    @nodes = []
    graph_data.each do |node|
      nodes << Node.new(node)
    end
    puts "Done!\n----------"
  rescue(ArgumentError)
  end

  def mapper(route)
    return if route.finalized?

    find_nodes_by_start_point(route.nodes.last.end_point).each do |node|
      new_route = Route.new(route.nodes.clone << node)
      new_route.finalized = true if new_route.nodes.count(node) >= MAX_NODES_REPEAT
      add_route(new_route)
      mapper(new_route)
    end
  end

  # Be sure not to add duplicate routes
  def add_route(new_route)
    unless @map.map{ |r| r.nodes}.include? new_route.nodes
      @map << new_route
    end
  end

  def find_nodes_by_start_point(start_point)
    nodes.clone.keep_if { |node| node.start_point == start_point }
  end

  class << self
    # Two nodes connected if firts node leads to second node.
    # In case when second node leads to first node we should return false,
    # because we work with directed graph structure that performs train routes
    def connected?(node_a, node_b)
      raise ArgumentError unless (node_a.is_a?(Node) and node_b.is_a?(Node))
      (node_a.start_point != node_b.start_point) and \
        (node_a.end_point == node_b.start_point)
    end

    def distance(nodes)
      return NO_ROUTE unless route?(nodes)
      nodes.map(&:weight).sum
    end

    # Set of nodes is a route if all nodes are connected directly
    def route?(nodes)
      raise(ArgumentError) if (!nodes.is_a?(Array) or nodes.empty?)
      return true if nodes.count == 1

      if nodes.count > 2
        (0..(nodes.count - 2)).each do |index|
          raise(ArgumentError) unless (nodes[index].is_a?(Node) and nodes[index + 1].is_a?(Node))
          return false unless connected?(nodes[index], nodes[index + 1])
        end

        true
      else
        connected?(nodes[0], nodes[1])
      end
    end
  end
end
