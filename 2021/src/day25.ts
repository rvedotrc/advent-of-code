import * as Base from "./base";

export class Part1 extends Base.BasePart implements Base.Part {
  calculate(lines: string[]): string {
    const grid = lines.map(line => line.split(""));
    let moves = 0;

    this.show(grid);

    while (true) {
      const moved = this.stepH(grid);
      ++moves;
      if (!moved) break;
    }

    return moves.toString();
  }

  stepH(grid: string[][]): boolean {
    const countX = grid[0].length;
    const countY = grid.length;

    const movedX = this.step(
      countX,
      countY,
      ">",
      (x: number, y: number) => grid[y][x],
      (x: number, y: number, v: string) => (grid[y][x] = v)
    );
    this.show(grid);

    const movedY = this.step(
      countY,
      countX,
      "v",
      (y: number, x: number) => grid[y][x],
      (y: number, x: number, v: string) => (grid[y][x] = v)
    );
    this.show(grid);

    return movedX || movedY;
  }

  step(
    countX: number,
    countY: number,
    cucumber: string,
    getter: (x: number, y: number) => string,
    setter: (x: number, y: number, v: string) => void
  ): boolean {
    let moved = false;

    for (let y = 0; y < countY; ++y) {
      const canMove = [...Array(countX).keys()].filter(
        x => getter(x, y) === cucumber && getter((x + 1) % countX, y) === "."
      );

      moved ||= canMove.length > 0;

      for (const x of canMove) {
        setter((x + 1) % countX, y, cucumber);
        setter(x, y, ".");
      }
    }

    return moved;
  }

  show(_grid: string[][]): void {
    // console.log(grid.map(row => row.join("")).join("\n"));
    // console.log("\n");
  }

  test(): boolean {
    return true;
  }
}

export class Part2 extends Part1 {}
