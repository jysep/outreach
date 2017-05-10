$(function() {
	if (!/campaigns\/(\w+)\/entries$/.test(location.href)) {
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
	}

	if (unsentEntries.length > 0) {
		showSync();
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
			sendEntries(maxTries, null);
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

	function sendEntries(tries, cb) {
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
					showSync();
				} else {
					tries--;
					setTimeout(function() {
						sendEntries(tries, cb);
					}, 1000);
				}
			},
			"success": function(data, status, xhr) {
				console.log("Submit response:");
				console.log(data);
				clearSent(data.successes);
				if (cb != null && cb != undefined) {
					cb();
				}
				sendEntries(maxTries, null);
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

		$("#entries-form input, #entries-form select, #entries-form textarea").each(function(i, el) {
			storeVal(el);
		});

		$('html, body').animate({
			scrollTop: form.find("#street-number").parent().offset().top - 50
		}, 200);
		if (entry.unit_number.length > 0) {
			form.find("#unit").focus();
		} else {
			form.find("#street-number").focus();
		}
	}

	function showSuccess(msg) {
		var $el = $('<div class="alert alert-fixed alert-success" role="alert"><strong>'+msg+'</strong></div>');
		$("body").append($el);
		setTimeout(function() {
			$el.hide('slow', function() { $el.remove(); });
		}, 1000);
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

	function showSync() {
		var entryNum;
		if (unsentEntries.length == 0) {
			return;
		} else if (unsentEntries.length == 1) {
			entryNum = "1 unsynced entry";
		} else {
			entryNum = unsentEntries.length + " unsynced entries"
		}
		$el = $("<div class='alert alert-warning' id='sync-alert'><button class='btn btn-warning'>Sync With Server</button> <span><strong>You have "+entryNum+".</strong></span></div>");
		$el.find("button").click(function() {
			sendEntries(maxTries, function() {
				showSuccess("Synced!");
				$el.remove();
			});
		})
		if ($('#sync-alert').length > 0) {
			$('#sync-alert').replaceWith($el);
		} else {
			$(".card").before($el);
		}
	}

	$("body").on("click", "#entry-submit", function(e) {
		e.preventDefault();
		var $this = $(this).parents("form");
		var entry = formEntry($this);
		if (!validate($this, entry)) {
			return;
		}
		storeEntry(entry);
		showSuccess("Saved!");
		resetForm($this, entry);

		return false;
	});


	if (hasLocalStorage()) {
		$("#entries-form input, #entries-form select, #entries-form textarea").each(function(i, el) {
			var $el = $(el);
			var id = $el.attr('id');
			if (id == "date") {
				return;
			}
			if (localStorage["form-"+id] != undefined) {
				if ($el.attr('type') == 'checkbox') {
					$el.prop('checked', true);
				} else {
					$el.val(localStorage["form-"+id]);
				}
			}
		});
	}

	function storeVal(el) {
		var $el = $(el);
		if (hasLocalStorage()) {
			if ($el.attr('type') == 'checkbox') {
				if (el.checked) {
					localStorage["form-"+$el.attr("id")] = "checked";
				} else {
					localStorage.removeItem("form-"+$el.attr("id"));
				}
			} else {
				localStorage["form-"+$el.attr("id")] = $el.val();
			}
		}
	}

	$("#entries-form input, #entries-form select, #entries-form textarea").on("change keyup", function() {
		storeVal(this);
	});
});
