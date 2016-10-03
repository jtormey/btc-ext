
let config = {
  entry: './src/index.js',
  output: {
    path: 'build',
    filename: 'bundle.js'
  },
  resolve: {
    modulesDirectories: ['node_modules'],
    extensions: ['', '.js', '.elm']
  },
  loaders: [{
    test: /\.scss$/,
    loader: ['style', 'css', 'sass']
  }],
  module: {
    loaders: [{
      test: /\.json$/,
      loader: 'json'
    }, {
      test: /\.elm$/,
      exclude: [/elm-stuff/, /node_modules/],
      loader: 'elm-webpack'
    }]
  }
}

module.exports = config
