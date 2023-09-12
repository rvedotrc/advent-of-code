type N<S, K> = {
  state: S;
  key: K;
  distance: number;
};

export const solve = <S, K = string>(
  initialState: S,
  keyMaker: (state: S) => K,
  getNextStates: (state: S) => { state: S; distance: number }[],
  found: (state: S, distance: number) => { stop: boolean },
): number | undefined => {
  const initialKey = keyMaker(initialState);
  const bestDistances = new Map<K, number>().set(initialKey, 0);
  const visited = new Set<K>();
  const seenUnvisited = new Map<K, S>();

  let current: N<S, K> = {
    state: initialState,
    key: initialKey,
    distance: 0,
  };

  while (true) {
    if (visited.has(current.key)) throw "124";

    const unvisitedNeighbours = getNextStates(current.state)
      .map((n) => ({
        ...n,
        key: keyMaker(n.state),
        distance: current.distance + n.distance,
      }))
      .filter((n) => !visited.has(n.key));

    for (const n of unvisitedNeighbours) {
      seenUnvisited.set(n.key, n.state);

      const existingDistance = bestDistances.get(n.key);
      if (existingDistance === undefined || n.distance < existingDistance)
        bestDistances.set(n.key, n.distance);
    }

    visited.add(current.key);
    seenUnvisited.delete(current.key);

    if (found(current.state, current.distance).stop) {
      return current.distance;
    }

    const candidates = [...seenUnvisited.entries()]
      .map(([key, state]) => {
        const bestScore = bestDistances.get(key);
        return {
          state,
          key,
          distance: bestScore === undefined ? Infinity : bestScore,
        };
      })
      .sort((a, b) => a.distance - b.distance);

    const next = candidates[0];
    if (!next) return undefined;
    if (next.distance === Infinity) return undefined;

    if (visited.has(next.key)) throw "159";

    current = next;
  }
};
