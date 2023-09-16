import * as Immutable from "immutable";
import * as Base from "./base";

type Register = string;

class Program {
  private readonly source: string[];
  private readonly compiled: Instruction[];
  private readonly compile: (line: string) => Instruction;

  constructor(source: string[], compile: (line: string) => Instruction) {
    this.source = source;
    this.compiled = new Array(source.length);
    this.compile = compile;
  }

  public get(ip: number): Instruction | undefined {
    if (this.compiled[ip]) return this.compiled[ip];
    if (!this.source[ip]) return undefined;
    return (this.compiled[ip] = this.compile(this.source[ip]));
  }
}

type Instruction =
  | HalfInstruction
  | TripleInstruction
  | IncrementInstruction
  | JumpInstruction
  | JumpIfEvenInstruction
  | JumpIfOneInstruction;

type HalfInstruction = {
  type: "hlf";
  register: Register;
};

type TripleInstruction = {
  type: "tpl";
  register: Register;
};

type IncrementInstruction = {
  type: "inc";
  register: Register;
};

type JumpInstruction = {
  type: "jmp";
  offset: number;
};

type JumpIfEvenInstruction = {
  type: "jie";
  register: Register;
  offset: number;
};

type JumpIfOneInstruction = {
  type: "jio";
  register: Register;
  offset: number;
};

type State = {
  program: Program;
  registers: Immutable.Map<string, number>;
  ip: number;
};

export class Part1 extends Base.Part {
  async calculate(lines: string[]): Promise<string> {
    let state: State = {
      program: this.readProgram(lines),
      ip: 0,
      registers: this.initialRegisters(),
    };

    while (true) {
      const next = this.iterate(state);
      if (next === "end") break;

      state = next;
    }

    return (state.registers.get("b") || "?").toString();
  }

  initialRegisters(): State["registers"] {
    return this.registers().reduce(
      (map, r) => map.set(r, 0),
      Immutable.Map<string, number>()
    );
  }

  registers(): string[] {
    return ["a", "b"];
  }

  readProgram(lines: string[]): Program {
    const registerPattern = `(?<r>${this.registers().join("|")})`;
    const hlfPattern = new RegExp(`^hlf ${registerPattern}$`);
    const tplPattern = new RegExp(`^tpl ${registerPattern}$`);
    const incPattern = new RegExp(`^inc ${registerPattern}$`);
    const jmpPattern = new RegExp(`^jmp (?<o>[+-][0-9]+)$`);
    const jiePattern = new RegExp(`^jie ${registerPattern}, (?<o>[+-][0-9]+)$`);
    const jioPattern = new RegExp(`^jio ${registerPattern}, (?<o>[+-][0-9]+)$`);
    let m: RegExpMatchArray | null;

    const compileFunction = (line: string): Instruction => {
      m = line.match(hlfPattern);
      if (m?.groups) return { type: "hlf", register: m.groups["r"] };

      m = line.match(tplPattern);
      if (m?.groups) return { type: "tpl", register: m.groups["r"] };

      m = line.match(incPattern);
      if (m?.groups) return { type: "inc", register: m.groups["r"] };

      m = line.match(jmpPattern);
      if (m?.groups) return { type: "jmp", offset: Number(m.groups["o"]) };

      m = line.match(jiePattern);
      if (m?.groups)
        return {
          type: "jie",
          register: m.groups["r"],
          offset: Number(m.groups["o"]),
        };

      m = line.match(jioPattern);
      if (m?.groups)
        return {
          type: "jio",
          register: m.groups["r"],
          offset: Number(m.groups["o"]),
        };

      throw `? ${line}`;
    };

    return new Program(lines, compileFunction);
  }

  iterate(s: State): State | "end" {
    const i = s.program.get(s.ip);
    if (i === undefined) return "end";

    if (i.type === "hlf")
      return {
        ...s,
        ip: s.ip + 1,
        registers: s.registers.set(
          i.register,
          (s.registers.get(i.register) || 0) / 2
        ),
      };

    if (i.type === "tpl")
      return {
        ...s,
        ip: s.ip + 1,
        registers: s.registers.set(
          i.register,
          (s.registers.get(i.register) || 0) * 3
        ),
      };

    if (i.type === "inc")
      return {
        ...s,
        ip: s.ip + 1,
        registers: s.registers.set(
          i.register,
          (s.registers.get(i.register) || 0) + 1
        ),
      };

    if (i.type === "jmp")
      return {
        ...s,
        ip: s.ip + i.offset,
      };

    if (i.type === "jie") {
      if ((s.registers.get(i.register) || 0) % 2 === 0) {
        return { ...s, ip: s.ip + i.offset };
      } else {
        return { ...s, ip: s.ip + 1 };
      }
    }

    if (i.type === "jio") {
      if ((s.registers.get(i.register) || 0) === 1) {
        return { ...s, ip: s.ip + i.offset };
      } else {
        return { ...s, ip: s.ip + 1 };
      }
    }

    throw "?";
  }

  async test(): Promise<Promise<boolean> | Promise<boolean>[]> {
    return [this.check("example", ["inc b"], "1")];
  }
}

export class Part2 extends Part1 {
  initialRegisters(): State["registers"] {
    return super.initialRegisters().set("a", 1);
  }

  async test(): Promise<Promise<boolean> | Promise<boolean>[]> {
    return [];
  }
}
