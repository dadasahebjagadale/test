// CytoscapeGraph.js
import React, { useEffect, useRef } from "react";
import cytoscape from "cytoscape";

const CytoscapeGraph = ({ graphData }) => {
  const cyRef = useRef(null);

  useEffect(() => {
    const cy = cytoscape({
      container: cyRef.current, // Reference to the container div
      elements: [
        ...graphData.nodes.map((node) => ({ data: { id: node.id } })),
        ...graphData.edges.map((edge) => ({
          data: { source: edge.source, target: edge.target }
        }))
      ],
      layout: {
        name: "breadthfirst",
        directed: true,
        padding: 10,
        spacingFactor: 1.5,
        animate: true,
        fit: true,
        roots: "#parent",
        direction: "LR" // Left-to-right layout
      },
      style: [
        {
          selector: "node",
          style: {
            "background-color": "#0074D9",
            label: "data(id)",
            color: "#ffffff",
            "text-valign": "center",
            "text-halign": "center",
            "font-size": "12px"
          }
        },
        {
          selector: "edge",
          style: {
            "curve-style": "bezier",
            "target-arrow-shape": "triangle",
            "line-color": "#FF4136",
            "target-arrow-color": "#FF4136",
            width: 2
          }
        }
      ]
    });

    // Cleanup Cytoscape instance on component unmount
    return () => {
      cy.destroy();
    };
  }, [graphData]);

  return (
    <div
      ref={cyRef}
      style={{ width: "100%", height: "500px", border: "1px solid #ccc" }}
    ></div>
  );
};

export default CytoscapeGraph;



// GraphData.js
import React from "react";
import CytoscapeGraph from "./CytoscapeGraph";

const GraphData = () => {
  // Example data passed as props to the CytoscapeGraph component
  const graphData = {
    nodes: [
      { id: "parent" },
      { id: "child1" },
      { id: "child2" },
      { id: "child3" },
      { id: "grandchild1" },
      { id: "grandchild2" }
    ],
    edges: [
      { source: "parent", target: "child1" },
      { source: "parent", target: "child2" },
      { source: "child1", target: "grandchild1" },
      { source: "child2", target: "grandchild2" }
    ]
  };

  return (
    <div>
      <h2>Graph Display</h2>
      <CytoscapeGraph graphData={graphData} />
    </div>
  );
};

export default GraphData;



import React, { useEffect, useRef } from "react";
import * as d3 from "d3";

const Graph = () => {
  const svgRef = useRef();

  // Graph data
  const nodes = [
    { id: "parent1" },
    { id: "parent2" },
    { id: "child1" },
    { id: "child2" },
    { id: "child3" },
    { id: "subchild1" },
    { id: "subchild2" }
  ];

  const links = [
    { source: "parent1", target: "child1" },
    { source: "parent2", target: "child1" },
    { source: "child1", target: "child2" },
    { source: "child1", target: "child3" },
    { source: "child2", target: "subchild1" },
    { source: "child3", target: "subchild2" }
  ];

  useEffect(() => {
    const svg = d3.select(svgRef.current);
    const width = 1000;
    const height = 600;

    // Create a simulation
    const simulation = d3.forceSimulation(nodes)
      .force(
        "link",
        d3.forceLink(links).id((d) => d.id).distance(100)
      )
      .force("charge", d3.forceManyBody().strength(-300))
      .force("x", d3.forceX((d, i) => i * 200).strength(1)) // Left-to-right flow
      .force("y", d3.forceY(height / 2).strength(0.5)) // Center vertically
      .force("center", d3.forceCenter(width / 2, height / 2));

    // Draw links
    const link = svg
      .append("g")
      .attr("class", "links")
      .selectAll("line")
      .data(links)
      .enter()
      .append("line")
      .attr("stroke", "#FF4136")
      .attr("stroke-width", 2);

    // Draw nodes
    const node = svg
      .append("g")
      .attr("class", "nodes")
      .selectAll("g")
      .data(nodes)
      .enter()
      .append("g")
      .attr("class", "node");

    node
      .append("circle")
      .attr("r", 10)
      .attr("fill", "#0074D9");

    node
      .append("text")
      .attr("dy", -15)
      .text((d) => d.id)
      .attr("text-anchor", "middle");

    // Update positions on each tick
    simulation.on("tick", () => {
      link
        .attr("x1", (d) => d.source.x)
        .attr("y1", (d) => d.source.y)
        .attr("x2", (d) => d.target.x)
        .attr("y2", (d) => d.target.y);

      node.attr("transform", (d) => `translate(${d.x},${d.y})`);
    });

    // Cleanup on component unmount
    return () => {
      simulation.stop();
      svg.selectAll("*").remove();
    };
  }, [nodes, links]);

  return <svg ref={svgRef} width={1000} height={600}></svg>;
};

export default Graph;








