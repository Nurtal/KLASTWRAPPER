
   		function bonjour(){
   		alert('bonjour a tous');
   		}

		function graphe(){
                        var data = {
                        labels: [
                                "Match",
                                "No match",
                        ],
                        datasets: [{
                                data: [1, 70],
                                backgroundColor: [
                                        "#58ACFA",
                                        "#DF013A",
                                ],
                                hoverBackgroundColor: [
                                        "#58ACFA",
                                        "#DF013A",
                                ]
                        }]
                };
                
                var options = {};
                var ctx_2 = document.getElementById("pieChart");
                var myPieChart = new Chart(ctx_2,{
                        type: 'pie',
                        data: data,
                        options: options
                });

        
                var ctx = document.getElementById("myChart");
                var myChart = new Chart(ctx, {
                        type: 'bar',
                        data: {
                                labels: ["Query Sequences", "Hits"],
                                datasets: [{
                                        label: 'Matching hits',
                                        data: [71, 4],
					backgroundColor: [
						"#36A2EB",
						"#04B45F",
					]
                                }]
                        },
                        options: {
                        }
                });


		var data = {};
		(function() {
			data.parties = [
				{name: "query", speeches: [ "QUERY: Murlock Murlock Murlock"] },
				{name: "subject", speeches: ["SUBJECT: Murlock"]}
			].map(party); 

			data.speakers = { "SUBJECT": {name: "Subject", title: "Subject"},
					  "QUERY": {name: "Query", title: "Query"},
					};
	
			data.topics = [ {name: "size (octets)", re: /\b(Murlock)\b/gi, x: 558, y: 181},
					{name: "number Of Sequences", re: /\b(Murlock)\b/gi, x: 458, y: 181},
					{name: "shortest Sequence", re: /\b(Murlock)\b/gi, x: 358, y: 181},
					{name: "largest Sequence", re: /\b(Murlock)\b/gi, x: 258, y: 181}
				].map(topic);
        	

			data.topic = function(name) {
				var t = topic({name: name, re: new RegExp("\b(" + d3.requote(name) + ")\b", "gi")}, data.topics.length);
				data.topics.push(t);
				return t;
			};

			function party(party) {
				party.speeches = party.speeches.map(speech);
				party.sections = sections(party.speeches);
				party.wordCount = d3.sum(party.sections, function(d) { return countWords(d.speech.text.substring(d.i, d.j)); });
				return party;
			}

			function speech(text, i) {
				return {text: text, id: i};
			}

			function sections(speeches) {
				var speakerRe = /(?:\n|^)([A-Z\.()\- ]+): /g,
				sections = [];
				speeches.forEach(function(speech) {
					var speakerName = "AUDIENCE", match,
					i = speakerRe.lastIndex = 0;
					while (match = speakerRe.exec(speech.text)) {
						if (match.index > i) sections.push({speaker: speakerName, speech: speech, i: i, j: match.index});
						speakerName = match[1];
						i = speakerRe.lastIndex;
					}
					sections.push({speaker: speakerName, speech: speech, i: i, j: speech.text.length});
				});
				return sections.filter(function(d) { return !/^AUDIENCE\b/.test(d.speaker); });
			}




			function topic(topic, i) {
				topic.id = i; 
				topic.count = 0;
				topic.cx = topic.x;
				topic.cy = topic.y;

				topic.parties = data.parties.map(function(party) {
					var count = 0, mentions = [];
					party.sections.forEach(function(section) {
						var text = section.speech.text.substring(section.i, section.j), match;
						topic.re.lastIndex = 0;
						while (match = topic.re.exec(text)) {
							++count;
							mentions.push({
								topic: topic,
								section: section,
								i: section.i + match.index,
								j: section.i + topic.re.lastIndex
							});
						}
					});
					topic.count += count;
					if(topic.name == "shortest Sequence"){
						topic.count = 765;
					}
					return {count: count, mentions: mentions};
				});
				return topic;
			}

			function countWords(text) {
				return text.split(/\s+/g)
				.filter(function(d) { return d !== "â€”"; })
				.length;
			}
		})();		
	
		(function() {
			var width = 500, 
			    height = 500;

			var collisionPadding = 4,
			    clipPadding = 4,
			    minRadius = 16, // minimum collision radius
			    maxRadius = 65, // also determines collision search radius
	 		    maxMentions = 100, // don't show full transcripts
			   activeTopic; // currently-displayed topic

			var formatShortCount = d3.format(",.0f"),
			    formatLongCount = d3.format(".1f"),
			    formatCount = function(d) { return (d < 10 ? formatLongCount : formatShortCount)(d); };

			var r = d3.scale.sqrt()
				.domain([0, d3.max(data.topics, function(d) { return d.count; })])
				.range([0, maxRadius]);

			var force = d3.layout.force()
				.charge(0)
				.size([width, height - 80])
				.on("tick", tick);

			var node = d3.select(".g-nodes").selectAll(".g-node"),
			    label = d3.select(".g-labels").selectAll(".g-label"),
			    arrow = d3.select(".g-nodes").selectAll(".g-note-arrow");
			    d3.select(".g-nodes").append("rect")
			    .attr("class", "g-overlay")
		 	    .attr("width", width)
			    .attr("height", height)
			    .on("click", clear);
			
			updateTopics(data.topics);

			// Update the known topics.
			function updateTopics(topics) {
				topics.forEach(function(d) {
					d.r = 65
					d.cr = Math.max(minRadius, d.r);
					if(d.name == "size (octets)"){
						d.parties[0].count = 11950358;
						d.parties[1].count = 50056;
					}
					if(d.name == "largest Sequence"){
						d.parties[0].count = 32454;
						d.parties[1].count = 3106;
					}
					if(d.name == "number Of Sequences"){
						d.parties[0].count = 16598;
						d.parties[1].count = 71;
					}
					if(d.name == "shortest Sequence"){
						d.parties[0].count = 7;
						d.parties[1].count = 90;
					}
					d.k = fraction(d.parties[0].count, d.parties[1].count);
					if (isNaN(d.k)) d.k = .5;
					if (isNaN(d.x)) d.x = (1 - d.k) * width + Math.random();
					d.bias = .5 - Math.max(.1, Math.min(.9, d.k));
				});
				force.nodes(data.topics = topics).start();
				updateNodes();
				updateLabels();
				tick({alpha: 0}); // synchronous update
			}

			// Update the displayed nodes.
			function updateNodes() {
				node = node.data(data.topics, function(d) { return d.name; });
				node.exit().remove();
				var nodeEnter = node.enter().append("a")
					.attr("class", "g-node")
					.attr("xlink:href", function(d) { return "#" + encodeURIComponent(d.name); })
					.call(force.drag)
					.call(linkTopic);
				
				var democratEnter = nodeEnter.append("g")
					.attr("class", "g-democrat"); 
				
				democratEnter.append("clipPath")
					.attr("id", function(d) { return "g-clip-democrat-" + d.id; })
					.append("rect");
			
				democratEnter.append("circle");
				
				var republicanEnter = nodeEnter.append("g")
					.attr("class", "g-republican");
					
	
				republicanEnter.append("clipPath")
					.attr("id", function(d) { return "g-clip-republican-" + d.id; })
					.append("rect");
		
				republicanEnter.append("circle");
					nodeEnter.append("line")
					.attr("class", "g-split");

				node.selectAll("rect")
					.attr("y", function(d) { return -d.r - clipPadding; })
					.attr("height", function(d) { return 2 * d.r + 2 * clipPadding; });

				node.select(".g-democrat rect")
					.style("display", function(d) { return d.k > 0 ? null : "none" })
					.attr("x", function(d) { return -d.r - clipPadding; })
					.attr("width", function(d) { return 2 * d.r * d.k + clipPadding; });

				node.select(".g-republican rect")
					.style("display", function(d) { return d.k < 1 ? null : "none" })
					.attr("x", function(d) { return -d.r + 2 * d.r * d.k; })
					.attr("width", function(d) { return 2 * d.r; });

				node.select(".g-democrat circle")
					.attr("clip-path", function(d) { return d.k < 1 ? "url(#g-clip-democrat-" + d.id + ")" : null; });

				node.select(".g-republican circle")
					.attr("clip-path", function(d) { return d.k > 0 ? "url(#g-clip-republican-" + d.id + ")" : null; });

				node.select(".g-split")
					.attr("x1", function(d) { return -d.r + 2 * d.r * d.k; })
					.attr("y1", function(d) { return -Math.sqrt(d.r * d.r - Math.pow(-d.r + 2 * d.r * d.k, 2)); })
					.attr("x2", function(d) { return -d.r + 2 * d.r * d.k; })
					.attr("y2", function(d) { return Math.sqrt(d.r * d.r - Math.pow(-d.r + 2 * d.r * d.k, 2)); });

				node.selectAll("circle")
					.attr("r", function(d) {return 65; });
			}


			// Update the displayed node labels.
			function updateLabels() {
				label = label.data(data.topics, function(d) { return d.name; });
				label.exit().remove();

				var labelEnter = label.enter().append("a")
					.attr("class", "g-label")
					.attr("href", function(d) { return "#" + encodeURIComponent(d.name); })
					.call(force.drag)
					.call(linkTopic);

				labelEnter.append("div")
					.attr("class", "g-name")
					.text(function(d) { return d.name; });
				
				labelEnter.append("div")
					.attr("class", "g-value");

				label
					.style("font-size", function(d) { return 11 + "px"; })
					.style("width", function(d) { return d.r * 2.5 + "px"; });

				// Create a temporary span to compute the true text width.
				label.append("span")
					.text(function(d) { return d.name; })
					.each(function(d) { d.dx = Math.max(d.r * 2.5, this.getBoundingClientRect().width); })
					.remove();
	
				label
					.style("width", function(d) { return d.dx + "px"; })
					.select(".g-value")
					.text(function(d) { return formatShortCount(d.parties[0].count) + " - " + formatShortCount(d.parties[1].count); });

				// Compute the height of labels when wrapped.
				label.each(function(d) { d.dy = this.getBoundingClientRect().height; });
			}


			// Update the active topic.
			function updateActiveTopic(topic) {
				d3.selectAll(".g-head").attr("class", topic ? "g-head g-has-topic" : "g-head g-hasnt-topic");
				if (activeTopic = topic) {
					node.classed("g-selected", function(d) { return d === topic; });
					updateMentions(findMentions(topic));
					d3.selectAll(".g-head a").text(topic.name);
					d3.select(".g-democrat .g-head span.g-count").text(formatCount(topic.parties[0].count));
					d3.select(".g-republican .g-head span.g-count").text(formatCount(topic.parties[1].count));
				} else {
					node.classed("g-selected", false);
					updateMentions(sampleMentions());
					d3.selectAll(".g-head a").text("various topics");
					d3.selectAll(".g-head span.g-count").text("some number of");
				}
			}



			// Update displayed excerpts.
			function updateMentions(mentions) {
				var column = d3.selectAll(".g-mentions")
					.data(mentions);
				
				column.select(".g-truncated")
					.style("display", function(d) { return d.truncated ? "block" : null; });

				var mention = column.selectAll(".g-mention")
					.data(groupMentionsBySpeaker, function(d) { return d.key; });

				mention.exit().remove();
				mention.selectAll("p")
					.remove();

				var mentionEnter = mention.enter().insert("div", ".g-truncated")
					.attr("class", "g-mention");
			
				mentionEnter.append("div")
					.attr("class", "g-speaker")
					.text(function(d) { var s = data.speakers[d.key]; return s ? s.name : d.key; });

				mentionEnter.append("div")
					.attr("class", "g-speaker-title")
					.text(function(d) { var s = data.speakers[d.key]; return s && s.title; });

				mention
					.sort(function(a, b) { return b.values.length - a.values.length; });
				var p = mention.selectAll("p")
					.data(function(d) { return d.values; })
					.enter().append("p")
					.html(function(d) { return d.section.speech.text.substring(d.start, d.end).replace(d.topic.re, "<a>$1</a>"); });
				
				if (activeTopic) {
					p.attr("class", "g-hover");
				} else {
					p.each(function(d) {
						d3.select(this).selectAll("a")
						.datum(d.topic)
						.attr("href", "#" + encodeURIComponent(d.topic.name))
						.call(linkTopic);
					});
				}
			}


			// Assign event handlers to topic links.
			function linkTopic(a) {
				a   .on("click", click)
				    .on("mouseover", mouseover)
				    .on("mouseout", mouseout);
			}

			// Simulate forces and update node and label positions on tick.
			function tick(e) {
				node
					.each(bias(e.alpha * 105))
					.each(collide(.5))
					.attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; });
				label
					.style("left", function(d) { return (d.x - d.dx / 2) + "px"; })
					.style("top", function(d) { return (d.y - d.dy / 2) + "px"; });

				arrow.style("stroke-opacity", function(d) {
					var dx = d.x - d.cx, dy = d.y - d.cy;
					return dx * dx + dy * dy < d.r * d.r ? 1: 0;
				});
			}

			// A left-right bias causing topics to orient by party preference.
			function bias(alpha) {
				return function(d) {
					d.x += d.bias * 0;
				};
			}

			// Resolve collisions between nodes.
			function collide(alpha) {
				var q = d3.geom.quadtree(data.topics);
				return function(d) {
					var r = d.cr + maxRadius + collisionPadding,
					nx1 = d.x - r,
					nx2 = d.x + r,
					ny1 = d.y - r,
					ny2 = d.y + r;
					q.visit(function(quad, x1, y1, x2, y2) {
						if (quad.point && (quad.point !== d) && d.other !== quad.point && d !== quad.point.other) {
							var x = d.x - quad.point.x,
							y = d.y - quad.point.y,
							l = Math.sqrt(x * x + y * y),
							r = d.cr + quad.point.r + collisionPadding;
							if (l < r) {
								l = (l - r) / l * alpha;
								d.x -= x *= l;
								d.y -= y *= l;
								quad.point.x += x;
								quad.point.y += y;	
							}
						}
						return x1 > nx2 || x2 < nx1 || y1 > ny2 || y2 < ny1;
					});
				};
			}


			// Fisherâ€“Yates shuffle.
			function shuffle(array) {
				var m = array.length, t, i;
				while (m) {
					i = Math.floor(Math.random() * m--);
					t = array[m];
					array[m] = array[i];
					array[i] = t;
				}
				return array;
			}


			// Given two quantities a and b, returns the fraction to split the circle a + b.
			function fraction(a, b) {
				var k = a / (a + b);
				if (k > 0 && k < 1) {
					var t0, t1 = Math.pow(12 * k * Math.PI, 1 / 3);
					for (var i = 0; i < 10; ++i) { // Solve for theta numerically.
						t0 = t1;
						t1 = (Math.sin(t0) - t0 * Math.cos(t0) + 2 * k * Math.PI) / (1 - Math.cos(t0));
					}
					k = (1 - Math.cos(t1 / 2)) / 2;
				}
				return k;
			}


			// Update the active topic on hashchange, perhaps creating a new topic.
			function hashchange() {
				var name = decodeURIComponent(location.hash.substring(1)).trim();
				updateActiveTopic(name && name != "!" ? findOrAddTopic(name) : null);
			}

			// Trigger a hashchange on submit.
			function submit() {
				var name = this.search.value.trim();
				location.hash = name ? encodeURIComponent(name) : "!";
				this.search.value = "";
				d3.event.preventDefault();
			}


			// Clear the active topic when clicking on the chart background.
			function clear() {
				location.replace("#!");
			}

			// Rather than flood the browser history, use location.replace.
			function click(d) {
				location.replace("#" + encodeURIComponent(d === activeTopic ? "!" : d.name));
				d3.event.preventDefault();
			}

			// When hovering the label, highlight the associated node and vice versa.
			// When no topic is active, also cross-highlight with any mentions in excerpts.
			function mouseover(d) {
				node.classed("g-hover", function(p) { return p === d; });
				if (!activeTopic) d3.selectAll(".g-mention p").classed("g-hover", function(p) { return p.topic === d; });
			}

			// When hovering the label, highlight the associated node and vice versa.
			// When no topic is active, also cross-highlight with any mentions in excerpts.
			function mouseout(d) {
				node.classed("g-hover", false);
				if (!activeTopic) d3.selectAll(".g-mention p").classed("g-hover", false);
			}
		})();
	}


	/* Custom filtering function which will search data in column four between two values */
	$.fn.dataTable.ext.search.push(
		function( settings, data, dataIndex ) {
			var minId = parseInt( $('#minId').val(), 10 );
			var minAln = parseInt( $('#minAln').val(), 10 );
			var minBitScore = parseInt( $('#bitScore').val(), 10 );
			var id = parseFloat( data[2] ) || 0;
			var aln = parseFloat( data[3] ) || 0;   
			var bitScore = parseFloat( data[11] ) || 0;
		if ( 
			( isNaN( minAln ) && isNaN( minId ) && isNaN( minBitScore )) ||
			( minAln <= aln && isNaN( minId ) && isNaN( minBitScore )) ||
			( isNaN( minAln ) && minId <= id && isNaN( minBitScore )) ||
			( minAln <= aln && minId <= id && isNaN( minBitScore )) ||

			( isNaN( minAln ) && isNaN( minId ) && minBitScore <= bitScore ) ||
			( minAln <= aln && isNaN( minId ) && minBitScore <= bitScore ) ||
			( isNaN( minAln ) && minId <= id && minBitScore <= bitScore ) ||
			( minAln <= aln && minId <= id && minBitScore <= bitScore ) )
		{
			return true;
		}
			return false;
		}
	);


	 function writeResultTable(data){
		var table = $('#example').DataTable( {
			data: data,
			columns: [
				{ title: "Query" },
                                { title: "Subject" },
                                { title: "% id" },
                                { title: "Alignment length" },
                                { title: "missmatches" },
                                { title: "gap openings" },
                                { title: "q.start"},
                                { title: "q.end"},
                                { title: "s.start"},
                                { title: "s.end"},
                                { title: "e value"},
                                { title: "bit score"}
				]
			}
		);

		// Event listener to the two range filtering inputs to redraw on input
		$('#minId, #minAln, #bitScore').keyup( function() {
			table.draw();
		} );


		$('#example tbody').on( 'click', 'tr', function () {
			$(this).toggleClass('selected');
		} );

		
		$('#button').click( function () {
			var myDataObject = table.rows('.selected').data();
			var numberOfSelectedRow = myDataObject.length;
		
			var dataInTxT = "";

			for (i = 0; i < numberOfSelectedRow; i++){
				dataInTxT = dataInTxT + myDataObject[i] + "\n";  
			}

			var selectedData = new Blob([dataInTxT], {type: 'text/plain'});
			// If we are replacing a previously generated file we need to
			// manually revoke the object URL to avoid memory leaks.
			var textFile = null;
			if (textFile !== null) {
				window.URL.revokeObjectURL(textFile);
			}
			
			textFile = window.URL.createObjectURL(selectedData);
			var link = document.getElementById('downloadlink');
			link.href = textFile;
			link.style.display = 'block'; 
		} );
	}


  var dataSet = [ 
[ "ENSTTRP00000001033","ENSTTRP00000001033","100.00","39","0","0","248","132","248","132","2e-09","43.7","ENSTTRP00000001033","89","39","39","0","100.00","-3","-3","SSXPXXXFFFXFFFFXLXSYXXXXXXFXTXXLXXXPSLF","SSXPXXXFFFXFFFFXLXSYXXXXXXFXTXXLXXXPSLF","400","400","N/A" ],
[ "ENSTTRP00000001033","ENSTTRP00000001033","100.00","36","0","0","238","131","238","131","3e-09","43.2","ENSTTRP00000001033","88","36","36","0","100.00","-1","-1","PPXXFFFXFFFFXXSPXXXRXXXSXXXXSXXXPPFF","PPXXFFFXFFFFXXSPXXXRXXXSXXXXSXXXPPFF","400","400","N/A" ],
[ "ENSTTRP00000001033","ENSTTRP00000001033","100.00","36","0","0","132","239","132","239","3e-07","36.3","ENSTTRP00000001033","76","36","36","0","100.00","3","3","KKGGXXXEXXXXEXXXRXXIGXXXKKKKXKKKXXGG","KKGGXXXEXXXXEXXXRXXIGXXXKKKKXKKKXXGG","400","400","N/A" ],
[ "ENSTTRP00000001033","ENSTTRP00000001033","100.00","36","0","0","133","240","133","240","3e-04","26.3","ENSTTRP00000001033","51","36","36","0","100.00","1","1","KREGXXXRXXVXXXXXXXX*EXXXKKKKXKKXXXXG","KREGXXXRXXVXXXXXXXX*EXXXKKKKXKKXXXXG","400","400","N/A" ]
];

			function timeInfo(){
				var margin = {top: 20, right: 20, bottom: 30, left: 40},
    				width = 400 - margin.left - margin.right,
    				height = 400 - margin.top - margin.bottom;
				var x = d3.scale.ordinal()
    					.rangeRoundBands([0, width], .1, 1);
				var y = d3.scale.linear()
					.range([height, 0]);
				var xAxis = d3.svg.axis()
					.scale(x)
					.orient("bottom");
				var yAxis = d3.svg.axis()
					.scale(y)
					.orient("left")
				var svg = d3.select("div2").append("svg")
					.attr("width", width + margin.left + margin.right)
					.attr("height", height + margin.top + margin.bottom)
					.append("g")
					.attr("transform", "translate(" + margin.left + "," + margin.top + ")");
				d3.tsv("executionTime.tsv", function(error, data) {
					data.forEach(function(d) {
						d.time = +d.time;
					});
					x.domain(data.map(function(d) { return d.job; }));
					y.domain([0, d3.max(data, function(d) { return d.time; })]);
					svg.append("g")
						.attr("class", "x axis")
						.attr("transform", "translate(0," + height + ")")
						.call(xAxis);
					svg.append("g")
						.attr("class", "y axis")
						.call(yAxis)
						.append("text")
						.attr("transform", "rotate(-90)")
						.attr("y", 6)
						.attr("dy", ".71em")
						.style("text-anchor", "end")
						.text("Execution time");
					svg.selectAll(".bar")
						.data(data)
						.enter().append("rect")
						.attr("class", "bar")
						.attr("x", function(d) { return x(d.job); })
						.attr("width", x.rangeBand())
						.attr("y", function(d) { return y(d.time); })
						.attr("height", function(d) { return height - y(d.time); });
					d3.select("input").on("change", change);
					var sortTimeout = setTimeout(function() {
						d3.select("input").property("checked", true).each(change);
					}, 2000);
					function change() {
						clearTimeout(sortTimeout);
						// Copy-on-write since tweens are evaluated after a delay.
						var x0 = x.domain(data.sort(this.checked
							? function(a, b) { return b.time - a.time; }
							: function(a, b) { return d3.ascending(a.job, b.job); })
							.map(function(d) { return d.job; }))
							.copy();
						svg.selectAll(".bar")
							.sort(function(a, b) { return x0(a.job) - x0(b.job); });
						var transition = svg.transition().duration(750),
        						delay = function(d, i) { return i * 50; };
						transition.selectAll(".bar")
							.delay(delay)
							.attr("x", function(d) { return x0(d.job); });
						transition.select(".x.axis")
							.call(xAxis)
							.selectAll("g")
							.delay(delay);
						}
					});
				}