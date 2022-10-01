// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./escrow.sol";
contract EscrowFactory {
    address payable public owner;
    mapping(string => address) private dealIdToContractAddress;

    event NewDeal(address _newContractAddress);

    constructor(){
        owner = payable(msg.sender);
    }

    modifier isDealIdValid(string memory _dealId){
        require(bytes(_dealId).length > 0, "Invalid DealId!");
        _;
    }

    modifier ownerOnly(){
        require(msg.sender == owner, "Function only accessible by owner!");
        _;
    }

    modifier isAddressValid(address payable _addr) {
        require(_addr.code.length == 0 && _addr != address(0) , "Not a valid address!");
        _;
    } 

    function createEscrow(
        string memory dealId,
        address payable _commissionWallet,
        uint256 _minimumEscrowAmount,
        uint256 _commissionRate,
        address payable seller
    ) 
        payable
        public 
        ownerOnly
        isDealIdValid(dealId) 
    {
        Escrow escrow = new Escrow();
        setdealId(dealId, address(escrow));
        emit NewDeal(address(escrow));
        escrow.initializeDeal(_commissionWallet, _minimumEscrowAmount, _commissionRate, owner);  
        escrow.escrowParties(/* payable(msg.sender), */ seller);
        escrow.deposit{value: msg.value}();
    }

    function setdealId(
        string memory _dealId, 
        address _escrowAddress
    ) 
        private
    {
        dealIdToContractAddress[_dealId] = _escrowAddress;
    }

    function getContractAddress(
        string memory _dealId
    ) 
        public 
        view 
        returns (address) 
    {
        return dealIdToContractAddress[_dealId];
    }

    function transferOwnership(
        address payable newOwner
    ) 
        public
        ownerOnly
        isAddressValid(newOwner)
    {
        owner = newOwner;
    }
}