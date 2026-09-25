# UAV Path Planning

MATLAB implementation for unmanned combat aerial vehicle (UCAV) path planning in a threat environment.

This repository contains the source code associated with the work:

**Unmanned Combat Aerial Vehicles Path Planning Using a Novel Probability Density Model Based on Artificial Bee Colony Algorithm**

The main idea is to represent the influence of threat sources using a continuous probability-density-based model and formulate path planning as an optimization problem that considers both **flight distance** and **threat exposure**. An **Artificial Bee Colony (ABC)** algorithm is used to search for the resulting path. A **Particle Swarm Optimization (PSO)** implementation is also included for comparison.

## Method Overview

The UAV flies from a predefined starting point to a target point through an environment containing multiple threat sources.

Each threat source is characterized by its location and an effective threat radius. Instead of treating the threat boundary only as a hard geometric constraint, the code evaluates the threat associated with each path node using a distance-dependent exponential function.

For a path node at distance \(d\) from a threat source, its contribution decreases approximately exponentially with distance. The total objective combines:

- the geometric length of the planned path; and
- the accumulated threat cost along the path.

The path-planning problem is then solved using population-based optimization.

### Artificial Bee Colony

`runABC.m` implements the Artificial Bee Colony algorithm. Candidate paths are treated as food sources and are iteratively improved through the employed-bee, onlooker-bee, and scout-bee stages.

### Particle Swarm Optimization

`runPSO.m` implements a Particle Swarm Optimization baseline using the same general path representation and threat environment, making it possible to compare the optimization behavior of ABC and PSO.

## Repository Structure

```text
UAV-Path-Planning/
├── runABC.m              # Main Artificial Bee Colony path-planning program
├── runPSO.m              # Particle Swarm Optimization implementation
├── newexp.m              # Additional ABC experiment
├── calcu.m                # Objective-function evaluation for ABC
├── fitness.m              # Objective-function evaluation used by PSO
├── calculateFitness.m     # Converts objective values to ABC fitness values
├── cir_plot.m             # Visualization of circular threat regions
├── 1.mat                  # Experimental data
├── matlab.mat             # Experimental data
├── 2L UAV.pdf             # Related material
├── Hindawi_UCAV.pdf       # Related publication/material
├── UCAV 2013.pdf          # Related publication/material
└── LICENSE
```

## Path Representation

The horizontal distance between the starting point and destination is divided into a fixed number of intervals.

The optimization variables determine the lateral positions of the intermediate path nodes:

```text
Start -> P1 -> P2 -> ... -> PN -> Target
```

A candidate solution can therefore be represented as

```matlab
path = [y1, y2, ..., yN];
```

where the longitudinal coordinates are distributed along the start-to-target direction and the lateral coordinates are optimized by ABC or PSO.

This representation converts the path-planning problem into a finite-dimensional optimization problem.

## Objective Function

The objective function consists primarily of two terms.

### 1. Path Length

The Euclidean distances between neighboring path nodes are accumulated to evaluate the total flight distance.

### 2. Threat Exposure

For every path node, its distance to each threat source is calculated. The threat contribution decreases exponentially as the UAV moves farther away from the threat center.

The optimization therefore searches for a compromise between:

```text
shorter path  <->  lower threat exposure
```

A direct path may be short but pass through high-threat regions, whereas an excessively conservative path may substantially increase the travel distance.

## Requirements

- MATLAB
- No additional MATLAB toolbox is required by the core implementation.

The code was written as a research implementation and uses MATLAB scripts and functions directly.

## Getting Started

Clone the repository:

```bash
git clone https://github.com/libai1943/UAV-Path-Planning.git
cd UAV-Path-Planning
```

Open MATLAB and set the repository directory as the current working directory.

### Run the ABC Planner

Execute:

```matlab
runABC
```

The program performs the ABC optimization and displays the objective value during the iterations.

After optimization, a figure is generated showing:

- starting point;
- target point;
- threat centers and threat regions; and
- optimized UAV path.

### Run the PSO Planner

Execute:

```matlab
runPSO
```

This runs the PSO-based planner under a similar threat-field formulation and visualizes the resulting path.

> **Note:** In the current archived source code, `runABC.m` and `runPSO.m` contain `qwe` as their first line. If MATLAB reports `Unrecognized function or variable 'qwe'`, simply remove or comment out this line before running the scripts.

## Customizing the Scenario

The threat environment can be modified directly in the main scripts.

For example:

```matlab
radar1 = [...];     % x coordinates of threat centers
radar2 = [...];     % y coordinates of threat centers
R      = [...];     % threat radii
```

The starting and target positions, number of intermediate path nodes, population size, search bounds, and number of optimization iterations can also be adjusted in the corresponding scripts.

For ABC, important parameters include:

```matlab
NP          % colony size
maxCycle    % maximum number of iterations
limit       % abandonment limit
D           % number of path variables
```

For PSO, important parameters include:

```matlab
N           % swarm size
MaxDT       % maximum number of iterations
c1, c2      % learning factors
w           % inertia weight
D           % number of path variables
```

## Visualization

Circular threat regions are visualized using:

```matlab
cir_plot.m
```

The generated figures provide an intuitive view of how the optimization algorithm trades path length against proximity to threat sources.

## Citation

If this repository is useful for your research, please cite the associated work:

```text
Unmanned Combat Aerial Vehicles Path Planning Using a Novel Probability
Density Model Based on Artificial Bee Colony Algorithm.
```

Detailed publication information can be found in the papers included in this repository.

## License

This project is released under the **GNU General Public License v3.0 (GPL-3.0)**. See the [LICENSE](LICENSE) file for details.
