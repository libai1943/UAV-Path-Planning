"""ABC/PSO ports of the repository's discrete path-cost demonstration."""
from dataclasses import dataclass
import numpy as np


@dataclass
class Scenario:
    dimension: int = 30
    lower: float = -50.0
    upper: float = 50.0
    distance: float = 500.0

    @property
    def threats(self):
        return np.array([
            [100, 0, 40], [200, 0, 40], [300, 0, 40], [400, 0, 40],
            [150, 50, 40], [250, 50, 40], [350, 50, 40],
            [150, -50, 40], [250, -50, 40], [350, -50, 40],
            [0, 40, 20], [466, 40, 20], [250, -300, 260],
            [250, 300, 277], [466, -40, 20], [30, -20, 30]], dtype=float)

    def objective(self, path):
        """Match calcu.m: interior-node exposure + normalized interior length."""
        x = np.arange(1, self.dimension + 1) * self.distance / (self.dimension + 1)
        threats = self.threats
        distances = np.hypot(x[:, None] - threats[:, 0], path[:, None] - threats[:, 1])
        exposure = np.exp(-distances * np.log(20) / threats[:, 2]).sum()
        length = np.hypot(self.distance / (self.dimension + 1), np.diff(path)).sum()
        return float(length / self.distance + exposure)


def optimize(scenario, algorithm='abc', iterations=500, seed=1):
    rng = np.random.default_rng(seed)
    dimension = scenario.dimension
    count = 20 if algorithm == 'abc' else 40
    positions = rng.uniform(scenario.lower, scenario.upper, (count, dimension))
    values = np.array([scenario.objective(p) for p in positions])
    index = values.argmin()
    best, best_cost = positions[index].copy(), values[index]
    history = []

    def remember():
        nonlocal best, best_cost
        index = values.argmin()
        if values[index] < best_cost:
            best, best_cost = positions[index].copy(), values[index]

    if algorithm == 'abc':
        trials = np.zeros(count, dtype=int)
        limit = 0.1 * iterations

        def visit(index):
            other = rng.integers(count - 1)
            other += other >= index
            coordinate = rng.integers(dimension)
            candidate = positions[index].copy()
            candidate[coordinate] += rng.uniform(-1, 1) * (positions[index, coordinate] - positions[other, coordinate])
            if not scenario.lower <= candidate[coordinate] <= scenario.upper:
                candidate[coordinate] = rng.uniform(scenario.lower, scenario.upper)
            cost = scenario.objective(candidate)
            if cost < values[index]:
                positions[index], values[index], trials[index] = candidate, cost, 0
            else:
                trials[index] += 1

        for _ in range(iterations):
            for index in range(count):
                visit(index)
            fitness = 1 / (1 + values)
            probability = 0.9 * fitness / fitness.max() + 0.1
            index = accepted = 0
            while accepted < count:
                if rng.random() < probability[index]:
                    visit(index)
                    accepted += 1
                index = (index + 1) % count
            remember()
            abandoned = int(np.flatnonzero(trials == trials.max())[-1])
            if trials[abandoned] > limit:
                positions[abandoned] = rng.uniform(scenario.lower, scenario.upper, dimension)
                values[abandoned] = scenario.objective(positions[abandoned])
                trials[abandoned] = 0
                remember()
            history.append(best_cost)
    elif algorithm == 'pso':
        velocity = rng.uniform(scenario.lower, scenario.upper, (count, dimension))
        personal, personal_cost = positions.copy(), values.copy()
        for _ in range(iterations):
            for index in range(count):
                velocity[index] = (0.7298 * velocity[index]
                    + 1.4962 * rng.random() * (personal[index] - positions[index])
                    + 1.4962 * rng.random() * (best - positions[index]))
                positions[index] += velocity[index]
                outside = (positions[index] < scenario.lower) | (positions[index] > scenario.upper)
                positions[index, outside] = rng.uniform(scenario.lower, scenario.upper, outside.sum())
                values[index] = scenario.objective(positions[index])
                if values[index] < personal_cost[index]:
                    personal[index], personal_cost[index] = positions[index].copy(), values[index]
                if personal_cost[index] < best_cost:
                    best, best_cost = personal[index].copy(), personal_cost[index]
            history.append(best_cost)
    else:
        raise ValueError('algorithm must be abc or pso')
    return best, np.asarray(history)
