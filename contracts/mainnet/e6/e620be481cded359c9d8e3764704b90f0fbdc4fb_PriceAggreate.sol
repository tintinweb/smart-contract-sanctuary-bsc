/**
 *Submitted for verification at BscScan.com on 2022-10-19
*/

pragma solidity ^0.8.0;

// SPDX-License-Identifier: UNLICENSED

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address previousOwner, address newOwner);


    function owner() external view returns (address) {
    return _owner;
    }

    function setOwner(address newOwner) internal {
        _owner = newOwner;
    }

    modifier onlyOwner() {
        require(_msgSender() == _owner, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0),"Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        setOwner(newOwner);
    }
}

contract PriceAggreate is Ownable {

    string constant public  pair = "USD/INR";
    uint256 public price;
    uint256 public lastupdatetime;

    mapping(address => bool) internal _trustedprovider;
    
    constructor (address _owner){
       setOwner(_owner);
       _trustedprovider[_owner] = true;
    }

    function configureTrustedProvider(address _provider) external  onlyOwner returns (bool) {
        require(!_trustedprovider[_provider],"should not be a provider before");
        _trustedprovider[_provider] = true;
        return true;
    }

    function removeProvider(address provider) external onlyOwner returns (bool) {
        _trustedprovider[provider] = false;
        return true;
    }

    function fullfillPrice(uint256 _price) external returns (bool) {
       require(_trustedprovider[msg.sender],"price can't update beacuase you are not provider !");
       price = _price; 
       lastupdatetime = block.timestamp;
       return true;
    }

}