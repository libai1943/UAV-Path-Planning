#include "planner.hpp"
#include <filesystem>
#include <fstream>
#include <iomanip>
#include <iostream>

void write_svg(const std::filesystem::path &path, const uav::Scenario &scene,
               const uav::Result &result) {
  std::ofstream out(path);
  out << "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 900 "
         "390\"><rect width=\"900\" height=\"390\" "
         "fill=\"white\"/><defs><clipPath id=\"plot\"><rect x=\"45\" y=\"65\" "
         "width=\"800\" height=\"256\"/></clipPath></defs><text x=\"45\" "
         "y=\"30\" font-family=\"sans-serif\" font-size=\"21\">Synthetic UAV "
         "path planning</text><g clip-path=\"url(#plot)\">";
  auto px = [](double x) { return 45 + 1.6 * x; };
  auto py = [](double y) { return 193 - 1.6 * y; };
  for (auto t : scene.threats)
    out << "<circle cx=\"" << px(t[0]) << "\" cy=\"" << py(t[1]) << "\" r=\""
        << 1.6 * t[2]
        << "\" fill=\"#e8d4bd\" fill-opacity=\"0.25\" stroke=\"#b58d69\" "
           "stroke-width=\"1\"/>";
  out << "<polyline fill=\"none\" stroke=\"#075985\" stroke-width=\"3\" "
         "points=\""
      << px(0) << "," << py(0) << " ";
  for (int i = 0; i < scene.dimension; ++i)
    out << px((i + 1) * scene.distance / (scene.dimension + 1)) << ","
        << py(result.path[i]) << " ";
  out << px(500) << "," << py(0)
      << "\"/></g><rect x=\"45\" y=\"65\" width=\"800\" height=\"256\" "
         "fill=\"none\" stroke=\"#94a3b8\"/><g font-family=\"sans-serif\" "
         "font-size=\"14\"><text x=\"45\" y=\"350\">Start (0, 0)</text><text "
         "x=\"730\" y=\"350\">Goal (500, 0)</text><text x=\"45\" "
         "y=\"375\">Discrete cost: "
      << std::setprecision(10) << result.history.back() << "</text></g></svg>";
}
int main(int argc, char **argv) {
  try {
    std::string algorithm = "abc";
    int iterations = 500;
    unsigned seed = 1;
    std::filesystem::path output = "results";
    for (int i = 1; i < argc; ++i) {
      std::string arg = argv[i];
      if (arg == "--algorithm" && i + 1 < argc)
        algorithm = argv[++i];
      else if (arg == "--iterations" && i + 1 < argc)
        iterations = std::stoi(argv[++i]);
      else if (arg == "--seed" && i + 1 < argc)
        seed = unsigned(std::stoul(argv[++i]));
      else if (arg == "--output" && i + 1 < argc)
        output = std::filesystem::u8path(argv[++i]);
      else
        throw std::runtime_error(
            "Usage: uav_demo [--algorithm abc|pso] [--iterations 500] [--seed "
            "1] [--output DIR]");
    }
    uav::Scenario scene;
    auto result = uav::optimize(scene, algorithm, iterations, seed);
    std::filesystem::create_directories(output);
    std::ofstream path(output / "path.csv");
    path << std::setprecision(17) << "x,y\n0,0\n";
    for (int i = 0; i < scene.dimension; ++i)
      path << (i + 1) * scene.distance / (scene.dimension + 1) << ','
           << result.path[i] << '\n';
    path << "500,0\n";
    std::ofstream history(output / "convergence.csv");
    history << std::setprecision(17) << "iteration,cost\n";
    for (size_t i = 0; i < result.history.size(); ++i)
      history << i + 1 << ',' << result.history[i] << '\n';
    write_svg(output / "path.svg", scene, result);
    std::cout << algorithm << ": cost=" << std::setprecision(12)
              << result.history.back() << "; output=" << output.string()
              << '\n';
    return 0;
  } catch (const std::exception &e) {
    std::cerr << e.what() << '\n';
    return 1;
  }
}
