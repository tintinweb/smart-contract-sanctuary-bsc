// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./ModuleBase.sol";
import "./Lockable.sol";
import "./PairPrice.sol";
import "./SafeMath.sol";
import "./IERC20Metadata.sol";

contract NodeDividend is ModuleBase, Lockable, SafeMath {

    //seller
    address internal uReceiver;
    //node price
    uint256 internal nPrice;
    //burn address 
    address internal burnAddress;

    uint256 nodeIndex;

    struct NodeData {
        address owner;
        uint256 usdtAmount;
        uint256 mmtAmount;
        uint256 unlockedAmount;
        uint256 buyTime;
        bool exists;
    }

    mapping(uint256 => NodeData) mapNodeData;

    mapping(address => uint256) mapUserNode;

    uint256 private totalLockAmount;

    struct UnlockData {
        uint256 index;
        uint256 amount;
        uint256 time;
        bool exists;
    }

    uint256 private unlockIndex;
    mapping(uint256 => UnlockData) mapUnlockData;

    constructor(address _auth, address _moduleMgr) ModuleBase(_auth, _moduleMgr) {
        uReceiver = msg.sender;
        nPrice = 2000*10**18;//IERC20Metadata(auth.getUSDTToken()).decimals();
        burnAddress = 0x000000000000000000000000000000000000dEaD;
    }

    function setReceiver(address to) external onlyOwner {
        uReceiver = to;
    }

    function getReceiver() external view returns (address res) {
        res = uReceiver;
    }

    function setPrice(uint256 price) external onlyOwner {
        nPrice = price;
    }

    function getPrice() external view returns (uint256 res) {
        res = nPrice;
    }

    // function testBuyTime(address addr, uint256 time) external onlyOwner {
    //     require(mapUserNode[addr] > 0, "node not exists");
    //     NodeData storage nd = mapNodeData[mapUserNode[addr]];
    //     nd.buyTime = time;
    // }

    function buyNode(uint256 uAmount) external lock {
        require(auth.getEnable(), "stopped");
        require(nodeIndex < 2000, "sold out");
        require(mapUserNode[msg.sender] == 0, "u'd bought a node");
        require(uAmount == nPrice, "input error");
        require(IERC20(auth.getUSDTToken()).balanceOf(msg.sender) >= uAmount, "insufficient usdt");
        require(IERC20(auth.getUSDTToken()).allowance(msg.sender, address(this)) >= uAmount, "not approved");
        uint256 mmtAmount = PairPrice(moduleMgr.getPairPrice()).cumulateMMTAmountOut(uAmount);
        require(mmtAmount > 0, "estimate error");
        require(IERC20(auth.getFarmToken()).balanceOf(address(this)) >= uAmount, "insufficient mmt");
        uint256 lockAmount = div(mmtAmount, 2);
        uint256 burnAmount = sub(mmtAmount, lockAmount);
        mapNodeData[++nodeIndex] = NodeData(msg.sender, uAmount, lockAmount, 0, block.timestamp, true);
        mapUserNode[msg.sender] = nodeIndex;
        totalLockAmount = add(totalLockAmount, lockAmount);
        require(IERC20(auth.getFarmToken()).transfer(burnAddress, burnAmount), "burn error");
        require(IERC20(auth.getUSDTToken()).transferFrom(msg.sender, address(uReceiver), uAmount), "transfer u error");
    }

    function getNodeLength() external view returns (uint256 res) {
        res = nodeIndex;
    }

    function getNodeData(uint256 index) external view returns (
        bool res,
        address owner,
        uint256 usdtAmount,
        uint256 mmtAmount,
        uint256 unlockedAmount,
        uint256 buyTime
    ) {
        if(mapNodeData[index].exists) {
            res = true;
            owner = mapNodeData[index].owner;
            usdtAmount = mapNodeData[index].usdtAmount;
            mmtAmount = mapNodeData[index].mmtAmount;
            unlockedAmount = mapNodeData[index].unlockedAmount;
            buyTime = mapNodeData[index].buyTime;
        }
    }

    function getUserNode(address addr) external view returns (
        bool res,
        address owner,
        uint256 usdtAmount,
        uint256 mmtAmount,
        uint256 unlockedAmount,
        uint256 buyTime
    ) {
        if(mapUserNode[addr] > 0) {
            NodeData memory nd = mapNodeData[mapUserNode[addr]];
            res = true;
            owner = nd.owner;
            usdtAmount = nd.usdtAmount;
            mmtAmount = nd.mmtAmount;
            unlockedAmount = nd.unlockedAmount;
            buyTime = nd.buyTime;
        }
    }

    function unlockTimeAndAmount(address addr) external view returns (
        bool res,
        uint256 time1,
        uint256 time2,
        uint256 time3,
        uint256 time4,
        uint256 time5,
        uint256 time6,
        uint256 amount
    ) {
        if(mapUserNode[addr] > 0) {
            uint256 index = mapUserNode[addr];
            NodeData memory nd = mapNodeData[index];
            res = true;
            time1 = nd.buyTime + 365*24*3600;
            time2 = time1 + 30*24*3600;
            time3 = time2 + 30*24*3600;
            time4 = time3 + 30*24*3600;
            time5 = time4 + 30*24*3600;
            time6 = time5 + 30*24*3600;
            amount = nd.mmtAmount / 6;
        }
    }

    function shouldUnlockAmount(address addr) external view returns (uint256 res) {
        res = _shouldUnlockAmount(addr);
    }

    function _shouldUnlockAmount(address addr) internal view returns (uint256 res) {
        if(mapUserNode[addr] > 0) {
            uint256 index = mapUserNode[addr];
            NodeData memory nd = mapNodeData[index];
            if(block.timestamp >= nd.buyTime + 365*24*3600) {
                uint256 months = (block.timestamp - nd.buyTime - 365*24*3600) / (30*24*3600);
                if(months >= 5) {
                    res = nd.mmtAmount;
                } else if(months >= 4) {
                    res = nd.mmtAmount * 5 / 6;
                } else if(months >= 3) {
                    res = nd.mmtAmount * 4 / 6;
                } else if(months >= 2) {
                    res = nd.mmtAmount * 3 / 6;
                } else if(months >= 1) {
                    res = nd.mmtAmount * 2 / 6;
                } else {
                    res = nd.mmtAmount * 1 / 6;
                }
            }
        }
    }

    function unlockMMT() external lock {
        require(auth.getEnable(), "stopped");
        require(mapUserNode[msg.sender] > 0, "not a node");
        uint256 index = mapUserNode[msg.sender];
        NodeData memory nd = mapNodeData[index];
        require(block.timestamp >= add(nd.buyTime, 365*24*3600), "not time to unlock");
        uint256 shouldUnlockAmountFromBegin = _shouldUnlockAmount(msg.sender);
        require(shouldUnlockAmountFromBegin > 0 && shouldUnlockAmountFromBegin > nd.unlockedAmount, "have no mmt to unlock");
        uint256 shouldUnlockAmountNow = sub(shouldUnlockAmountFromBegin, nd.unlockedAmount);
        require(IERC20(auth.getFarmToken()).balanceOf(address(this)) >= shouldUnlockAmountNow, "insufficient fund");
        mapNodeData[index].unlockedAmount = add(mapNodeData[index].unlockedAmount, shouldUnlockAmountNow);
        totalLockAmount = sub(totalLockAmount, shouldUnlockAmountNow);
        mapUnlockData[++unlockIndex] = UnlockData(index, shouldUnlockAmountNow, block.timestamp, true); 
        require(IERC20(auth.getFarmToken()).transfer(msg.sender, shouldUnlockAmountNow), "unlock error");            
    }

    function withdrawMMT(uint256 amount, address to) external onlyOwner {
        require(IERC20(auth.getFarmToken()).balanceOf(address(this)) >= add(amount, totalLockAmount), "insufficient fund 2");
        require(IERC20(auth.getFarmToken()).transfer(to, amount), "w err");
    }

    function getUnlockLength() external view returns (uint256 res) {
        res = unlockIndex;    
    }

    function getUnlockData(uint256 index) external view returns (
        bool res,
        address account, 
        uint256 amount,
        uint256 time
    ) {
        if(mapUnlockData[index].exists) {
            UnlockData memory ud = mapUnlockData[index];
            NodeData memory nd = mapNodeData[ud.index];
            res = true;
            account = nd.owner;
            amount = ud.amount;
            time = ud.time;
        }
    }
}