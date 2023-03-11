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
        'click .calc_coin': ->
            count = Docs.find(
                model:'coin'
                _author_id:Meteor.userId()
            ).count()
            Meteor.users.update Meteor.userId(),
                $set:
                    coins:count
        'click .mint_coin': ->
            Docs.insert
                model:'coin'
    Template.coin.events
        'click .transfer': ->
            new_id = 
                Docs.insert 
                    model:'transfer'
            Router.go "/transfer/#{new_id}/edit"
        
    
if Meteor.isServer
    Meteor.publish 'my_coins', ->
        Docs.find 
            model:'coin'
            _author_id:Meteor.userId()
        