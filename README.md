Signal Transformation App

A MATLAB GUI application for exploring continuous-time signal transformations, including time shifting, time scaling, and time reversal. It displays the original and transformed signals for easy visual comparison.

Features

- Built-in signals: Unit Step, Impulse, Ramp, Signum, Triangular, and Rectangular.
- Custom signal equations: Enter and plot your own signal using "t" as the independent variable.
- Time scaling: Adjust the scaling factor.
- Time shifting: Shift the signal using an interactive slider.
- Time reversal: Enable or disable time reversal with a checkbox.
- Signal visualization: Compare original and transformed waveforms.
- Signal information: View the time range, sample count, and sampling interval.
- Reset and export: Reset the settings and export plots to PNG, JPG, or PDF.

Requirements

- MATLAB with support for the UI components used by the application.
- No third-party MATLAB toolboxes are intentionally required.

Note: This is a MATLAB source-code project, not a standalone Windows executable. A compatible MATLAB installation is required to run it.

Installation and Usage

1. Download this repository using Code → Download ZIP, or clone it:
   
   git clone https://github.com/edurgamadhav-beep/Signal-Transformation-App.git

2. Extract the ZIP file if downloaded.

3. Open MATLAB.

4. Set MATLAB's Current Folder to the extracted project directory.

5. In the MATLAB Command Window, execute:
   
   RunSignalTransformApp

6. The Signal Transformation App window should open.

Alternatively, open "RunSignalTransformApp.m" in the MATLAB Editor and click Run.

Project Structure

File| Description
"SignalTransformApp.m"| Main GUI class and signal transformation logic
"RunSignalTransformApp.m"| Launcher script
"README.md"| Project documentation

Custom Signal Examples

Enter a MATLAB expression using "t" as the independent variable.

sin(2*pi*t)
cos(t)
exp(-t.^2)
sin(2*pi*t).*exp(-0.2*abs(t))

Use element-wise operators such as ".*", "./", and ".^" for vector calculations.

Security: Custom expressions are evaluated by MATLAB. Only enter expressions you understand and trust.

Applications

This project can be used for:

- Digital signal processing demonstrations.
- Understanding continuous-time signal transformations.
- MATLAB laboratory exercises.
- Engineering coursework and self-learning.

Troubleshooting

The app does not launch: Ensure both ".m" files are in the current project directory. Then run "RunSignalTransformApp" in the MATLAB Command Window.

A custom equation fails: Check the expression's syntax, parentheses, and element-wise operators.

The app displays an error: Review the complete MATLAB error message and check compatibility with your MATLAB version.

Contributing

Suggestions, bug reports, and improvements are welcome. When reporting an issue, include the MATLAB version and steps to reproduce the problem.

License

No license has been selected for this repository yet. Add a suitable open-source license before explicitly permitting others to reuse, modify, or redistribute the code.
