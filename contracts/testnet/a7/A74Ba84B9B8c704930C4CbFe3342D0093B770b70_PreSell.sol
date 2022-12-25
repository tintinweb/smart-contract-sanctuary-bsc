// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Lockable.sol";
import "./ModuleBase.sol";
import "./IERC20.sol";
import "./PairPrice.sol";
import "./SafeMath.sol";
import "./Strings.sol";
import "./ECDSA.sol";

contract PreSell is ModuleBase, SafeMath, Lockable, ECDSA {

    uint256 internal constant min_usdt_amount = 10*10**18;
    uint256 internal constant max_usdt_mount = 300000*10**18;

    address internal signer;

    struct BuyData {
        address account;
        uint256 usdtAmount;
        uint256 mmtAmount;
        uint256 buyTime;
        bytes32 parentId;
        bool exists;
    }

    uint256 internal totalUsdtAmount;
    
    uint32 internal buyLength;
    mapping(uint32 => BuyData) mapBuy;

    //key: hash(account) => child number
    mapping(bytes32 => uint32) mapChildNumber;

    //key: account => parentId
    mapping(address => bytes32) mapParentId;

    //mapping for user buy length
    mapping(address => uint32) mapUserBuyLength;
    mapping(address => mapping(uint32 => uint32)) mapUserBuyData;

    //sorted prize
    struct SortedPrize {
        address account;
        uint8 pos;
        uint256 amount;
        bool claimed;
        bool exists;
    }
    mapping(uint8 => SortedPrize) mapSortedPrize;
    mapping(address => uint8) mapUserSortedPrize;
    uint8 private sortedPrizeIndex;

    //share prize
    struct ClaimData {
        address account;
        uint256 mmtAmount;
        bool exists;
    }
    mapping(address => ClaimData) mapClaimAI;
    mapping(address => ClaimData) mapClaimIPhone;

    //prize wheel
    //wheel count
    //key: hash(account) => wheel count
    mapping(bytes32 => uint32) mapWheelCount;
    mapping(bytes32 => uint32) mapWheelCountOfShare;


    struct WithdrawData {
        address account;
        uint256 mmtAmount;
        uint256 usdtValue;
        uint256 withdrawTime;
        bool exists;
    }

    //key: withdrawId => WithdrawData
    mapping(uint32 => WithdrawData) private mapWithdraw;
    //key: user wallet address => withdraw length
    mapping(address => uint32) mapUserWithdrawLength;
    //key: usre wallet address => (index of withdraw length => withdrawId)
    mapping(address => mapping(uint32 => uint32)) mapUserWithdrawData;

    struct ClaimWheelPrizeData {
        address account;
        uint256 wheelIndex;
        uint256 amount;
        bool exists;
    }
    uint32 private claimWheelPrizeLength;
    mapping(uint32 => ClaimWheelPrizeData) mapClaimWheelPrize;

    mapping(address => mapping(uint256 => uint32)) mapUserClaimWheelPrize;

    constructor(address _auth, address _moduleMgr) ModuleBase(_auth, _moduleMgr) {
    }

    function setSigner(address _signer) external onlyOwner {
        signer = _signer;
    }

    function getSigner() external view returns (address res) {
        res = signer;
    }

    function buyMMT(uint256 usdtAmount, bytes32 parentId) external lock {
        require(usdtAmount >= min_usdt_amount, "must >= 10");
        require(IERC20(auth.getUSDTToken()).balanceOf(msg.sender) >= usdtAmount, "insufficient balance");
        require(IERC20(auth.getUSDTToken()).allowance(msg.sender, address(this)) >= usdtAmount, "not approved");
        require(totalUsdtAmount < max_usdt_mount, "sold out");
        uint256 mmtAmount = PairPrice(moduleMgr.getPairPrice()).cumulateMMTAmountOut(usdtAmount);
        require(mmtAmount > 0, "price err");
        require(IERC20(auth.getFarmToken()).balanceOf(address(this)) >= mmtAmount, "insufficient fund");

        totalUsdtAmount = add(totalUsdtAmount, usdtAmount);
        if(parentId > 0 && mapParentId[msg.sender] == 0) {
            mapParentId[msg.sender] = parentId;
            mapChildNumber[parentId]++;
            if(mapChildNumber[parentId] % 10 > mapWheelCountOfShare[parentId]) {
                mapWheelCount[parentId]++;
                mapWheelCountOfShare[parentId]++;
            }
        }
        mapBuy[++buyLength] = BuyData(msg.sender, usdtAmount, mmtAmount, block.timestamp, mapParentId[msg.sender], true);
        
        mapUserBuyLength[msg.sender]++;
        mapUserBuyData[msg.sender][mapUserBuyLength[msg.sender]] = buyLength;
        mapWheelCount[keccak256(abi.encodePacked(Strings.addressToString(msg.sender)))]++;

        require(IERC20(auth.getFarmToken()).transfer(msg.sender, mmtAmount), "transfer mmt err");
        require(IERC20(auth.getUSDTToken()).transferFrom(msg.sender, address(this), usdtAmount), "transferFrom usdt err");
    }

    function getSellStatus() external view returns (
        uint256 maxAmount,
        uint256 soldAmount
    ) {
        maxAmount = max_usdt_mount;
        soldAmount = totalUsdtAmount;
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
        uint256 buyTime,
        bytes32 parentId
    ) {
        if(mapBuy[index].exists) {
            res = true;
            account = mapBuy[index].account;
            usdtAmount = mapBuy[index].usdtAmount;
            mmtAmount = mapBuy[index].mmtAmount;
            buyTime = mapBuy[index].buyTime;
            parentId = mapBuy[index].parentId;
        }
    }

    function getChildLength(address account) external view returns (uint32 res) {
        bytes32 parentId = keccak256(abi.encodePacked(Strings.addressToString(account)));
        res = mapChildNumber[parentId];
    }

    function getParentId(address account) external view returns (bytes32 res) {
        res = mapParentId[account];
    }

    function getUserBuyLength(address account) external view returns (uint32 res) {
        res = mapUserBuyLength[account];
    }

    function getUserBuyData(address account, uint32 uIndex) external view returns (
        bool res,
        uint256 usdtAmount,
        uint256 mmtAmount,
        uint256 buyTime,
        bytes32 parentId
    ) {
        if(mapUserBuyData[account][uIndex] > 0) {
            uint32 buyIndex = mapUserBuyData[account][uIndex];
            BuyData memory bd = mapBuy[buyIndex];
            res = true;
            usdtAmount = bd.usdtAmount;
            mmtAmount = bd.mmtAmount;
            buyTime = bd.buyTime;
            parentId = bd.parentId;
        }
    }

    function canClaimAiBot(address account) external view returns (bool res) {
        bytes32 parentId = keccak256(abi.encodePacked(Strings.addressToString(account)));
        return mapChildNumber[parentId] >= 100;
    }

    function aibotClaimed(address account) external view returns (bool res) {
        res = mapClaimAI[account].exists;
    }

    function claimaibot(uint8 claimType, bytes memory signature) external lock {
        string memory message = string(abi.encodePacked(Strings.addressToString(msg.sender),
                                                        Strings.uint256ToString(claimType)
                                                    ));
        require(_IsSignValid(message, signature), "invalid signature");
        require(claimType == 2, "param err");
        require(!mapClaimAI[msg.sender].exists, "u'd claimed ai");
        bytes32 parentId = keccak256(abi.encodePacked(Strings.addressToString(msg.sender)));
        require(mapChildNumber[parentId] >= 100, "not reach 100 child");
        uint256 mmtAmount = PairPrice(moduleMgr.getPairPrice()).cumulateMMTAmountOut(600*10**18);
        require(IERC20(auth.getFarmToken()).balanceOf(address(this)) >= mmtAmount, "insuff fund");
        mapClaimAI[msg.sender] = ClaimData(msg.sender, mmtAmount, true);
        require(IERC20(auth.getFarmToken()).transfer(msg.sender, mmtAmount));
    }

    function canClaimIPhone(address account) external view returns (bool res) {
        bytes32 parentId = keccak256(abi.encodePacked(Strings.addressToString(account)));
        return mapChildNumber[parentId] >= 200;
    }

    function iPhoneClaimed(address account) external view returns (bool res) {
        res = mapClaimIPhone[account].exists;
    }

    function claimIPhone(uint8 claimType, bytes memory signature) external lock {
        string memory message = string(abi.encodePacked(Strings.addressToString(msg.sender),
                                                        Strings.uint256ToString(claimType)
                                                    ));
        require(_IsSignValid(message, signature), "invalid signature");
        require(claimType == 2, "param err");
        require(!mapClaimIPhone[msg.sender].exists, "u'd claimed iPhone");
        bytes32 parentId = keccak256(abi.encodePacked(Strings.addressToString(msg.sender)));
        require(mapChildNumber[parentId] >= 200, "not reach 200 child");
        uint256 mmtAmount = PairPrice(moduleMgr.getPairPrice()).cumulateMMTAmountOut(700*10**18);
        require(IERC20(auth.getFarmToken()).balanceOf(address(this)) >= mmtAmount, "insuff fund");
        mapClaimIPhone[msg.sender] = ClaimData(msg.sender, mmtAmount, true);
        require(IERC20(auth.getFarmToken()).transfer(msg.sender, mmtAmount), "transfer err");
    }

    //set sorted prize, pos may be dulplicated but that is allright
    function setSortedPrize(address account, uint8 pos) external onlyOwner {
        require(account != address(0), "acc 0");
        require(pos >= 1 && pos <= 3, "pos err");
        require(mapUserSortedPrize[account] == 0, "acc'd set");
        uint8 index = mapUserSortedPrize[account];
        require(!mapSortedPrize[index].exists, "acc'd set 2");
        uint256 usdtAmount = 0;
        if(pos == 3) {
            usdtAmount = 100*10**18;
        } else if (pos == 2) {
            usdtAmount = 300*10**18;
        } else if (pos == 1) {
            usdtAmount = 500*10**18;
        }
        uint256 mmtAmount = PairPrice(moduleMgr.getPairPrice()).cumulateMMTAmountOut(usdtAmount);
        mapSortedPrize[++sortedPrizeIndex] = SortedPrize(account, pos, mmtAmount, false, true);
        mapUserSortedPrize[account] = sortedPrizeIndex;
    }

    function claimSortedPrize() external lock {
        require(mapUserSortedPrize[msg.sender] > 0, "u dont have prize");
        uint8 index = mapUserSortedPrize[msg.sender];
        SortedPrize storage sp = mapSortedPrize[index];
        require(sp.exists && !sp.claimed, "u'd claimed");
        require(IERC20(auth.getFarmToken()).balanceOf(address(this)) >= sp.amount, "insfuff fund");
        sp.claimed = true;
        require(IERC20(auth.getFarmToken()).transfer(msg.sender, sp.amount), "transfer err");
    }

    function getSortedPrizeLength() external view returns (uint8 res) {
        res = sortedPrizeIndex;
    }

    function getSortedPrizeData(uint8 index) external view returns (
        bool res,
        address account,
        uint8 pos,
        uint256 mmtAmount,
        bool claimed
    ) {
        if(mapSortedPrize[index].exists) {
            res = true;
            account = mapSortedPrize[index].account;
            pos = mapSortedPrize[index].pos;
            mmtAmount = mapSortedPrize[index].amount;
            claimed = mapSortedPrize[index].claimed;
        }
    }

    //get wheel prize count
    function getWheelTotalLength(address account) external view returns (uint32 res) {
        bytes32 parentId = keccak256(abi.encodePacked(Strings.addressToString(account)));
        res = mapWheelCount[parentId];
    }

    //claim wheel prize
    function claimWheelPrize(uint256 amount, uint32 withdrawId, uint32 wheelIndex, bytes memory signature) external lock {
        string memory message = string(abi.encodePacked(Strings.addressToString(msg.sender),
                                                        Strings.uint256ToString(amount),
                                                        Strings.uint256ToString(withdrawId),
                                                        Strings.uint256ToString(wheelIndex)
                                                    ));
        require(_IsSignValid(message, signature), "invalid signature");
        require(amount > 0 && wheelIndex > 0, "input err");
        require(mapUserClaimWheelPrize[msg.sender][wheelIndex] == 0, "u'd claimed");
        bytes32 parentId = keccak256(abi.encodePacked(Strings.addressToString(msg.sender)));
        require(wheelIndex <= mapWheelCount[parentId], "id err");
        uint256 usdtValue = PairPrice(moduleMgr.getPairPrice()).cumulateUSDTAmountOut(amount);
        require(usdtValue > 0, "PRICE ERR");
        require(!_triggerWithdrawLimit(msg.sender, usdtValue), "triggered limit");
        require(IERC20(auth.getFarmToken()).balanceOf(address(this)) >= amount, "insuff fund");
        _setWithdrawData(withdrawId, msg.sender, amount, usdtValue);
        mapClaimWheelPrize[++claimWheelPrizeLength] = ClaimWheelPrizeData(msg.sender, wheelIndex, amount, true); 
        mapUserClaimWheelPrize[msg.sender][wheelIndex] = claimWheelPrizeLength;
        require(IERC20(auth.getFarmToken()).transfer(msg.sender, amount), "transfer err");
    }

    function getClaimWheelPrizeLength() external view returns (uint32 res) {
        res = claimWheelPrizeLength;
    }

    function getClaimWheelPrizeData(uint32 index) external view returns (
        bool res,
        address account,
        uint256 wheelIndex,
        uint256 amount
    ) {
        if(mapClaimWheelPrize[index].exists) {
            res = true;
            account = mapClaimWheelPrize[index].account;
            wheelIndex = mapClaimWheelPrize[index].wheelIndex;
            amount = mapClaimWheelPrize[index].amount;
        }
    }

    function _IsSignValid(string memory message, bytes memory signature) internal view returns(bool) {
        return signer == recover(
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n",
                    Strings.toString(bytes(message).length),
                    message
                )
            ),
            signature
        );
    }

    function _triggerWithdrawLimit(address account, uint256 usdtValue) internal view returns (bool res) {
        if(usdtValue >= 5000*10**18) {
            res = true;
        } else {
            uint256 sum = 0;
            for(uint32 i = mapUserWithdrawLength[account]; i > 0; -- i) {
                uint32 withdrawId = mapUserWithdrawData[account][i];
                WithdrawData memory wd = mapWithdraw[withdrawId];
                if(block.timestamp <= wd.withdrawTime + 3600) {
                    sum += wd.usdtValue;
                    if(sum >= 10000*10**18) {
                        res = true;
                        break;
                    }
                } else {
                    break;
                }
            }
        }
    }

    function _setWithdrawData(uint32 withdrawId, address account, uint256 mmtAmount, uint256 usdtValue) internal {
        mapWithdraw[withdrawId] = WithdrawData(account, mmtAmount, usdtValue, block.timestamp, true);
        mapUserWithdrawLength[account] ++;
        mapUserWithdrawData[account][mapUserWithdrawLength[account]] = withdrawId;
    }
}