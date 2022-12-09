/**
 *Submitted for verification at BscScan.com on 2022-12-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Context {
  function _msgSender() internal view returns (address payable) {
    return payable(msg.sender);
  }
  function _msgData() internal view returns (bytes memory) {
    this;
    return msg.data;
  }
}

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

  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

library TransferHelper {
  function safeApprove(
    address _token,
    address _to,
    uint256 _value
  ) internal {
    // bytes4(keccak256(bytes('approve(address,uint256)')));
    (bool success, bytes memory data) =
      _token.call(abi.encodeWithSelector(0x095ea7b3, _to, _value));
    require(
      success && (data.length == 0 || abi.decode(data, (bool))),
      "TransferHelper::safeApprove: approve failed"
    );
  }

  function safeTransfer(
    address token,
    address to,
    uint256 value
  ) internal {
    // bytes4(keccak256(bytes('transfer(address,uint256)')));
    (bool success, bytes memory data) =
      token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
    require(
      success && (data.length == 0 || abi.decode(data, (bool))),
      "TransferHelper::safeTransfer: transfer failed"
    );
  }

  function safeTransferFrom(
    address token,
    address from,
    address to,
    uint256 value
  ) internal {
    // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
    (bool success, bytes memory data) =
      token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
    require(
      success && (data.length == 0 || abi.decode(data, (bool))),
      "TransferHelper::transferFrom: transferFrom failed"
    );
  }

  function safeTransferBNB(address _to, uint256 _value) internal {
    (bool success, ) = _to.call{value: _value}("");
    require(success, "TransferHelper::safeTransferBNB: BNB transfer failed");
  }
}

library Strings {
  bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
  uint8 private constant _ADDRESS_LENGTH = 20;

  /**
   * @dev Converts a `uint256` to its ASCII `string` decimal representation.
   */
  function toString(uint256 value) internal pure returns (string memory) {
    // Inspired by OraclizeAPI's implementation - MIT licence
    // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

    if (value == 0) {
      return "0";
    }
    uint256 temp = value;
    uint256 digits;
    while (temp != 0) {
      digits++;
      temp /= 10;
    }
    bytes memory buffer = new bytes(digits);
    while (value != 0) {
      digits -= 1;
      buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
      value /= 10;
    }
    return string(buffer);
  }

  /**
   * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
   */
  function toHexString(uint256 value) internal pure returns (string memory) {
    if (value == 0) {
      return "0x00";
    }
    uint256 temp = value;
    uint256 length = 0;
    while (temp != 0) {
      length++;
      temp >>= 8;
    }
    return toHexString(value, length);
  }

  /**
   * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
   */
  function toHexString(uint256 value, uint256 length)
    internal
    pure
    returns (string memory)
  {
    bytes memory buffer = new bytes(2 * length + 2);
    buffer[0] = "0";
    buffer[1] = "x";
    for (uint256 i = 2 * length + 1; i > 1; --i) {
      buffer[i] = _HEX_SYMBOLS[value & 0xf];
      value >>= 4;
    }
    require(value == 0, "Strings: hex length insufficient");
    return string(buffer);
  }

  /**
   * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
   */
  function toHexString(address addr) internal pure returns (string memory) {
    return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
  }
}

