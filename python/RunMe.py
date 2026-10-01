"""Run a toy path-planning example and display the path and convergence."""
import argparse
from pathlib import Path
import numpy as np
from planner import Scenario, optimize


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--algorithm', choices=['abc', 'pso'], default='abc')
    parser.add_argument('--iterations', type=int, default=500)
    parser.add_argument('--seed', type=int, default=1)
    parser.add_argument('--output', type=Path, default=Path(__file__).resolve().parent / 'results')
    parser.add_argument('--no-show', action='store_true')
    args = parser.parse_args()
    if args.iterations < 1:
        parser.error('--iterations must be positive')
    if args.no_show:
        import matplotlib
        matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    from matplotlib.patches import Circle
    scenario = Scenario()
    path, history = optimize(scenario, args.algorithm, args.iterations, args.seed)
    xy = np.column_stack((np.linspace(0, 500, scenario.dimension + 2), np.r_[0, path, 0]))
    args.output.mkdir(parents=True, exist_ok=True)
    np.savetxt(args.output / 'path.csv', xy, delimiter=',', header='x,y', comments='')
    np.savetxt(args.output / 'convergence.csv', np.column_stack((np.arange(1, len(history)+1), history)), delimiter=',', header='iteration,cost', comments='')
    fig, ax = plt.subplots(figsize=(11, 5), layout='constrained')
    x, y = np.meshgrid(np.linspace(0, 500, 501), np.linspace(-80, 80, 161))
    field = sum(np.exp(-np.hypot(x-tx, y-ty)*np.log(20)/radius) for tx, ty, radius in scenario.threats)
    contour = ax.contourf(x, y, field, 30, cmap='YlOrRd', alpha=.7)
    fig.colorbar(contour, ax=ax, label='Synthetic risk-field intensity')
    for tx, ty, radius in scenario.threats:
        ax.add_patch(Circle((tx, ty), radius, fill=False, color='#7d6253', alpha=.35, lw=.7))
    ax.plot(xy[:, 0], xy[:, 1], color='#075985', lw=2, marker='.', markersize=4, label=args.algorithm.upper())
    ax.scatter([0, 500], [0, 0], c=['#008468', '#1e293b'], s=55, zorder=5)
    ax.set(xlim=(-5, 505), ylim=(-80, 80), xlabel='x', ylabel='y', title=f'{args.algorithm.upper()} path · discrete cost = {history[-1]:.6f}')
    ax.set_aspect('equal'); ax.legend()
    fig.savefig(args.output / 'path.png', dpi=160)
    fig2, ax2 = plt.subplots(figsize=(8, 4), layout='constrained')
    ax2.plot(np.arange(1, len(history)+1), history, color='#075985')
    ax2.set(xlabel='Iteration', ylabel='Best-so-far discrete cost', title='Convergence')
    ax2.grid(alpha=.2); fig2.savefig(args.output / 'convergence.png', dpi=160)
    print(f'{args.algorithm.upper()}: cost={history[-1]:.10f}; output={args.output}')
    if not args.no_show:
        plt.show()
    plt.close('all')


if __name__ == '__main__':
    main()
