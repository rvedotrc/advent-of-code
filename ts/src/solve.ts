import * as Immutable from "immutable";

import { CURRENT, isKey, SPACE } from "./cells";
import { Cost, Graph, Position } from "./graph";
import { reduceSpaces } from "./reduceSpaces";

type Item = {
  graph: Graph;
  cost: Cost;
  keysHeld: Immutable.Set<string>;
  keyOrder: string;
};

const currentPositions = (g: Graph): Immutable.Set<Position> =>
  Immutable.Set(g.nodes.byWhat.get(CURRENT) || Immutable.Set());

const unlockDoors = (g: Graph, door: string): Graph => {
  for (const doorPosition of g.nodes.byWhat.get(door) || Immutable.Set()) {
    g = g.changeNode(doorPosition, SPACE);
  }

  return g;
};

const move = (g: Graph, from: Position, to: Position): Graph =>
  g.changeNode(from, SPACE).changeNode(to, CURRENT);

const solveForQueue = (queue: Item[], numberOfKeys: number): number => {
  // const bestByPosition: Map<Position, number> = new Map();
  // for (const pos of g.nodes.byPosition.keys()) {
  //     bestByPosition.set(pos, Infinity);
  // }
  //
  // for (const pos of (g.nodes.byWhat.get(CURRENT) || Immutable.Set())) {
  //     bestByPosition.set(pos, 0);
  // }

  const bestByState: Map<
    {
      keysHeld: Immutable.Set<string>;
      currentPositions: Immutable.Set<Position>;
    },
    number
  > = new Map();

  let bestScore = Infinity;

  while (true) {
    const item = queue.shift();
    if (!item) break;

    // console.log({
    //   graph: item.graph.toString(),
    //   cost: item.cost,
    //   keyOrder: item.keyOrder,
    // });

    if (item.keysHeld.size === numberOfKeys) {
      if (item.cost < bestScore) {
        console.log({ solution: { keyOrder: item.keyOrder, cost: item.cost } });
        bestScore = item.cost;
      }

      continue;
    }

    if (item.cost >= bestScore) continue;

    const currents = currentPositions(item.graph);

    const state = {
      keysHeld: item.keysHeld,
      currentPositions: currents,
    };

    const previousBest = bestByState.get(state);
    // console.log({ state, previousBest, cost: item.cost });
    if (previousBest && previousBest <= item.cost) {
      // process.stderr.write(".");
      console.log("skip");
      continue;
    }

    bestByState.set(state, item.cost);

    const neighbouringKeys = [...currents]
      .flatMap((from) => {
        const r = item.graph.edges.getByPosition(from);
        return [...r.entries()].map(([to, cost]) => ({
          from,
          to,
          cost,
          key: item.graph.nodes.byPosition.get(to) || "",
        }));
      })
      .filter((ftck) => isKey(ftck.key));

    neighbouringKeys.sort(
      (a, b) => b.cost - a.cost || b.from - a.from || b.to - a.to,
    );

    const newItems = neighbouringKeys.map((k) => ({
      graph: reduceSpaces(
        move(unlockDoors(item.graph, k.key.toUpperCase()), k.from, k.to),
      ),
      cost: item.cost + k.cost,
      keysHeld: item.keysHeld.add(k.key),
      keyOrder: item.keyOrder + k.key,
    }));

    // const first = newItems.shift();
    // if (first) queue.unshift(first);
    // queue.push(...newItems);

    queue.unshift(...newItems);
  }

  return bestScore;
};

export const solve = (g: Graph): number => {
  const numberOfKeys = [...g.nodes.byWhat.keys()].filter(isKey).length;

  const queue: Item[] = [
    {
      graph: g,
      cost: 0,
      keysHeld: Immutable.Set(),
      keyOrder: "",
    },
  ];

  return solveForQueue(queue, numberOfKeys);
};
