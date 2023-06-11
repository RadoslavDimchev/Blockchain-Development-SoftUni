// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "@openzeppelin/contracts/utils/Counters.sol";

import "./ERC20Treasury.sol";

/**
 * @title Treasury
 * @dev This contract is designed to manage funds in a treasury.
 * Each withdrawal proposal can be voted on by users.
 * Proposal for withdrawals are initiated by the contract owner.
 */
contract Treasury is ERC20Treasury {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    /**
     * @dev A struct to hold the withdrawal data.
     */
    struct Withdrawal {
        uint256 amount;
        string description;
        uint256 duration;
        uint256 votesYes;
        uint256 votesNo;
        uint256 startTime;
    }

    // id => Withdrawal
    mapping(uint256 => Withdrawal) public withdrawals;

    // withdrawalId => user address => amount votes
    mapping(uint256 => mapping(address => uint)) public votes;

    error InvalidVoteOption();
    error InvalidAmount();

    event StoredFunds(address account, uint256 amount);
    event WithdrawalInitiated(
        uint256 withdrawalId,
        uint256 amount,
        string description,
        uint256 duration
    );
    event Voted(uint256 withdrawalId, string voteOfPerson, uint256 amount);
    event WithdrawalExecuted(
        uint256 withdrawalId,
        address account,
        uint256 withdrawAmount
    );
    event TokensUnlocked(uint256 withdrawalId, address account, uint256 amount);

    /**
     * @dev Store funds in the contract and mint tokens for the sender.
     */
    function storeFunds() external payable {
        _mint(msg.sender, msg.value);
        emit StoredFunds(msg.sender, msg.value);
    }

    /**
     * @dev Initiates a withdrawal proposal which can be voted on.
     * Can only be called by the contract owner.
     * @param amount Amount to be withdrawn
     * @param description Description of the withdrawal
     * @param duration Duration of the voting period
     */
    function initiateWithdrawal(
        uint256 amount,
        string memory description,
        uint256 duration
    ) external onlyOwner {
        if (amount == 0) {
            revert InvalidAmount();
        }
        require(duration > 0, "Duration must be greater than 0");

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();

        withdrawals[tokenId] = Withdrawal({
            amount: amount,
            description: description,
            duration: duration,
            votesYes: 0,
            votesNo: 0,
            startTime: block.timestamp
        });

        emit WithdrawalInitiated(tokenId, amount, description, duration);
    }

    /**
     * @dev Allows users to vote on a withdrawal proposal.
     * @param withdrawalId ID of the withdrawal to vote on
     * @param voteOfPerson Vote of the person ('Yes' or 'No')
     * @param amount Amount of tokens to vote with
     */
    function vote(
        uint256 withdrawalId,
        string memory voteOfPerson,
        uint256 amount
    ) external {
        Withdrawal memory withdrawal = withdrawals[withdrawalId];

        require(withdrawal.amount > 0, "Withdrawal not found");
        if (amount == 0) {
            revert InvalidAmount();
        }
        require(
            withdrawal.startTime + withdrawal.duration >= block.timestamp,
            "Voting period is ended"
        );

        if (
            keccak256(abi.encodePacked(voteOfPerson)) ==
            keccak256(abi.encodePacked("Yes"))
        ) {
            withdrawals[withdrawalId].votesYes += amount;
        } else if (
            keccak256(abi.encodePacked(voteOfPerson)) ==
            keccak256(abi.encodePacked("No"))
        ) {
            withdrawals[withdrawalId].votesNo += amount;
        } else {
            revert InvalidVoteOption();
        }

        _transfer(msg.sender, address(this), amount);
        emit Voted(withdrawalId, voteOfPerson, amount);
    }

    /**
     * @dev Executes a withdrawal if the voting period is ended.
     * Can only be called by the contract owner.
     * @param withdrawalId ID of the withdrawal to execute
     * @param accountToWithdraw Account to which the funds are transferred
     */
    function executeWithdrawal(
        uint256 withdrawalId,
        address accountToWithdraw
    ) external onlyOwner {
        Withdrawal memory withdrawal = withdrawals[withdrawalId];

        require(
            block.timestamp > withdrawal.startTime + withdrawal.duration,
            "Voting period is not ended"
        );

        require(
            withdrawal.votesYes > withdrawal.votesNo ||
                (withdrawal.votesYes == 0 && withdrawal.votesNo == 0),
            "Not enough yes votes"
        );

        _burn(address(this), withdrawal.amount);

        emit WithdrawalExecuted(
            withdrawalId,
            accountToWithdraw,
            withdrawal.amount
        );

        (bool success, ) = accountToWithdraw.call{value: withdrawal.amount}("");
        require(success, "Transfer failed.");
    }

    /**
     * @dev Allows users to unlock tokens for votes after the voting period is ended.
     * @param withdrawalId ID of the withdrawal from which to unlock tokens
     * @param addressToTransfer Account to which the tokens are transferred
     */
    function unlockTokens(
        uint256 withdrawalId,
        address addressToTransfer
    ) external {
        require(
            block.timestamp >=
                withdrawals[withdrawalId].startTime +
                    withdrawals[withdrawalId].duration,
            "Voting period is not ended"
        );
        uint256 votesAmount = votes[withdrawalId][msg.sender];
        require(votesAmount > 0, "No voted");

        votes[withdrawalId][msg.sender] = 0;

        emit TokensUnlocked(withdrawalId, addressToTransfer, votesAmount);

        _transfer(address(this), addressToTransfer, votesAmount);
    }
}
