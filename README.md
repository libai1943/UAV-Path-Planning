# UAV Path Planning

MATLAB implementation for unmanned combat aerial vehicle (UCAV) path planning in a threat environment.

This repository provides the source code associated with:

**Unmanned Combat Aerial Vehicles Path Planning Using a Novel Probability Density Model Based on Artificial Bee Colony Algorithm**

The method represents threat sources using a continuous probability-density-based model and formulates path planning as an optimization problem considering both **flight distance** and **threat exposure**. An **Artificial Bee Colony (ABC)** algorithm is used for optimization, with a **Particle Swarm Optimization (PSO)** implementation included for comparison.

## Method Overview

The UAV flies from a predefined starting point to a target point through an environment containing multiple threat sources.

Each threat source is characterized by its location and effective threat radius. Rather than modeling threats only as hard geometric obstacles, the code evaluates threat continuously as a distance-dependent exponential function.

The objective mainly combines:

- geometric path length; and
- accumulated threat exposure.

### Artificial Bee Colony

`runABC.m` implements the Artificial Bee Colony algorithm. Candidate paths are treated as food sources and improved through employed-bee, onlooker-bee, and scout-bee stages.

### Particle Swarm Optimization

`runPSO.m` implements Particle Swarm Optimization under the same general path-planning framework for comparison with ABC.

## Repository Structure

```text
UAV-Path-Planning/
├── runABC.m              # Main Artificial Bee Colony path-planning program
├── runPSO.m              # Particle Swarm Optimization implementation
├── newexp.m              # Additional ABC experiment
├── calcu.m               # Objective-function evaluation for ABC
├── fitness.m             # Objective-function evaluation used by PSO
├── calculateFitness.m    # Converts objective values to ABC fitness values
├── cir_plot.m            # Visualization of circular threat regions
├── 1.mat                 # Experimental data
├── matlab.mat            # Experimental data
├── 2L UAV.pdf            # Related material
├── Hindawi_UCAV.pdf      # Related publication/material
├── UCAV 2013.pdf         # Related publication/material
├── README.md
└── LICENSE
```

## Path Representation

The horizontal distance between the starting point and target point is divided into a fixed number of intervals. The optimization variables determine the lateral coordinates of the intermediate path nodes:

```text
Start -> P1 -> P2 -> ... -> PN -> Target
```

A candidate path is represented as:

```matlab
path = [y1, y2, ..., yN];
```

The longitudinal coordinates are distributed along the start-to-target direction, while the lateral coordinates are optimized by ABC or PSO.

## Objective Function

The objective function mainly contains two components.

### 1. Path Length

The Euclidean distances between neighboring path nodes are accumulated to evaluate total flight distance.

### 2. Threat Exposure

For each path node, its distance to every threat source is calculated. Threat contribution decreases exponentially with distance from the corresponding threat center.

The planner therefore searches for a compromise between:

```text
shorter flight distance  <->  lower threat exposure
```

A direct path may be short but pass through high-threat regions, while an excessively conservative path may substantially increase flight distance.

## Requirements

- MATLAB

No additional third-party optimization library is required by the core implementation.

## Getting Started

Clone the repository:

```bash
git clone https://github.com/libai1943/UAV-Path-Planning.git
cd UAV-Path-Planning
```

Open MATLAB and set the repository directory as the current working directory.

### Run the ABC Planner

```matlab
runABC
```

The program reports the objective value during optimization and generates a figure showing:

- starting point;
- target point;
- threat centers;
- threat regions; and
- optimized UAV path.

### Run the PSO Planner

```matlab
runPSO
```

This runs the PSO-based planner under a similar path representation and threat-field formulation.

> **Note:** In the current archived source code, `runABC.m` and `runPSO.m` contain `qwe` as their first line. If MATLAB reports `Unrecognized function or variable 'qwe'`, remove or comment out this line before running the scripts.

## Customizing the Scenario

The threat environment can be modified directly in the main scripts:

```matlab
radar1 = [...];     % x coordinates of threat centers
radar2 = [...];     % y coordinates of threat centers
R      = [...];     % threat radii
```

The starting and target positions, number of intermediate path nodes, population size, search bounds, and number of optimization iterations can also be modified.

For ABC:

```matlab
NP          % colony size
maxCycle    % maximum number of iterations
limit       % abandonment limit
D           % number of path variables
```

For PSO:

```matlab
N           % swarm size
MaxDT       % maximum number of iterations
c1, c2      % learning factors
w           % inertia weight
D           % number of path variables
```

## Visualization

Circular threat regions are plotted using:

```matlab
cir_plot.m
```

The generated figures illustrate the trade-off between path length and proximity to threat sources.

## Citation

If you find this repository useful for your research, please cite:

> B. Li, L. Gong, and C. Zhao, "Unmanned combat aerial vehicles path planning using a novel probability density model based on artificial bee colony algorithm," in *2013 Fourth International Conference on Intelligent Control and Information Processing (ICICIP)*, IEEE, 2013, pp. 620–625.

### BibTeX

```bibtex
@inproceedings{li2013ucav,
  title={Unmanned combat aerial vehicles path planning using a novel probability density model based on artificial bee colony algorithm},
  author={Li, Bai and Gong, Liang and Zhao, Chao},
  booktitle={2013 Fourth International Conference on Intelligent Control and Information Processing (ICICIP)},
  pages={620--625},
  year={2013},
  organization={IEEE}
}
```

## License

This project is released under the **GNU General Public License v3.0 (GPL-3.0)**.

See the [LICENSE](LICENSE) file for details.
