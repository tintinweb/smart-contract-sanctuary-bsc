// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract BlindAngelTreasury {
    event Transfer(address indexed createdBy, address indexed dealedBy, address to, uint256 value, bool indexed status);
    event Deposited(address dealer, uint256 amount);
    event Withdraw(address dealer, address to, uint256 amount);

    struct RequestStruct {
        bool isActive;
        bool isClosed;
        bool isSent;
        address createdBy;
        address to;
        uint256 value;
        uint256 created_at;
    }

    RequestStruct public transferRequest;
    
    mapping(address => bool) public owners;

    modifier onlySigners() {
        require(owners[msg.sender]);
        _;
    }
    
    constructor(
        address[] memory _owners
    ) {
        require(_owners.length == 3, "Owners are not 3 addresses" );
        for (uint i = 0; i < _owners.length; i ++) owners[_owners[i]] = true;
    }

    // start transfer part
    function newTransferRequest(address to, uint256 value) public onlySigners {
        transferRequest = RequestStruct({
            to: to,
            value: value,
            isClosed: false,
            isSent: false,
            isActive: true,
            createdBy: msg.sender,
            created_at: block.timestamp
        });
    }
    
    function declineTransferRequest() public onlySigners {
        require(transferRequest.isActive);
        closeTransferRequest(false);
    }

    function approveTransferRequest() public onlySigners {
        require(transferRequest.isActive);
        require(transferRequest.createdBy != msg.sender, "can't approve transaction you created");
        
        payable(transferRequest.to).transfer(transferRequest.value);
        closeTransferRequest(true);
    }
    
    function closeTransferRequest(bool status) private onlySigners {
        transferRequest.isActive = false;
        transferRequest.isClosed = true;
        transferRequest.isSent = status;
        emit Transfer(transferRequest.createdBy, msg.sender, transferRequest.to, transferRequest.value, status);

    }
    // end transfer part
    function deposit(uint256 amount) external payable {
        require(msg.value >= amount);
        emit Deposited(msg.sender, amount);
    }

    function withdraw(address to) external onlySigners {
        emit Withdraw(msg.sender, to, address(this).balance);
        payable(to).transfer(address(this).balance);
    }
}