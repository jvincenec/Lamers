// based on https://observablehq.com/@d3/multi-line-chart
class Chart {
	constructor(url, key, valueKey) {
		this.url = url
		
		// one or both of these may be set.  e.g. the key is the id of a player and the valueKey is the name of a toon
		this.key = key
		this.valueKey = valueKey
		
		this.height = 700
		this.width = 1000
		
		this.round = 1000
		
		this.id = "chart"
	}
	
	display() {
		const self = this
		d3.json(this.url).then(function(originalData) {
			self.handleResult(originalData)
		})
	}
	
	transformData(originalData) {
		
		const key = this.key
		const valueKey = this.valueKey
		
		// first tranform the originalData into the format we want:
		// {
		//     series = [{ name = ..., values = [ ... ]}]
		// }
		var data = {}
		data.y = originalData.y
		data.dates = originalData.dates.map(d3.utcParse("%m/%d/%Y"))
		
		var title = this.title

		if (key && valueKey) {
			const entry = originalData.series.filter(function (e) {
				return e.id == key
			})[0]
			data.series = [{
				name: valueKey,
				id: valueKey,
				values: entry.values[valueKey],
			}]
			
			if (!title) {
				title = entry.name + " " + key
			}

		} else if (key && !valueKey) {
			const entry = originalData.series.filter(function (e) {
				return e.id == key
			})[0]
			data.series = []
			for (var vk in entry.values) {
				data.series.push({
					name: vk,
					id: vk,
					values: entry.values[vk]
				})
			}
			
			if (!title) {
				title = entry.name + " All"
			}
			
		} else if (!key && valueKey) {
			data.series = originalData.series.map(function (e) {
				return {
					name: e.name,
					id: e.id,
					values: e.values[valueKey]
				}
			})
			
			if (!title) {
				title = "All " + valueKey
			}
			
		}
		
		if (this.filter) {
			data = this.filter(data)
		}
		
		return [title, data]
	}
	
	handleResult(originalData) {
			
		const values = this.transformData(originalData)
		const title = values[0]
		const data = values[1]
		
		// then build up the SVG of the chart itself	
		const margin = ({top: 20, right: 20, bottom: 30, left: 80})

		const id = this.id	
		d3.select("#" + id).append("div").html(title)

		const height = this.height
		const width = this.width		

		var svg = d3.select("#" + id)
		    .append("svg")
		        .attr("width", width + margin.left + margin.right)
		        .attr("height", height + margin.top + margin.bottom)

		svg.append("g")
		        .attr("transform", 
		              "translate(" + margin.left + "," + margin.top + ")")

		const x = d3.scaleUtc()
		    .domain(d3.extent(data.dates))
		    .range([margin.left, width - margin.right])

		var y
		if (this.tightScale) {
			const min = d3.min(data.series, d => d3.min(d.values.filter(v => v >= 0)))
			const max = d3.max(data.series, d => d3.max(d.values))
			const round = this.round
			y = d3.scaleLinear()
			    .domain([min - (min % round), max + (max % round)]).nice()
			    .range([height - margin.bottom, margin.top])
		} else {
			y = d3.scaleLinear()
			    .domain([0, d3.max(data.series, d => d3.max(d.values))]).nice()
			    .range([height - margin.bottom, margin.top])
		}
		
		const xAxis = g => g
		    .attr("transform", `translate(0,${height - margin.bottom})`)
		    .call(d3.axisBottom(x).ticks(width / 200).tickSizeOuter(0))

		const yAxis = g => g
		    .attr("transform", `translate(${margin.left},0)`)
		    .call(d3.axisLeft(y))
		    .call(g => g.select(".domain").remove())
		    .call(g => g.select(".tick:last-of-type text").clone()
		        .attr("x", 3)
		        .attr("text-anchor", "start")
		        .attr("font-weight", "bold")
		        .text(data.y))

		const line = d3.line()
		    .defined(d => d != -1)
		    .x((d, i) => x(data.dates[i]))
		    .y(d => y(d))

			xAxis(svg.append("g"))

		svg.append("g")
			.call(xAxis);

		svg.append("g")
			.call(yAxis);

		const path = svg.append("g")
			.attr("fill", "none")
			.attr("stroke", "steelblue")
			.attr("stroke-width", 3)
			.attr("stroke-linejoin", "round")
			.attr("stroke-linecap", "round")
			.selectAll("path")
			.data(data.series)
			.join("path")
			.style("mix-blend-mode", "multiply")
			.attr("d", d => line(d.values));

		function numberWithCommas(x) {
			var parts = x.toString().split(".");
			parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",");
			return parts.join(".");
		}

		function hover(svg, path) {
			svg
			    .style("position", "relative");

			if ("ontouchstart" in document) svg
			    .style("-webkit-tap-highlight-color", "transparent")
			    .on("touchmove", moved)
			    .on("touchstart", entered)
			    .on("touchend", left)
			else svg
			    .on("mousemove", moved)
			    .on("mouseenter", entered)
			    .on("mouseleave", left);

			const dot = svg.append("g")
			    .attr("display", "none");

			dot.append("circle")
			    .attr("r", 2.5);

			dot.append("text")
			    .style("font", "10px sans-serif")
			    .attr("text-anchor", "middle")
			    .attr("y", -8);

			function moved() {
			  d3.event.preventDefault();
			  const ym = y.invert(d3.event.layerY);
			  const xm = x.invert(d3.event.layerX);
			  const i1 = d3.bisectLeft(data.dates, xm, 1);
			  const i0 = i1 - 1;
			  const i = xm - data.dates[i0] > data.dates[i1] - xm ? i1 : i0;
			  const s = data.series.reduce((a, b) => Math.abs(a.values[i] - ym) < Math.abs(b.values[i] - ym) ? a : b);
			  const delta = i == 0 ? 0 : s.values[i] - s.values[i - 1]
			  const deltaLabel = delta == 0 ? "" : "(" + (delta < 0 ? "-" : "+") + numberWithCommas(Math.abs(delta)) + ")"
			  const label = s.name + ": " + numberWithCommas(s.values[i]) + " " + deltaLabel
			  path.attr("stroke", d => d === s ? null : "#ddd").filter(d => d === s).raise();
			  dot.attr("transform", `translate(${x(data.dates[i])},${y(s.values[i])})`);
			  dot.select("text").text(label);
			}

			function entered() {
			  path.style("mix-blend-mode", null).attr("stroke", "#ddd");
			  dot.attr("display", null);
			}

			function left() {
			  path.style("mix-blend-mode", "multiply").attr("stroke", null);
			  dot.attr("display", "none");
			}
		}
  
  	  	// apply the hover behavior
		hover(svg, path)
	}
}

function getUrlParameter(name) {
    name = name.replace(/[\[]/, '\\[').replace(/[\]]/, '\\]');
    var regex = new RegExp('[\\?&]' + name + '=([^&#]*)');
    var results = regex.exec(location.search);
    return results === null ? '' : decodeURIComponent(results[1].replace(/\+/g, ' '));
};
