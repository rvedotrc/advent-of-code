class MazeSolver
  def initialize(graph)
    @graph = graph
  end

  attr_reader :graph

  Item = Data.define(:graph, :cost, :path)

  def best_distance
    graph.reduce!
    graph.puts_dot

    queue = [
      Item.new(graph:, cost: 0, path: [])
    ]

    best_to = {}

    best = nil

    n0 = 0
    n1 = 0

    while item = queue.shift
      n0 += 1
      if n0 & 0xFFF == 0
        print "#{n0} #{n1}\r"
      end

      unless item.path.empty?
        state = item.path.map(&:first).sort.join + item.path.last.first
        # puts state

        if best_to[state] && best_to[state].cost < item.cost

          # if best_to[state].graph.hash != item.graph.hash
          #   p state
          #   p best_to[state]
          #   p best_to[state].graph.hash
          #   p item
          #   p item.graph.hash
          #   puts
          # end

          # puts "x #{state}"
          next
        end
      end

      best_to[state] = item

      neighbouring_keys = item.graph.each_neighbouring_key.to_a
      # puts item.path.inspect
      if best && item.cost >= best.cost
        # print "-"
        next
      end

      if neighbouring_keys.empty?
        n1 += 1
        if best.nil? || item.cost < best.cost
          puts "Solution! #{item.cost} #{item.path}"
          best = item
        end
      else
        neighbouring_keys.sort_by { |n| [n.edge.distance, n.node.what] }.each do |neighbour|
          new_item = Item.new(
            graph: item.graph.move_to(neighbour),
            cost: item.cost + neighbour.edge.distance,
            path: [*item.path, [neighbour.node.what, neighbour.edge.distance, neighbouring_keys.count]],
          )

          queue.push(new_item)
        end
      end
    end

    p [n0, n1]
    best.cost
  end
end
