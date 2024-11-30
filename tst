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
