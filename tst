import React, { useEffect, useRef, useState } from "react";
import * as d3 from "d3";
import dagreD3 from "dagre-d3";
import "./custom-graph.css";

const HierarchicalGraph = ({ data }) => {
  const svgRef = useRef(null);
  const [collapsedNodes, setCollapsedNodes] = useState({});

  useEffect(() => {
    const svg = d3.select(svgRef.current);
    const inner = svg.select("g");
    const graph = new dagreD3.graphlib.Graph()
      .setGraph({
        rankdir: "TB",
        ranksep: 100,
        nodesep: 70
      })
      .setDefaultEdgeLabel(() => ({}));

    // Recursive node addition with collapse handling
    const addNodesAndEdges = (nodeId) => {
      const node = data.nodes.find(n => n.id === nodeId);
      if (!node) return;

      graph.setNode(node.id, {
        label: `${node.id}`,
        class: `group-node ${collapsedNodes[node.id] ? "collapsed" : ""}`
      });

      if (!collapsedNodes[node.id] && node.child_nodes) {
        node.child_nodes.forEach(childId => {
          graph.setEdge(node.id, childId, {
            class: `edge-${node.id}-${childId}`
          });
          addNodesAndEdges(childId);
        });
      }
    };

    // Find root nodes (nodes without parents)
    const rootNodes = data.nodes.filter(node => 
      !data.nodes.some(n => 
        n.child_nodes && n.child_nodes.includes(node.id)
      )
    );

    // Clear existing graph and re-render
    inner.selectAll("*").remove();
    rootNodes.forEach(node => addNodesAndEdges(node.id));

    // Create renderer and draw graph
    const render = dagreD3.render();
    render(inner, graph);

    // Set up zoom/pan
    const zoom = d3.zoom().on("zoom", (event) => {
      inner.attr("transform", event.transform);
    });
    svg.call(zoom);

    // Set initial viewport
    const { width, height } = svg.node().getBBox();
    svg
      .attr("width", Math.max(width, 800))
      .attr("height", Math.max(height, 600))
      .call(zoom.transform, d3.zoomIdentity.translate(20, 20));

    // Recursively find all predecessors (ancestors) of a node
    const getAllPredecessors = (nodeId, visited = new Set()) => {
      const predecessors = graph.predecessors(nodeId) || [];
      predecessors.forEach(pred => {
        if (!visited.has(pred)) {
          visited.add(pred);
          getAllPredecessors(pred, visited); // Recursively find predecessors
        }
      });
      return Array.from(visited);
    };

    // Node interaction handlers
    const handleNodeClick = (event, id) => {
      // Reset all highlights
      d3.selectAll(".highlighted").classed("highlighted", false);

      // Highlight the clicked node
      const node = d3.select(event.currentTarget);
      node.classed("highlighted", true);

      // Highlight all predecessors (including indirect ones)
      const allPredecessors = getAllPredecessors(id);
      allPredecessors.forEach(pred => {
        d3.select(`.node-${pred}`).classed("highlighted", true);
        // Highlight the edge from the predecessor to the current node
        d3.select(`.edge-${pred}-${id}`).classed("highlighted", true);
      });

      // Highlight only the link to one immediate successor
      const successors = graph.successors(id) || [];
      if (successors.length > 0) {
        const firstSuccessor = successors[0];
        d3.select(`.edge-${id}-${firstSuccessor}`).classed("highlighted", true);
      }
    };

    const handleNodeDoubleClick = (event, id) => {
      // Toggle collapsed state
      setCollapsedNodes(prev => ({ ...prev, [id]: !prev[id] }));
    };

    // Add event listeners
    svg.selectAll("g.node")
      .on("click", handleNodeClick)
      .on("dblclick", handleNodeDoubleClick);

  }, [data, collapsedNodes]);

  return (
    <svg ref={svgRef} style={{ border: "1px solid #ddd" }}>
      <g />
    </svg>
  );
};

export default HierarchicalGraph;
