// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SafeMath.sol";
import "./Lockable.sol";
import "./MUTFarmAppData.sol";
import "./SystemSetting.sol";
import "./FarmLand.sol";
import "./Relationship.sol";
import "./AppWallet.sol";
import "./ModuleBase.sol";
import "./Coupon.sol";

contract MUTFarmApp is SafeMath, Lockable, ModuleBase {
    //events
    //seed bought event
    event seedBoughtEvent(address account, uint256 amount, uint time);
    //seed claimed event
    event seedClaimedEvent(address account, uint256 amount);
    //fomo reward claimed event
    event fomoRewardClaimedEvent(address account, uint256 amount);
    //claim shared profit event
    event sharedProfitClaimedEvent(address account, uint256 amount);

    constructor
    (
        address _systemAuthAddress, 
        address _moduleMgrAddress
    ) ModuleBase(_systemAuthAddress, _moduleMgrAddress) {
    }

    function sowSeed(
        uint256 withPaymentAmount,
        uint256 withSharedProfit,
        uint256 withFomoReward
    ) external lock {
        _sowSeed(msg.sender, ssAuth.getRoot(), withPaymentAmount, withSharedProfit, withFomoReward);
    }

    function sowSeedWithParent(
        address parent,
        uint256 withPaymentAmount,
        uint256 withSharedProfit,
        uint256 withFomoReward
    ) external lock {
        _sowSeed(msg.sender, parent, withPaymentAmount, withSharedProfit, withFomoReward);
    }

    function resowSeed(uint32 roundNumber) external lock {
        require(
            !MUTFarmAppData(moduleMgr.getModuleAppData()).isUserSeedExists(MUTFarmAppData(moduleMgr.getModuleAppData()).getCurrentRoundIndex(), msg.sender),
            "Seeds are not Matured 2"
        );
        (bool res, uint256 sowAmount, uint256 withdrawAmount) = MUTFarmAppData(moduleMgr.getModuleAppData()).resowSeed(msg.sender, roundNumber);
        if(res && withdrawAmount > 0) {
            require(AppWallet(moduleMgr.getModuleAppWallet()).transferToken(ssAuth.getPayment(), msg.sender, withdrawAmount), 
            "withdraw error while resow");
        }
        emit seedBoughtEvent(msg.sender, sowAmount, block.timestamp);
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
                    sub(sharedProfitTotal, sharedProfitClaimed),
                "Insufficient"
            );
            consumeAmount = add(consumeAmount, withSharedProfit);
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
            consumeAmount = add(consumeAmount, withFomoReward);
            useFomoReward = true;
        }

        uint256 discountPaymentAmount = withPaymentAmount;
        if (withPaymentAmount > 0) {
            (bool resCoupon, uint256 amountCoupon, uint256 usedAmountCoupon) = Coupon(moduleMgr.getModuleCoupon()).getCouponAmount(account);
            if(resCoupon && amountCoupon > usedAmountCoupon) {
                discountPaymentAmount = add(discountPaymentAmount, sub(amountCoupon, usedAmountCoupon));
            }
            require(ERC20(ssAuth.getPayment()).balanceOf(account) >= withPaymentAmount, "insufficient payment balance");
            require(ERC20(ssAuth.getPayment()).allowance(account, address(this)) >= withPaymentAmount, "not allowed to spend");
            require(ERC20(ssAuth.getPayment()).transferFrom(account, moduleMgr.getModuleAppWallet(), withPaymentAmount), "sow error");
            consumeAmount = add(consumeAmount, discountPaymentAmount);
            Coupon(moduleMgr.getModuleCoupon()).useCoupon(account);
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

        if (parent == address(parent) && parent != address(0)) {
            Relationship(moduleMgr.getModuleRelationship()).makeRelationship(parent, account);
        } else {
            Relationship(moduleMgr.getModuleRelationship()).makeRelationship(ssAuth.getRoot(), account);
        }
        bool dist = MUTFarmAppData(moduleMgr.getModuleAppData()).distributeMony(account, consumeAmount, withSharedProfit, withFomoReward);
        require(dist, "Buy error");
        if (useSharedProfit) {
            Relationship(moduleMgr.getModuleRelationship()).useSharedProfit(account, withSharedProfit);
        }
        if (useFomoReward) {
            MUTFarmAppData(moduleMgr.getModuleAppData()).increaseUserFomoRewardClaimed(account, withFomoReward);
        }
        emit seedBoughtEvent(account, consumeAmount, block.timestamp);
    }

    //claim collectable seed
    //if you miss or just forget to claim your collectable seed, the money will be transfered to an account by system after a while(fixed set to 1 month)
    function claimSeed(uint32 roundNumber) external lock {
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
            ERC20(ssAuth.getPayment()).balanceOf(moduleMgr.getModuleAppWallet()) >= amount,
            "Insufficient balance of Coin"
        );  
        require(AppWallet(moduleMgr.getModuleAppWallet()).transferToken(ssAuth.getPayment(), msg.sender, amount), "Failed to claim seed");
        MUTFarmAppData(moduleMgr.getModuleAppData()).increaseUserSeedClaimedAmount(roundNumber, msg.sender, amount);
        emit seedClaimedEvent(msg.sender, amount);
    }

    function transferFomoReward(uint32 roundNumber) external
    {
        _transferFomoReward(roundNumber);
    }

    //fomo reward
    //transfer rewards from pool
    function _transferFomoReward(uint32 roundNumber) internal {
        MUTFarmAppData(moduleMgr.getModuleAppData()).transferFomoReward(roundNumber);
    }

    //claim my reward
    //if you miss or just forget to claim your reward, the money will be transfered to an account by system after a while(fixed set to 1 month)
    function claimFomoReward(uint256 amount) external lock {
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
            ERC20(ssAuth.getPayment()).balanceOf(moduleMgr.getModuleAppWallet()) >= amount,
            "Insufficient balance in this contract for reward claiming"
        );
        (bool transfered) = AppWallet(moduleMgr.getModuleAppWallet()).transferToken(ssAuth.getPayment(), to, amount);
        require(transfered, "Claiming reward error");
        MUTFarmAppData(moduleMgr.getModuleAppData()).increaseFomoRewardClaimedAmount(account, amount);
        emit fomoRewardClaimedEvent(account, amount);
    }

    //claim shared profit
    function claimSharedProfit(uint256 amount) external lock {
        require(msg.sender != address(0), "can not be ZERO address");
        (bool res, uint256 totalAmount, uint256 claimedAmount) = Relationship(moduleMgr.getModuleRelationship()).getSharedProfit(msg.sender);
        require(res, "shared profit not exists");
        require(
            totalAmount >= add(amount, claimedAmount),
            "insufficient amount to be claimed"
        );
        require(
            ERC20(ssAuth.getPayment()).balanceOf(moduleMgr.getModuleAppWallet()) >= amount,
            "Insufficient balance in contract"
        );
        require(AppWallet(moduleMgr.getModuleAppWallet()).transferToken(ssAuth.getPayment(), msg.sender, amount), "claim shared profit error");
        Relationship(moduleMgr.getModuleRelationship()).increaseClaimedSharedProfit(msg.sender, amount);
        emit sharedProfitClaimedEvent(msg.sender, amount);
    }
}