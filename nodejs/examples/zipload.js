var JSZip = module.exports,
    zip = new JSZip(new Buffer(zipfile, 'base64')),
    pfs = process.binding('fs'),
    fs = require('fs'),
    mod = require('module'),
    path = require('path'),
    stream = require('stream'),
    orig_internalModuleStat = pfs.internalModuleStat,
    orig_internalModuleReadFile = pfs.internalModuleReadFile,
    orig_readFile = fs.readFile,
    orig_readFileSync = fs.readFileSync,
    orig_realpath = fs.realpath,
    orig_realpathSync = fs.realpathSync,
    orig_readdir = fs.readdir,
    orig_readdirSync = fs.readdirSync,
    orig_exists = fs.exists,
    orig_existsSync = fs.existsSync,
    orig_stat = fs.stat,
    orig_statSync = fs.statSync,
    orig_access = fs.access,
    orig_accessSync = fs.accessSync,
    orig_createReadStream = fs.createReadStream;

function normalize_path(p)
{
    return path.normalize(p.lastIndexOf('/', 0) == 0 ? p.substr(1) : p);
}

function get_obj(path, try_dir)
{
    var path2 = normalize_path(path),
        obj = zip.files[path2];
    if (try_dir && !obj)
    {
        path2 += '/';
        obj = zip.files[path2];
    }
    return obj;
}

function get_buf(obj, options)
{
    var buf = obj.asNodeBuffer();
    if (options)
    {
        if (typeof options == 'string')
        {
            return buf.toString(options);
        }
        else if (options.encoding)
        {
            return buf.toString(options.encoding)
        }
    }
    return buf;
}

pfs.internalModuleStat = function (path)
{
    //console.log("STAT", path);
    var obj = get_obj(path, true);
    return obj ? (obj.dir ? 1 : 0) : orig_internalModuleStat.apply(this, arguments);
};

pfs.internalModuleReadFile = function (path)
{
    //console.log("READ1", path);
    var obj = get_obj(path, false);
    return obj ? obj.asNodeBuffer() : orig_internalModuleReadFile.apply(this, arguments);
};

fs.readFileSync = function (path, options)
{
    //console.log("READ2", path);
    var obj = get_obj(path, false);
    if (obj)
    {
        return get_buf(obj, options);
    }
    return orig_readFileSync.apply(this, arguments);
};

fs.readFile = function (path, options, cb)
{
    //console.log("READ3", path);
    var obj = get_obj(path, false);
    if (obj)
    {
        if (!cb)
        {
            cb = options;
            options = undefined;
        }
        return cb(null, get_buf(obj, options));
    }
    return orig_readFile.apply(this, arguments);
};

fs.realpathSync = function (path)
{
    //console.log("REALPATH", path);
    var obj = get_obj(path, true);
    return obj ? path : orig_realpathSync.apply(this, arguments);
};

fs.realpath = function (path, cache, cb)
{
    //console.log("REALPATH2", path);
    var obj = get_obj(path, true);
    if (!obj)
    {
        return orig_realpath.apply(this, arguments);
    }
    if (!cb)
    {
        cb = cache;
    }
    cb(null, path);
};

function get_dir_names(obj)
{
    var folder = zip.folder(obj.name),
        names = [];
    folder.filter(function (name)
    {
        if (name && (name.indexOf('/') < 0))
        {
            names.push(name);
        }
        return false;
    });
    return names;
}

fs.readdirSync = function (path)
{
    //console.log("READDIR", path);
    var obj = get_obj(path, true);
    if (!obj)
    {
        return orig_readdirSync.apply(this, arguments);
    }
    return get_dir_names(obj);
};

fs.readdir = function (path, cb)
{
    //console.log("READDIR2", path);
    var obj = get_obj(path, true);
    if (!obj)
    {
        return orig_readdir.apply(this, arguments);
    }
    cb(null, get_dir_names(obj));
};

fs.existsSync = function (path)
{
    //console.log("EXISTS", path);
    return get_obj(path, true) ? true : orig_existsSync.apply(this, arguments);
};

fs.exists = function (path, cb)
{
    //console.log("EXISTS2", path);
    var obj = get_obj(path, true);
    if (!obj)
    {
        return orig_exists.apply(this, arguments);
    }
    cb(true);
};

function stats(obj)
{
    return {
        _obj: obj,
        get mode() { return this._obj.unixPermissions; },
        get atime() { return this._obj.date; },
        get mtime() { return this._obj.date; },
        get ctime() { return this._obj.date; },
        get birthtime() { return this._obj.date },
        get size() { return this._obj.asNodeBuffer().length; },
        get ino() { return -1; },
        isFile: function () { return !this._obj.dir; },
        isDirectory: function () { return this._obj.dir; },
        isBlockDevice: function () { return false; },
        isCharacterDevice: function () { return false; },
        isSymbolicLink: function () { return false; },
        isFIFO: function () { return false; },
        isSocket: function () { return false; }
    };
}

fs.stat = function (path, cb)
{
    //console.log("FSSTAT", path);
    var obj = get_obj(path, true);
    if (!obj)
    {
        return orig_stat.apply(this, arguments);
    }
    cb(null, stats(obj));
};

fs.statSync = function (path, cb)
{
    //console.log("FSSTATSYNC", path);
    var obj = get_obj(path, true);
    if (!obj)
    {
        return orig_statSync.apply(this, arguments);
    }
    return stats(obj);
};

fs.access = function (path, mode, cb)
{
    //console.log("ACCESS", path);
    var obj = get_obj(path, true);
    if (!obj)
    {
        return orig_access.apply(this, arguments);
    }
    if (!cb)
    {
        cb = mode;
    }
    cb();
};

fs.accessSync = function (path)
{
    //console.log("ACCESSSYNC", path);
    var obj = get_obj(path, true);
    if (!obj)
    {
        return orig_accessSync.apply(this, arguments);
    }
};

fs.lstat = fs.stat;
fs.lstatSync = fs.statSync;

fs.createReadStream = function (path, options)
{
    //console.log("CREATEREADSTREAM", path);
    var obj = get_obj(path, false);
    if (!obj)
    {
        return orig_createReadStream.apply(this, arguments);
    }
    options = options || {};
    var buf = get_buf(obj, options),
        s = new stream.PassThrough();
    s.end(buf.slice(options.start || 0, options.end || buf.length));
    return s;
};

process.argv[1] = main;
mod.runMain();
