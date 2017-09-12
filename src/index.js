import '../manifest.json?loadfile'
import './style/main.scss'
import * as labels from './js/labels'
import { setupPorts as setupBitcoinPorts } from './js/bitcoin'

// xpub6DX2ZjB6qgNGPuGobYQbpwXHrn7zue1xWSpg29cw6HxovCE9F4iHqEzjnhXk1PbKrfVGwMMrgQv7Q1wWDDBYzx85C8dsvD6jqc49U2PYstx

let Elm = require('./elm/Main')
let app = Elm.Main.embed(document.getElementById('main'))

setupBitcoinPorts(app.ports)

app.ports.set.subscribe((data) => {
  let [key, value] = data.split(',')
  localStorage.setItem(key, value)
})

app.ports.get.subscribe((key) => {
  let value = localStorage.getItem(key)
  app.ports.storage.send([key, value].join(','))
})

app.ports.remove.subscribe((key) => {
  localStorage.removeItem(key)
})

app.ports.save.subscribe((data) => {
  let [index, label] = data.split(',')
  labels.save({ index: parseInt(index), label })
})

app.ports.readLabels.subscribe(() => {
  let labelsStr = JSON.stringify(labels.read())
  app.ports.readResponse.send(labelsStr)
})

app.ports.lastIndex.send(labels.lastIndex())
