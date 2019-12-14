class Orbits

  ROOT_NODE = 'COM'

  def initialize(inputs)
    parents = {}

    inputs.each_line do |text|
      text.match(/^\s*(\w+)\)(\w+)\s*$/) or raise
      parent = $1
      child = $2

      raise "already seen what #{child} orbits" if parents[child]
      parents[child] = parent
    end

    require 'set'
    found = Set.new
    queue = [ROOT_NODE]
    @depths_of = { ROOT_NODE => 0 }

    while parent = queue.shift
      found.add(parent)
      children = parents.entries.map {|k,v| k if v == parent}.compact
      children.each do |child|
        @depths_of[child] = 1 + @depths_of[parent]
      end
      queue.push(*children)
    end

    found.delete(ROOT_NODE)
    unless found.sort == parents.keys.sort
      raise "did not find everything: parents=#{parents.keys.sort} found=#{found.sort}"
    end

    @parents = parents
  end

  def count
    @parents.keys.map {|n| depth_of(n)}.reduce(&:+)
  end

  def depth_of(name, to: ROOT_NODE)
    @depths_of[name]
  end

  def distance(a, b)
    a = @parents[a]
    b = @parents[b]
    ancestor = find_ancestor(a, b)
    return @depths_of[a] + @depths_of[b] - 2 * @depths_of[ancestor]
  end

  def path_to(node, from:)
    path = [node]
    while path.last != from
      path << @parents[ path.last ]
    end
    path.reverse
  end

  def find_ancestor(a, b)
    path_a = [a]
    while true
      return b if path_a.last == b
      break if path_a.last == ROOT_NODE
      path_a.push( @parents[path_a.last] )
    end

    while true
      return b if path_a.include?(b)
      b = @parents[b]
    end

    raise
  end

end
