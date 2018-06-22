var glance = function() {
	var main_list = document.getElementById("explorer");
	var viewer = document.getElementById("viewer");

	var htmlEscape = function(str) {
    return String(str)
            .replace(/&/g, '&amp;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
				.replace("\n", '<br>');
	}

	var update_files = function() {
		main_list.innerHTML = "";
		var xhttp = new XMLHttpRequest();
		xhttp.onreadystatechange = function() {
			if (this.readyState == 4 && this.status == 200) {
				var response = JSON.parse(xhttp.responseText);

				var dig = function(obj) {
					obj.folders.forEach(function(folder) {
						if (folder != "undefined") {
							var new_li = document.createElement("li");
							new_li.className = "inner-list-container file-folder";
							new_li.innerHTML = "<i>/" + folder.name + "</i>";

							var new_ul = document.createElement("ul");
							new_ul.className = "inner-list";

							folder.files.forEach(function(file) {
								var new_li2 = document.createElement("li");
								new_li2.className = "file-document";
								new_li2.innerHTML = file.name;
								new_li2.onclick = function() {
									if (file.contents !== undefined) {
										viewer.innerHTML = "<p>" + htmlEscape(file.contents) + "</p>";
									}
								}
								
								new_ul.appendChild(new_li2);
							})

							new_li.appendChild(new_ul);

							main_list.appendChild(new_li);

							if (folder.folders !== undefined) {
								if (folder.folders.length > 0) {
									dig(folder.folders)
								}
							}
						} // end folder != "undefined"
					}); // end foreach folders

					obj.files.forEach(function(file) {
						var new_li = document.createElement("li");
						new_li.className = "file-document";
						new_li.innerHTML = "<i>" + file.name + "</i>";
						new_li.onclick = function() {
							if (file.contents !== undefined) {
								viewer.innerHTML = "<p>" + htmlEscape(file.contents) + "</p>";
							}
						}

						main_list.appendChild(new_li);
					}); // end foreach files
				} // end dig declaration

				dig(response);

				var folders = document.querySelectorAll('.inner-list-container');

				folders.forEach(function(folder) {
					var list = folder.getElementsByTagName("UL")[0];
					var text = folder.getElementsByTagName("i")[0]
					if (list !== undefined) {
						text.onclick = function(el) {
							var active = list.active;
							if (active) {
								list.style.display = "none";
							} else {
								list.style.display = "block";
							}
							list.active = !list.active;
							console.log("clicked")
						}
					}
				});
			}
		}

		xhttp.open("GET", "http://127.0.0.1:8888/files", true);
		xhttp.send();
	} // end update files declaration

	// window.setInterval(update_files, 1000);
	update_files();
}

window.onload = glance;
