import * as fs from "fs";

import { graphToDot } from "./dot";
import { graphBuilder } from "./graphBuilder";
import { reduceSpaces } from "./reduceSpaces";
import { solve } from "./solve";

const run = (filename: string, dotFile: string) => {
  const text: string = fs.readFileSync(filename).toString();
  let g = graphBuilder(text);
  g.dump();

  g = reduceSpaces(g);
  g.dump();

  fs.writeFileSync(dotFile, graphToDot(g));
  console.log(`wrote ${dotFile}}`);

  const best = solve(g);
  console.log({ best });
};

run("../input/day18", "day18.part1.dot");
run("../input/day18.part2", "day18.part2.dot");
