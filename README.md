# 병민의 하루 - Personal Website

A personal blog website built with vanilla HTML, CSS, and JavaScript, designed for deployment on Neocities. Features markdown-based microblog with Pandoc conversion and component-based architecture.

🌐 **Live Site**: https://www.kobm.xyz

## ⚡ Quick Start

**After adding/editing posts, just run:**
```bash
./build.sh build-all
```

This single command handles everything: converts markdown, rebuilds indexes, and updates navigation/footer.

## 📁 Project Structure

```
website/
├── build.sh                    # Build script for website management
├── README.md                   # This file
├── .gitignore                  # Git ignore rules
└── public/                     # All website files (Neocities deployment)
    ├── index.html              # Homepage
    ├── assets/                 # Static assets
    │   ├── css/
    │   │   └── style.css       # Main stylesheet
    │   ├── fonts/              # Custom fonts
    │   └── images/             # Images and badges
    ├── components/             # Reusable HTML components
    │   ├── nav.html            # Navigation component
    │   └── footer.html         # Footer component
    ├── templates/              # HTML templates
    │   └── blog_post_template.html
    ├── posts/                  # Blog posts organized by category
    │   ├── thoughts/           # Personal thoughts and experiences
    │   └── travel-food/        # Travel and food content
    ├── microblog/              # Microblog content (HTML)
    └── markdown/               # Markdown source files
        ├── microblog/          # Microblog entries in markdown
        └── posts/              # Blog posts in markdown
            ├── thoughts/       # Thoughts posts in markdown
            └── travel-food/    # Travel-food posts in markdown
```

## 📋 Available Commands

| Command | Purpose |
|---------|---------|
| `./build.sh new-post [category] [filename]` | Create a new blog post |
| `./build.sh new-post-md [category] [filename]` | Create a new markdown blog post |
| `./build.sh new-microblog [filename]` | Create a new microblog entry |
| `./build.sh build-microblog` | Convert markdown to HTML using Pandoc |
| `./build.sh build-posts` | Convert markdown blog posts to HTML |
| `./build.sh rebuild-indexes` | Rebuild all index files from existing posts |
| `./build.sh build-all` | **One-click build: convert markdown, rebuild indexes, inject nav/footer** |
| `./build.sh inject-nav` | Update navigation on all pages |
| `./build.sh inject-footer` | Update footer on all pages |
| `./build.sh validate` | Validate HTML structure |
| `./build.sh clean` | Clean up temporary files |
| `./build.sh deploy` | Prepare for Neocities deployment |

## 🚀 Quick Start

### Prerequisites
- Bash shell (macOS/Linux/WSL)
- Basic knowledge of HTML/CSS
- Pandoc (for markdown conversion) - install with `brew install pandoc`

### Setup
1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd website
   ```

2. Make the build script executable:
   ```bash
   chmod +x build.sh
   ```

## 🛠️ Build Script Usage

The `build.sh` script provides several commands to help manage the website:

### Available Commands

#### Create a New Blog Post
```bash
./build.sh new-post [category] [filename]
```

**Categories:**
- `thoughts` - Personal thoughts and experiences
- `travel-food` - Travel and food content

#### Create a New Markdown Blog Post
```bash
./build.sh new-post-md [category] [filename]
```

**Categories:**
- `thoughts` - Personal thoughts and experiences
- `travel-food` - Travel and food content

**Benefits of Markdown Posts:**
- ✅ **Pandoc conversion** - Professional markdown to HTML conversion
- ✅ **Rich formatting** - Tables, code blocks, math equations, etc.
- ✅ **Easy editing** - Write in markdown, get clean HTML
- ✅ **Version control friendly** - Markdown is easier to diff and merge

**Examples:**
```bash
# Create a new thoughts post
./build.sh new-post thoughts my-new-thought
# Generates title: "My New Thought"

# Create a new travel-food post
./build.sh new-post travel-food restaurant-review
# Generates title: "Restaurant Review"

# Filename with underscores and hyphens
./build.sh new-post thoughts my_daily_reflection
# Generates title: "My Daily Reflection"
```

#### Create a New Microblog Entry (Markdown)
```bash
./build.sh new-microblog [filename]
```

**Filename Format:**
- Use date-based naming: `YYYY-MM-DD-description`
- Example: `2025-01-15-my-thoughts`

**Examples:**
```bash
# Create a new microblog entry
./build.sh new-microblog 2025-01-15-daily-thoughts

# Convert markdown to HTML using Pandoc
./build.sh build-microblog

# Convert markdown blog posts to HTML
./build.sh build-posts

# Rebuild all index files (removes deleted posts from indexes)
./build.sh rebuild-indexes

