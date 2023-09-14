import * as Base from "./base";

type TargetArea = { x0: number; x1: number; y0: number; y1: number };
type ResultPair = {
  input: { vX: number; vY: number };
  output: { hitTarget: boolean; maxY: number };
};

export class Part1 extends Base.BasePart implements Base.Part {
  calculate(lines: string[]): string {
    const target = this.parseTarget(lines[0]);

    let best: ResultPair | undefined;

    for (const result of this.allHits(target)) {
      if (!best || result.output.maxY > best.output.maxY) {
        best = result;
      }
    }

    if (!best) throw "No best";

    console.log({ best });
    return best.output.maxY.toString();
  }

  protected allHits(target: TargetArea): ResultPair[] {
    if (target.y1 >= 0) throw "erk y";
    if (target.x0 <= 0) throw "erk x";

    const output: ResultPair[] = [];

    for (let vX = 0; vX <= target.x1; ++vX) {
      for (let vY = target.y0; vY <= -target.y0; ++vY) {
        const result = this.runTrajectory(target, vX, vY);
        if (result.hitTarget)
          output.push({ input: { vX, vY }, output: result });
      }
    }

    return output;
  }

  protected parseTarget(line: string): TargetArea {
    const match =
      /^target area: x=(-?\d+)\.\.(-?\d+), y=(-?\d+)\.\.(-?\d+)$/.exec(line);
    if (!match) throw "No match";

    const x0 = parseInt(match[1]);
    const x1 = parseInt(match[2]);
    const y0 = parseInt(match[3]);
    const y1 = parseInt(match[4]);

    return { x0, x1, y0, y1 };
  }

  private runTrajectory(
    target: TargetArea,
    vX: number,
    vY: number
  ): { hitTarget: boolean; maxY: number } {
    let x = 0;
    let y = 0;
    let maxY = y;
    let hitTarget = false;

    while (true) {
      if (
        x >= target.x0 &&
        x <= target.x1 &&
        y >= target.y0 &&
        y <= target.y1
      ) {
        hitTarget = true;
        break;
      }

      if ((x > target.x1 && vX >= 0) || (x < target.x0 && vX <= 0)) {
        break;
      }

      if (y < target.y0 && vY < 0) {
        break;
      }

      x += vX;
      y += vY;
      vX -= Math.sign(vX);
      --vY;

      if (vY === 0) maxY = y;
    }

    return { hitTarget, maxY };
  }

  test(): boolean {
    return true;
  }
}

export class Part2 extends Part1 {
  calculate(lines: string[]): string {
    const target = this.parseTarget(lines[0]);
    return this.allHits(target).length.toString();
  }
}
