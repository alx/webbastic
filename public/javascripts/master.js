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
	// Media Partial, add thumnail to text editor
	//
	// =====
	
	
	function load_media_thumb_list(gallery_id) {
		
		// Tell the user to wait
		$("#webbastic_list #thumbs").hide();
		$("#webbastic_list #spinner").show();
		
		// Remove existing thumbs
		$("#webbastic_list #thumbs a.media_thumb").remove();
		
		// Fetch new medias from media_rocket using JSON
		$.getJSON("/library/galleries/" + gallery_id + "/medias/index.json",
			function(data){
				$.each(data.medias, function(i,media){
					$("#webbastic_list #thumbs").append(
						"<a class='media_thumb' rel='" + media.url + "'>" +
						"<img src='" + media.icon + "' title='" + media.title + "'/>" +
						"</a>"
					);
					if ( i == 6 ) $("#webbastic_list #thumbs").append("<br/>");
				});
			}
		);
		
		// Show the user the loaded images
		$("#webbastic_list #spinner").hide();
		$("#webbastic_list #thumbs").show();
	}
	
	//
	// Select box changed:
	// call method to load media_thumb_list
	// with first gallery
	//
	$("#media_gallery_select").change(function() {
		// call method to load media_thumb_list
		// with selected gallery
		load_media_thumb_list($("#webbastic_list option:selected").val());
	});
	
	//
	// Document Loading:
	// call method to load media_thumb_list
	// with first gallery
	//
	$(".media_gallery_select").ready(function() {
		load_media_thumb_list(1);
	});
	
	//
	// User click on a thumbnail to be displayed in editor
	//
	$(".media_thumb").click(function() {
		$(".mceEditor").append(this.$("img").rel)
	});
});