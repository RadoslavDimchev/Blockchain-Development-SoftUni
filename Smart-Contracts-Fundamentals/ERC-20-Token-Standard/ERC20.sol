// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import "./IERC20.sol";

contract ERC20 is IERC20 {
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSuply;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
    }

    function balanceOf(address owner) public view returns (uint256 balance) {
        return _balances[owner];
    }

    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        _transfer(msg.sender, _to, _value);

        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success) {
        require(_allowances[_from][msg.sender] > 0, "Not authorized");

        _transfer(_from, _to, _value);

        _allowances[_from][msg.sender] -= _value;

        return true;
    }

    function approve(address _spender, uint256 _value)
        external
        returns (bool success)
    {
        _allowances[msg.sender][_spender] += _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256 remaining)
    {
        return _allowances[_owner][_spender];
    }

    function _mint(address _to, uint256 _value) internal virtual {
        _balances[_to] += _value;
        totalSuply += _value;

        emit Transfer(address(0), _to, _value);
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _value
    ) internal {
        _balances[_from] -= _value;
        _balances[_to] += _value;

        emit Transfer(_from, _to, _value);
    }
}
