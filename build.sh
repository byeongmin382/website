#!/bin/bash

# Website Build Script for Neocities Deployment
# This script helps manage the website structure and deployment

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show help
show_help() {
    echo "Website Build Script"
    echo "Usage: ./build.sh [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  new-post [category] [filename]  Create a new blog post"
    echo "  new-post-md [category] [filename]  Create a new markdown blog post"
    echo "  new-microblog [filename]       Create a new microblog entry (markdown)"
    echo "  build-microblog                Convert markdown to HTML and update microblog"
    echo "  build-posts                    Convert markdown blog posts to HTML"
    echo "  rebuild-indexes                Rebuild all index files from existing posts"
    echo "  build-all                      One-click build: convert markdown, rebuild indexes, inject nav/footer"
    echo "  inject-nav                    Inject navigation into all HTML pages"
    echo "  inject-footer                  Inject footer into all HTML pages"
    echo "  validate                       Validate HTML structure"
    echo "  clean                          Clean up temporary files"
    echo "  deploy                         Prepare for Neocities deployment"
    echo "  help                           Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./build.sh new-post thoughts my-new-thought"
    echo "  ./build.sh new-microblog 2025-01-15-my-entry"
    echo "  ./build.sh build-microblog"
    echo "  ./build.sh validate"
    echo "  ./build.sh deploy"
}

# Function to update index pages with new posts
update_index_pages() {
    local category=$1
    local filename=$2
    local display_title=$3
    
    print_status "Updating index pages..."
    
    # Update category index page
    local category_index="public/posts/$category/index.html"
    if [ -f "$category_index" ]; then
        # Create a temporary file with the new post entry
        local temp_file=$(mktemp)
        
        # Find the line with "최근 글" and add the new post after it
        awk -v new_post="<li><a href=\"$filename.html\">$display_title</a></li>" '
            /<h2>최근 글/ {
                print $0
                getline
                if ($0 ~ /<ul>/) {
                    print $0
                    print "        " new_post
                    getline
                    while ($0 ~ /<li><a href=/) {
                        print "        " $0
                        getline
                    }
                    print "      </ul>"
                } else {
                    print "      <ul>"
                    print "        " new_post
                    print "      </ul>"
                }
                next
            }
            { print }
        ' "$category_index" > "$temp_file"
        
        # Replace the original file
        mv "$temp_file" "$category_index"
        print_success "Updated $category index page"
    fi
    
    # Update main index.html
    local main_index="public/index.html"
    if [ -f "$main_index" ]; then
        # Create a temporary file with the new post entry
        local temp_file=$(mktemp)
        
        # Find the line with "최근 발행된 글" and add the new post after it
        awk -v new_post="<li><a href=posts/$category/$filename.html>$display_title</a></li>" '
            /<h2>최근 발행된 글/ {
                print $0
                getline
                if ($0 ~ /<ul>/) {
                    print $0
                    print "        " new_post
                    getline
                    while ($0 ~ /<li><a href=posts/) {
                        print "        " $0
                        getline
                    }
                    print "      </ul>"
                } else {
                    print "      <ul>"
                    print "        " new_post
                    print "      </ul>"
                }
                next
            }
            { print }
        ' "$main_index" > "$temp_file"
        
        # Replace the original file
        mv "$temp_file" "$main_index"
        print_success "Updated main index page"
    fi
}

# Function to create a new microblog entry
create_microblog_entry() {
    local filename=$1
    
    if [ -z "$filename" ]; then
        print_error "Filename is required"
        echo "Usage: ./build.sh new-microblog [filename]"
        exit 1
    fi
    
    local markdown_dir="public/markdown/microblog"
    local template_file="$markdown_dir/template.md"
    local new_entry="$markdown_dir/$filename.md"
    
    # Check if entry already exists
    if [ -f "$new_entry" ]; then
        print_error "Microblog entry already exists: $new_entry"
        exit 1
    fi
    
    # Create entry from template
    if [ -f "$template_file" ]; then
        cp "$template_file" "$new_entry"
        print_success "Created new microblog entry: $new_entry"
        print_status "Edit the markdown file to add your content"
        print_status "Run './build.sh build-microblog' to convert to HTML"
    else
        print_error "Template file not found: $template_file"
        exit 1
    fi
}

