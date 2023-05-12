// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import "./IERC721.sol";

contract ERC721 is IERC721 {
    string public name;
    string public symbol;

    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokens;
    mapping(uint256 => address) private _approvals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    modifier onlyValidToken(uint256 _tokenId) {
        require(_tokens[_tokenId] != address(0), "not a valid token");
        _;
    }

    function balanceOf(address _owner) external view returns (uint256) {
        require(_owner != address(0), "zero address are considered invalid");

        return _balances[_owner];
    }

    function ownerOf(uint256 _tokenId) external view onlyValidToken(_tokenId) returns (address) {
        return _tokens[_tokenId];
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory data
    ) public payable onlyValidToken(_tokenId) {
        require(_approvals[_tokenId] == msg.sender, "not approved");
        require(_operatorApprovals[_from][msg.sender], "not operator approved");
        require(_tokens[_tokenId] == _from, "token must be owned by _from");
        require(_to != address(0), "_to cannot be the zero address");

        _transfer(_from, _to, _tokenId);

        //  checks if `_to` is a smart contract (code size > 0). If so, it calls
        //  `onERC721Received` on `_to`
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable {
        safeTransferFrom(_from, _to, _tokenId, "");
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable onlyValidToken(_tokenId) {
        require(_from == msg.sender, "not owner");
        require(_to != address(0), "_to is zero address");

        _transfer(_from, _to, _tokenId);
    }

    function approve(address _approved, uint256 _tokenId) external payable {
        require(_approved != address(0), "zero approved address");
        require(_tokens[_tokenId] == msg.sender, "not owner of token");

        _approvals[_tokenId] = _approved;

        emit Approval(msg.sender, _approved, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved) external {
        _operatorApprovals[msg.sender][_operator] = _approved;

        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function getApproved(uint256 _tokenId) external view onlyValidToken(_tokenId) returns (address) {
        return _approvals[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
        return _operatorApprovals[_owner][_operator];
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal virtual {
        _tokens[_tokenId] = _to;

        delete _approvals[_tokenId];

        _balances[_from] -= 1;
        _balances[_to] += 1;

        emit Transfer(_from, _to, _tokenId);
    }
}
