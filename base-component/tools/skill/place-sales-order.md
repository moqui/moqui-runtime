---
name: place-sales-order
title: Place a sales order
description: Create a sales order, add product items, and Place on FindOrder / OrderDetail
risk: confirm
screens: [/apps/marble/Order/FindOrder, /apps/marble/Order/OrderDetail]
---
# Create sales order

Never `/rest` or `/popc`. Use screen transitions (JSON under `/apps`).

Dashboard Sales Orders → `/apps/marble/Order/FindOrder` `orderType=Sales`.

**Create Sales Order** POST `/apps/marble/Order/FindOrder/createOrder`
fields: `productStoreId`, `vendorPartyId` (from store), `facilityId`, `customerPartyId`.
Starts `OrderOpen`. Returns `orderId`.

OrderDetail `/apps/marble/Order/OrderDetail?orderId=` **Add Product Item** POST `addProductItem`
(`productId`, `quantity`; leave `unitAmount` empty for Calc Price).

Stop after create and line items. **Place** (`placeOrder`) and **Approve** (`approveOrder`) are separate confirmed steps. Do not Place on the create submit.

Link `/qapps/marble/Order/OrderDetail?orderId=`.

Script mode: the Mutation runs on click. Do not also `request` that same POST.
Agent mode: after `submitted:true`, `request` the create, then items. Do not `placeOrder` in that same turn.
