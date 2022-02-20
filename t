[1mdiff --git a/client/nav.jade b/client/nav.jade[m
[1mindex 62cf045..f12a333 100644[m
[1m--- a/client/nav.jade[m
[1m+++ b/client/nav.jade[m
[36m@@ -7,10 +7,10 @@[m [mtemplate(name='nav')[m
         // else [m
         // a.icon.item.toggle_leftbar[m
         //     i.large.bars.icon[m
[31m-        a.header.item.zoomer(href='/' class="{{isActivePath '/'}}" )[m
[31m-            +i name='yin-yang'[m
[31m-            // i.large.home.icon[m
[31m-            span.mobile.hidden one[m
[32m+[m[32m        // a.header.item.zoomer(href='/' class="{{isActivePath '/'}}" )[m
[32m+[m[32m        //     +i name='yin-yang'[m
[32m+[m[32m        //     // i.large.home.icon[m
[32m+[m[32m        //     span.mobile.hidden one[m
         // .search.item.zoomer.mobile.hidden(title='search')[m
         //     .ui.icon.transparent.input[m
         //         if current_product_search[m
[36m@@ -18,14 +18,14 @@[m [mtemplate(name='nav')[m
         //         else[m
         //             i.search.large.icon[m
         //         input.search_products(type='text' autocomplete="off" value=current_product_search)[m
[31m-        // a.icon.item(href="/users")[m
[31m-        //     // i.large.inbox.icon[m
[31m-        //     +i name='groups'[m
[31m-        //     .mobile.hidden users [m
         a.icon.item(href="/events")[m
             // i.large.inbox.icon[m
             +i name='calendar'[m
             span.mobile.hidden events[m
[32m+[m[32m        a.icon.item(href="/users")[m
[32m+[m[32m            // i.large.inbox.icon[m
[32m+[m[32m            +i name='groups'[m
[32m+[m[32m            .mobile.hidden users[m[41m [m
         a.icon.item(href="/groups")[m
             // i.large.inbox.icon[m
             +i name='campfire'[m
[1mdiff --git a/parts/blocks.coffee b/parts/blocks.coffee[m
[1mindex 39b9319..9b599d6 100644[m
[1m--- a/parts/blocks.coffee[m
[1m+++ b/parts/blocks.coffee[m
[36m@@ -105,10 +105,10 @@[m [mif Meteor.isClient[m
             Docs.update @_id,[m
                 $pull:follower_ids:Meteor.userId()[m
 [m
[31m-    Template.set_limit.events[m
[31m-        'click .set_limit': ->[m
[31m-            console.log @[m
[31m-            Session.set('limit', @amount)[m
[32m+[m[32m    # Template.set_limit.events[m
[32m+[m[32m    #     'click .set_limit': ->[m
[32m+[m[32m    #         console.log @[m
[32m+[m[32m    #         Session.set('limit', @amount)[m
 [m
     Template.set_sort_key.helpers[m
         sort_button_class: ->[m
[1mdiff --git a/parts/event.coffee b/parts/event.coffee[m
[1mindex cb1d915..a624a42 100644[m
[1m--- a/parts/event.coffee[m
[1m+++ b/parts/event.coffee[m
[36m@@ -1,5 +1,5 @@[m
 if Meteor.isClient[m
[31m-    Router.route '/event/:doc_id/view', (->[m
[32m+[m[32m    Router.route '/event/:doc_id', (->[m
         @layout 'layout'[m
         @render 'event_view'[m
         ), name:'event_view'[m
[1mdiff --git a/parts/event.jade b/parts/event.jade[m
[1mindex 96dc46a..3d75e15 100644[m
[1m--- a/parts/event.jade[m
[1m+++ b/parts/event.jade[m
[36m@@ -23,12 +23,12 @@[m [mtemplate(name='events')[m
 template(name='event_card')[m
     .ui.card[m
         if image_id[m
[31m-            a.image.zoom.pointer.mobile.hidden(href="/event/#{_id}/view")[m
[32m+[m[32m            a.image.zoom.pointer.mobile.hidden(href="/event/#{_id}")[m
                 img.ui.image(src="{{c.url image_id height=500 width=500 gravity='face' crop='fill'}}" class=currentUser.invert_class)[m
[31m-            a.image.zoom.pointer.mobile.only(href="/event/#{_id}/view")[m
[32m+[m[32m            a.image.zoom.pointer.mobile.only(href="/event/#{_id}")[m
                 img.ui.image(src="{{c.url image_id height=200 width=500 gravity='center' crop='fill'}}" class=currentUser.invert_class)[m
         .content[m
[31m-            a.ui.header(href="/event/#{_id}/view") #{title} [m
[32m+[m[32m            a.ui.header.fly_right(href="/event/#{_id}") #{title}[m[41m [m
             div[m
             .ui.small.header {{medium_date date}} [m
                 if time [m
[36m@@ -46,7 +46,7 @@[m [mtemplate(name='event_card')[m
             strong #{fac.name}[m
         .content[m
             |#{event_tickets.count}[m
[31m-            a(href="/m/event/#{_id}/view" title='ticket purchase required')[m
[32m+[m[32m            a(href="/event/#{_id}" title='ticket purchase required')[m
                 i.checkmark.green.link.icon[m
             | #{going.count}[m
             each going[m
[36m@@ -82,51 +82,6 @@[m [mtemplate(name='gcal_button')[m
         [m
         [m
         [m
[31m-template(name='event_edit')[m
[31m-    with current_doc[m
[31m-        .ui.stackable.padded.grid[m
[31m-            .centered.row [m
[31m-                .five.wide.column[m
[31m-                    a.ui.icon.green.big.button.fly_right(href="/event/#{_id}/view" title='save')[m
[31m-                        i.checkmark.big.icon[m
[31m-                    .ui.inline.header [m
[31m-                        +icolor name='tear-off-calendar'[m
[31m-                        |edit event[m
[31m-                    +boolean_edit key='published' label='published' direct=true[m
[31m-                    .ui.icon.basic.circular.button.delete_item(title='delete')[m
[31m-                        i.remove.red.icon[m
[31m-                    +text_edit key='title' label='title' direct=true[m
[31m-                    .ui.header [m
[31m-                        small author[m
[31m-                        |#{_author.name}[m
[31m-                    // +slug_edit key='slug' label='slug' icon='slug' direct=true[m
[31m-                    // if reservation_exists[m
[31m-                    //     .ui.header date: #{date}[m
[31m-                    //     .ui.header time: #{time}[m
[31m-                    // else[m
[31m-                    +datetime_edit key='start_datetime' label='start datetime' direct=true[m
[31m-                    +datetime_edit key='end_datetime' label='end datetime' direct=true[m
[31m-                    // +time_edit key='time' label='time' direct=true[m
[31m-                    // +number_edit key='hour_duration' label='hours' direct=true[m
[31m-                    // +range_edit label='time range' direct=true[m
[31m-                    // +single_user_edit key='facilitator_id' label='facilitator' icon='chess king' direct=true[m
[31m-                    // +single_user_edit key='support_id' label='support' icon='chess queen' direct=true[m
[31m-                    +single_user_edit key='host_id' label='host' icon='shield' direct=true[m
[31m-                    div [m
[31m-                    +array_edit key='tags' label='tags' icon='red tags' direct=true[m
[31m-                .ten.wide.column[m
[31m-                    .ui.header[m
[31m-                        i.users.icon[m
[31m-                        |audience[m
[31m-                    +number_edit key='max_attendees' label='max attendees' min='0' max='100' direct=true[m
[31m-                    // div[m
[31m-                    +boolean_edit key='free' label='free' direct=true[m
[31m-                    unless free[m
[31m-                        +number_edit key='price_points' label='point price' min='0' max='100' direct=true[m
[31m-                    +number_edit key='price_usd' label='dollar price' min='0' max='100' direct=true[m
[31m-                    +html_edit key='description' label='description' direct=true[m
[31m-                    +image_edit key='image_id' label='image' direct=true[m
[31m-                    +link_edit key='link' label='link'[m
 [m
 template(name='reserve_button')[m
     if slot_res[m
[36m@@ -153,10 +108,10 @@[m [mtemplate(name='event_view')[m
             .middle.aligned.row [m
                 .sixteen.wide.column[m
                     if currentUser[m
[31m-                        a(href="/events")[m
[31m-                            i.calendar.big.circular.link.icon[m
[32m+[m[32m                        a.ui.circular.icon.button.fly_left(href="/events")[m
[32m+[m[32m                            i.calendar.big.icon[m
                     .ui.large.inline.header #{title}[m
[31m-                    div[m
[32m+[m[32m                    // div[m
                     if can_edit[m
                         if published [m
                             i.big.eye.green.icon(title='published')[m
[36m@@ -169,7 +124,7 @@[m [mtemplate(name='event_view')[m
                     if time [m
                         .ui.inline.grey.header {{time}}[m
                     if can_edit[m
[31m-                        a.edit_event(href="/event/#{_id}/edit" title='edit')[m
[32m+[m[32m                        a.edit_event.fly_left(href="/event/#{_id}/edit" title='edit')[m
                             i.large.blue.link.pencil.circular.icon[m
             .three.column.row [m
                 .column.scrollin[m
[1mdiff --git a/parts/profile.coffee b/parts/profile.coffee[m
[1mindex bb6eb0d..d11ea2d 100644[m
[1m--- a/parts/profile.coffee[m
[1m+++ b/parts/profile.coffee[m
[36m@@ -68,24 +68,24 @@[m [mif Meteor.isClient[m
             [m
             [m
             [m
[31m-    Template.topup_button.events[m
[31m-        'click .topup': ->[m
[31m-            [m
[31m-            $('body').toast([m
[31m-                showIcon: 'food'[m
[31m-                message: "100 points added"[m
[31m-                showProgress: 'bottom'[m
[31m-                class: 'success'[m
[31m-                # displayTime: 'auto',[m
[31m-                position: "bottom right"[m
[31m-            )[m
[31m-            Docs.insert [m
[31m-                model:'topup'[m
[31m-                amount:100[m
[31m-            Meteor.call 'calc_user_credit', Meteor.userId(), ->[m
[31m-            # Meteor.users.update Meteor.userId(),[m
[31m-            #     $inc:[m
[31m-            #         points:@amount[m
[32m+[m[32m    # Template.topup_button.events[m
[32m+[m[32m    #     'click .topup': ->[m
[32m+[m[41m            [m
[32m+[m[32m    #         $('body').toast([m
[32m+[m[32m    #             showIcon: 'food'[m
[32m+[m[32m    #             message: "100 points added"[m
[32m+[m[32m    #             showProgress: 'bottom'[m
[32m+[m[32m    #             class: 'success'[m
[32m+[m[32m    #             # displayTime: 'auto',[m
[32m+[m[32m    #             position: "bottom right"[m
[32m+[m[32m    #         )[m
[32m+[m[32m    #         Docs.insert[m[41m [m
[32m+[m[32m    #             model:'topup'[m
[32m+[m[32m    #             amount:100[m
[32m+[m[32m    #         Meteor.call 'calc_user_credit', Meteor.userId(), ->[m
[32m+[m[32m    #         # Meteor.users.update Meteor.userId(),[m
[32m+[m[32m    #         #     $inc:[m
[32m+[m[32m    #         #         points:@amount[m
             [m
             [m
 if Meteor.isServer[m
[36m@@ -255,106 +255,6 @@[m [mif Meteor.isServer[m
             amount:$exists:true[m
             [m
             [m
[31m-            [m
[31m-if Meteor.isClient[m
[31m-    Router.route '/user/:username/genekeys', (->[m
[31m-        @layout 'profile_layout'[m
[31m-        @render 'user_genekeys'[m
[31m-        ), name:'user_genekeys'[m
[31m-    [m
[31m-    Template.user_genekeys.onCreated ->[m
[31m-        @autorun => Meteor.subscribe 'docs', picked_tags.array(), 'thought'[m
[31m-[m
[31m-[m
[31m-    Template.user_genekeys.onCreated ->[m
[31m-        @autorun => Meteor.subscribe 'user_genekeys', Router.current().params.username[m
[31m-        @autorun => Meteor.subscribe 'model_docs', 'message'[m
[31m-[m
[31m-    Template.user_genekeys.events[m
[31m-        'keyup .new_public_message': (e,t)->[m
[31m-            if e.which is 13[m
[31m-                val = $('.new_public_message').val()[m
[31m-                console.log val[m
[31m-                target_user = Meteor.users.findOne(username:Router.current().params.username)[m
[31m-                Docs.insert[m
[31m-                    model:'message'[m
[31m-                    body: val[m
[31m-                    is_private:false[m
[31m-                    recipient: target_user._id[m
[31m-                val = $('.new_public_message').val('')[m
[31m-[m
[31m-        'click .submit_public_message': (e,t)->[m
[31m-            val = $('.new_public_message').val()[m
[31m-            console.log val[m
[31m-            target_user = Meteor.users.findOne(username:Router.current().params.username)[m
[31m-            Docs.insert[m
[31m-                model:'message'[m
[31m-                is_private:false[m
[31m-                body: val[m
[31m-                recipient: target_user._id[m
[31m-            val = $('.new_public_message').val('')[m
[31m-[m
[31m-[m
[31m-        'keyup .new_private_message': (e,t)->[m
[31m-            if e.which is 13[m
[31m-                val = $('.new_private_message').val()[m
[31m-                console.log val[m
[31m-                target_user = Meteor.users.findOne(username:Router.current().params.username)[m
[31m-                Docs.insert[m
[31m-                    model:'message'[m
[31m-                    body: val[m
[31m-                    is_private:true[m
[31m-                    recipient: target_user._id[m
[31m-                val = $('.new_private_message').val('')[m
[31m-[m
[31m-        'click .submit_private_message': (e,t)->[m
[31m-            val = $('.new_private_message').val()[m
[31m-            console.log val[m
[31m-            target_user = Meteor.users.findOne(username:Router.current().params.username)[m
[31m-            Docs.insert[m
[31m-                model:'message'[m
[31m-                body: val[m
[31m-                is_private:true[m
[31m-                recipient: target_user._id[m
[31m-            val = $('.new_private_message').val('')[m
[31m-[m
[31m-[m
[31m-[m
[31m-    Template.user_genekeys.helpers[m
[31m-        user_public_genekeys: ->[m
[31m-            target_user = Meteor.users.findOne(username:Router.current().params.username)[m
[31m-            Docs.find[m
[31m-                model:'message'[m
[31m-                recipient: target_user._id[m
[31m-                is_private:false[m
[31m-[m
[31m-        user_private_genekeys: ->[m
[31m-            target_user = Meteor.users.findOne(username:Router.current().params.username)[m
[31m-            Docs.find[m
[31m-                model:'message'[m
[31m-                recipient: target_user._id[m
[31m-                is_private:true[m
[31m-                _author_id:Meteor.userId()[m
[31m-[m
[31m-[m
[31m-[m
[31m-if Meteor.isServer[m
[31m-    Meteor.publish 'user_public_genekeys', (username)->[m
[31m-        target_user = Meteor.users.findOne(username:Router.current().params.username)[m
[31m-        Docs.find[m
[31m-            model:'message'[m
[31m-            recipient: target_user._id[m
[31m-            is_private:false[m
[31m-[m
[31m-    Meteor.publish 'user_private_genekeys', (username)->[m
[31m-        target_user = Meteor.users.findOne(username:Router.current().params.username)[m
[31m-        Docs.find[m
[31m-            model:'message'[m
[31m-            recipient: target_user._id[m
[31m-            is_private:true[m
[31m-            _author_id:Meteor.userId()[m
[31m-[m
[31m-[m
 [m
 [m
 if Meteor.isClient[m
[36m@@ -365,7 +265,7 @@[m [mif Meteor.isClient[m
 [m
 [m
     Template.user_received.onCreated ->[m
[31m-        @autorun => Meteor.subscribe 'user_received', Router.current().params.username[m
[32m+[m[32m        @autorun => Meteor.subscribe 'user_received', Router.current().params.username, ->[m
         # @autorun => Meteor.subscribe 'model_docs', 'debit'[m
 [m
     Template.user_received.events[m
[36m@@ -411,61 +311,6 @@[m [mif Meteor.isServer[m
             [m
             [m
             [m
[31m-if Meteor.isClient[m
[31m-    Router.route '/user/:username/badges', (->[m
[31m-        @layout 'profile_layout'[m
[31m-        @render 'user_badges'[m
[31m-        ), name:'user_badges'[m
[31m-    [m
[31m-[m
[31m-    Template.user_badges.onCreated ->[m
[31m-        @autorun => Meteor.subscribe 'user_badges', Router.current().params.username[m
[31m-        @autorun => Meteor.subscribe 'model_docs', 'badge'[m
[31m-[m
[31m-    Template.user_badges.events[m
[31m-        'keyup .new_badge': (e,t)->[m
[31m-            if e.which is 13[m
[31m-                val = $('.new_badge').val()[m
[31m-                console.log val[m
[31m-                target_user = Meteor.users.findOne(username:Router.current().params.username)[m
[31m-                Docs.insert[m
[31m-                    model:'badge'[m
[31m-                    body: val[m
[31m-                    recipient: target_user._id[m
[31m-                val = $('.new_badge').val('')[m
[31m-[m
[31m-        'click .submit_badge': (e,t)->[m
[31m-            val = $('.new_badge').val()[m
[31m-            console.log val[m
[31m-            target_user = Meteor.users.findOne(username:Router.current().params.username)[m
[31m-            Docs.insert[m
[31m-                model:'badge'[m
[31m-                body: val[m
[31m-                recipient: target_user._id[m
[31m-            val = $('.new_badge').val('')[m
[31m-[m
[31m-[m
[31m-[m
[31m-    Template.user_badges.helpers[m
[31m-        user_badges: ->[m
[31m-            target_user = Meteor.users.findOne(username:Router.current().params.username)[m
[31m-            Docs.find[m
[31m-                model:'badge'[m
[31m-                # recipient: target_user._id[m
[31m-[m
[31m-        slots: ->[m
[31m-            Docs.find[m
[31m-                model:'slot'[m
[31m-                _author_id: Router.current().params.user_id[m
[31m-[m
[31m-[m
[31m-if Meteor.isServer[m
[31m-    Meteor.publish 'user_badges', (username)->[m
[31m-        Docs.find[m
[31m-            model:'badge'[m
[31m-            [m
[31m-            [m
[31m-            [m
 if Meteor.isClient[m
     Router.route '/user/:username/dashboard', (->[m
         @layout 'profile_layout'[m
[36m@@ -474,9 +319,6 @@[m [mif Meteor.isClient[m
         [m
         [m
     Template.user_dashboard.onCreated ->[m
[31m-        @autorun -> Meteor.subscribe 'user_credits', Router.current().params.username[m
[31m-        @autorun -> Meteor.subscribe 'user_debits', Router.current().params.username[m
[31m-        @autorun -> Meteor.subscribe 'user_requests', Router.current().params.username[m
         @autorun -> Meteor.subscribe 'user_completed_requests', Router.current().params.username[m
         @autorun -> Meteor.subscribe 'user_event_tickets', Router.current().params.username[m
         @autorun -> Meteor.subscribe 'model_docs', 'event'[m
[1mdiff --git a/parts/profile.jade b/parts/profile.jade[m
[1mindex f2706b6..6c44b42 100644[m
[1m--- a/parts/profile.jade[m
[1m+++ b/parts/profile.jade[m
[36m@@ -259,23 +259,6 @@[m [mtemplate(name='user_info_tag')[m
             [m
             [m
             [m
[31m-template(name='user_genekeys')[m
[31m-    .ui.header [m
[31m-        +icolor name='dna-helix'[m
[31m-        |user genekeys[m
[31m-    with current_user[m
[31m-        if genekeys_link[m
[31m-            a.ui.basic.button(href=genekeys_link target="_window")[m
[31m-                |view gene keys link[m
[31m-        .ui.stackable.three.column.grid[m
[31m-            .column[m
[31m-                +image_view key='gene1' label='gene keys 1' icon='dna' direct=true[m
[31m-            .column[m
[31m-                +image_view key='gene2' label='gene keys 2' icon='dna' direct=true[m
[31m-            .column[m
[31m-                +image_view key='gene3' label='gene keys 3' icon='dna' direct=true[m
[31m-        |!{genekeys_report}[m
[31m-[m
 // template(name='user_info_tag')[m
 //     .ui.basic.tertiary.button [m
 //         if term [m
[36m@@ -343,9 +326,9 @@[m [mtemplate(name='user_credit')[m
                 // // +number_edit key='credit' label='edit credit' min='0' step='1' max='1000' direct=true[m
                 // .ui.big.icon.button.remove_credit(title='remove credit')[m
                 //     |-1[m
[31m-                +topup_button amount=10[m
[31m-                +topup_button amount=20[m
[31m-                +topup_button amount=100[m
[32m+[m[32m                // +topup_button amount=10[m
[32m+[m[32m                // +topup_button amount=20[m
[32m+[m[32m                // +topup_button amount=100[m
                 // |includes 2% credit card processing fee[m
                 // .ui.action.input[m
                 //     input.deposit_amount(type='number' min='1' placeholder='deposit')[m
