$(document).ready(function(){

	// $('#uploadfile').change(function(ev) {
	// 	alert("file change");
	// });

	//binds to onchange event of your input field
	$('#uploadfile').change(function() {
	  var uploadFile = this.files[0];
      // validation, need to be less than 50MB
	  if (uploadFile.size > 52428800){
	  	alert("The selected file exceed maximum 50 MB size, please choose another file!");
	  	 $('input:submit').attr('disabled',true);
	  } else {
	  	$('input:submit').attr('disabled',false);
	  }
	});

	// initial state for js enabled browsers
	$("#inputchoice a:contains('file')").addClass("active")
	$("#input-uri").hide();
	
	// select the visible input form
	$("#inputchoice a").click(function() {
		
		var old_choice = $("#inputchoice a.active");
		var old_pane = $(old_choice.attr("href"));
		
		var new_choice = $(this);
		var new_pane = $(new_choice.attr("href"));

		old_choice.removeClass("active");
		new_choice.addClass("active");
		
		old_pane.fadeOut("fast", function () {
			new_pane.fadeIn("fast");
		});
	});	


			
});
