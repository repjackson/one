Router.route '/tribe/:doc_id', (->
    @layout 'layout'
    @render 'tribe_view'
    ), name:'tribe_view'


if Meteor.isClient
    Template.tribe_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        # @autorun => Meteor.subscribe 'children', 'tribe_update', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'tribe_members', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'tribe_leaders', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'tribe_events', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'tribe_posts', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'tribe_products', Router.current().params.doc_id, ->
    Template.tribe_view.onRendered ->
        Meteor.call 'log_view', Router.current().params.doc_id, ->
    
    Template.tribe_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->


    # Template.tribes_small.onCreated ->
    #     @autorun => Meteor.subscribe 'model_docs', 'tribe', Sesion.get('tribe_search'),->
    # Template.tribes_small.helpers
    #     tribe_docs: ->
    #         Docs.find   
    #             model:'tribe'
                
                
                
    Template.tribe_view.helpers
        tribe_events: ->
            Docs.find 
                model:'event'
                tribe_ids:$in:[Router.current().params.doc_id]
        tribe_posts: ->
            Docs.find 
                model:'post'
                # tribe_ids:$in:[Router.current().params.doc_id]
        # current_tribe: ->
        #     Docs.findOne
        #         model:'tribe'
        #         slug: Router.current().params.doc_id

    Template.tribe_shop.events
        'click .add_product': ->
            new_id = 
                Docs.insert 
                    model:'product'
                    tribe_id:Router.current().params.doc_id
                    
            Router.go "/product/#{new_id}/edit"
            
    Template.tribe_view.events
        'click .refresh_tribe_stats': ->
            Meteor.call 'calc_tribe_stats', Router.current().params.doc_id, ->
        'click .add_tribe_event': ->
            new_id = 
                Docs.insert 
                    model:'event'
                    tribe_ids:[Router.current().params.doc_id]
            Router.go "/event/#{new_id}/edit"
        'click .add_tribe_post': ->
            new_id = 
                Docs.insert 
                    model:'post'
                    tribe_ids:[Router.current().params.doc_id]
            Router.go "/post/#{new_id}/edit"
        # 'click .join': ->
        #     Docs.update
        #         model:'tribe'
        #         _author_id: Meteor.userId()
        # 'click .tribe_leave': ->
        #     my_tribe = Docs.findOne
        #         model:'tribe'
        #         _author_id: Meteor.userId()
        #         ballot_id: Router.current().params.doc_id
        #     if my_tribe
        #         Docs.update my_tribe._id,
        #             $set:value:'no'
        #     else
        #         Docs.insert
        #             model:'tribe'
        #             ballot_id: Router.current().params.doc_id
        #             value:'no'


if Meteor.isServer
    Meteor.publish 'tribe_events', (tribe_id)->
        # tribe = Docs.findOne
        #     model:'tribe'
        #     _id:tribe_id
        Docs.find
            model:'event'
            tribe_ids:$in: [tribe_id]

    Meteor.publish 'tribe_posts', (tribe_id)->
        # tribe = Docs.findOne
        #     model:'tribe'
        #     _id:tribe_id
        Docs.find
            model:'post'
            tribe_ids:$in: [tribe_id]


    Meteor.publish 'tribe_leaders', (tribe_id)->
        tribe = Docs.findOne tribe_id
        if tribe.leader_ids
            Meteor.users.find
                _id: $in: tribe.leader_ids

    Meteor.publish 'tribe_members', (tribe_id)->
        tribe = Docs.findOne tribe_id
        Meteor.users.find
            _id: $in: tribe.member_ids




Router.route '/tribe/:doc_id/edit', -> @render 'tribe_edit'


# tribe edit
if Meteor.isClient
    Template.tribe_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'tribe_options', Router.current().params.doc_id
    Template.tribe_edit.events
        'click .add_option': ->
            Docs.insert
                model:'tribe_option'
                ballot_id: Router.current().params.doc_id
    Template.tribe_edit.helpers
        options: ->
            Docs.find
                model:'tribe_option'


