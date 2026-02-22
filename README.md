# Advanced-4D-Data-Visualization-Analysis-Tool
Scientist Data Suite | Advanced 4D Data Visualization &amp; Analysis Tool
Scientist Data Suite | Advanced 4D Data Visualization & Analysis Tool
A comprehensive MATLAB application for multi-dimensional data visualization, statistical analysis, and biomarker discovery

Author: Muralidharan Mani

📋 Table of Contents
Overview

Key Features

System Requirements

Installation Guide

Quick Start

Detailed User Guide

Visualization Types

Statistical Analysis

Data Processing

Export Options

Example Workflows

Troubleshooting

Citation

License

🔬 Overview
Scientist Data Suite is a powerful MATLAB-based interactive application designed for researchers and data scientists who need to explore, visualize, and analyze complex datasets. The tool excels at handling multi-dimensional data with intuitive controls for mapping variables to visual properties (X, Y, group, size, color) and supports a wide range of plot types from simple scatter plots to complex 4D visualizations and IC50 curve fitting.

Built with a clean, professional interface, this application streamlines the data analysis workflow from import to publication-quality exports.

✨ Key Features
Feature Category	Capabilities
Data Import	Multi-file Excel/CSV import, sheet selection, range selection, data preview
Data Processing	Z-score normalization, Min-Max scaling, outlier filtering, data subsetting
Visualization	4D scatter plots, multi-X/Y tiled plots, line charts, bar charts, box plots, heatmaps, IC50 curve fitting
Layout Options	Tiled display, overlay mode, configurable tile limits
Statistical Analysis	Correlations, Mann-Whitney, ANOVA, Dunnett's test, Chi-square, multi-variable correlation
Export	TIFF (300 DPI), PNG (300 DPI), PDF (vector)
💻 System Requirements
MATLAB R2024b or newer (requires Statistics and Machine Learning Toolbox for some statistical functions)

Operating System: Windows, macOS, or Linux

Memory: Minimum 4GB RAM (8GB+ recommended for large datasets)

Display: 1280x720 or higher resolution

Required Toolboxes
Statistics and Machine Learning Toolbox (for advanced statistics and curve fitting)

MATLAB base system

📦 Installation Guide
Step 1: Save the Application
Save the DataVisualizationApp1.m class definition file to your MATLAB working directory.

Step 2: Launch the Application
In the MATLAB command window, type:

matlab
app = DataVisualizationApp1();
The application window will open with a split-panel interface:

Left panel: Analysis controls (scrollable)

Right panel: Visualization canvas

Bottom bar: Status display

🚀 Quick Start
Basic Workflow in 5 Steps:
Import Data: Click "Import Excel/CSV (Multi-file)" and select your data files

Select Dataset: Choose from the File ListBox

Map Variables:

Select X variable(s) (Ctrl+Click for multiple)

Select Y variable(s) (Ctrl+Click for multiple)

Optional: Choose Group, Size, Color variables

Choose Plot Type: Select from the Graph Type dropdown

Explore: Interact with the visualization, adjust parameters

📖 Detailed User Guide
1. Data Import Panel
Import Button
Click to select one or more Excel (.xlsx) or CSV (.csv) files

For Excel files, all sheets are automatically loaded

Files appear in the File ListBox with generated variable names

File ListBox
Shows all imported datasets

Click to switch between datasets

Active dataset highlighted

Sheet DropDown
For multi-sheet Excel files, select which sheet to analyze

Automatically enabled for files with multiple sheets

Control Buttons
Preview: Opens a new figure showing first 80 rows of data

Select Range: Opens interactive range selector for subsetting data

Refresh Vars: Updates variable lists after data changes

2. Data Preprocessing
Normalization Options
None: Raw data

Z-score (Y): (value - mean) / standard deviation

Min-Max (Y): (value - min) / (max - min)

Outlier Filter
Set SD threshold (0 = disable)

Filters based on first selected Y variable

Removes points beyond n × standard deviation from mean

3. Variable Mapping
Control	Description	Multi-Select
X Axis	Independent variable(s)	✓ (Ctrl+Click)
Y Axis	Dependent variable(s)	✓ (Ctrl+Click)
Group By	Categorical variable for grouping	✗
Bubble Size	Numeric variable for point scaling	✗
Bubble Color	Numeric variable for color mapping	✗
Colormap	Color scheme for mapped data	✗
4. Multi-Plot Controls
Multi-Plot Mode: Tiled (separate axes) or Overlay (single axis)

Max Tiles: Safety cap for number of subplots (1-36)

📊 Visualization Types
1. Scatter (4D) [single X,Y]
Basic scatter plot with up to 4 dimensions:

X position: First selected X variable

Y position: First selected Y variable

Point size: Optional Size variable (rescaled 20-500)

Point color: Optional Color variable (color-mapped)

Group colors: Optional Group variable (categorical)

2. Multi-X Scatter [Y fixed]
Multiple scatter plots with same Y, different X variables

Tiled mode: Separate plots per X variable

Overlay mode: All X variables on same plot

3. Multi-Y Scatter [X fixed]
Multiple scatter plots with same X, different Y variables

Useful for comparing multiple responses to same predictor

4. Line (Time Series) [X fixed]
Line plots with markers

Ideal for time course or sequential data

Multiple Y variables supported

5. Bar Chart
Mean values with optional error bars (SEM)

Supports grouping and multi-Y tiled displays

6. Box Plot
Distribution visualization with quartiles

Grouped or ungrouped options

