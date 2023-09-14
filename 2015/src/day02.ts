import * as Base from "./base";

export class Part1 extends Base.Part {
  async calculate(lines: string[]): Promise<string> {
    return lines
      .map(line => {
        const [x, y, z] = line.split("x").map(Number);

        const xy = x * y;
        const yz = y * z;
        const zx = z * x;

        return 2 * (xy + yz + zx) + [xy, yz, zx].sort((a, b) => a - b)[0];
      })
      .reduce((a, b) => a + b, 0)
      .toString();
  }

  async test(): Promise<Promise<boolean> | Promise<boolean>[]> {
    return [
      this.check("example", "2x3x4", "58"),
      this.check("example", "1x1x10", "43"),
    ];
  }
}

export class Part2 extends Part1 {
  async calculate(lines: string[]): Promise<string> {
    return lines
      .map(line => {
        const [x, y, z] = line.split("x").map(Number);

        const sides = [x, y, z].sort((a, b) => a - b);

        return 2 * (sides[0] + sides[1]) + x * y * z;
      })
      .reduce((a, b) => a + b, 0)
      .toString();
  }

  async test(): Promise<Promise<boolean> | Promise<boolean>[]> {
    return [
      this.check("example", "2x3x4", "34"),
      this.check("example", "1x1x10", "14"),
    ];
  }
}
