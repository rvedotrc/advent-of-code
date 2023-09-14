import { WALL } from "./cells";
import { Graph as Graph } from "./graph";

export type Maze = Graph<number, string, number>;

export const graphBuilder = (text: string): Graph<number, string, number> => {
  let g: ReturnType<typeof graphBuilder> = Graph.empty();

  const rows = text.trimEnd().split("\n");
  if (rows.length === 0) throw "No rows";
  if (rows[0].length === 0) throw "No columns";

  const xyToPos = (x: number, y: number) => y * rows[0].length + x;

  for (const row of rows) {
    if (row.length !== rows[0].length) throw "Unequal rows";
  }

  rows.forEach((row, y) => {
    row.split("").forEach((cell, x) => {
      if (cell === WALL) return;
      const pos = xyToPos(x, y);
      g = g.addNode(pos, cell);

      if (x > 0 && row[x - 1] !== WALL)
        g = g.addEdge(pos, xyToPos(x - 1, y), 1);
      if (y > 0 && rows[y - 1][x] !== WALL)
        g = g.addEdge(pos, xyToPos(x, y - 1), 1);
    });
  });

  return g;
};
