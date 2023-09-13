import * as Immutable from "immutable";

import { Graph } from "./graph";

const findSpace = <P, N, E>(
  g: Graph<P, N, E>,
  space: N,
): { position: P; neighbours: Immutable.Map<P, E> } | undefined => {
  const spaces = g.nodes.getByValue(space);
  const iter = spaces.values().next();
  if (iter.done) return undefined;

  return {
    position: iter.value,
    neighbours: g.edges.getByPosition(iter.value),
  };
};

const pairs = <Position, Cost>(
  neighbours: [Position, Cost][],
  reduce: (a: Cost, b: Cost) => Cost,
): { fromPosition: Position; toPosition: Position; cost: Cost }[] => {
  const answer: { fromPosition: Position; toPosition: Position; cost: Cost }[] =
    [];

  for (let i = 0; i < neighbours.length - 1; ++i) {
    for (let j = i + 1; j < neighbours.length; ++j) {
      answer.push({
        fromPosition: neighbours[i][0],
        toPosition: neighbours[j][0],
        cost: reduce(neighbours[i][1], neighbours[j][1]),
      });
    }
  }

  return answer;
};

export const reduceSpaces = <P, N, E>(
  g: Graph<P, N, E>,
  space: N,
  combineEdgeValues: (a: E, b: E) => E,
  edgeValueIsBetter: (a: E, b: E) => boolean,
): Graph<P, N, E> => {
  while (true) {
    const toRemove = findSpace(g, space);
    if (!toRemove) break;

    const neighbours = [...toRemove.neighbours.entries()];

    const combos = pairs(neighbours, combineEdgeValues);

    for (const neighbour of neighbours) {
      g = g.removeEdge(toRemove.position, neighbour[0]);
    }

    g = g.removeNode(toRemove.position);

    for (const pair of combos) {
      g = g.addEdgeIfBetter(
        pair.fromPosition,
        pair.toPosition,
        pair.cost,
        edgeValueIsBetter,
      );
    }
  }

  return g;
};
