// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ModuleBase.sol";
import "./Lockable.sol";
import "./AppWallet.sol";
import "./NFTFarmLand.sol";
import "./Relationship.sol";
import "./RelationshipData.sol";
import "./PairPrice.sol";
import "./SystemSetting.sol";
import "./RewardAccount.sol";

contract LandBureau is ModuleBase, Lockable {
    uint256 private constant group_number = 10;

    bool private singleLand = true;

    struct RoundData {
        uint256 roundIndex;
        uint256 inCount; //people number of round
    }

    struct UserData {
        uint256 roundIndex;
        uint256 position;
        address account;
        uint256 amount;
        uint256 price;
        uint256 rewardAmount;
        uint256 rewardInUsdt;
        uint256 farmLandTokenId;
        uint32 ssIndex;
    }

    uint256 roundIndex;

    //mapping for round data
    //key: round index => RoundData
    mapping(uint256 => RoundData) mapRound;

    //mapping for user list
    //key: round index => (position index => UserData)
    //position index : from 1 to 10
    mapping(uint256 => mapping(uint256 => UserData)) mapUserList;

    //mapping for user data of round
    //key: account => (round index => position)
    mapping(address => mapping(uint256 => uint256)) mapUserData;

    //mapping for user bingo
    //key: roundIndex => (position index => true)
    mapping(uint256 => mapping(uint256 => bool)) mapRoundBingo;

    event grouponSuccess(address account, uint256 roundNumber, uint256 position, uint256 amount, uint256 usdtPrice, uint time);
    event grouponComplete(uint256 roundNumber);

    constructor(address _auth, address _moduleMgr)
        ModuleBase(_auth, _moduleMgr)
    {}

    function setSingleLand(bool _single) external onlyOwner {
        singleLand = _single;
    }

    function getSingleLand() external view returns (bool res) {
        res = singleLand;
    }

    function _newRound() internal {
        ++roundIndex;
        mapRound[roundIndex] = RoundData(roundIndex, 0);
    }

    function cumulateLandPrice() external view returns (uint256 mutAmount) {
        (mutAmount, ) = _cumulateLandPrice();
    }

    function _cumulateLandPrice()
        internal
        view
        returns (uint256 mutAmount, uint256 landPrice)
    {
        (bool res, uint256 _landPrice) = NFTFarmLand(moduleMgr.getFarmLand())
            .getLandPriceByIndex(0);
        require(res && _landPrice > 0, "price not set");
        landPrice = _landPrice*10**ERC20(auth.getUSDTToken()).decimals();

        //折算为100USDT价值的MUT数额
        mutAmount = PairPrice(moduleMgr.getPairPrice()).cumulateMUTAmountOut(landPrice);
    }

    function getMaxRoundIndex() external view returns (uint256 res) {
        res = roundIndex;
    }

    //group purchase
    function grouponLand(uint256 amount, address parent) external lock {

        if(singleLand) {
           require(ERC721(moduleMgr.getFarmLand()).balanceOf(msg.sender) == 0, "u'd have NFT land"); 
        }

        //go to next round if full in current round
        if (mapRound[roundIndex].inCount >= group_number || 0 == roundIndex) {
            _newRound();
        }

        require(
            mapUserData[msg.sender][roundIndex] == 0,
            "u r in this round"
        );
        //折算为100USDT价值的MUT数额,价格可浮动0.5%
        (uint256 needMUTAmount, uint256 landPrice) = _cumulateLandPrice();
        require(amount >= needMUTAmount - needMUTAmount * SystemSetting(moduleMgr.getSystemSetting()).getPriceTolerance(0) / 1000, 
        "amount too small");

        require(
            ERC20(auth.getFarmToken()).balanceOf(msg.sender) >= needMUTAmount,
            "insufficient balance"
        );
        require(
            ERC20(auth.getFarmToken()).allowance(msg.sender, address(this)) >=
                needMUTAmount,
            "not approved"
        );
        require(
            ERC20(auth.getFarmToken()).transferFrom(
                msg.sender,
                moduleMgr.getAppWallet(),
                needMUTAmount
            ),
            "group on error 1"
        );

        //make relationship
        address _parent = parent == address(0) ? auth.getRoot() : parent;
        Relationship(moduleMgr.getRelationship()).makeRelationship(
            _parent,
            msg.sender
        );

        //purchase
        _grouponLand(msg.sender, needMUTAmount, landPrice);
    }

    function _grouponLand(
        address account,
        uint256 mutAmount,
        uint256 landPrice
    ) internal {
        // RoundData storage rd = mapRound[roundIndex];
        // rd.inCount++;
        mapRound[roundIndex].inCount ++;

        mapUserList[roundIndex][mapRound[roundIndex].inCount] = UserData(
            roundIndex,
            mapRound[roundIndex].inCount,
            account,
            mutAmount,
            landPrice,
            0,
            0,
            0,
            SystemSetting(moduleMgr.getSystemSetting()).getCurrentSettingIndex()
        );
        mapUserData[account][roundIndex] = mapRound[roundIndex].inCount;

        emit grouponSuccess(account, roundIndex, mapRound[roundIndex].inCount, mutAmount, landPrice, block.timestamp);

        if (mapRound[roundIndex].inCount == group_number) {
            //random select 3 user to win
            uint32 i = 1;
            uint256[] memory positions = new uint256[](group_number);
            for (i = 1; i <= group_number; ++i) {
                positions[i - 1] = i;
            }
            (uint256 a, uint256 b, uint256 c) = _select3Targets(
                positions,
                msg.sender,
                roundIndex
            );
            mapRoundBingo[roundIndex][a] = true;
            mapRoundBingo[roundIndex][b] = true;
            mapRoundBingo[roundIndex][c] = true;

            //mint NFT land to bingo user
            uint256 a_tokenId = NFTFarmLand(moduleMgr.getFarmLand()).mintLand(
                landPrice / (10 ** ERC20(auth.getFarmToken()).decimals()),
                mapUserList[roundIndex][a].account
            );
            mapUserList[roundIndex][a].farmLandTokenId = a_tokenId;

            uint256 b_tokenId = NFTFarmLand(moduleMgr.getFarmLand()).mintLand(
                landPrice / (10 ** ERC20(auth.getFarmToken()).decimals()),
                mapUserList[roundIndex][b].account
            );
            mapUserList[roundIndex][b].farmLandTokenId = b_tokenId;
            
            uint256 c_tokenId = NFTFarmLand(moduleMgr.getFarmLand()).mintLand(
                landPrice / (10 ** ERC20(auth.getFarmToken()).decimals()),
                mapUserList[roundIndex][c].account
            );
            mapUserList[roundIndex][c].farmLandTokenId = c_tokenId;

            //shared reward and refund 
            for (i = 1; i <= group_number; ++i) {
                UserData memory ud = mapUserList[roundIndex][i];

                (bool hasParent, address parentAddress) = RelationshipData(moduleMgr.getRelationshipData()).getParent(ud.account);

                //shared reward
                uint256 rewardAmount = 0;
                uint256 rewardInUsdt = 0;
                if (hasParent) {
                    uint256 rewardType;
                    if (
                        ud.account == mapUserList[roundIndex][a].account ||
                        ud.account == mapUserList[roundIndex][b].account ||
                        ud.account == mapUserList[roundIndex][c].account
                    ) {
                        rewardInUsdt = ud.price * SystemSetting(moduleMgr.getSystemSetting()).getSharedBingoReward(0) / 1000;
                        rewardAmount = PairPrice(moduleMgr.getPairPrice()).cumulateMUTAmountOut(rewardInUsdt);
                        rewardType = 2;                        
                    } else {
                        rewardInUsdt = ud.price * SystemSetting(moduleMgr.getSystemSetting()).getSharedEmptyReward(0) / 1000;
                        rewardAmount = PairPrice(moduleMgr.getPairPrice()).cumulateMUTAmountOut(rewardInUsdt);
                        rewardType = 3;
                    }

                    UserData storage udInUser = mapUserList[roundIndex][mapUserData[parentAddress][roundIndex]];
                    udInUser.rewardAmount += rewardAmount;
                    udInUser.rewardInUsdt += rewardInUsdt;
                    
                    RewardAccount(moduleMgr.getRewardAccount()).addReward(parentAddress, rewardType, rewardAmount);
                }

                //refund and get 10% lost consolation reward
                if (
                    ud.account != mapUserList[roundIndex][a].account &&
                    ud.account != mapUserList[roundIndex][b].account &&
                    ud.account != mapUserList[roundIndex][c].account
                ) {
                    rewardInUsdt = ud.price + (ud.price * SystemSetting(moduleMgr.getSystemSetting()).getLoseRefund(0)) / 1000;
                    rewardAmount = PairPrice(moduleMgr.getPairPrice()).cumulateMUTAmountOut(rewardInUsdt);
                    UserData storage udInUser = mapUserList[roundIndex][mapUserData[ud.account][roundIndex]];
                    udInUser.rewardAmount += rewardAmount;
                    udInUser.rewardInUsdt += rewardInUsdt;
                    RewardAccount(moduleMgr.getRewardAccount()).addReward(ud.account, 1, rewardAmount);
                }

                if(ud.account == account) {
                    rewardInUsdt = ud.price * SystemSetting(moduleMgr.getSystemSetting()).getOpenerReward(0)/1000;
                    rewardAmount = PairPrice(moduleMgr.getPairPrice()).cumulateMUTAmountOut(rewardInUsdt);// 5% valued of reward
                    UserData storage udInUser = mapUserList[roundIndex][mapUserData[ud.account][roundIndex]];
                    udInUser.rewardAmount += rewardAmount;
                    udInUser.rewardInUsdt += rewardInUsdt;
                    RewardAccount(moduleMgr.getRewardAccount()).addReward(ud.account, 4, rewardAmount);
                }

                emit grouponComplete(roundIndex);
            }
        }
    }

    function _getParentSharedAddress(address child)
        internal
        view
        returns (bool res, address parent)
    {
        for (uint32 i = 1; i <= group_number; ++i) {
            UserData memory ud = mapUserList[roundIndex][i];
            (bool get, address tempParent) = RelationshipData(
                moduleMgr.getRelationshipData()
            ).getParent(child);
            if (get && tempParent == ud.account) {
                res = true;
                parent = ud.account;
            }
        }
    }

    function _select3Targets(
        uint256[] memory arr,
        address sender,
        uint256 roundNumber
    )
        internal
        view
        returns (
            uint256 a,
            uint256 b,
            uint256 c
        )
    {
        uint8 i = 0;
        do {
            uint256[] memory temp = new uint256[](arr.length - i);
            uint8 k = 0;
            for (uint8 j = 0; j < arr.length; ++j) {
                if (arr[j] != a && arr[j] != b && arr[j] != c) {
                    temp[k] = arr[j];
                    ++k;
                }
            }
            uint256 selected = _randomSelectPosition(temp, sender, roundNumber);
            if (i == 0) a = selected;
            else if (i == 1) b = selected;
            else c = selected;

            ++i;
        } while (i < 3);
    }

    function _randomSelectPosition(
        uint256[] memory arr,
        address lastInAccount,
        uint256 roundNumber
    ) internal view returns (uint256 res) {
        uint256 len = arr.length;
        uint256 randomSeed = uint256(
            keccak256(
                abi.encodePacked(
                    block.difficulty,
                    block.timestamp,
                    lastInAccount,
                    roundNumber,
                    len
                )
            )
        );
        uint256 min = 0;
        uint256 max = len - 1;
        uint256 _index = (randomSeed % (max - min + 1)) + min;
        res = arr[_index];
    }

    //获取轮次团购信息列表
    function getRoundGrouponAddress(uint256 roundNumber) 
        external
        view 
        returns (
            bool res,
            bool end,
            address [] memory addresses,
            bool [] memory bingos
        )
    {
        if(mapRound[roundNumber].inCount > 0) {
            res = true;
            addresses = new address[](mapRound[roundNumber].inCount);
            bingos = new bool[](mapRound[roundNumber].inCount);
            for(uint256 i = 1; i <= mapRound[roundNumber].inCount; ++i) {
                UserData memory ud = mapUserList[roundNumber][i];
                addresses[i-1] = ud.account; 
                if(mapRoundBingo[roundNumber][i]) {
                    bingos[i-1] = true;
                } else {
                    bingos[i-1] = false;
                }
            }
            end = mapRound[roundNumber].inCount == group_number;
        }
    }

    function getUserGrouponData(uint256 roundNumber, address account) 
        external 
        view 
        returns (
            bool res,
            uint256 position,
            uint256 amount,
            uint256 price,
            bool end,
            bool bingo,
            uint256 rewardAmount,
            uint256 rewardInUsdt,
            uint256 farmLandTokenId,
            uint32 ssIndex
        ) {
        if(mapUserData[account][roundNumber] > 0) {
            res = true;
            position = mapUserList[roundNumber][mapUserData[account][roundNumber]].position;
            amount = mapUserList[roundNumber][mapUserData[account][roundNumber]].amount;
            price = mapUserList[roundNumber][mapUserData[account][roundNumber]].price;
            farmLandTokenId = mapUserList[roundNumber][mapUserData[account][roundNumber]].farmLandTokenId;
            ssIndex = mapUserList[roundNumber][mapUserData[account][roundNumber]].ssIndex;
            (end, bingo, rewardAmount, rewardInUsdt) = _checkGroupon(roundNumber, account);
        }
    }

    function getGrouponNumber(uint256 roundNumber) external view returns (uint256 res) {
        res = mapRound[roundNumber].inCount;
    }

    function getGrouponData(uint256 roundNumber, uint256 _position)
        external
        view 
        returns (
            bool res,
            address account,
            uint256 position,
            uint256 amount,
            uint256 price,
            bool end,
            bool bingo,
            uint256 rewardAmount,
            uint256 rewardInUsdt,
            uint256 farmLandTokenId,
            uint32 ssIndex
        ) 
    {
        UserData memory ud = mapUserList[roundNumber][_position];
        if(ud.position > 0) {
            res = true;
            account = ud.account;
            position = ud.position;
            amount = ud.amount;
            price = ud.price;
            farmLandTokenId = ud.farmLandTokenId;
            ssIndex = ud.ssIndex;
            (end, bingo, rewardAmount, rewardInUsdt) = _checkGroupon(roundNumber, ud.account);
        }
    }

    function checkGroupon(uint256 roundNumber, address account)
        external
        view
        returns (
            bool end,
            bool bingo,
            uint256 rewardAmount,
            uint256 rewardInUsdt
        )
    {
        (end, bingo, rewardAmount, rewardInUsdt) = _checkGroupon(
            roundNumber,
            account
        );
    }

    function _checkGroupon(uint256 roundNumber, address account)
        internal
        view
        returns (
            bool end,
            bool bingo,
            uint256 rewardAmount,
            uint256 rewardInUsdt
        )
    {
        if (mapRound[roundNumber].inCount == 10) {
            end = true;
            UserData memory ud = mapUserList[roundNumber][mapUserData[account][roundNumber]];
            if (ud.position > 0) {
                if (mapRoundBingo[roundNumber][ud.position]) {
                    bingo = true;
                }
                rewardAmount = ud.rewardAmount;
                rewardInUsdt = ud.rewardInUsdt;
            }
        }
    }
}