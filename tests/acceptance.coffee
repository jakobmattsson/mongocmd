async = require 'async'
jscov = require 'jscov'
chai = require 'chai'
sinon = require 'sinon'
sinonChai = require 'sinon-chai'
mongojs = require 'mongojs'

chai.use sinonChai
expect = chai.expect

mongocmd = require jscov.cover('..', 'src', 'mongocmd')

describe 'mongocmd', ->

  data = [
    { v: 1, name: 'jakob' }
    { v: 2, name: 'foo' }
    { v: 3, name: 'bar' }
  ]

  insertData = (db, callback) ->
    db.coll1.remove {}, ->
      async.forEach data, (entry, callback) ->
        db.coll1.insert(entry, callback)
      , callback

  [true, false].forEach (verbose) ->

    it "runs full circle with verbosity set to #{verbose}", (done) ->
      dumpconf = {
        verbose
        host: 'localhost'
        db: 'mongocmd-testdb'
        outdir: 'backupdir'
      }
      restoreconf = {
        verbose
        host: 'localhost'
        db: 'restored'
        outdir: 'backupdir/mongocmd-testdb'
      }

      db = mongojs('mongocmd-testdb', ['coll1'])

      insertData db, ->

        mongocmd.dump dumpconf, (err) ->
          expect(err).to.not.exist

          mongocmd.restore restoreconf, (err) ->
            expect(err).to.not.exist

            db2 = mongojs('restored', ['coll1'])

            db2.coll1.find (err, docs) ->
              expect(err).to.not.exist
              expect(docs).to.have.length 3
              expect(docs.map (x) -> x.v).to.eql [1,2,3]
              done()
