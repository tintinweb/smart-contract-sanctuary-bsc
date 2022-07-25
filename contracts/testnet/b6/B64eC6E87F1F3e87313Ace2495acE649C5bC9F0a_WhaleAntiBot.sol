// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IWhaleswapFactory {
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
}

contract WhaleAntiBot {
    address public ownerContract;
    bool public protecing;
    address private pairAddress;
    uint256 public AmountPerTrade;
    uint256 public AmountAddedPerBlock;
    uint256 public TimePerTrade;
    uint256 public BlockNumToDisable;
    bool public addedLiqui;
    address public WBNBAddress;

    mapping(address => uint256) public lastTradeTime;

    IWhaleswapFactory public whaleswapFactory;

    constructor(address whaleswapFactory_) {
        whaleswapFactory = IWhaleswapFactory(whaleswapFactory_);
    }

    function setWBNBAddress(address wBnbAddress_) public {
        require(msg.sender == ownerContract, "Caller is not the owner");
        require(wBnbAddress_ != address(0), "Address can not be Adress(0)");
        WBNBAddress = wBnbAddress_;
    }

    function setTokenOwner(address _owner) external {
        require(_owner != address(0), "can set from the zero address");
        ownerContract = _owner;
    }

    function checkAddedLiquidity(address token) public returns (bool) {
        address pair = whaleswapFactory.getPair(WBNBAddress, token);
        if (pair == address(0)) {
            addedLiqui = false;
        } else {
            addedLiqui = true;
            pairAddress = pair;
        }
        return addedLiqui;
    }

    function checkEnableAntiBot() public view returns (bool) {
        return protecing;
    }

    function enableAntiBot() public returns (bool) {
        require(msg.sender == ownerContract, "Caller is not the owner");
        protecing = true;
        return protecing;
    }

    function disableAntiBot() public returns (bool) {
        require(msg.sender == ownerContract, "Caller is not the owner");
        protecing = false;
        return protecing;
    }

    function setConfig(
        uint256 AmountPerTrade_,
        uint256 AmountAddPerBlock_,
        uint256 TimePerTrade_,
        uint256 BlockNumToDisable_
    ) public returns (bool) {
        require(msg.sender == ownerContract, "Caller is not the owner");
        AmountPerTrade = AmountPerTrade_;
        AmountAddedPerBlock = AmountAddPerBlock_;
        TimePerTrade = TimePerTrade_;
        BlockNumToDisable = BlockNumToDisable_;
        return true;
    }

    function onPreTransferCheck(
        address from,
        address to,
        uint256 amount
    ) private {
        if (addedLiqui && protecing) {
            if (from == pairAddress) {
                require(amount <= AmountPerTrade, "Exceed the amount to trade");
                require(
                    block.timestamp >= lastTradeTime[to] + TimePerTrade,
                    "Trade so fast"
                );

                lastTradeTime[to] = block.timestamp;
            }
        }
    }
}