Daily Work (use your enhanced setup):

git checkout personal/docker-mcp-enhanced

# Make your changes...

git add .
git commit -m "Your improvements"
git push origin personal/docker-mcp-enhanced

Getting Official Updates:

# Fetch and merge official updates

git checkout main
git fetch upstream
git merge upstream/main
git push origin main

# Update your personal branch with latest changes

git checkout personal/docker-mcp-enhanced
git merge main
git push origin personal/docker-mcp-enhanced

Setup New Environment:

# Copy your personal config

cp .env.local .env

# Your system is ready!
