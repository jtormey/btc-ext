const STORE_KEY = '@btc-ext'

export const setupPorts = (ports) => {
  ports.updateStorage.subscribe((data) => {
    localStorage.setItem(STORE_KEY, data)
    ports.receiveStorage.send(data)
  })

  ports.fetchStorage.subscribe(() => {
    let value = localStorage.getItem(STORE_KEY)
    if (value != null) ports.receiveStorage.send(value)
  })

  ports.clearStorage.subscribe(() => {
    localStorage.removeItem(STORE_KEY)
  })
}