7. Heatmap [Y vars]
Color-coded matrix of Y variables

Automatic normalization options

Interactive color mapping

8. IC50 Fit (4PL) [single X,Y]
4-parameter logistic curve fitting

Requires X > 0 (typically concentration data)

Calculates IC50 and Hill slope

Uses nlinfit (Statistics Toolbox required)

📈 Statistical Analysis
Available Tests
Test	Description	Requirements
Pearson Correlation	Linear correlation between X1 and Y1	Numeric variables
Spearman Correlation	Rank-based correlation	Numeric variables
Mann-Whitney	Nonparametric two-group comparison	Group variable + Y1
One-way ANOVA	Multiple group comparison	Group variable + Y1
Dunnett's Test	Multiple comparison vs control	Group variable + Y1 + Control group selection
Chi-Square	Independence test	X1 (categorical) + Group
Multi-variable Correlation	Correlation matrix of all Y variables	Multiple numeric Y variables
Running Statistics
Set up your variables (X, Y, Group as needed)

Select statistical test from dropdown

For Dunnett's test, select control group

Click "Run Stats"

Results appear in dialog box

🔧 Data Processing
Range Selection Tool
Click "Select Range"

Interactive table shows first 150 rows

Click and drag to select cells

Or manually enter row/column ranges

Click "Apply Selection" to subset data

Outlier Filtering
Based on mean ± (threshold × SD) of first Y variable

Removes extreme values from all variables

Useful for cleaning noisy datasets

💾 Export Options
Formats
TIFF (300 dpi): Publication-quality raster images

PNG (300 dpi): Web-friendly raster images

PDF (vector): Scalable vector graphics

Export Process
Create your desired visualization

Select export format

Click "Export Plot"

Choose filename and location

Plot saved with 300 DPI resolution

📝 Example Workflows
Workflow 1: Dose-Response Analysis
text
1. Import dose-response data (concentration vs response)
2. Set X = Concentration, Y = Response
3. Select Graph Type = "IC50 Fit (4PL)"
4. View fitted curve and IC50 value
5. Export as TIFF for publication
Workflow 2: Multi-Parameter Comparison
text
1. Import experimental data with multiple measurements
2. Select multiple Y variables (Ctrl+Click)
3. Choose X variable (e.g., Time or Treatment)
4. Set Graph Type = "Multi-Y Scatter [X fixed]"
5. Select "Tiled" layout
6. Compare patterns across parameters
Workflow 3: Group Comparison with Statistics
text
1. Import data with group labels
2. Set Y = Measurement variable
3. Set Group By = Treatment group
4. Choose Graph Type = "Box Plot"
5. Run Stats: Select "One-way ANOVA"
6. Identify significant differences
Workflow 4: 4D Data Exploration
text
1. Import multi-parametric data
2. Set X, Y variables
3. Set Size variable (e.g., concentration)
4. Set Color variable (e.g., time point)
5. Select Graph Type = "Scatter (4D)"
6. Explore patterns in 4 dimensions
🛠️ Troubleshooting
Common Issues and Solutions
Problem	Possible Cause	Solution
"No data loaded" error	No dataset selected	Import data and select from File ListBox
Empty plot	Variables not selected	Check X and Y listbox selections
IC50 fit fails	X values not positive	Ensure X > 0 (log scale requirement)
Stats Toolbox error	Missing toolbox	Install Statistics and Machine Learning Toolbox
Heatmap shows nothing	No numeric Y variables	Select at least one numeric Y variable
Group dropdown empty	No categorical variables	Select variable with groups/categories
Outlier filter not working	Threshold too high/low	Adjust spinner value (try 2-3 for normal data)
Slow performance	Too many tiles	Reduce Max Tiles setting
Export fails	File permissions	Check write access to destination folder
Validation Checklist
✓ Data file imported successfully

✓ At least one X and one Y variable selected

✓ For grouped plots: Group variable selected

✓ For IC50: X > 0, at least 4 points

✓ For heatmap: Multiple numeric Y variables

✓ For statistics: Appropriate variable types selected

📋 MATLAB Version Compatibility
This application is designed for MATLAB R2024b and uses:

uifigure for modern UI components

uigridlayout for responsive layouts

tiledlayout for multi-plot displays

heatmap for matrix visualizations

For earlier MATLAB versions, some features may not be available.

📝 Citation
If you use this tool in your research, please cite:

text
Mani, M. (2024). Scientist Data Suite: Advanced 4D Data Visualization 
and Analysis Tool for MATLAB. GitHub repository.
BibTeX entry:

bibtex
@software{mani2024scientist,
  author = {Mani, Muralidharan},
  title = {Scientist Data Suite: Advanced 4D Data Visualization and Analysis Tool for MATLAB},
  year = {2024},
  publisher = {GitHub},
  url = {https://github.com/[username]/scientist-data-suite}
}
📄 License
This project is licensed under the MIT License - see the LICENSE file for details.

📧 Contact
Author: Muralidharan Mani

For questions, bug reports, or feature requests, please open an issue on GitHub or contact the author directly.

🙏 Acknowledgments
MATLAB Development Team at MathWorks

Contributors to the Statistics and Machine Learning Toolbox

Beta testers and collaborators who provided valuable feedback

🔄 Version History
Version	Date	Changes
1.0.0	2024	Initial release with core functionality
1.1.0	2024	Added multi-select for X/Y, tiled layouts
1.2.0	2024	Added IC50 fitting, heatmap, export options
Happy data exploration! 📊🔬✨