contract Ownable is Context {
  address private _owner;
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor() {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  /**
   * @dev Returns the address of the current owner.
   */
  function owner() public view returns (address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) external onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract FIFA2022 is Context, IBEP20, Ownable {
  using SafeMath for uint256;

  mapping(address => uint256) private _balances;
  mapping(address => mapping(address => uint256)) private _allowances;
  uint256 private _totalSupply;

  uint8 public _decimals;
  string public _symbol;
  string public _name;

  constructor() public {
    _name = "FIFA-2022-BET-THE-SECOND";
    _symbol = "FF22";
    _decimals = 18;
    _totalSupply = 0;
    _balances[msg.sender] = _totalSupply;
  }

  function getOwner() external view override returns (address) {
    return owner();
  }

  function decimals() external view override returns (uint8) {
    return _decimals;
  }

  function symbol() external view override returns (string memory) {
    return _symbol;
  }

  function name() external view override returns (string memory) {
    return _name;
  }

  function totalSupply() external view override returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) external view override returns (uint256) {
    return _balances[account];
  }

  function transfer(address recipient, uint256 amount)
    external
    override
    returns (bool)
  {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function allowance(address owner, address spender)
    external
    view
    override
    returns (uint256)
  {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount)
    external
    override
    returns (bool)
  {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external override returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(
      sender,
      _msgSender(),
      _allowances[sender][_msgSender()].sub(
        amount,
        "BEP20: transfer amount exceeds allowance"
      )
    );
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue)
    public
    returns (bool)
  {
    _approve(
      _msgSender(),
      spender,
      _allowances[_msgSender()][spender].add(addedValue)
    );
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue)
    public
    returns (bool)
  {
    _approve(
      _msgSender(),
      spender,
      _allowances[_msgSender()][spender].sub(
        subtractedValue,
        "BEP20: decreased allowance below zero"
      )
    );
    return true;
  }

  function _transfer(
    address sender,
    address recipient,
    uint256 amount
  ) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    _balances[sender].sub(
      amount,
      "BEP20: transfer amount exceeds balance"
    );
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }

  function _approve(
    address owner,
    address spender,
    uint256 amount
  ) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");
    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  /////////// MAIN CONTENT ///////////
  // Open duration: Deploy -> Final
  // The 2nd place team share 95% of BNB reward pool.
  // Rest 5% for dev fee.

  uint256 public beginTs = 1670515200; // 2022-12-09 00:00:00 UTC+0 // 1670515200
  uint256 public endTs = 1671375600;   // 2022-12-18 15:00:00 UTC+0 (before final)
  bool public _isBetOpen = false;
  string public _siteAddr = "https://ff22.tk";
  uint8 public _finalResult;
  Bet[] public betList;
  Nation[] public nationList;

  mapping(address => Buy[]) private myBuys;
  mapping(address => uint256) public _refLog;

  struct Buy {
    uint256 amountBNB;
    bool refund;
  }

  struct Bet {
    address user;
    uint256 timestamp;
    uint256 wager; // wager amount
    uint256 nationIndex; // which nation
    string note; // message
    bool exist; // 
  }

  struct Nation {
    string name; // nation name
    uint256[] betIndexList;
    uint256 wagerSum;
    bool exist;
  }

  /**** MANAGEMENT ****/

  function setSite(string memory _site) external onlyOwner {
    _siteAddr = _site;
  }

  function initNationOptions(string[] memory _nations) external onlyOwner {
    // Add nations and begin bet.
    for (uint8 i = 0; i < _nations.length; i++) {
      Nation memory tempN;
      tempN.name = _nations[i];
      tempN.wagerSum = 0;
      tempN.exist = true;
      nationList.push(tempN);
    }
    _isBetOpen = true;
  }

  // Remove eliminated team.
  // Remove nation of _index in nationList.
  // Give 30% of FF22 (include time multiply reward) back to user.
  function removeNation(uint8 _index) external onlyOwner {
    require(nationList[_index].exist, "The team has been removed.");
    uint256[] memory betInNation = nationList[_index].betIndexList;
    for(uint256 i = 0; i < betInNation.length; i++) {
      uint256 betIndex = betInNation[i];
      betList[betIndex].exist = false;
      uint256 getBackFF22 = betList[betIndex].wager
        .mul(this.timeMultiply(block.timestamp - betList[betIndex].timestamp)).mul(3)
        .div(1e4).div(10);       
      // if gain > original wager
      if(getBackFF22 > betList[betIndex].wager) {
        uint256 more = getBackFF22.sub(betList[betIndex].wager);
        _totalSupply += more;
        _balances[address(this)] += more;
        emit Transfer(address(0), address(this), more);
      }
      // Time reward must add to _totalSupply & temp add to contract addr.
      _balances[address(this)] -= getBackFF22;
      _balances[betList[betIndex].user] += getBackFF22;
      emit Transfer(address(this), betList[betIndex].user, getBackFF22);
    }
    nationList[_index].exist = false; // remove nation
  }

  // Set 2nd place
  function setAnswer(uint8 _winnerIndex) external onlyOwner {
    require(block.timestamp > endTs, "Bet still open.");
    require(_isBetOpen, "Final result published already.");
    // Fee: 5%
    TransferHelper.safeTransferBNB(msg.sender, address(this).balance.mul(5).div(100));
    _isBetOpen = false;
    _finalResult = _winnerIndex;
    // check if win team is valid.
    Nation memory winNation = nationList[_winnerIndex];
    require(winNation.exist, "Eliminated team.");
    uint256 winPool = address(this).balance; // Pool = Total bet BNB
    uint256 finalWager = 0;
    for(uint8 j = 0; j < winNation.betIndexList.length; j++) {
      Bet memory thisBet = betList[winNation.betIndexList[j]];
      if(thisBet.exist) finalWager += thisBet.wager.mul(this.timeMultiply(block.timestamp - thisBet.timestamp)).div(1e4);
    }
    for(uint8 k = 0; k < winNation.betIndexList.length; k++) {
      Bet memory thisBet = betList[winNation.betIndexList[k]];
      if(thisBet.exist) {
        uint256 thisWager1e4 = thisBet.wager.mul(this.timeMultiply(block.timestamp - thisBet.timestamp));
        TransferHelper.safeTransferBNB(thisBet.user, winPool.mul(thisWager1e4).div(finalWager).div(1e4));
      }
    }
  }

  /**** BET ****/

  // use FF22 to bet on team
  function addBet(uint256 _index, uint256 _amount, string calldata _note) external {
    require(_amount >= 10 * 1e18, "At least 10 FF22 to bet.");
    require(_balances[msg.sender] >= _amount, "Insufficient FF22.");
    require(block.timestamp >= beginTs, "Not begin yet.");
    require(block.timestamp <= endTs, "Bet closed.");
    require(_index < nationList.length, "Invalid nation index.");
    _balances[msg.sender] -= _amount;
    _balances[address(this)] += _amount;
    emit Transfer((msg.sender), address(this), _amount);

    // push bet into bet list and nation list
    Bet memory tempBet;
    tempBet.user = msg.sender;
    tempBet.timestamp = block.timestamp;
    tempBet.wager = _amount; // FF22
    tempBet.nationIndex = _index;
    tempBet.exist = true;
    if(bytes(_note).length > 0) tempBet.note = _note;
    betList.push(tempBet);
    nationList[_index].betIndexList.push(betList.length - 1);
    nationList[_index].wagerSum += _amount;
  }

  // 1 BNB buy 10000 FF22, min 100 FF22.
  function buyFF22(address _ref) external payable {
    // Minimal pay: 0.01 BNB
    // If has a referer, BOTH get 3% more of FF22.
    require(msg.value >= 1 * 1e16, "Minimum = 0.01 BNB (100 FF22).");
    uint bought = msg.value.mul(10000);
    uint reward = 0;
    if(_ref != address(0) && _ref != msg.sender) {
      reward = bought.mul(3).div(100);
      // Referrer reward
      _balances[_ref] += reward;
      _refLog[_ref] += reward;
      emit Transfer(address(0), _ref, reward);
    }
    // Your FF22 + reward
    _balances[msg.sender] += (bought + reward);
    emit Transfer(address(0), msg.sender, (bought + reward));
    _totalSupply += (bought + reward + reward);
    // Keep log in case of fund return.
    Buy memory tempBuy;
    tempBuy.amountBNB = msg.value;
    tempBuy.refund = false;
    myBuys[msg.sender].push(tempBuy);
  }

  function refund() external returns (bool) {
    // Everyone can request a refund if no result set 10 days after 12/17 in case of game delay.
    require(_isBetOpen, "Result already published.");
    require(block.timestamp - endTs > 864000, "Please wait for the result.");
    _refund();
  }

  function _refund() internal {
    for (uint256 i = 0; i < myBuys[msg.sender].length; i++) {
      if(myBuys[msg.sender][i].refund == false) {
        myBuys[msg.sender][i].refund = true;
        TransferHelper.safeTransferBNB(msg.sender, myBuys[msg.sender][i].amountBNB);
      }
    }
  }

  /**** VIEW ****/

  function officialSite() public view returns (string memory) {
    return _siteAddr;
  }

  function getNationList() public view returns (Nation[] memory) {
    return nationList;
  }

  function getBetList() public view returns (Bet[] memory) {
    return betList;
  }

  function timeMultiply(uint _sec) public view returns (uint rate) {
    // *** RATE = y / 1e4
    // y = 0.0001x^2 + 0.015x + 0.35
    // y = rate, x = hours elapsed after bet
    uint256 hr = _sec.div(3600);
    if(hr > 239) hr = 239;
    rate = hr.mul(hr).add(hr.mul(150)).add(3500);
  }

}