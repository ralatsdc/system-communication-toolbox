
TestUtility.testDir('src/matlab/com/springbok/antenna');
TestUtility.testDir('src/matlab/com/springbok/operator');
TestUtility.testDir('src/matlab/com/springbok/sgp4v');
TestUtility.testDir('src/matlab/com/springbok/simulation');
TestUtility.testDir('src/matlab/com/springbok/station');
TestUtility.testDir('src/matlab/com/springbok/system');
TestUtility.testDir('src/matlab/com/springbok/test');
TestUtility.testDir('src/matlab/com/springbok/twobody');
TestUtility.testDir('src/matlab/com/springbok/utility');

keyboard;

pool = gcp;

simulate_gso_leo.Simulate();
pause(1);
close all

TestUtility.testDir('src/matlab/com/springbok/pattern');
