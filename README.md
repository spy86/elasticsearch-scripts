# README #

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Few scripts to Elasticsearch Index Management

- [ ] ***elasticsearch-remove-old-indices.sh*** - This script generically walks through the indices, sorts them lexicographically, and deletes anything older than the configured number of indices.
- [ ] ***elasticsearch-remove-expired-indices.sh*** - This script generically walks through the indices, and deletes anything older than the configured expiration date.
- [ ] ***elasticsearch-close-old-indices.sh*** - This script generically walks through the indices, sorts them lexicographically, and closes indices older than the configured number of indices.
- [ ] ***elasticsearch-backup-index.sh*** - Backup handles making a backup and a restore script for a given index. The default is yesterday's index, or you can pass a specific date for backup. You can optionally keep the backup locally, and/or push it to s3. If you want to get tricky, you can override the s3cmd command, and you could have this script push the backups to a storage server on your network (or whatever you want, really).
- [ ] ***elasticsearch-restore-index.sh*** - Restore handles retrieving a backup file and restore script (from S3), and then executing the restore script locally after download.
