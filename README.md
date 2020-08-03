# Metaverse Clearing House

Metaverse users want to serendipitiously encounter relevant media and participate in activities along with other users. Parcel builders would like to serve this audience by creating experiences around curated media on parcels.

Point is a basic unit which can help create efficient markets in the Metaverse around this building activity and media display and cater to participants of all sizes. A point contains enough space to display one media item, and volume to allow multiple users to gather and experience it together. Multiple adjacent points can also be used together to create a more engaging experience for users.

Parcel developers reserve space for points on their parcels to create the supply, and users can then lease one or more points to gain the right to display media at the point for a certain duration, and allow them to be showcased to users. Points can be used to place an advertisement within a gallery, or to rent slots in a gallery to display relevant artwork

## Contract Interface

Users can interact with MCH in the following ways,

* Parcel owner creates point using `createPoint()` with the following details: Metaverse NFT Address, Parcel NFT ID, Reserved volume on parcel with starting co-ordinates and size.
* Parcel owner sets an offer for an existing point using `updateOffer()` with price per second in wei and minimum and maximum duration. MCH imposes a max lease duration of 180 days.
* Leasee accepts offer using `startLease()` and locks funds in MCH which will be paid out to the parcel owner at lease expiry.
* Leasee can set their Info contract of choice using `setInfoAddr()`, within the info contract set the details that the point owner uses to initialize the requested feature like an NFT image.
* If ownership of parcel changes, Leasee can cancel lease to get the funds locked refunded if the new owner does not respect their lease on the point.
* Owner can claim funds locked after end of lease term with `settleLease()`. MCH collects a fee from the transaction.
* MCH can set approved owners to give additional protection from its funds to leasees of their points.
