/**
 *Submitted for verification at BscScan.com on 2022-12-05
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    
    function totalSupply() external view returns (uint256);
    function balanceOf(address tokenOwner) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address tokenOwner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

/**
 *
 *  Doge Token
 * 
 *  High-quality tokens with a total supply of 10**15 
 * 
 */
contract Tips is IERC20 {
    
    using SafeMath for uint256;
    
    //Tips token, creator will take 0.6% fee
    address public marketWallet = 0x80Ad12375a77aF8cCBcc8fBcA37A94523211DC21;

    string public name = "Tips";
    string public symbol = "Tips";
    uint256 public decimals = 18;
    uint256 private _totalSupply = 10**10 *(10**decimals);
    
    //Tips Token supply max length
    // uint256 private totalLength = 11;

    address public owner;
    // address internal initReward;

    address internal deadAddress = 0x0000000000000000000000000000000000000000;

    
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowed;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    constructor() {
       owner = msg.sender;
       balances[owner]=_totalSupply;
    //    minet(msg.sender, _totalSupply);

    }

  

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(owner == msg.sender, "Ownable: caller is not the owner");
    _;
  }


  /**
   * @dev Leaves the contract without owner. It will not be possible to call
   * `onlyOwner` functions anymore. Can only be called by the current owner.
   *
   * NOTE: Renouncing ownership will leave the contract without an owner,
   * thereby removing any functionality that is only available to the owner.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(owner, deadAddress);
    owner = deadAddress;
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != deadAddress, "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
  }



    function minet(address tokenOwner, uint256 amount) internal returns (uint256) {
        require(msg.sender == owner, "Owner Erro");
        _totalSupply = _totalSupply.add(amount);
        balances[tokenOwner] = balances[tokenOwner].add(amount);
        emit Transfer(deadAddress, tokenOwner, amount);
        return balances[tokenOwner];
    }


    
    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner];    
    }
    
    function allowance(address tokenOwner, address spender) external override view returns (uint) {
        return allowed[tokenOwner][spender];
    }
    
    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, allowed[sender][msg.sender].sub(amount));
        return true;
    }
    
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != deadAddress, "BEP20: transfer from the zero address");
        require(recipient != deadAddress, "BEP20: transfer to the zero address");
        require(balances[sender] >= amount, "BEP20: transfer sender amount exceeds balance");
         
        uint256 totalFee = amount * 1 / 100;


        if (totalFee == 0) totalFee = 1; // minimum 0.000000000000000001 Tips
        
        balances[sender] = balances[sender].sub(amount);
        balances[recipient] = balances[recipient].add(amount.sub(totalFee));
        emit Transfer(sender, recipient, amount.sub(totalFee));
        
        
        // Trigger notify and added fee into marketWallet
        balances[marketWallet] = balances[marketWallet].add(totalFee);
        emit Transfer(sender, marketWallet, totalFee);
        
    }
    
    function _approve(address tokenOwner, address spender, uint256 amount) internal {
        allowed[tokenOwner][spender] = amount;
    }
    
}