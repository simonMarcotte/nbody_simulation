
HIPCC       = hipcc # I use a custom .bat script for this

HIP_FLAGS   = --offload-arch=gfx1101 # For AMD RADEON 7800xt
CXXFLAGS    = -Wall -g -I$(GLFW_INCLUDE)

# Path to GLFW include files (cloned locally)
GLFW_INCLUDE = C:/projects/download_packages/glfw/include # might need to change this
GLFW_LIB_DIR = C:/projects/download_packages/glfw/build/src
GLFW_LIB   = $(GLFW_LIB_DIR)/libglfw3.a

SRC_DIR     = src
SRCS        = $(wildcard $(SRC_DIR)/*.cu)
OBJS        = $(SRCS:.cu=.o)

TARGET      = nbodysim.exe

# Default target
all: $(TARGET)

# Link the object files to create the executable
$(TARGET): $(OBJS)
	$(HIPCC) $(HIP_FLAGS) $(OBJS) $(GLFW_LIB) -lopengl32 -luser32 -lgdi32 -lshell32 -lmsvcrt -llegacy_stdio_definitions -o $(TARGET)


# Compile each .cu file into an object file
$(SRC_DIR)/%.o: $(SRC_DIR)/%.cu
	$(HIPCC) $(HIP_FLAGS) $(CXXFLAGS) -c $< -o $@

# Clean up build files
clean:
	rm -rf src/*.o nbodysim.exe

