#pragma once
#include <algorithm>
#include <array>
#include <cmath>
#include <random>
#include <stdexcept>
#include <string>
#include <vector>
namespace uav {
using Path = std::vector<double>;
struct Scenario {
  int dimension = 30;
  double lower = -50, upper = 50, distance = 500;
  std::vector<std::array<double, 3>> threats = {
      {100, 0, 40},     {200, 0, 40},    {300, 0, 40},   {400, 0, 40},
      {150, 50, 40},    {250, 50, 40},   {350, 50, 40},  {150, -50, 40},
      {250, -50, 40},   {350, -50, 40},  {0, 40, 20},    {466, 40, 20},
      {250, -300, 260}, {250, 300, 277}, {466, -40, 20}, {30, -20, 30}};
  double objective(const Path &path) const {
    double cost = 0, dx = distance / (dimension + 1);
    for (int i = 0; i < dimension; ++i)
      for (auto t : threats)
        cost += std::exp(-std::hypot(dx * (i + 1) - t[0], path[i] - t[1]) *
                         std::log(20.) / t[2]);
    for (int i = 1; i < dimension; ++i)
      cost += std::hypot(dx, path[i] - path[i - 1]) / distance;
    return cost;
  }
};
struct Result {
  Path path, history;
};
inline Result optimize(const Scenario &scene, const std::string &algorithm,
                       int iterations, unsigned seed) {
  if (algorithm != "abc" && algorithm != "pso")
    throw std::runtime_error("Algorithm must be abc or pso");
  if (iterations < 1)
    throw std::runtime_error("Iterations must be positive");
  std::mt19937 engine(seed);
  std::uniform_real_distribution<double> unit(0, 1);
  auto random = [&]() { return unit(engine); };
  auto coordinate = [&]() {
    return scene.lower + (scene.upper - scene.lower) * random();
  };
  auto random_index = [&](int count) {
    return std::min(count - 1, int(random() * count));
  };
  int count = algorithm == "abc" ? 20 : 40, dimension = scene.dimension;
  std::vector<Path> positions(count, Path(dimension));
  Path values(count);
  for (int i = 0; i < count; ++i) {
    for (auto &q : positions[i])
      q = coordinate();
    values[i] = scene.objective(positions[i]);
  }
  int first =
      int(std::min_element(values.begin(), values.end()) - values.begin());
  Path best = positions[first];
  double best_cost = values[first];
  Result result;
  auto remember = [&]() {
    int index =
        int(std::min_element(values.begin(), values.end()) - values.begin());
    if (values[index] < best_cost) {
      best_cost = values[index];
      best = positions[index];
    }
  };
  if (algorithm == "abc") {
    std::vector<int> trials(count);
    auto visit = [&](int i) {
      int other = random_index(count - 1);
      if (other >= i)
        ++other;
      int j = random_index(dimension);
      Path candidate = positions[i];
      candidate[j] +=
          (2 * random() - 1) * (positions[i][j] - positions[other][j]);
      if (candidate[j] < scene.lower || candidate[j] > scene.upper)
        candidate[j] = coordinate();
      double value = scene.objective(candidate);
      if (value < values[i]) {
        positions[i] = candidate;
        values[i] = value;
        trials[i] = 0;
      } else
        ++trials[i];
    };
    for (int cycle = 0; cycle < iterations; ++cycle) {
      for (int i = 0; i < count; ++i)
        visit(i);
      Path probability(count);
      double max_fitness =
          1 / (1 + *std::min_element(values.begin(), values.end()));
      for (int i = 0; i < count; ++i)
        probability[i] = .9 / (1 + values[i]) / max_fitness + .1;
      for (int i = 0, accepted = 0; accepted < count; i = (i + 1) % count)
        if (random() < probability[i]) {
          visit(i);
          ++accepted;
        }
      remember();
      int abandoned = 0;
      for (int i = 1; i < count; ++i)
        if (trials[i] >= trials[abandoned])
          abandoned = i;
      if (trials[abandoned] > .1 * iterations) {
        for (auto &q : positions[abandoned])
          q = coordinate();
        values[abandoned] = scene.objective(positions[abandoned]);
        trials[abandoned] = 0;
        remember();
      }
      result.history.push_back(best_cost);
    }
  } else {
    auto personal = positions, velocity = positions;
    Path personal_cost = values;
    for (auto &row : velocity)
      for (auto &q : row)
        q = coordinate();
    for (int cycle = 0; cycle < iterations; ++cycle) {
      for (int i = 0; i < count; ++i) {
        double r1 = random(), r2 = random();
        for (int j = 0; j < dimension; ++j) {
          velocity[i][j] = .7298 * velocity[i][j] +
                           1.4962 * r1 * (personal[i][j] - positions[i][j]) +
                           1.4962 * r2 * (best[j] - positions[i][j]);
          positions[i][j] += velocity[i][j];
          if (positions[i][j] < scene.lower || positions[i][j] > scene.upper)
            positions[i][j] = coordinate();
        }
        values[i] = scene.objective(positions[i]);
        if (values[i] < personal_cost[i]) {
          personal[i] = positions[i];
          personal_cost[i] = values[i];
        }
        if (personal_cost[i] < best_cost) {
          best = personal[i];
          best_cost = personal_cost[i];
        }
      }
      result.history.push_back(best_cost);
    }
  }
  result.path = best;
  return result;
}
} // namespace uav
