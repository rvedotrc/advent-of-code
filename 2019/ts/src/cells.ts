export const SPACE = ".";
export const WALL = "#";
export const CURRENT = "@";

export const isKey = (what: string): boolean => what >= "a" && what <= "z";
export const isDoor = (what: string): boolean => what >= "A" && what <= "Z";
export const keyFor = (what: string): string => what.toLowerCase();
export const doorFor = (what: string): string => what.toUpperCase();
