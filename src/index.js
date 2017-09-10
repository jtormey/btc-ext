import '../manifest.json?loadfile'
import './style/main.scss'
import { HDNode } from 'bitcoinjs-lib'
import * as labels from './js/labels'

// xpub6DX2ZjB6qgNGPuGobYQbpwXHrn7zue1xWSpg29cw6HxovCE9F4iHqEzjnhXk1PbKrfVGwMMrgQv7Q1wWDDBYzx85C8dsvD6jqc49U2PYstx

let deriveFromXpub = (xpub, index) => (
  HDNode.fromBase58(xpub).derive(0).derive(index).getAddress()
)

let Elm = require('./elm/Main')
let app = Elm.Main.embed(document.getElementById('main'))

app.ports.derive.subscribe(({ xpub, index }) => {
  let address = deriveFromXpub(xpub, index)
  app.ports.derivation.send(address)
})

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

app.ports.lastIndex.send(labels.lastIndex())
