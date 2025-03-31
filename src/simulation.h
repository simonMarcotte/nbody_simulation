#pragma once

#include <vector>
#include "body.h"
#include <hip/hip_runtime.h>

// Updates the simulation state (positions and velocities) using HIP
void simulationUpdate(std::vector<nbody::Body>& bodies, float dt, float G, float eps);