# Function to convert markdown to HTML and update microblog
build_microblog() {
    print_status "Building microblog from markdown..."
    
    local markdown_dir="public/markdown/microblog"
    local microblog_html="public/microblog/microblog.html"
    
    if [ ! -d "$markdown_dir" ]; then
        print_error "Markdown directory not found: $markdown_dir"
        exit 1
    fi
    
    # Create a temporary file for the new microblog content
    local temp_file=$(mktemp)
    
    # Start with the HTML header
    cat > "$temp_file" << 'EOF'
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="짧은 기록들" />
    <title>마이크로블로그</title>
    <link href="../assets/css/style.css" rel="stylesheet" type="text/css" media="all">
  </head>
  <body>
    <display_title>
      <center>
        마이크로블로그
      </center>
    </display_title>
<nav class="main-nav">
<div class="nav-container">
  <a href="../index.html" class="nav-link">Home</a>
  <a href="../posts/travel-food/index.html" class="nav-link">여행과 식도락</a>
  <span class="nav-link disabled">게임</span>
  <span class="nav-link disabled">기술</span>
  <a href="../posts/thoughts/index.html" class="nav-link">생각</a>
  <a href="../microblog/microblog.html" class="nav-link">마이크로블로그</a>
  <a href="https://flickr.com/photos/202913508@N04/" class="nav-link" target="_blank" rel="noopener">사진들</a>
  <a href="https://www.instagram.com/garfield_kbm/" class="nav-link" target="_blank" rel="noopener">인스타그램</a>
</div>
</nav>
    <div class="container">
EOF

    # Process markdown files in reverse chronological order
    local current_year=""
    local current_month=""
    
    # First, collect all files with their dates and sort by date (newest first)
    local sort_file=$(mktemp)
    find "$markdown_dir" -name "*.md" -not -name "template.md" | while read -r markdown_file; do
        local basename=$(basename "$markdown_file" .md)
        local date=""
        local year=""
        local month=""
        local day=""
        local sortable_date=""
        
        # Try YYYY-MM-DD format first
        date=$(echo "$basename" | grep -o '[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}' || echo "")
        if [ -n "$date" ]; then
            year=$(echo "$date" | cut -d'-' -f1)
            month=$(echo "$date" | cut -d'-' -f2)
            day=$(echo "$date" | cut -d'-' -f3)
            sortable_date="${year}${month}${day}"
        else
            # Try YYMMDD format (6 digits)
            local yymmdd=$(echo "$basename" | grep -o '^[0-9]\{6\}' || echo "")
            if [ -n "$yymmdd" ]; then
                year="20$(echo "$yymmdd" | cut -c1-2)"
                month=$(echo "$yymmdd" | cut -c3-4)
                day=$(echo "$yymmdd" | cut -c5-6)
                sortable_date="${year}${month}${day}"
            fi
        fi
        
        # Only include files with valid dates
        if [ -n "$sortable_date" ]; then
            echo "${sortable_date}|${markdown_file}" >> "$sort_file"
        fi
    done
    
    # Sort by date in reverse order (newest first) and process
    sort -r "$sort_file" | cut -d'|' -f2 | while read -r markdown_file; do
        local basename=$(basename "$markdown_file" .md)
        local date=""
        local year=""
        local month=""
        local day=""
        
        # Try YYYY-MM-DD format first
        date=$(echo "$basename" | grep -o '[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}' || echo "")
        if [ -n "$date" ]; then
            year=$(echo "$date" | cut -d'-' -f1)
            month=$(echo "$date" | cut -d'-' -f2)
            day=$(echo "$date" | cut -d'-' -f3)
        else
            # Try YYMMDD format (6 digits)
            local yymmdd=$(echo "$basename" | grep -o '^[0-9]\{6\}' || echo "")
            if [ -n "$yymmdd" ]; then
                year="20$(echo "$yymmdd" | cut -c1-2)"
                month=$(echo "$yymmdd" | cut -c3-4)
                day=$(echo "$yymmdd" | cut -c5-6)
            fi
        fi
        
        if [ -n "$year" ] && [ -n "$month" ] && [ -n "$day" ]; then
            
            # Add year header if changed
            if [ "$year" != "$current_year" ]; then
                echo "<h1 id=\"년-${year}년-${month}월-마이크로블로그\">${year}년 ${month}월</h1>" >> "$temp_file"
                current_year="$year"
                current_month="$month"
            fi
            
            # Add month header if changed
            if [ "$month" != "$current_month" ]; then
                echo "<h1 id=\"년-${year}년-${month}월-마이크로블로그\">${year}년 ${month}월</h1>" >> "$temp_file"
                current_month="$month"
            fi
            
            # Add day header
            echo "<h2 id=\"년-${month}월-${day}일\">${year}년 ${month}월 ${day}일</h2>" >> "$temp_file"
            
            # Convert markdown to HTML using pandoc
            pandoc -f markdown -t html --syntax-highlighting=none "$markdown_file" >> "$temp_file"
        fi
    done
    
    # Clean up temporary sort file
    rm -f "$sort_file"
    
    # Add HTML footer
    cat >> "$temp_file" << 'EOF'
    </div>
    <br><br>
    <footer>
    <!-- Footer will be injected by build script -->
    </footer>
  </body>
</html>
EOF

    # Replace the original microblog file
    mv "$temp_file" "$microblog_html"
    print_success "Microblog updated from markdown files"
    print_status "Check $microblog_html for the updated content"
}

