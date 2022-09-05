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

contract LandBureau is ModuleBase, Lockable {
    uint256 private constant group_number = 10;

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
        bool rewardClaimed;
        uint256 farmLandTokenId;
        bool exists;
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

    constructor(address _auth, address _moduleMgr)
        ModuleBase(_auth, _moduleMgr)
    {}

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
        landPrice = _landPrice;

        //折算为100USDT价值的MUT数额
        mutAmount = PairPrice(moduleMgr.getPairPrice()).cumulateMUTAmountOut(
            landPrice * 10**ERC20(auth.getUSDTToken()).decimals()
        );
    }

    function getMaxRoundIndex() external view returns (uint256 res) {
        res = roundIndex;
    }

    //group purchase
    function grouponLand(uint256 amount, address parent) external lock {

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
        Relationship(moduleMgr.getRelationship()).makeRelationship(
            parent,
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
        RoundData storage rd = mapRound[roundIndex];
        rd.inCount++;

        UserData memory userData = UserData(
            roundIndex,
            rd.inCount,
            account,
            mutAmount,
            landPrice,
            0,
            false,
            0,
            true
        );
        mapUserList[roundIndex][rd.inCount] = userData;
        mapUserData[account][roundIndex] = rd.inCount;

        if (rd.inCount == group_number) {
            //random select 3 user to win
            uint256[] memory positions = new uint256[](group_number);
            for (uint32 i = 1; i <= group_number; ++i) {
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
                landPrice,
                mapUserList[roundIndex][a].account
            );
            mapUserList[roundIndex][a].farmLandTokenId = a_tokenId;

            uint256 b_tokenId = NFTFarmLand(moduleMgr.getFarmLand()).mintLand(
                landPrice,
                mapUserList[roundIndex][b].account
            );
            mapUserList[roundIndex][b].farmLandTokenId = b_tokenId;
            
            uint256 c_tokenId = NFTFarmLand(moduleMgr.getFarmLand()).mintLand(
                landPrice,
                mapUserList[roundIndex][c].account
            );
            mapUserList[roundIndex][c].farmLandTokenId = c_tokenId;

            //shared reward
            for (uint32 i = 1; i <= group_number; ++i) {
                UserData memory ud = mapUserList[roundIndex][i];
                (
                    bool isParent,
                    address parentAddress
                ) = _getParentSharedAddress(ud.account);
                if (isParent) {
                    uint256 rewardShared = 0;
                    if (
                        ud.account == mapUserList[roundIndex][a].account ||
                        ud.account == mapUserList[roundIndex][b].account ||
                        ud.account == mapUserList[roundIndex][c].account
                    ) {
                        rewardShared =
                            (ud.amount *
                                SystemSetting(moduleMgr.getSystemSetting())
                                    .getSharedBingoReward(0)) /
                            1000;
                    } else {
                        rewardShared =
                            (ud.amount *
                                SystemSetting(moduleMgr.getSystemSetting())
                                    .getSharedEmptyReward(0)) /
                            1000;
                    }

                    UserData storage udInUser = mapUserList[roundIndex][mapUserData[parentAddress][roundIndex]];
                    udInUser.rewardAmount += rewardShared;
                }

                //refund and get 10% lost consolation reward
                if (
                    ud.account != mapUserList[roundIndex][a].account &&
                    ud.account != mapUserList[roundIndex][b].account &&
                    ud.account != mapUserList[roundIndex][c].account
                ) {
                    uint256 refund10 = ud.amount + (ud.amount *
                        SystemSetting(moduleMgr.getSystemSetting())
                            .getLoseRefund(0)) / 1000;
                    UserData storage udInUser = mapUserList[roundIndex][mapUserData[ud.account][roundIndex]];
                    udInUser.rewardAmount += refund10;
                }
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
            bool rewardClaimed,
            uint256 farmLandTokenId
        ) {
        if(mapUserData[account][roundNumber] > 0) {
            UserData memory ud = mapUserList[roundNumber][mapUserData[account][roundNumber]];
            res = true;
            position = ud.position;
            amount = ud.amount;
            price = ud.price;
            farmLandTokenId = ud.farmLandTokenId;
            (end, bingo, rewardAmount, rewardClaimed) = _checkGroupon(roundNumber, account);
        }
    }

    function checkGroupon(uint256 roundNumber, address account)
        external
        view
        returns (
            bool end,
            bool bingo,
            uint256 rewardAmount,
            bool rewardClaimed
        )
    {
        (end, bingo, rewardAmount, rewardClaimed) = _checkGroupon(
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
            bool rewardClaimed
        )
    {
        if (mapRound[roundNumber].inCount == 10) {
            end = true;
            UserData memory ud = mapUserList[roundNumber][mapUserData[account][roundNumber]];
            if (ud.exists) {
                if (mapRoundBingo[roundNumber][ud.position]) {
                    bingo = true;
                }
                rewardAmount = ud.rewardAmount;
                rewardClaimed = ud.rewardClaimed;
            }
        }
    }

    function claimReward(uint256 roundNumber) external {
        (
            bool end,
            bool bingo,
            uint256 rewardAmount,
            bool rewardClaimed
        ) = _checkGroupon(roundNumber, msg.sender);
        if (end && !bingo && !rewardClaimed) {
            UserData storage ud = mapUserList[roundNumber][mapUserData[msg.sender][roundNumber]];
            AppWallet(moduleMgr.getAppWallet()).transferToken(
                auth.getFarmToken(),
                msg.sender,
                rewardAmount
            );
            ud.rewardClaimed = true;
        }
    }
}