import * as Base from "./base";

export class Part1 extends Base.Part {
  async calculate(lines: string[]): Promise<string> {
    return [...lines[0].split("")].reverse().join("");
  }

  async test(): Promise<Promise<boolean> | Promise<boolean>[]> {
    return [this.check("example", "polo", "olop")];
  }
}

export class Part2 extends Part1 {
  async calculate(lines: string[]): Promise<string> {
    return (await super.calculate(lines)).toUpperCase();
  }

  async test(): Promise<Promise<boolean> | Promise<boolean>[]> {
    return [this.check("example", "polo", "OLOP")];
  }
}
