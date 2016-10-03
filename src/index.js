
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
