// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "./Event.sol";

contract Marketplace {
    address[] public events;

    event EventCreation(address creator, uint256 ticketsPrice, address eventAddress);

    function createEvent(
        uint256 _ticketsSaleStart,
        uint256 _ticketsSaleEnd,
        uint256 _ticketsPrice,
        string memory _metadata,
        uint256 _maxTickets
    ) external {
        address newEvent = address(
            new Event(_ticketsSaleStart, _ticketsSaleEnd, _ticketsPrice, _metadata, _maxTickets, msg.sender)
        );
        events.push(newEvent);

        emit EventCreation(msg.sender, _ticketsPrice, newEvent);
    }
}
