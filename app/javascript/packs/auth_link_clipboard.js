import Clipboard from 'clipboard'

document.addEventListener('DOMContentLoaded', () => {
  let div = document.getElementById('clipboard-trigger-holder')
  div.innerHTML = '<button class="btn btn-primary" id="clipboard-trigger">Copy link to clipboard</button>'
  new Clipboard('#clipboard-trigger', {
    text: function (trigger) {
      let url = document.getElementById('authorized-link').children[0].getAttribute('href')
      return url
    }
  })
})