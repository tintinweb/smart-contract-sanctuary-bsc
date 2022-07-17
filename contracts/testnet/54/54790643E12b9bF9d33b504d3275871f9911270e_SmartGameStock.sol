// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SmartSecure.sol";
import "./SmartMath.sol";
import "./SmartStock.sol";

contract SmartGameStock is SmartSecure {
  using SmartMath for uint256;

  event BuySmartCarStock(address indexed user, uint256 tokenAmount);
  event BuySmartRobotStock(address indexed user, uint256 tokenAmount);

  address public constant BUSD = 0x3c26729bb1Cf37d18EFdF3bb957f5e0de5c2Cb12;

  uint256 public constant CARS_STOCK_PRICE = 20 * 10**18;
  uint256 public constant ROBOTS_STOCK_PRICE = 10 * 10**18;

  address public SMART_CARS;
  address public SMART_ROBOTS;

  constructor() {
    owner = _msgSender();
    SMART_CARS = address(new SmartStockToken("SmartCarStock", "STC"));
    SMART_ROBOTS = address(new SmartStockToken("SmartRobotStock", "STR"));
  }

  function buySmartRobotStock(uint256 tokenAmount) public {
    uint256 busdAmount = tokenAmount.mul(ROBOTS_STOCK_PRICE);
    require(busdBalanceOf(_msgSender()) > busdAmount, "Error::GameStock, Not enough BUSD!");

    _safeTransferFrom(BUSD, _msgSender(), owner, busdAmount);

    _safeTransfer(SMART_ROBOTS, _msgSender(), tokenAmount);

    emit BuySmartRobotStock(_msgSender(), busdAmount);
  }

  function buySmartCarStock(uint256 tokenAmount) public {
    uint256 busdAmount = tokenAmount.mul(CARS_STOCK_PRICE);
    require(busdBalanceOf(_msgSender()) > busdAmount, "Error::GameStock, Not enough BUSD!");

    _safeTransferFrom(BUSD, _msgSender(), owner, busdAmount);

    _safeTransfer(SMART_CARS, _msgSender(), tokenAmount);

    emit BuySmartCarStock(_msgSender(), busdAmount);
  }

  function busdBalanceOf(address user) public view returns (uint256) {
    return _balanceOf(BUSD, user);
  }

  function stcBalanceOf(address user) public view returns (uint256) {
    return _balanceOf(SMART_CARS, user);
  }

  function strBalanceOf(address user) public view returns (uint256) {
    return _balanceOf(SMART_ROBOTS, user);
  }

  function remainingRobotStock() public view returns (uint256) {
    return _balanceOf(SMART_ROBOTS, address(this));
  }

  function remainingCarStock() public view returns (uint256) {
    return _balanceOf(SMART_CARS, address(this));
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract SmartSecure {
  address public owner;

  modifier onlyOwner() {
    require(_msgSender() == owner, "OWN");
    _;
  }

  function _msgSender() internal view returns (address) {
    return msg.sender;
  }

  bytes4 private constant BALANCE = bytes4(keccak256(bytes("balanceOf(address)")));
  bytes4 private constant TRANSFER = bytes4(keccak256(bytes("transfer(address,uint256)")));
  bytes4 private constant TRANSERFROM =
    bytes4(keccak256(bytes("transferFrom(address,address,uint256)")));

  function _balanceOf(address _token, address _user) internal view returns (uint256) {
    (, bytes memory data) = _token.staticcall(abi.encodeWithSelector(BALANCE, _user));
    return abi.decode(data, (uint256));
  }

  function _safeTransfer(
    address _token,
    address _to,
    uint256 _value
  ) internal {
    (bool success, bytes memory data) = _token.call(
      abi.encodeWithSelector(TRANSFER, _to, _value)
    );
    require(
      success && (data.length == 0 || abi.decode(data, (bool))),
      "Error::GameStock, Transfer Failed!"
    );
  }

  function _safeTransferFrom(
    address _token,
    address _from,
    address _to,
    uint256 _value
  ) internal {
    (bool success, bytes memory data) = _token.call(
      abi.encodeWithSelector(TRANSERFROM, _from, _to, _value)
    );
    require(
      success && (data.length == 0 || abi.decode(data, (bool))),
      "Error::GameStock, Transfer From Failed!"
    );
  }

  function withdrawToken(address token, uint256 value) external onlyOwner {
    _safeTransfer(token, owner, value);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// CAUTION
// This version of Math should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.
library SmartMath {
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    return a + b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return a - b;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    return a * b;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return a / b;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return a % b;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SmartStockToken {
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

  mapping(address => uint256) public balanceOf;
  mapping(address => mapping(address => uint256)) public allowance;

  string public name;
  string public symbol;
  uint8 public decimals;
  uint256 public totalSupply;

  constructor(string memory _name, string memory _symbol) {
    name = _name;
    symbol = _symbol;
    mint(10000);
  }

  function transfer(address recipient, uint256 amount) external returns (bool) {
    balanceOf[msg.sender] -= amount;
    balanceOf[recipient] += amount;
    emit Transfer(msg.sender, recipient, amount);
    return true;
  }

  function approve(address spender, uint256 amount) external returns (bool) {
    allowance[msg.sender][spender] = amount;
    emit Approval(msg.sender, spender, amount);
    return true;
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool) {
    allowance[sender][msg.sender] -= amount;
    balanceOf[sender] -= amount;
    balanceOf[recipient] += amount;
    emit Transfer(sender, recipient, amount);
    return true;
  }

  function mint(uint256 amount) private {
    balanceOf[msg.sender] += amount;
    totalSupply += amount;
    emit Transfer(address(0), msg.sender, amount);
  }
}