---
name: create-user-account
title: Create user account
description: Create a UserAccount. Group membership is a separate step and is not ADMIN unless the user named that group.
risk: confirm
services: [org.moqui.impl.UserServices.create#UserAccount]
---
# Create user account

`create#UserAccount` is `allow-remote=false`. Call it once with **`run_service`**. Do not also POST the screen for the same create.

- Service: `org.moqui.impl.UserServices.create#UserAccount`
- Parameters: `username`, `emailAddress`, `newPassword`, `newPasswordVerify` (must match). This service does not take first or last name.
- Returns: `userId`
- Do not add a user group unless the user named one. Never default the group to ADMIN.

Script mode: the Mutation runs on click. Do not `run_service` the same create after submit.
Agent mode: after `submitted:true`, `run_service` the create once.

Canvas fields: `username`, `emailAddress`, `newPassword`, `newPasswordVerify`.
