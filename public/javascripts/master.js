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
		$("#webbastic_list #thumbs a").remove();
		
		// Fetch new medias from media_rocket using JSON
		url = "/medias/sites/1/galleries/" + gallery_id + "?format=json";
		console.log(url);
		$.getJSON(url,
			function(data){
				$.each(data.items, function(i,item){
					$("<img/>").attr("src", item.media.thumbnail)
						.appendTo($("<a>").attr("class", "media_thumb"))
						.appendTo("#webbastic_list #thumbs");
					if ( i == 6 ) $("<br/>").appendTo("#webbastic_list #thumbs");
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
	$(".media_gallery_select").onLoad(function() {
		load_media_thumb_list(1);
	});
	
	//
	// User click on a thumbnail to be displayed in editor
	//
	$(".media_thumb").click(function() {
		$(".mceEditor").append(this.$("img").rel)
	});
});