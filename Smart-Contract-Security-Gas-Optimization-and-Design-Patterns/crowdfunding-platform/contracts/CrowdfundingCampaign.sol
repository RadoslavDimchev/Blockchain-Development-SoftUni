// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CrowdfundingCampaign is Ownable, ERC20 {
    uint256 id;
    string nameOfCampaign;
    string description;
    uint256 fundingGoal;
    uint256 duration;
    address ownerOfCampaign;

    mapping(address => uint256) contributions;
    mapping(address => bool) claimedRewards;
    uint256 currentBalance;
    uint256 reward;

    error LessContribution();
    error NotReachFundGoal();
    error ReachedFundGoal();

    constructor(
        uint256 _id,
        string memory _symbol,
        string memory _nameOfCampaign,
        string memory _description,
        uint256 _fundingGoal,
        uint256 _duration,
        address _ownerOfCampaign
    ) ERC20(_nameOfCampaign, _symbol) {
        id = _id;
        nameOfCampaign = _nameOfCampaign;
        description = _description;
        fundingGoal = _fundingGoal;
        duration = _duration;
        ownerOfCampaign = _ownerOfCampaign;

        _transferOwnership(ownerOfCampaign);
    }

    function contribute() external payable {
        if (fundingGoal > msg.value) {
            revert LessContribution();
        }

        currentBalance += msg.value;
        contributions[msg.sender] = msg.value;
    }

    function releaseFunds() external onlyOwner {
        if (currentBalance < fundingGoal) {
            revert NotReachFundGoal();
        }

        currentBalance = 0;

        (bool success, ) = ownerOfCampaign.call{value: currentBalance}("");

        require(success, "failed release funds");
    }

    function refund() external {
        if (currentBalance >= fundingGoal) {
            revert ReachedFundGoal();
        }
        require(currentBalance > 0, "not enough campaign balance");

        uint256 valueToRefund = contributions[msg.sender];
        contributions[msg.sender] = 0;
        currentBalance -= valueToRefund;

        (bool success, ) = msg.sender.call{value: valueToRefund}("");

        require(success, "failed refund");
    }

    function distribution() external onlyOwner payable {
        require(reward == 0, "reward has to be distributed");

        reward = msg.value;
    }

    function claimReward() external {
        uint256 contibution = contributions[msg.sender];

        require(contibution > 0, "not enough contributon");
        require(claimedRewards[msg.sender] == false, "claimed reward");

        uint256 rewardToGet = (contibution / currentBalance) * 100;
        reward -= rewardToGet;
        claimedRewards[msg.sender] = true;

        (bool success, ) = msg.sender.call{value: rewardToGet}("");

        require(success, "failed claim reward");
    }
}
