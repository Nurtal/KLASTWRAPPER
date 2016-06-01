#!/usr/bin/perl
use strict;
use warnings;




# Running NGKLAST
my $cmd_line = "";
my $html_path = $ARGV[-2];
my $input_file = $ARGV[4];
my $output_file;
my $stat_file; # file containing statistic informations

my $missmatch_count = 0; # Number of query not found in output file
my $query_count = 0; # Number of query in input file
my $query_found = 0; # Number of query found in output file
my $hit_count = 0; # Number of hits in output file

my $bit_size_query = 0; # size of the query
my $bit_size_subject = 0; # size of the subject
my $shortest_sequence_query = 0; # shortest sequence in query
my $shortest_sequence_subject = 0; # shortest sequence in subject 
my $largest_sequence_query = 0; # largest sequence in query
my $largest_sequence_subject = 0; # largest sequence in subject
my $number_sequence_query = 0; # number of sequences in query
my $number_sequence_subject = 0; # number of sequence in subject

my $executionTime_dataFile = "executionTime.tsv"; # file containing the data to display
my $executionTime_algorithm = 0; # time used for the algorithm
my $executionTime_indexation = 0; # time used for the indexation
my $executionTime_iteration = 0; # time used for iterations
my $executionTime_output = 0; # time used to create the output
my $executionTime_reading = 0; # time used for reading





my $index_for_ARGV = 0;

foreach my $element (@ARGV){
	
	if($element eq "-o"){
		$output_file = $ARGV[$index_for_ARGV + 1];
	}
	
	if($element eq "-full-stats"){
		$stat_file = $ARGV[$index_for_ARGV + 1];

	}	

	if($element ne $ARGV[-1] and $element ne $ARGV[-2]){
		$cmd_line=$cmd_line.$element." ";
	}

	$index_for_ARGV = $index_for_ARGV + 1;

}


# RUN COMMAND

system("mkdir -p $ARGV[-1]");
system("$cmd_line");


# GET STAT INFO

open(my $fhstatistic, "<", $stat_file);
my $line_number = 0;
while(my $line = <$fhstatistic>){
	$line_number++;
	if($line_number == 41 && $line =~ m/size.+:(.+)/){
		$bit_size_subject = $1;
	}
	if(($line_number == 46 || $line_number == 44) && $line =~ m/size.+:(.+)/){
		$bit_size_query = $1;
	}
	if($line_number == 42 && $line =~ m/nb_sequences.+:(.+)/){
		$number_sequence_subject = $1;
	}
	if(($line_number == 47 || $line_number == 45) && $line =~ m/nb_sequences.+:(.+)/){
		$number_sequence_query = $1;
	}
	if($line_number == 43 && $line =~ m/shortest.+:(.+)/){
		$shortest_sequence_subject = $1;
	}
	if($line_number == 48 && $line =~ m/shortest.+:(.+)/){
		$shortest_sequence_query = $1;
	}
	if($line_number == 44 && $line =~ m/largest.+:(.+)/){
		$largest_sequence_subject = $1;
	}
	if($line_number == 49 && $line =~ m/largest.+:(.+)/){
		$largest_sequence_query = $1;
	}

	if($line =~ m/algorithm.+:(.+)/){
		$executionTime_algorithm = $1;
        }
        if($line =~ m/indexation.+:(.+)/){
		$executionTime_indexation = $1;
        }
        if($line =~ m/iteration.+:(.+)/){
		$executionTime_iteration = $1;
        }
        if($line =~ m/output.+: ([0-9].+)/){
		$executionTime_output = $1;
        }
        if($line =~ m/reading.+:(.+)/){
		$executionTime_reading = $1;
        }

}
close($fhstatistic);

open(my $fhexecTime, ">", $executionTime_dataFile);
print $fhexecTime "job\ttime\n";
print $fhexecTime "algorithm\t$executionTime_algorithm\n";
print $fhexecTime "indexation\t$executionTime_indexation\n";
print $fhexecTime "iteration\t$executionTime_iteration\n";
print $fhexecTime "output\t$executionTime_output\n";
print $fhexecTime "reading\t$executionTime_reading\n";
close($fhexecTime);


#copy files to work directory
system("cp -r $output_file $ARGV[-1]/");
system("cp -r $stat_file $ARGV[-1]/");
system("cp $executionTime_dataFile $ARGV[-1]/");
system("cp /home/nfoulqui/WorkSpace/galaxy/tools/ngklast/chart.js $ARGV[-1]/");
system("cp /home/nfoulqui/WorkSpace/galaxy/tools/ngklast/jquery.js $ARGV[-1]/");
system("cp /home/nfoulqui/WorkSpace/galaxy/tools/ngklast/dataTable.js $ARGV[-1]/");
system("cp /home/nfoulqui/WorkSpace/galaxy/tools/ngklast/d3.v3.min.js $ARGV[-1]/");
system("cp /home/nfoulqui/WorkSpace/galaxy/tools/ngklast/style.css $ARGV[-1]/");


