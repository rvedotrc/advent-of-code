import * as Base from "./base";

export class Part1 extends Base.Part {
  calculate(lines: string[], actors = 1): string {
    const visited = new Set<string>().add("0,0");
    const positions = new Array(actors).fill(0).map(() => ({ x: 0, y: 0 }));

    for (const c of lines[0].split("")) {
      const pos = positions[0];
      if (c === "^") ++pos.y;
      else if (c === "v") --pos.y;
      else if (c === ">") ++pos.x;
      else if (c === "<") --pos.x;

      visited.add(`${pos.x},${pos.y}`);
      positions.push(...positions.splice(0, 1));
    }

    return visited.size.toString();
  }

  test(): boolean[] {
    return [
      this.check("example", ">", "2"),
      this.check("example", "^>v<", "4"),
      this.check("example", "^v^v^v^v^v", "2"),
    ];
  }
}

export class Part2 extends Part1 {
  calculate(lines: string[]): string {
    return super.calculate(lines, 2);
  }

  test(): boolean[] {
    return [
      this.check("example", "^v", "3"),
      this.check("example", "^>v<", "3"),
      this.check("example", "^v^v^v^v^v", "11"),
    ];
  }
}
