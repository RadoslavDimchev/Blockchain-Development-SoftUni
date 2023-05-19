// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Event is ERC721, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    string constant _METADATA = "https://api.jsonbin.io/v3/b/6464ee1d9d312622a360108d?meta=false";

    uint256 public ticketsSaleStart;
    uint256 public ticketsSaleEnd;
    uint256 public ticketsPrice;
    string public metadata;
    uint256 public maxTickets;
    address public randomWinner;

    constructor(
        uint256 _ticketsSaleStart,
        uint256 _ticketsSaleEnd,
        uint256 _ticketsPrice,
        string memory _metadata,
        uint256 _maxTickets,
        address owner
    ) ERC721("MyToken", "MTK") {
        require(_ticketsPrice > 0, "Invalid price");
        require(_ticketsSaleStart < _ticketsSaleEnd, "Invalid dates");

        ticketsSaleStart = _ticketsSaleStart;
        ticketsSaleEnd = _ticketsSaleEnd;
        ticketsPrice = _ticketsPrice;
        metadata = _metadata;
        maxTickets = _maxTickets;

        _transferOwnership(owner);
    }

    /**
    * Min new NFTs
    * @param amount How many NTFs to mint
    */
    function buyTicket(uint256 amount) external payable {
        require(amount < 50, "Too big amount");
        require(amount * ticketsPrice == msg.value, "Invalid value");
        require(amount + _tokenIdCounter.current() <= maxTickets, "Too many NFTs");

        for (uint256 i = 0; i < amount; i++) {
            _safeMint(msg.sender, _METADATA);
        }
    }

    function withdraw() external onlyOwner {
        require(block.timestamp > ticketsSaleEnd, "Too early");

        _chooseRandomWinner();

        payable(owner()).transfer(address(this).balance);
    }

    function _chooseRandomWinner() internal {
        require(randomWinner == address(0), "Already chosen");
        randomWinner = ownerOf((block.prevrandao % _tokenIdCounter.current()) - 1);
        _safeMint(randomWinner, _METADATA);
    }

    function _safeMint(address to, string memory uri) private {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }
}
