// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

interface IERC20 {
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSuply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256 balance);

    function transfer(address _to, uint256 value)
        external
        returns (bool success);

    function transferFrom(
        address _from,
        address _to,
        uint256 value
    ) external returns (bool success);

    function approve(address _spender, uint256 value)
        external
        returns (bool success);

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256 remaining);
}
