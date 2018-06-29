/*!
 * CSS Slider jQuery plugin
 *
 * @author digital-telepathy
 * 
 * Copyright (C) 2013 digital-telepathy  (http://www.dtelepathy.com/)
 * 
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

( function( $, window, undefined, I ) {
    var CSSSlider = function( el, params ) {
        // Visibility of dropdown navigation
        this._dropdownNavVisible = false;

        // Event trigger counts
        this._eventTrigger = {};

        // Is the interface device interacting
        this._interacting = false;
        this._interactingOffset = {
            top: -1,
            left: -1
        };

        // Cached elements
        this.elements = {};

        // Disable slider boolean
        this.disabled = false;

        // The current slide
        this.current = 0;

        // The previous slide
        this.previous = -1;

        // Namespace
        this.namespace = "slider";

        // CSSSlider Width
        this.sliderWidth = -1;

        // CSSSlider Height
        this.sliderHeight = -1;

        // Navigation "gutter"
        this.navigationGutter = 0;

        // Auto play?
        this.autoPlay = false;

        // Default Swipe Prevention - used to disable X or Y swipe based off orientation of slider
        this.preventDefaultSwipeX = false;
        this.preventDefaultSwipeY = true;

        // Figure out where the nav is, if present
        this.childNav = false;

        // Default options
        this.options = {
            easing: "ease-in-out",              // CSS easing
            loop: true,                         // Loop around to the other end ("rewind" for now)
            method: 'css',                      // Method for animation (css|animate)
            navigation: '>.slider-navigation',  // Optional navigation element
            navigationWidth: "24%",             // Default width of the navigation
            next: '>.next',                     // Previous button selector
            orientation: 'horizontal',          // Orientation of slider
            prev: '>.prev',                     // Next button selector
            slides: '>.slide',                  // Slide elements selector (defaults to children)
            speed: 500,                         // Animation speed in milliseconds
            start: 0,                           // Start slide
            touch: false,                       // Enable touch support
            autoPlay: false,                    // Start autoplay
            autoPlayDelay: 5000,                // Delay between slides for autoplay in milliseconds
            dropdownNav: true,                  // Enable support for a responsive dropdown navigation for vertical sliders
            touchThreshold: 4,                  // Sensitivty in X vs Y scroll for preventing animation/inertaction
            dynamicHeight: 'none',              // Enable dynamic height (none|pogo|tallest)
            disabledMediaQuery: false           // Set the media query at which the slider should be disabled
        };

        this.initialize( el, params );
    };

    // Build navigation elements themselves
    CSSSlider.prototype._addNavigationElements = function( container ) {
        var self = this;

        this.elements.slides.each( function( ind ) {
            var $slide = self.elements.slides.eq( ind );
            var label = $slide.data( 'label' ) || "Slide " + ( ind + 1 );

            container.append( '<a href="#" data-slide="' + ind + '"><span>' + label + '</span></a>' );
        } );
    };

    // Adjust the dimensions of the CSSSlider
    CSSSlider.prototype._adjustDimensions = function() {
        var self = this;

        this.sliderWidth = this.elements.slider.width();
        this.sliderHeight = this._getSliderHeight();

        if( this.elements.navigation.length && this.options.orientation == "vertical" ) {
            if( Modernizr.mq( 'only screen and (max-width: 767px)' ) ) {
                this.showDropdownNav();
            } else {
                this.hideDropdownNav();
            }
        }

        // Get navigation gutter dimensions
        this._getNavigationDimensions();

        if( this.disabled == false ) {

            this.elements.slides.each( function( ind ) {
                var css = {
                    position: 'absolute',
                    left: ( ind - self.current ) * ( self.sliderWidth + self.navigationGutter),
                    width: self.sliderWidth - self.navigationGutter,
                    height: self.sliderHeight
                };

                if( self.options.orientation == "vertical" ) {
                    css.left = self.navigationGutter;
                    css.top = ( ind - self.current ) * self.sliderHeight;
                }

                self.elements.slides.eq( ind ).css( css, $.extend( I.prefixCSS( { transition: 'left 0ms, top 0ms' } ) ) );
            } );

            // Adjust slider height if dynamicHeight is being used
            self._setDynamicSliderHeight();

            // Adjust navigation dimensions if present
            if( this.elements.navigation.length && this.options.orientation == "vertical" ) {
                this.elements.navigation.width( this.navigationGutter );

                this.elements.navigation.height( this.sliderHeight );
                this.elements.navigationLinks.css( {
                    height: Math.round( this.sliderHeight / this.elements.navigationLinks.length )
                } );
            }
        } else {
            var css;

            if(this.options.dynamicHeight !== 'none'){
                this.elements.slider.css({
                    height: 'auto'
                });

                css = {
                    height: 'auto',
                    width: 'auto'
                };
            }

            this.elements.slides.each( function( ind ) {
                css = $.extend(css, {
                    position: 'relative',
                    left: 'auto'
                });

                self.elements.slides.eq( ind ).css( css, $.extend( I.prefixCSS( { transition: 'left 0ms, top 0ms' } ) ) );
            } );
        }
    };

    CSSSlider.prototype._autoPlay = function() {
        var self = this;

        setTimeout( function() {
            if( self.autoPlay ) {
                self.next();
            }

            self._autoPlay();
        }, this.options.autoPlayDelay );
    }

    CSSSlider.prototype._bindEvents = function(){
        var self = this;

        // Previous Button
        this.elements.prev.on( 'click', function( event ) {
            event.preventDefault();

            // Turn off autoplay
            self.autoPlay = false;

            self.prev();
        } );

        // Next Button
        this.elements.next.on( 'click', function( event ) {
            event.preventDefault();

            // Turn off autoplay
            self.autoPlay = false;

            self.next();
        } );

        // Navigation elements
        this.elements.navigation.on( 'click', 'a', function( event ) {
            event.preventDefault();

            var $this = $.data( this, '$this' ) || $.data( this, '$this', $( this ) );

            // Turn off autoplay
            self.autoPlay = false;

            self.goTo( $this.data( 'slide' ) );
        } );

        // Reset animating property
        this.elements.body.on( 'transitionend webkitTransitionEnd oTransitionEnd MSTransitionEnd', function( event ) {
            if( self.elements.slides.filter( event.target ).length ) {
                self._eventComplete();
            }
        } );

        this.elements.slider.on( 'mousedown', function( event ) {
            // Only respect left click
            if( event.button <= 1 ) self._touchStart( event );
        } ).on( 'mousemove', function( event ) {
            // Only respect left click
            if( event.button <= 1 ) self._touchMove( event );
        } ).on( 'mouseup', function( event ) {
            // Only respect left click
            if( event.button <= 1 ) self._touchEnd( event );
        } );

        if( window.addEventListener ) {
            this.elements.slider[0].addEventListener( 'touchstart', self._touchStart, false );
        }

        // Resize watcher
        $( window ).resize( function() {
            // Adjust width
            self._adjustDimensions();
        } ).resize( $.throttle( 250, function() {
            // Reset transition rules
            self._setTransition();
            self._checkDisable();
        } ) );

        // Navigation before action
        this.elements.slider.on( this.namespace + ':before', function( event, slider, index ) {
            var label = self.elements.slides.eq( index ).data( 'label' ) || "Slide " + ( index + 1 );

            self._adjustDimensions();

            // Update dropdown navigation
            if( typeof( self.elements.dropdownNav ) != 'undefined' ) {
                // Update the selected slide display
                self.elements.dropdownNavSelected.text( label );

                // Update the active dropdown option
                self.elements.dropdownNavLinks.removeClass( 'active' ).eq( index ).addClass( 'active' );
            }

            // Update regular navigation
            if( self.elements.navigation.length ) {
                self.elements.navigationLinks.removeClass( 'active' ).eq( index ).addClass( 'active' );
            }
        } );
    };

    CSSSlider.prototype._build = function() {
        var self = this;

        // if dynamicHeight is set
        if( this.options.dynamicHeight != 'none' ) {
            // wrap the markup in slide-inner
            this.elements.slides.wrapInner('<div class="slide-inner"></div>');
            if( this.options.dynamicHeight == 'tallest' ) {
                this.elements.slides.wrapInner('<div class="slide-tallest-inner"></div>');
            }
        }

        // this.sliderHeight = this._getSliderHeight();
        this.sliderHeight = this.elements.slider.height();
        this.sliderWidth = this.elements.slider.width();

        // Build navigation if present
        if( this.elements.navigation.length ) {
            this._buildNavigation();
        }

        if( this.elements.slider.find( this.options.navigation ).length > 0 ) {
            this.childNav = true;
        }

        // Setup the transition rules
        if( this.options.method == "css" ) {
            this._setTransition();
        }

        this.elements.slides.each( function( ind ) {
            var css = {

                left: ( ind - self.current ) * self.sliderWidth
            };

            // TODO:: accomodate for dynamicHeight options
            if( self.options.orientation == "vertical" ) {
                self.preventDefaultSwipeX = true;
                self.preventDefaultSwipeY = false;
                css = $.extend( css, {
                    left: this.navigationGutter,
                    top: ( ind - self.current ) * self.sliderHeight,
                    width: self.sliderWidth,
                    height: self.sliderHeight
                } );
            }

            self.elements.slides.eq( ind ).css( css );
        } );

        this.elements.slider.triggerHandler( this.namespace + ':built', [ this, this.current ] );
    };

    // Build responsive dropdown navigation
    CSSSlider.prototype._buildDropdownNav = function() {
        var self = this;

        this.elements.dropdownNav = $( '<div class="' + this.namespace + '-dropdown-nav" />' ).insertBefore( this.elements.slider );
        this.elements.dropdownNavSelected = $( '<div class="' + this.namespace + '-dropdown-nav-selected" />' ).appendTo( this.elements.dropdownNav );
        this.elements.dropdownNavOptions = $( '<div class="' + this.namespace + '-dropdown-nav-options" />' ).appendTo( this.elements.dropdownNav );
        this.elements.dropdownNavList = $('<div class="' + this.namespace + '-dropdown-nav-list" />' ).appendTo( this.elements.dropdownNavOptions );

        // Build and append navigation elements to the dropdown nav options
        this._addNavigationElements( this.elements.dropdownNavList );

        this.elements.dropdownNavLinks = this.elements.dropdownNavOptions.find('a');

        // Set current selected value
        this.elements.dropdownNavSelected.text( this.elements.dropdownNavLinks.eq( this.current ).addClass( 'active' ).text() );

        // Bind dropdown display event
        this.elements.dropdownNavSelected.on( 'click', function( event ) {
            event.preventDefault();

            self.elements.dropdownNavOptions.show();

            self.elements.body.on( 'click.' + self.namespace, function( event ) {
                if( $( event.target ).closest( '.' + self.namespace + '-dropdown-nav-list, .' + self.namespace + '-dropdown-nav-selected').length < 1 ) {
                    self.elements.dropdownNavOptions.hide();
                    self.elements.body.off( 'click.' + self.namespace );
                }
            } );
        } );

        // Bind dropdown selection interaction
        this.elements.dropdownNavOptions.on( 'click', 'a', function( event ) {
            event.preventDefault();

            var $this = $.data( this, '$this' ) || $.data( this, '$this', $( this ) );

            // Hide the selection dropdown and unbind the click event
            self.elements.dropdownNavOptions.hide();
            self.elements.body.off( 'click.' + self.namespace );

            // Turn off autoplay
            self.autoPlay = false;

            self.goTo( $this.data( 'slide' ) );
        } );
    };

    // Build navigation
    CSSSlider.prototype._buildNavigation = function() {
        var self = this;

        // Build and append navigation elements to the vertical nav
        this._addNavigationElements( this.elements.navigation );

        this.elements.navigationLinks = this.elements.navigation.find( 'a' );

        // Set the active state
        this.elements.navigationLinks.eq( this.current ).addClass( 'active' );

        // Only build a sized navigation if this is a vertical slider
        if( this.options.orientation == 'vertical' ) {
            var navHeight = ( this.sliderHeight / this.elements.slides.length );
            this._getNavigationDimensions();

            this.elements.navigation.css( {
                position: "absolute",
                top: 0,
                left: 0,
                width: this.navigationGutter,
                height: this.sliderHeight
            } );
            this.elements.navigationLinks.css( {
                position: "relative",
                height: navHeight + "px"
            } ).eq( this.current ).addClass( 'active' );
        }
    };

    CSSSlider.prototype._checkDisable = function() {
        if( Modernizr.mq( this.options.disabledMediaQuery ) ) {
            this.disabled = true;
        } else {
            this.disabled = false;
        }
    }

    // Animation complete event
    CSSSlider.prototype._eventComplete = function() {
        // Only allow the event to trigger once the last slide has completed
        if( this._triggerEvent( 'complete' ) ) {
            this.animating = false;

            this.elements.slider.triggerHandler( this.namespace + ':complete', [ this ] );

            this._eventTrigger.complete = 0;
        }
    };

    // Get and cache elements used by this Class Instance
    CSSSlider.prototype._getElements = function() {
        // Body element
        this.elements.body = $(document.body);

        // Get slide elements
        this.elements.slides = this.elements.slider.find( this.options.slides );

        // Previous/Next buttons
        this.elements.prev = this.elements.slider.find( this.options.prev );
        if( !this.elements.prev.length ) this.elements.prev = $( this.options.prev );
        this.elements.next = this.elements.slider.find( this.options.next );
        if( !this.elements.next.length ) this.elements.next = $( this.options.next );

        // Navigation element
        this.elements.navigation = this.elements.slider.find( this.options.navigation );
        if( !this.elements.navigation.length ) this.elements.navigation = $( this.options.navigation );
    };

    // Get dimensions for the navigation if it exists and updates the navigationGutter parameter
    CSSSlider.prototype._getNavigationDimensions = function(){
        // Don't change the gutter if we don't have navigation
        if( this.elements.navigation.length == 0 ) return false;

        // Don't change the gutter if the slider isn't vertical
        if( this.options.orientation != 'vertical' ) return false;

        this.navigationGutter = this.options.navigationWidth;

        if( this.options.navigationWidth.indexOf( '%' ) != -1 ) {
            this.navigationGutter = parseFloat( this.options.navigationWidth.replace( "%", "" ) ) / 100 * this.sliderWidth;
        }

        // Override the width to 0 if the dropdown nav is visible
        if( this._dropdownNavVisible ) this.navigationGutter = 0;
    };

    /**
     * Return height of slider
     *
     * Checking to see if dynamicHeight is set and returning height accordingly
     *
     * @return integer
     */
    CSSSlider.prototype._getSliderHeight = function() {
        var self = this,
            sliderHeight = 0;

        if( this.options.dynamicHeight != 'none' ) {
            if( this.options.dynamicHeight == 'tallest' ) {
                var slideHeights = new Array();
                $(this.elements.slides).each( function( index ) {
                    slideHeights.push( $(self.elements.slides.get( index )).find('.slide-inner').get(0).scrollHeight );
                });
                sliderHeight = Math.max.apply(Math, slideHeights);
            } else if( this.options.dynamicHeight == 'pogo' ) {
                sliderHeight = $(this.elements.slides.get( self.current )).find('.slide-inner').get(0).scrollHeight;
            }

        } else {
            sliderHeight = this.elements.slider.height();
        }
        return sliderHeight;
    };

    /**
     * Set dynamic height of slider
     *
     * Check if dynamicHeight is set and if navigation was found inside the slider
     * then set the height of the slider
     */
    CSSSlider.prototype._setDynamicSliderHeight = function() {
        var self = this;

        if( this.options.dynamicHeight != "none" ) {
            var navHeightOffset = 0;
            if( this.childNav ) {
                navHeightOffset = this.elements.navigation.get(0).scrollHeight;
            }
            var css = {
                height: this.sliderHeight + navHeightOffset
            }
            this.elements.slider.css( css, $.extend( css, I.prefixCSS( { 'transition': 'height 250ms' } ) ) );
        }
    };

    /**
     * Set CSS transition rules to a slide or slides
     *
     * Applies browser prefixed CSS transition rules to slides or, if passed, a single
     * slide element.
     *
     * @param object slide Optional jQuery extended slide object
     */
    CSSSlider.prototype._setTransition = function( slide ) {
        var self = this;

        // Setup the prefixed transition rules
        var css = I.prefixCSS( { transition: 'left ' + this.options.speed + 'ms ' + this.options.easing + ', top ' + this.options.speed + 'ms ' + this.options.easing } );

        // Apply to a single slide
        if( slide != undefined ) {
            slide.css( css );
        }
        // Otherwise, apply to all slides
        else {
            this.elements.slides.css( css );
        }
    };

    /**
     * Stop touch interacting with slider
     *
     * Fire on "mouseup" or "touchend" events to stop the drag interaction
     *
     * @param object event The event being fired
     */
    CSSSlider.prototype._touchEnd = function( event ) {
        var slider = ($(this).data("CSSSlider") == undefined)? this : $(this).data("CSSSlider");

        if( (slider.options.touch === false) || (slider.disabled === true) ) return false;

        if( window.addEventListener ) {
            slider.elements.slider[0].removeEventListener( 'touchmove', slider._touchMove, false );
        }

        slider._interacting = false;

        slider._interactingOffset.end = slider._touchOffset( event );

        slider.elements.slides.css( I.prefixCSS( { 'transition-duration': slider.options.speed + 'ms' } ) );

        var breach = false;
        var direction = 'next';
        if( slider.options.orientation == "horizontal" ) {
            breach = Math.abs( slider._interactingOffset.left / slider.sliderWidth ) >= 0.5;
            if( slider._interactingOffset.left > 0 ) direction = 'prev';
        } else {
            breach = Math.abs( slider._interactingOffset.top / slider.sliderHeight ) >= 0.5;
            if( slider._interactingOffset.top > 0 ) direction = 'prev';
        }

        if( slider._interactionMoving && breach ) {
            // Turn off Autoplay
            slider.autoPlay = false;

            slider[direction]();
        } else {
            slider.elements.slides.each( function( ind ) {
                var css = {};

                if( slider.options.orientation == "horizontal" ) {
                    css.left = ( ind - slider.current ) * slider.sliderWidth;
                } else {
                    css.top = ( ind - slider.current ) * slider.sliderHeight;
                }

                slider.elements.slides.eq( ind ).css( css );
            } );
        }

        if( window.addEventListener ) {
            slider.elements.slider[0].removeEventListener( 'touchend', slider._touchEnd, false );
        }
    };

    /**
     * Touch interacting with slider
     *
     * Fire on "mousemove" or "touchmove" events to drag the slides of the slider
     *
     * @param object event The event being fired
     */
    CSSSlider.prototype._touchMove = function( event ) {
        var slider = ($(this).data("CSSSlider") == undefined)? this : $(this).data("CSSSlider");

        if( (slider.options.touch === false) || (slider.disabled === true) ) return false;

        if( slider._interacting ) {
            slider._interactionMoving = true;

            var offset = slider._touchOffset( event );

            slider._interactingOffset.left = offset.left - slider._interactingOffset.start.left;
            slider._interactingOffset.top = offset.top - slider._interactingOffset.start.top;

            // x axis swipe
            if((Math.abs(slider._interactingOffset.left) > Math.abs(slider._interactingOffset.top) )){
                if(slider.options.orientation == "horizontal") {
                    event.preventDefault();
                }
                if ( slider.preventDefaultSwipeX ) {
                    return false;
                }
            // y axis swipe
            }else if(( Math.abs(slider._interactingOffset.top) > Math.abs(slider._interactingOffset.left) )){
                if(slider.options.orientation == "vertical") {
                    event.preventDefault();
                }
                return false;
            }

            slider.elements.slides.each( function( ind ) {
                var css = {};

                if( slider.options.orientation == "horizontal" ) {
                    css.left = ( ( ind - slider.current ) * slider.sliderWidth ) + slider._interactingOffset.left;
                } else {
                    css.top = ( ( ind - slider.current ) * slider.sliderHeight ) + slider._interactingOffset.top;
                }

                slider.elements.slides.eq( ind ).css( css );
            } );
        }
    };

    /**
     * Touch Event Offset
     *
     * Returns the top and left offset of a "touch" or drag interaction on the
     * slider element. Automatically determines what event type is being triggered.
     * Returns an object with "top" and "left" values in integer format
     *
     * @param object event The event being fired
     *
     * @return object
     */
    CSSSlider.prototype._touchOffset = function( event ) {
        var offset = {
            top: -1,
            left: -1
        };

        if( event.touches ) {
            if( event.touches.length ) {
                if( event.touches[0].pageY ) offset.top = event.touches[0].pageY;
                if( event.touches[0].pageX ) offset.left = event.touches[0].pageX;
            }
        } else {
            offset.top = event.screenY;
            offset.left = event.screenX;
        }

        return offset;
    };

    /**
     * Start touch interaction with slider
     *
     * Fire on "mousedown" or "touchstart" events to start dragging the slides of the slider
     *
     * @param object event The event being fired
     */
    CSSSlider.prototype._touchStart = function( event ) {
        var slider = ($(this).data("CSSSlider") == undefined)? this : $(this).data("CSSSlider");
        
        if( (slider.options.touch === false) || (slider.disabled === true) ) return false;

        slider._interacting = true;
        slider._interactionMoving = false;

        var offset = slider._touchOffset( event );

        // Turn off autoplay
        slider.autoPlay = false;

        slider._interactingOffset = {
            top: offset.top,
            left: offset.left,
            start: {
                top: offset.top,
                left: offset.left
            }
        };

        slider.elements.slides.css( I.prefixCSS( { 'transition-duration': '0ms' } ) );

        if( window.addEventListener ) {
            slider.elements.slider[0].addEventListener( 'touchmove', slider._touchMove, false );
            slider.elements.slider[0].addEventListener( 'touchend', slider._touchEnd, false );
        }
    };

    /**
     * Check if an event can be fired
     *
     * Incremenets an even trigger counter to force the event trigger to only fire
     * once it's parent even has triggered for each slide. Returns a boolean and
     * resets the count whenever the event can actually be fired.
     *
     * @param string eventname The name of the event to check
     *
     * @return boolean
     */
    CSSSlider.prototype._triggerEvent = function( eventname ) {
        if( this._eventTrigger[eventname] == undefined ) this._eventTrigger[eventname] = 0;

        this._eventTrigger[eventname]++;

        if( this._eventTrigger[eventname] == this.elements.slides.length ) {
            this._eventTrigger[eventname] = 0;
            return true;
        }

        return false;
    };

    /**
     * Go to a particular slide
     *
     * @param mixed A zero-indexed integer of the slide, a CSS selector or DOM Object
     */
    CSSSlider.prototype.goTo = function( slide ) {
        if( this.disabled == false ) {
            var index = -1;

            switch( typeof( slide ) ) {
                case 'number':
                    index = slide;
                break;

                case 'string':
                case 'object':
                    index = this.elements.slides.index( $( slide ) );
                break;
            }

            if( index > -1 ) {
                this.slide( index );
            }
        }
    };

    // Hide dropdown navigation
    CSSSlider.prototype.hideDropdownNav = function() {
        // Set visibility of dropdown nav
        this._dropdownNavVisible = false;

        if( typeof( this.elements.dropdownNav ) != 'undefined' ) this.elements.dropdownNav.hide();
        this.elements.navigation.show();
    };

    CSSSlider.prototype.initialize = function( el ) {
        var self = this;

        // Merge options for this instance with defaults
        this.options = $.extend( this.options, arguments[1][0] || {}, $( el ).data() );

        // Set autoPlay state based off option value
        this.autoPlay = this.options.autoPlay;

        // Fall back to jQuery Animation if the browser doesn't support CSS Transitions
        if( !I.supports( 'cssanimations' ) ) {
            this.options.method = "animate";
        }

        // Set current slide to start slide requested
        this.current = this.options.start;

        // Cache slider element
        this.elements.slider = $( el );

        // Cache elements used by this instance
        this._getElements();

        // Bind events
        this._bindEvents();

        // Check if it should be disabled
        this._checkDisable();

        // Build the slider
        this._build();

        // Start autoplay timer
        this._autoPlay();

        this._adjustDimensions();
        setTimeout(function(){
            self._setTransition();
        }, 100);

    };

    // Go to the next slide
    CSSSlider.prototype.next = function() {
        if( this.disabled == false ) {
            var slide = Math.min( this.elements.slides.length - 1, this.current + 1 );
            if( Modernizr.mq( 'only screen and (max-width: 767px)' ) ) {
                if( this.options.loop !== false && ( this.current == this.elements.slides.length - 1 ) ) {
                    slide = 0;
                }
            } else {
                if( this.options.loop !== false && ( this.current == this.elements.slides.length - 2 ) ) {
                    slide = 1;
                }
                else if( this.options.loop !== false && ( this.current == this.elements.slides.length - 2 ) ) {
                    slide = this.elements.slides.length - 2;
                }
            }

            this.goTo( slide );
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
    CSSSlider.prototype.option = function( key, val ) {
        if( val != undefined )
            this.options[key] = val;

        return this.options[key];
    };

    // Go to the previous slide
    CSSSlider.prototype.prev = function() {
        if( this.disabled == false ) {
            var slide = Math.max( 0, this.current - 1 );

            if( Modernizr.mq( 'only screen and (max-width: 767px)' ) ) {
                if( this.options.loop !== false && this.current == 0 ) {
                    slide = this.elements.slides.length - 1;
                }
            } else {
                if( this.options.loop !== false && this.current == 1 ) {
                    slide = this.elements.slides.length - 2;
                }
            }

            this.goTo( slide );
        }
    };

    /**
     * Method for doing actions passed to an instantiated slider
     *
     * Takes multiple arguments:
     *
     * @param action string The action to run. This should be a public method of the CSSSlider Class like "prev" or "goTo"
     * @param args mixed Optional arguments which may or may not be required by a method
     */
    CSSSlider.prototype.run = function() {
        var arguments_array = [];
        for( var i = 0; i < arguments.length; i++ ) {
            arguments_array.push( arguments[i] );
        }

        var action = arguments_array[0];
        var args = arguments_array.length > 1 ? arguments_array.slice( 1 ) : [];

        if( typeof( this[action] ) == 'function' ) {
            return this[action].apply( this, args );
        } else if( typeof( this[action] ) != 'undefined' ) {
            if( args.length > 0 ) this[action] = args[0];
            return this[action];
        }
    };

    /**
     * Slide to a slide
     *
     * @param integer A zero-indexed integer of the slide to slide to
     */
    CSSSlider.prototype.slide = function( index ) {
        var self = this;

        this.animating = true;

        this.previous = this.current;

        this.current = index;

        this.elements.slider.triggerHandler( this.namespace + ":before", [ this, index ] );

        // Update active navigation
        if( this.elements.navigation.length ) {
            this.elements.navigationLinks.removeClass( 'active' ).eq( this.current ).addClass( 'active' );
        }

        this.elements.slides.each( function( ind ) {
            var $slide = self.elements.slides.eq( ind );

            // Stop all queued jQuery animations if animating via JavaScript
            if( self.options.method == "animate" ) {
                $slide.stop();
            }

            var css = {};
            if( self.options.orientation == "horizontal" ) {
                css.left = ( ind - self.current ) * self.sliderWidth;
            } else {
                css.top = ( ind - self.current ) * self.sliderHeight;
            }

            $slide[self.options.method]( css, self.options.speed, function() {
                if( self.options.method != "css" ) {
                    self._eventComplete.apply( self );
                }
            } );
        } );
    };

    // Show the dropdown navigation
    CSSSlider.prototype.showDropdownNav = function() {
        // Fail silently if dropdown nav is turned off
        if( !this.options.dropdownNav ) {
            return false;
        }

        // Build the dropdown nav if it hasn't been built already
        if( !this.elements.dropdownNav ) {
            this._buildDropdownNav();
        }

        // Set visibility of dropdown nav
        this._dropdownNavVisible = true;

        this.elements.dropdownNav.show();
        this.elements.navigation.hide();
    };

    $.extend( $.fn, {
        cssSlider: function() {
            var options = action = arguments;
            var _return = this;

            this.each( function( ind ) {
                // Look up if an instance already exists
                var _CSSSlider = $.data( this, 'CSSSlider' );

                // Else create one and store it
                if( !_CSSSlider ) {
                    _CSSSlider = new CSSSlider( this, options );
                    $.data( this, 'CSSSlider', _CSSSlider );
                }

                // Act upon it
                if( action.length > 0 ) {
                    var _do = _CSSSlider.run.apply( _CSSSlider, action );
                    if( typeof( _do ) != 'undefined' ) {
                        _return = _do;
                    }
                }
            } );

            return _return;
        }
    } );
} )( jQuery, window, null, Impress );
