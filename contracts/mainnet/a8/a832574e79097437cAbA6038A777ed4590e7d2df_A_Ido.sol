/**
 *Submitted for verification at BscScan.com on 2022-11-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

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

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

contract Base {
    function getThisTime() view public returns(uint256) {
        return block.timestamp;
    }
}

contract A_Ido is Ownable, Base {
    uint256 private _startTime;
    uint256 private _endTime;
    address private _thisAddress;
    address private _sendAwardAddress;
    address private _collectionAddress;
    uint256 private _successIdo;
    uint256 private _totalPerson;
    uint256 public  _perQuantity;
    IERC20  private _okcToken;
    IERC20  private _usdtToken;
    struct OrderInfo {
        address sender;
        uint256 amount;
    }

    mapping (uint256 => OrderInfo) private order;
    mapping (address => uint8) private person;
    constructor() {
        _thisAddress       = address(this);
        _sendAwardAddress  = address(0xA12CC19e68741327b9AD03D3cb6BD0B4e8Dd2a9B);
        _okcToken          = IERC20(address(0xF8d6D3Ae255094FA7db192956A4B2A3F5bd8e6e6));
        _usdtToken         = IERC20(address(0x55d398326f99059fF775485246999027B3197955));
        _collectionAddress = address(0xE7d8C91B87FbD7b7Ee16759846b41eA7C2Dffe5B);

        _startTime         = 1667476800;
        _endTime           = 1668772800;
        _perQuantity       = 10;
    }

    event BuyEvent(address sender, uint256 orderId, uint256 amount);
    function buy(uint256 orderId, uint256 amount) public {
        require(amount <= _perQuantity, "Exceeds the quantity per purchase");
        require(order[orderId].amount == 0, "Order number already exists");
        require(block.timestamp >= _startTime, "ido not started");
        require(block.timestamp <= _endTime, "ido is over");
        
        address sender = _msgSender();
        emit BuyEvent(sender, orderId, amount);
        order[orderId].sender = sender;
        order[orderId].amount = amount;
        uint256 usdtAmount = amount * 100 * 1e18;
        _usdtToken.transferFrom(sender, _thisAddress, usdtAmount);
        _usdtToken.approve(_thisAddress, usdtAmount);
        _usdtToken.transferFrom(_thisAddress, _collectionAddress, usdtAmount);

        uint256 total = 0;
        uint256 sendAmount = amount * 105 * 1e18;
        total += sendAmount;
        _okcToken.transferFrom(_sendAwardAddress, sender, sendAmount);

        _successIdo += total;
        if (person[sender] == 0) {
            person[sender] = 1;
            _totalPerson += 1;
        }
    }

    function check(uint256 orderId, uint256 amount, address sender) view public returns(uint256) {
        if (order[orderId].amount == amount && order[orderId].sender == sender) {
            return 1;
        }
        return 0;
    }

    function setPerQuantity(uint256 data) public onlyOwner {
        _perQuantity = data;
    }

    function setStartTime(uint256 data) public onlyOwner {
        _startTime = data;
    }

    function getStartTime() view public returns(uint256) {
        return _startTime;
    }

    function setEndTime(uint256 data) public onlyOwner {
        _endTime = data;
    }

    function getEndTime() view public returns(uint256) {
        return _endTime;
    }

    function getSuccessIdo() view public returns(uint256) {
        return _successIdo;
    }

    function getTotalPerson() view public returns(uint256) {
        return _totalPerson;
    }
}