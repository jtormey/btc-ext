const path = require('path')
const HtmlWebpackPlugin = require('html-webpack-plugin')

let resolve = (f) => path.resolve(__dirname, f)

module.exports = {
  entry: {
    main: resolve('src/index.js')
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
        oneOf: [
          {
            resourceQuery: /loadfile/,
            loader: 'file-loader',
            options: {
              name: '[name].[ext]'
            }
          },
          {
            use: 'json-loader'
          }
        ]
      },
      {
        test: /\.scss$/,
        use: ['style-loader', 'css-loader', 'sass-loader']
      },
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: 'elm-webpack-loader'
      },
      {
        test: /\.png$/,
        use: {
          loader: 'file-loader',
          options: {
            name: '[name].[ext]'
          }
        }
      }
    ]
  },
  plugins: [
    new HtmlWebpackPlugin({
      template: resolve('src/index.html')
    })
  ],
  devServer: {
    port: 8080
  }
}
