let url = 'http://localhost/*'
let extId = chrome.runtime.id
let EXT_HANDSHAKE = 'EXT_HANDSHAKE'

let handshake = (id) => ({
  type: EXT_HANDSHAKE,
  payload: { id }
})

let showAlert = () => ({
  type: 'ALERTS_SHOW',
  payload: { type: 'success', message: 'hello!', id: 1 }
})

let init = (tab) => {
  chrome.tabs.sendMessage(tab.id, handshake(extId), (response) => {
    console.log(response)
    chrome.tabs.sendMessage(tab.id, showAlert())
  })
}

let findTab = (cb) => {
  chrome.tabs.query({ url }, (tabs) => {
    tabs[0] && cb(tabs[0])
  })
}

chrome.tabs.onCreated.addListener(() => {
  findTab(init)
})

chrome.tabs.onUpdated.addListener(() => {
  findTab(init)
})

/*
handshake ->
<- acceptance

action ->
<- success

select ->
<- response
*/
