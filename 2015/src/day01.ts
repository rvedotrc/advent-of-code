import * as Base from "./base";

export class Part1 extends Base.Part {
  async calculate(lines: string[]): Promise<string> {
    const chars = lines[0].split("");
    return (2 * chars.filter(c => c === "(").length - chars.length).toString();
  }

  async test(): Promise<Promise<boolean>[]> {
    return [
      this.check("example", "(())", "0"),
      this.check("example", "()()", "0"),
      this.check("example", "(((", "3"),
      this.check("example", "(()(()(", "3"),
      this.check("example", "))(((((", "3"),
      this.check("example", "())", "-1"),
      this.check("example", "))(", "-1"),
      this.check("example", ")))", "-3"),
      this.check("example", ")())())", "-3"),
    ];
  }
}

export class Part2 extends Part1 {
  async calculate(lines: string[]): Promise<string> {
    let floor = 0;
    let pos = 1;

    for (const c of lines[0].split("")) {
      if (c === "(") ++floor;
      if (c === ")") --floor;
      if (floor < 0) return pos.toString();
      ++pos;
    }

    throw "";
  }

  async test(): Promise<Promise<boolean>[]> {
    return [
      this.check("example", ")", "1"),
      this.check("example", "()())", "5"),
    ];
  }
}
