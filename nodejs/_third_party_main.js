var path = require('path'),
    mod = require('module'),
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

if (process.argv[1])
{
    mod.runMain();
}
else
{
    require('rumpmain');
}
