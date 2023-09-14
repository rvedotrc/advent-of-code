import * as Base from "./base";

export class Part1 extends Base.BasePart implements Base.Part {
  calculate(lines: string[]): string {
    const chars = lines[0].split("");
    return (2 * chars.filter(c => c === "(").length - chars.length).toString();
  }

  test(): boolean {
    const c = (i: string) => this.calculate([i]);

    return [
      this.checkResult("example 1", c("(())"), "0"),
      this.checkResult("example 1", c("()()"), "0"),
      this.checkResult("example 1", c("((("), "3"),
      this.checkResult("example 1", c("(()(()("), "3"),
      this.checkResult("example 1", c("))((((("), "3"),
      this.checkResult("example 1", c("())"), "-1"),
      this.checkResult("example 1", c("))("), "-1"),
      this.checkResult("example 1", c(")))"), "-3"),
      this.checkResult("example 1", c(")())())"), "-3"),
    ].every(Boolean);
  }
}

export class Part2 extends Part1 {
  calculate(lines: string[]): string {
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

  test(): boolean {
    const c = (i: string) => this.calculate([i]);

    return [
      this.checkResult("example 1", c(")"), "1"),
      this.checkResult("example 1", c("()())"), "5"),
    ].every(Boolean);
  }
}
