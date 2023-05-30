// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Counters.sol";

import "./CrowdfundingCampaign.sol";

contract CrowdfundingPlatform {
    using Counters for Counters.Counter;

    Counters.Counter public id;

    struct Campaign {
        uint256 id;
        string symbol;
        string nameOfCampaign;
        string description;
        uint256 fundingGoal;
        uint256 duration;
        address owner;
    }

    mapping(uint256 => address) public campaigns;

    event CampaignCreation(uint256 id);

    function createCampaign(
        string calldata _symbol,
        string calldata _nameOfCampaign,
        string calldata _description,
        uint256 _fundingGoal,
        uint256 _duration
    ) external returns (uint256) {
        id.increment();
        uint256 campaignId = id.current();

        address newCampaign = address(
            new CrowdfundingCampaign(
                campaignId,
                _symbol,
                _nameOfCampaign,
                _description,
                _fundingGoal,
                _duration,
                msg.sender
            )
        );

        campaigns[campaignId] = newCampaign;

        emit CampaignCreation(campaignId);

        return campaignId;
    }
}
