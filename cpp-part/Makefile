# Define the name of your executable
TARGET = tema-dos

# Define the name of your source file
SOURCE = main.cpp

# Define the C++ compiler to use
CXX = g++

# Define compiler flags (e.g., -Wall for warnings, -std=c++11 for C++11 standard)
CXXFLAGS = -Wall -std=c++11 -O3 -march=native

# Default target: builds the executable
all: $(TARGET)

# Rule to build the executable from the source file
$(TARGET): $(SOURCE)
	$(CXX) $(CXXFLAGS) $(SOURCE) -o $(TARGET)

# Phony target for cleaning up generated files
.PHONY: clean
clean:
	rm -f $(TARGET)
