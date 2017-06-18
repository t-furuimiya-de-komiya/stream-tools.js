const {promisify} = require('util')

module.exports = {
    waitOnce, waitEnd,
    arrayFrom, bufferFrom,
    pipePromise,

    once: promisify(waitOnce),
    endOf: promisify(waitEnd),
    buffering: promisify(bufferFrom),
}

function waitOnce(ev, x, done)
{
    return x.once('error', done)
    .once(ev, (...args) => done.call(this, null, ...args))
}

function waitEnd(x, done)
{
    return waitOnce.call(this, 'end', x, done)
}

function arrayFrom(x)
{
    const ret = []
    x.on('data', val => ret.push(val))
    return ret
}

function bufferFrom(x, done)
{
    if (Buffer.isBuffer(x)) {
        done.call(this, null, x)
        return x
    }
    const bufs = arrayFrom(x)
    return waitEnd(x, err => done.call(this, err, Buffer.concat(bufs)))
}

function pipePromise(p, s)
{
    if (s instanceof Promise)
        [p, s] = [s, p]
    p.then(val => s.end(val))
    .catch(err => s.destroy(err))
    return s
}
