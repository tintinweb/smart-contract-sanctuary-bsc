// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./MUTFarmAppData.sol";
import "./SystemAuth.sol";
import "./SystemSetting.sol";
import "./FarmLand.sol";
import "./Relationship.sol";
import "./History.sol";
import "./AppWallet.sol";

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

    SystemSetting ssSetting;
    SystemAuth ssAuth;
    FarmLand farmLand;
    Relationship relationship;
    History history;
    MUTFarmAppData appData;
    AppWallet appWallet;

    constructor
    (
        address _systemSettingAddress, 
        address _systemAuthAddress, 
        address _farmLandAddress, 
        address _relationshipAddress, 
        address _historyAddress,
        address _appDataAddress,
        address _appWalletAddress
    ) {
        ssSetting = SystemSetting(_systemSettingAddress);
        ssAuth = SystemAuth(_systemAuthAddress);

        farmLand = FarmLand(_farmLandAddress);
        relationship = Relationship(_relationshipAddress);
        history = History(_historyAddress);
        appData = MUTFarmAppData(_appDataAddress);
        appWallet = AppWallet(_appWalletAddress);
    }

    //buy seeds and sow them to the ground, using coin as payment
    //with withPaymentAmount, such as usdt
    //with shared profit if available
    //with fomo reward if available
    function sowSeed(
        uint256 withPaymentAmount,
        uint256 withSharedProfit,
        uint256 withFomoReward
    ) external {
        _sowSeed(msg.sender, ssAuth.getRoot(), withPaymentAmount, withSharedProfit, withFomoReward);
    }

    //buy seeds and sow them to the ground, using coin as payment
    //with parent address
    //with withPaymentAmount
    //with shared profit if available
    //with fomo reward if available
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
            "ZERO address not allowed to buy seed"
        );
        require(
            farmLand.haveLand(account),
            "You need to buy a land to active your farming"
        );

        uint256 consumeAmount = 0;
        bool useSharedProfit = false;
        if (withSharedProfit > 0) {
            (
                bool resShared,
                uint256 sharedProfitTotal,
                uint256 sharedProfitClaimed
            ) = relationship.getSharedProfit(account);
            require(
                resShared &&
                    withSharedProfit <=
                    (sharedProfitTotal - sharedProfitClaimed),
                "Insufficient available shared profit to spend"
            );
            consumeAmount += withSharedProfit;
            useSharedProfit = true;
        }

        bool useFomoReward = false;
        if (withFomoReward > 0) {
            (
                bool available,
                uint256 availableFomoReward
            ) = appData.fomoRewardClaimable(account);
            require(
                available && withFomoReward <= availableFomoReward,
                "Insufficient available fomo reward to spend"
            );
            consumeAmount += withFomoReward;
            useFomoReward = true;
        }

        if (withPaymentAmount > 0) {
            require(ERC20(ssAuth.getPayment()).balanceOf(account) >= withPaymentAmount, "insufficient payment balance");
            require(ERC20(ssAuth.getPayment()).allowance(account, address(this)) >= withPaymentAmount, "not allowed to spend payment amount");
            consumeAmount += withPaymentAmount;
        }

        require(consumeAmount >= ssSetting.getMinAmountBuy(0), "too small amount to buy seed");
        require(consumeAmount <= ssSetting.getMaxAmountBuy(0), "too much amount to buy seed");

        if(appData.getCurrentRoundIndex() > 0 && appData.getQueueFirstIndex() > 0) {
            _transferFomoReward(appData.getCurrentRoundIndex());
        }

        if (appData.isRoundStop(appData.getCurrentRoundIndex(), ssSetting.getResetCountDownTimeLength(0), ssSetting.getBacklogToCountdown(0), ssSetting.getBacklogTime(0))|| 
            appData.getCurrentRoundIndex() == 0
        ) {
            //reset round
            //create a new round and left the old round data as there was.
            appData.createNewRound(consumeAmount);
        } else {
            appData.updateRoundDataInAmount(consumeAmount);
        }

        require(
            !appData.isUserSeedExists(appData.getCurrentRoundIndex(), account),
            "All your Seeds are not Mature yet"
        );

        //transfer payment to contract
        // require(ERC20(ssAuth.getPayment()).transferFrom(account, address(this), withPaymentAmount), "sow seed error while transfer payment ot contract");
        require(ERC20(ssAuth.getPayment()).transferFrom(account, ssAuth.getAppWallet(), withPaymentAmount), "sow seed error while transfer payment ot contract");

        if (parent == address(parent) && parent != address(0)) {
            relationship.makeRelationship(parent, account);
        } else {
            relationship.makeRelationship(ssAuth.getRoot(), account);
        }

        require(_distributeMony(account, consumeAmount, withSharedProfit, withFomoReward), "Buy seed error 407");

        if (useSharedProfit) {
            relationship.useSharedProfit(account, withSharedProfit);
        }

        if (useFomoReward) {
            appData.increaseUserFomoRewardClaimed(account, withFomoReward);
        }

        emit seedBoughtEvent(account, consumeAmount, block.timestamp);
    }

    //distribute money
    function _distributeMony(address account, uint256 amount, uint256 withSharedProfit, uint256 withFomoReward)
        internal
        returns (bool res)
    {

        //share profit upstream
        uint256 sharedAmount = relationship.sharedProfit(account, amount);

        //deposit charity
        uint256 charity = (amount * ssSetting.getCharityPercent(0)) / 1000;
        appData.increaseCharityAmount(charity);

        //deposit sysFund
        uint256 forSysFund = (amount * ssSetting.getSysFundPercent(0)) / 1000;
        appData.increaseSysFundAmount(forSysFund);

        //deposit fomoPool
        uint256 forFomoPool = (amount * ssSetting.getFomoPoolPercent(0)) / 1000;
        appData.increaseFomoPoolAmount(forFomoPool);

        uint256 paddingAmount = amount -
            (sharedAmount + forSysFund + forFomoPool + charity);

        while (true) {
            if (paddingAmount == 0) {
                break;
            }

            if(!appData.isFirstSeedDataExists()) {
                break;
            }

            uint256 firstNodeSeedAmount = appData.getFirstNodeSeedAmount();
            if(firstNodeSeedAmount == 0) {
                appData.increaseQueueFirstIndex(1);
                continue;
            }
            
            uint256 userSellAmount = 0;
            if (paddingAmount >= firstNodeSeedAmount) {
                userSellAmount = firstNodeSeedAmount;
            } else {
                userSellAmount = paddingAmount;
            }
            bool sold = _sellUserSeed(appData.getFirstNodeSeedAccount(), userSellAmount);
            if (sold) {
                paddingAmount -= userSellAmount;
                appData.decreaseTotalQueueAmount(userSellAmount);
                appData.increaseRoundDataOutAmount(userSellAmount);
            } else {
                revert("Error while buying seed");
            }
        }

        uint256 newAmount = amount + (amount * ssSetting.getCycleYieldsPercent(0)) / 1000;
        appData.enqueue(account, newAmount, withSharedProfit, withFomoReward, ssSetting.getCurrentSettingIndex());
        appData.createNewUserSeedData(account, newAmount, ssSetting.getCurrentSettingIndex());
        appData.increaseTotalQueueAmount(newAmount);

        res = true;
    }

    function _sellUserSeed(address account, uint256 amount)
        internal
        returns (bool res)
    {
        require(appData.isUserSeedExists(appData.getCurrentRoundIndex(), account), "You seed not exists");

        appData.sellUserSeed(account, amount);

        history.addMatureRecord(account, amount);
        
        emit seedSoldEvent(account, amount, block.timestamp);
        res = true;
    }

    //get range index of current round
    function getIndexRange()
        external
        view
        returns (uint32 firstIndex, uint32 lastIndex)
    {
        firstIndex = appData.getQueueFirstIndex();
        lastIndex = appData.getQueueLastIndex();
    }

    //check if seed is collectable
    function checkCollectable(uint256 roundNumber, address account)
        external
        view
        returns (bool res, uint256 amount)
    {
        (res, amount) = appData.checkCollectable(roundNumber, account, ssSetting.getMatureTime(0));
    }

    //claim collectable seed
    //if you miss or just forget to claim your collectable seed, the money will be transfered to an account by system after a while(fixed set to 1 month)
    function claimSeed(uint256 roundNumber) external {
        require(
            msg.sender != address(0),
            "ZERO address not allowed to claim seed"
        );
        require(
            appData.isUserSeedExists(appData.getCurrentRoundIndex(), msg.sender),
            "You seeds not exists"
        );

        (bool collectable, uint256 amount) = appData.checkCollectable(
            roundNumber,
            msg.sender,
            ssSetting.getMatureTime(0)
        );
        require(collectable, "Seeds uncollectable");
        require(
            ERC20(ssAuth.getPayment()).balanceOf(address(this)) >= amount,
            "Insufficient balance of Coin"
        );

        //(bool transfered) = ERC20(ssAuth.getPayment()).transfer(msg.sender, amount);
        (bool transfered) = appWallet.transferToken(ssAuth.getPayment(), msg.sender, amount);
        require(transfered, "Failed to claim seed");

        appData.increaseUserSeedClaimedAmount(roundNumber, msg.sender, amount);

        history.addClaimRecord(msg.sender, amount);

        emit seedClaimedEvent(msg.sender, amount);
    }

    //collect user's forgotten money of seed
    function collectForgottenSeed(address account, uint256 roundNumber, address to) external {
        require(
            msg.sender == ssAuth.getOwner(),
            "Only owner can collect user's forgotten money to `to` address"
        );

        require(appData.isRoundExists(roundNumber), "Round not exists");
        require(appData.isUserSeedExists(roundNumber, account), "user's forgotten money not available");

        (bool avaible, uint256 amount) = appData.userForgottenSeedAvailable(account, roundNumber, ssSetting.getFixedTimeForgotten(0));
        require(avaible && amount > 0, "have not forgotten seed to collect");
  
        require(ERC20(ssAuth.getPayment()).balanceOf(address(this)) >= amount, "insufficient balance in contract");
        // (bool transfered) = ERC20(ssAuth.getPayment()).transfer(to, amount);
        (bool transfered) = appWallet.transferToken(ssAuth.getPayment(), to, amount);
        require(transfered, "collect forgotten seed error");

        appData.deleteUserSeedData(account, roundNumber);
    }

    function userForgottenSeedAvailable(address account, uint256 roundNumber) external view returns (bool res, uint256 amount) {
        (res, amount) = appData.userForgottenSeedAvailable(account, roundNumber, ssSetting.getFixedTimeForgotten(0));
    }

    //withdraw system fund
    function withdrawSysFund(uint256 amount, address to) external {
        require(msg.sender == ssAuth.getOwner(), "!!!###");
        require(ERC20(ssAuth.getPayment()).balanceOf(address(this)) >= amount, "$$$%%%");
        require(appData.getSysFundAmount() >= amount, "&&&***");
        (bool t) = ERC20(ssAuth.getPayment()).transfer(to, amount);
        require(t, "Failed to withdraw system fund");
        appData.decreaseSysFundAmount(amount);
    }

    function withdrawCharity(uint256 amount, address to) external {
        require(msg.sender == ssAuth.getOwner(), "!!!###");
        require(ERC20(ssAuth.getPayment()).balanceOf(address(this)) >= amount, "$$$%%%");
        require(appData.getCharityAmount() >= amount, "&&&***");
        // (bool t) = ERC20(ssAuth.getPayment()).transfer(to, amount);
        (bool transfered) = appWallet.transferToken(ssAuth.getPayment(), to, amount);
        require(transfered, "Failed to withdraw charity");
        appData.decreaseCharityAmount(amount);
    }

    //check if the round is dead
    function isRoundStop(uint256 roundNumber) external view returns (bool res) {
        res = appData.isRoundStop
        (
            roundNumber, 
            ssSetting.getResetCountDownTimeLength(0), 
            ssSetting.getBacklogToCountdown(0), 
            ssSetting.getBacklogTime(0)
        );
    }

    //calculate the backlog of keep long value
    //returns percent 0 ~ 1000
    function getBacklog(uint256 roundNumber)
        external
        view
        returns (bool res, uint256 percent)
    {
        (res, percent) = appData.getBacklog(roundNumber, ssSetting.getBacklogTime(0));
    }

    //fomo reward
    //transfer rewards from pool
    function _transferFomoReward(uint256 roundNumber) internal {
        appData.transferFomoReward(roundNumber, ssSetting.getResetCountDownTimeLength(0), ssSetting.getBacklogToCountdown(0), ssSetting.getBacklogTime(0));
    }

    //check if an account is rewarded the fomo prize
    function checkFomoReward(address account, uint256 roundNumber)
        external
        view
        returns (
            bool isLastIn,
            bool isMostIn,
            uint256 amount
        )
    {
        (isLastIn, isMostIn, amount) = appData.checkFomoReward(account, roundNumber, ssSetting.getResetCountDownTimeLength(0), ssSetting.getBacklogToCountdown(0), ssSetting.getBacklogTime(0));
    }

    //get the account who got the last in rewards
    function getLastInRewardAddress(uint256 roundNumber)
        external
        view
        returns (
            bool res,
            address account,
            uint256 amount
        )
    {
        (res, account, amount) = appData.getLastInRewardAddress(roundNumber, ssSetting.getResetCountDownTimeLength(0), ssSetting.getBacklogToCountdown(0), ssSetting.getBacklogTime(0));
    }

    //get the account who got the most in rewards, the first one in reverse travel
    function getMostInRewardAddress(uint256 roundNumber)
        external
        view
        returns (
            bool res,
            address account,
            uint256 amount
        )
    {
        (res, account, amount) = appData.getMostInRewardAddress(roundNumber, ssSetting.getResetCountDownTimeLength(0), ssSetting.getBacklogToCountdown(0), ssSetting.getBacklogTime(0));
    }

    //claim my reward
    //if you miss or just forget to claim your reward, the money will be transfered to an account by system after a while(fixed set to 1 month)
    function claimFomoReward(uint256 amount) external {
        require(address(0) != msg.sender, "ZERO address forbidden");
        require(msg.sender != ssAuth.getOwner(), "owner can not claim fomo rewards");

        uint256 rIndex = appData.getCurrentRoundIndex();
        uint256 roundNumber = rIndex > 0 ? rIndex - 1 : 0;
        _transferFomoReward(roundNumber);

        require(
            appData.fomoRewardClaimedDataExists(msg.sender),
            "fomo rewards unavailable for you"
        );

        (bool resClaimable, uint256 claimableAmount) = appData.fomoRewardClaimable(msg.sender);
        require(resClaimable, "not claimable");
        require(claimableAmount >= amount, "insufficient amount to claim");

        require(
            ERC20(ssAuth.getPayment()).balanceOf(address(this)) >= claimableAmount,
            "Insufficient balance in this contract for reward claiming"
        );
        // (bool transfered) = ERC20(ssAuth.getPayment()).transfer(msg.sender, claimableAmount);
        (bool transfered) = appWallet.transferToken(ssAuth.getPayment(), msg.sender, claimableAmount);
        require(transfered, "Claiming reward error");

        appData.increaseFomoRewardClaimedAmount(msg.sender, claimableAmount);

        emit fomoRewardClaimedEvent(msg.sender, claimableAmount);
    }

    //claim shared profit
    function claimSharedProfit(uint256 amount) external {
        require(msg.sender != ssAuth.getOwner(), "can not be owner");
        require(msg.sender != address(0), "can not be ZERO address");
        (bool res, uint256 totalAmount, uint256 claimedAmount) = relationship.getSharedProfit(msg.sender);
        require(res, "shared profit not exists");
        require(
            totalAmount >= amount + claimedAmount,
            "insufficient amount to be claimed"
        );
        require(
            ERC20(ssAuth.getPayment()).balanceOf(address(this)) >= amount,
            "Insufficient balance in contract"
        );
        // bool transfered = ERC20(ssAuth.getPayment()).transfer(
        //     msg.sender,
        //     amount
        // );
        (bool transfered) = appWallet.transferToken(ssAuth.getPayment(), msg.sender, amount);
        require(transfered, "claim shared profit error");
        
        relationship.increaseClaimedSharedProfit(msg.sender, amount);

        emit sharedProfitClaimedEvent(msg.sender, amount);
    }

    //send forgotten reward to an account
    function sendFomoRewardByOwner(address account, address to) external {
        require(
            msg.sender == ssAuth.getOwner(),
            "Only owner can send rewards to an account"
        );

        uint256 rIndex = appData.getCurrentRoundIndex();
        uint256 roundNumber = rIndex > 0 ? rIndex - 1 : 0;
        _transferFomoReward(roundNumber);

        require(appData.fomoRewardClaimedDataExists(account), "reward not exists");

        (bool resForgottenClaimable, uint256 forgottenAmount) = appData.getForgottenClaimable(account, roundNumber, ssSetting.getFixedTimeForgotten(0), ssSetting.getResetCountDownTimeLength(0));
        require(resForgottenClaimable && forgottenAmount > 0, "have no forgotten fomo reward");
        require(ERC20(ssAuth.getPayment()).balanceOf(address(this)) >= forgottenAmount, "insufficient balance in contract");
        // (bool transfered) = ERC20(ssAuth.getPayment()).transfer(to, forgottenAmount);
        (bool transfered) = appWallet.transferToken(ssAuth.getPayment(), to, forgottenAmount);
        require(transfered, "sendFomoRewardByOwner");
        appData.increaseFomoRewardClaimedAmount(account, forgottenAmount);
    }

    //get max round index
    function getMaxRoundNumber() external view returns (uint256 res) {
        res = appData.getCurrentRoundIndex();
    }
}