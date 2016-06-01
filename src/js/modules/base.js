define([
    'jquery',               // handy util
    'underscore',             // models / view framework
    'models/base',
    'views/base'
], function($, _, BaseModel, BaseView) {
    'use strict';

    // Valid data options:
    //     id: ID of the photo set
    //     type: Type of gallery.  Currently only 'flickr' is permitted
    function BaseModule (options) {
        var optionsBaseModel = _.chain(options)
                .filterArg(['defaults', 'format', 'url'])
                .value(),
            baseModel = new BaseModel(options.defaults || {}, optionsBaseModel),
            optionsBaseView = _.chain(options)
                .filterArg(['el', 'templateName'])
                .extend({
                        model: baseModel,
                        // Build the template path: baseTemplateUrl/templateScheme/templateName
                        // There's a special case when the template is not defined - use the debug template instead
                        templatePath: _.has(options, 'templateName') ?
                            _.reject([
                                options.baseTemplateUrl,
                                options.templateScheme,
                                options.templateName
                            ], _.isEmpty).join('/') :
                            options.baseTemplateUrlInternal + '/debug'
                })
                .value(),
            baseView = new BaseView(optionsBaseView);

        // Set up the view to listen to the model once (BaseModel assumes static representation)
        baseView.listenToOnce(baseModel, 'sync', baseView.render);

        // Initialize the data
        baseModel.fetch();
    }

    BaseModule.prototype = {
        constructor: BaseModule
    };

    // Return the initialization routine to the main controller
    return BaseModule;
});
