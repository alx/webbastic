$(document).ready(function() {
	
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
		$.getJSON("/library/gallery/" + gallery_id + ".json",
			function(data){
				$.each(data.medias, function(i,media){
					$("#webbastic_list #thumbs").append(
						"<a class='media_thumb' rel='" + media.url + "' type='" + media.mime + "'>" +
						"<img src='" + media.icon + "' alt='" + media.title + "'/>" + media.title +
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
		load_media_thumb_list(this.value);
	});

	//
	// Document Loading:
	// call method to load media_thumb_list
	// with first gallery
	//
	if ( $("#media_gallery_select").length > 0 ) {
			load_media_thumb_list('first');
	});

	//
	// User click on a thumbnail to be displayed in editor
	//
	$('a.media_thumb').livequery('click', function(event) {
		switch(this.type){
			case "jpg":
			case "jpeg":
			case "gif":
			case "png":
				$.wymeditors(0).insert("<img src='" + this.rel + "'/>");
				break
			case "mp3":
				var flash_player = "<object type='application/x-shockwave-flash' width='400' height='170' ";
				flash_player += "data='/slices/webbastic/flash/xspf_player_slim.swf?";
				flash_player += "song_url='" + this.rel + "'>";
				flash_player += "<param name='movie' value='/slices/webbastic/flash/xspf_player_slim.swf?";
				flash_player += "song_url='" + this.rel + "'>";
				flash_player += this.rel + "' /></object>";
				$.wymeditors(0).insert(flash_player);
				break
			default:
				title = this.firstChild.alt;
				$.wymeditors(0).insert("<a href='" + this.rel + "'/>" + title + "</a>");
		}
		return false; 
	});
	
	//
	// In gallery builder widget, user can select the gallery to be displayed after generation
	// Send id of selected galleries to widget headers "displayed_galleries"
	//
	$('.checkbox_gallery').livequery('click', function(event) {
		
		// Fetch widget_id
		widget_id = $(this).parents('select').name.split("_").pop();

		// Build gallery ids list that will be the content of the widget header "displayed_galleries"
		var galleries = "";
		$(this).parents('select').children('option').each( function(index){
			galleries += $(this).name.split("_").pop() + ",";
		});

		// query on widgets to modify header,
		// method is defined in widget help to have the right route to header update
		update_widget(galleries);

		return false; 
	});
});