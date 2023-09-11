import * as Immutable from "immutable";

import { SPACE } from "./cells";
import { Cost, Graph, Position } from "./graph";

const findSpace = (
  g: Graph,
):
  | { position: Position; neighbours: Immutable.Map<Position, Cost> }
  | undefined => {
  const spaces = g.nodes.getByWhat(SPACE);
  const iter = spaces.values().next();
  if (iter.done) return undefined;

  return {
    position: iter.value,
    neighbours: g.edges.getByPosition(iter.value),
  };
};

const pairs = (
  neighbours: [string, number][],
): { fromPosition: Position; toPosition: Position; cost: Cost }[] => {
  const answer: { fromPosition: Position; toPosition: Position; cost: Cost }[] =
    [];

  for (let i = 0; i < neighbours.length - 1; ++i) {
    for (let j = i + 1; j < neighbours.length; ++j) {
      answer.push({
        fromPosition: neighbours[i][0],
        toPosition: neighbours[j][0],
        cost: neighbours[i][1] + neighbours[j][1],
      });
    }
  }

  return answer;
};

export const reduceSpaces = (g: Graph): Graph => {
  while (true) {
    const toRemove = findSpace(g);
    if (!toRemove) break;

    const neighbours = [...toRemove.neighbours.entries()];

    const combos = pairs(neighbours);

    for (const neighbour of neighbours) {
      g = g.removeEdge(toRemove.position, neighbour[0]);
    }

    g = g.removeNode(toRemove.position);

    for (const pair of combos) {
      g = g.addEdgeIfBetter(pair.fromPosition, pair.toPosition, pair.cost);
    }
  }

  return g;
};
