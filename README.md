# System Communication Toolbox

The system communication toolbox performs the engineering analysis
required for the coordination of communication networks under national
and international regulatory criteria with a focus on the
Radiocommunication Sector Space Services.

## Implementation

The system communicaiton toolbox is implemented in MATLAB, and as
such, a license for MATLAB is required to use the toolbox. No other
toolboxes provided by The Mathworks are, however, required for
calculating equivalent power flux density (EPFD) up, down, and
inter-satellite for comparison with Article 22 limits. Test coverage
is quite complete.

The system communication toolbox is also immplemented in Java,
however, some features, and test coverage is incomplete. Contributions
welcome!

## Documentation

Toolbox and relevant ITU documentation can be found in the "doc"
directory, and example simulation scripts can be found in the
"src/matlab/com/springbok/test" directory.

## Using the toolbox

To use the package, unzip the archive, then in MATLAB, navigate to the
resulting directory and add the toolbox to the MATLAB search path:

`>> addpath(genpath(‘src/matlab’);`

Run the example simulations and plot the results:

`>> MatlabExamples;`

Run the test suite:

`>> MatlabTestSuite;`

Run the tests in a directory:

`>> TestUtility.testDir('src/matlab/com/springbok/antenna');`

# Getting help

For help using MATLAB, The Mathworks provides excellent online
documentation at: http://www.mathworks.com/help/matlab/index.html.

For help using this toolbox contact Raymond LeClair at
raymond.leclair@springbok.io. For spectrum management and frequency
coordination services, or representation before national and
international regulatory entities, contact Roger LeClair at
roger@leclairtelecom.com.
