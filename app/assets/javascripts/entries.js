$(function() {
	if (location.href.indexOf("/campaigns/") == -1 || location.href.indexOf("/entries") == -1) {
		return;
	}
	var campaignID = location.href.split("/campaigns/")[1].split("/entries")[0];
	console.log("campaign: "+campaignID);

	function hasLocalStorage() {
		return typeof(Storage) !== "undefined";
	}

	var unsentEntries = [];
	var isSending = false;
	var maxTries = 5;
	if (hasLocalStorage() && localStorage[campaignID] != undefined) {
		console.log("Loading from local storage")
		console.log(localStorage[campaignID]);
		unsentEntries = JSON.parse(localStorage[campaignID]);
		unsentCount = JSON.parse(localStorage[campaignID]);
	}

	function storeEntry(entry) {
		unsentEntries.push({
			"timestamp": Date.now(),
			"entry": entry
		});
		console.log("updating local storage");
		console.log(JSON.stringify(unsentEntries));
		localStorage[campaignID] = JSON.stringify(unsentEntries);
		if (!isSending) {
			sendEntries(maxTries);
		}
	}

	function clearSent(sent) {
		for (var i = unsentEntries.length - 1; i >= 0; i--) {
			if (sent[unsentEntries[i].timestamp]) {
				unsentEntries.splice(i, 1);
			}
		}
		localStorage[campaignID] = JSON.stringify(unsentEntries);
	}

	function sendEntries(tries) {
		isSending = true;
		if (unsentEntries.length == 0) {
			isSending = false;
			return;
		}
		$.ajax({
			"data": unsentEntries,
			"dataType": "json",
			"type": "POST",
			"timeout": 15000,
			"url": location.href,
			"error": function(xhr, status, err) {
				if (tries == 0) {
					isSending = false;
				} else {
					tries--;
					setTimeout(1000, function() {
						sendEntries(tries);
					});
				}
			},
			"success": function(data, status, xhr) {
				clearSent(data.created);
				sendEntries(maxTries);
			}
		});
	}

	function formEntry(form) {
		return {
			"team": form.find("#team").val(),
			"date": form.find("#date").val(),
			"street": form.find("#street").val(),
			"street_number": form.find("#street-number").val(),
			"unit_number": form.find("#unit").val(),
			"outcome": form.find("#outcome").val(),
			"people": form.find("#people").val(),
			"contact": form.find("#contact").val(),
			"notes": form.find("#notes").val(),
			"age_groups": form.find(".age-groups:checked").map(function(i, el){return $(el).val()}).get(),
			"themes": form.find(".themes:checked").map(function(i, el){return $(el).val()}).get()
		};
	}

	function resetForm(form, entry) {
		if (entry.unit_number.length > 0) {
			form.find("#unit").val("");
		} else {
			form.find("#street-number").val("");
		}
		form.find("#outcome").val("");
		form.find("#people").val("");
		form.find("#contact").val("");
		form.find("#notes").val("");
		form.find(".age-groups").prop("checked", false);
		form.find(".themes").prop("checked", false);

		$('html, body').animate({
    	scrollTop: form.find("#street-number").parent().offset().top
		}, 200);
		if (entry.unit_number.length > 0) {
			form.find("#unit").focus();
		} else {
			form.find("#street-number").focus();
		}
	}

	$("#entries-form").submit(function(e) {
		e.preventDefault();
		var $this = $(this);
		var entry = formEntry($this);
		storeEntry(entry);
		resetForm($this, entry);

		return false;
	});
});
