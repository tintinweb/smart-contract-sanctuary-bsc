// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Lockable.sol";
import "./ModuleBase.sol";
import "./IERC20.sol";
import "./PairPrice.sol";
import "./SafeMath.sol";

contract PreSell is ModuleBase, SafeMath, Lockable {

    uint256 internal constant min_usdt_amount = 10*10**18;
    uint256 internal constant max_usdt_mount = 300000*10**18;

    struct BuyData {
        address account;
        uint256 usdtAmount;
        uint256 mmtAmount;
        uint256 buyTime;
        bool exists;
    }

    uint256 internal totalUsdtAmount;
    
    uint32 internal buyLength;
    mapping(uint32 => BuyData) mapBuy;

    //key: account => child number
    mapping(address => uint32) mapChildNumber;

    //key: account => parentId
    mapping(address => uint32) mapParentId;

    mapping(address => bool) mapBought;

    constructor(address _auth, address _moduleMgr) ModuleBase(_auth, _moduleMgr) {
    }

    function buyMMT(uint256 usdtAmount, uint32 parentId) external lock {
        require(!mapBought[msg.sender], "u'd bought");
        require(usdtAmount >= min_usdt_amount, "must >= 10");
        if(parentId > 0) {
            require(mapParentId[msg.sender] != parentId, "parent dulplicated");
        }
        require(IERC20(auth.getUSDTToken()).balanceOf(msg.sender) >= usdtAmount, "insufficient balance");
        require(IERC20(auth.getUSDTToken()).allowance(msg.sender, address(this)) >= usdtAmount, "not approved");
        require(totalUsdtAmount < max_usdt_mount, "sold out");
        uint256 mmtAmount = PairPrice(moduleMgr.getPairPrice()).cumulateMMTAmountOut(usdtAmount);
        require(mmtAmount > 0, "price err");
        require(IERC20(auth.getFarmToken()).balanceOf(address(this)) >= mmtAmount, "insufficient fund");

        mapBuy[++buyLength] = BuyData(msg.sender, usdtAmount, mmtAmount, block.timestamp, true);
        totalUsdtAmount = add(totalUsdtAmount, usdtAmount);

        mapParentId[msg.sender] = parentId;
        mapChildNumber[msg.sender]++;
        mapBought[msg.sender] = true;

        require(IERC20(auth.getFarmToken()).transfer(msg.sender, mmtAmount), "transfer mmt err");
        require(IERC20(auth.getUSDTToken()).transferFrom(msg.sender, address(this), usdtAmount), "transferFrom usdt err");
    }

    function withdrawToken(address token, uint256 amount, address to) external onlyOwner {
        require(IERC20(token).balanceOf(address(this)) >= amount, "insufficient fund");
        require(IERC20(token).transfer(to, amount), "transfer mmt err");
    }

    function getTotalBuyLength() external view returns (uint32 res) {
        res = buyLength;
    }

    function getBuyData(uint32 index) external view returns (
        bool res,
        address account,
        uint256 usdtAmount,
        uint256 mmtAmount,
        uint256 buyTime
    ) {
        if(mapBuy[index].exists) {
            res = true;
            account = mapBuy[index].account;
            usdtAmount = mapBuy[index].usdtAmount;
            mmtAmount = mapBuy[index].mmtAmount;
            buyTime = mapBuy[index].buyTime;
        }
    }

    function getChildLength(address account) external view returns (uint32 res) {
        res = mapChildNumber[account];
    }

    function getParentId(address account) external view returns (uint32 res) {
        res = mapParentId[account];
    }
}