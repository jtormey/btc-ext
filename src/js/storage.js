export const setupPorts = (ports) => {
  ports.set.subscribe((data) => {
    let [key, value] = data.split(',')
    localStorage.setItem(key, value)
  })

  ports.get.subscribe((key) => {
    let value = localStorage.getItem(key)
    ports.storage.send([key, value].join(','))
  })

  ports.remove.subscribe((key) => {
    localStorage.removeItem(key)
  })
}
