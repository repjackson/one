if Meteor.isClient
    Router.route '/coin', (->
        @layout 'layout'
        @render 'coin'
        ), name:'coin'    
    
    Template.coin.onCreated ->
        @autorun => @subscribe 'my_coins', ->
    Template.coin.helpers 
        my_coins: ->
            Docs.find 
                model:'coin'
                _author_id:Meteor.userId()
    Template.coin.events
        'click .mint_coin': ->
            Docs.insert
                model:'coin'
        
    
if Meteor.isServer
    Meteor.publish 'my_coins', ->
        Docs.find 
            model:'coin'
            _author_id:Meteor.userId()
        