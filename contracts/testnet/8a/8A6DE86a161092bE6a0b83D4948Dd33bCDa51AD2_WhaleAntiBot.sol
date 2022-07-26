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
    address public tokenAntiBotAddress;
    bool public protecing;
    bool public enablePayFee;
    address private pairAddress;
    uint256 public AmountPerTrade;
    uint256 public AmountAddedPerBlock;
    uint256 public TimePerTrade;
    uint256 public BlockNumToDisable;
    uint256 public BlockNumAtFirst;
    bool public SetBlockNumAtFirstYet;
    bool public addedLiqui;
    address public WBNBAddress;

    mapping(address => uint256) public lastTradeTime;
    mapping(address => bool) public inBlackList;
    mapping(address => bool) public inWhiteList;

    IWhaleswapFactory public whaleswapFactory;

    constructor(address whaleswapFactory_) {
        whaleswapFactory = IWhaleswapFactory(whaleswapFactory_);
        SetBlockNumAtFirstYet = false;
        protecing = true;
        enablePayFee = false;
    }

    function setWBNBAddress(address wBnbAddress_) public {
        require(msg.sender == ownerContract, "Caller is not the owner");
        require(wBnbAddress_ != address(0), "Address can not be Adress(0)");
        WBNBAddress = wBnbAddress_;
    }

    function setTokenOwner(address _owner) external {
        require(_owner != address(0), "can set from the zero address");
        require(ownerContract == address(0), "already have token owner");
        ownerContract = _owner;
    }

    function setTokenAntiBotAddress(address token) external {
        require(token != address(0), "can set from the zero address");
        require(
            tokenAntiBotAddress == address(0),
            "already have token antibot address"
        );
        tokenAntiBotAddress = token;
    }

    function checkHasPayFee() public view returns (bool) {
        return enablePayFee;
    }

    function settingPayFee() public returns (bool) {
        require(
            msg.sender == tokenAntiBotAddress,
            "Caller is not token antibot address"
        );
        enablePayFee = !enablePayFee;
        return enablePayFee;
    }

    function checkAddedLiquidity(address token) public returns (bool) {
        address pair = whaleswapFactory.getPair(WBNBAddress, token);
        if (pair == address(0)) {
            addedLiqui = false;
        } else {
            addedLiqui = true;
            pairAddress = pair;
        }
        if (SetBlockNumAtFirstYet == false) {
            BlockNumAtFirst = block.number;
            SetBlockNumAtFirstYet = true;
        }
        return addedLiqui;
    }

    function resetBlockNumAtFirst() public returns (bool) {
        require(msg.sender == ownerContract, "Caller is not the owner");
        SetBlockNumAtFirstYet = false;
    }

    function checkBlockNumber() public view returns (uint256) {
        return block.number;
    }

    function checkBlockLeftToDisable() public view returns (uint256) {
        if (BlockNumAtFirst + BlockNumToDisable - block.number >= 0) {
            return BlockNumAtFirst + BlockNumToDisable - block.number;
        } else {
            return 0;
        }
    }

    function checkEnableAntiBot() public view returns (bool) {
        return protecing;
    }

    // function enableAntiBot() public returns (bool) {
    //     require(msg.sender == ownerContract, "Caller is not the owner");
    //     protecing = true;
    //     return protecing;
    // }

    // function disableAntiBot() public returns (bool) {
    //     require(msg.sender == ownerContract, "Caller is not the owner");
    //     protecing = false;
    //     return protecing;
    // }

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
        if (SetBlockNumAtFirstYet == false) {
            BlockNumAtFirst = block.number;
            SetBlockNumAtFirstYet = true;
        }
        return true;
    }

    function addBlackList(address user) public returns (bool) {
        require(msg.sender == ownerContract, "Caller is not the owner");
        require(inWhiteList[user] != true, "Address in WhiteList");
        inBlackList[user] = true;
        return true;
    }

    function addWhiteList(address user) public returns (bool) {
        require(msg.sender == ownerContract, "Caller is not the owner");
        require(inBlackList[user] != true, "Address in BlackList");
        inWhiteList[user] = true;
        return true;
    }

    function removeAddresInWhiteList(address user) public returns (bool) {
        require(msg.sender == ownerContract, "Caller is not the owner");
        require(inWhiteList[user] == true, "Address is not in WhiteList");
        inWhiteList[user] = false;
        return true;
    }

    function removeAddresInBlackList(address user) public returns (bool) {
        require(msg.sender == ownerContract, "Caller is not the owner");
        require(inBlackList[user] == true, "Address is not in BlackList");
        inBlackList[user] = false;
        return true;
    }

    function onPreTransferCheck(
        address from,
        address to,
        uint256 amount
    ) external {
        require(inBlackList[from] != true, "Address in BlackList");
        if (
            addedLiqui &&
            protecing &&
            block.number > BlockNumAtFirst + BlockNumToDisable &&
            inWhiteList[from] != true
        ) {
            if (from == pairAddress) {
                AmountPerTrade =
                    AmountPerTrade +
                    (block.number - BlockNumAtFirst) *
                    AmountAddedPerBlock;
                require(amount <= AmountPerTrade, "Exceed the amount to trade");
                require(
                    block.timestamp >= lastTradeTime[to] + TimePerTrade,
                    "Trade so fast"
                );

                lastTradeTime[to] = block.timestamp;
            }
        }
        if (
            block.number > BlockNumAtFirst + BlockNumToDisable &&
            inWhiteList[from] != true
        ) {
            protecing = false;
        }
    }
}