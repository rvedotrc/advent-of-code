import * as fs from "fs";

import { graphToDot } from "./dot";
import { graphBuilder } from "./graphBuilder";
import { reduceSpaces } from "./reduceSpaces";
import { solve } from "./solve";

const text: string = fs.readFileSync("../input/day18").toString();
let g = graphBuilder(text);
g.dump();
g = reduceSpaces(g);
g.dump();

fs.writeFileSync("t.dot", graphToDot(g));
console.log("wrote t.dot");

const best = solve(g);
console.log({ best });
