import '../manifest.json?loadfile'
import '../icons/icon16.png'
import '../icons/icon32.png'
import '../icons/icon64.png'
import '../icons/icon128.png'
import '../icons/icon256.png'
import './style/main.scss'
import { setupPorts as setupBitcoinPorts } from './js/bitcoin'
import { setupPorts as setupStoragePorts } from './js/storage'

let Elm = require('./elm/Main')
let app = Elm.Main.embed(document.getElementById('main'))

setupBitcoinPorts(app.ports)
setupStoragePorts(app.ports)
