import * as Base from "./base";

export class Part1 extends Base.Part {
  async calculate(lines: string[]): Promise<string> {
    return lines.filter(s => this.isNice(s)).length.toString();
  }

  isNice(s: string): boolean {
    return (
      [...s.matchAll(/[aeiou]/g)].length >= 3 &&
      s.match(/(.)\1/) !== null &&
      !s.match(/(ab|cd|pq|xy)/)
    );
  }

  async test(): Promise<Promise<boolean> | Promise<boolean>[]> {
    return [
      this.check("example", "ugknbfddgicrmopn", "1"),
      this.check("example", "aaa", "1"),
      this.check("example", "jchzalrnumimnmhp", "0"),
      this.check("example", "haegwjzuvuyypxyu", "0"),
      this.check("example", "dvszwmarrgswjxmb", "0"),
    ];
  }
}

export class Part2 extends Part1 {
  isNice(s: string): boolean {
    return s.match(/(..).*?\1/) !== null && s.match(/(.).\1/) !== null;
  }

  async test(): Promise<Promise<boolean> | Promise<boolean>[]> {
    return [
      this.check("example", "qjhvhtzxzqqjkmpb", "1"),
      this.check("example", "xxyxx", "1"),
      this.check("example", "uurcxstgmygtbstg", "0"),
      this.check("example", "ieodomkazucvgmuy", "0"),
    ];
  }
}
