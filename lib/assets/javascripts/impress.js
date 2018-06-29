/*!
 * Impress Core Support Utilities
 * 
 * Copyright 2012 digital-telepathy
 */

var Impress = {
    // Computed prefixes
    computedPrefixes: ['Moz', 'ms', 'O', 'Webkit', 'Khtml'],
    
    // Cached elements
    elements: {},

    namespace: "impress",
    
    // Browser prefixes
    prefixes: ['moz', 'ms', 'o', 'webkit'],
    
    // Browser support
    support: {}
};

( function( $, window, undefined ) {

    // Check to see if the current browser supports CSS transitions
    Impress.supports = function( support ) {
        var $html = this.elements.html = this.elements.html || $('html');
        var supported = false;

        if( !this.support[support] ) {
            switch(support) {
                case "cssanimations":
                    var s = this.elements.body[0].style;
                    var p = 'transition';
                    if(typeof s[p] == 'string') { supported = true; }

                    // Tests for vendor specific prop
                    p = p.charAt(0).toUpperCase() + p.substr(1);
                    for(var i=0; i<this.computedPrefixes.length; i++) {
                        if(typeof s[this.computedPrefixes[i] + p] == 'string') { supported = true; }
                    }
                break;

                case "csstransforms3d":
                    var el = document.createElement('p'),
                    has3d,
                    transforms = {
                        'webkitTransform':'-webkit-transform',
                        'OTransform':'-o-transform',
                        'msTransform':'-ms-transform',
                        'MozTransform':'-moz-transform',
                        'transform':'transform'
                    };
                 
                    // Add it to the body to get the computed style
                    document.body.appendChild(el);
                 
                    for(var t in transforms){
                        if( el.style[t] !== undefined ){
                            el.style[t] = 'translate3d(1px,1px,1px)';
                            has3d = has3d || window.getComputedStyle(el).getPropertyValue(transforms[t]);
                        }
                    }
                 
                    document.body.removeChild(el);
                 
                    supported = (has3d !== undefined && has3d.length > 0 && has3d !== "none");
                break;
            }

            this.support[support] = supported;
        }

        return this.support[support];
    };
    
    /**
     * Get jQuery extended elements
     * 
     * Iterates through an Object of selectors and retrieves the jQuery
     * extended objects of those selectors. Returns an Object of those
     * jQuery extended objects for caching.
     * 
     * @param {Object} selectors Object of selectors to retrieve and cache
     * @param {mixed} context jQuery extended Object, selector or DOM element to use as a context
     * @param {Boolean} cached Use Impress global cache or always query new 
     * 
     * @return {Object} Object of jQuery extended elements
     */
    Impress.getElements = function( selectors, context, cached ) {
        var cached = ( cached || false );
        var elements = {};
        var self = this;
        var $context = $( context || 'html' );
        
        $.each( selectors, function( key, value ) {
            if( $.inArray( key, [window, 'body', 'html'] ) != -1 ) elements[key] = self.elements[key];

            if( $.isPlainObject( value ) ) {
                elements[key] = elements[key] || {};
                $.each( value, function( key2, value2 ) {
                    elements[key][key2] = ( cached && self.elements[value2] ) ? self.elements[value2] : self.elements[value2] = $( value2, $context );
                } );
            } else {
                elements[key] = ( cached && self.elements[value] ) ? self.elements[value] : self.elements[value] = $( value, $context );
            }
        } );
        
        return elements;
    };
    
    /**
     * Get an element's CSS transition properties
     * 
     * Uses getComputedStyle() commands to read an element's transition properties
     * and returns an object with applied values.
     * 
     * @param {Object} el DOM element, selector or jQuery Object
     * 
     * @return {Object}  
     */
    Impress.getTransition = function( el, includePrefixes ) {
        if( !window.getComputedStyle ) return {};

        var $el = $( el );
        var includePrefixes = includePrefixes || false;
        var computed = window.getComputedStyle( $el[0] );
        var properties = {
            transitionProperty: 'transition-property', 
            transitionDuration: 'transition-duration', 
            transitionDelay: 'transition-delay', 
            transitionTimingFunction: 'transition-timing-function'
        };
        
        var css = {};
        for( property in properties ) {
            css[properties[property]] = computed[property] || "";
            
            if( includePrefixes ) {
                for( var p in this.computedPrefixes ) {
                    if( this.prefixes[p] ) {
                        var prefixKey = this.computedPrefixes[p] + property.charAt(0).toUpperCase() + property.substr(1);
                        css["-" + this.prefixes[p] + "-" + properties[property]] = computed[prefixKey];
                    }
                }
            }
        }
        
        return css;
    };

    /**
     * Build an object of browser prefixed CSS3 properties
     * 
     * Pass in the un-prefixed CSS3 property to apply (e.x. transition) and the
     * value to set to build an object of CSS properties that can be applied with
     * the jQuery .css() command.
     * 
     * @param {Object} properties Un-prefixed CSS3 property to set
     * @param {Boolean} prefixValue Set to boolean(true) to prefix the value as well
     * 
     * @return {Object} Object of prefixed CSS properties to be applied with $.css()
     */
    Impress.prefixCSS = function( properties, prefixValue ) {
        var prefixValue = prefixValue || false;

        if( ie && ie < 9 ) return properties;
        
        for( var property in properties ) {
            var value = properties[property];
            
            for( var p in this.prefixes ) {
                valuePrefix = prefixValue ? '-' + this.prefixes[p] + '-' : "";
                properties['-' + this.prefixes[p] + '-' + property] = valuePrefix + value;
            }
        }
        
        return properties;
    };
    
    /**
     * Smooth Scroll utility function
     * 
     * @param mixed $el Element to scroll to. Can be either a selector or DOM element.
     * @param speed integer Optional speed in milliseconds to scroll at (defaults to 500)
     * @param offset integer Optional offset for scroll
     * @param delay integer Optional delay in milliseconds for the scrollTo effect (useful when coupling with other actions, defaults to 0)
     */
    Impress.scrollTo = function( $el, speed, offset, delay ){
        // Set a speed if it isn't specified
        speed = speed || 500;
        // Set a delay if it isn't specified (default is 0)
        delay = delay || 0;

        // Numeric positioning
        var top = $el;

        // Handle DOM element calculated offsets
        if( isNaN($el) ) {
            top = $($el).offset().top;
        }

        top = top + ( parseInt( offset, 10 ) || 0 );

        $( 'html, body' ).delay( delay ).animate( {
            scrollTop: top
        }, {
            duration: speed,
            easing: "swing",
            complete: function() {
                // Enforce window scroll
                window.scrollTo( 0, top );
            }
        } );
    };

    /**
     * Monitor resize of the window and trigger browser mode change events
     */
    Impress.resize = function() {
        this.previousMode = this.currentMode;

        if( Modernizr.mq('only screen and (max-width: 767px)') ) {
            this.currentMode = 'mobile';
        } else {
            this.currentMode = 'desktop';
        }

        if( this.previousMode != this.currentMode ) {
            this.elements.window.triggerHandler( this.namespace + ":changed-responsive-mode", [this.currentMode] );
        }
    };


    $(function(){
        // Set some basic elements
        Impress.elements.window = $(window);
        Impress.elements.body = $('body');
        Impress.elements.html = $('html');
        
        Impress.elements.window.on('resize', $.throttle( 50, function(){
            Impress.resize();
        }));
    })

} )( jQuery, window, null );
