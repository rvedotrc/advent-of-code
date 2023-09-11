export type Position = string;
export type What = string;
export type Cost = number;

// export type GNode = {
//     readonly position: Position;
//     readonly what: What;
// };

export class Graph {
  private nodesByPosition: Map<Position, What> = new Map<Position, What>();
  private edgeCostsByStartAndEndPosition: Map<Position, Map<Position, Cost>> =
    new Map();
  private nodePositionsByWhat: Map<What, Set<Position>> = new Map();

  constructor() {}

  public addNode(position: Position, what: What): void {
    if (this.nodesByPosition.has(position)) throw "Already got a node here";

    this.nodesByPosition.set(position, what);

    const s = this.nodePositionsByWhat.get(what);
    if (s) {
      if (s.has(position)) throw "Already got this position";
      s.add(position);
    } else {
      this.nodePositionsByWhat.set(what, new Set(position));
    }
  }

  public removeNode(position: Position): void {
    const existingWhat = this.nodesByPosition.get(position);
    if (existingWhat === undefined) throw "Haven't got a node here";

    if (this.edgeCostsByStartAndEndPosition.has(position))
      throw "Still got edges here";

    this.nodesByPosition.delete(position);

    const byWhat = this.nodePositionsByWhat.get(existingWhat);
    if (!byWhat) throw "Wasn't in index";

    byWhat.delete(position);
    if (byWhat.size === 0) this.nodePositionsByWhat.delete(existingWhat);
  }

  public addEdge(from: Position, to: Position, cost: Cost): void {
    if (!this.nodesByPosition.has(from)) throw "No node here";
    if (!this.nodesByPosition.has(to)) throw "No node here";
    if (from === to) throw "Can't do from==to";

    {
      const existing = this.edgeCostsByStartAndEndPosition.get(from);
      if (existing) {
        if (existing.has(to)) throw "Already got an edge here";
        existing.set(to, cost);
      } else {
        this.edgeCostsByStartAndEndPosition.set(from, new Map().set(to, cost));
      }
    }

    [from, to] = [to, from];

    {
      const existing = this.edgeCostsByStartAndEndPosition.get(from);
      if (existing) {
        if (existing.has(to)) throw "Already got an edge here";
        existing.set(to, cost);
      } else {
        this.edgeCostsByStartAndEndPosition.set(from, new Map().set(to, cost));
      }
    }
  }

  public dump(): void {
    const e = [...this.edgeCostsByStartAndEndPosition.values()]
      .map((s) => s.size)
      .reduce((prev, curr) => prev + curr, 0);
    console.log(`${this.nodesByPosition.size} nodes, ${e} edges`);
  }
}