# Stats on the Output
# count number of query retrieve (work on tabular output)

open(my $fhquery, "<", "$input_file");
while(my $lineInQuery = <$fhquery>){
        if($lineInQuery =~ m/^>/){
                $query_count++;
                my @lineInQueryInArray = split(" ", $lineInQuery);
                $lineInQueryInArray[0] =~ s/.//;
                my $query_id = $lineInQueryInArray[0];
                my $queryNotFound = 1;
		$hit_count = 0;
                open(my $fhresult, "<", "$output_file");
                while(my $lineInResult = <$fhresult>){
                        my @lineInResultInArray = split("\t", $lineInResult);
                        if($query_id eq $lineInResultInArray[0]){
                                $queryNotFound = 0;
                        }
			$hit_count++;
                }
                if($queryNotFound){
                        $missmatch_count++;
                }
                close($fhresult);
        }
}
$query_found = $query_count - $missmatch_count;
close($fhquery);











my @PathINArray = split("/", $output_file);
my @PathInArray_statistic = split("/", $stat_file);



# Writting Html OUTPUT
open(my $fhHtml, ">", $html_path);
print $fhHtml "<html>\n";
print $fhHtml "<title> Results </title>\n";

print $fhHtml "<link rel=\"stylesheet\" type=\"text/css\" href=\"style.css\" />";

