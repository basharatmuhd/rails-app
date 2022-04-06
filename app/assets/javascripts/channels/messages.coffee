App.messages = App.cable.subscriptions.create {channel: "MessagesChannel", project_id: 2},
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    # Called when there's incoming data on the websocket for this channel
    $('.js-messages').append "<div>" + data['body'] + "</div>"
