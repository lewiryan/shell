import os

def create_index_md(directory):
    # Use the folder name as the title (or "Documentation" for the root folder)
    folder_name = os.path.basename(directory) or "Documentation"
    
    # Gather subdirectories and Markdown files (excluding _index.md)
    subdirs = sorted([d for d in os.listdir(directory) if os.path.isdir(os.path.join(directory, d))])
    md_files = sorted([f for f in os.listdir(directory) if f.endswith(".md") and f != "_index.md"])
    
    # Define template strings for folder and markdown cards.
    # We need to double the curly braces to output literal ones.
    folder_card_template = '  {{{{< card link="{link}" title="{title}" icon="library" >}}}}'
    md_card_template = '  {{{{< card link="{link}" title="{title}" icon="document-text" >}}}}'
    
    # Build the _index.md content with Hugo cards shortcode
    lines = []
    lines.append("---")
    lines.append('title: "{}"'.format(folder_name.replace("-", " ").title()))
    lines.append("sidebar:")
    lines.append("  open: false")
    lines.append("---")
    lines.append("")  # Blank line to separate front matter from content
    lines.append("") 
    lines.append("The following topics are:")
    lines.append("")
    lines.append("<!--more-->")
    lines.append("")
    lines.append("{{< cards >}}")
    
    # Create a card for each subdirectory (using the library icon)
    for subdir in subdirs:
        title = subdir.replace("-", " ").title()
        card_line = folder_card_template.format(link=subdir, title=title)
        lines.append(card_line)
    
    # Create a card for each Markdown file (using the document-text icon)
    for md_file in md_files:
        name = os.path.splitext(md_file)[0]
        title = name.replace("-", " ").title()
        card_line = md_card_template.format(link=name, title=title)
        lines.append(card_line)
    
    lines.append("{{< /cards >}}")
    
    index_path = os.path.join(directory, "_index.md")
    with open(index_path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))
    print(f"Created {index_path}")

def generate_indexes(root_dir):
    # Walk through every folder in the root directory.
    for current_dir, dirs, files in os.walk(root_dir):
        create_index_md(current_dir)

# Replace 'path/to/ccie' with the actual path to your unzipped CCIE folder.
generate_indexes("ccie")
