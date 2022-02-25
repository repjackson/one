if Meteor.isClient
    Router.route '/users', -> @render 'users'

    Template.users.onCreated ->
        # @autorun -> Meteor.subscribe('users')
        Session.setDefault('view_mode','grid')
        @autorun => Meteor.subscribe 'search_user', Session.get('username_query'), picked_user_tags.array(), ->
        @autorun => Meteor.subscribe 'user_tags', picked_user_tags.array(), ->
    Template.users.helpers
        picked_user_tags: -> picked_user_tags.array()
        all_user_tags: -> Results.find model:'user_tag'
        one_result: ->
            # console.log 'one'
            Meteor.users.find().count() is 1
        username_query: -> Session.get('username_query')
        user_docs: ->
            match = {}
            username_query = Session.get('username_query')
            if username_query
                match.username = {$regex:"#{username_query}", $options: 'i'}
            if picked_user_tags.array().length > 0
                match.tags = $all: picked_user_tags.array()
                
            match._id = $ne:Meteor.userId()
            Meteor.users.find(match
                # roles:$in:['resident','owner']
            ,{ limit:20 }).fetch()

    Template.users.events
        'click .pick_user_tag': -> picked_user_tags.push @name
        'click .unpick_user_tag': -> picked_user_tags.remove @valueOf()
        'click .add_user': ->
            new_username = prompt('username')
            Meteor.call 'add_user', new_username, (err,res)->
                console.log res
                new_user = Meteor.users.findOne res
                Router.go "/user/#{new_user.username}"
        'keyup .search_user': (e,t)->
            username_query = $('.search_user').val()
            if e.which is 8
                if username_query.length is 0
                    Session.set 'username_query',null
                    # Session.set 'checking_in',false
                else
                    Session.set 'username_query',username_query
            else
                Session.set 'username_query',username_query

        'click .clear_query': ->
            Session.set('username_query',null)


if Meteor.isServer
    Meteor.publish 'users', (limit)->
        if limit
            Meteor.users.find({},limit:limit)
        else
            Meteor.users.find()
    Meteor.publish 'user_results', (
        picked_tags
        doc_limit
        doc_sort_key
        doc_sort_direction
        view_delivery
        view_pickup
        view_open
        )->
        # console.log picked_tags
        if doc_limit
            limit = doc_limit
        else
            limit = 42
        if doc_sort_key
            sort_key = doc_sort_key
        if doc_sort_direction
            sort_direction = parseInt(doc_sort_direction)
        self = @
        match = {model:'event'}
        # if view_open
        #     match.open = $ne:false
        # if view_delivery
        #     match.delivery = $ne:false
        # if view_pickup
        #     match.pickup = $ne:false
        if picked_tags.length > 0
            match.tags = $all: picked_tags
            # sort = 'member_count'
        else
            # match.tags = $nin: ['wikipedia']
            sort = '_timestamp'
            # match.source = $ne:'wikipedia'
        # if view_images
        #     match.is_image = $ne:false
        # if view_videos
        #     match.is_video = $ne:false

        # match.tags = $all: picked_tags
        # if filter then match.model = filter
        # keys = _.keys(prematch)
        # for key in keys
        #     key_array = prematch["#{key}"]
        #     if key_array and key_array.length > 0
        #         match["#{key}"] = $all: key_array
            # console.log 'current facet filter array', current_facet_filter_array

        console.log 'group match', match
        console.log 'sort key', sort_key
        console.log 'sort direction', sort_direction
        Docs.find match,
            # sort:"#{sort_key}":sort_direction
            sort:_timestamp:-1
            limit: limit


    Meteor.publish 'search_user', (username, picked_user_tags)->
        match = {}
        if picked_user_tags.length > 0 then match.tags = $all:picked_user_tags 
        if username
            match.username = {$regex:"#{username}", $options: 'i'}
        Meteor.users.find(match,{ 
            limit:200, 
            fields:
                roles:1
                username:1
                image_id:1
                tags:1
                credit:1
                first_name:1
                last_name:1
        }
        )
    
    Meteor.publish 'user_tags', (picked_tags)->
        # user = Meteor.users.findOne @userId
        # current_herd = user.profile.current_herd
    
        self = @
        match = {}
    
        # picked_tags.push current_herd
        if picked_tags.length > 0
            match.tags = $all: picked_tags
    
        cloud = Meteor.users.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $group: _id: '$tags', count: $sum: 1 }
            { $match: _id: $nin: picked_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        cloud.forEach (tag, i) ->
    
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'user_tag'
                index: i
    
        self.ready()
        