import { Graph, Position } from "./graph";

const WALL = "#";

export const graphBuilder = (text: string): Graph => {
  const g = new Graph();

  const xyToPos = (x: number, y: number): Position => `(${x},${y})`;

  const rows = text.trimEnd().split("\n");
  if (rows.length === 0) throw "No rows";
  if (rows[0].length === 0) throw "No columns";

  for (const row of rows) {
    if (row.length !== rows[0].length) throw "Unequal rows";
  }

  rows.forEach((row, y) => {
    row.split("").forEach((cell, x) => {
      if (cell === WALL) return;
      const pos = xyToPos(x, y);
      g.addNode(pos, cell);

      if (x > 0 && row[x - 1] !== WALL) g.addEdge(pos, xyToPos(x - 1, y), 1);
      if (y > 0 && rows[y - 1][x] !== WALL)
        g.addEdge(pos, xyToPos(x, y - 1), 1);
    });
  });

  return g;
};
