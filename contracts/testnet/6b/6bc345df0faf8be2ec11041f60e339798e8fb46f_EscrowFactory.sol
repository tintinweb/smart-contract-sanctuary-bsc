// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./escrow.sol";
import "./clones.sol";

contract EscrowFactory {
    address payable public factoryOwner;
    address public libraryAddress;
    mapping(string => mapping(string => address)) public user;

    event ProxyAddress(address _ProxyAddress);

    modifier initCheck() {
        require(factoryOwner == address(0x0), "Can't initialize more than once!");
        _;
    }

    modifier ownerOnly(){
        require(msg.sender == factoryOwner, "Function only accessible by owner!");
        _;
    }

    modifier isAddressValid(address payable _addr) {
        require(_addr.code.length == 0 && _addr != address(0) , "Not a valid address!");
        _;
    } 
    
    modifier isLibraryAddressValid(address _libraryAddress) {
        require(_libraryAddress.code.length != 0 && _libraryAddress != address(0) , "Not a valid address!");
        _;
    } 

    function initialize(address _libraryAddress) 
        public 
        initCheck
    {
        factoryOwner = payable(msg.sender);
        libraryAddress = _libraryAddress;
    }

    function createEscrow(
        string memory userId,
        string memory dealId,
        address payable _commissionWallet,
        uint256 _minimumEscrowAmount,
        uint256 _commissionRate,
        address payable seller
    ) 
        payable
        public 
    {
        address proxyAddress = Clones.clone(libraryAddress);
        emit ProxyAddress(proxyAddress);
        setDealDetails(userId, dealId, proxyAddress);
        Escrow(proxyAddress).initializeDeal(_commissionWallet, _minimumEscrowAmount, _commissionRate, factoryOwner);  
        Escrow(proxyAddress).escrowParties(seller);
        Escrow(proxyAddress).deposit{value: msg.value}();
    }

    function setDealDetails(
        string memory _userId,
        string memory _dealId, 
        address _escrowAddress
    ) 
        private
    {
        user[_userId][_dealId] = _escrowAddress;
    }

    function getContractAddress(
        string memory _userId,
        string memory _dealId
    ) 
        public 
        view 
        returns (address) 
    {
        return user[_userId][_dealId];
    }

    function changeLibraryAddress(address newLibraryAddress)
        public 
        ownerOnly
        isLibraryAddressValid(newLibraryAddress)
    {
        libraryAddress = newLibraryAddress;
    }

    function transferOwnership(
        address payable newFactoryOwner
    ) 
        public
        ownerOnly
        isAddressValid(newFactoryOwner)
    {
        factoryOwner = newFactoryOwner;
    }
}