# tribes
if Meteor.isClient
    Router.route '/tribes', (->
        @layout 'layout'
        @render 'tribes'
        ), name:'tribes'


    Template.tribes.onCreated ->
        Session.setDefault 'view_mode', 'list'
        Session.setDefault 'sort_key', 'member_count'
        Session.setDefault 'sort_label', 'available'
        Session.setDefault 'limit', 20
        Session.setDefault 'view_open', true

    Template.tribes.onCreated ->
        @autorun => @subscribe 'tribe_facets',
            picked_tags.array()
            Session.get('limit')
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('view_delivery')
            Session.get('view_pickup')
            Session.get('view_open')

        @autorun => @subscribe 'tribe_results',
            picked_tags.array()
            Session.get('tribe_title_search')
            Session.get('limit')
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('view_delivery')
            Session.get('view_pickup')
            Session.get('view_open')


    Template.tribe_card.events
        'click .pick_tribe_tag_flat': -> picked_tags.push @valueOf()
    Template.tribe_item.events
        'click .pick_tribe_tag_flat': -> picked_tags.push @valueOf()
        # 'click .unpick_tribe_tag': ->
        #     picked_tags.remove @valueOf()

    Template.tribes.events
        'click .add_tribe': ->
            new_id =
                Docs.insert
                    model:'tribe'
            Router.go("/tribe/#{new_id}/edit")
        'keyup .search_tribe': _.throttle((e,t)->
            query = $('.search_tribe').val()
            Session.set('tribe_title_search', query)
            
            console.log Session.get('tribe_title_search')
            if e.which is 13
                search = $('.search_tribe').val().trim().toLowerCase()
                if search.length > 0
                    picked_tags.push search
                    console.log 'search', search
                    # Meteor.call 'log_term', search, ->
                    $('.search_tribe').val('')
                    Session.set('tribe_title_search', null)
                    # # $( "p" ).blur();
                    # Meteor.setTimeout ->
                    #     Session.set('dummy', !Session.get('dummy'))
                    # , 10000
        , 500)


        'click .toggle_delivery': -> Session.set('view_delivery', !Session.get('view_delivery'))
        'click .toggle_pickup': -> Session.set('view_pickup', !Session.get('view_pickup'))
        'click .toggle_open': -> Session.set('view_open', !Session.get('view_open'))

        'click .pick_tribe_tag': -> picked_tags.push @name
        'click .unpick_tribe_tag': ->
            picked_tags.remove @valueOf()
            # console.log picked_tags.array()
            # if picked_tags.array().length is 1
                # Meteor.call 'call_wiki', search, ->

            # if picked_tags.array().length > 0
                # Meteor.call 'search_reddit', picked_tags.array(), ->

        'click .clear_picked_tags': ->
            Session.set('current_tribe_search',null)
            picked_tags.clear()

        'keyup #search': _.throttle((e,t)->
            query = $('#search').val()
            Session.set('current_tribe_search', query)
            # console.log Session.get('current_tribe_search')
            if e.which is 13
                search = $('#search').val().trim().toLowerCase()
                if search.length > 0
                    picked_tags.push search
                    console.log 'search', search
                    # Meteor.call 'log_term', search, ->
                    $('#search').val('')
                    Session.set('current_tribe_search', null)
                    # # $('#search').val('').blur()
                    # # $( "p" ).blur();
                    # Meteor.setTimeout ->
                    #     Session.set('dummy', !Session.get('dummy'))
                    # , 10000
        , 1000)

        'click .calc_tribe_count': ->
            Meteor.call 'calc_tribe_count', ->

        # 'keydown #search': _.throttle((e,t)->
        #     if e.which is 8
        #         search = $('#search').val()
        #         if search.length is 0
        #             last_val = picked_tags.array().slice(-1)
        #             console.log last_val
        #             $('#search').val(last_val)
        #             picked_tags.pop()
        #             Meteor.call 'search_reddit', picked_tags.array(), ->
        # , 1000)

        'click .reconnect': ->
            Meteor.reconnect()


        'click .set_sort_direction': ->
            if Session.get('tribe_sort_direction') is -1
                Session.set('tribe_sort_direction', 1)
            else
                Session.set('tribe_sort_direction', -1)


    Template.tribes.helpers
        sorting_up: -> parseInt(Session.get('tribe_sort_direction')) is 1

        # toggle_open_class: -> if Session.get('view_open') then 'blue' else ''
        # connection: ->
        #     console.log Meteor.status()
        #     Meteor.status()
        # connected: ->
        #     Meteor.status().connected
        tribe_tag_results: ->
            # if Session.get('current_tribe_search') and Session.get('current_tribe_search').length > 1
            #     Terms.find({}, sort:count:-1)
            # else
            tribe_count = Docs.find().count()
            # console.log 'tribe count', tribe_count
            # if tribe_count < 3
            #     Results.find({count: $lt: tribe_count})
            # else
            Results.find()

        current_tribe_search: -> Session.get('current_tribe_search')

        result_class: ->
            if Template.instance().subscriptionsReady()
                ''
            else
                'disabled'

        picked_tribe_tags: -> picked_tags.array()
        picked_tags_plural: -> picked_tags.array().length > 1
        searching: -> Session.get('searching')

        one_post: ->
            Docs.find().count() is 1
        tribe_docs: ->
            # if picked_tags.array().length > 0
            Docs.find {
                model:'tribe'
            },
                sort: "#{Session.get('tribe_sort_key')}":parseInt(Session.get('tribe_sort_direction'))
                # limit:Session.get('tribe_limit')

        home_subs_ready: ->
            Template.instance().subscriptionsReady()
        users: ->
            # if picked_tags.array().length > 0
            Meteor.users.find {
            },
                sort: count:-1
                # limit:1


        # timestamp_tags: ->
        #     # if picked_tags.array().length > 0
        #     Timestamp_tags.find {
        #         # model:'reddit'
        #     },
        #         sort: count:-1
        #         # limit:1

        tribe_limit: ->
            Session.get('tribe_limit')

        current_tribe_sort_label: ->
            Session.get('tribe_sort_label')


