pragma solidity 0.5.12;

import "./ds-math.sol";

contract MCHLike{
    function getLeasee(uint point_) external view returns(address);
}

contract NFTLike{
    function ownerOf(uint256 _tokenId) external view returns (address);
}

contract MCH is DSMath {

    address public manager;

    uint MCH_FEE = 1050000000000000000; // wad // 5% MCH fee on settled leases
    uint MAX_MCH_DURATION = 180 days;
    mapping (address => bool) approvedOwners; // allow protection to leased points

    mapping (address => address) delegate; // parcel owner delegate

    struct Point {  
        address metaverse; // metaverse nft contract address
        uint parcel; // parcel nft id

        int[3] coordinates; // x y z starting point
        uint[3] dimensions; // dimensions of cube allocated to point

        address owner; // point owner
    }

    struct Offer {
        uint price; // price per second in wei
        uint min_duration; // seconds
        uint max_duration; // seconds
    }

    struct Lease {
        uint expiry; // lease expiry timestamp
        address leasee; // leasee address
        uint amount; // amount locked to pay point owner after lease
    }

    mapping (uint => Point) points; // created points
    mapping (uint => Offer) offers; // point owners accepting offers
    mapping (uint => Lease) leases; // current leases
    mapping (uint => bytes) ipfsHash; // point initialization info stored in an ipfs doc
    uint lastid;

    constructor() public {
        manager = msg.sender;
    }

    event NewManager(address manager);
    event ApprovedOwner(address indexed owner, bool status);
    event DelegateChange(address indexed owner, address indexed delegate);

    modifier auth {
        require(manager == msg.sender, "not-authorized");
        _;
    }

    modifier onlyPointOwner(uint point_) {
        address pointOwner = points[point_].owner;
        require(pointOwner == msg.sender || delegate[pointOwner] == msg.sender);
        _;
    }

    modifier onlyLeasee(uint point_) {
        require(leases[point_].leasee == msg.sender);
        _;
    }

    modifier isActiveLease(uint point_) {
        require(leases[point_].leasee != address(0));
        _;
    }

    modifier isInActiveLease(uint point_) {
        require(leases[point_].leasee == address(0));
        _;
    }

    // --- Auth ---
    function setManager(address manager_) public auth {
        manager = manager_;
        emit NewManager(manager_);
    }

    // --- MCH Management ---
    // Internal function to unlock funds and transfer them to recipient(leasee or owner)
    function unlockFunds(uint point_, address recipient) internal {
        uint funds = leases[point_].amount;

        // TODO: send funds to recipient, send fee to mch
    } 

    // leasees can expect to be protected by MCH when they deal with approved owners
    function updateApproved(address owner_, bool status) public auth {
        approvedOwners[owner_] = status;
        emit ApprovedOwner(owner_, status);
    }

    // MCH can invalidate an active lease and give funds back to leasee
    function invalidateLease(uint point_) public auth {
        unlockFunds(point_, leases[point_].leasee); // send funds back to leasee
        delete leases[point_]; // delete existing lease details
    }

    // --- Point Management ---
    function updateDelegate(address delegate_) public {
        delegate[msg.sender] = delegate_;
        emit DelegateChange(msg.sender, delegate_);
    }

    function createPoint(address metaverse_, uint parcel_, int[3] memory coordinates_, uint[3] memory dimensions_) public {
        uint id = lastid;

        address parcelOwner = NFTLike(metaverse_).ownerOf(parcel_);
        require(parcelOwner == msg.sender || delegate[parcelOwner] == msg.sender);

        points[id].metaverse = metaverse_;
        points[id].parcel = parcel_;
        points[id].owner = parcelOwner;

        points[id].coordinates = coordinates_;
        points[id]. dimensions = dimensions_;

        lastid++;
    }

    function removePoint(uint point_) public onlyPointOwner(point_) isInActiveLease(point_) {
        delete offers[point_]; // delete current offer set for point
        delete points[point_]; // delete point
    }

    // -- Offers Management ---
    function updateOffer(uint point_, uint price_, uint min_duration_, uint max_duration_) public onlyPointOwner(point_) {
        require((min_duration_ <= max_duration_) && (max_duration_ <= MAX_MCH_DURATION));

        offers[point_].price = price_;
        offers[point_].min_duration = min_duration_;
        offers[point_].max_duration = max_duration_;
    }

    // --- Lease Management ---
    function getLeasee(uint point_) public returns(address leasee_) {
        leasee_ = leases[point_].leasee;
    }

    function startLease(uint point_, uint duration) public isInActiveLease(point_) {
        require((offers[point_].min_duration <= duration) && (duration <= offers[point_].max_duration));
        require(duration <= MAX_MCH_DURATION);

        uint totalAmount = mul(offers[point_].price, duration);
        // TODO: total amount transferred to MCH

        leases[point_].leasee = msg.sender;
        leases[point_].expiry = add(now, duration);
        leases[point_].amount = totalAmount;

    }

    function cancelLease(uint point_) public onlyLeasee(point_) {
        // validate if point owner is different from parcel owner to cancel and refund leasee
        require(points[point_].owner != NFTLike(points[point_].metaverse).ownerOf(points[point_].parcel));

        unlockFunds(point_, leases[point_].leasee);

        delete leases[point_]; // delete existing lease details
        delete offers[point_]; // delete current offer set for point
        delete points[point_]; // delete point
    }

    function settleLease(uint point_) public isActiveLease(point_){
        require(leases[point_].expiry <= now);

        unlockFunds(point_, points[point_].owner);
        delete leases[point_]; // delete expired lease
    }

    // --- Point Info management ---
    function setIpfsHash(uint point_, bytes memory ipfsHash_) public onlyLeasee(point_) {
        ipfsHash[point_] = ipfsHash_;
    }
}