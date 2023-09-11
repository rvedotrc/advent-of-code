export type Position = string;
export type What = string;
export type Cost = number;

// export type GNode = {
//     readonly position: Position;
//     readonly what: What;
// };

const SPACE = ".";

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

  public reduceTwoEdgeSpaceNodes(): void {
    while (true) {
      const spacePositions = this.nodePositionsByWhat.get(SPACE);
      if (!spacePositions) break;

      const twoEdgeSpacePositions = [...spacePositions].filter(
        (pos) => this.edgeCostsByStartAndEndPosition.get(pos)?.size === 2,
      );
      if (twoEdgeSpacePositions.length === 0) break;

      for (const positionToRemove of twoEdgeSpacePositions) {
        const e = this.edgeCostsByStartAndEndPosition.get(positionToRemove);
        if (e === undefined) continue;

        const neighbourPositions = [...e.entries()];
        if (neighbourPositions.length !== 2) continue;

        const [[leftPosition, leftCost], [rightPosition, rightCost]] =
          neighbourPositions;
        const newCost = leftCost + rightCost;

        this.edgeCostsByStartAndEndPosition.delete(positionToRemove);
        this.edgeCostsByStartAndEndPosition
          .get(leftPosition)
          ?.delete(positionToRemove);
        this.edgeCostsByStartAndEndPosition
          .get(rightPosition)
          ?.delete(positionToRemove);

        this.nodesByPosition.delete(positionToRemove);
        this.nodePositionsByWhat.get(SPACE)?.delete(positionToRemove);

        const existingLeft =
          this.edgeCostsByStartAndEndPosition.get(leftPosition);
        const existingRight =
          this.edgeCostsByStartAndEndPosition.get(rightPosition);
        if (!existingLeft) throw "?";
        if (!existingRight) throw "?";

        const existingCost = existingLeft.get(rightPosition);
        if (existingCost === undefined || newCost < existingCost) {
          existingLeft.set(rightPosition, newCost);
          existingRight.set(leftPosition, newCost);
        }
      }
    }
  }

  public reduceDeadEnds(): void {
    while (true) {
      const spacePositions = this.nodePositionsByWhat.get(SPACE);
      if (!spacePositions) break;

      const oneEdgeSpacePositions = [...spacePositions].filter(
        (pos) => this.edgeCostsByStartAndEndPosition.get(pos)?.size === 1,
      );
      if (oneEdgeSpacePositions.length === 0) break;

      for (let positionToRemove of oneEdgeSpacePositions) {
        while (true) {
          const m = this.edgeCostsByStartAndEndPosition.get(positionToRemove);
          if (!m) throw "?146";

          const neighbours = [...m.keys()];
          if (neighbours.length !== 1) break;

          const neighbourPosition = neighbours[0];
          const neighbourWhat = this.nodesByPosition.get(neighbourPosition);
          if (!neighbourWhat) throw "?153";

          this.edgeCostsByStartAndEndPosition.delete(positionToRemove);
          const n = this.edgeCostsByStartAndEndPosition.get(neighbourPosition);
          if (!n) throw "?157";

          n.delete(positionToRemove);
          if (n.size === 0) {
            this.edgeCostsByStartAndEndPosition.delete(neighbourPosition);
          }

          this.nodesByPosition.delete(positionToRemove);
          this.nodePositionsByWhat.get(SPACE)?.delete(positionToRemove);

          if (neighbourWhat !== SPACE) break;

          positionToRemove = neighbourPosition;
        }
      }
    }

    if (this.nodePositionsByWhat.get(SPACE)?.size === 0)
      this.nodePositionsByWhat.delete(SPACE);
  }
}
