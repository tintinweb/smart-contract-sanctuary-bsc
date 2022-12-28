/**
 *Submitted for verification at BscScan.com on 2022-12-28
*/

pragma solidity 0.6.6;

// Partial License: MIT

interface IERC20 {
   
    function totalSupply() external view returns (uint256);

   
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

   
    function allowance(address owner, address spender) external view returns (uint256);

   
    function approve(address spender, uint256 amount) external returns (bool);

  
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

   
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


// Partial License: MIT

pragma solidity ^0.6.0;


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


// Partial License: MIT

pragma solidity ^0.6.0;


contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

  
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

   
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

 
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


// Partial License: MIT

pragma solidity ^0.6.0;
 
library SafeMath {
 
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
 
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
 
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
 
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

   
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


pragma solidity 0.6.6;





contract MTB_TestSale is Ownable {
    using SafeMath for uint256;
    IERC20 public MTB;

    // BP
    uint256 constant BP = 10000;

    // sale params
    bool    public started;
    uint256 public price;
    uint256 public ends;
    uint256 public hardcap;
    bool    public paused;
    uint256 public minimum;

    // stats:
    uint256 public totalOwed;
    uint256 public weiRaised;

    mapping(address => uint256) public claimable;

    constructor (address TokenAddress) public { MTB = IERC20(TokenAddress); }

    // pause contract preventing further purchase.
    // pausing however has no effect on those who
    // have already purchased.
    function pause(bool _paused)            public onlyOwner { paused = _paused;}
    function setPrice(uint256 _price)       public onlyOwner { price = _price; }
    function setHardCap(uint256 _hardcap)   public onlyOwner { hardcap = _hardcap; }
    function setMinimum(uint256 _minimum)   public onlyOwner { minimum = _minimum; }
    function unlock()                       public onlyOwner { ends = 0; }

    function withdrawETH(uint256 amount) public onlyOwner {
        msg.sender.transfer(amount);
    }

    function withdrawUnsold(uint256 amount) public onlyOwner {
        require(amount <= MTB.balanceOf(address(this)).sub(totalOwed), "insufficient balance");
        MTB.transfer(msg.sender, amount);
    }

    // start the presale
    function startPresale(uint256 _ends) public onlyOwner {
        require(!started, "already started!");
        require(price > 0, "set price first!");
        require(hardcap > 0, "set hardcap first!");
        require(minimum > 0, "set minimum first!");

        started = true;
        paused = false;
        ends = _ends;
    }

    // the amount of MTB purchased
    function calculateAmountPurchased(uint256 _value) public view returns (uint256) {
        return _value.mul(BP).div(price).mul(1e18).div(BP);
    }

    // claim your purchased tokens
    function claim() public {
        //solium-disable-next-line
        require(block.timestamp > ends, "presale has not yet ended");
        require(claimable[msg.sender] > 0, "nothing to claim");

        uint256 amount = claimable[msg.sender];

        // update user and stats
        claimable[msg.sender] = 0;
        totalOwed = totalOwed.sub(amount);

        // send owed tokens
        require(MTB.transfer(msg.sender, amount), "failed to claim");
    }

    // purchase tokens
    function buy() public payable {
        //solium-disable-next-line
        require(block.timestamp < ends, "presale has ended");
        require(!paused, "presale is paused");
        require(msg.value > minimum, "amount too small");
        require(weiRaised.add(msg.value) <= hardcap, "hardcap exceeded");

        uint256 amount = calculateAmountPurchased(msg.value);
        require(totalOwed.add(amount) <= MTB.balanceOf(address(this)), "sold out");

        // update user and stats:
        claimable[msg.sender] = claimable[msg.sender].add(amount);
        totalOwed = totalOwed.add(amount);
        weiRaised = weiRaised.add(msg.value);
    }
    
    fallback() external payable { buy(); }
    receive() external payable { buy(); }
    
    
}