print $fhHtml "<script src=\"chart.js\"></script>\n";
print $fhHtml "<script src=\"jquery.js\"></script>\n";
print $fhHtml "<script src=\"dataTable.js\"></script>\n";
print $fhHtml "<script type=\"text/javascript\">\n
   		function bonjour(){\n
   		alert('bonjour a tous');\n
   		}\n


		function graphe(){
                        var data = {
                        labels: [
                                \"Match\",
                                \"No match\",
                        ],
                        datasets: [{
                                data: [$query_found, $missmatch_count],
                                backgroundColor: [
                                        \"#58ACFA\",
                                        \"#DF013A\",
                                ],
                                hoverBackgroundColor: [
                                        \"#58ACFA\",
                                        \"#DF013A\",
                                ]
                        }]
                };
                
                var options = {};
                var ctx_2 = document.getElementById(\"pieChart\");
                var myPieChart = new Chart(ctx_2,{
                        type: 'pie',
                        data: data,
                        options: options
                });\n
        
                var ctx = document.getElementById(\"myChart\");
                var myChart = new Chart(ctx, {
                        type: 'bar',
                        data: {
                                labels: [\"Query Sequences\", \"Hits\"],
                                datasets: [{
                                        label: 'Matching hits',
                                        data: [$query_count, $hit_count],
					backgroundColor: [
						\"#36A2EB\",
						\"#04B45F\",
					]
                                }]
                        },
                        options: {
                        }
                });


		var data = {};
		(function() {
			data.parties = [
				{name: \"query\", speeches: [ \"QUERY: Murlock Murlock Murlock\"] },
				{name: \"subject\", speeches: [\"SUBJECT: Murlock\"]}
			].map(party); 

			data.speakers = { \"SUBJECT\": {name: \"Subject\", title: \"Subject\"},
					  \"QUERY\": {name: \"Query\", title: \"Query\"},
					};
	
			data.topics = [ {name: \"size (MB)\", re: /\\b(Murlock)\\b/gi, x: 558, y: 181},
					{name: \"number Of Sequences\", re: /\\b(Murlock)\\b/gi, x: 458, y: 181},
					{name: \"shortest Sequence\", re: /\\b(Murlock)\\b/gi, x: 358, y: 181},
					{name: \"largest Sequence\", re: /\\b(Murlock)\\b/gi, x: 258, y: 181}
				].map(topic);
        	

			data.topic = function(name) {
				var t = topic({name: name, re: new RegExp(\"\\b(\" + d3.requote(name) + \")\\b\", \"gi\")}, data.topics.length);
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
				var speakerRe = /(?:\\n|^)([A-Z\\.()\\- ]+): /g,
				sections = [];
				speeches.forEach(function(speech) {
					var speakerName = \"AUDIENCE\", match,
					i = speakerRe.lastIndex = 0;
					while (match = speakerRe.exec(speech.text)) {
						if (match.index > i) sections.push({speaker: speakerName, speech: speech, i: i, j: match.index});
						speakerName = match[1];
						i = speakerRe.lastIndex;
					}
					sections.push({speaker: speakerName, speech: speech, i: i, j: speech.text.length});
				});
				return sections.filter(function(d) { return !/^AUDIENCE\\b/.test(d.speaker); });
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
					if(topic.name == \"shortest Sequence\"){
						topic.count = 765;
					}
					return {count: count, mentions: mentions};
				});
				return topic;
			}

			function countWords(text) {
				return text.split(/\\s+/g)
				.filter(function(d) { return d !== \"â€”\"; })
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

			var formatShortCount = d3.format(\",.0f\"),
			    formatLongCount = d3.format(\".1f\"),
			    formatCount = function(d) { return (d < 10 ? formatLongCount : formatShortCount)(d); };

			var r = d3.scale.sqrt()
				.domain([0, d3.max(data.topics, function(d) { return d.count; })])
				.range([0, maxRadius]);

			var force = d3.layout.force()
				.charge(0)
				.size([width, height - 80])
				.on(\"tick\", tick);

			var node = d3.select(\".g-nodes\").selectAll(\".g-node\"),
			    label = d3.select(\".g-labels\").selectAll(\".g-label\"),
			    arrow = d3.select(\".g-nodes\").selectAll(\".g-note-arrow\");
			    d3.select(\".g-nodes\").append(\"rect\")
			    .attr(\"class\", \"g-overlay\")
		 	    .attr(\"width\", width)
			    .attr(\"height\", height)
			    .on(\"click\", clear);
			
			updateTopics(data.topics);

			// Update the known topics.
			function updateTopics(topics) {
				topics.forEach(function(d) {
					d.r = 65
					d.cr = Math.max(minRadius, d.r);
					if(d.name == \"size (MB)\"){
						d.parties[0].count = $bit_size_subject;
						d.parties[1].count = $bit_size_query;
					}
					if(d.name == \"largest Sequence\"){
						d.parties[0].count = $largest_sequence_subject;
						d.parties[1].count = $largest_sequence_query;
					}
					if(d.name == \"number Of Sequences\"){
						d.parties[0].count = $number_sequence_subject;
						d.parties[1].count = $number_sequence_query;
					}
					if(d.name == \"shortest Sequence\"){
						d.parties[0].count = $shortest_sequence_subject;
						d.parties[1].count = $shortest_sequence_query;
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
				var nodeEnter = node.enter().append(\"a\")
					.attr(\"class\", \"g-node\")
					.attr(\"xlink:href\", function(d) { return \"#\" + encodeURIComponent(d.name); })
					.call(force.drag)
					.call(linkTopic);
				
				var democratEnter = nodeEnter.append(\"g\")
					.attr(\"class\", \"g-democrat\"); 
				
				democratEnter.append(\"clipPath\")
					.attr(\"id\", function(d) { return \"g-clip-democrat-\" + d.id; })
					.append(\"rect\");
			
				democratEnter.append(\"circle\");
				
				var republicanEnter = nodeEnter.append(\"g\")
					.attr(\"class\", \"g-republican\");
					
	
				republicanEnter.append(\"clipPath\")
					.attr(\"id\", function(d) { return \"g-clip-republican-\" + d.id; })
					.append(\"rect\");
		
				republicanEnter.append(\"circle\");
					nodeEnter.append(\"line\")
					.attr(\"class\", \"g-split\");

				node.selectAll(\"rect\")
					.attr(\"y\", function(d) { return -d.r - clipPadding; })
					.attr(\"height\", function(d) { return 2 * d.r + 2 * clipPadding; });

				node.select(\".g-democrat rect\")
					.style(\"display\", function(d) { return d.k > 0 ? null : \"none\" })
					.attr(\"x\", function(d) { return -d.r - clipPadding; })
					.attr(\"width\", function(d) { return 2 * d.r * d.k + clipPadding; });

				node.select(\".g-republican rect\")
					.style(\"display\", function(d) { return d.k < 1 ? null : \"none\" })
					.attr(\"x\", function(d) { return -d.r + 2 * d.r * d.k; })
					.attr(\"width\", function(d) { return 2 * d.r; });

				node.select(\".g-democrat circle\")
					.attr(\"clip-path\", function(d) { return d.k < 1 ? \"url(#g-clip-democrat-\" + d.id + \")\" : null; });

				node.select(\".g-republican circle\")
					.attr(\"clip-path\", function(d) { return d.k > 0 ? \"url(#g-clip-republican-\" + d.id + \")\" : null; });

				node.select(\".g-split\")
					.attr(\"x1\", function(d) { return -d.r + 2 * d.r * d.k; })
					.attr(\"y1\", function(d) { return -Math.sqrt(d.r * d.r - Math.pow(-d.r + 2 * d.r * d.k, 2)); })
					.attr(\"x2\", function(d) { return -d.r + 2 * d.r * d.k; })
					.attr(\"y2\", function(d) { return Math.sqrt(d.r * d.r - Math.pow(-d.r + 2 * d.r * d.k, 2)); });

				node.selectAll(\"circle\")
					.attr(\"r\", function(d) {return 65; });
			}


			// Update the displayed node labels.
			function updateLabels() {
				label = label.data(data.topics, function(d) { return d.name; });
				label.exit().remove();

				var labelEnter = label.enter().append(\"a\")
					.attr(\"class\", \"g-label\")
					.attr(\"href\", function(d) { return \"#\" + encodeURIComponent(d.name); })
					.call(force.drag)
					.call(linkTopic);

				labelEnter.append(\"div\")
					.attr(\"class\", \"g-name\")
					.text(function(d) { return d.name; });
				
				labelEnter.append(\"div\")
					.attr(\"class\", \"g-value\");

				label
					.style(\"font-size\", function(d) { return 11 + \"px\"; })
					.style(\"width\", function(d) { return d.r * 2.5 + \"px\"; });

				// Create a temporary span to compute the true text width.
				label.append(\"span\")
					.text(function(d) { return d.name; })
					.each(function(d) { d.dx = Math.max(d.r * 2.5, this.getBoundingClientRect().width); })
					.remove();
	
				label
					.style(\"width\", function(d) { return d.dx + \"px\"; })
					.select(\".g-value\")
					.text(function(d) { return formatShortCount(d.parties[0].count) + \" - \" + formatShortCount(d.parties[1].count); });

				// Compute the height of labels when wrapped.
				label.each(function(d) { d.dy = this.getBoundingClientRect().height; });
			}


			// Update the active topic.
			function updateActiveTopic(topic) {
				d3.selectAll(\".g-head\").attr(\"class\", topic ? \"g-head g-has-topic\" : \"g-head g-hasnt-topic\");
				if (activeTopic = topic) {
					node.classed(\"g-selected\", function(d) { return d === topic; });
					updateMentions(findMentions(topic));
					d3.selectAll(\".g-head a\").text(topic.name);
					d3.select(\".g-democrat .g-head span.g-count\").text(formatCount(topic.parties[0].count));
					d3.select(\".g-republican .g-head span.g-count\").text(formatCount(topic.parties[1].count));
				} else {
					node.classed(\"g-selected\", false);
					updateMentions(sampleMentions());
					d3.selectAll(\".g-head a\").text(\"various topics\");
					d3.selectAll(\".g-head span.g-count\").text(\"some number of\");
				}
			}



			// Update displayed excerpts.
			function updateMentions(mentions) {
				var column = d3.selectAll(\".g-mentions\")
					.data(mentions);
				
				column.select(\".g-truncated\")
					.style(\"display\", function(d) { return d.truncated ? \"block\" : null; });

				var mention = column.selectAll(\".g-mention\")
					.data(groupMentionsBySpeaker, function(d) { return d.key; });

				mention.exit().remove();
				mention.selectAll(\"p\")
					.remove();

				var mentionEnter = mention.enter().insert(\"div\", \".g-truncated\")
					.attr(\"class\", \"g-mention\");
			
				mentionEnter.append(\"div\")
					.attr(\"class\", \"g-speaker\")
					.text(function(d) { var s = data.speakers[d.key]; return s ? s.name : d.key; });

				mentionEnter.append(\"div\")
					.attr(\"class\", \"g-speaker-title\")
					.text(function(d) { var s = data.speakers[d.key]; return s && s.title; });

				mention
					.sort(function(a, b) { return b.values.length - a.values.length; });
				var p = mention.selectAll(\"p\")
					.data(function(d) { return d.values; })
					.enter().append(\"p\")
					.html(function(d) { return d.section.speech.text.substring(d.start, d.end).replace(d.topic.re, \"<a>\$1</a>\"); });
				
				if (activeTopic) {
					p.attr(\"class\", \"g-hover\");
				} else {
					p.each(function(d) {
						d3.select(this).selectAll(\"a\")
						.datum(d.topic)
						.attr(\"href\", \"#\" + encodeURIComponent(d.topic.name))
						.call(linkTopic);
					});
				}
			}


			// Assign event handlers to topic links.
			function linkTopic(a) {
				a   .on(\"click\", click)
				    .on(\"mouseover\", mouseover)
				    .on(\"mouseout\", mouseout);
			}

			// Simulate forces and update node and label positions on tick.
			function tick(e) {
				node
					.each(bias(e.alpha * 105))
					.each(collide(.5))
					.attr(\"transform\", function(d) { return \"translate(\" + d.x + \",\" + d.y + \")\"; });
				label
					.style(\"left\", function(d) { return (d.x - d.dx / 2) + \"px\"; })
					.style(\"top\", function(d) { return (d.y - d.dy / 2) + \"px\"; });

				arrow.style(\"stroke-opacity\", function(d) {
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
				updateActiveTopic(name && name != \"!\" ? findOrAddTopic(name) : null);
			}

			// Trigger a hashchange on submit.
			function submit() {
				var name = this.search.value.trim();
				location.hash = name ? encodeURIComponent(name) : \"!\";
				this.search.value = \"\";
				d3.event.preventDefault();
			}


			// Clear the active topic when clicking on the chart background.
			function clear() {
				location.replace(\"#!\");
			}

			// Rather than flood the browser history, use location.replace.
			function click(d) {
				location.replace(\"#\" + encodeURIComponent(d === activeTopic ? \"!\" : d.name));
				d3.event.preventDefault();
			}

			// When hovering the label, highlight the associated node and vice versa.
			// When no topic is active, also cross-highlight with any mentions in excerpts.
			function mouseover(d) {
				node.classed(\"g-hover\", function(p) { return p === d; });
				if (!activeTopic) d3.selectAll(\".g-mention p\").classed(\"g-hover\", function(p) { return p.topic === d; });
			}

			// When hovering the label, highlight the associated node and vice versa.
			// When no topic is active, also cross-highlight with any mentions in excerpts.
			function mouseout(d) {
				node.classed(\"g-hover\", false);
				if (!activeTopic) d3.selectAll(\".g-mention p\").classed(\"g-hover\", false);
			}
		})();
	}



	/* Custom filtering function which will search data in column four between two values */
	\$.fn.dataTable.ext.search.push(
		function( settings, data, dataIndex ) {
			var minId = parseInt( \$('#minId').val(), 10 );
			var minAln = parseInt( \$('#minAln').val(), 10 );
			var minBitScore = parseInt( \$('#bitScore').val(), 10 );
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
		var table = \$('#example').DataTable( {
			data: data,
			columns: [
				{ title: \"Query\" },
                                { title: \"Subject\" },
                                { title: \"% id\" },
                                { title: \"Alignment length\" },
                                { title: \"missmatches\" },
                                { title: \"gap openings\" },
                                { title: \"q.start\"},
                                { title: \"q.end\"},
                                { title: \"s.start\"},
                                { title: \"s.end\"},
                                { title: \"e value\"},
                                { title: \"bit score\"}
				]
			}
		);

		// Event listener to the two range filtering inputs to redraw on input
		\$('#minId, #minAln, #bitScore').keyup( function() {
			table.draw();
		} );


		\$('#example tbody').on( 'click', 'tr', function () {
			\$(this).toggleClass('selected');
		} );

		
		\$('#button').click( function () {
			var myDataObject = table.rows('.selected').data();
			var numberOfSelectedRow = myDataObject.length;
		
			var dataInTxT = \"\";

			for (i = 0; i < numberOfSelectedRow; i++){
				dataInTxT = dataInTxT + myDataObject[i] + \"\\n\";  
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


   		</script>\n";


print $fhHtml "<script>\n";
print $fhHtml "var dataSet = [ \n";

my $dataToWrite = "";
open(my $fhdata2,"<", $PathINArray[-1]);
while(my $line = <$fhdata2>){
	
	my $lineToWrite = "";
	
	$lineToWrite = $lineToWrite . "[ ";

	my @lineInArray = split("\t", $line);
	substr($lineInArray[-1], '-1') = '';
	my @scoreInArray = split/\./, $lineInArray[2];
	my $score = $scoreInArray[0];
	
	foreach my $elt (@lineInArray){
		$lineToWrite = $lineToWrite . "\"$elt\",";
	}

	substr($lineToWrite, -1) = '';
	$lineToWrite = $lineToWrite . " ],\n";
	
	$dataToWrite = $dataToWrite . "$lineToWrite";
}
close($fhdata2);
substr($dataToWrite, '-2') = '';
print $fhHtml "$dataToWrite";
print $fhHtml "\n];\n";


print $fhHtml "</script>\n";


print $fhHtml "<style>\n
			canvas{\n
				display:inline-block;}\n
			div{\n
				display:inline-block;\n
			}\n

	h2{
		margin: 1em 0 0.5em 0;
		font-weight: normal;
		position: relative;
		text-shadow: 0 -1px rgba(0,0,0,0.6);
		font-size: 28px;
		line-height: 40px;
		background: #355681;
		background: rgba(53,86,129, 0.8);
		border: 1px solid #fff;
		padding: 5px 15px;
		color: white;
		border-radius: 0 10px 0 10px;
		box-shadow: inset 0 0 5px rgba(53,86,129, 0.5);
		font-family: 'Muli', sans-serif;
	}




	#g-chart {
  		overflow: hidden;
  		position: relative;
	}

	#g-form {
 	 	font: 16px sans-serif;
  		text-align: center;
	}

	#g-form input {
 		 border-right: none;
  		border-radius: 3px 0 0 3px;
  		border: solid 1px #ccc;
  		font: inherit;
  		padding: 4px 8px;
  		width: 223px;
	}

#g-form button {
  background: #004276;
  border: none;
  border-radius: 0 3px 3px 0;
  color: #fff;
  font: inherit;
  font-weight: bold;
  padding: 5px 8px;
  position: relative;
  top: 1px;
  width: 30px;
}

.g-legend {
  color: #999;
  font: 11px/1.3em sans-serif;
  height: 30px;
  margin-top: 15px;
  position: relative;
  text-align: center;
}

.g-arrow {
  position: absolute;
  width: 100px;
}

.g-arrow:before {
  position: absolute;
  font-size: 15px;
  font-style: normal;
  top: 7px;
}

.g-democrat.g-arrow {
  left: 170px;
  padding-left: 40px;
}

.g-arrow.g-democrat:before {
  content: \"â†\";
  right: 100px;
}

.g-republican.g-arrow {
  right: 170px;
  padding-right: 40px;
}

.g-arrow.g-republican:before {
  content: \"â†’\";
  left: 100px;
}

.g-legend .g-pointer {
  width: 150px;
}

.g-overview {
  position: absolute;
  left: 360px;
  text-align: center;
  width: 250px;
}

.g-legend .g-democrat.g-pointer {
  position: absolute;
  left: 314px;
  text-align: right;
  padding-right: 20px;
}

.g-swatch {
  width: 6px;
  height: 8px;
  display: inline-block;
  position: relative;
  top: 1px;
  margin: 0 3px;
}

.g-republican.g-swatch {
  background-color: #f9caca;
  border-radius: 0 4px 4px 0;
}

.g-democrat.g-swatch {
  background-color: #c5d7ea;
  border-radius: 4px 0 0 4px;
}

.g-republican.g-swatch {
  background-color: #f9caca;
}

.g-notes {
  font: 11px/1.3em sans-serif;
  height: 100px;
  position: absolute;
  top: 430px;
}

.g-note {
  color: #999;
  position: absolute;
  width: 212px;
}

.g-note b {
  color: #333;
  text-transform: uppercase;
}

.g-note-arrow {
  fill: none;
  stroke: #aaa;
  stroke-dasharray: 2,2;
  stroke-width: 1.5px;
  -webkit-transition: stroke-opacity 250ms ease;
  -moz-transition: stroke-opacity 250ms ease;
  -ms-transition: stroke-opacity 250ms ease;
  -o-transition: stroke-opacity 250ms ease;
  transition: stroke-opacity 250ms ease;
}

.g-error {
  background: #ffa;
  border: solid 1px #ccc;
  font-size: 16px;
  line-height: 1.2em;
  margin: 10px;
  padding: 10px;
}

.g-node .g-democrat {
  fill: #c5d7ea;
}

.g-node.g-hover .g-democrat {
  fill: #acbed1; /* darker(.5) */
}

.g-node.g-selected .g-democrat {
  fill: #99c0e5; /* c *= 2, darker(.5) */
  stroke: #6081a3; /* c *= 2, darker(2) */
  stroke-width: 1.5px;
}

.g-node .g-republican {
  fill: #f9caca;
}

.g-node.g-hover .g-republican {
  fill: #dfb1b1; /* darker(.5) */
}

.g-node.g-selected .g-republican {
  fill: #fda4a7; /* c *= 2, darker(.5) */
  stroke: #af5e61; /* c *= 2, darker(2) */
  stroke-width: 1.5px;
}

.g-node .g-split {
  stroke: #000;
  stroke-opacity: .18;
  shape-rendering: crispEdges;
}

a.g-label {
  color: inherit;
  cursor: pointer;
  display: block;
  text-align: center;
  text-decoration: none;
  line-height: 1em;
  position: absolute;
}

.g-label .g-value {
  font: 11px sans-serif;
  white-space: nowrap;
}

.g-overlay,
.g-node,
.g-label {
  -webkit-tap-highlight-color: transparent;
}

.g-overlay {
  fill: none;
  pointer-events: all;
}

.g-body {
  min-height: 700px;
}

.g-has-topic .g-isnt-topic,
.g-hasnt-topic .g-is-topic {
  display: none;
}

.g-body h3 {
  font-size: 18px;
  line-height: 1.4em;
  font-family: Georgia;
  font-weight: normal;
  margin-bottom: 0.9em;
}

.g-mentions {
  width: 445px;
}

.g-mentions h3 {
  text-align: center;
}

.g-mentions.g-democrat h3 {
  margin-left: 140px;
}

.g-mentions.g-republican h3 {
  margin-right: 140px;
}

.g-divider,
.g-mention,
.g-truncated {
  border-top: solid 1px #ccc;
}

.g-mentions.g-democrat {
  margin: 0 0 0 20px;
  float: left;
}

.g-mentions.g-republican {
  margin: 0 20px 0 0;
  float: right;
}

.g-head a {
  border-radius: 3px;
  padding: 3px 3px;
  white-space: nowrap;
}

.g-mention {
  clear: both;
  margin: -1px 0 1.5em 0;
}

.g-mention p {
  color: #444;
  font-family: Georgia;
  font-size: 1.3em;
  line-height: 1.40em;
}

.g-democrat .g-mention p {
  margin: 1.5em 0 1.5em 160px;
}

.g-republican .g-mention p {
  margin: 1.5em 140px 1.5em 20px;
}

.g-mention a {
  border-radius: 3px;
  padding: 1px 3px;
  text-decoration: none;
}

.g-democrat a {
  background-color: #c5d7ea;
  color: #4a5783;
}

.g-republican a {
  background-color: #fbdedf;
  color: #734143;
}

.g-mention p:before,
.g-mention p:after {
  color: #ddd;
  font-family: sans-serif;
  font-size: 36px;
  position: absolute;
}

.g-mention p::before {
  content: \"â€œ\";
  margin: 0.25em 0 0 -20px;
}

.g-mention p::after {
  content: \"â€\";
  margin: 0.25em 0 0 0.1em;
}

.g-speaker {
  font: bold 13px sans-serif;
  margin: 1.5em 0 0.15em 0;
  text-transform: uppercase;
  width: 125px;
}

.g-speaker-title {
  clear: both;
  color: #aaa;
  font: 11px sans-serif;
  margin-bottom: 1em;
  width: 125px;
}

.g-democrat .g-speaker,
.g-democrat .g-speaker-title {
  float: left;
  text-align: left;
}

.g-republican .g-speaker,
.g-republican .g-speaker-title {
  float: right;
  text-align: right;
}

.g-truncated {
  border-top-style: dashed;
  color: #aaa;
  display: none;
  font: 11px sans-serif;
  padding-top: 1em;
  text-align: center;
}

/* Scoop Fixes */

.storySummary,
.storyHeader h1 {
  display: block;
  margin: 5px auto;
  padding: 0;
  text-align: center;
  width: 640px;
}

#interactiveFooter {
  border-top: 1px solid #ddd;
  margin-top: 10px;
  padding-top: 12px;
}

#main .storyHeader h1 {
  font-size: 26px;
  margin: 25px auto 4px auto;
}

</style>\n";





print $fhHtml "<body>\n";


print $fhHtml "<section>\n";
print $fhHtml "<h2>Job Overview</h2>\n";

print $fhHtml "<center>

	<table>
	<tr>
	<td>
	<div>\n
		<canvas id=\"pieChart\" width=\"300\" height=\"300\"></canvas>\n
	</div>\n
	</td>

	<td>
	<div>\n
		<canvas id=\"myChart\" width=\"400\" height=\"400\"></canvas>\n
	</div>
	</td>

	<td>
	<div>
		<div id=\"g-chart\">
		<div class=\"g-notes\">
		<div class=\"g-note\" style=\"left:20px;\">
		</div>
		</div>
		<div class=\"g-labels\"></div>
		<svg class=\"g-nodes\" width=\"500\" height=\"500\">
		</svg>
		</div>
		<script src=\"https://static01.nyt.com/newsgraphics/2012/09/04/convention-speeches/ac823b240e99920e91945dbec49f35b268c09c38/d3.v2.min.js\"></script>
	</div>
	</td>
	</tr>
	</table>
	</center>\n";

print $fhHtml "<center><button onclick='graphe()'>Display</button></center>";

print $fhHtml "</section>\n";

print $fhHtml "<section>\n";
print $fhHtml "<h2>Best Hit Table</h2>\n";
#print $fhHtml "<table id=\"example\" class=\"display\" width=\"100%\"></table>\n";

print $fhHtml "<center>
		<tbody>
		<tr>
			<td>Min id:</td>
			<td><input id=\"minId\" name=\"minId\" type=\"text\"></td>
		</tr>
		<tr>
			<td>ALignment Length:</td>
			<td><input id=\"minAln\" name=\"minAln\" type=\"text\"></td>
		</tr>
		<tr>
			<td>Score:</td>
			<td><input id=\"bitScore\" name=\"bitScore\" type=\"text\"></td>
		</tr>

		</tbody>
		</center>
	</table><table id=\"example\" class=\"display\" cellspacing=\"0\" width=\"100%\"></table>";


print $fhHtml "<center>\n";
print $fhHtml "<button onclick='writeResultTable(dataSet)'>Display Table</button>\n";
print $fhHtml "<button id=\"button\", name =\"button\">Export Selection</button>\n";
print $fhHtml "<a href=\"$PathINArray[-1]\">Download all data</a>\n";
print $fhHtml "<a download=\"info.txt\" id=\"downloadlink\" style=\"display: none\">Download Selection</a>\n";
print $fhHtml "</center>\n";

print $fhHtml "</section>\n";

print $fhHtml "<section>\n";
print $fhHtml "<h2>Computational informations</h2>\n";

print $fhHtml "<style>
			.axis text {
  				font: 10px sans-serif;
			}

			.axis path,
			.axis line {
  				fill: none;
  				stroke: #000;
  				shape-rendering: crispEdges;
			}

			.bar {
				fill: steelblue;
  				fill-opacity: .9;
			}

			.x.axis path {
  				display: none;
			}

		</style>\n";

print $fhHtml "<center>\n";
print $fhHtml "<label><input type=\"checkbox\"> Sort values</label>\n";
print $fhHtml "<script src=\"d3.v3.min.js\"></script>\n";
print $fhHtml "<script>
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
					.orient(\"bottom\");
				var yAxis = d3.svg.axis()
					.scale(y)
					.orient(\"left\")
				var svg = d3.select(\"div2\").append(\"svg\")
					.attr(\"width\", width + margin.left + margin.right)
					.attr(\"height\", height + margin.top + margin.bottom)
					.append(\"g\")
					.attr(\"transform\", \"translate(\" + margin.left + \",\" + margin.top + \")\");
				d3.tsv(\"executionTime.tsv\", function(error, data) {
					data.forEach(function(d) {
						d.time = +d.time;
					});
					x.domain(data.map(function(d) { return d.job; }));
					y.domain([0, d3.max(data, function(d) { return d.time; })]);
					svg.append(\"g\")
						.attr(\"class\", \"x axis\")
						.attr(\"transform\", \"translate(0,\" + height + \")\")
						.call(xAxis);
					svg.append(\"g\")
						.attr(\"class\", \"y axis\")
						.call(yAxis)
						.append(\"text\")
						.attr(\"transform\", \"rotate(-90)\")
						.attr(\"y\", 6)
						.attr(\"dy\", \".71em\")
						.style(\"text-anchor\", \"end\")
						.text(\"Execution time\");
					svg.selectAll(\".bar\")
						.data(data)
						.enter().append(\"rect\")
						.attr(\"class\", \"bar\")
						.attr(\"x\", function(d) { return x(d.job); })
						.attr(\"width\", x.rangeBand())
						.attr(\"y\", function(d) { return y(d.time); })
						.attr(\"height\", function(d) { return height - y(d.time); });
					d3.select(\"input\").on(\"change\", change);
					var sortTimeout = setTimeout(function() {
						d3.select(\"input\").property(\"checked\", true).each(change);
					}, 2000);
					function change() {
						clearTimeout(sortTimeout);
						// Copy-on-write since tweens are evaluated after a delay.
						var x0 = x.domain(data.sort(this.checked
							? function(a, b) { return b.time - a.time; }
							: function(a, b) { return d3.ascending(a.job, b.job); })
							.map(function(d) { return d.job; }))
							.copy();
						svg.selectAll(\".bar\")
							.sort(function(a, b) { return x0(a.job) - x0(b.job); });
						var transition = svg.transition().duration(750),
        						delay = function(d, i) { return i * 50; };
						transition.selectAll(\".bar\")
							.delay(delay)
							.attr(\"x\", function(d) { return x0(d.job); });
						transition.select(\".x.axis\")
							.call(xAxis)
							.selectAll(\"g\")
							.delay(delay);
						}
					});
				}
				</script>";
print $fhHtml "<div2> <button onclick='timeInfo()'>Display performances</button> </div2>\n";
#print $fhHtml "<button onclick='timeInfo()'>Display performances</button>\n";
print $fhHtml "</center>\n";

print $fhHtml "</section>\n";

#print $fhHtml "<section>\n";
#print $fhHtml "<h1>Biological Classification Table</h1>\n";
#print $fhHtml "</section>\n";


#print $fhHtml "<section>\n";
#print $fhHtml "<h1>Trash Stuff </h1>\n";
#print $fhHtml "<button onclick='bonjour()'>click</button>\n";
#print $fhHtml "<a href=\"$PathINArray[-1]\">Some special output</a>\n";
#print $fhHtml "$ARGV[-1]\n";
#print $fhHtml "$PathINArray[-1]\n";
#print $fhHtml "$ARGV[3]\n";
#print $fhHtml "</section>\n";


print $fhHtml "</body>\n";
print $fhHtml "</html>\n";
close($fhHtml);





