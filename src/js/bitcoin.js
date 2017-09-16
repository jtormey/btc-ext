import { HDNode } from 'bitcoinjs-lib'

let deriveFromXpub = (xpub, index) => (
  HDNode.fromBase58(xpub).derive(0).derive(index).getAddress()
)

export const setupPorts = (ports) => {
  ports.derive.subscribe(({ xpub, index }) => {
    let address = deriveFromXpub(xpub, index)
    ports.derivation.send(JSON.stringify({ index, address }))
  })
}
