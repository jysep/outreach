$(function() {
	$("#entry-links tbody tr").click(function(e) {
		location.href = $(this).data("href");
	});
});
