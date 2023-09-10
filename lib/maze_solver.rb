class MazeSolver
  def initialize(graph)
    @graph = graph
    @all_keys = graph.nodes.select(&:key?).what.sort
  end

  attr_reader :graph

  def best_distance
    graph.reduce!
    current = graph.find_node_from_what('@')
    current.what = '.'
    shortest_paths_from(current, [], 0)
  end

  def best_distance_from(node, keys_held, best_distance_so_far)
    return best_distance_so_far if keys_held == @all_keys

    # What new keys can we reach from here, and
    #
  end
end
