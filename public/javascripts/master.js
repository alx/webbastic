$(document).ready(function() {
	
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
});