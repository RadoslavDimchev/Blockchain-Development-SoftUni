// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./NFT.sol";

contract NFTMarketplace is NFT {
    struct Sale {
        address seller;
        uint256 price;
    }

    // collection => id => price
    mapping(address => mapping(uint256 => Sale)) public nftsForSale;

    function listNFTForSale(
        address collection,
        uint256 id,
        uint256 price
    ) external {
        require(_msgSender() == ownerOf(id), "Only owner can list NFT");
        require(
            nftsForSale[collection][id].seller == address(0),
            "NFT is already listed"
        );
        require(price != 0, "Price must be greater than 0");

        nftsForSale[collection][id] = Sale(_msgSender(), price);

        transferFrom(_msgSender(), address(this), id);
        approve(address(this), id);
    }
}
