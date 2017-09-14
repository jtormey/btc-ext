import '../manifest.json?loadfile'
import './style/main.scss'
import { setupPorts as setupBitcoinPorts } from './js/bitcoin'
import { setupPorts as setupLabelsPorts } from './js/labels'

// xpub6DX2ZjB6qgNGPuGobYQbpwXHrn7zue1xWSpg29cw6HxovCE9F4iHqEzjnhXk1PbKrfVGwMMrgQv7Q1wWDDBYzx85C8dsvD6jqc49U2PYstx

let Elm = require('./elm/Main')
let app = Elm.Main.embed(document.getElementById('main'))

setupBitcoinPorts(app.ports)
setupLabelsPorts(app.ports)

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
