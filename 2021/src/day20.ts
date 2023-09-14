import * as Base from "./base";

export class Part1 extends Base.BasePart implements Base.Part {
  calculate(lines: string[]): string {
    const { map, grid: startGrid } = this.parse(lines);
    let grid = startGrid;
    // this.showGrid(grid);
    for (let n = 0; n < this.iterations(); ++n)
      grid = this.iterate(grid, map, n % 2 === 1 && map[0]);
    return this.countPixels(grid).toString();
  }

  parse(lines: string[]): { map: boolean[]; grid: boolean[][] } {
    const copy = [...lines];
    let map: boolean[] = [];

    while (true) {
      const line = copy.shift();
      if (line === undefined || line === "") break;

      map = map.concat(...line.split("").map(s => s === "#"));
    }

    const grid = copy.map(line => line.split("").map(s => s === "#"));

    return { map, grid };
  }

  iterate(grid: boolean[][], map: boolean[], offGrid: boolean): boolean[][] {
    const output: boolean[][] = [];
    const padding = 1;

    for (let y = -padding; y < grid.length + padding; ++y) {
      const row: boolean[] = [];
      for (let x = -padding; x < grid[0].length + padding; ++x) {
        row.push(this.calculatePixel(grid, map, y, x, offGrid));
      }
      output.push(row);
    }

    // this.showGrid(output);

    return output;
  }

  showGrid(grid: boolean[][]): void {
    for (const row of grid) {
      console.log(row.map(s => (s ? "#" : ".")).join(""));
    }
    console.log("");
  }

  calculatePixel(
    grid: boolean[][],
    map: boolean[],
    y: number,
    x: number,
    offGrid: boolean
  ): boolean {
    const p = (py: number, px: number) => {
      if (px < 0 || py < 0 || px >= grid[0].length || py >= grid.length)
        return offGrid ? 1 : 0;
      return grid[py][px] ? 1 : 0;
    };

    const index =
      256 * p(y - 1, x - 1) +
      128 * p(y - 1, x) +
      64 * p(y - 1, x + 1) +
      32 * p(y, x - 1) +
      16 * p(y, x) +
      8 * p(y, x + 1) +
      4 * p(y + 1, x - 1) +
      2 * p(y + 1, x) +
      1 * p(y + 1, x + 1);

    return map[index];
  }

  iterations(): number {
    return 2;
  }

  countPixels(grid: boolean[][]): number {
    return grid.flatMap(s => s).filter(s => s).length;
  }

  test(): boolean {
    return true;
  }
}

export class Part2 extends Part1 {
  iterations(): number {
    return 50;
  }
}
