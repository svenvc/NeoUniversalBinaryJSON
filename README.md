# NeoUniversalBinaryJSON
An implementation of Universal Binary JSON (UBJSON) for Pharo.

[![Build Status](https://travis-ci.org/svenvc/NeoUniversalBinaryJSON.svg?branch=master)](https://travis-ci.org/svenvc/NeoUniversalBinaryJSON)

Universal Binary JSON (UBJSON) is a computer data interchange format. It is a binary form directly imitating JSON, but requiring fewer bytes of data. It aims to achieve the generality of JSON, combined with being easier and more efficient to process than JSON.

The size/speed/efficiency differences are minor for typical JSON payloads, especially compared with compacted JSON. The implementation is simpler, though, as there is no string escaping and no number parsing.

UBJSON is making a larger difference when dealing with arrays containing numbers. Especially with ByteArrays, BJSON makes a huge difference, since these are essentially stored natively.

See also

- http://ubjson.org
- https://en.wikipedia.org/wiki/UBJSON

## Usage

NeoUBJSONReader reads/parses a Universal Binary JSON stream. Use #on: to initialize it on a binary read stream and decode a value using #next. Its class side #fromByteArray: is convenient too.

NeoUBJSONWriter writes/generates a Universal Binary JSON stream. Use #on: to initialize it on a binary write stream and encode a value using #nextPut:. Its class side #toByteArray: is convenient too.

## Installation

This is a [Pharo Smalltalk](http://wwww.pharo.st) project 
using the [Tonel](https://github.com/pharo-vcs/tonel) source code format.

In Pharo 8 you can use Iceberg to load this project.

You can also load using the following expression:

    Metacello new
      baseline: 'NeoUniversalBinaryJSON';
      repository: 'github://svenvc/NeoUniversalBinaryJSON';
      load.
 
### Note about Pharo 7 Compatibility

For Pharo 7, prior to 7.0.5, you need to change the method NeoUBJSONWriter>>#writeInteger:ofSize:signed:bigEndian: so that it sends #digitAt: instead of #byteAt: 

Written and supported by Sven Van Caekenberghe. MIT Licensed.
