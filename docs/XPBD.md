# XPBD (Extended Position Based Dynamics)

## Problem

Classic PBD (Position Based Dynamics) corrects particle positions to satisfy constraints, but does not conserve energy. This causes:
- Energy loss (pendulum gradually stops)
- Or energy gain (simulation explodes)

## Solution: XPBD with Substeps

Instead of **1 frame with N constraint iterations**, we do **N substeps with 1 iteration each**. This improves energy conservation because velocity (implicit in Verlet) is updated consistently at each substep.

## Algorithm

```
For each frame:
  dt_sub = time_step / num_substeps

  For i = 1 to num_substeps:

    # 1. Verlet integration
    For each particle p (not fixed):
      velocity = p.current - p.old
      p.old = p.current
      p.current = p.current + velocity + p.acc * dt_sub²

    # 2. Constraint solving (1 iteration is enough with substeps)
    α̃ = compliance / dt_sub²

    For each rod constraint:
      delta = p2.current - p1.current
      length = |delta|
      n = delta / length                    # unit direction

      C = length - rest_length              # constraint error
      w = p1.invmass + p2.invmass           # sum of inverse masses

      Δλ = C / (w + α̃)                      # Lagrange multiplier

      # Position corrections
      p1.current += n * (Δλ * p1.invmass)   # p1 toward p2
      p2.current -= n * (Δλ * p2.invmass)   # p2 toward p1
```

## Key Parameters

| Parameter | Recommended Value | Description |
|-----------|-------------------|-------------|
| `num_substeps` | 16-32 | More = better stability and energy conservation |
| `compliance` | 0.0 | 0 = rigid, > 0 = elastic (e.g., 0.0001 for soft spring) |
| `time_step` | 1/60.0 (fixed) | Variable timestep breaks energy conservation |

## Implementation in MechaSimulator

### Modified Files

- `src/particle_system.rb`:
  - `next_step()`: substep loop
  - `verlet_substep(dt)`: Verlet integration
  - `satisfy_constraints_xpbd(dt)`: XPBD solving
  - `satisfy_rod_xpbd(c, alpha_tilde)`: distance constraint

- `src/main.rb`:
  - Fixed timestep (1/60s) instead of variable

- `config.rb`:
  - `:num_substeps` and `:compliance` parameters

### Important Notes

1. **Fixed timestep**: Verlet with variable timestep does not conserve energy
2. **Explicit copies**: `p.old = MVector.new(...)` to avoid shared references
3. **Check invmass**: Skip particles with `invmass == 0` (fixed particles)

## Energy Calculation

```ruby
# Kinetic energy
velocity = (p.current - p.old) / dt_sub
KE = 0.5 * mass * velocity²

# Potential energy (gravity)
PE = mass * g * z

# Total (should be ~constant)
E = KE + PE
```

## Springs vs Rods

MechaSimulator has two ways to connect particles:

| | Rod | Spring |
|---|---|---|
| **Type** | Position constraint (XPBD) | Force (Hooke's law) |
| **Behavior** | Maintains exact distance | Pulls proportional to stretch |
| **Equation** | Δx = C / (w + α̃) | F = k × (length - rest) |
| **Use case** | Rigid structures | Elastic, bouncy objects |
| **Color** | Red | Green |

Springs apply forces during `accumulate_forces()`, while rods adjust positions during `satisfy_constraints_xpbd()`.

## Limitations

- XPBD does not conserve energy perfectly (slight dissipation)
- More substeps = better conservation but more expensive
- Compliance = 0 can cause oscillations in some cases

## References

### Papers
- [XPBD: Position-Based Simulation of Compliant Constrained Dynamics](https://matthias-research.github.io/pages/publications/XPBD.pdf) - Macklin, Müller, Chentanez (2016)

### Tutorials
- [Ten Minute Physics - XPBD](https://matthias-research.github.io/pages/tenMinutePhysics/09-xpbd.pdf) - Matthias Müller
- [XPBD Explained](https://carmencincotti.com/2022-08-08/xpbd-extended-position-based-dynamics/) - Carmen Cincotti
- [The Distance Constraint](https://carmencincotti.com/2022-08-22/the-distance-constraint-of-xpbd/) - Carmen Cincotti

### Videos
- [Ten Minute Physics YouTube](https://www.youtube.com/c/TenMinutePhysics) - XPBD implementations in JavaScript
