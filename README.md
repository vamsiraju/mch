# Metaverse Clearing House

Metaverse users want to serendipitiously encounter relevant media and participate in activities along with other users. Parcel builders would like to serve this audience by creating experiences around curated media on parcels.

Point is a basic unit which can help create efficient markets in the Metaverse around this building activity and media display and cater to participants of all sizes. A point contains enough space to display one media item, and volume to allow multiple users to gather and experience it together. Multiple adjacent points can also be used together to create a more engaging experience for users.

Parcel developers reserve space for points on their parcels to create the supply, and users can then lease one or more points to gain the right to display media at the point for a certain duration, and allow them to be showcased to users. Points can be used to place an advertisement within a gallery, or to rent slots in a gallery to display relevant artwork.

A clearing house contract supports the market for leasing points, arbitrates in disputes between owners and leasees, steps in with insurance protection for leases of points created by approved owners, and charges a fee to provide this service. MCH itself can be owned by a single address, multi-sig, or even a DAO through token voting.

## Contract Interface

Users can interact with MCH in the following ways,

* Parcel owner creates point using `createPoint()` with the following details: Metaverse NFT Address, Parcel NFT ID, Reserved volume on parcel with starting co-ordinates and size.
* Parcel owner sets an offer for an existing point using `updateOffer()` with price per second in wei and minimum and maximum duration. MCH imposes a max lease duration of 180 days.
* Leasee accepts offer using `startLease()` and locks funds in MCH which will be paid out to the parcel owner at lease expiry.
* Leasee can capture what media they'd like to display in a script(or in plain text understandable by the owner), and upload it to an IPFS document. They can then set the ipfs hash using `setIpfsHash()`, which the point owner(address controlling the parcel) uses to initialize the point as requested by leasee.
* If owner does not respect the leasee, MCH can cancel and refund leasee their locked funds.
* If ownership of parcel changes, and new owner does not respect the lease, Leasee can cancel lease themselves to get the funds locked refunded.
* Owner can claim funds locked after end of lease term with `settleLease()`. MCH collects a fee from the transaction.
* MCH can set approved owners to give additional protection from its funds to leasees of their points.
