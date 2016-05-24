'use strict'

git = require '../git'
pathUtils = require 'path'
{Heading, ProgramCode, Paragraph, headingToUrl} = require '../markdown'

URL_PREFIX = '/Neft-io/neft/blob/'

exports.prepareFileToSave = (file, path) ->
    fileCommit = git.getFileCommitSync './', path
    heading = null
    for type, i in file
        if type instanceof Heading and type.getLevel() <= 4
            heading = type
        else if type instanceof ProgramCode
            url = pathUtils.join URL_PREFIX, fileCommit, '/', path
            if heading?
                url += headingToUrl heading.text
            text = "> [`Source`](#{url})\n"
            file[i] = new Paragraph type.line, text

    return