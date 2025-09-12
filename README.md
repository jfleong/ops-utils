# ops-utils

Collection of operational utilities for DevOps and system administration tasks.

## Scripts

### benchmark_urls.sh

A comprehensive URL benchmarking tool that measures response times and provides detailed performance statistics.

**Features:**
- Tests multiple URLs with configurable number of runs (default: 100)
- Calculates min, max, and average response times
- Provides percentile analysis (50th, 90th, 95th)
- Categorizes requests by speed: Fast (<200ms), Medium (200-500ms), Slow (>500ms)
- Real-time progress indicator
- Clean, emoji-enhanced output formatting

**Usage:**
```bash
# Benchmark single URL with default 100 runs
./scripts/benchmark_urls.sh https://example.com

# Benchmark multiple URLs
./scripts/benchmark_urls.sh https://site1.com https://site2.com

# Custom number of runs
./scripts/benchmark_urls.sh -n 50 https://example.com

# Benchmark with custom runs and multiple URLs
./scripts/benchmark_urls.sh -n 200 https://api1.com https://api2.com
```

**Output includes:**
- Response time statistics (min/max/average)
- Percentile breakdown (P50, P90, P95)
- Speed distribution analysis
- Progress tracking during execution

**Requirements:**
- `curl` for HTTP requests
- `bc` for floating-point calculations

### aws_login_bookmark_generator.sh

A Python script that generates browser bookmarks for quick AWS console access via SSO. Creates one-click links to all your AWS accounts and roles based on your local AWS configuration.

**Features:**
- Automatically reads AWS profiles from `~/.aws/config`
- Generates HTML bookmark file for browser import
- Creates direct links to AWS console for each account/role combination
- Alphabetically organizes bookmarks by profile name
- Skips default profiles for cleaner organization

**Installation & Usage:**
```bash
# Option 1: Using uv (Recommended)
curl -LsSf https://astral.sh/uv/install.sh | sh  # Install uv if needed
uv install                                        # Install dependencies
uv run scripts/aws_login_bookmark_generator.sh d-1234567890.awsapps.com

# Option 2: Using pip
pip install click>=8.0.0                         # Install dependencies
python3 scripts/aws_login_bookmark_generator.sh d-1234567890.awsapps.com

# View help and login domain instructions
python3 scripts/aws_login_bookmark_generator.sh --help
```

**Finding your login domain:**
1. Check `~/.aws/config` for `sso_start_url` entries
2. Extract domain from URLs like `https://d-1234567890.awsapps.com/start`
3. Check your AWS SSO portal URL from your admin
4. Run `aws sso login` and note the domain in the browser URL

**Output:**
- Creates `output.html` file in current directory
- Import this file into your browser's bookmarks
- Access any AWS account/role with a single click from your browser

**Requirements:**
- Configured AWS profiles in `~/.aws/config` with SSO settings
