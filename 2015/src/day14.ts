import * as Base from "./base";

type Reindeer = {
  name: string;
  speed: number;
  flyTime: number;
  restTime: number;
};

export class Part1 extends Base.Part {
  async calculate(lines: string[]): Promise<string> {
    const deer = lines.map(line => this.parse(line));
    const snapshot = deer.map(d => this.afterNSeconds(d, 2503));
    const max = Math.max(...snapshot.map(s => s.distance));
    return max.toString();
  }

  parse(line: string): Reindeer {
    const m = line.match(
      /^(?<name>\w+) can fly (?<speed>[0-9]+) km\/s for (?<flyTime>[0-9]+) seconds?, but then must rest for (?<restTime>[0-9]+) seconds?\.$/
    );
    if (!m?.groups) throw `? ${line}`;

    return {
      name: m.groups.name,
      speed: Number(m.groups.speed),
      flyTime: Number(m.groups.flyTime),
      restTime: Number(m.groups.restTime),
    };
  }

  afterNSeconds(
    reindeer: Reindeer,
    seconds: number
  ): { reindeer: Reindeer; distance: number } {
    const cycleTime = reindeer.flyTime + reindeer.restTime;
    const cycles = Math.floor(seconds / cycleTime);
    const leftoverSeconds = seconds % cycleTime;
    const flyTime =
      reindeer.flyTime * cycles + Math.min(reindeer.flyTime, leftoverSeconds);
    const distance = reindeer.speed * flyTime;
    return { reindeer, distance };
  }

  async test(): Promise<Promise<boolean> | Promise<boolean>[]> {
    return [];
  }
}

type IterationState = {
  reindeer: Reindeer;
  flying: boolean;
  secondsRemaining: number;
  distance: number;
  points: number;
};

export class Part2 extends Part1 {
  async calculate(lines: string[]): Promise<string> {
    const deer = lines.map(line => this.parse(line));

    const states: IterationState[] = deer.map(d => ({
      reindeer: d,
      flying: true,
      secondsRemaining: d.flyTime,
      distance: 0,
      points: 0,
    }));

    for (let i = 0; i < 2503; ++i) {
      for (const s of states) {
        if (s.flying) {
          s.distance += s.reindeer.speed;
          --s.secondsRemaining;

          if (s.secondsRemaining === 0) {
            s.flying = false;
            s.secondsRemaining = s.reindeer.restTime;
          }
        } else {
          --s.secondsRemaining;

          if (s.secondsRemaining === 0) {
            s.flying = true;
            s.secondsRemaining = s.reindeer.flyTime;
          }
        }
      }

      const greatestDistance = Math.max(...states.map(s => s.distance));

      for (const s of states) {
        if (s.distance === greatestDistance) ++s.points;
      }
    }

    const topScore = Math.max(...states.map(s => s.points));
    return topScore.toString();
  }

  async test(): Promise<Promise<boolean> | Promise<boolean>[]> {
    return [];
  }
}
