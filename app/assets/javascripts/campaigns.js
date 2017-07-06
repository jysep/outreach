$(function() {
	$("#entry-links tbody tr").click(function(e) {
		if (window.getSelection().type == "Range") {
			return;
		}
		location.href = $(this).data("href");
	});
});
