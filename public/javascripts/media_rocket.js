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
		$.getJSON("/library/galleries/" + gallery_id + "/medias/index.json",
			function(data){
				$.each(data.medias, function(i,media){
					$("#webbastic_list #thumbs").append(
						"<a class='media_thumb' rel='" + media.url + "' type='" + media.mime + "'>" +
						"<img src='" + media.icon + "' alt='" + media.title + "'/>" +
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
	$(".media_gallery_select").change(function() {
		// call method to load media_thumb_list
		// with selected gallery
		load_media_thumb_list(this.value);
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
	// Initialize wymeditor
	//
	$('.wymeditor').wymeditor({

	    postInit: function(wym) {

			//
			// User click on a thumbnail to be displayed in editor
			//
			$('a.media_thumb').livequery('click', function(event) {
				switch(this.type){
					case "jpg":
					case "jpeg":
					case "gif":
					case "png":
						wym.insert("<img src='" + this.rel + "'/>");
						break
					default:
						title = this.firstChild.alt;
						wym.insert("<a href='" + this.rel + "'/>" + title + "</a>");
				}
				return false; 
			});
	    }
	});
	
});