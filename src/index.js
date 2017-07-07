
// xpub6DX2ZjB6qgNGPuGobYQbpwXHrn7zue1xWSpg29cw6HxovCE9F4iHqEzjnhXk1PbKrfVGwMMrgQv7Q1wWDDBYzx85C8dsvD6jqc49U2PYstx

require('!style!css!sass!./main.scss')
let { HDNode } = require('bitcoinjs-lib')

let deriveFromXpub = (xpub, index) => (
  HDNode.fromBase58(xpub).derive(0).derive(index).getAddress()
)

let Elm = require('./Main')
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

let labels = {
  name: 'labels',
  save (entry) {
    let labels = this.read()
    labels.push(entry)
    localStorage.setItem(this.name, JSON.stringify(labels))
  },
  read () {
    return JSON.parse(localStorage.getItem(this.name) || '[]')
  },
  lastIndex () {
    let labels = this.read()
    return labels.map(l => l.index).reduce((a, i) => Math.max(a, i), 0)
  }
}

app.ports.save.subscribe((data) => {
  let [index, label] = data.split(',')
  labels.save({ index, label })
})

app.ports.lastIndex.send(labels.lastIndex())
