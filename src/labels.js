
module.exports = {
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
