import React, { useEffect, useRef } from "react";
import * as d3 from "d3";
import dagreD3 from "dagre-d3";

const HierarchicalGraph = ({ data }) => {
  const svgRef = useRef(null);

  useEffect(() => {
    const svg = d3.select(svgRef.current);
    const inner = svg.select("g");
    const graph = new dagreD3.graphlib.Graph().setGraph({
      rankdir: "TB", // Top-to-Bottom layout
      ranksep: 150, // Spacing between ranks
      nodesep: 100, // Spacing between nodes
    });

    // Add nodes to the graph
    data.nodes.forEach((node) => {
      graph.setNode(node.id, {
        label: `${node.id} (${node.type})`,
        class: "group-node",
      });
    });

    // Add edges (child nodes) to the graph
    data.nodes.forEach((node) => {
      node.child_nodes.forEach((child) => {
        graph.setEdge(node.id, child, {
          label: " ",
        });
      });
    });

    // Render the graph
    const render = new dagreD3.render();
    render(inner, graph);

    // Adjust SVG dimensions
    const { width, height } = svg.node().getBBox();
    svg.attr("width", width + 40).attr("height", height + 40);
    inner.attr("transform", "translate(20, 20)");
  }, [data]);

  return (
    <svg ref={svgRef} style={{ border: "1px solid black" }}>
      <g />
    </svg>
  );
};

// Sample JSON data (without x and y coordinates)
const jsonData = {
  nodes: [
    { id: "A", type: "Group", weight: 1, path: 1, child_nodes: ["B", "C", "D"] },
    { id: "B", type: "Group", weight: 2, path: 1, child_nodes: ["E"] },
    { id: "C", type: "Group", weight: 2, path: 1, child_nodes: [] },
    { id: "D", type: "Group", weight: 2, path: 1, child_nodes: ["E"] },
    { id: "E", type: "Group", weight: 3, path: 1, child_nodes: [] },
    { id: "P", type: "Group", weight: 1, path: 2, child_nodes: ["Q", "R"] },
    { id: "Q", type: "Group", weight: 2, path: 2, child_nodes: [] },
    { id: "R", type: "Group", weight: 2, path: 2, child_nodes: ["S"] },
    { id: "S", type: "Group", weight: 3, path: 2, child_nodes: [] },
  ],
};

export default function App() {
  return <HierarchicalGraph data={jsonData} />;
}











.group-node rect {
  fill: #3498db;
  stroke: #2980b9;
  rx: 5;
  ry: 5;
}

.group-node text {
  fill: white;
  font-weight: bold;
}

.edgePath path {
  stroke: #7f8c8d;
  stroke-width: 2px;
}


import React, { useEffect, useRef } from "react";
import * as d3 from "d3";
import dagreD3 from "dagre-d3";

const HierarchicalGraph = ({ data }) => {
  const svgRef = useRef(null);

  useEffect(() => {
    const svg = d3.select(svgRef.current);
    const inner = svg.select("g");
    const graph = new dagreD3.graphlib.Graph().setGraph({
      rankdir: "TB", // Top-to-Bottom layout
      ranksep: 150, // Spacing between ranks
      nodesep: 100, // Spacing between nodes
    });

    // Add nodes to the graph
    data.nodes.forEach((node) => {
      graph.setNode(node.id, {
        label: `${node.id} (${node.type})`,
        class: "group-node",
      });
    });

    // Add edges (child nodes) to the graph
    data.nodes.forEach((node) => {
      node.child_nodes.forEach((child) => {
        graph.setEdge(node.id, child, {
          label: " ",
        });
      });
    });

    // Render the graph
    const render = new dagreD3.render();
    render(inner, graph);

    // Adjust SVG dimensions
    const { width, height } = svg.node().getBBox();
    svg.attr("width", width + 40).attr("height", height + 40);
    inner.attr("transform", "translate(20, 20)");

    // Add background image
    svg
      .append("image")
      .attr("href", "path/to/your/background-image.jpg") // Replace with the path to your background image
      .attr("x", 0)
      .attr("y", 0)
      .attr("width", width + 40)
      .attr("height", height + 40)
      .lower(); // Push the image behind the graph

    // Add click event for highlighting predecessors and successors
    svg.selectAll("g.node").on("click", function (event, id) {
      // Reset styles
      svg.selectAll("g.node").classed("highlighted", false);
      svg.selectAll("g.edgePath").classed("highlighted", false);

      // Highlight the selected node
      d3.select(this).classed("highlighted", true);

      // Highlight successors
      const successors = graph.successors(id) || [];
      successors.forEach((succ) => {
        d3.select(`g.node[id="${succ}"]`).classed("highlighted", true);
        d3.select(`g.edgePath[id="${id}-${succ}"]`).classed("highlighted", true);
      });

      // Highlight predecessors if available
      const predecessors = graph.predecessors(id) || [];
      predecessors.forEach((pred) => {
        d3.select(`g.node[id="${pred}"]`).classed("highlighted", true);
        d3.select(`g.edgePath[id="${pred}-${id}"]`).classed("highlighted", true);
      });
    });
  }, [data]);

  return (
    <svg ref={svgRef} style={{ border: "1px solid black" }}>
      <g />
    </svg>
  );
};

