# Node class represents stucture and actions for Nodes of Graph
class Node
  attr_accessor :start_point, :end_point, :weight

  def initialize(args)
    raise(ArgumentError) unless valid?(args)
    @start_point = args[0]
    @end_point   = args[1]
    @weight      = args[2].to_i
  end

  def valid?(args)
    args[0].is_a?(String) and args[1].is_a?(String) and args[2].to_i.positive?
  end
end
