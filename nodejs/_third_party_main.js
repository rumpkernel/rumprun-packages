var path = require('path'),
    fs = require('fs'),
    mod = require('module'),
    dir = path.dirname(process.argv[0]),
    orig_load = mod._load;

mod._load = function (id)
{
    if (path.extname(id) === '.node')
    {
        try
        {
            return process._linkedBinding(path.basename(id, '.node'));
        }
        catch (ex)
        {
        }
    }
    return orig_load.apply(this, arguments);
};

fs.stat(dir, function (err, stats)
{
    if (stats && stats.isDirectory())
    {
        process.chdir(dir);
    }

    if (process.argv.length == 1)
    {
        process.argv.push('rumpmain');
    }

    mod.runMain();
});
