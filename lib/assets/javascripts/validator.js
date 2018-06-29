/*!
 * jQuery Form Validator
 *
 * Copyright (c) 2012 digital-telepathy
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 */
var FormValidator = function( el, params ) {
    // Cached elements
    this.elements = {};

    // Class namespace
    this.namespace = "formvalidator";

    // Default options for this Class
    this.options = {
        errorPosition: 'after',
        errorShow: 'slideDown',
        errorHide: 'slideUp',
        errorSpeed: 500,
        scrollToError: true,
        validateFields: false,
        html5Validation: true
    };

    /**
     * Required Fields Model
     *
     * Key value pairs in each form group should be keyed off the name of the element
     * to be validated and the value should be an object containing various parameters
     * describing how that field shouold be validated.
     *
     * Required form scaffold:
     * @key string Form ID used in FormValidator.forms
     * @value object JSON formatted object of fields within that form to validate
     *
     * Field scaffold:
     * @key The name of the field to validate
     * @param [algorithm] An optional regular expression to validate the
     *                    field against, default is to evaluate against empty, can
     *                    also take an object with two keys - "pass" and "fail"
     *                    to validate against a passing value and an always fail value.
     *                    If an object is passed you MUST pass both "pass" and "fail" values.
     * @param [type] (text|checkbox|radio) Optional field type validation
     *               style, default is to treat as a text field.
     * @param [when] An optional object that will specify when this field
     *               should be validated. The key of each entry should be
     *               a jQuery selector for the element to check its value
     *               against the expected value of each corresponding key.
     * @param [message] Either a string or an object to define the error
     *                  message to be displayed. If this is an object, you
     *                  may specify an "empty" message or an "algorithm"
     *                  message to be displayed.
     * @param [pseudo] An optional field name that will have its error shown
     *                 instead of this field if this field fails validation.
     *                 Useful for validating multi-field entities like a first
     *                 and last name field to show the same error for failure
     *                 on either field.
     * @param [errorShow] An optional callback function to use for displaying
     *                    the error message if the default functionality does
     *                    not work in the layout.
     * @param [errorHide] An optional callback function to use for hiding the
     *                    error message if the default functionality does not
     *                    work in the layout.
     */
    this.options.required = {};

    this.initialize( el, params );
};
( function( $, window, undefined ) {
    FormValidator.prototype._bindEvents = function() {
        var self = this;

        this.elements.form.on( 'submit', function( event ) {
            if( !self.validate() ) {
                event.preventDefault();
            }
        } );

        this.elements.form.on( 'reset', function( event ) {
            self.reset();
        } );

        this.elements.form.on( 'blur', "input, textarea, select", function( event ) {
            if(self.options.required[this.name]){
                self.validateField(this.name, self.options.validateFields);
            }
        } );
    };

    FormValidator.prototype._build = function() {
        var self = this;

        if(!this.options.html5Validation){
            this.elements.form.attr('novalidate', true);
        }

        this.elements.fields = $( 'input[required], textarea[required], select[required], input.required, textarea.required, select.required', this.elements.form );

        this.elements.fields.each(function(i){
            var $field = self.elements.fields.eq(i);

            // Define the default required entry
            self.options.required[this.name] = self.options.required[this.name] || {};

            // Automatically define the default algorithm for email fields
            if(this.type == "email"){
                self.options.required[this.name].algorithm = "[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\.)+[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?";
                self.options.required[this.name].message = {
                    empty: "Please enter an email address",
                    algorithm: "Please enter a valid email address"
                };
            }

            self.options.required[this.name] = $.extend( self.options.required[this.name] || {}, $field.data() );
        });
    };

    /**
     * Method for doing actions passed to an instantiated slider
     *
     * Takes multiple arguments:
     *
     * @param action string The action to run
     * @param args mixed Optional arguments which may or may not be required by a method
     */
    FormValidator.prototype._run = function() {
        var arguments_array = [];
        for( var i = 0; i < arguments.length; i++ ) {
            arguments_array.push( arguments[i] );
        }

        var action = arguments_array[0];
        var args = arguments_array.length > 1 ? arguments_array.slice( 1 ) : [];

        if( typeof( this[action] ) == 'function' ) {
            return this[action].apply( this, args );
        } else if( typeof( this[action] ) != 'undefined' ) {
            return this[action];
        }
    };

    FormValidator.prototype.initialize = function( el, params ) {
        // Merge options for this instance with defaults
        this.options = $.extend( this.options, arguments[1][0] || {}, $( el ).data() );

        this.elements.form = $( el );

        // Build form
        this._build();

        // Bind events
        this._bindEvents();
    };

    // Default error show method
    FormValidator.prototype.errorShow = function($elem, errorMessage){
        var $error = $.data($elem[0], '$error');

        if(!$error){
            $elem[this.options.errorPosition]('<span class="validation-error" style="display:none;"></span>');
            $error = $elem[this.options.errorPosition == "after" ? 'next' : 'prev']('.validation-error');
            $.data($elem[0], '$error', $error);
        }

        $error.html(errorMessage);

        $elem.addClass('error');
        $error[this.options.errorShow](this.options.errorSpeed);
    },

    // Default error hide method
    FormValidator.prototype.errorHide = function($elem){
        var $error = $.data($elem[0], '$error');

        if($error){
            $elem.removeClass('error');
            $error[this.options.errorHide](this.options.errorSpeed);
        }
    };

    /**
     * Set or get an option value
     *
     * Sets the requested instance's option to a particular value. If no value is
     * passed it just returns the current option's value. Always returns the set
     * value of the requested option.
     *
     * @param string key The option key to get or set
     * @param mixed val Optional value to set the option to
     *
     * @return mixed
     */
    FormValidator.prototype.option = function( key, val ) {
        if( val != undefined )
            this.options[key] = val;

        return this.options[key];
    };

    FormValidator.prototype.reset = function() {
        for(var name in this.options.required){
            var $elem = this.elements.form.find('[name="' + name + '"]');

            // Invalidate if the field does not exist
            if($elem.length) {
                // Combine the field's model with the defaults
                var model = $.extend({
                    type: "text",
                    message: "Please fill in this required field"
                }, this.options.required[name]);

                $elem.add($elem.parent()).removeClass('invalid valid');

                // Use the model's custom method if it is available
                if(model.errorHide){
                    model.errorHide($elem);
                }
                // Use the default errorHide() method
                else {
                    this.errorHide($elem);
                }
            }
        }
    };

    FormValidator.prototype.shouldHideError = function(name, model){
        var errorHide = true;

        // Validate if the model does not have a custom errorHide method
        if(!model.errorHide){
            var pseudos = [];
            // If the element being validated is pseudo'd by other fields, find them
            for(var pname in this.options.required){
                if(this.options.required[pname].pseudo){
                    if(this.options.required[pname].pseudo == name){
                        pseudos.push(pname);
                    }
                }
            }

            var errorHide = true;
            // Loop through pseudo'd elements to make sure they are valid, if not, don't hide the error
            for(var i = 0; i < pseudos.length; i++){
                if(!this.validateField(pseudos[i], false)){
                    errorHide = false;
                }
            }

            // If the element being validated has a pseudo, it shouldn't be able to hide its pseudo element's error
            if(this.options.required[name].pseudo){
                errorHide = false;
            }
        }

        return errorHide;
    };

    FormValidator.prototype.validate = function(){
        var self = this;
        var valid = true;

        // Loop through all required fields
        for(var name in this.options.required){
            var model = this.options.required[name];
            var fieldValid = false;

            // Validate only if the when condition passes if a when condition is present
            if(model.when){
                var whenValid = 0;

                var whenCount = 0;
                for(var w in model.when) if(model.when.hasOwnProperty(w)) whenCount++;

                for(var whenSelector in model.when){
                    var whenExpected = new RegExp(model.when[whenSelector]);
                    var $when = $(whenSelector);

                    if($when.length){
                        if($when.val().match(whenExpected)){
                            whenValid++;
                        }
                    }
                }

                // Check field valid status only if the when passes
                if(whenValid == whenCount){
                    fieldValid = this.validateField(name, true);
                }
                // Validate as true if the when validation fails
                else {
                    fieldValid = true;
                }
            }
            // Otherwise, just validate
            else {
                // Field valid status
                fieldValid = this.validateField(name, true);
            }

            // Invalidate the form if the field was not valid
            if(fieldValid === false){
                valid = false;
            }
        }

        this.elements.form.data('valid', valid);
        this.elements.form.trigger('validate', [this.elements.form]);

        if(this.elements.form.data('valid') == false){
            var $errors = $('.validation-error');

            if($errors.length){
                var $visibleErrors = $errors.filter(':visible');
                if($visibleErrors.length && this.options.scrollToError == true){
                    $( 'html, body' ).animate( {
                        scrollTop: $visibleErrors.eq(0).offset().top - 50
                    }, {
                        duration: 1000
                    } );
                }
            }
        }

        return this.elements.form.data('valid');
    };

    FormValidator.prototype.validateField = function(name, showError){
        // Don't show the error by default
        if(showError == undefined){
            showError = false;
        }

        // Field valid status
        var fieldValid = false;
        // The Error type (empty|algorithm)
        var errorType = "empty";
        // Find the field
        var $elem = this.elements.form.find('[name="' + name + '"]');

        // Ignore validation if it isn't a required field
        if( !this.options.required[name] ) {
            return true;
        }

        // Invalidate if the field does not exist
        if($elem.length) {
            // Combine the field's model with the defaults
            var model = $.extend({
                type: "text",
                message: "Please fill in this required field"
            }, this.options.required[name]);

            // Validate differently based off of the type of field
            switch(model.type){
                case "checkbox":
                    if($elem.is(':checked')){
                        fieldValid = true;
                    }
                break;

                case "radio":
                    var fieldValue = "";
                    var selected = $elem.filter(':checked');
                    if(selected.length){
                        if(selected.val().trim() != ""){
                            fieldValid = true;
                        }
                    }
                break;

                default:
                case "text":
                    var fieldValue = $.trim( $elem.val() );

                    // Validate other properties if it is not empty
                    if(fieldValue != ""){
                        // Validate against the algorithm
                        if(model.algorithm){
                            if(typeof(model.algorithm) == 'object'){
                                var passRegex = new RegExp(model.algorithm.pass);
                                var failRegex = new RegExp(model.algorithm.fail);
                            } else {
                                var passRegex = new RegExp(model.algorithm);
                            }

                            if(fieldValue.match(passRegex)){
                                fieldValid = true;

                                if(failRegex){
                                    if(fieldValue.match(failRegex)){
                                        errorType = "algorithm";
                                        fieldValid = false;
                                    }
                                }
                            } else {
                                errorType = "algorithm";
                            }
                        }
                        // Mark as valid if no algorithm
                        else {
                            fieldValid = true;
                        }
                    }
                break;
            }

            // Only handle error display if its requested
            if(showError === true){
                // If the element checked is a pseudo for another element, process the error as though the other element failed
                if(model.pseudo){
                    var pseudoName = model.pseudo;
                    var model = this.options.required[pseudoName];
                    var $elem = this.elements.form.find('[name="' + pseudoName + '"]');
                }

                if(typeof(model.message) == "object"){
                    switch(errorType){
                        default:
                        case "empty":
                            var errorMessage = model.message.empty;
                        break;

                        case "algorithm":
                            var errorMessage = model.message.algorithm;
                        break;
                    }
                } else {
                    errorMessage = model.message;
                }

                // Show the field's error message if validation failed
                if(fieldValid === false){
                    $elem.add($elem.parent()).removeClass('valid').addClass('invalid');

                    // Use the model's custom method if it is available
                    if(model.errorShow){
                        model.errorShow($elem, errorMessage);
                    }
                    // Use the default errorShow() method
                    else {
                        this.errorShow($elem, errorMessage);
                    }
                }
                // Hide the field's error message
                else {
                    $elem.add($elem.parent()).removeClass('invalid').addClass('valid');

                    // Use the model's custom method if it is available
                    if(model.errorHide){
                        model.errorHide($elem);
                    }
                    // Use the default errorHide() method
                    else {
                        if(this.shouldHideError(name, model)){
                            this.errorHide($elem);
                        }
                    }
                }
            }
        }

        return fieldValid;
    };

    $.extend( $.fn, {
        validator: function(){
            var options = action = arguments;
            var _return = this;

            this.each( function( ind ) {
                // Look up if an instance already exists
                var _FormValidator = $.data( this, 'FormValidator' );

                // Else create one and store it
                if( !_FormValidator ) {
                    _FormValidator = new FormValidator( this, options );
                    $.data( this, 'FormValidator', _FormValidator );
                }

                // Act upon it
                if( action.length > 0 ) {
                    var _do = _FormValidator._run.apply( _FormValidator, action );
                    if( typeof( _do ) != 'undefined' ) {
                        _return = _do;
                    }
                }
            } );

            return _return;
        }
    });
} )( jQuery, window, null );
