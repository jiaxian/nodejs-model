Q = require 'q'
s = require 'stampit'
Validators = require './validators'
_ = require 'underscore'

model_instance = s().enclose(() ->
    model = @model
    delete @model

    @validate = (filter) ->
        @errors = {}
        oper = Q.defer()
        deffers = []

        if filter
            vProps = [filter];
        else
            attrsDefs = model.attrsDefs()

            for prop of attrsDefs
                validators = attrsDefs[prop].validations
                if validators?
                    for validator of validators
                            validator_options = validators[validator]

                            if Validators[validator]
                                deffers = deffers.concat Validators[validator][validator](@, prop, validator_options)

                    Q.allSettled(deffers).then((result) =>
                        @isValid = Object.keys(@errors).length is 0
                        oper.resolve()
                    )
        oper.promise

    @getType = () ->
        model.getType()

    @addError = (attr, message) ->
        @errors[attr] = (@errors[attr] || []).concat(message)

    @update = (object, accessibility) ->
        if ! accessibility?
            accessibility = ['public']
        else if accessibility.constructor isnt Array
            accessibility = [accessibility]

        attrsDefs = model.attrsDefs()
        for p of object
            if _.intersection(attrsDefs[p].accessibility, accessibility).length > 0
                @attrs[p] = object[p]

        @


    @toJSON = (accessibility) ->
        if ! accessibility?
            accessibility = ['public']
        else if accessibility.constructor isnt Array
            accessibility = [accessibility]

        attrsToReturn = {}
        attrsDefs = model.attrsDefs()

        for attr of @attrs
            if _.contains(accessibility, '*') or _.intersection(attrsDefs[attr].accessibility, accessibility).length > 0
                attrsToReturn[attr] = @attrs[attr]

        attrsToReturn
    @
)

module.exports = model_instance