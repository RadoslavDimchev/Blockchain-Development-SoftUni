// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

contract AuctionPlatform {
    struct Auction {
        address creator;
        uint256 start;
        uint256 end;
        string name;
        string description;
        uint256 startingPrice;
        uint256 highestBid;
        bool isFinalized;
        address highestBidder;
    }

    uint256 auctionId;
    mapping(uint256 => Auction) auctions;
    mapping(uint256 => mapping(address => uint256)) availableToWithdrawal;

    event NewAuction(uint256 indexed auctionId);
    event NewHighestBid(uint256 id, uint256 bid, address bidder);

    modifier onlyActiveAuction(uint256 id) {
        require(
            auctions[id].start < block.timestamp &&
                auctions[id].end > block.timestamp,
            "Not active auction"
        );
        require(auctions[id].isFinalized == false, "Auction is finalized");
        _;
    }

    function createAuction(
        uint256 start,
        uint256 end,
        string memory name,
        string memory decription,
        uint256 startingPrice
    ) public {
        require(start > block.timestamp, "Auction has to start in the future");
        require(end > start, "Not valid auction duration");

        auctionId++;

        auctions[auctionId] = Auction({
            creator: msg.sender,
            start: start,
            end: end,
            name: name,
            description: decription,
            startingPrice: startingPrice,
            highestBid: 0,
            isFinalized: false,
            highestBidder: address(0)
        });

        emit NewAuction(auctionId);
    }

    function placeBid(uint256 id) public payable onlyActiveAuction(id) {
        require(auctions[id].startingPrice < msg.value, "Bid must be bigger than the starting price");
        require(auctions[id].highestBid < msg.value, "Not valid bid");

        if (auctions[id].highestBidder != address(0)) {
            availableToWithdrawal[id][auctions[id].highestBidder] += auctions[
                id
            ].highestBid;
        }

        auctions[id].highestBid = msg.value;
        auctions[id].highestBidder = msg.sender;

        emit NewHighestBid(id, msg.value, msg.sender);
    }

    function finalizeBid(uint256 id) public payable {
        require(auctions[id].end < block.timestamp, "Auction is not ended");
        
        if (auctions[id].highestBid > 0) {
            payable(auctions[id].creator).transfer(auctions[id].highestBid);
        }
        auctions[id].isFinalized = true;
    }

    function withdraw(uint256 id) public {
        require(
            availableToWithdrawal[id][msg.sender] > 0,
            "User has nothing to withdraw"
        );

        payable(msg.sender).transfer(availableToWithdrawal[id][msg.sender]);
        
        availableToWithdrawal[id][msg.sender] = 0;
    }
}
