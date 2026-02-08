# Microblog Entry Template

## Date: 2026-02-08
## Title: Cleaning up macOS disk space

Sharing a code snippet I found it reddit -- quite useful for cleaning up macOS disk space.
Source: [u/MoreCowbellMofo @ r/mac](https://www.reddit.com/r/mac/comments/ynv4d0/comment/ivc0dm4/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button)

### Code blocks
```bash
df -h | grep Gi # find which dirs are consuming large parts of disk space

du -h /System/Volumes/Data | grep "G\t" | sort # Investigate specific directory
```
