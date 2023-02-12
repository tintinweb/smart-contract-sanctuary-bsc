// SPDX-License-Identifier: MIT
/**

    🎮⭐️Ultron⭐️🎮
    #Ultron, the fun virtual reality game allowing you to #earn and #live online.
    ⭐️With #Ultron you really can take the reality of living and dreaming into a virtual world. 
    Where all aspects are created, designed, and perfected by you.
    ⭐️⭐️Starting with player skills and characteristics, this will give you an online fresh start 
    where you choose your path of success within the Ultron world.

    🎮⭐️Ultron Game Summary; 
    🗣️Ultron #Characters; Each player will create their own #identity with specific characteristics, 
    #skills and attributes. These chosen skills will allow you to browse the Ultron in-game world to 
    complete different daily tasks for fun!

    💎🚙Ultron #Assets; Like any real world, once you earn your #Ultron you can exchange them 
    for realtime in game assets. Upgrade and be the first to own an array of attributes such as #jewellery, 
    #houses, #cars and even pets. All will be delivered and claimed through in game #marketplace NFT upgrades

    🌇Ultron #City; In the game our first city will be designed for in game player interaction, with #tasks, 
    #skills and #games. The more successfull you are at completeing such interactions the more you are rewarded.

    🌆Ultron #Marketplace; Game items could both be traded through the in-game #marketplace and also the 
    NFT marketplaces on other blockchains. It creates #liquidity for the assets created through the game and also 
    encourages more players to participate in building the the Ultron world.

    🚀FairLaunch on Pancakeswap: Feb 12th, 17:00 UTC 📆

    🌍Web       : https://www.Ultron.online
    🔎Telegram  : https://t.me/UltronChannel
    🕊Twitter    : https://twitter.com/ortiz234

    Ultron
    1,000,000,000 Ultron
    ⭐️Tax Fee %2 💰%1 to Marketing 🎮🎁%1 to Gaming Rewards
   
*/
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

contract Ultron is ERC20, Ownable {
  uint256 private initialSupply = 500000000 * (10 ** 18);

  mapping(bool => mapping(address => bool)) public isExcludedFromFees;

  uint256 public sellFee = 2;
  uint256 public buyFee = 1;
  address public marketingWallet = 0xc4314883FA477Fa377BB05bC904CFF96A9c13D85;

  IUniswapV2Router02 public uniswapV2Router;
  address public uniswapV2Pair;

  constructor() ERC20("Ultron", "Ultron") {
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