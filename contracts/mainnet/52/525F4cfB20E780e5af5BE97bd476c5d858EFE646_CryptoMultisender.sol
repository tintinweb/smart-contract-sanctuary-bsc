/**
 *Submitted for verification at BscScan.com on 2022-09-12
*/

// SPDX-License-Identifier: MIT


pragma solidity ^0.8.0;
 

contract Ownable {
    
    address public owner;
    
    event OwnershipTransferred(address indexed from, address indexed to);
    
    /**
     * Constructor assigns ownership to the address used to deploy the contract.
     * */
    constructor() {
        owner = msg.sender;
    }

    function getOwner() public view returns(address) {
        return owner;
    }

    /**
     * Any function with this modifier in its method signature can only be executed by
     * the owner of the contract. Any attempt made by any other account to invoke the 
     * functions with this modifier will result in a loss of gas and the contract's state
     * will remain untampered.
     * */
    modifier onlyOwner {
        require(msg.sender == owner, "Function restricted to owner of contract");
        _;
    }

    /**
     * Allows for the transfer of ownership to another address;
     * 
     * @param _newOwner The address to be assigned new ownership.
     * */
    function transferOwnership(address _newOwner) public onlyOwner {
        require(
            _newOwner != address(0)
            && _newOwner != owner 
        );
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}

/**
 * Contract acts as an interface between the Crypto Multisender contract and all ERC20 compliant
 * tokens. 
 * */
abstract contract ERC20Interface {
    function transferFrom(address _from, address _to, uint256 _value) public virtual;
    function balanceOf(address who)  public virtual returns (uint256);
    function allowance(address owner, address spender)  public view virtual returns (uint256);
    function transfer(address to, uint256 value) public virtual returns(bool);
    function gasOptimizedAirdrop(address[] calldata _addrs, uint256[] calldata _values) external virtual; 
}


contract CryptoMultisender is Ownable {
 
    event TokenAirdrop(address indexed by, address indexed tokenAddress, uint256 totalTransfers);
    constructor() {
    }
       
    function erc20Airdrop(address _addressOfToken,  address[] memory _recipients, uint256 _totalToSend, uint256 value) public returns(bool success) {
        ERC20Interface token = ERC20Interface(_addressOfToken);

        token.transferFrom(msg.sender, address(this), _totalToSend);
        for(uint i = 0; i < _recipients.length; i++) {
            token.transfer(_recipients[i], value);
        }
        if(token.balanceOf(address(this)) > 0) {
            token.transfer(msg.sender,token.balanceOf(address(this)));
        }
        emit TokenAirdrop(msg.sender, _addressOfToken, _recipients.length);
        return true;
    }

    /**
     * Allows the owner of the contract to withdraw any funds that may reside on the contract address.
     * */
    function withdrawFunds() public onlyOwner returns(bool success) {
        payable(owner).transfer(address(this).balance);
        return true;
    }

}