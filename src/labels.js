const STORE_KEY = 'labels'

export const save = (entry) => {
  let labels = read()
  labels.push(entry)
  localStorage.setItem(STORE_KEY, JSON.stringify(labels))
}

export const read = () => {
  return JSON.parse(localStorage.getItem(STORE_KEY) || '[]')
}

export const lastIndex = () => {
  let labels = read()
  return labels.map(l => l.index).reduce((a, i) => Math.max(a, i), 0)
}
