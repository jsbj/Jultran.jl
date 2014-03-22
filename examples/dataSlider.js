var timeIndex = 0

var tScale
function dataSlider(svg, dim, data, updateVis) {    
    var sliderTicks = [];
    var sliderRange = [0, dim.width];
    for(var k in data.ts) sliderTicks.push(k);

    tScale = d3.scale.ordinal()
        .domain(sliderTicks)
        .range(data.ts);
    
    var sliderX = d3.scale.ordinal()
        .domain(sliderTicks)
        .rangePoints(sliderRange);
    
    var brush = d3.svg.brush()
        .x(sliderX)
        .extent([0, 0])
        .on("brush", brushed);
    
    var sliderG = svg.append("g")
        .attr("transform", "translate(" + dim.x + "," + dim.y + ")");
    
    sliderG.append("g")
        .attr("id", "slider")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + dim.height / 2 + ")")
        .call(d3.svg.axis()
            .scale(sliderX)
            .orient("bottom")
            .tickSize(0)
            .tickPadding(12)
            .tickFormat(function(d) {
                t = tScale(d)
                if ((d % 100) == 0) {
                // if (Math.abs(t * 10 - Math.floor(t * 10)) < 0.00001) {
                    return "" + t
                } else {
                    return ""
                }
            })
        )
        .select(".domain")
        .select(function() { return this.parentNode.appendChild(this.cloneNode(true)); })
        .attr("class", "halo");
    
    var slider = sliderG.append("g")
        .attr("class", "slider")
        .call(brush);
    
    slider.selectAll(".extent,.resize")
        .remove();
    
    slider.select(".background")
        .attr("height", dim.height);
    
    var handle = slider.append("circle")
        .attr("class", "handle")
        .attr("transform", "translate(0," + dim.height / 2 + ")")
        .attr("r", 9);
    
    slider.call(brush.event);
    
    function brushed() {
        var value = brush.extent()[0];
    
        if (d3.event.sourceEvent) { // not a programmatic event
            timeIndex = Math.round((d3.mouse(this)[0] / (sliderRange[1] - sliderRange[0])) * (sliderTicks.length - 1))

            if (timeIndex >= 0) {
                if (timeIndex < data.ts.length) {
                    brush.extent([timeIndex, timeIndex]);
                    updateVis(timeIndex, data);
                }
            }
        }
        
        handle.attr("cx", sliderX(timeIndex));
    }
    
    d3.select("body")
        .on("keydown", function(){
            switch(d3.event.keyCode) {
                case 37:
                    timeIndex = Math.max(0,timeIndex-1)
                    break;
                case 39:
                    timeIndex = Math.min(data.ts.length-1,timeIndex+1)
                    break;
            }
            brush.extent([timeIndex, timeIndex]);
            updateVis(timeIndex, data);
            handle.attr("cx", sliderX(timeIndex));
        })
        
    updateVis(0, data);
}