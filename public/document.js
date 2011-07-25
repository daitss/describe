$(document).ready(function(){
	$("#uploadfile").change(update_ext);
});

function update_ext() {
	fileElement = $("#uploadfile").val().split(".");
	index = fileElement.length-1;
	$("#extension").val(fileElement[index]);
    }
}