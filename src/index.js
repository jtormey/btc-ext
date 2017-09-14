import '../manifest.json?loadfile'
import './style/main.scss'
import { setupPorts as setupBitcoinPorts } from './js/bitcoin'
import { setupPorts as setupLabelsPorts } from './js/labels'
import { setupPorts as setupStoragePorts } from './js/storage'

let Elm = require('./elm/Main')
let app = Elm.Main.embed(document.getElementById('main'))

setupBitcoinPorts(app.ports)
setupLabelsPorts(app.ports)
setupStoragePorts(app.ports)
