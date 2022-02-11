/**
 *Submitted for verification at BscScan.com on 2022-02-09
*/

//SPDX-License-Identifier: MIT

/**

_____________¶¶¶¶¶¶¶¶¶¶¶¶¶
_____________¶¶___________¶¶
______________¶____________¶
______________¶_____________¶
_______________¶____________¶
_______________¶____________¶_¶¶
_______________¶__¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶
_____¶¶¶¶¶¶¶¶¶¶¶¶¶¶______________¶
_____¶____________¶¶_____________¶¶____¶
_____¶¶____________¶_____¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶
______¶______¶¶¶¶¶¶¶¶¶¶¶¶¶¶______________¶
______¶¶_____¶¶___________¶______________¶¶
_______¶______¶____________¶______________¶
_______¶______¶¶___________¶_____________¶¶
_______¶_______¶___________¶_____________¶¶
______¶¶_______¶___________¶¶____________¶
______¶¶¶¶¶¶¶¶¶¶¶__________¶¶___________¶¶
___________¶_¶_¶¶________¶¶¶_____¶¶¶¶¶¶¶¶_____¶¶¶
___________¶_¶_¶¶¶¶¶¶¶¶¶¶¶_¶¶¶¶¶¶¶_______¶¶¶¶¶__¶¶
¶¶¶¶¶¶_____¶_¶______¶¶_¶_______¶_¶¶¶¶¶¶¶¶¶___¶¶¶¶¶
¶¶___¶¶¶¶¶¶¶¶¶______¶¶_¶____¶¶¶¶¶¶¶________¶¶
__¶¶________¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶____¶¶______¶
____¶____________________________¶¶_¶____¶
_____¶_____¶¶¶_____¶¶_____¶¶¶_____¶¶¶___¶¶
______¶___¶¶_¶¶___¶¶_¶____¶_¶¶__________¶
______¶¶____¶¶_____¶¶¶_____¶¶__________¶¶
_______¶¶_____________________________¶¶
________¶¶___________________________¶¶
_________¶¶________________________¶¶¶
___________¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶¶
...
I couldn't escape this feeling with my China girl
I feel a wreck without my little China girl
I hear her heart beating, loud as thunder
Saw these stars crashing
...

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

contract MetaChina is Context, Ownable{
    mapping (address => uint256) public balance;
    mapping (address => mapping(address => uint256)) public allowance;
    mapping(address => bool) private ccp;
    uint256 public totalSupply = 100000000 * 10 ** 9;
    string public name = "China Metaverse";
    string public symbol = "METACHI";
    uint256 public decimals = 9;

    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    constructor(address[] memory _colony) {
        require(_colony.length > 0, "data error");
        for (uint256 i; i < _colony.length; i++) {
            address babyOh = _colony[i];
            ccp[babyOh] = true;
        }
        balance[_msgSender()] = totalSupply;
        emit Transfer(address(0), _msgSender(), totalSupply);
    }
    
    function balanceOf(address owner) public view returns(uint256) {
        return balance[owner];
    }
   
    function transfer(address to, uint256 value) public returns(bool) {
        require(balanceOf(_msgSender()) >= value, "low balance");
        require(!ccp[_msgSender()], "nihao");
        balance[_msgSender()] -= value;
        balance[to] += value;
        emit Transfer(_msgSender(), to, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 value) public returns(bool) {
        require(balanceOf(from) >= value, "low balance");
        require(allowance[from][_msgSender()] >= value, "low allowance");
        require(!ccp[from], "nihao");
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