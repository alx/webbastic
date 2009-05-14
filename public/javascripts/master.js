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


	// User has selected mode-display for gallery
	$('input.mode-display').click(function() {
		
		// Uncheck first
		$('input.mode-external.gallery-'+gallery_id).attr("checked", false);
		
		if (match = $(this).attr('class').match(/gallery-(\d+)/)) var gallery_id = match[1]
		var header_value = $('span.edit_header.linked_galleries').value;

		// Replace gallery link in header by comma, if already present
		// regexp reading: 1http://abc.com,2http://bcd.com -> [,gallery_id|http...,]
		var match = new RegExp(','+gallery_id+'.*?,','i').exec(header_value);

		// Only make a new post if gallery can be deleted
		if(match != null & match[1].length > 0) {
			header_value.replace(match[1], ',')
			post_header_value('linked_galleries', header_value);
		}
	});

	$('input.mode-external').click(function() {
		
		// Uncheck first
		$('input.mode-display.gallery-'+gallery_id).attr("checked", false);

		// Fetch gallery_id from input.class attribute
			if (match = $(this).attr('class').match(/gallery-(\d+)/)) var gallery_id = match[1]
		// Fetch current header[linked_galleries] value
		var header_value = $('span.edit_header.linked_galleries').value;

		// Replace gallery link in header by comma, if already present
		// regexp reading: 1http://abc.com,2http://bcd.com -> [,gallery_id|http...,]
		var match = new RegExp(','+gallery_id+'.*?,','i').exec(header_value);
		if(match != null && match[1].length > 0) header_value.replace(match[1], ',')

		jPrompt('URL Externe:', 'http://', 'Gallery Mode', function(r) {
			if( r ) {
				// send the current header value with the new [id, link] hash
				// inside header[linked_galleries] value
				post_header_value('linked_galleries', header_value + ',' + gallery_id + r);
			} 
		});
	});

});