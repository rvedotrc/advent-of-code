import * as Base from "./base";

class Position {
  public readonly x: number;
  public readonly y: number;
  public readonly key: string;

  constructor(x: number, y: number) {
    this.x = x;
    this.y = y;
    this.key = `${x}:${y}`;
  }
}

type PositionWithDistance = { position: Position; distance: number };

class Nodes {
  // Unvisited with no distance
  // Unvisited with a distance
  // Visited (with a distance)
  private readonly distances = new Map<string, number>();
  private readonly unvisitedByDistance: PositionWithDistance[] = [];
  private readonly visited = new Set<string>();

  public setDistance(position: Position, distance: number) {
    // console.log(`setDistance ${JSON.stringify(position)} to ${distance}`);
    if (distance === undefined || distance === null || isNaN(distance))
      throw `Unexpected undef/null ${distance}`;

    if (this.visited.has(position.key)) throw "Can't set for visited";

    const oldDistance = this.distances.get(position.key);
    // console.log(`setDistance oldDistance=${oldDistance}`);
    if (oldDistance !== undefined && distance >= oldDistance) return;

    if (oldDistance !== undefined) {
      const oldPos = this.find({
        position,
        distance: oldDistance,
      });
      this.unvisitedByDistance.splice(oldPos, 1);
    }

    this.distances.set(position.key, distance);

    const newPos = this.find({ position, distance });
    if (isNaN(distance)) throw `Unexpected NaN ${distance}`;
    this.unvisitedByDistance.splice(newPos, 0, { position, distance });
  }

  public getDistance(position: Position): number {
    if (!this.visited.has(position.key))
      throw "Can't getDistance for unvisited";

    const distance = this.distances.get(position.key);
    if (distance === undefined) throw "Can't getDistance for distance-less";

    return distance;
  }

  public markAsVisited(position: Position): void {
    // console.log(`markAsVisited ${JSON.stringify(position)}`);
    if (this.visited.has(position.key)) throw "Already visited";

    const distance = this.distances.get(position.key);
    if (distance === undefined) throw "Can't mark distance-less as visited";

    this.visited.add(position.key);

    const index = this.find({ position, distance });
    if (index >= this.unvisitedByDistance.length) {
      throw `markAsVisited removal got index off end`;
    }

    const r = Nodes.compare(
      { position, distance },
      this.unvisitedByDistance[index]
    );
    if (r !== 0) {
      throw `markAsVisited removal got r=${r}`;
    }

    this.unvisitedByDistance.splice(index, 1);
    // console.log(JSON.stringify(this.unvisitedByDistance));
  }

  public nearestUnvisited(): PositionWithDistance {
    const item = this.unvisitedByDistance[0];
    if (!item) throw "No nearest item";

    // console.log(`nearestUnvisited is ${JSON.stringify(item)}`);
    return item;
  }

  public isVisited(position: Position): boolean {
    return this.visited.has(position.key);
  }

  private find(target: PositionWithDistance): number {
    if (
      target.distance === undefined ||
      target.distance === null ||
      isNaN(target.distance)
    )
      throw `Unexpected undef/null ${target.distance}`;

    let min: number = 0;
    let max: number = this.unvisitedByDistance.length;

    while (min < max) {
      const mid = Math.floor((min + max) / 2);

      const result = Nodes.compare(this.unvisitedByDistance[mid], target);

      if (result > 0) {
        max = mid;
      } else if (result < 0) {
        min = mid + 1;
      } else {
        min = max = mid;
      }
    }

    return min;
  }

  private static compare(
    aaa: PositionWithDistance,
    bbb: PositionWithDistance
  ): number {
    // console.log([aaa, bbb]);
    let r = bbb.distance - aaa.distance;
    if (r === 0) r = bbb.position.x - aaa.position.x;
    if (r === 0) r = bbb.position.y - aaa.position.y;
    return -r;
  }
}

export class Part1 extends Base.BasePart implements Base.Part {
  calculate(lines: string[]): string {
    const grid = this.parseInput(lines);
    const maxX = grid[0].length - 1;
    const maxY = grid.length - 1;
    // console.log({ maxX, maxY });

    const nodes = new Nodes();

    let current = new Position(0, 0);
    let currentDistance = 0;
    nodes.setDistance(current, currentDistance);
    // nodes.markAsVisited(current);

    while (true) {
      for (const neighbour of this.unvisitedNeighboursOf(
        current,
        nodes,
        maxX,
        maxY
      )) {
        // console.log({
        //   current,
        //   currentDistance,
        //   g: grid[neighbour.y][neighbour.x],
        //   neighbour,
        //   grid,
        // });
        const g = grid[neighbour.y][neighbour.x];
        if (isNaN(g)) {
          console.log({
            x: neighbour.x,
            y: neighbour.y,
            row: grid[neighbour.y],
          });
          throw "Unexpected NaN";
        }

        const distance = currentDistance + g;
        nodes.setDistance(neighbour, distance);
      }

      nodes.markAsVisited(current);
      if (current.x === maxX && current.y === maxY) break;

      const nextCurrent = nodes.nearestUnvisited();
      current = nextCurrent.position;
      currentDistance = nextCurrent.distance;
    }

    return nodes.getDistance(new Position(maxX, maxY)).toString();
  }

  protected parseInput(lines: string[]): number[][] {
    // const chars = lines.map(line => line.split(""));
    return lines.map(line => line.split("").map(s => parseInt(s)));
  }

  neighboursOf(position: Position, maxX: number, maxY: number): Position[] {
    const r: Position[] = [];

    if (position.x > 0) r.push(new Position(position.x - 1, position.y));
    if (position.x < maxX) r.push(new Position(position.x + 1, position.y));
    if (position.y > 0) r.push(new Position(position.x, position.y - 1));
    if (position.y < maxY) r.push(new Position(position.x, position.y + 1));

    return r;
  }

  unvisitedNeighboursOf(
    position: Position,
    nodes: Nodes,
    maxX: number,
    maxY: number
  ): Position[] {
    return this.neighboursOf(position, maxX, maxY).filter(
      pos => !nodes.isVisited(pos)
    );
  }

  test(): boolean {
    return true;
  }
}

export class Part2 extends Part1 {
  protected parseInput(lines: string[]): number[][] {
    const smallGrid = super.parseInput(lines);

    return [...Array(5).keys()].flatMap(tileY => {
      return smallGrid.map(row => {
        return [...Array(5).keys()].flatMap(tileX => {
          return this.rotate(row, tileX + tileY);
        });
      });
    });
  }

  private rotate(row: number[], by: number) {
    return row.map(n => ((n - 1 + by) % 9) + 1);
  }
}
