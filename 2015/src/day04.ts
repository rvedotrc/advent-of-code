import * as c from "node:crypto";

import * as Base from "./base";
import { Worker, isMainThread, parentPort } from "worker_threads";

export class Part1 extends Base.Part {
  async calculate(lines: string[], part = 1): Promise<string> {
    return new Promise<string>(resolve => {
      const n = 4;

      const chunkSize = 100000;
      let current = 0;

      const workers = new Array(n).fill(0).map((_, i) => {
        const w = new Worker(__filename, {
          argv: [i, part],
          transferList: [new ArrayBuffer(i)],
          name: `w${i}`,
        });
        w.on("online", () => {
          // console.log(`w${i} >> online`);
          w.postMessage([lines[0], current, current + chunkSize]);
          current += chunkSize;
        });
        w.on("error", err => console.log(`w${i} >> error`, err));
        // w.on("exit", code => console.log(`w${i} >> exit`, code));
        w.on("message", message => {
          // console.log(`w${i} >> message`, message);
          if (message === undefined) {
            w.postMessage([lines[0], current, current + chunkSize]);
            current += chunkSize;
          } else {
            Promise.all(workers.map(wk => wk.terminate())).then(() =>
              resolve(message.toString())
            );
          }
          // w.terminate();
        });
        w.on("messageerror", error =>
          console.log(`w${i} >> messageerror`, error)
        );
        return w;
      });
    });
  }

  async test(): Promise<Promise<boolean> | Promise<boolean>[]> {
    return [
      this.check("example", "abcdef", "609043"),
      this.check("example", "pqrstuv", "1048970"),
    ];
  }
}

export class Part2 extends Part1 {
  async calculate(lines: string[]): Promise<string> {
    return super.calculate(lines, 2);
  }

  async test(): Promise<Promise<boolean> | Promise<boolean>[]> {
    return [];
  }
}

if (!isMainThread && parentPort) {
  const port = parentPort;
  const workerName = process.argv[2];
  const part = Number(process.argv[3]);

  parentPort.on("message", msg => {
    // console.log(`${workerName} << message`, { msg });
    const [prefix, start, stop] = msg as [string, number, number];

    for (let i = start; i < stop; ++i) {
      const hash = c.createHash("md5");
      hash.update(`${prefix}${i}`);
      const d = hash.digest();

      if (part == 1 && d.readUint16BE() === 0 && d.readUint8(2) < 16) {
        port.postMessage(i);
        return;
      } else if (part == 2 && d.readUint16BE() === 0 && d.readUint8(2) === 0) {
        port.postMessage(i);
        return;
      }
    }

    port.postMessage(undefined);
  });
  parentPort.on("messageerror", err =>
    console.log(`${workerName} << messageerror`, { err })
  );
  parentPort.on("close", () => console.log(`${workerName} << close`));
}
