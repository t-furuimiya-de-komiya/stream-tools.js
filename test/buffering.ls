require! './test.ls': {expect}
require! '..': stools
require! stream


suite \buffering


test 'pass Buffer' ->
    buf = Buffer.from \abc
    expect stools.buffering buf
    .to.become buf

test 'pass stream (succeed)' ->
    s = new stream.PassThrough
    s.write \abc
    s.end \def
    expect stools.buffering s
    .to.become Buffer.from \abcdef

test 'pass stream (error)' ->
    s = new stream.PassThrough
    s.write \abc
    s.destroy new Error \error
    expect stools.buffering s
    .to.be.rejected-with /^error$/
