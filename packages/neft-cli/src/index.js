const { parseArgv } = require('./argv-parser')
const { initialize } = require('./initializer')
const { build } = require('./builder')
const { run } = require('./runner')
const { clean } = require('./cleaner')

module.exports = async (argv) => {
  const { operation, target, args } = parseArgv(argv)
  if (operation === 'init') {
    initialize()
  }
  if (operation === 'build' || operation === 'run') {
    try {
      await build(target, args)
    } catch (error) {
      console.error(error.message)
      process.exit(1)
    }
  }
  if (operation === 'run') {
    run(target)
  }
  if (operation === 'clean') {
    clean()
  }
}
