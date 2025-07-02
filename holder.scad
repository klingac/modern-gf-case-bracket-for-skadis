// OpenSCAD code for the Modern Gridfinity Case bracket for Skadis

// --- Global Parameters ---
base_width = 30;     // X-axis dimension (also width of the L-bracket extrusion)
base_height = 3;     // Z-axis dimension (thickness of the base segment)

// Parameters for the L-shaped brackets
bracket_thickness = 2;        // Thickness of the L-bracket's wall (material thickness)
vertical_arm_height = 55.5;     // Height of the vertical arm of the L-bracket (from the base_height upwards)
horizontal_arm_length = 20;    // Length of the horizontal lip of the L-bracket (extending outwards)
chamfer_offset = 6.3;           // The offset distance for the 45-degree inner chamfer from the sharp inner corner

// Parameters for the optional top arm (only for the last bracket)
top_arm_length = 15;          // Length of the top arm extending from the vertical arm (along Y-axis)
top_arm_thickness = 3;        // Thickness of the top arm (along Z-axis)

// Calculated footprint of the L-bracket along the Y-axis.
l_bracket_y_footprint = vertical_arm_height + bracket_thickness; 
l_bracket_x_footprint = horizontal_arm_length + bracket_thickness; 

// Number of bracket units to create
num_brackets = 3; 

// --- L-Bracket Module Definition ---
module l_bracket_component(is_last_bracket = false) {
    union() {
        points = [
            [0, 0], // P0: Bottom-left point of the overall L-bracket profile (on the base plane)
            [horizontal_arm_length + bracket_thickness, 0], // P1: Bottom-right point (end of horizontal arm at base level)
            [horizontal_arm_length + bracket_thickness, bracket_thickness], // P2: Top-right point of the horizontal arm (outer edge)
            [bracket_thickness + chamfer_offset, bracket_thickness], // P3: Point on the horizontal arm side of the 45-degree inner chamfer
            [bracket_thickness, bracket_thickness + chamfer_offset], // P4: Point on the vertical arm side of the 45-degree inner chamfer
            [bracket_thickness, vertical_arm_height + bracket_thickness], // P5: Top-right point of the vertical arm (inner edge)
            [0, vertical_arm_height + bracket_thickness] // P6: Top-left point of the entire L-bracket profile (outer edge of vertical arm)
        ];

        linear_extrude(height = base_width) { 
            polygon(points = points);
        }

        // Conditionally add the top arm if this is the last bracket
        if (is_last_bracket) {
            translate([0, vertical_arm_height - bracket_thickness/2 + top_arm_thickness, 0]) {
                cube(size = [l_bracket_x_footprint, bracket_thickness, base_width]);
            }
        }
    }
}

module single_bracket_assembly_unit(is_last_bracket = false) {
    union() {
        // 1. Create the "back wall" segment of the base.
        cube(size = [l_bracket_x_footprint, l_bracket_y_footprint+bracket_thickness, base_height]);

        // 2. Place the L-bracket component directly on top of this base segment.
        translate([0, 0, base_height]) {
            l_bracket_component(is_last_bracket = is_last_bracket);
        }
    }
}

// --- Main Assembly ---
for (i = [0 : num_brackets - 1]) {
    is_current_bracket_last = (i == num_brackets - 1);
    translate([0, i * l_bracket_y_footprint, 0]) {
        single_bracket_assembly_unit(is_last_bracket = is_current_bracket_last);
    }
}
