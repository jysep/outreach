console.log("JS Loaded");
$(function() {
	console.log("In function");
	if (location.href.indexOf("/campaigns/") == -1 || location.href.indexOf("/entries") == -1) {
		console.log("Not Entry Page");
		return;
	}
	console.log("Connecting Form");
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
	}

	if (unsentEntries.length > 0) {
		sendEntries(maxTries);
	}

	function storeEntry(entry) {
		unsentEntries.push({
			"timestamp": Date.now(),
			"entry": entry
		});
		if (hasLocalStorage()) {
			console.log("updating local storage");
			console.log(JSON.stringify(unsentEntries));
			localStorage[campaignID] = JSON.stringify(unsentEntries);
		}
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
		if (hasLocalStorage()) {
			console.log("updating local storage");
			console.log(JSON.stringify(unsentEntries));
			localStorage[campaignID] = JSON.stringify(unsentEntries);
		}
	}

	function sendEntries(tries) {
		isSending = true;
		if (unsentEntries.length == 0) {
			isSending = false;
			return;
		}
		$.ajax({
			"contentType": "application/json",
			"data": JSON.stringify({"entries": unsentEntries}),
			"dataType": "json",
			"type": "POST",
			"timeout": 15000,
			"url": location.href + '/submit',
			"error": function(xhr, status, err) {
				if (tries == 0) {
					isSending = false;
				} else {
					tries--;
					setTimeout(function() {
						sendEntries(tries);
					}, 1000);
				}
			},
			"success": function(data, status, xhr) {
				console.log("Submit response:");
				console.log(data);
				clearSent(data.successes);
				sendEntries(maxTries);
			}
		});
	}

	function formEntry(form) {
		return {
			"team": $.trim(form.find("#team").val()),
			"date": $.trim(form.find("#date").val()),
			"street": $.trim(form.find("#street").val()),
			"street_number": $.trim(form.find("#street-number").val()),
			"unit_number": $.trim(form.find("#unit").val()),
			"outcome": form.find("#outcome").val(),
			"people": $.trim(form.find("#people").val()),
			"contact": $.trim(form.find("#contact").val()),
			"notes": $.trim(form.find("#notes").val()),
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

	function showSuccess() {
		var $el = $('<div class="alert alert-fixed alert-success" role="alert"><strong>Saved!</strong></div>');
		$("body").append($el);
		setTimeout(function() {
			$el.hide('slow', function() { $el.remove(); });
		}, 500);
	}

	function showError(msg, target) {
		var top = target.parent().offset().top;
		if (top < 50) {
			top = 0;
		} else {
			top = top - 50;
		}
		$('html, body').animate({
			scrollTop: top
		}, 200);

		var $el = $('<div class="alert alert-fixed alert-danger" role="alert"></div>');
		$el.text(msg);
		$("body").append($el);
		setTimeout(function() {
			$el.hide('slow', function() { $el.remove(); });
		}, 3000);
		target.focus();
	}

	function validate(form, entry) {
		if (entry.team.length == 0) {
			showError("Team Members cannot be blank", form.find("#team"));
			return false;
		}
		if (entry.date.length == 0) {
			showError("Date cannot be blank", form.find("#date"));
			return false;
		}
		if (entry.street.length == 0) {
			showError("Street cannot be blank", form.find("#street"));
			return false;
		}
		if (entry.street_number.length == 0) {
			showError("Street Number cannot be blank", form.find("#street-number"));
			return false;
		}
		if (entry.outcome.length == 0) {
			showError("Outcome must be selected", form.find("#outcome"));
			return false;
		}
		return true;
	}

	$("#entries-form").submit(function(e) {
		e.preventDefault();
		var $this = $(this);
		var entry = formEntry($this);
		if (!validate($this, entry)) {
			return;
		}
		storeEntry(entry);
		showSuccess();
		resetForm($this, entry);

		return false;
	});
	console.log("Form Bound");
});
