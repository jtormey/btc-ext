import '../manifest.json?loadfile'
import './style/main.scss'
import { setupPorts as setupBitcoinPorts } from './js/bitcoin'
import { setupPorts as setupLabelsPorts } from './js/labels'
import { setupPorts as setupStoragePorts } from './js/storage'

// xpub6DX2ZjB6qgNGPuGobYQbpwXHrn7zue1xWSpg29cw6HxovCE9F4iHqEzjnhXk1PbKrfVGwMMrgQv7Q1wWDDBYzx85C8dsvD6jqc49U2PYstx

let Elm = require('./elm/Main')
let app = Elm.Main.embed(document.getElementById('main'))

setupBitcoinPorts(app.ports)
setupLabelsPorts(app.ports)
setupStoragePorts(app.ports)
