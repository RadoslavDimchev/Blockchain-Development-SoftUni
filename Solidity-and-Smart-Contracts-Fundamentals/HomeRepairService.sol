// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

contract HomeRepairService {
    struct Request {
        address payable user;
        string description;
        uint256 tax;
        uint256 auditsCount;
    }

    address constant admin = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

    mapping(uint256 => Request) public requests;
    mapping(uint256 => uint256) private _payments;
    mapping(uint256 => uint256) private _confirmations;
    mapping(address => bool) private _auditors;
    mapping(uint256 => mapping(address => bool)) private _auditedRequestsBy;

    error NotEnoughETH();
    error NotAuditedEnough();
    error MoreTimeToVerify();

    function addRepairRequest(string calldata description, uint256 requestId)
        public
    {
        require(
            requests[requestId].user == address(0),
            "Already has a request with this requestId"
        );

        requests[requestId].user = payable(msg.sender);
        requests[requestId].description = description;
    }

    function acceptRepairRequest(uint256 requestId, uint256 tax) public {
        require(admin == msg.sender, "Not administrator");

        requests[requestId].tax = tax;
    }

    function addPayment(uint256 requestId) public payable {
        require(requests[requestId].tax > 0, "Request not accepted");
        require(_payments[requestId] == 0, "The request has already been paid");

        _payments[requestId] = msg.value;

        if (msg.value < requests[requestId].tax) {
            revert NotEnoughETH();
        }
    }

    function confirmRepairRequest(uint256 requestId) public {
        require(admin == msg.sender, "Not administrator");

        _confirmations[requestId] = block.timestamp;
    }

    function verifyDoneJob(uint256 requestId) public {
        require(_auditors[msg.sender], "Not auditor");
        require(
            _auditedRequestsBy[requestId][msg.sender] == false,
            "This auditor has already verify the request"
        );

        _auditedRequestsBy[requestId][msg.sender] = true;
        requests[requestId].auditsCount++;
    }

    function executeRepairRequest(uint256 requestId, address payable repairer)
        public
    {
        require(_auditors[msg.sender], "Not auditor");
        require(_payments[requestId] > 0, "Not paid");

        if (requests[requestId].auditsCount < 2) {
            revert NotAuditedEnough();
        }

        repairer.transfer(_payments[requestId]);
    }

    function getMoneyBack(uint256 requestId) public {
        require(
            requests[requestId].user == msg.sender,
            "Not user who created request"
        );
        require(
            address(this).balance > 0,
            "Not enough balance to return money"
        );

        if (_confirmations[requestId] + 30 days < block.timestamp) {
            revert MoreTimeToVerify();
        }

        requests[requestId].user.transfer(_payments[requestId]);

        _payments[requestId] = 0;
        delete requests[requestId];
        delete _confirmations[requestId];
    }

    function addAuditor(address auditor) public {
        require(admin == msg.sender, "Not administrator");

        _auditors[auditor] = true;
    }

    function removeAuditor(address auditor) public {
        require(admin == msg.sender, "Not administrator");

        _auditors[auditor] = false;
    }
}
