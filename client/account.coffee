Template.account_finance.onCreated ->
    if Meteor.isDevelopment
        pub_key = Meteor.settings.public.stripe_test_publishable
    else if Meteor.isProduction
        pub_key = Meteor.settings.public.stripe_live_publishable
    Template.instance().checkout = StripeCheckout.configure(
        key: pub_key
        image: 'https://res.cloudinary.com/facet/image/upload/v1585357133/one_logo.png'
        locale: 'auto'
        zipCode: true
        token: (token) ->
            amount = parseInt(Session.get('topup_amount'))
            # product = Docs.findOne Meteor.user()._model
            charge =
                amount: amount*100
                currency: 'usd'
                source: token.id
                description: token.description
                # receipt_email: token.email
            Meteor.call 'credit_topup', charge, (err,res)=>
                if err then alert err.reason, 'danger'
                else
                    Swal.fire(
                        'topup processed',
                        ''
                        'success'
                    Docs.insert
                        model:'transaction'
                        transaction_type:'topup'
                        amount:amount
                    Meteor.users.update Meteor.userId(),
                        $inc: credit:amount
                    )
    )
    Template.account_finance.events
        'click .add_five_credits': ->
            console.log Template.instance()
            if confirm 'add 5 credits?'
                Session.set('topup_amount',5)
                Template.instance().checkout.open
                    name: 'credit deposit'
                    # email:Meteor.user().emails[0].address
                    description: 'wc top up'
                    amount: 500
