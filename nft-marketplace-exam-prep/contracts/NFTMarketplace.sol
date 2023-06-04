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

    // seller => profit
    mapping(address => uint256) profits;

    function listNFTForSale(
        address collection,
        uint256 id,
        uint256 price
    ) external {
        require(_msgSender() == ownerOf(id), "You are not the owner of NFT");
        require(
            nftsForSale[collection][id].seller == address(0),
            "NFT is already listed"
        );
        require(price != 0, "Price must be greater than 0");

        nftsForSale[collection][id] = Sale(_msgSender(), price);

        transferFrom(_msgSender(), address(this), id);
        approve(address(this), id);
    }

    function unlistNFT(address collection, uint256 id, address to) external {
        Sale memory sale = nftsForSale[collection][id];
        address seller = sale.seller;

        require(seller != address(0), "NFT is not listed");
        require(seller == _msgSender(), "You are not the seller");

        delete nftsForSale[collection][id];

        safeTransferFrom(address(this), to, id);
        approve(to, id);
    }

    function purchaseNFT(
        address collection,
        uint256 id,
        address to
    ) external payable {
        Sale memory sale = nftsForSale[collection][id];
        address seller = sale.seller;

        require(seller != address(0), "NFT is not listed");
        require(seller != _msgSender(), "You cannot buy your own NFT");
        require(sale.price == msg.value, "Invalid price");

        profits[seller] += msg.value;

        delete nftsForSale[collection][id];

        safeTransferFrom(address(this), _msgSender(), id);
        approve(to, id);
    }

    function claimProfit() external {
        uint256 profit = profits[_msgSender()];
        require(profit != 0, "No profit to claim");

        profits[_msgSender()] = 0;

        (bool success, ) = payable(_msgSender()).call{value: profit}("");

        require(success, "Failed to claim profit");
    }
}
