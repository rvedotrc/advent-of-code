import * as c from "stream-chain";
import * as Base from "./base";
import { Readable } from "stream";
import { parser } from "stream-json/Parser";
import { Token } from "stream-json/filters/FilterBase";

export class Part1 extends Base.Part {
  async calculate(lines: string[]): Promise<string> {
    return new Promise((resolve, reject) => {
      const stringReader = new Readable();

      let sum = 0;

      const pipeline = c.chain([stringReader, parser()]);

      pipeline.on("data", (data: Token) => {
        if (data.name === "numberValue") sum += Number(data.value);
      });

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
    return new Promise((resolve, reject) => {
      const stringReader = new Readable();

      const sums = [{ sum: 0, isObject: false, seenRed: false }];

      const pipeline = c.chain([stringReader, parser()]);

      pipeline.on("data", (data: Token) => {
        if (data.name === "numberValue")
          sums[sums.length - 1].sum += Number(data.value);

        if (data.name === "startArray")
          sums.push({ sum: 0, isObject: false, seenRed: false });
        if (data.name === "startObject")
          sums.push({ sum: 0, isObject: true, seenRed: false });

        if (data.name === "stringValue" && data.value === "red")
          sums[sums.length - 1].seenRed = true;
        if (data.name === "endObject" || data.name === "endArray") {
          const last = sums.pop() as (typeof sums)[0];
          if (!last.isObject || !last.seenRed)
            sums[sums.length - 1].sum += last.sum;
        }
      });

      pipeline.on("finish", () => {
        resolve(sums[0].sum.toString());
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
      this.check("a", "[1,2,3]", "6"),
      this.check("b", '[1,{"c":"red","b":2},3]', "4"),
      this.check("c", '{"d":"red","e":[1,2,3,4],"f":5}', "0"),
      this.check("d", '[1,"red",5]', "6"),
    ];
  }
}
