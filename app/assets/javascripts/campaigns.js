$(function() {
	$("#entry-links tbody tr").click(function(e) {
		if (window.getSelection().type == "Range") {
			return;
		}
		var href = $(this).data("href");
		if (e.metaKey) {
			var win = window.open(href, "_blank");
		} else {
			location.href = href;
		}
	});
});