# One-click build: convert markdown, rebuild indexes, inject nav/footer
./build.sh build-all
```

#### Rebuild All Index Files
```bash
./build.sh rebuild-indexes
```
Automatically rebuilds all index files by scanning existing HTML posts. This is useful when:
- Posts are deleted and need to be removed from index files
- You want to ensure all indexes are up-to-date
- Posts are moved or renamed

**What it does:**
- ✅ Scans `public/posts/` directories for existing HTML files
- ✅ Extracts titles and dates from HTML files
- ✅ Rebuilds main index, thoughts index, and travel-food index
- ✅ Removes references to deleted posts
- ✅ Maintains proper HTML structure and navigation

#### One-Click Build (Recommended)
```bash
./build.sh build-all
```
**The ultimate convenience command!** This single command handles everything you need after adding or editing posts:

**What it does automatically:**
- ✅ **Step 1**: Converts microblog markdown to HTML using Pandoc
- ✅ **Step 2**: Converts blog posts markdown to HTML using Pandoc  
- ✅ **Step 3**: Rebuilds all index files (removes deleted, adds new posts)
- ✅ **Step 4**: Updates navigation and footer on all pages

**Perfect for:**
- 🚀 **After adding new posts** - Everything gets updated automatically
- 🔄 **After editing existing posts** - Changes are reflected everywhere
- 🧹 **After deleting posts** - Removed from all indexes automatically
- 📝 **After markdown changes** - All conversions and updates handled

**Usage:**
```bash
# After creating/editing posts, just run:
./build.sh build-all

# Your website is now fully updated and ready!
```

#### Inject Navigation into All Pages
```bash
./build.sh inject-nav
```
Automatically injects navigation components into all HTML pages based on their directory depth.

**What it does:**
- ✅ Reads navigation components from `public/components/`
- ✅ Injects appropriate navigation based on file depth
- ✅ Uses `nav-root.html` for root level pages
- ✅ Uses `nav-level1.html` for microblog pages
- ✅ Uses `nav-level2.html` for posts pages
- ✅ Updates all HTML files with inline navigation

#### Inject Footer into All Pages
```bash
./build.sh inject-footer
```
Automatically injects the footer component into all HTML pages with correct relative paths.

**What it does:**
- ✅ Reads footer content from `public/components/footer.html`
- ✅ Automatically adjusts image paths based on page location
- ✅ Injects footer content into all HTML files
- ✅ Maintains HTML structure and formatting
- ✅ Works with static hosting (Neocities compatible)

**Usage:**
1. Edit `public/components/footer.html` to update footer content
2. Run `./build.sh inject-footer` to update all pages
3. Deploy to Neocities - no JavaScript required!

**When to use:**
- After modifying footer content
- When adding new pages that need footer
- To ensure consistent footer across all pages

**Navigation Components:**
- `public/components/nav-root.html` - For root level pages
- `public/components/nav-level1.html` - For microblog pages
- `public/components/nav-level2.html` - For posts pages

#### Validate HTML Structure
```bash
./build.sh validate
```
Comprehensive HTML validation with detailed feedback:

**Checks performed:**
- ✅ DOCTYPE declarations
- ✅ Viewport meta tags
- ✅ Image alt attributes (with line numbers)
- ✅ Broken internal links (with expected paths)
- ✅ HTML tag balance (open vs close tags)
- ✅ CSS stylesheet links
- ✅ Navigation and footer components
- ✅ UTF-8 charset declarations
- ✅ Title tags

**Output includes:**
- Specific file names and line numbers
- Exact code to add for fixes
- Clear error vs warning distinction
- Helpful suggestions for resolution

#### Clean Temporary Files
```bash
./build.sh clean
```
Removes `.DS_Store` files and other temporary files.

#### Prepare for Deployment
```bash
./build.sh deploy
```
Validates the structure and creates a deployment checklist.

#### Show Help
```bash
./build.sh help
```
Displays all available commands and usage examples.

## 📝 Creating New Content

### Blog Posts
1. Use the build script to create a new post:
   ```bash
   ./build.sh new-post thoughts my-post-name
   ```

2. The script automatically:
   - Creates the HTML file from template
   - Generates title from filename (converts underscores/hyphens to spaces, capitalizes)
   - Sets meta description
   - Updates all title placeholders

3. Edit the generated HTML file in `public/posts/[category]/` to:
   - Add your content in the main container
   - Customize the description if needed
   - Add images and formatting

### Microblog (Markdown-based)
1. Create a new microblog entry:
   ```bash
   ./build.sh new-microblog 2025-01-15-my-entry
   ```

2. Edit the markdown file in `public/markdown/microblog/`:
   - Write your content in markdown format
   - Use standard markdown syntax (bold, italic, links, etc.)
   - Include images using HTML `<figure>` tags

3. Convert to HTML and update microblog:
   ```bash
   ./build.sh build-microblog
   ```

**Markdown Features Supported (via Pandoc):**
- **Bold** and *italic* text
- [Links](https://example.com)
- `Code snippets` and code blocks with syntax highlighting
- > Blockquotes
- Lists (ordered and unordered)
- Headers (H1-H6)
- Tables
- Images and figures
- HTML tags for complex formatting
- Math equations (LaTeX)
- And all other standard Markdown features

### Pandoc Integration

The microblog system uses **Pandoc** for professional-quality markdown conversion:

**Benefits:**
- ✅ **Reliable conversion** - handles all standard markdown features
- ✅ **Clean HTML output** - semantic, well-structured HTML
- ✅ **Code highlighting** - proper `<pre><code>` with language classes
- ✅ **Math support** - LaTeX equations and mathematical notation
- ✅ **Table support** - automatic HTML table generation
- ✅ **Standards compliant** - follows markdown specifications

**Installation:**
```bash
# macOS (using Homebrew)
brew install pandoc

