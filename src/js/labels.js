const STORE_KEY = '@btc-ext:labels'

class Labels {
  save (entry) {
    let labels = this.read()
    labels.push(entry)
    localStorage.setItem(STORE_KEY, JSON.stringify(labels))
  }

  read () {
    return JSON.parse(localStorage.getItem(STORE_KEY) || '[]')
  }

  lastIndex () {
    let labels = this.read()
    return labels.map(l => l.index).reduce((a, i) => Math.max(a, i), 0)
  }
}

export const setupPorts = (ports) => {
  let labels = new Labels()

  ports.save.subscribe((data) => {
    let [index, label] = data.split(',')
    labels.save({ index: parseInt(index), label })
  })

  ports.readLabels.subscribe(() => {
    let labelsStr = JSON.stringify(labels.read())
    ports.readResponse.send(labelsStr)
  })

  ports.lastIndex.send(labels.lastIndex())
}