# Function to convert markdown blog posts to HTML
build_posts() {
    print_status "Building blog posts from markdown..."
    
    local markdown_dir="public/markdown/posts"
    local posts_dir="public/posts"
    
    if [ ! -d "$markdown_dir" ]; then
        print_error "Markdown posts directory not found: $markdown_dir"
        exit 1
    fi
    
    # Process each category
    for category in thoughts travel-food tech; do
        local category_markdown_dir="$markdown_dir/$category"
        local category_posts_dir="$posts_dir/$category"
        
        if [ ! -d "$category_markdown_dir" ]; then
            print_warning "No markdown files found for category: $category"
            continue
        fi
        
        # Create posts directory if it doesn't exist
        mkdir -p "$category_posts_dir"
        
        # Process each markdown file
        find "$category_markdown_dir" -name "*.md" -not -name "template.md" | while read -r markdown_file; do
            local basename=$(basename "$markdown_file" .md)
            local html_file="$category_posts_dir/$basename.html"
            
            print_status "Converting: $markdown_file -> $html_file"
            
            # Extract title from markdown file (first # heading)
            local title=$(grep -m 1 '^# ' "$markdown_file" | sed 's/^# //')
            if [ -z "$title" ]; then
                # Fallback to filename if no title found
                title=$(echo "$basename" | sed 's/_/ /g' | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')
            fi
            
            # Extract description from markdown file (first paragraph after title, skip metadata)
            local description=$(awk '/^# /{for(i=1;i<=5;i++){getline; if($0 !~ /^$|^\*\*|^---|^##/) {print $0; exit}}}' "$markdown_file")
            if [ -z "$description" ]; then
                description="A $category post about $title"
            fi
            
            # Create HTML file with proper structure
            cat > "$html_file" << EOF
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="$description">
    <title>병민의 하루: $title</title>
    <link href="../../assets/css/style.css" rel="stylesheet" type="text/css" media="all">
  </head>
  <body>
  <display_title>
  <center>
  $title
  </center>
  </display_title>
<nav class="main-nav">
<div class="nav-container">
  <a href="../../index.html" class="nav-link">Home</a>
  <a href="../../posts/travel-food/index.html" class="nav-link">여행과 식도락</a>
  <span class="nav-link disabled">게임</span>
  <span class="nav-link disabled">기술</span>
  <a href="../../posts/thoughts/index.html" class="nav-link">생각</a>
  <a href="../../microblog/microblog.html" class="nav-link">마이크로블로그</a>
  <a href="https://flickr.com/photos/202913508@N04/" class="nav-link" target="_blank" rel="noopener">사진들</a>
  <a href="https://www.instagram.com/garfield_kbm/" class="nav-link" target="_blank" rel="noopener">인스타그램</a>
</div>
</nav>
    <div class="container">
EOF
            
            # Convert markdown to HTML using pandoc
            pandoc -f markdown -t html --syntax-highlighting=none "$markdown_file" >> "$html_file"
            
            # Add footer placeholder
            cat >> "$html_file" << EOF
    </div>
    <br><br>
    <footer>
    <!-- Footer will be injected by build script -->
    </footer>
  </body>
</html>
EOF
            
            print_success "Converted: $basename"
        done
    done
    
    print_success "Blog posts updated from markdown files"
    print_status "Run './build.sh inject-nav' and './build.sh inject-footer' to update navigation and footer"
}

# Function to rebuild all index files from existing posts
rebuild_indexes() {
    print_status "Rebuilding all index files from existing posts..."
    
    # Rebuild thoughts index
    local thoughts_dir="public/posts/thoughts"
    local thoughts_index="$thoughts_dir/index.html"
    
    if [ -d "$thoughts_dir" ]; then
        print_status "Rebuilding thoughts index..."
        
        # Create temporary file
        local temp_file=$(mktemp)
        
        # Start with the HTML header
        cat > "$temp_file" << 'EOF'
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="병민의 생각과 일상에 대한 글들입니다." />
    <title>병민의 하루: 생각</title>
    <link href="../../assets/css/style.css" rel="stylesheet" type="text/css" media="all">
  </head>
  <body>
    <display_title>
      <br>
      <center>
        &#128221; 생각
      </center>
    </display_title>
<nav class="main-nav">
<div class="nav-container">
  <a href="../../index.html" class="nav-link">Home</a>
  <a href="../../posts/travel-food/index.html" class="nav-link">여행과 식도락</a>
  <span class="nav-link disabled">게임</span>
  <span class="nav-link disabled">기술</span>
  <a href="../../posts/thoughts/index.html" class="nav-link">생각</a>
  <a href="../../microblog/microblog.html" class="nav-link">마이크로블로그</a>
  <a href="https://flickr.com/photos/202913508@N04/" class="nav-link" target="_blank" rel="noopener">사진들</a>
  <a href="https://www.instagram.com/garfield_kbm/" class="nav-link" target="_blank" rel="noopener">인스타그램</a>
</div>
</nav>
    <div class="container">
      <h1>생각과 일상</h1>
      <p>일상에서 느낀 생각들과 경험을 기록합니다.</p>
      
      <h2>최근 글</h2>
      <ul>
EOF
        
        # Find all HTML files in thoughts directory (excluding index.html)
        find "$thoughts_dir" -name "*.html" -not -name "index.html" | sort -r | while read -r html_file; do
            local basename=$(basename "$html_file" .html)
            local title=""
            
            # Extract title from HTML file
            if [ -f "$html_file" ]; then
                title=$(grep -o '<title>병민의 하루: [^<]*</title>' "$html_file" | sed 's/<title>병민의 하루: //' | sed 's/<\/title>//')
                if [ -z "$title" ]; then
                    # Fallback to filename if title not found
                    title=$(echo "$basename" | sed 's/_/ /g' | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')
                fi
                
                # Extract date from filename if it follows the pattern YYYYMMDD
                local date=""
                if echo "$basename" | grep -q '^[0-9]\{8\}'; then
                    local year=$(echo "$basename" | cut -c1-4)
                    local month=$(echo "$basename" | cut -c5-6)
                    local day=$(echo "$basename" | cut -c7-8)
                    date="($year-$month-$day)"
                fi
                
                echo "        <li><a href=\"$basename.html\">$title $date</a></li>" >> "$temp_file"
            fi
        done
        
        # Add footer placeholder
        cat >> "$temp_file" << 'EOF'
      </ul>
    </div>
    <br><br>
    <footer>
    <!-- Footer will be injected by build script -->
    </footer>
  </body>
</html>
EOF
        
        # Replace the original file
        mv "$temp_file" "$thoughts_index"
        print_success "Updated thoughts index"
    fi
    
    # Rebuild travel-food index
    local travel_food_dir="public/posts/travel-food"
    local travel_food_index="$travel_food_dir/index.html"
    
    if [ -d "$travel_food_dir" ]; then
        print_status "Rebuilding travel-food index..."
        
        # Create temporary file
        local temp_file=$(mktemp)
        
        # Start with the HTML header
        cat > "$temp_file" << 'EOF'
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="여행과 식도락에 대한 글들입니다." />
    <title>병민의 하루: 여행과 식도락</title>
    <link href="../../assets/css/style.css" rel="stylesheet" type="text/css" media="all">
  </head>
  <body>
    <display_title>
      <br>
      <center>
        &#127829; 여행과 식도락
      </center>
    </display_title>
<nav class="main-nav">
<div class="nav-container">
  <a href="../../index.html" class="nav-link">Home</a>
  <a href="../../posts/travel-food/index.html" class="nav-link">여행과 식도락</a>
  <span class="nav-link disabled">게임</span>
  <span class="nav-link disabled">기술</span>
  <a href="../../posts/thoughts/index.html" class="nav-link">생각</a>
  <a href="../../microblog/microblog.html" class="nav-link">마이크로블로그</a>
  <a href="https://flickr.com/photos/202913508@N04/" class="nav-link" target="_blank" rel="noopener">사진들</a>
  <a href="https://www.instagram.com/garfield_kbm/" class="nav-link" target="_blank" rel="noopener">인스타그램</a>
</div>
</nav>
    <div class="container">
      <h1>여행과 식도락</h1>
      <p>여행 경험과 맛있는 음식에 대한 이야기를 기록합니다.</p>
      
      <h2>최근 글</h2>
      <ul>
EOF
        
        # Find all HTML files in travel-food directory (excluding index.html)
        find "$travel_food_dir" -name "*.html" -not -name "index.html" | sort -r | while read -r html_file; do
            local basename=$(basename "$html_file" .html)
            local title=""
            
            # Extract title from HTML file
            if [ -f "$html_file" ]; then
                title=$(grep -o '<title>병민의 하루: [^<]*</title>' "$html_file" | sed 's/<title>병민의 하루: //' | sed 's/<\/title>//')
                if [ -z "$title" ]; then
                    # Fallback to filename if title not found
                    title=$(echo "$basename" | sed 's/_/ /g' | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')
                fi
                
                # Extract date from filename if it follows the pattern YYYYMMDD
                local date=""
                if echo "$basename" | grep -q '^[0-9]\{8\}'; then
                    local year=$(echo "$basename" | cut -c1-4)
                    local month=$(echo "$basename" | cut -c5-6)
                    local day=$(echo "$basename" | cut -c7-8)
                    date="($year-$month-$day)"
                fi
                
                echo "        <li><a href=\"$basename.html\">$title $date</a></li>" >> "$temp_file"
            fi
        done
        
        # Add footer placeholder
        cat >> "$temp_file" << 'EOF'
      </ul>
    </div>
    <br><br>
    <footer>
    <!-- Footer will be injected by build script -->
    </footer>
  </body>
</html>
EOF
        
        # Replace the original file
        mv "$temp_file" "$travel_food_index"
        print_success "Updated travel-food index"
    fi
    
    # Rebuild tech index
    local tech_dir="public/posts/tech"
    local tech_index="$tech_dir/index.html"
    
    if [ -d "$tech_dir" ]; then
        print_status "Rebuilding tech index..."
        
        # Create temporary file
        local temp_file=$(mktemp)
        
        # Start with the HTML header
        cat > "$temp_file" << 'EOF'
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="기술과 개발에 대한 글들입니다." />
    <title>병민의 하루: 기술</title>
    <link href="../../assets/css/style.css" rel="stylesheet" type="text/css" media="all">
  </head>
  <body>
    <display_title>
      <br>
      <center>
        &#128187; 기술
      </center>
    </display_title>
<nav class="main-nav">
<div class="nav-container">
  <a href="../../index.html" class="nav-link">Home</a>
  <a href="../../posts/travel-food/index.html" class="nav-link">여행과 식도락</a>
  <span class="nav-link disabled">게임</span>
  <a href="../../posts/tech/index.html" class="nav-link">기술</a>
  <a href="../../posts/thoughts/index.html" class="nav-link">생각</a>
  <a href="../../microblog/microblog.html" class="nav-link">마이크로블로그</a>
  <a href="https://flickr.com/photos/202913508@N04/" class="nav-link" target="_blank" rel="noopener">사진들</a>
  <a href="https://www.instagram.com/garfield_kbm/" class="nav-link" target="_blank" rel="noopener">인스타그램</a>
</div>
</nav>
    <div class="container">
      <h1>기술과 개발</h1>
      <p>프로그래밍, 개발 도구, 기술 트렌드에 대한 이야기를 기록합니다.</p>
      
      <h2>최근 글</h2>
      <ul>
EOF
        
        # Find all HTML files in tech directory (excluding index.html)
        find "$tech_dir" -name "*.html" -not -name "index.html" | sort -r | while read -r html_file; do
            local basename=$(basename "$html_file" .html)
            local title=""
            
            # Extract title from HTML file
            if [ -f "$html_file" ]; then
                title=$(grep -o '<title>병민의 하루: [^<]*</title>' "$html_file" | sed 's/<title>병민의 하루: //' | sed 's/<\/title>//')
                if [ -z "$title" ]; then
                    # Fallback to filename if title not found
                    title=$(echo "$basename" | sed 's/_/ /g' | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')
                fi
                
                # Extract date from filename if it follows the pattern YYYYMMDD
                local date=""
                if echo "$basename" | grep -q '^[0-9]\{8\}'; then
                    local year=$(echo "$basename" | cut -c1-4)
                    local month=$(echo "$basename" | cut -c5-6)
                    local day=$(echo "$basename" | cut -c7-8)
                    date="($year-$month-$day)"
                fi
                
                echo "        <li><a href=\"$basename.html\">$title $date</a></li>" >> "$temp_file"
            fi
        done
        
        # Add footer placeholder
        cat >> "$temp_file" << 'EOF'
      </ul>
    </div>
    <br><br>
    <footer>
    <!-- Footer will be injected by build script -->
    </footer>
  </body>
</html>
EOF
        
        # Replace the original file
        mv "$temp_file" "$tech_index"
        print_success "Updated tech index"
    fi
    
    # Update main index posts list only (preserve custom content)
    local main_index="public/index.html"
    print_status "Updating main index posts list (preserving custom content)..."
    
    # Create temporary file
    local temp_file=$(mktemp)
    
    # Generate the new posts list
    local posts_list=""
    find public/posts -name "*.html" -not -name "index.html" -exec ls -t {} + | head -10 | while read -r html_file; do
        local basename=$(basename "$html_file" .html)
        local relative_path=$(echo "$html_file" | sed 's|public/||')
        local title=""
        
        # Extract title from HTML file
        if [ -f "$html_file" ]; then
            title=$(grep -o '<title>병민의 하루: [^<]*</title>' "$html_file" | sed 's/<title>병민의 하루: //' | sed 's/<\/title>//')
            if [ -z "$title" ]; then
                # Fallback to filename if title not found
                title=$(echo "$basename" | sed 's/_/ /g' | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')
            fi
            
            # Extract date from filename if it follows the pattern YYYYMMDD
            local date=""
            if echo "$basename" | grep -q '^[0-9]\{8\}'; then
                local year=$(echo "$basename" | cut -c1-4)
                local month=$(echo "$basename" | cut -c5-6)
                local day=$(echo "$basename" | cut -c7-8)
                date="($year-$month-$day)"
            fi
            
            echo "        <li><a href=$relative_path>$title $date</a></li>"
        fi
    done > "$temp_file"
    
    # Update the main index file by replacing only the posts list section
    awk -v posts_file="$temp_file" '
    BEGIN { 
        in_posts_list = 0
        posts_replaced = 0
        # Read the new posts list
        while ((getline line < posts_file) > 0) {
            posts_content = posts_content line "\n"
        }
        close(posts_file)
    }
    
    # Detect start of posts list
    /<h2>최근 발행된 글/ {
        print $0
        getline
        if ($0 ~ /<ul>/) {
            print $0
            printf "%s", posts_content
            getline
            # Skip existing list items until we find the closing </ul>
            while ($0 !~ /<\/ul>/) {
                getline
            }
            print "      </ul>"
            posts_replaced = 1
        } else {
            print "      <ul>"
            printf "%s", posts_content
            print "      </ul>"
            posts_replaced = 1
        }
        next
    }
    
    # Skip content while inside the posts list (until </ul>)
    in_posts_list && /<\/ul>/ {
        in_posts_list = 0
        next
    }
    
    # Track if we are inside the posts list
    /<ul>/ && /최근 발행된 글/ { in_posts_list = 1 }
    in_posts_list { next }
    
    # Print all other lines
    { print }
    ' "$main_index" > "${temp_file}.new"
    
    # Replace the original file
    mv "${temp_file}.new" "$main_index"
    rm -f "$temp_file"
    print_success "Updated main index posts list (preserved custom content)"
    
    print_success "All index files rebuilt successfully!"
    print_status "Run './build.sh inject-nav' and './build.sh inject-footer' to update navigation and footer"
}

# Function to perform complete build workflow
build_all() {
    print_status "🚀 Starting one-click build process..."
    print_status "This will clean files, convert markdown, rebuild indexes, and update navigation/footer"
    echo ""
    
    # Step 1: Clean up temporary files
    print_status "Step 1/5: Cleaning up temporary files..."
    clean_files
    echo ""
    
    # Step 2: Convert markdown microblog
    print_status "Step 2/5: Converting microblog markdown to HTML..."
    build_microblog
    echo ""
    
    # Step 3: Convert markdown blog posts
    print_status "Step 3/5: Converting blog posts markdown to HTML..."
    build_posts
    echo ""
    
    # Step 4: Rebuild all indexes
    print_status "Step 4/5: Rebuilding all index files..."
    rebuild_indexes
    echo ""
    
    # Step 5: Inject navigation and footer
    print_status "Step 5/5: Updating navigation and footer on all pages..."
    inject_navigation
    inject_footer
    echo ""
    
    print_success "🎉 One-click build completed successfully!"
    print_status "Your website is now fully updated and ready for deployment"
    print_status "Run './build.sh deploy' to prepare for Neocities deployment"
}

# Function to create a new markdown blog post
create_new_markdown_post() {
    local category=$1
    local filename=$2
    
    if [ -z "$category" ] || [ -z "$filename" ]; then
        print_error "Usage: ./build.sh new-post-md [category] [filename]"
        print_error "Categories: thoughts, travel-food, tech"
        exit 1
    fi
    
    # Validate category
    if [ "$category" != "thoughts" ] && [ "$category" != "travel-food" ] && [ "$category" != "tech" ]; then
        print_error "Invalid category. Use: thoughts, travel-food, tech"
        exit 1
    fi
    
    local markdown_dir="public/markdown/posts/$category"
    local template_file="public/templates/markdown/blog_post_template.md"
    local new_post="$markdown_dir/$filename.md"
    
    # Create directory if it doesn't exist
    mkdir -p "$markdown_dir"
    
    # Check if post already exists
    if [ -f "$new_post" ]; then
        print_error "Post already exists: $new_post"
        exit 1
    fi
    
    if [ -f "$template_file" ]; then
        # Generate title from filename
        local title=$(echo "$filename" | sed 's/_/ /g' | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')
        
        # Get current date
        local current_date=$(date +"%Y-%m-%d")
        
        # Create the new post from template
        sed -e "s/POST_TITLE/$title/g" \
            -e "s/POST_DATE/$current_date/g" \
            -e "s/POST_CATEGORY/$category/g" \
            -e "s/POST_DESCRIPTION/A $category post about $title/g" \
            "$template_file" > "$new_post"
        
        print_success "Created new markdown post: $new_post"
        print_status "Edit the file to add your content"
        print_status "Run './build.sh build-posts' to convert to HTML"
    else
        print_error "Template file not found: $template_file"
        exit 1
    fi
}

# Function to create a new blog post
create_new_post() {
    local category=$1
    local filename=$2
    
    if [ -z "$category" ] || [ -z "$filename" ]; then
        print_error "Category and filename are required"
        echo "Usage: ./build.sh new-post [category] [filename]"
        echo "Categories: thoughts, travel-food, tech"
        exit 1
    fi
    
    # Validate category
    if [ "$category" != "thoughts" ] && [ "$category" != "travel-food" ] && [ "$category" != "tech" ]; then
        print_error "Invalid category. Use 'thoughts', 'travel-food', or 'tech'"
        exit 1
    fi
    
    local post_dir="public/posts/$category"
    local template_file="public/templates/blog_post_template.html"
    local new_post="$post_dir/$filename.html"
    
    # Check if post already exists
    if [ -f "$new_post" ]; then
        print_error "Post already exists: $new_post"
        exit 1
    fi
    
    # Create post from template
    if [ -f "$template_file" ]; then
        cp "$template_file" "$new_post"
        
        # Generate title from filename
        # Convert filename to title (replace underscores and hyphens with spaces, capitalize)
        local display_title=$(echo "$filename" | sed 's/_/ /g' | sed 's/-/ /g' | sed 's/\b\w/\U&/g')
        local page_title="$display_title"
        
        # Replace placeholders in the new post
        sed -i.bak "s/POST_TITLE/$page_title/g" "$new_post"
        sed -i.bak "s/POST_DISPLAY_TITLE/$display_title/g" "$new_post"
        sed -i.bak "s/POST_DESCRIPTION/A blog post about $display_title/g" "$new_post"
        
        # Remove backup file
        rm "$new_post.bak"
        
        print_success "Created new post: $new_post"
        print_success "Title automatically set to: $display_title"
        
        # Update index pages
        update_index_pages "$category" "$filename" "$display_title"
        
        print_status "Edit the file to add your content and customize the description"
    else
        print_error "Template file not found: $template_file"
        exit 1
    fi
}

# Function to validate HTML structure
validate_html() {
    print_status "Validating HTML structure..."
    
    local issues=0
    local warnings=0
    local errors=0
    
    # Check for missing DOCTYPE declarations
    print_status "Checking DOCTYPE declarations..."
    find public/ -name "*.html" | grep -v "/components/" | while read -r file; do
        if ! grep -q "<!DOCTYPE html>" "$file"; then
            print_error "Missing DOCTYPE declaration in: $file"
            ((errors++))
        fi
    done
    
    # Check for missing viewport meta tags
    print_status "Checking viewport meta tags..."
    find public/ -name "*.html" | grep -v "/components/" | while read -r file; do
        if ! grep -q "meta name=\"viewport\"" "$file"; then
            print_warning "Missing viewport meta tag in: $file"
            print_status "  → Add: <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">"
            ((warnings++))
        fi
    done
    
    # Check for missing alt attributes on images
    print_status "Checking image alt attributes..."
    find public/ -name "*.html" | while read -r file; do
        local missing_alt=$(grep -n "src=" "$file" | grep -v "alt=" | head -5)
        if [ -n "$missing_alt" ]; then
            print_warning "Images missing alt attributes in: $file"
            echo "$missing_alt" | while read -r line; do
                print_status "  → Line $line: Add alt=\"description\" to img tag"
            done
            ((warnings++))
        fi
    done
    
    # Check for broken internal links
    print_status "Checking internal links..."
    find public/ -name "*.html" | while read -r file; do
        local file_dir=$(dirname "$file")
        local links=$(grep -o 'href="[^"]*"' "$file" | grep -v "http" | grep -v "mailto" | sed 's/href="//g' | sed 's/"//g')
        for link in $links; do
            # Handle relative paths
            local target_path
            if [[ "$link" == /* ]]; then
                # Absolute path from public root
                target_path="public$link"
            else
                # Relative path from current file
                target_path="$file_dir/$link"
            fi
            
            # Check if target exists
            if [ ! -f "$target_path" ] && [ ! -d "$target_path" ]; then
                print_error "Broken link in $file: $link"
                print_status "  → Expected: $target_path"
                ((errors++))
            fi
        done
    done
    
    # Check for missing closing tags
    print_status "Checking HTML tag balance..."
    find public/ -name "*.html" | while read -r file; do
        # Count self-closing tags and regular tags separately
        local self_closing=$(grep -o '<[^>]*/>' "$file" | wc -l)
        local open_tags=$(grep -o '<[^/][^>]*>' "$file" | grep -v '/>' | wc -l)
        local close_tags=$(grep -o '</[^>]*>' "$file" | wc -l)
        
        # Adjust for self-closing tags
        local adjusted_open=$((open_tags - self_closing))
        
        if [ "$adjusted_open" -ne "$close_tags" ]; then
            print_warning "Possible unclosed tags in: $file"
            print_status "  → Open tags: $adjusted_open, Close tags: $close_tags"
            print_status "  → Check for missing </div>, </p>, </body>, </html>"
            ((warnings++))
        fi
    done
    
    # Check for missing CSS links
    print_status "Checking CSS links..."
    find public/ -name "*.html" | while read -r file; do
        if ! grep -q "link.*stylesheet" "$file"; then
            print_warning "Missing CSS stylesheet link in: $file"
            print_status "  → Add: <link href=\"../assets/css/style.css\" rel=\"stylesheet\" type=\"text/css\" media=\"all\">"
            ((warnings++))
        fi
    done
    
    # Check for missing navigation components
    print_status "Checking navigation components..."
    find public/ -name "*.html" | grep -v "/components/" | while read -r file; do
        if ! grep -q "fetch.*nav.html" "$file"; then
            print_warning "Missing navigation component in: $file"
            print_status "  → Add navigation script or check if intentional"
            ((warnings++))
        fi
    done
    
    # Check for missing footer components
    print_status "Checking footer components..."
    find public/ -name "*.html" | grep -v "/components/" | while read -r file; do
        if ! grep -q "fetch.*footer.html" "$file"; then
            print_warning "Missing footer component in: $file"
            print_status "  → Add footer script or check if intentional"
            ((warnings++))
        fi
    done
    
    # Check for proper charset declarations
    print_status "Checking charset declarations..."
    find public/ -name "*.html" | grep -v "/components/" | while read -r file; do
        if ! grep -q "charset.*UTF-8" "$file"; then
            print_warning "Missing UTF-8 charset in: $file"
            print_status "  → Add: <meta charset=\"UTF-8\">"
            ((warnings++))
        fi
    done
    
    # Check for missing title tags
    print_status "Checking title tags..."
    find public/ -name "*.html" | grep -v "/components/" | while read -r file; do
        if ! grep -q "<title>" "$file"; then
            print_error "Missing title tag in: $file"
            print_status "  → Add: <title>Your Page Title</title>"
            ((errors++))
        fi
    done
    
    # Summary
    local total_issues=$((errors + warnings))
    if [ $total_issues -eq 0 ]; then
        print_success "HTML validation passed! No issues found."
    else
        print_warning "Found $total_issues issues: $errors errors, $warnings warnings"
        print_status "Run './build.sh help' for more information on fixing these issues"
    fi
}

# Function to clean up temporary files
clean_files() {
    print_status "Cleaning up temporary files..."
    
    # Remove .DS_Store files
    find public/ -name ".DS_Store" -delete 2>/dev/null || true
    
    # Remove any backup files
    find public/ -name "*.bak" -delete 2>/dev/null || true
    find public/ -name "*~" -delete 2>/dev/null || true
    
    print_success "Cleanup completed"
}

# Function to inject navigation into all HTML pages
inject_navigation() {
    print_status "Injecting navigation into all HTML pages..."
    
    # Check if navigation components exist
    local nav_files=("public/components/nav-root.html" "public/components/nav-level1.html" "public/components/nav-level2.html")
    for nav_file in "${nav_files[@]}"; do
        if [ ! -f "$nav_file" ]; then
            print_error "Navigation component not found: $nav_file"
            exit 1
        fi
    done
    
    # Find all HTML files (excluding components, templates, and not_found.html by basename)
    find public/ -name "*.html" -not -path "*/components/*" -not -path "*/templates/*" -not -name "not_found.html" | while read -r html_file; do
        # Explicitly skip not_found.html (match by basename to be robust)
        if [ "$(basename "$html_file")" = "not_found.html" ]; then
            print_status "Skipping footer injection for: $html_file"
            continue
        fi
        local file_dir=$(dirname "$html_file")
        local nav_component=""
        local relative_path=""
        
        # Calculate relative path from HTML file to components directory
        # Count path segments after "public/"
        local path_after_public=$(echo "$file_dir" | sed 's|public/||')
        local depth=$(echo "$path_after_public" | grep -o "/" | wc -l)
        
        if [ -z "$path_after_public" ] || [ "$path_after_public" = "public" ]; then
            # File is in public/ root
            nav_component="nav-root.html"
            relative_path="components/nav-root.html"
        elif [ "$depth" -eq 0 ]; then
            # File is one level deep (e.g., public/microblog/)
            nav_component="nav-level1.html"
            relative_path="../components/nav-level1.html"
        elif [ "$depth" -eq 1 ]; then
            # File is two levels deep (e.g., public/posts/thoughts/)
            nav_component="nav-level2.html"
            relative_path="../../components/nav-level2.html"
        else
            print_warning "Unexpected file depth for: $html_file (depth: $depth, path: $path_after_public)"
            continue
        fi
        
        # Create a temporary file
        local temp_file=$(mktemp)
        
        # Read the navigation content
        local nav_content_file="public/components/$nav_component"
        
        # Process the HTML file
        awk -v nav_file="$nav_content_file" '
        BEGIN { 
            in_nav = 0
            nav_replaced = 0
            # Read navigation content
            while ((getline line < nav_file) > 0) {
                nav_content = nav_content line "\n"
            }
            close(nav_file)
        }
        
        # Detect navigation section
        /<nav/ {
            in_nav = 1
            print "<nav class=\"main-nav\">"
            printf "%s", nav_content
            print "</nav>"
            nav_replaced = 1
            next
        }
        
        # Skip content inside nav until closing tag
        in_nav && /<\/nav>/ {
            in_nav = 0
            next
        }
        
        # Skip content while inside nav
        in_nav { next }
        
        # Print all other lines
        { print }
        ' "$html_file" > "$temp_file"
        
        # Replace the original file
        mv "$temp_file" "$html_file"
        print_success "Updated navigation in: $html_file (using $nav_component)"
    done
    
    print_success "Navigation injection completed!"
    print_status "All HTML pages now use the centralized navigation component"
    print_status "To update navigation, edit the nav-*.html files in components/"
}

# Function to inject footer into all HTML pages
inject_footer() {
    print_status "Injecting footer into all HTML pages..."
    
    # Check if footer component exists
    if [ ! -f "public/components/footer.html" ]; then
        print_error "Footer component not found: public/components/footer.html"
        exit 1
    fi
    
    # Find all HTML files (excluding components, templates, and not_found.html by name)
    find public/ -name "*.html" -not -path "*/components/*" -not -path "*/templates/*" -not -name "not_found.html" | while read -r html_file; do
        local file_dir=$(dirname "$html_file")
        local relative_path=""
        
        # Calculate relative path from HTML file to components directory
        local path_after_public=$(echo "$file_dir" | sed 's|public/||')
        local depth=$(echo "$path_after_public" | grep -o "/" | wc -l)
        
        if [ -z "$path_after_public" ] || [ "$path_after_public" = "public" ]; then
            # File is in public/ root
            relative_path="assets/images/"
        elif [ "$depth" -eq 0 ]; then
            # File is one level deep (e.g., public/microblog/)
            relative_path="../assets/images/"
        elif [ "$depth" -eq 1 ]; then
            # File is two levels deep (e.g., public/posts/thoughts/)
            relative_path="../../assets/images/"
        else
            print_warning "Unexpected file depth for: $html_file (depth: $depth, path: $path_after_public)"
            continue
        fi
        
        # Create a temporary file
        local temp_file=$(mktemp)
        
        # Read the footer content and adjust image paths
        local footer_content_file=$(mktemp)
        cat "public/components/footer.html" | sed "s|../assets/images/|$relative_path|g" > "$footer_content_file"
        
        # Process the HTML file
        awk -v footer_file="$footer_content_file" '
        BEGIN { 
            in_footer = 0
            footer_replaced = 0
        }
        /<footer>/ {
            in_footer = 1
            print $0
            next
        }
        in_footer && /<\/footer>/ {
            # Read and print footer content from file
            while ((getline line < footer_file) > 0) {
                print line
            }
            close(footer_file)
            print "</footer>"
            in_footer = 0
            footer_replaced = 1
            next
        }
        in_footer {
            # Skip content inside footer tags
            next
        }
        {
            print $0
        }
        END {
            if (!footer_replaced) {
                print "<!-- Footer injection failed for this file -->"
            }
        }' "$html_file" > "$temp_file"
        
        # Clean up footer content file
        rm -f "$footer_content_file"
        
        # Replace the original file
        mv "$temp_file" "$html_file"
        print_status "Updated footer in: $html_file"
    done
    
    print_success "Footer injection completed!"
    print_status "All HTML pages now use the centralized footer component"
    print_status "To update footer, edit public/components/footer.html and run './build.sh inject-footer'"
}

# Function to prepare for deployment
prepare_deploy() {
    print_status "Preparing for Neocities deployment..."
    
    # Clean up files first
    clean_files
    
    # Validate structure
    validate_html
    
    # Check that all required files exist
    local required_files=(
        "public/index.html"
        "public/assets/css/style.css"
        "public/components/nav.html"
        "public/components/footer.html"
    )
    
    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            print_error "Required file missing: $file"
            exit 1
        fi
    done
    
    # Create a simple deployment checklist
    cat > public/DEPLOYMENT_CHECKLIST.md << EOF
# Deployment Checklist

## Pre-deployment
- [ ] All files are in the public/ directory
- [ ] All paths use relative references
- [ ] No absolute URLs in navigation
- [ ] All images have alt attributes
- [ ] CSS and fonts are properly linked

## Files to upload to Neocities
- Upload the entire contents of the public/ directory
- Make sure to preserve the directory structure

## Post-deployment
- [ ] Test all navigation links
- [ ] Verify images load correctly
- [ ] Check responsive design on mobile
- [ ] Test external links

## Directory Structure
\`\`\`
public/
├── index.html
├── assets/
├── components/
├── templates/
├── posts/
└── microblog/
\`\`\`
EOF
    
    print_success "Deployment preparation complete!"
    print_status "Check public/DEPLOYMENT_CHECKLIST.md for deployment instructions"
}

# Main script logic
case "${1:-help}" in
    "new-post")
        create_new_post "$2" "$3"
        ;;
    "new-post-md")
        create_new_markdown_post "$2" "$3"
        ;;
    "new-microblog")
        create_microblog_entry "$2"
        ;;
    "build-microblog")
        build_microblog
        ;;
    "build-posts")
        build_posts
        ;;
    "rebuild-indexes")
        rebuild_indexes
        ;;
    "build-all")
        build_all
        ;;
    "inject-nav")
        inject_navigation
        ;;
    "inject-footer")
        inject_footer
        ;;
    "validate")
        validate_html
        ;;
    "clean")
        clean_files
        ;;
    "deploy")
        prepare_deploy
        ;;
    "help"|*)
        show_help
        ;;
esac
