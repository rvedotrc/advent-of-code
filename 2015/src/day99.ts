import * as Base from "./base";

export class Part1 extends Base.Part {
  calculate(lines: string[]): string {
    return [...lines[0].split("")].reverse().join("");
  }

  test(): boolean[] {
    return [this.check("example", "polo", "olop")];
  }
}

export class Part2 extends Part1 {
  calculate(lines: string[]): string {
    return super.calculate(lines).toUpperCase();
  }

  test(): boolean[] {
    return [this.check("example", "polo", "OLOP")];
  }
}
