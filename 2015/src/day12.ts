import * as c from "stream-chain";
import * as Base from "./base";
import { Readable } from "stream";
import { parser } from "stream-json/Parser";
import { emitter } from "stream-json/Emitter";

export class Part1 extends Base.Part {
  async calculate(lines: string[]): Promise<string> {
    return new Promise((resolve, reject) => {
      const stringReader = new Readable();

      let sum = 0;

      const pipeline = c.chain([
        stringReader,
        parser(),
        emitter().on("numberValue", data => (sum += Number(data))),
      ]);

      pipeline.on("finish", () => {
        resolve(sum.toString());
      });

      pipeline.on("error", err => {
        console.error({ err });
        reject(err);
      });

      stringReader.push(lines[0]);
      stringReader.push(null);
    });
  }

  async test(): Promise<Promise<boolean> | Promise<boolean>[]> {
    return [
      this.check("example", '[7,8,"",{}]', "15"),
      this.check("example", '[7,8,"",{"x": 9}]', "24"),
    ];
  }
}

export class Part2 extends Part1 {
  async calculate(lines: string[]): Promise<string> {
    const data = JSON.parse(lines[0]);
    return this.sum(data).toString();
  }

  sum(data: unknown): number {
    if (typeof data === "number") return data;
    if (typeof data === "string") return 0;

    if (Array.isArray(data)) {
      return data.reduce((sum, item) => sum + this.sum(item), 0);
    }

    if (data && typeof data === "object") {
      const d = data as unknown as Record<string, unknown>;

      for (const v of Object.values(d)) {
        if (v === "red") return 0;
      }

      /* eslint-disable @typescript-eslint/no-explicit-any */
      const v: any[] = Object.values(d);
      return v.reduce(
        (previousValue, currentValue) => previousValue + this.sum(currentValue),
        0
      );
    }

    throw "?";
  }

  async test(): Promise<Promise<boolean> | Promise<boolean>[]> {
    return [
      this.check("a", "[1,2,3]", "6"),
      this.check("b", '[1,{"c":"red","b":2},3]', "4"),
      this.check("c", '{"d":"red","e":[1,2,3,4],"f":5}', "0"),
      this.check("d", '[1,"red",5]', "6"),
    ];
  }
}
