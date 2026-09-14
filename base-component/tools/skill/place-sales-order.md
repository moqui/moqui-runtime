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

**Place** / **Place Warnings** POST `placeOrder` → `OrderPlaced`.
**Approve** / **Approve Warnings** POST `approveOrder` → `OrderApproved` (needs ORDER_APPROVE).

Link `/qapps/marble/Order/OrderDetail?orderId=`.

Canvas: Form + Mutation POST `createOrder`. After `submitted:true`: `request` that POST, then `writeThrough` item fields and POST `addProductItem`, then POST `placeOrder`. Confirm with `orderId`.
