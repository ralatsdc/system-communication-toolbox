
TestUtility.testDir('src/matlab/com/springbok/antenna');
TestUtility.testDir('src/matlab/com/springbok/operator');
TestUtility.testDir('src/matlab/com/springbok/sgp4v');
TestUtility.testDir('src/matlab/com/springbok/station');
TestUtility.testDir('src/matlab/com/springbok/system');
TestUtility.testDir('src/matlab/com/springbok/twobody');
TestUtility.testDir('src/matlab/com/springbok/utility');

disp(' ')
disp('Hit return to test patterns ...')
disp(' ')
disp('This may take a few minutes ...')
disp(' ')
pause();
TestUtility.testDir('src/matlab/com/springbok/pattern');
