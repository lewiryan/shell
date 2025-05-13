import networkx as nx
import matplotlib.pyplot as plt

# Create a simple graph
G = nx.Graph()
nodes = ['SW1', 'SW2', 'SW3', 'SW4', 'SW5', 'SW6']
G.add_nodes_from(nodes)

edges = [
    ('SW1', 'SW2'), ('SW1', 'SW3'),
    ('SW2', 'SW3'), ('SW2', 'SW4'), ('SW2', 'SW5'),
    ('SW4', 'SW6'), ('SW4', 'SW5'), ('SW4', 'SW3'),
    ('SW3', 'SW5'), ('SW6', 'SW5')
]
G.add_edges_from(edges)

# Define fixed positions
pos = {
    'SW1': (0, 2), 'SW2': (-1, 1),
    'SW3': (1, 1), 'SW4': (-1, -1),
    'SW5': (1, -1), 'SW6': (0, -2)
}

# Draw the graph with red edges
plt.figure(figsize=(6, 6))
nx.draw(G, pos, with_labels=True, node_size=3000, node_color='lightblue',
        font_size=10, font_weight='bold', edge_color='red', style='solid',
        width=1.5)

# Save as PNG with no background
plt.savefig("network_graph.png", transparent=True, dpi=300)

# Show the graph
plt.show()
