/**
 *Submitted for verification at BscScan.com on 2022-09-26
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract Base {
    address internal _master;
    address internal _thisAddress;

    uint256 internal randKey = 0;
    function rand(uint256 max, uint256 randNums) internal returns (uint256) {
        uint256 rands = uint256(keccak256(abi.encodePacked(getTime(), block.difficulty, msg.sender, randKey, randNums))) % max;
        if (rands <= 0) {
            rands = max;
        }
        randKey++;
        return rands;
    }

    function getTime() view public returns(uint256) {
        return block.timestamp;
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
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        _status = _NOT_ENTERED;
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract Ido is Ownable, Base, ReentrancyGuard {
    using SafeMath for uint256;
    address private _collectionAddress;

    struct Config {
        uint256 totalIdo;               //IDO總數
        uint256 successIdo;             //已完成的IDO數
        IERC20 idoToken;                //購買到的代幣
        IERC20 payToken;                //使用什麼代幣來交換
        uint256 price;
        uint256 minIdo;
        uint256 maxIdo;
        uint256 personMaxIdo;
        uint256 startTime;
        uint256 endTime;
    }

    uint256 private personCount = 0;
    uint256 private totalIdoPrice = 0;
    mapping (address => uint256) ido;
    mapping (uint256 => Config) internal config;

    event SubscribeEvent(uint256 amount, address user);

    constructor() {
        _master = msg.sender;
        _thisAddress = address(this);
        _collectionAddress = address(0xC4357D73AD8d84D2BBA89aF701B9B3d134377d7C);
        set(50000000 * 1e18, IERC20(0x8Ead4A6b5Ab1EF6c19AF8C84C33071B404913E53), IERC20(0x55d398326f99059fF775485246999027B3197955), 0.005 * 1e18, 10 * 1e18, 850000 * 1e18);
        //_collectionAddress = address(0x70d648614d11652a93314fc9f3427AA54bad8259);
        //set(50000000 * 1e18, IERC20(0x5Db6C66a12949774272E148dc2af9ab8cD0af096), IERC20(0x696d5527e49a35396B10dD3A97a93ec0dd2F0687), 0.005 * 1e18, 1 * 1e18, 850000 * 1e18);

        setStartTime(1664467200);
        setEndTime(1759161600);
    }

    function set(uint256 _totalIdo, IERC20 _idoToken, IERC20 _payToken, uint256 _price, uint256 _minIdo, uint256 _maxIdo) private onlyOwner {
        config[0].totalIdo = _totalIdo;
        config[0].idoToken = _idoToken;
        config[0].payToken = _payToken;
        config[0].price = _price;
        config[0].minIdo = _minIdo;
        config[0].maxIdo = _maxIdo;
    }

    function subscribe(uint256 amount) nonReentrant public payable {
    	require(block.timestamp >= config[0].startTime && block.timestamp <= config[0].endTime, "Sales have not started");
        address sender = msg.sender;
        require(
            config[0].payToken.balanceOf(sender) >= amount,
            "Insufficient available balance"
        );
        require(amount >= config[0].minIdo, "Below the minimum subscription amount");
        require(config[0].successIdo < config[0].totalIdo, "sold out");
        require(config[0].successIdo + amount <= config[0].totalIdo, "Insufficient quantity left");
        require(amount + ido[sender] <= config[0].maxIdo, "Maximum limit total exceeded");
        require(amount <= config[0].personMaxIdo, "Exceed the maximum purchase limit per person");
        
        uint256 price = config[0].price;
        uint256 totalAmount = (amount / price) * 1e18;

        ido[sender] += amount;
        config[0].successIdo += amount;

        config[0].payToken.transferFrom(sender, _thisAddress, amount);
        config[0].idoToken.transfer(sender, totalAmount);
        config[0].payToken.approve(_collectionAddress, amount);
        config[0].payToken.transfer(_collectionAddress, amount);
        personCount += 1;
        totalIdoPrice += totalAmount;
        emit SubscribeEvent(totalAmount, sender);
    }

    function getSubscribeCount(uint256 amount) view public returns(uint256) {
        return amount / config[0].price;
    }

    function getPersonCount() public view returns(uint256) {
        return personCount;
    }

    function getSellInfo() public view returns(uint256[2] memory) {
        uint256[2] memory data = [personCount, totalIdoPrice];
        return data;
    }

    function setMinIdo(uint256 _minIdo) public onlyOwner {
        config[0].minIdo = _minIdo;
    }

    function setMaxIdo(uint256 _maxIdo) public onlyOwner {
        config[0].maxIdo = _maxIdo;
    }

    function getPrice() view public returns(uint256) {
        return config[0].price;
    }

    function getSuccessIdo() view public returns(uint256) {
        return config[0].successIdo;
    }
    
    function setStartTime(uint256 _startTime) public onlyOwner {
        config[0].startTime = _startTime;
    }

    function setEndTime(uint256 _endTime) public onlyOwner {
        config[0].endTime = _endTime;
    }

    function getStartTime() view public returns(uint256) {
        return config[0].startTime;
    }

    function getEndTime() view public returns(uint256) {
        return config[0].endTime;
    }

    function getTotalIdo() view public returns(uint256) {
        return config[0].totalIdo;
    }

    function getConfig() public view returns(Config memory) {
        return config[0];
    }
}