// Sample JSON data (without x and y coordinates)
const jsonData = {
  nodes: [
    { id: "A", type: "Group", weight: 1, path: 1, child_nodes: ["B", "C", "D"] },
    { id: "B", type: "Group", weight: 2, path: 1, child_nodes: ["E"] },
    { id: "C", type: "Group", weight: 2, path: 1, child_nodes: [] },
    { id: "D", type: "Group", weight: 2, path: 1, child_nodes: ["E"] },
    { id: "E", type: "Group", weight: 3, path: 1, child_nodes: [] },
    { id: "P", type: "Group", weight: 1, path: 2, child_nodes: ["Q", "R"] },
    { id: "Q", type: "Group", weight: 2, path: 2, child_nodes: [] },
    { id: "R", type: "Group", weight: 2, path: 2, child_nodes: ["S"] },
    { id: "S", type: "Group", weight: 3, path: 2, child_nodes: [] },
  ],
};

export default function App() {
  return <HierarchicalGraph data={jsonData} />;
}






.group-node {
  fill: lightblue;
  stroke: black;
}

.highlighted {
  fill: orange !important;
  stroke: red !important;
}







import React, { useEffect, useRef, useState } from "react";
import * as d3 from "d3";
import dagreD3 from "dagre-d3";
import "./custom-graph.css";

const HierarchicalGraph = ({ data }) => {
  const svgRef = useRef(null);
  const [collapsedNodes, setCollapsedNodes] = useState({}); // Tracks collapsed nodes

  useEffect(() => {
    const svg = d3.select(svgRef.current);
    const inner = svg.select("g");

    const graph = new dagreD3.graphlib.Graph().setGraph({
      rankdir: "TB", // Top-to-Bottom layout
      ranksep: 100, // Spacing between ranks
      nodesep: 70,  // Spacing between nodes
    });

    // Add nodes to the graph
    data.nodes.forEach((node) => {
      const isCollapsed = collapsedNodes[node.id];
      graph.setNode(node.id, {
        label: `${node.id} (${node.type})`,
        class: isCollapsed ? "group-node collapsed" : "group-node",
      });
    });

    // Add edges (child nodes) to the graph
    data.nodes.forEach((node) => {
      if (!collapsedNodes[node.id]) {
        node.childNodes.forEach((child) => {
          graph.setEdge(node.id, child, {
            label: "",
            class: `edge-${node.id}-${child}`,
          });
        });
      }
    });

    // Render the graph
    const render = new dagreD3.render();
    render(inner, graph);

    // Adjust SVG dimensions
    const { width, height } = svg.node().getBBox();
    svg
      .attr("width", width + 40)
      .attr("height", height + 40);
    inner.attr("transform", "translate(20, 20)");

    // Add click event for collapsing/expanding nodes and highlighting
    svg.selectAll("g.node").on("click", function (event, id) {
      // Toggle collapse/expand state
      setCollapsedNodes((prevState) => ({
        ...prevState,
        [id]: !prevState[id],
      }));

      // Reset highlight styles
      d3.selectAll("g.node").classed("highlighted", false);
      d3.selectAll("g.edgePath").classed("highlighted", false);

      // Highlight the selected node
      d3.select(this).classed("highlighted", true);

      // Highlight successors
      const successors = graph.successors(id) || [];
      successors.forEach((succ) => {
        d3.select(`g.node[id="${succ}"]`).classed("highlighted", true);
        d3.select(`.edge-${id}-${succ}`).classed("highlighted", true);
      });

      // Highlight predecessors
      const predecessors = graph.predecessors(id) || [];
      predecessors.forEach((pred) => {
        d3.select(`g.node[id="${pred}"]`).classed("highlighted", true);
        d3.select(`.edge-${pred}-${id}`).classed("highlighted", true);
      });
    });
  }, [data, collapsedNodes]); // Re-render on data or collapse state change

  return (
    <svg ref={svgRef}>
      <g />
    </svg>
  );
};

export default HierarchicalGraph;




.group-node {
  fill: lightblue;
  stroke: black;
}

.group-node.collapsed {
  fill: lightgray;
}

.highlighted {
  stroke: red;
  stroke-width: 2px;
}

.edgePath.highlighted path {
  stroke: red;
  stroke-width: 2px;
}



import React, { useEffect, useRef, useState } from "react";
import * as d3 from "d3";
import dagreD3 from "dagre-d3";
import "./custom-graph.css";

const HierarchicalGraph = ({ data }) => {
  const svgRef = useRef(null);
  const [collapsedNodes, setCollapsedNodes] = useState({});

  useEffect(() => {
    if (!data || !Array.isArray(data.nodes)) {
      console.error("Invalid data format: `data.nodes` is required and should be an array.");
      return;
    }

    const svg = d3.select(svgRef.current);
    const inner = svg.select("g");

    const graph = new dagreD3.graphlib.Graph().setGraph({
      rankdir: "TB",
      ranksep: 100,
      nodesep: 70,
    });

    // Add nodes to the graph
    data.nodes.forEach((node) => {
      const isCollapsed = collapsedNodes[node.id];
      graph.setNode(node.id, {
        label: `${node.id} (${node.type})`,
        class: isCollapsed ? "group-node collapsed" : "group-node",
      });
    });

    // Add edges to the graph
    data.nodes.forEach((node) => {
      if (!node.childNodes || collapsedNodes[node.id]) return;

      node.childNodes.forEach((child) => {
        graph.setEdge(node.id, child, {
          label: "",
          class: `edge-${node.id}-${child}`,
        });
      });
    });

    const render = new dagreD3.render();
    render(inner, graph);

    const { width, height } = svg.node().getBBox();
    svg.attr("width", width + 40).attr("height", height + 40);
    inner.attr("transform", "translate(20, 20)");

    svg.selectAll("g.node").on("click", function (event, id) {
      setCollapsedNodes((prevState) => ({
        ...prevState,
        [id]: !prevState[id],
      }));
    });
  }, [data, collapsedNodes]);

  return (
    <svg ref={svgRef}>
      <g />
    </svg>
  );
};

export default HierarchicalGraph;