# Linux (using package manager)
sudo apt-get install pandoc  # Ubuntu/Debian
sudo yum install pandoc      # CentOS/RHEL
```

**Usage:**
The build script automatically uses Pandoc for markdown conversion:
```bash
./build.sh build-microblog  # Uses pandoc internally
```

### Post Management Workflow

#### 🚀 Quick Workflow (Recommended)
```bash
# After creating/editing/deleting posts, just run:
./build.sh build-all

# That's it! Everything is updated automatically.
```

#### 📋 Detailed Workflow (Manual Steps)
**When posts are deleted:**
```bash
# 1. Delete the post file(s)
rm public/posts/thoughts/old-post.html

# 2. Rebuild indexes to remove from index files
./build.sh rebuild-indexes

# 3. Update navigation and footer
./build.sh inject-nav
./build.sh inject-footer
```

**When posts are added:**
```bash
# 1. Create new post (HTML or markdown)
./build.sh new-post thoughts my-new-post
# OR
./build.sh new-post-md thoughts my-new-post

# 2. Convert markdown to HTML (if using markdown)
./build.sh build-posts

# 3. Rebuild indexes to include new posts
./build.sh rebuild-indexes

# 4. Update navigation and footer
./build.sh inject-nav
./build.sh inject-footer
```

**💡 Pro Tip:** Use `./build.sh build-all` instead of running individual commands - it's faster and less error-prone!

### Adding Images
1. Place images in the `pics/` folder within your post directory
2. Use the provided image template in the HTML:
   ```html
   <figure>
     <img src="./pics/your-image.jpg" title="Image Title" alt="Image Description" />
     <figcaption aria-hidden="true">Image Caption</figcaption>
   </figure>
   ```

### Updating Navigation

The website uses a centralized navigation system with multiple components for different directory levels.

**Navigation Components:**
- `public/components/nav-root.html` - For root level pages (index.html)
- `public/components/nav-level1.html` - For microblog pages
- `public/components/nav-level2.html` - For posts pages

**To update navigation:**
1. Edit the appropriate navigation component file(s)
2. Run the injection script to apply changes to all pages:
   ```bash
   ./update-nav.sh
   ```
   Or use the build script directly:
   ```bash
   ./build.sh inject-nav
   ```

**Quick Navigation Update:**
```bash
# Simple script to update navigation across all pages
./update-nav.sh
```

This ensures all pages have consistent navigation with correct relative paths for their directory level.

## 🎨 Customization

### Styling
- Main stylesheet: `public/assets/css/style.css`
- Custom font: Neo둥근모 (neodgm)
- Color scheme: Light background with accent colors

### Fonts
- Custom font files are in `public/assets/fonts/`
- Font family: `neodgm` (Neo둥근모)

## 🚀 Deployment to Neocities

### Pre-deployment Checklist
1. Run the deployment preparation:
   ```bash
   ./build.sh deploy
   ```

2. Verify all files are in the `public/` directory
3. Check that all paths use relative references
4. Test navigation and links locally

### Deployment Steps
1. Upload the entire contents of the `public/` directory to Neocities
2. Preserve the directory structure
3. Test all functionality after deployment

### Post-deployment Testing
- [ ] Test all navigation links
- [ ] Verify images load correctly
- [ ] Check responsive design on mobile
- [ ] Test external links

## 🔧 Development

### File Organization
- **Assets**: All static files (CSS, fonts, images) in `public/assets/`
- **Components**: Reusable HTML components in `public/components/`
- **Templates**: HTML templates in `public/templates/`
- **Content**: Blog posts organized by category in `public/posts/`

### Path Structure
- All paths use relative references for Neocities compatibility
- CSS files reference fonts with `../fonts/` paths
- Components use relative paths to assets

## 📱 Features

- **Responsive Design**: Mobile-friendly layout
- **Custom Typography**: Neo둥근모 font for Korean text
- **Component-based**: Reusable navigation and footer
- **SEO Optimized**: Proper meta tags and structure
- **Accessibility**: Alt attributes and semantic HTML

## 🐛 Troubleshooting

### Common Issues

**Images not loading:**
- Check that image paths are relative
- Verify images are in the correct directory
- Ensure alt attributes are present

**Navigation not working:**
- Verify component paths are correct
- Check that nav.html and footer.html are in components/
- Test relative path references

**CSS not applying:**
- Check that style.css path is correct
- Verify font files are in assets/fonts/
- Test relative path references

### Getting Help
1. Run `./build.sh validate` to check for issues
2. Check the deployment checklist: `public/DEPLOYMENT_CHECKLIST.md`
3. Verify all files are in the `public/` directory

## 📄 License

This project is for personal use. Feel free to use the structure and build script as inspiration for your own website.

---

**Built with ❤️ for the personal web**
