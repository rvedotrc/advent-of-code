import * as c from "node:crypto";

import * as Base from "./base";

export class Part1 extends Base.Part {
  calculate(lines: string[]): string {
    for (let i = 0; ; ++i) {
      const hash = c.createHash("md5");
      hash.update(`${lines[0]}${i}`);
      const d = hash.digest();
      if (d.readUint16BE() === 0 && d.readUint8(2) < 16) return i.toString();
    }
  }

  test(): boolean[] {
    return [
      this.check("example", "abcdef", "609043"),
      this.check("example", "pqrstuv", "1048970"),
    ];
  }
}

export class Part2 extends Part1 {
  calculate(lines: string[]): string {
    for (let i = 0; ; ++i) {
      const hash = c.createHash("md5");
      hash.update(`${lines[0]}${i}`);
      const d = hash.digest();
      if (d.readUint16BE() === 0 && d.readUint8(2) === 0) return i.toString();
    }
  }

  test(): boolean[] {
    return [];
  }
}
