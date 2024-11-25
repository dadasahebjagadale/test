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








