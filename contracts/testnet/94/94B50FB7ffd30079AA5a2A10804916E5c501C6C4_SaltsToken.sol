/**
 *Submitted for verification at BscScan.com on 2022-11-17
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

// File: openzeppelin-solidity/contracts/ownership/Whitelist.sol

/**
 * @title Whitelist
 * @dev The Whitelist contract has a whitelist of addresses, and provides basic authorization control functions.
 * @dev This simplifies the implementation of "user permissions".
 */




contract SaltsToken is Ownable {

    string public name = "Salts Token";
    string public symbol = "SALTZ";
    uint8 public decimals = 18 ;
    uint256 public totalSupply;
    uint256 public currentSupply_;


    constructor(uint256 _totalSupply) {
        totalSupply = _totalSupply * (10 ** decimals);
        balanceOf[msg.sender] = totalSupply;
        currentSupply_ = totalSupply;
    }

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // address where burned tokens sent to, No one have access to this address
    address private constant burnAccount = 0x000000000000000000000000000000000000dEaD;

    uint256 public totalBurnt;

    uint256 private totalrewards;
    //Array of addresses that can update the total rewards. staking and market address.

     event Transfer(
        address indexed from, 
        address indexed to, 
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    event RewardsUpdated(
        uint256 amount,
        uint256 timestamp
    );

    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        require(balanceOf[msg.sender] >= _value);
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _value
    ) internal {
        require(_to != address(0));

        balanceOf[_from] -= _value;
        balanceOf[_to] +=  _value;

        emit Transfer(_from, _to, _value);
    }

    function approve(address _spender, uint _value) public returns (bool success) {
        _approve(msg.sender, _spender, _value);
        return true;
    }

    function _approve(address account, address spender, uint256 amount) internal {
        require(spender != address(0));
        allowance[account][spender] += amount;
        emit Approval(account, spender, amount);
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(_value <= balanceOf[_from], "insufficient balance");
        require(_value <= allowance[_from][msg.sender], "insufficient allowance");
        allowance[_from][msg.sender] -=  _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function _burn(address account, uint256 amount) internal {
        require(account != burnAccount);
        require(balanceOf[account] >= amount);
        balanceOf[account] -= amount;
        currentSupply_ -= amount;
        totalBurnt += amount;
        emit Transfer(account, burnAccount, amount);
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    function burnFrom(address account, uint256 amount) public {
        require(allowance[account][msg.sender] >= amount, "insufficient allowance");
        _approve(account, msg.sender, allowance[account][msg.sender] - amount);
        _burn(account, amount);
    } 

    mapping(address => bool) public whitelisted;
    
    function addToWhitelist(address _address) public onlyOwner {
        whitelisted[_address] = true;
    }
     
    function updateRewards(uint256 _amount) external {
        require(whitelisted[msg.sender] == true);
        totalrewards += _amount;
        emit RewardsUpdated(_amount, block.timestamp);
    }
    
    //////////////// View Functions /////////////////

    function currentSupply() external view returns(uint256) {
        return currentSupply_;
    }

    function TotalRewards() external view returns(uint256) {
        return totalrewards;
    }

    function BurnedTokens() external  view returns(uint256) {
        return totalBurnt;
    }
}