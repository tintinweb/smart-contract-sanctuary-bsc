/**
 *Submitted for verification at BscScan.com on 2022-06-08
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-08
*/

pragma solidity ^0.4.11;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract ERC20Constant {
    function balanceOf( address who ) constant returns (uint value);
}
contract ERC20Stateful {
    function transfer( address to, uint value) returns (bool ok);
}
contract ERC20Events {
    event Transfer(address indexed from, address indexed to, uint value);
    function transferFrom(address from, address to, uint256 value) returns (bool);
}
contract ERC20 is ERC20Constant, ERC20Stateful, ERC20Events {}

contract Ownable {
  address public owner;


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
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
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}

contract HyperwalkSale is Ownable {

    ERC20 public hyperwalkToken;

    // Sales start at this timestamp
    uint256 public initialTimestamp;

    uint256 public publicSaleTimestamp;

    uint256 public minBuy;
    uint256 public maxBuy;

    uint256 public totalAllocation;
    uint256 public purchasedAllocation = 0;

    // This mapping stores the addresses for whitelisted users
    mapping(address => bool) public whitelisted;

    mapping(address => uint256) public purchasedAmount;

    address public BUSD = 0xFED7d14630D1fcDC806d39AbbdA69ea07Ea4eC8D;

    uint256 public price;

    event LogWithdrawal(uint256 _value);
    event LogUserAdded(address user);
    event LogUserRemoved(address user);
    event LogBuy(address receiver, uint256 amount);
    event LogClaim(address receiver, uint256 amount);

    function HyperwalkSale(
        ERC20 _hyperwalkToken,
        uint256 _initialTimestamp,
        uint256 _publicSaleTimestamp,
        uint256 _price,
        uint256 _minBuy,
        uint256 _maxBuy,
        uint256 _totalAllocation
    ) public
    {
        hyperwalkToken = _hyperwalkToken;
        initialTimestamp = _initialTimestamp;
        price = _price;
        publicSaleTimestamp = _publicSaleTimestamp;
        minBuy = _minBuy;
        maxBuy = _maxBuy;
        totalAllocation = _totalAllocation;
    }

    function withdrawHyperwalk(uint256 _value) public onlyOwner returns (bool ok) {
        return withdrawToken(hyperwalkToken, _value);
    }

    // Withdraw any ERC20 token (just in case)
    function withdrawToken(address _token, uint256 _value) public onlyOwner returns (bool ok) {
        return ERC20(_token).transfer(owner,_value);
        LogWithdrawal(_value);
    }

    function buy(uint256 amount) public {
      require(amount > 0);
      require(block.timestamp > initialTimestamp);
      if (block.timestamp < publicSaleTimestamp) {
          require(whitelisted[msg.sender] == true);
      }
      require(purchasedAmount[msg.sender] + amount >= minBuy);
      require(purchasedAmount[msg.sender] + amount <= maxBuy);
      require(purchasedAllocation + amount <= totalAllocation);

      ERC20(BUSD).transferFrom(msg.sender, address(this), amount);
      purchasedAmount[msg.sender] = purchasedAmount[msg.sender] + amount;
      purchasedAllocation += amount;
      LogBuy(msg.sender, amount);
    }

    function claimToken() public {
      require(purchasedAmount[msg.sender] > 0);
      uint256 claimAmount = purchasedAmount[msg.sender];
      purchasedAmount[msg.sender] = 0;
      hyperwalkToken.transfer(msg.sender, claimAmount);
      LogClaim(msg.sender, claimAmount);
    }

    // set min max buy ido
    function setMinMaxBuy(uint256 _minBuy, uint256 _maxBuy) onlyOwner {
      minBuy = _minBuy;
      maxBuy = _maxBuy;
    }

    // Add a user to the whitelist
    function addUser(address user) onlyOwner {
        whitelisted[user] = true;
        LogUserAdded(user);
    }

    // Remove an user from the whitelist
    function removeUser(address user) onlyOwner {
        whitelisted[user] = false;
        LogUserRemoved(user);
    }

    // Batch add users
    function addManyUsers(address[] users) onlyOwner {
        require(users.length < 10000);
        for (uint index = 0; index < users.length; index++) {
             whitelisted[users[index]] = true;
             LogUserAdded(users[index]);
        }
    }
}