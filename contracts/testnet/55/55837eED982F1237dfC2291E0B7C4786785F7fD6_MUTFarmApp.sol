// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./MUTFarmAppData.sol";
import "./SystemAuth.sol";
import "./SystemSetting.sol";
import "./FarmLand.sol";
import "./Relationship.sol";
import "./History.sol";
import "./AppWallet.sol";
import "./ModuleMgr.sol";

contract MUTFarmApp {
    //events
    //seed bought event
    event seedBoughtEvent(address account, uint256 amount, uint time);
    //seed sold event
    event seedSoldEvent(address account, uint256 amount, uint time);
    //seed claimed event
    event seedClaimedEvent(address account, uint256 amount);
    //fomo reward claimed event
    event fomoRewardClaimedEvent(address account, uint256 amount);
    //claim shared profit event
    event sharedProfitClaimedEvent(address account, uint256 amount);
    SystemAuth ssAuth;
    ModuleMgr moduleMgr;
    constructor
    (
        address _systemAuthAddress, 
        address _moduleMgrAddress
    ) {
        ssAuth = SystemAuth(_systemAuthAddress);
        moduleMgr = ModuleMgr(_moduleMgrAddress);
    }

    function setSystemAuth(address addr) external {
        require(msg.sender == ssAuth.getOwner() && addr != ssAuth.getOwner(), "owner only");
        ssAuth = SystemAuth(addr);
    }

    function setModuleMgr(address addr) external {
        require(msg.sender == ssAuth.getOwner(), "owner only");
        moduleMgr = ModuleMgr(addr);
    }

    function sowSeed(
        uint256 withPaymentAmount,
        uint256 withSharedProfit,
        uint256 withFomoReward
    ) external {
        _sowSeed(msg.sender, ssAuth.getRoot(), withPaymentAmount, withSharedProfit, withFomoReward);
    }

    function sowSeedWithParent(
        address parent,
        uint256 withPaymentAmount,
        uint256 withSharedProfit,
        uint256 withFomoReward
    ) external {
        _sowSeed(msg.sender, parent, withPaymentAmount, withSharedProfit, withFomoReward);
    }

    function _sowSeed(address account, address parent, uint256 withPaymentAmount, uint256 withSharedProfit, uint256 withFomoReward) internal {
        require(
            account != address(0),
            "ZERO address"
        );
        require(
            FarmLand(moduleMgr.getModuleFarmLand()).haveLand(account),
            "no land"
        );
        uint256 consumeAmount = 0;
        bool useSharedProfit = false;
        if (withSharedProfit > 0) {
            (
                bool resShared,
                uint256 sharedProfitTotal,
                uint256 sharedProfitClaimed
            ) = Relationship(moduleMgr.getModuleRelationship()).getSharedProfit(account);
            require(
                resShared &&
                    withSharedProfit <=
                    (sharedProfitTotal - sharedProfitClaimed),
                "Insufficient"
            );
            consumeAmount += withSharedProfit;
            useSharedProfit = true;
        }
        bool useFomoReward = false;
        if (withFomoReward > 0) {
            (
                bool available,
                uint256 availableFomoReward
            ) = MUTFarmAppData(moduleMgr.getModuleAppData()).fomoRewardClaimable(account);
            require(
                available && withFomoReward <= availableFomoReward,
                "Insufficient"
            );
            consumeAmount += withFomoReward;
            useFomoReward = true;
        }
        if (withPaymentAmount > 0) {
            require(ERC20(ssAuth.getPayment()).balanceOf(account) >= withPaymentAmount, "insufficient payment balance");
            require(ERC20(ssAuth.getPayment()).allowance(account, address(this)) >= withPaymentAmount, "not allowed to spend");
            consumeAmount += withPaymentAmount;
        }
        require(consumeAmount >= SystemSetting(moduleMgr.getModuleSystemSetting()).getMinAmountBuy(0), "too small amount");
        require(consumeAmount <= SystemSetting(moduleMgr.getModuleSystemSetting()).getMaxAmountBuy(0), "too much amount");
        if(MUTFarmAppData(moduleMgr.getModuleAppData()).getCurrentRoundIndex() > 0 && MUTFarmAppData(moduleMgr.getModuleAppData()).getQueueFirstIndex() > 0) {
            _transferFomoReward(MUTFarmAppData(moduleMgr.getModuleAppData()).getCurrentRoundIndex());
        }
        if (MUTFarmAppData(moduleMgr.getModuleAppData()).isRoundStop(MUTFarmAppData(moduleMgr.getModuleAppData()).getCurrentRoundIndex())|| 
            MUTFarmAppData(moduleMgr.getModuleAppData()).getCurrentRoundIndex() == 0
        ) {
            MUTFarmAppData(moduleMgr.getModuleAppData()).createNewRound(consumeAmount);
        } else {
            MUTFarmAppData(moduleMgr.getModuleAppData()).updateRoundDataInAmount(consumeAmount);
        }
        require(
            !MUTFarmAppData(moduleMgr.getModuleAppData()).isUserSeedExists(MUTFarmAppData(moduleMgr.getModuleAppData()).getCurrentRoundIndex(), account),
            "Seeds are not Matured"
        );
        require(ERC20(ssAuth.getPayment()).transferFrom(account, ssAuth.getAppWallet(), withPaymentAmount), "sow error");
        if (parent == address(parent) && parent != address(0)) {
            Relationship(moduleMgr.getModuleRelationship()).makeRelationship(parent, account);
        } else {
            Relationship(moduleMgr.getModuleRelationship()).makeRelationship(ssAuth.getRoot(), account);
        }
        require(_distributeMony(account, consumeAmount, withSharedProfit, withFomoReward), "Buy error");
        if (useSharedProfit) {
            Relationship(moduleMgr.getModuleRelationship()).useSharedProfit(account, withSharedProfit);
        }
        if (useFomoReward) {
            MUTFarmAppData(moduleMgr.getModuleAppData()).increaseUserFomoRewardClaimed(account, withFomoReward);
        }
        emit seedBoughtEvent(account, consumeAmount, block.timestamp);
    }

    //distribute money
    function _distributeMony(address account, uint256 amount, uint256 withSharedProfit, uint256 withFomoReward)
        internal
        returns (bool res)
    {

        //share profit upstream
        uint256 sharedAmount = Relationship(moduleMgr.getModuleRelationship()).sharedProfit(account, amount);
        //deposit charity
        uint256 charity = (amount * SystemSetting(moduleMgr.getModuleSystemSetting()).getCharityPercent(0)) / 1000;
        MUTFarmAppData(moduleMgr.getModuleAppData()).increaseCharityAmount(charity);
        //deposit sysFund
        uint256 forSysFund = (amount * SystemSetting(moduleMgr.getModuleSystemSetting()).getSysFundPercent(0)) / 1000;
        MUTFarmAppData(moduleMgr.getModuleAppData()).increaseSysFundAmount(forSysFund);
        //deposit fomoPool
        uint256 forFomoPool = (amount * SystemSetting(moduleMgr.getModuleSystemSetting()).getFomoPoolPercent(0)) / 1000;
        MUTFarmAppData(moduleMgr.getModuleAppData()).increaseFomoPoolAmount(forFomoPool);
        uint256 paddingAmount = amount - (sharedAmount + forSysFund + forFomoPool + charity);
        while (true) {
            if (paddingAmount == 0) {
                break;
            }

            if(!MUTFarmAppData(moduleMgr.getModuleAppData()).isFirstSeedDataExists()) {
                break;
            }
            uint256 firstNodeSeedAmount = MUTFarmAppData(moduleMgr.getModuleAppData()).getFirstNodeSeedAmount();
            if(firstNodeSeedAmount == 0) {
                MUTFarmAppData(moduleMgr.getModuleAppData()).increaseQueueFirstIndex(1);
                continue;
            }
            uint256 userSellAmount = 0;
            if (paddingAmount >= firstNodeSeedAmount) {
                userSellAmount = firstNodeSeedAmount;
            } else {
                userSellAmount = paddingAmount;
            }
            bool sold = _sellUserSeed(MUTFarmAppData(moduleMgr.getModuleAppData()).getFirstNodeSeedAccount(), userSellAmount);
            if (sold) {
                paddingAmount -= userSellAmount;
                MUTFarmAppData(moduleMgr.getModuleAppData()).decreaseTotalQueueAmount(userSellAmount);
                MUTFarmAppData(moduleMgr.getModuleAppData()).increaseRoundDataOutAmount(userSellAmount);
            } else {
                revert("Error");
            }
        }
        uint256 newAmount = amount + (amount * SystemSetting(moduleMgr.getModuleSystemSetting()).getCycleYieldsPercent(0)) / 1000;
        MUTFarmAppData(moduleMgr.getModuleAppData()).enqueue(account, newAmount, withSharedProfit, withFomoReward);
        MUTFarmAppData(moduleMgr.getModuleAppData()).createNewUserSeedData(account, newAmount);
        MUTFarmAppData(moduleMgr.getModuleAppData()).increaseTotalQueueAmount(newAmount);
        res = true;
    }

    function _sellUserSeed(address account, uint256 amount)
        internal
        returns (bool res)
    {
        require(MUTFarmAppData(moduleMgr.getModuleAppData()).isUserSeedExists(MUTFarmAppData(moduleMgr.getModuleAppData()).getCurrentRoundIndex(), account), "You seed not exists");
        MUTFarmAppData(moduleMgr.getModuleAppData()).sellUserSeed(account, amount);
        History(moduleMgr.getModuleHistory()).addMatureRecord(account, amount);
        emit seedSoldEvent(account, amount, block.timestamp);
        res = true;
    }

    //claim collectable seed
    //if you miss or just forget to claim your collectable seed, the money will be transfered to an account by system after a while(fixed set to 1 month)
    function claimSeed(uint256 roundNumber) external {
        require(
            msg.sender != address(0),
            "ZERO address"
        );
        require(
            MUTFarmAppData(moduleMgr.getModuleAppData()).isUserSeedExists(roundNumber, msg.sender),
            "Your seeds not exists"
        );
        (bool collectable, uint256 amount) = MUTFarmAppData(moduleMgr.getModuleAppData()).checkCollectable(
            roundNumber,
            msg.sender
        );
        require(collectable, "Seeds uncollectable");
        require(
            ERC20(ssAuth.getPayment()).balanceOf(ssAuth.getAppWallet()) >= amount,
            "Insufficient balance of Coin"
        );  
        require(AppWallet(moduleMgr.getModuleAppWallet()).transferToken(ssAuth.getPayment(), msg.sender, amount), "Failed to claim seed");
        MUTFarmAppData(moduleMgr.getModuleAppData()).increaseUserSeedClaimedAmount(roundNumber, msg.sender, amount);
        History(moduleMgr.getModuleHistory()).addClaimRecord(msg.sender, amount);
        emit seedClaimedEvent(msg.sender, amount);
    }

    function transferFomoReward(uint256 roundNumber) external
    {
        _transferFomoReward(roundNumber);
    }

    //fomo reward
    //transfer rewards from pool
    function _transferFomoReward(uint256 roundNumber) internal {
        MUTFarmAppData(moduleMgr.getModuleAppData()).transferFomoReward(roundNumber);
    }

    //claim my reward
    //if you miss or just forget to claim your reward, the money will be transfered to an account by system after a while(fixed set to 1 month)
    function claimFomoReward(uint256 amount) external {
        _claimFomoReward(msg.sender, amount, msg.sender);
    }

    function _claimFomoReward(address account, uint256 amount, address to) internal {
        require(address(0) != account, "ZERO address forbidden");
        require(account != ssAuth.getOwner(), "owner can not claim fomo rewards");
        require(
            MUTFarmAppData(moduleMgr.getModuleAppData()).fomoRewardClaimedDataExists(account),
            "fomo rewards unavailable for you"
        );
        (bool resClaimable, uint256 claimableAmount) = MUTFarmAppData(moduleMgr.getModuleAppData()).fomoRewardClaimable(account);
        require(resClaimable, "not claimable");
        require(claimableAmount >= amount, "insufficient amount to claim");
        require(
            ERC20(ssAuth.getPayment()).balanceOf(ssAuth.getAppWallet()) >= amount,
            "Insufficient balance in this contract for reward claiming"
        );
        (bool transfered) = AppWallet(moduleMgr.getModuleAppWallet()).transferToken(ssAuth.getPayment(), to, amount);
        require(transfered, "Claiming reward error");
        MUTFarmAppData(moduleMgr.getModuleAppData()).increaseFomoRewardClaimedAmount(account, amount);
        emit fomoRewardClaimedEvent(account, amount);
    }

    //claim shared profit
    function claimSharedProfit(uint256 amount) external {
        require(msg.sender != ssAuth.getOwner(), "can not be owner");
        require(msg.sender != address(0), "can not be ZERO address");
        (bool res, uint256 totalAmount, uint256 claimedAmount) = Relationship(moduleMgr.getModuleRelationship()).getSharedProfit(msg.sender);
        require(res, "shared profit not exists");
        require(
            totalAmount >= amount + claimedAmount,
            "insufficient amount to be claimed"
        );
        require(
            ERC20(ssAuth.getPayment()).balanceOf(ssAuth.getAppWallet()) >= amount,
            "Insufficient balance in contract"
        );
        require(AppWallet(moduleMgr.getModuleAppWallet()).transferToken(ssAuth.getPayment(), msg.sender, amount), "claim shared profit error");
        Relationship(moduleMgr.getModuleRelationship()).increaseClaimedSharedProfit(msg.sender, amount);
        emit sharedProfitClaimedEvent(msg.sender, amount);
    }
}