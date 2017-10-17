const STORE_KEY = '@btc-ext'

const fallbackStorage = {
  set (kvs, callback) {
    Object.keys(kvs).forEach(key => {
      localStorage.setItem(key, kvs[key])
    })
    callback()
  },
  get (key, callback) {
    let data = { [key]: localStorage.getItem(key) }
    callback(data)
  },
  remove (key) {
    localStorage.removeItem(key)
  }
}

const storage = chrome.storage
  ? chrome.storage.sync
  : fallbackStorage

export const setupPorts = (ports) => {
  ports.updateStorage.subscribe((data) => {
    storage.set({ [STORE_KEY]: data }, () => {
      ports.receiveStorage.send(data)
    })
  })

  ports.fetchStorage.subscribe(() => {
    storage.get(STORE_KEY, (data) => {
      let value = data[STORE_KEY]
      if (value != null) ports.receiveStorage.send(value)
    })
  })

  ports.clearStorage.subscribe(() => {
    storage.remove(STORE_KEY)
  })
}
