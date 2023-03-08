// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "../interfaces/ICommunityCoin.sol";
import "../interfaces/ICommunityStakingPoolFactory.sol";
import "../interfaces/ICommunityStakingPool.sol";
import "../interfaces/IRewards.sol";

//import "hardhat/console.sol";
library PoolStakesLib {
    using MinimumsLib for MinimumsLib.UserStruct;
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;

    function unstakeablePart(
        mapping(address => ICommunityCoin.UserData) storage users,
        mapping(address => ICommunityCoin.InstanceStruct) storage _instances,
        address from, 
        address to, 
        IStructs.Total storage total, 
        uint256 amount
    ) external {
        // console.log("amount                         =",amount);
        // console.log("remainingAmount                =",remainingAmount);
        // console.log("users[from].unstakeable        =",users[from].unstakeable);
        // console.log("users[from].unstakeableBonuses =",users[from].unstakeableBonuses);
        // console.log("users[to].unstakeable          =",users[to].unstakeable);
        // console.log("users[to].unstakeableBonuses   =",users[to].unstakeableBonuses);
        // else it's just transfer

        // so while transfer user will user free tokens at first
        // then try to use locked. when using locked we should descrease

        //users[from].unstakeableBonuses;
        //try to get from bonuses
        //  here just increase redeemable
        //then try to get from main unstakeable
        //  here decrease any unstakeable vars
        //              increase redeemable
        uint256 r;
        uint256 left = amount;
        if (users[from].unstakeableBonuses > 0) {
            
            if (users[from].unstakeableBonuses >= left) {
                r = left;
            } else {
                r = users[from].unstakeableBonuses;
            }

            if (to == address(0)) {
                // it's simple burn and tokens can not be redeemable
            } else {
                total.totalRedeemable += r;
            }

            PoolStakesLib._removeBonusThroughInstances(users, _instances, from, r);
            users[from].unstakeableBonuses -= r;
            left -= r;
        }

        if ((left > 0) && (users[from].unstakeable >= left)) {
            // console.log("#2");
            if (users[from].unstakeable >= left) {
                r = left;
            } else {
                r = users[from].unstakeable;
            }

            //   r = users[from].unstakeable - left;
            // if (totalUnstakeable >= r) {
            users[from].unstakeable -= r;
            total.totalUnstakeable -= r;

            if (to == address(0)) {
                // it's simple burn and tokens can not be redeemable
            } else {
                total.totalRedeemable += r;
            }

            PoolStakesLib._removeMainThroughInstances(users, _instances, from, r);

            //left -= r;

            // }
        }

        // if (users[from].unstakeable >= remainingAmount) {
        //     uint256 r = users[from].unstakeable - remainingAmount;
        //     // if (totalUnstakeable >= r) {
        //     users[from].unstakeable -= r;
        //     totalUnstakeable -= r;
        //     if (to == address(0)) {
        //         // it's simple burn and tokens can not be redeemable
        //     } else {
        //         totalRedeemable += r;
        //     }
        //     // }
        // }
        // console.log("----------------------------");
        // console.log("users[from].unstakeable        =",users[from].unstakeable);
        // console.log("users[from].unstakeableBonuses =",users[from].unstakeableBonuses);
        // console.log("users[to].unstakeable          =",users[to].unstakeable);
        // console.log("users[to].unstakeableBonuses   =",users[to].unstakeableBonuses);
    }

    
    function _removeMainThroughInstances(
        mapping(address => ICommunityCoin.UserData) storage users,
        mapping(address => ICommunityCoin.InstanceStruct) storage _instances,
        address account, 
        uint256 amount
    ) internal {
        uint256 len = users[account].instancesList.length();
        address[] memory instances2Delete = new address[](len);
        uint256 j = 0;
        address instance;
        for (uint256 i = 0; i < len; i++) {
            instance = users[account].instancesList.at(i);
            if (_instances[instance].unstakeable[account] >= amount) {
                _instances[instance].unstakeable[account] -= amount;
                _instances[instance].redeemable += amount;
            } else if (_instances[instance].unstakeable[account] > 0) {
                _instances[instance].unstakeable[account] = 0;
                instances2Delete[j] = instance;
                j += 1;
                amount -= _instances[instance].unstakeable[account];
            }
        }

        // do deletion out of loop above. because catch out of array
        cleanInstancesList(users, _instances, account, instances2Delete, j);
    }

    function _removeBonusThroughInstances(
        mapping(address => ICommunityCoin.UserData) storage users,
        mapping(address => ICommunityCoin.InstanceStruct) storage _instances,
        // address account, 
        // // address to, 
        // // IStructs.Total storage total, 
        // uint256 amount
        address account, 
        uint256 amount
    ) internal {
        //console.log("START::_removeBonusThroughInstances");
        uint256 len = users[account].instancesList.length();
        address[] memory instances2Delete = new address[](len);
        uint256 j = 0;
        //console.log("_removeBonusThroughInstances::len", len);
        address instance;
        for (uint256 i = 0; i < len; i++) {
            instance = users[account].instancesList.at(i);
            if (_instances[instance].unstakeableBonuses[account] >= amount) {
                //console.log("_removeBonusThroughInstances::#1");
                _instances[instance].unstakeableBonuses[account] -= amount;
            } else if (_instances[instance].unstakeableBonuses[account] > 0) {
                //console.log("_removeBonusThroughInstances::#2");
                _instances[instance].unstakeableBonuses[account] = 0;
                instances2Delete[i] = instance;
                j += 1;
                amount -= _instances[instance].unstakeableBonuses[account];
            }
        }

        // do deletion out of loop above. because catch out of array
        PoolStakesLib.cleanInstancesList(users, _instances, account, instances2Delete, j);
        //console.log("END::_removeBonusThroughInstances");
    }

    /*
    function _removeBonus(
        address instance,
        address account,
        uint256 amount
    ) internal {
        // todo 0:
        //  check `instance` exists in list.
        //  check `amount` should be less or equal `_instances[instance].unstakeableBonuses[account]`

        _instances[instance].unstakeableBonuses[account] -= amount;
        users[account].unstakeableBonuses -= amount;

        if (_instances[instance].unstakeable[account] >= amount) {
            _instances[instance].unstakeable[account] -= amount;
        } else if (_instances[instance].unstakeable[account] > 0) {
            _instances[instance].unstakeable[account] = 0;
            //amount -= _instances[instance].unstakeable[account];
        }
        _cleanInstance(account, instance);
    }
    */

    function cleanInstancesList(
        
        mapping(address => ICommunityCoin.UserData) storage users,
        mapping(address => ICommunityCoin.InstanceStruct) storage _instances,
        address account,
        address[] memory instances2Delete,
        uint256 indexUntil
    ) internal {
        // console.log("start::cleanInstancesList");
        // console.log("cleanInstancesList::indexUntil=",indexUntil);
        //uint256 len = instances2Delete.length;
        if (indexUntil > 0) {
            for (uint256 i = 0; i < indexUntil; i++) {
                PoolStakesLib._cleanInstance(users, _instances, account, instances2Delete[i]);
            }
        }
        // console.log("end::cleanInstancesList");
    }

     function _cleanInstance(
        mapping(address => ICommunityCoin.UserData) storage users,
        mapping(address => ICommunityCoin.InstanceStruct) storage _instances,
        address account, 
        address instance
    ) internal {
        //console.log("start::_cleanInstance");
        if (_instances[instance].unstakeableBonuses[account] == 0 && _instances[instance].unstakeable[account] == 0) {
            users[account].instancesList.remove(instance);
        }

        // console.log("end::_cleanInstance");
    }

    function lockedPart(
        mapping(address => ICommunityCoin.UserData) storage users,
        address from, 
        uint256 remainingAmount
    ) external {
        /*
        balance = 100
        amount = 40
        locked = 50
        minimumsTransfer - ? =  0
        */
        /*
        balance = 100
        amount = 60
        locked = 50
        minimumsTransfer - ? = [50 > (100-60)] locked-(balance-amount) = 50-(40)=10  
        */
        /*
        balance = 100
        amount = 100
        locked = 100
        minimumsTransfer - ? = [100 > (100-100)] 100-(100-100)=100  
        */

        uint256 locked = users[from].tokensLocked._getMinimum();
        uint256 lockedBonus = users[from].tokensBonus._getMinimum();
        //else drop locked minimum, but remove minimums even if remaining was enough
        //minimumsTransfer(account, ZERO_ADDRESS, (locked - remainingAmount))
        // console.log("locked---start");
        // console.log("balance        = ",balance);
        // console.log("amount         = ",amount);
        // console.log("remainingAmount= ",remainingAmount);
        // console.log("locked         = ",locked);
        // console.log("lockedBonus    = ",lockedBonus);
        if (locked + lockedBonus > 0 && locked + lockedBonus >= remainingAmount) {
            // console.log("#1");
            uint256 locked2Transfer = locked + lockedBonus - remainingAmount;
            if (lockedBonus >= locked2Transfer) {
                // console.log("#2.1");
                users[from].tokensBonus.minimumsTransfer(
                    users[address(0)].tokensBonus,
                    true,
                    (lockedBonus - locked2Transfer)
                );
            } else {
                // console.log("#2.2");

                // console.log("locked2Transfer = ", locked2Transfer);
                //uint256 left = (remainingAmount - lockedBonus);
                if (lockedBonus > 0) {
                    users[from].tokensBonus.minimumsTransfer(
                        users[address(0)].tokensBonus,
                        true,
                        lockedBonus
                    );
                    locked2Transfer -= lockedBonus;
                }
                users[from].tokensLocked.minimumsTransfer(
                    users[address(0)].tokensLocked,
                    true,
                    locked2Transfer
                );
            }
        }
        // console.log("locked         = ",locked);
        // console.log("lockedBonus    = ",lockedBonus);
        // console.log("locked---end");
        //-------------------
    }

    function proceedPool(
        ICommunityStakingPoolFactory instanceManagment,
        address hook,
        address account,
        address pool,
        uint256 amount,
        ICommunityCoin.Strategy strategy /*, string memory errmsg*/
    ) external {

        ICommunityStakingPoolFactory.InstanceInfo memory instanceInfo = instanceManagment.getInstanceInfoByPoolAddress(pool);

        try ICommunityStakingPool(pool).redeem(account, amount) returns (
            uint256 affectedAmount,
            uint64 rewardsRateFraction
        ) {
// console.log("proceedPool");
// console.log(account, amount);
            if (
                (hook != address(0)) &&
                (strategy == ICommunityCoin.Strategy.UNSTAKE)
            ) {
                require(instanceInfo.exists == true);
                IRewards(hook).onUnstake(pool, account, instanceInfo.duration, affectedAmount, rewardsRateFraction);
            }
        } catch {
            if (strategy == ICommunityCoin.Strategy.UNSTAKE) {
                revert ICommunityCoin.UNSTAKE_ERROR();
            } else if (strategy == ICommunityCoin.Strategy.REDEEM) {
                revert ICommunityCoin.REDEEM_ERROR();
            }
            
        }
        
    }

    // adjusting amount and applying some discounts, fee, etc
    function getAmountLeft(
        address account,
        uint256 amount,
        uint256 totalSupplyBefore,
        ICommunityCoin.Strategy strategy,
        IStructs.Total storage total,
        // uint256 totalRedeemable,
        // uint256 totalUnstakeable,
        // uint256 totalReserves,
        uint256 discountSensitivity,
        mapping(address => ICommunityCoin.UserData) storage users,
        uint64 unstakeTariff, 
        uint64 redeemTariff,
        uint64 fraction

    ) external view returns(uint256) {
        
        if (strategy == ICommunityCoin.Strategy.REDEEM) {

            // LPTokens =  WalletTokens * ratio;
            // ratio = A / (A + B * discountSensitivity);
            // где 
            // discountSensitivity - constant set in constructor
            // A = totalRedeemable across all pools
            // B = totalSupply - A - totalUnstakeable
            uint256 A = total.totalRedeemable;
            uint256 B = totalSupplyBefore - A - total.totalUnstakeable;
            // uint256 ratio = A / (A + B * discountSensitivity);
            // amountLeft =  amount * ratio; // LPTokens =  WalletTokens * ratio;

            // --- proposal from audit to keep precision after division
            // amountLeft = amount * A / (A + B * discountSensitivity / 100000);
            amount = amount * A * fraction;
            amount = amount / (A + B * discountSensitivity / fraction);
            amount = amount / fraction;

            /////////////////////////////////////////////////////////////////////
            // Formula: #1
            // discount = mainTokens / (mainTokens + bonusTokens);
            // 
            // but what we have: 
            // - mainTokens     - tokens that user obtain after staked 
            // - bonusTokens    - any bonus tokens. 
            //   increase when:
            //   -- stakers was invited via community. so inviter will obtain amount * invitedByFraction
            //   -- calling addToCirculation
            //   decrease when:
            //   -- by applied tariff when redeem or unstake
            // so discount can be more then zero
            // We didn't create int256 bonusTokens variable. instead this we just use totalSupply() == (mainTokens + bonusTokens)
            // and provide uint256 totalReserves as tokens amount  without bonuses.
            // increasing than user stakes and decreasing when redeem
            // smth like this
            // discount = totalReserves / (totalSupply();
            // !!! keep in mind that we have burn tokens before it's operation and totalSupply() can be zero. use totalSupplyBefore instead 

            amount = amount * total.totalReserves / totalSupplyBefore;

            /////////////////////////////////////////////////////////////////////

            // apply redeem tariff                    
            amount -= amount * redeemTariff/fraction;
            
        }

        if (strategy == ICommunityCoin.Strategy.UNSTAKE) {

            if (
               (totalSupplyBefore - users[account].tokensBonus._getMinimum() < amount) || // insufficient amount
               (users[account].unstakeable < amount)  // check if user can unstake such amount across all instances
            ) {
                revert ICommunityCoin.InsufficientAmount(account, amount);
            }

            // apply unstake tariff
            amount -= amount * unstakeTariff/fraction;


        }

        return amount;
        
    }
    
    // create map of instance->amount or LP tokens that need to redeem
    function available(
        address account,
        uint256 amount,
        address[] memory preferredInstances,
        ICommunityCoin.Strategy strategy,
        ICommunityStakingPoolFactory instanceManagment,
        mapping(address => ICommunityCoin.InstanceStruct) storage _instances
    ) 
        external 
        view
        returns(
            address[] memory instancesAddress,  // instance's addresses
            uint256[] memory values,            // amounts to redeem in instance
            uint256[] memory amounts,           // itrc amount equivalent(applied num/den)
            uint256 len
        ) 
    {
    
        //  uint256 FRACTION = 100000;

        if (preferredInstances.length == 0) {
            preferredInstances = instanceManagment.instances();
        }

        instancesAddress = new address[](preferredInstances.length);
        values = new uint256[](preferredInstances.length);
        amounts = new uint256[](preferredInstances.length);

        uint256 amountLeft = amount;
        

        len = 0;
        uint256 amountToRedeem;

        // now calculate from which instances we should reduce tokens
        for (uint256 i = 0; i < preferredInstances.length; i++) {

            if (
                (strategy == ICommunityCoin.Strategy.UNSTAKE) &&
                (_instances[preferredInstances[i]].unstakeable[account] > 0)
            ) {
                amountToRedeem = 
                    amountLeft > _instances[preferredInstances[i]].unstakeable[account]
                    ?
                    _instances[preferredInstances[i]].unstakeable[account]
                        // _instances[preferredInstances[i]]._instanceStaked > users[account].unstakeable
                        // ? 
                        // users[account].unstakeable
                        // :
                        // _instances[preferredInstances[i]]._instanceStaked    
                    :
                    amountLeft;

            }  
            if (
                strategy == ICommunityCoin.Strategy.REDEEM
            ) {
                amountToRedeem = 
                    amountLeft > _instances[preferredInstances[i]]._instanceStaked
                    ? 
                    _instances[preferredInstances[i]]._instanceStaked
                    : 
                    amountLeft
                    ;
            }
                
            if (amountToRedeem > 0) {

                ICommunityStakingPoolFactory.InstanceInfo memory instanceInfo;
                instancesAddress[len] = preferredInstances[i]; 
                instanceInfo =  instanceManagment.getInstanceInfoByPoolAddress(preferredInstances[i]); // todo is exist there?
                amounts[len] = amountToRedeem;
                //backward conversion( СС -> LP)
                values[len] = amountToRedeem * (instanceInfo.denominator) / (instanceInfo.numerator);
                
                len += 1;
                
                amountLeft -= amountToRedeem;
            }
        }
        
        if(amountLeft > 0) {revert ICommunityCoin.InsufficientAmount(account, amount);}

    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./IStructs.sol";

interface ICommunityStakingPoolFactory {
    
    
    struct InstanceInfo {
        address tokenErc20;
        uint64 duration;
        bool exists;
        uint64 bonusTokenFraction;
        address popularToken;
        uint64 rewardsRateFraction;
        uint64 numerator;
        uint64 denominator;
    }

    event InstanceCreated(address indexed erc20, address instance, uint instancesCount);

    function initialize(address impl) external;
    function getInstance(address tokenErc20, uint256 lockupIntervalCount) external view returns (address instance);
    function instancesByIndex(uint index) external view returns (address instance);
    function instances() external view returns (address[] memory instances);
    function instancesCount() external view returns (uint);
    function produce(address tokenErc20, uint64 duration, uint64 bonusTokenFraction, address popularToken, IStructs.StructAddrUint256[] memory donations, uint64 rewardsRateFraction, uint64 numerator, uint64 denominator) external returns (address instance);
    function getInstanceInfoByPoolAddress(address addr) external view returns(InstanceInfo memory);

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./IStructs.sol";
import "../minimums/libs/MinimumsLib.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
interface ICommunityCoin {
    
    struct UserData {
        uint256 unstakeable; // total unstakeable across pools
        uint256 unstakeableBonuses;
        MinimumsLib.UserStruct tokensLocked;
        MinimumsLib.UserStruct tokensBonus;
        // lists where user staked or obtained bonuses
        EnumerableSetUpgradeable.AddressSet instancesList;
    }

    struct InstanceStruct {
        uint256 _instanceStaked;
        
        uint256 redeemable;
        // //      user
        // mapping(address => uint256) usersStaked;
        //      user
        mapping(address => uint256) unstakeable;
        //      user
        mapping(address => uint256) unstakeableBonuses;
        
    }

    function initialize(
        string calldata name,
        string calldata symbol,
        address poolImpl,
        address hook,
        address instancesImpl,
        uint256 discountSensitivity,
        IStructs.CommunitySettings calldata communitySettings,
        address costManager,
        address producedBy
    ) external;

    enum Strategy{ UNSTAKE, REDEEM} 

    event InstanceCreated(address indexed erc20token, address instance);
    
    error InsufficientBalance(address account, uint256 amount);
    error InsufficientAmount(address account, uint256 amount);
    error StakeNotUnlockedYet(address account, uint256 locked, uint256 remainingAmount);
    error TrustedForwarderCanNotBeOwner(address account);
    error DeniedForTrustedForwarder(address account);
    error OwnTokensPermittedOnly();
    error UNSTAKE_ERROR();
    error REDEEM_ERROR();
    error HookTransferPrevent(address from, address to, uint256 amount);
    error AmountExceedsAllowance(address account,uint256 amount);
    error AmountExceedsMaxTariff();
    
    function issueWalletTokens(address account, uint256 amount, uint256 priceBeforeStake, uint256 donatedAmount) external;

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./IStructs.sol";

interface ICommunityStakingPool {
    
    function initialize(
        address stakingProducedBy_,
        address token_,
        address popularToken_,
        IStructs.StructAddrUint256[] memory donations_,
        uint64 rewardsRateFraction_
    ) external;

    function redeem(address account, uint256 amount) external returns(uint256 affectedAmount, uint64 rewardsRateFraction);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./IHook.sol";
interface IRewards is IHook {

    function initialize(
        address sellingToken,
        uint256[] memory timestamps,
        uint256[] memory prices,
        uint256[] memory thresholds,
        uint256[] memory bonuses
    ) external;

    function onClaim(address account) external;

    function onUnstake(address instance, address account, uint64 duration, uint256 amount, uint64 rewardsFraction) external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.11;

interface IStructs {
    struct StructAddrUint256 {
        address account;
        uint256 amount;
    }

    struct CommunitySettings {
        uint256 invitedByFraction;
        address addr;
        uint8 redeemRoleId;
        uint8 circulationRoleId;
        uint8 tariffRoleId;
    }

    struct Total {
        uint256 totalUnstakeable;
        uint256 totalRedeemable;
        // it's how tokens will store in pools. without bonuses.
        // means totalReserves = SUM(pools.totalSupply)
        uint256 totalReserves;
    }

    enum InstanceType{ USUAL, ERC20, NONE }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";

library MinimumsLib {
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

    address internal constant ZERO_ADDRESS = address(0);

    struct Minimum {
     //   uint256 timestampStart; //ts start no need 
        //uint256 timestampEnd;   //ts end
        uint256 speedGradualUnlock;    
        uint256 amountGradualWithdrawn;
        //uint256 amountGradual;
        uint256 amountNoneGradual;
        //bool gradual;
    }

    struct Lockup {
        uint64 duration;
        //bool gradual; // does not used 
        bool exists;
    }

    struct UserStruct {
        EnumerableSetUpgradeable.UintSet minimumsIndexes;
        mapping(uint256 => Minimum) minimums;
        //mapping(uint256 => uint256) dailyAmounts;
        Lockup lockup;
    }


      /**
    * @dev adding minimum holding at sender during period from now to timestamp.
    *
    * @param amount amount.
    * @param intervalCount duration in count of intervals defined before
    * @param gradual true if the limitation can gradually decrease
    */
    function _minimumsAdd(
        UserStruct storage _userStruct,
        uint256 amount, 
        uint256 intervalCount,
        uint64 interval,
        bool gradual
    ) 
        // public 
        // onlyOwner()
        internal
        returns (bool)
    {
        uint256 timestampStart = getIndexInterval(block.timestamp, interval);
        uint256 timestampEnd = timestampStart + (intervalCount * interval);
        require(timestampEnd > timestampStart, "TIMESTAMP_INVALID");
        
        _minimumsClear(_userStruct, interval, false);
        
        _minimumsAddLow(_userStruct, timestampStart, timestampEnd, amount, gradual);
    
        return true;
        
    }
    
    /**
     * @dev removes all minimums from this address
     * so all tokens are unlocked to send
     *  UserStruct which should be clear restrict
     */
    function _minimumsClear(
        UserStruct storage _userStruct,
        uint64 interval
    )
        internal
        returns (bool)
    {
        return _minimumsClear(_userStruct, interval, true);
    }
    
    /**
     * from will add automatic lockup for destination address sent address from
     * @param duration duration in count of intervals defined before
     */
    function _automaticLockupAdd(
        UserStruct storage _userStruct,
        uint64 duration,
        uint64 interval
    )
        internal
    {
        _userStruct.lockup.duration = duration * interval;
        _userStruct.lockup.exists = true;
    }
    
    /**
     * remove automaticLockup from UserStruct
     */
    function _automaticLockupRemove(
        UserStruct storage _userStruct
    )
        internal
    {
        _userStruct.lockup.exists = false;
    }
    
    /**
    * @dev get sum minimum and sum gradual minimums from address for period from now to timestamp.
    *
    */
    function _getMinimum(
        UserStruct storage _userStruct
    ) 
        internal 
        view
        returns (uint256 amountLocked) 
    {
        
        uint256 mapIndex;
        uint256 tmp;
        for (uint256 i=0; i<_userStruct.minimumsIndexes.length(); i++) {
            mapIndex = _userStruct.minimumsIndexes.at(i);
            
            if (block.timestamp <= mapIndex) { // block.timestamp<timestampEnd
                tmp = _userStruct.minimums[mapIndex].speedGradualUnlock * (mapIndex - block.timestamp);
                
                amountLocked = amountLocked +
                                    (
                                        tmp < _userStruct.minimums[mapIndex].amountGradualWithdrawn 
                                        ? 
                                        0 
                                        : 
                                        tmp - (_userStruct.minimums[mapIndex].amountGradualWithdrawn)
                                    ) +
                                    (_userStruct.minimums[mapIndex].amountNoneGradual);
            }
        }
    }

    function _getMinimumList(
        UserStruct storage _userStruct
    ) 
        internal 
        view
        returns (uint256[][] memory ) 
    {
        
        uint256 mapIndex;
        uint256 tmp;
        uint256 len = _userStruct.minimumsIndexes.length();

        uint256[][] memory ret = new uint256[][](len);


        for (uint256 i=0; i<len; i++) {
            mapIndex = _userStruct.minimumsIndexes.at(i);
            
            if (block.timestamp <= mapIndex) { // block.timestamp<timestampEnd
                tmp = _userStruct.minimums[mapIndex].speedGradualUnlock * (mapIndex - block.timestamp);
                ret[i] = new uint256[](2);
                ret[i][1] = mapIndex;
                ret[i][0] = (
                                tmp < _userStruct.minimums[mapIndex].amountGradualWithdrawn 
                                ? 
                                0 
                                : 
                                tmp - _userStruct.minimums[mapIndex].amountGradualWithdrawn
                            ) +
                            _userStruct.minimums[mapIndex].amountNoneGradual;
            }
        }

        return ret;
    }
    
    /**
    * @dev clear expired items from mapping. used while addingMinimum
    *
    * @param deleteAnyway if true when delete items regardless expired or not
    */
    function _minimumsClear(
        UserStruct storage _userStruct,
        uint64 interval,
        bool deleteAnyway
    ) 
        internal 
        returns (bool) 
    {
        uint256 mapIndex = 0;
        uint256 len = _userStruct.minimumsIndexes.length();
        if (len > 0) {
            for (uint256 i=len; i>0; i--) {
                mapIndex = _userStruct.minimumsIndexes.at(i-1);
                if (
                    (deleteAnyway == true) ||
                    (getIndexInterval(block.timestamp, interval) > mapIndex)
                ) {
                    delete _userStruct.minimums[mapIndex];
                    _userStruct.minimumsIndexes.remove(mapIndex);
                }
                
            }
        }
        return true;
    }


        
    /**
     * added minimum if not exist by timestamp else append it
     * @param _userStruct destination user
     * @param timestampStart if empty get current interval or currente time. Using only for calculate gradual
     * @param timestampEnd "until time"
     * @param amount amount
     * @param gradual if true then lockup are gradually
     */
    //function _appendMinimum(
    function _minimumsAddLow(
        UserStruct storage _userStruct,
        uint256 timestampStart, 
        uint256 timestampEnd, 
        uint256 amount, 
        bool gradual
    )
        private
    {
        _userStruct.minimumsIndexes.add(timestampEnd);
        if (gradual == true) {
            // gradual
            _userStruct.minimums[timestampEnd].speedGradualUnlock = _userStruct.minimums[timestampEnd].speedGradualUnlock + 
                (
                amount / (timestampEnd - timestampStart)
                );
            //_userStruct.minimums[timestamp].amountGradual = _userStruct.minimums[timestamp].amountGradual.add(amount);
        } else {
            // none-gradual
            _userStruct.minimums[timestampEnd].amountNoneGradual = _userStruct.minimums[timestampEnd].amountNoneGradual + amount;
        }
    }
    
    /**
     * @dev reduce minimum by value  otherwise remove it 
     * @param _userStruct destination user struct
     * @param timestampEnd "until time"
     * @param value amount
     */
    function _reduceMinimum(
        UserStruct storage _userStruct,
        uint256 timestampEnd, 
        uint256 value,
        bool gradual
    )
        internal
    {
        
        if (_userStruct.minimumsIndexes.contains(timestampEnd) == true) {
            
            if (gradual == true) {
                
                _userStruct.minimums[timestampEnd].amountGradualWithdrawn = _userStruct.minimums[timestampEnd].amountGradualWithdrawn + value;
                
                uint256 left = (_userStruct.minimums[timestampEnd].speedGradualUnlock) * (timestampEnd - block.timestamp);
                if (left <= _userStruct.minimums[timestampEnd].amountGradualWithdrawn) {
                    _userStruct.minimums[timestampEnd].speedGradualUnlock = 0;
                    // delete _userStruct.minimums[timestampEnd];
                    // _userStruct.minimumsIndexes.remove(timestampEnd);
                }
            } else {
                if (_userStruct.minimums[timestampEnd].amountNoneGradual > value) {
                    _userStruct.minimums[timestampEnd].amountNoneGradual = _userStruct.minimums[timestampEnd].amountNoneGradual - value;
                } else {
                    _userStruct.minimums[timestampEnd].amountNoneGradual = 0;
                    // delete _userStruct.minimums[timestampEnd];
                    // _userStruct.minimumsIndexes.remove(timestampEnd);
                }
                    
            }
            
            if (
                _userStruct.minimums[timestampEnd].speedGradualUnlock == 0 &&
                _userStruct.minimums[timestampEnd].amountNoneGradual == 0
            ) {
                delete _userStruct.minimums[timestampEnd];
                _userStruct.minimumsIndexes.remove(timestampEnd);
            }
                
                
            
        }
    }
    
    /**
     * 
     
     * @param value amount
     */
    function minimumsTransfer(
        UserStruct storage _userStructFrom, 
        UserStruct storage _userStructTo, 
        bool isTransferToZeroAddress,
        //address to,
        uint256 value
    )
        internal
    {
        

        uint256 len = _userStructFrom.minimumsIndexes.length();
        uint256[] memory _dataList;
        //uint256 recieverTimeLeft;
    
        if (len > 0) {
            _dataList = new uint256[](len);
            for (uint256 i=0; i<len; i++) {
                _dataList[i] = _userStructFrom.minimumsIndexes.at(i);
            }
            _dataList = sortAsc(_dataList);
            
            uint256 iValue;
            uint256 tmpValue;
        
            for (uint256 i=0; i<len; i++) {
                
                if (block.timestamp <= _dataList[i]) {
                    
                    // try move none-gradual
                    if (value >= _userStructFrom.minimums[_dataList[i]].amountNoneGradual) {
                        iValue = _userStructFrom.minimums[_dataList[i]].amountNoneGradual;
                        value = value - iValue;
                    } else {
                        iValue = value;
                        value = 0;
                    }
                    
                    // remove from sender
                    _reduceMinimum(
                        _userStructFrom,
                        _dataList[i],//timestampEnd,
                        iValue,
                        false
                    );

                    // shouldn't add miniums for zero account.
                    // that feature using to drop minimums from sender
                    //if (to != ZERO_ADDRESS) {
                    if (!isTransferToZeroAddress) {
                        _minimumsAddLow(_userStructTo, block.timestamp, _dataList[i], iValue, false);
                    }
                    
                    if (value == 0) {
                        break;
                    }
                    
                    
                    // try move gradual
                    
                    // amount left in current minimums
                    tmpValue = _userStructFrom.minimums[_dataList[i]].speedGradualUnlock * (_dataList[i] - block.timestamp);
                        
                        
                    if (value >= tmpValue) {
                        iValue = tmpValue;
                        value = value - tmpValue;

                    } else {
                        iValue = value;
                        value = 0;
                    }
                    // remove from sender
                    _reduceMinimum(
                        _userStructFrom,
                        _dataList[i],//timestampEnd,
                        iValue,
                        true
                    );
                    // uint256 speed = iValue.div(
                        //     users[from].minimums[_dataList[i]].timestampEnd.sub(block.timestamp);
                        // );

                    // shouldn't add miniums for zero account.
                    // that feature using to drop minimums from sender
                    //if (to != ZERO_ADDRESS) {
                    if (!isTransferToZeroAddress) {
                        _minimumsAddLow(_userStructTo, block.timestamp, _dataList[i], iValue, true);
                    }
                    if (value == 0) {
                        break;
                    }
                    


                } // if (block.timestamp <= users[from].minimums[_dataList[i]].timestampEnd) {
            } // end for
            
   
        }
        
        // if (value != 0) {
            // todo 0: what this?
            // _appendMinimum(
            //     to,
            //     block.timestamp,//block.timestamp.add(minTimeDiff),
            //     value,
            //     false
            // );
        // }
     
        
    }

    /**
    * @dev gives index interval. here we deliberately making a loss precision(div before mul) to get the same index during interval.
    * @param ts unixtimestamp
    */
    function getIndexInterval(uint256 ts, uint64 interval) internal pure returns(uint256) {
        return ts / interval * interval;
    }
    
    // useful method to sort native memory array 
    function sortAsc(uint256[] memory data) private returns(uint[] memory) {
       quickSortAsc(data, int(0), int(data.length - 1));
       return data;
    }
    
    function quickSortAsc(uint[] memory arr, int left, int right) private {
        int i = left;
        int j = right;
        if(i==j) return;
        uint pivot = arr[uint(left + (right - left) / 2)];
        while (i <= j) {
            while (arr[uint(i)] < pivot) i++;
            while (pivot < arr[uint(j)]) j--;
            if (i <= j) {
                (arr[uint(i)], arr[uint(j)]) = (arr[uint(j)], arr[uint(i)]);
                i++;
                j--;
            }
        }
        if (left < j)
            quickSortAsc(arr, left, j);
        if (i < right)
            quickSortAsc(arr, i, right);
    }

 


}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 *  Trying to delete such a structure from storage will likely result in data corruption, rendering the structure unusable.
 *  See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 *  In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an array of EnumerableSet.
 * ====
 */
library EnumerableSetUpgradeable {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IHook {
    // uses in initialing. fo example to link hook and caller of this hook
    function setupCaller() external;

    


}