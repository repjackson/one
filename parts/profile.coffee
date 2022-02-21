if Meteor.isClient
    Router.route '/user/:username', (->
        @layout 'layout'
        @render 'profile'
        ), name:'profile'
    Router.route '/user/:username/cart', (->
        @layout 'layout'
        @render 'cart'
        ), name:'user_cart'
    Router.route '/user/:username/credit', (->
        @layout 'layout'
        @render 'user_credit'
        ), name:'user_credit'
    Router.route '/user/:username/orders', (->
        @layout 'layout'
        @render 'user_orders'
        ), name:'user_orders'
    Router.route '/user/:username/friends', (->
        @layout 'layout'
        @render 'user_friends'
        ), name:'user_friends'




    Template.profile.onCreated ->
        @autorun -> Meteor.subscribe 'user_from_username', Router.current().params.username, ->
        # @autorun -> Meteor.subscribe 'user_referenced_docs', Router.current().params.username, ->
if Meteor.isServer 
    Meteor.publish 'user_bookmark_docs', ->
        Docs.find 
            _id:$in:Meteor.user().bookmark_ids


if Meteor.isClient 
    Template.profile.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
        , 2000


    # Template.user_section.helpers
    #     user_section_template: ->
    #         "user_#{Router.current().params.group}"

    Template.profile.helpers
        current_user: ->
            Meteor.users.findOne username:Router.current().params.username

        user: ->
            Meteor.users.findOne username:Router.current().params.username

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
                
                
                
if Meteor.isClient
    Router.route '/user/:username/dashboard', (->
        @layout 'profile_layout'
        @render 'user_dashboard'
        ), name:'user_dashboard'
        
        
    Template.user_dashboard.onCreated ->
        @autorun -> Meteor.subscribe 'user_completed_requests', Router.current().params.username
        @autorun -> Meteor.subscribe 'user_event_tickets', Router.current().params.username
        @autorun -> Meteor.subscribe 'model_docs', 'event'
        
    Template.user_dashboard.events
        'click .user_credit_segment': ->
            Router.go "/debit/#{@_id}/view"
            
        'click .user_debit_segment': ->
            Router.go "/debit/#{@_id}/view"
            
            
            
    Template.user_dashboard.helpers
        user_event_tickets: ->
            current_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find {
                model:'transaction'
                transaction_type:'ticket_purchase'
            }, 
                sort: _timestamp:-1
                limit: 10


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
        
        
        
        
        
if Meteor.isClient
    Router.route '/user/:username/groups', (->
        @layout 'profile_layout'
        @render 'user_groups'
        ), name:'user_groups'

    Template.user_groups.onCreated ->
        @autorun -> Meteor.subscribe 'user_member_groups', Router.current().params.username
        @autorun -> Meteor.subscribe 'user_leader_groups', Router.current().params.username
        # @autorun => Meteor.subscribe 'user_groups', Router.current().params.username
        # @autorun => Meteor.subscribe 'model_docs', 'order'

    Template.user_groups.events
        'keyup .new_order': (e,t)->
            if e.which is 13
                val = $('.new_order').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'order'
                    body: val
                    recipient: target_user._id


    Template.user_groups.helpers
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
            
            
            
            
if Meteor.isClient
    Router.route '/user/:username/messages', (->
        @layout 'profile_layout'
        @render 'user_messages'
        ), name:'user_messages'
    
    Template.user_messages.onCreated ->
        @autorun => Meteor.subscribe 'docs', selected_tags.array(), 'thought'


    Template.user_messages.onCreated ->
        @autorun => Meteor.subscribe 'user_messages', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'message'

    Template.user_messages.events
        'keyup .new_public_message': (e,t)->
            if e.which is 13
                val = $('.new_public_message').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'message'
                    body: val
                    is_private:false
                    recipient: target_user._id
                val = $('.new_public_message').val('')

        'click .submit_public_message': (e,t)->
            val = $('.new_public_message').val()
            console.log val
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.insert
                model:'message'
                is_private:false
                body: val
                recipient: target_user._id
            val = $('.new_public_message').val('')


        'keyup .new_private_message': (e,t)->
            if e.which is 13
                val = $('.new_private_message').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'message'
                    body: val
                    is_private:true
                    recipient: target_user._id
                val = $('.new_private_message').val('')

        'click .submit_private_message': (e,t)->
            val = $('.new_private_message').val()
            console.log val
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.insert
                model:'message'
                body: val
                is_private:true
                recipient: target_user._id
            val = $('.new_private_message').val('')



    Template.user_messages.helpers
        user_public_messages: ->
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find
                model:'message'
                recipient: target_user._id
                is_private:false

        user_private_messages: ->
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find
                model:'message'
                recipient: target_user._id
                is_private:true
                _author_id:Meteor.userId()



if Meteor.isServer
    Meteor.publish 'user_public_messages', (username)->
        target_user = Meteor.users.findOne(username:Router.current().params.username)
        Docs.find
            model:'message'
            recipient: target_user._id
            is_private:false

    Meteor.publish 'user_private_messages', (username)->
        target_user = Meteor.users.findOne(username:Router.current().params.username)
        Docs.find
            model:'message'
            recipient: target_user._id
            is_private:true
            _author_id:Meteor.userId()


