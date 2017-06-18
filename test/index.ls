require! './test.ls': {expect}
require! '..': stools
require! stream


suite \#once

test \error ->
    s = new stream.PassThrough
    s.destroy new Error \error
    expect stools.once \data, s
    .to.be.rejected-with /^error/

test \data ->
    s = new stream.PassThrough
    s.write \abc
    s.destroy new Error \error
    expect stools.once \data, s
    .to.become Buffer.from \abc

test 'other event (response)' ->
    s = new stream.PassThrough
    p = stools.once \response, s
    s.emit \response, 42, [1 2 3]
    expect p
    .to.become 42


suite \#endOf

test \error ->
    s = new stream.PassThrough
    s.destroy new Error \error
    expect stools.end-of s
    .to.be.rejected-with /^error$/

test \success ->
    s = new stream.PassThrough
    s.on \data ->
    s.end!
    expect stools.end-of s
    .to.be.fulfilled


suite \#arrayFrom

test \arrayFrom ->
    s = new stream.PassThrough {+object-mode}
    arr = stools.array-from s
    expect arr .to.eql []
    s.write 1
    expect arr .to.eql [1]
    s.write 2
    expect arr .to.eql [1 2]
    s.write 42
    expect arr .to.eql [1 2 42]


suite \#pipePromise

test \success ->
    s = new stream.PassThrough
    expect stools.once \data, stools.pipe-promise s, Promise.resolve \abc
    .to.become Buffer.from \abc

test \error ->
    s = new stream.PassThrough
    expect stools.once \data, stools.pipe-promise s, Promise.reject new Error \abc
    .to.be.rejected-with /^abc$/
