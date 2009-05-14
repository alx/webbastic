$(document).ready(function() {

	// =====
	//
	// Form: clear values when user focus on the textfield
	//
	// =====

	$.fn.clear_value = function() {
		return this.focus(function() {
			if( this.value == this.defaultValue ) {
				this.value = "";
			}
		}).blur(function() {
			if( !this.value.length ) {
				this.value = this.defaultValue;
			}
		});
	};

	$(".clear").clear_value();

	// =====
	//
	// File Tree
	//
	// ===== 

	// $('#file_tree').fileTree({ root: '', script: 'content' });

	// =====
	//
	// Generate spinner
	//
	// =====

	$('a#generate').click( function() {
		$('span#generate-status').addClass('hidden');
		$('span#generate-spinner').removeClass('hidden');
	});

	// =====
	//
	// GalleryBuilder edit_partial
	//
	// =====
	
	function post_header_value(header_name, header_value) {
		var data = '_method=PUT&header[name]=' + header_name + '&header[content]='+header_value;
		var widget_id = $('input#current-widget')[0].value.split('-').pop();
		$.post('/cms/widgets/' + widget_id, data);
		if (input = $('input#' + header_name)) $(input).attr('value', header_value);
	}

	function post_displayed_galleries() {
		var widget_content = '';
		$('input.checkbox_gallery:checked').each(function(index, item){
			gallery_id = item.name.split('_').pop();
			widget_content += gallery_id + ',';
		});
		post_header_value('displayed_galleries', widget_content);
	}

	$('input.checkbox_gallery').click(function() {
		post_displayed_galleries();
	});

	$('a.select_all').click(function() {
		$('input.checkbox_gallery').attr('checked', true);
		post_displayed_galleries();
	});

	$('a.deselect_all').click(function() {
		$('input.checkbox_gallery').attr('checked', false);
		post_header_value('displayed_galleries', 0);
	});
	
	// Return header_value parameter without current url
	function clean_header_value(gallery_id) {
		// Fetch current header[linked_galleries] value
		var header_value = $('input#linked-galleries')[0].value;
		
		// Replace gallery link in header by comma, if already present
		// regexp reading: 1http://abc.com,2http://bcd.com -> [,gallery_id|http...,]
		var match = new RegExp('('+gallery_id+'http:.[^,]*)','i').exec(header_value);
		
		if(match != null && match[1].length > 0){
			return header_value.replace(match[1], ',')
		} else {
			return header_value;
		}
	}
	
	// User has selected mode-display for gallery
	$('input.mode-display').click(function() {
		
		// Fetch gallery_id from input.class attribute
		if (match = $(this).attr('class').match(/gallery-(\d+)/)) var gallery_id = match[1]
		
		// Uncheck first
		$('input.mode-external.gallery-'+gallery_id).attr("checked", false);
		
		// send header value without current gallery
		post_header_value('linked_galleries', clean_header_value(gallery_id));
	});

	$('input.mode-external').click(function() {
		
		// Fetch gallery_id from input.class attribute
		if (match = $(this).attr('class').match(/gallery-(\d+)/)) var gallery_id = match[1]
		
		// Uncheck first
		$('input.mode-display.gallery-'+gallery_id).attr("checked", false);
		
		
		jPrompt('URL Externe:', 'http://', 'Gallery Mode', function(r) {
			if( r ) {
				// send the current header value with the new [id, link] hash
				// inside header[linked_galleries] value
				post_header_value('linked_galleries', gallery_id + r + ',' + clean_header_value(gallery_id));
			} else {
				// prompt canceled, recheck display mode
				$('input.mode-external.gallery-'+gallery_id).attr("checked", false);
				$('input.mode-display.gallery-'+gallery_id).attr("checked", true);
			}
		});
	});

});