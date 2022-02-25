if Meteor.isClient
    Router.route '/user/:username', (->
        @layout 'layout'
        @render 'profile'
        ), name:'profile'



    Template.profile.onCreated ->
        @autorun -> Meteor.subscribe 'user_member_groups', Router.current().params.username
        @autorun -> Meteor.subscribe 'user_leader_groups', Router.current().params.username
        @autorun -> Meteor.subscribe 'user_hosted_events', Router.current().params.username, ->
        # @autorun => Meteor.subscribe 'profile', Router.current().params.username
        # @autorun => Meteor.subscribe 'model_docs', 'order'

        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username, ->
        # @autorun -> Meteor.subscribe 'user_referenced_docs', Router.current().params.username, ->
        @autorun -> Meteor.subscribe 'user_event_tickets', Router.current().params.username
        # @autorun -> Meteor.subscribe 'model_docs', 'event'
        
    Template.profile.events
        'click .user_credit_segment': ->
            Router.go "/debit/#{@_id}/view"
            
        'click .user_debit_segment': ->
            Router.go "/debit/#{@_id}/view"
            
            
    Template.profile.helpers
        current_user: ->
            Meteor.users.findOne username:Router.current().params.username

        user: ->
            Meteor.users.findOne username:Router.current().params.username
    
    
        user_event_tickets: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'transaction'
                transaction_type:'ticket_purchase'
            }, 
                sort: _timestamp:-1
                limit: 10

        groups: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'order'
                _author_id: current_user._id
                # recipient: target_user._id
            },
                sort:_timestamp:-1

        user_member_groups: ->
            user = Meteor.users.findOne username:@username
            Docs.find
                model:'group'
                group_member_ids:$in:[user._id]
            
        user_leader_groups: ->
            user = Meteor.users.findOne username:@username
            Docs.find
                model:'group'
                group_leader_ids:$in:[user._id]


        user_going_events: ->
            user = Meteor.users.findOne username:@username
            Docs.find
                model:'event'
                going_user_ids:$in:[user._id]
        user_hosted_events: ->
            user = Meteor.users.findOne username:@username
            Docs.find
                model:'event'
                host_id:user._id
    Template.profile.onCreated ->
        @autorun => Meteor.subscribe 'user_groups', Router.current().params.username
    Template.profile.helpers
        groups: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Docs.find {
                model:'group'
                _author_id: current_user._id
            }, sort:_timestamp:-1

if Meteor.isServer 
    Meteor.publish 'user_bookmark_docs', ->
        Docs.find 
            _id:$in:Meteor.user().bookmark_ids

    Meteor.publish 'user_hosted_events', (username)->
        user = Meteor.users.findOne username:username
        Docs.find 
            model:'event'
            host_id:user._id


if Meteor.isClient 
    Template.profile.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 2000


    # Template.user_section.helpers
    #     user_section_template: ->
    #         "user_#{Router.current().params.group}"


    Template.profile.events
        'click .logout_other_clients': ->
            Meteor.logoutOtherClients()

        'click .logout': ->
            Router.go '/login'
            Meteor.logout()
            
        'click .boop': (e,t)->
            $(e.currentTarget).closest('.image').transition('bounce', 500)
            user = Meteor.users.findOne username:Router.current().params.username
            Meteor.users.update user._id,
                $inc:boops:1
            
    # Template.topup_button.events
    #     'click .topup': ->
            
    #         $('body').toast(
    #             showIcon: 'food'
    #             message: "100 points added"
    #             showProgress: 'bottom'
    #             class: 'success'
    #             # displayTime: 'auto',
    #             position: "bottom right"
    #         )
    #         Docs.insert 
    #             model:'topup'
    #             amount:100
    #         Meteor.call 'calc_user_credit', Meteor.userId(), ->
    #         # Meteor.users.update Meteor.userId(),
    #         #     $inc:
    #         #         points:@amount
            
            
if Meteor.isServer
    Meteor.methods
        'calc_user_credit': (user_id)->
            total_points = 0
            topups = 
                Docs.find 
                    model:'topup'
                    _author_id:Meteor.userId()
                    amount:$exists:true
            for topup in topups.fetch()
                total_points += topup.amount
            console.log total_points
            
            Meteor.users.update Meteor.userId(),
                $set:points:total_points
            
            
    Meteor.publish 'username_model_docs', (model, username)->
        if username 
            Docs.find   
                model:model
                _author_username:username
        else 
            Docs.find   
                model:model
                _author_username:Meteor.user().username            
                
                
                

if Meteor.isServer
    Meteor.publish 'user_event_tickets', (username)->
        user = Meteor.users.findOne username:username
        Docs.find({
            model:'transaction'
            transaction_type:'ticket_purchase'
            _author_id:user._id
        },{
            limit:20
            sort: _timestamp:-1
        })
        
        
        
        

if Meteor.isServer
    Meteor.methods 
        enter_group: (group_id)->
            Meteor.users.update Meteor.userId(),
                $set:
                    current_group_id:group_id
    
    Meteor.publish 'user_member_groups', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'group'
            group_member_ids:$in:[user._id]
            
    Meteor.publish 'user_leader_groups', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'group'
            group_leader_ids:$in:[user._id]
            
    Meteor.publish 'user_event_going', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'event'
            going_user_ids:$in:[user._id]
    Meteor.publish 'user_event_maybe', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'event'
            maybe_user_ids:$in:[user._id]
    Meteor.publish 'user_event_not_going', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'event'
            not_user_ids:$in:[user._id]
            
            