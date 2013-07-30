childProcess = require 'child_process'

exports.dump = ({host, db, username, password, outdir, verbose}, callback) ->

  args = [
    '--host', host
    '--db', db
    '--username', username
    '--password', password
    '--out', outdir
  ]
  dump = childProcess.spawn('mongodump', args)

  dump.stdout.on 'data', (data) ->
    process.stdout.write(data.toString()) if verbose

  dump.stderr.on 'data', (data) ->
    process.stdout.write(data.toString()) if verbose

  dump.on 'exit', (code) ->
    return callback("Process mongodump failed") if code != 0
    callback()


exports.restore = ({host, db, username, password, outdir, verbose}, callback) ->

  args = [
    '--drop'
    '--host', host
    '--db', db
  ]

  if username
    args.push('--username')
    args.push(username)

  if password
    args.push('--password')
    args.push(password)

  args.push(outdir)

  dump = childProcess.spawn('mongorestore', args)

  dump.stdout.on 'data', (data) ->
    process.stdout.write(data.toString()) if verbose

  dump.stderr.on 'data', (data) ->
    process.stdout.write(data.toString()) if verbose

  dump.on 'exit', (code) ->
    return callback("Process mongorestore failed") if code != 0
    callback()
