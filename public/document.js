$(document).ready(function(){
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
	$("#uploadfile").change(update_ext);
});

function update_ext() {
	fileElement = $("#uploadfile").val().split(".");
	index = fileElement.length-1;
	$("#extension").val(fileElement[index]);
};
