<?php
// Runs in PHP7, not PHP5
// Coercive mode
function sumOfInts(int ...$ints)
{
    return array_sum($ints);
}

?><html>
<body style="font-size: 14pt;">
    <img src="static/logo150.png"/>
    Hello, <?php echo $_SERVER['REMOTE_ADDR']; ?>
    <p>
    It is now <?php echo date(DATE_RFC2822); ?>
    <p>
    Welcome to PHP<?php echo sumOfInts(1, '2', 4); ?>
    <a href="http://php.net/">PHP</a>,
    running on a
    <a href="http://rumpkernel.org">rump kernel</a>...
    <p>
    Try <a href="phpinfo.php">phpinfo()</a>.
</body>
</html>
