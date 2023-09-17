import * as Base from "./base";

// const nextLetter: Record<string, string> = {};

export class Part1 extends Base.Part {
  async calculate(lines: string[]): Promise<string> {
    let password = lines[0];

    // for (let i = 0; i < 100; ++i) {
    //   console.log({ password });
    //   password = this.increment(password);
    // }

    while (true) {
      password = this.increment(password);
      if (this.validPassword(password)) break;
    }

    return password;
  }

  private increment(password: string): string {
    // const input = password;
    let pos = password.length - 1;

    while (true) {
      let letter = password[pos];
      letter =
        letter == "z"
          ? "a"
          : letter == "h"
          ? "j"
          : letter == "k"
          ? "m"
          : letter == "n"
          ? "p"
          : String.fromCharCode(letter.charCodeAt(0) + 1);
      password = password.slice(0, pos) + letter + password.slice(pos + 1);
      if (letter !== "a") break;

      --pos;
      if (pos < 0) throw "nah";
    }

    // console.log([input, password]);
    return password;
  }

  private validPassword(password: string) {
    return (
      this.containsRunOfThree(password) &&
      this.containsTwoDifferentPairs(password)
    );
  }

  private containsRunOfThree(password: string): boolean {
    return (
      password.match(
        /(abc|bcd|cde|def|efg|fgh|pqr|qrs|rst|stu|tuv|uvw|vwx|wxy|xyz)/
      ) !== null
    );
  }

  private containsTwoDifferentPairs(password: string): boolean {
    return password.match(/(.)\1.*(.)\2(?!<\1\1)/) != null;
  }

  async test(): Promise<Promise<boolean> | Promise<boolean>[]> {
    return [this.check("example", "peloerhiu", "peloffghh")];
  }
}

export class Part2 extends Part1 {
  async calculate(lines: string[]): Promise<string> {
    return super.calculate([await super.calculate(lines)]);
  }

  async test(): Promise<Promise<boolean> | Promise<boolean>[]> {
    return [];
  }
}
