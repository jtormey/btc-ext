const path = require('path')

let resolve = (f) => path.resolve(__dirname, f)

module.exports = {
  entry: {
    main: resolve('src/index.js'),
    background: resolve('src/background.js'),
    content: resolve('src/content.js')
  },
  output: {
    path: resolve('build'),
    filename: '[name].bundle.js'
  },
  resolve: {
    extensions: ['.js', '.elm']
  },
  module: {
    rules: [
      {
        test: /\.json$/,
        use: 'json-loader'
      },
      {
        test: /\.scss$/,
        use: ['style-loader', 'css-loader', 'sass-loader']
      },
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: 'elm-webpack-loader'
      }
    ]
  }
}
