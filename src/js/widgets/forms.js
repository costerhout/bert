;(function(mymodule) {
    'use strict';

    mymodule(window.jQuery, window, document);
}(function($, window, document) {
    'use strict';

    // Dynamic controls helper functions
    var hideDel = function ($group) {
        $('.form-del-item', $group).hide();
    };

    var showDel = function ($group) {
        $('.form-del-item', $group).show();
    };

    var removeGroup = function ($group) {
        // Save away other sibling groups
        var $groups = $group.siblings('.form-multiple-group');

        // Remove the group
        $group.remove();

        // Hide the delete button on sole remaining group
        if ($groups.length === 1) {
            hideDel($groups);
        }
    };

    var cloneGroup = function ($master) {
        // Where are we in the list? We'll be using this to alter IDs, names, and for attributes of cloned elements
        var index = $master.siblings().length + 1,
            // Figure out if the master is a clone as well
            master_is_clone = $master.data('is-clone') === true,
            // Perform the deep copy (events and data as well)
            $copy = $master.clone(true),
            $siblings,
            id_base, id_clone;

        // Mark copy as clone
        $copy.data('is-clone', true);

        // Walk through and update the 'for' fields of all labels in the copy
        $copy.find('label[for]').each(function () {
            // If the parent was a clone, the parent should have a base-id set
            id_base = master_is_clone ? $(this).data('id-base') : $(this).attr('for');

            // Set the element's 'for' attribute
            id_clone = id_base + '_' + String(index);
            $(this).attr('for', id_clone);

            // Set the base ID for future cloning
            $(this).data('id-base', id_base);
        });

        // Walk through and update name / id fields of all input elements in the copy
        $copy.find(':input').each(function () {
            if (master_is_clone) {
                id_base = $(this).data('id-base');
            } else if ( $(this).attr('id') === 'undefined' ) {
                id_base = $(this).attr('name');
            } else {
                id_base = $(this).attr('id');
            }

            // Set the current value to the initial value
            if ( $(this).data('init-val') !== undefined ) {
                $(this).val($(this).data('init-val'));
            }

            // Set the element's 'id' and 'name' attributes
            id_clone = id_base + '_' + String(index);
            $(this).attr('id', id_clone);
            $(this).attr('name', id_clone);

            // Set the base ID for future cloning
            $(this).data('id-base', id_base);
        });

        // Insert this copy right after the parent
        $master.after($copy);

        // Enable the delete button on previously hidden siblings
        $siblings = $master.siblings('.form-multiple-group');
        if ($siblings.length === 1) {
            showDel($master);
            showDel($siblings);
        }
    };

    $(function () {
        // DOM is ready

        // Match .form-multiple-item elements - they wrap elements that need to
        // be duplicated.
        $('.form-multiple-group').each(function () {
            // Save away the initial value
            $(':input', this).each(function () {
                $(this).data('init-val', $(this).val());
            });

            // Insert dynamic controls at the head of the children
            var htmlControls = UAS.Templates['forms/dynamic-controls'],
                $controls;

            // Check to make sure we obtained the template
            if (typeof htmlControls === 'function') {
                // Create a new DOM element for the inserted content
                $controls = $(htmlControls());

                // Hide the delete button since this is the sole group
                hideDel($controls);

                // Attach event handlers to the contained control elemenets
                $('.form-add-item', $controls).click(function(ev) {
                    // Copy the parent group
                    cloneGroup($(this).parents('.form-multiple-group').first());

                    // Don't actually follow the link
                    ev.preventDefault();
                });

                $('.form-del-item', $controls).click(function(ev) {
                    // Remove the parent group
                    removeGroup($(this).parents('.form-multiple-group').first());

                    // Don't actually follow the link
                    ev.preventDefault();
                });

                // Insert into the DOM
                $(this).prepend($controls);
            } else {
                console.log('Could not get forms/dynamic-controls template');
            }
        });
    });
}));
