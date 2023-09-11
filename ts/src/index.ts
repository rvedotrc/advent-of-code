import * as fs from "fs";

import { graphBuilder } from "./graphBuilder";

// const CURRENT = "@";
// const isKey = (s: string) => s >= "a" && s <= "z";
// const isDoor = (s: string) => s >= "A" && s <= "Z";

// type Edge = {
//   readonly start: Position;
//   readonly end: Position;
//   readonly cost: number;
// };

const text: string = fs.readFileSync("../input/day18").toString();
const g = graphBuilder(text);
g.dump();
g.reduceDeadEnds();
g.dump();
g.reduceTwoEdgeSpaceNodes();
g.dump();
