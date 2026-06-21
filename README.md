# Microsoft OneNote Sync and Notebook Repair Toolkit

Created by **Dewald Pretorius**.

`Troubleshooter.ps1` collects notebook sync, cache, conflict, corruption, and missing-note evidence. `Repair.ps1` adds guarded `Diagnose`, `ResetOneNoteCache`, and `FlushDns` actions.

```powershell
.\Repair.ps1 -Action Diagnose
.\Repair.ps1 -Action ResetOneNoteCache -WhatIf
.\Repair.ps1 -Action ResetOneNoteCache -Confirm
```

Confirm notebooks have finished syncing and close OneNote before cache repair. Existing cache data is preserved as a timestamped backup and a clean cache folder is verified after creation. The helper does not delete notebooks or sections. Source-reviewed for Windows PowerShell 5.1; not runtime-tested against every notebook topology or OneNote build.
