/**
 *Submitted for verification at BscScan.com on 2022-05-27
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    /**
     * mul 
     * @dev Safe math multiply function
     */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
  /**
   * add
   * @dev Safe math addition function
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

abstract contract Ownable {
  address public owner;

  constructor () internal {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    owner = newOwner;
  }
}

/**
 * @title Token
 * @dev API interface for interacting with the WILD Token contract 
 */
interface IToken {
  function transfer(address _to, uint256 _value) external returns (bool);
  function balanceOf(address _owner) external returns (uint256 balance);
}

/**
 * @title NowMetaICO
 * @dev NowMetaICO contract is Ownable
 **/
contract NowMetaICO is Ownable {
  using SafeMath for uint256;
  uint256 public tokenLength = 0;

  struct PoolInfo {
    address tokenAddr;
    uint256 rate;
    uint256 cap;
    uint256 contribute;
    uint256 start;
    uint256 day;
    uint256 initialToken;
    uint256 boughtToken;
    bool initialized;
    bool activated;
    address[] users;
  }

  struct UserInfo {
    uint256 depositAmount;
    uint256 pendingAmount;
  }
  
  mapping(uint256 => PoolInfo) public pools;

  mapping(address =>  mapping(uint256 => UserInfo)) public users;

  event BoughtTokens(address indexed to, uint256 value);

  constructor(
    address _tokenaddr,
    uint256 rate,
    uint256 cap,
    uint256 contribute,
    uint256 start,
    uint256 day,
    uint256 initialToken
  ) public {
    address[] memory initial;
    pools[tokenLength] = PoolInfo(_tokenaddr, rate, cap, contribute, start, day, initialToken, 0, false, true, initial);
    tokenLength = tokenLength.add(1);
  }


  function addPool(
      address _tokenaddr,
      uint256 rate,
      uint256 cap,
      uint256 contribute,
      uint256 start,
      uint256 day,
      uint256 initialToken
  ) external onlyOwner returns (bool) {
    address[] memory initial;
    pools[tokenLength] = PoolInfo(_tokenaddr, rate, cap, contribute, start, day, initialToken, 0, false, true, initial);
    tokenLength = tokenLength.add(1);
    return true;
  }
  
  function initialize(uint256 _poolId) public onlyOwner {
    PoolInfo storage _token = pools[_poolId];
    require(_token.initialized == false, "Can only be initialized once"); // Can only be initialized once
    require(tokensAvailable(_poolId) >= _token.initialToken, "Must have enough tokens allocated"); // Must have enough tokens allocated
    
    _token.initialized = true;
  }

  modifier beforeBuy(uint256 _poolId) {
    PoolInfo storage _token = pools[_poolId];
    require(isActive(_poolId), "Not activated");
    require(_token.cap  >= _token.boughtToken.add(msg.value), "error : overflow cap");
    _;
  }

  function isActive(uint256 _poolId) public view returns (bool) {
    PoolInfo storage _token = pools[_poolId];
    
    return (
        _token.initialized == true &&
        _token.activated == true &&
        now >= _token.start && // Must be after the START date
        now <= _token.start.add(_token.day * 1 days) // Must be before the end date
    );
  }

  function deposit(uint256 _poolId) public payable beforeBuy(_poolId) {
    PoolInfo storage _token = pools[_poolId];
    UserInfo storage _user = users[msg.sender][_poolId];
    uint256 weiAmount = msg.value; // Calculate tokens to sell

    require(_user.depositAmount.add(weiAmount) <= _token.contribute, "error : overflow contributed Amount");
    
    if(_user.depositAmount == 0) {
      _token.users.push(msg.sender);
    }

    _user.depositAmount = _user.depositAmount.add(weiAmount);
    _token.boughtToken = _token.boughtToken.add(weiAmount);
    
    
    uint256 tokens = weiAmount.mul(_token.rate);
    
    _user.pendingAmount = _user.pendingAmount.add(tokens);


    // IToken token = IToken(_token.tokenAddr);
    // token.transfer(msg.sender, tokens); // Send tokens to buyer
    // payable(owner).transfer(weiAmount);// Send money to owner
    
    emit BoughtTokens(msg.sender, tokens); // log event onto the blockchain
  }

  function tokensAvailable(uint256 _poolId) public returns (uint256) {
    PoolInfo memory _token = pools[_poolId];
    IToken token = IToken(_token.tokenAddr);
    return token.balanceOf(address(this));
  }

  function pendingAmount(uint256 _poolId, address userAddr) internal view returns(uint256){
    UserInfo memory _user = users[userAddr][_poolId];
    return _user.pendingAmount;
  }

  function destroy(uint256 _poolId) onlyOwner public {
    PoolInfo memory _token = pools[_poolId];
    require(_token.activated == false, "error : pool is activated now");
    
    IToken token = IToken(_token.tokenAddr);
    uint256 balance = token.balanceOf(address(this));
    assert(balance > 0);
    token.transfer(owner, balance);
    payable(owner).transfer(_token.boughtToken);
  }

  function controlServer(bool _status, uint256 _poolId) external onlyOwner {
    PoolInfo memory _token = pools[_poolId];
    IToken token = IToken(_token.tokenAddr);
    require(_token.activated == true, "error : not activated");

    if(_status == true) {
      for(uint256 i = 0; i < _token.users.length; i ++) {
        uint256 pending = users[_token.users[i]][_poolId].pendingAmount;
        token.transfer(_token.users[i], pending);
      }
    } else {
      for(uint256 i = 0; i < _token.users.length; i ++) {
        uint256 deposited = users[_token.users[i]][_poolId].depositAmount;
        payable(_token.users[i]).transfer(deposited);
      }
      _token.boughtToken = 0;
    }

    _token.activated = false;
  }


}