if Meteor.isServer
    Meteor.publish 'tribe_results', (
        picked_tags
        title_search=''
        doc_limit
        doc_sort_key
        doc_sort_direction
        view_delivery
        view_pickup
        view_open
        )->
        # console.log picked_tags
        match = {model:'tribe'}
        if doc_limit
            limit = doc_limit
        else
            limit = 42
        if title_search.length > 0
            match.title = {$regex:"#{title_search}", $options: 'i'}

        if doc_sort_key
            sort_key = doc_sort_key
        if doc_sort_direction
            sort_direction = parseInt(doc_sort_direction)
        self = @
        # if view_open
        #     match.open = $ne:false
        # if view_delivery
        #     match.delivery = $ne:false
        # if view_pickup
        #     match.pickup = $ne:false
        if picked_tags.length > 0
            match.tags = $all: picked_tags
            sort = 'member_count'
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

        console.log 'tribe match', match
        console.log 'sort key', sort_key
        console.log 'sort direction', sort_direction
        Docs.find match,
            # sort:"#{sort_key}":sort_direction
            sort:_timestamp:-1
            limit: limit

    Meteor.publish 'tribe_facets', (
        picked_tags=[]
        picked_timestamp_tags
        query
        doc_limit
        doc_sort_key
        doc_sort_direction
        view_delivery
        view_pickup
        view_open
        )->
        # console.log 'dummy', dummy
        # console.log 'query', query
        # console.log 'selected tags', picked_tags

        self = @
        match = {}
        match.model = 'tribe'
        # if view_open
        #     match.open = $ne:false

        # if view_delivery
        #     match.delivery = $ne:false
        # if view_pickup
        #     match.pickup = $ne:false
        if picked_tags.length > 0 then match.tags = $all: picked_tags
            # match.$regex:"#{current_tribe_search}", $options: 'i'}
        result_count = Docs.find(match).count()
        tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: count: $lt:result_count }
            { $sort: count: -1, _id: 1 }
            { $limit: 20 }
            { $project: _id: 0, name: '$_id', count: 1 }
        ], {
            allowDiskUse: true
        }

        tag_cloud.forEach (tag, i) =>
            # console.log 'tribe tag result ', tag
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'tribe_tag'
                # category:key
                # index: i


        self.ready()


# Router.route '/tribe/:doc_id/', (->
#     @render 'tribe_view'
#     ), name:'tribe_view'
# Router.route '/tribe/:doc_id/edit', (->
#     @render 'tribe_edit'
#     ), name:'tribe_edit'


if Meteor.isClient
    Meteor.methods
        calc_tribe_stats: ->
            tribe_stat_doc = Docs.findOne(model:'tribe_stats')
            unless tribe_stat_doc
                new_id = Docs.insert
                    model:'tribe_stats'
                tribe_stat_doc = Docs.findOne(model:'tribe_stats')
            console.log tribe_stat_doc
            total_count = Docs.find(model:'tribe').count()
            complete_count = Docs.find(model:'tribe', complete:true).count()
            incomplete_count = Docs.find(model:'tribe', complete:$ne:true).count()
            Docs.update tribe_stat_doc._id,
                $set:
                    total_count:total_count
                    complete_count:complete_count
                    incomplete_count:incomplete_count

if Meteor.isServer
    Meteor.publish 'user_tribes', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'tribe'
            _author_id: user._id

    Meteor.publish 'tribe_by_slug', (tribe_slug)->
        Docs.find
            model:'tribe'
            slug:tribe_slug
    Meteor.methods
        calc_tribe_stats: (tribe_slug)->
            tribe = Docs.findOne
                model:'tribe'
                slug: tribe_slug

            member_count =
                tribe.member_ids.length

            tribe_members =
                Meteor.users.find
                    _id: $in: tribe.member_ids

            dish_count = 0
            dish_ids = []
            for member in tribe_members.fetch()
                member_dishes =
                    Docs.find(
                        model:'dish'
                        _author_id:member._id
                    ).fetch()
                for dish in member_dishes
                    console.log 'dish', dish.title
                    dish_ids.push dish._id
                    dish_count++
            # dish_count =
            #     Docs.find(
            #         model:'dish'
            #         tribe_id:tribe._id
            #     ).count()
            tribe_count =
                Docs.find(
                    model:'tribe'
                    tribe_id:tribe._id
                ).count()

            order_cursor =
                Docs.find(
                    model:'order'
                    tribe_id:tribe._id
                )
            order_count = order_cursor.count()
            total_credit_exchanged = 0
            for order in order_cursor.fetch()
                if order.order_price
                    total_credit_exchanged += order.order_price
            tribe_tribes =
                Docs.find(
                    model:'tribe'
                    tribe_id:tribe._id
                ).fetch()

            console.log 'total_credit_exchanged', total_credit_exchanged


            Docs.update tribe._id,
                $set:
                    member_count:member_count
                    tribe_count:tribe_count
                    dish_count:dish_count
                    total_credit_exchanged:total_credit_exchanged
                    dish_ids:dish_ids