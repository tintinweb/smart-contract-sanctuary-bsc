// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./interfaces/IUndelegationHolder.sol";
import "./interfaces/IAddressStore.sol";
import "./interfaces/IStakePoolBot.sol";

contract UndelegationHolder is IUndelegationHolder {
    /*********************
     * STATE VARIABLES
     ********************/

    /**
     * @dev _addressStore: The Address Store. Used to fetch addresses of the other contracts in the system.
     */
    IAddressStore private _addressStore;

    /*********************
     * ERRORS
     ********************/
    error UnauthorizedSender();
    error TransferToStakePoolFailed();

    /*********************
     * CONTRACT LOGIC
     ********************/

    constructor(IAddressStore addressStore_) {
        _addressStore = addressStore_;
    }

    /**
     * @dev Called by the TokenHub contract when undelegated funds are transferred cross-chain by
     * bot from BBC staking address to this contract on BSC. At the same time, can also be used by
     * anyone to send any amount to this contract, which can be both a use as well as a misuse.
     * So, should be handled properly.
     */
    receive() external payable override {
        emit Received(msg.sender, msg.value);
    }

    /**
     * @dev Called by the StakePool contract to withdraw the undelegated funds. It sends at max
     * the bnbUnbonding to StakePool.
     *
     * Requirements:
     * - The caller must be the StakePool contract.
     *
     * @return The amount it sent to the StakePool.
     */
    function withdrawUnbondedBNB() external override returns (uint256) {
        address stakePool = _addressStore.getStakePool();
        if (msg.sender != stakePool) {
            revert UnauthorizedSender();
        }

        // the current balance can be more than what the StakePool contract needs based on bnbUnbonding. It might happen
        // if someone makes an unexpected donation to this contract. The person making the donation could be us, trying
        // to payout the fee losses to the protocol (a legit use-case). It could also be a malicious actor trying to
        // play with the protocol (a misuse-case). In any case, we will only send the needed amount to the StakePool
        // contract instead of forwarding all the current balance. This way, we can pay fee losses to the protocol in
        // advance, without hampering protocol's security, and at the same time, be free of worries about claims failing
        // even in the rarest of the rare scenarios.
        uint256 amountToSend = address(this).balance;
        uint256 bnbUnbonding = IStakePoolBot(stakePool).bnbUnbonding();
        if (amountToSend > bnbUnbonding) {
            amountToSend = bnbUnbonding;
        }
        // can't use address.transfer() here as it limits the gas to 2300, resulting in failure due to gas exhaustion.
        (
            bool sent, /*memory data*/

        ) = stakePool.call{ value: amountToSend }("");
        if (!sent) {
            revert TransferToStakePoolFailed();
        }

        return amountToSend;
    }

    /**
     * @return the address store
     */
    function addressStore() external view returns (IAddressStore) {
        return _addressStore;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

/**
 * @title Undelegation Holder interface
 *
 * @dev This contract temporarily holds the undelegated amount transferred from the BC staking
 * address before it is transferred to the StakePool contract to fulfil claimReserve. This is
 * needed to ensure that all the amount transferred from the BC staking address to BSC gets
 * correctly reflected in the StakePool claimReserve without any loss of funds in-between.
 * This has following benefits:
 * - Less dependence on bot. Lesser the amount of time funds remain with a custodial address managed
 *   by the bot, greater the security.
 * - In case of an emergency situation like bot failing to undelegate timely, or some security
 *   mishap with the staking address on BC, funds can be added directly to this contract to
 *   satisfy user claims.
 * - Possibility to replace this contract with a TSS managed address in future, if needed.
 */
interface IUndelegationHolder {
    // @dev Emitted when receive function is called.
    event Received(address sender, uint256 amount);

    /**
     * @dev Called by the TokenHub contract when undelegated funds are transferred cross-chain by
     * bot from BC staking address to this contract on BSC.
     */
    receive() external payable;

    /**
     * @dev Called by the StakePool contract to withdraw the undelegated funds. It sends all its
     * funds to StakePool.
     *
     * Requirements:
     * - The caller must be the StakePool contract.
     *
     * @return The current balance, all of which it will be sending to the StakePool.
     */
    function withdrawUnbondedBNB() external returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface IAddressStore {
    function setAddr(string memory key, address value) external;

    function setTimelockedAdmin(address addr) external;

    function setStkBNB(address addr) external;

    function setFeeVault(address addr) external;

    function setStakePool(address addr) external;

    function setUndelegationHolder(address addr) external;

    function getAddr(string calldata key) external view returns (address);

    function getTimelockedAdmin() external view returns (address);

    function getStkBNB() external view returns (address);

    function getFeeVault() external view returns (address);

    function getStakePool() external view returns (address);

    function getUndelegationHolder() external view returns (address);
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.7;

/**
 * @title StakePool Bot
 * @dev The functionalities required from the StakePool contract by the bot. This contract should
 * be implemented by the StakePool contract.
 */
interface IStakePoolBot {
    /**
     * @dev The amount that needs to be unbonded in the next unstaking epoch.
     * It increases on every user unstake operation, and decreases when the bot initiates unbonding.
     * This is queried by the bot in order to initiate unbonding.
     * It is int256, not uint256 because bnbUnbonding can be more than it and is subtracted from it.
     * So, if it is < 0, means we have already initiated unbonding for that much amount and eventually
     * that amount would be part of claimReserve. So, we don't need to unbond anything new on the BBC
     * side as long as this value is negative.
     *
     * Increase frequency: anytime
     * Decrease frequency & Bot query frequency:
     *      Mainnet: Weekly
     *      Testnet: Daily
     */
    function bnbToUnbond() external view returns (int256);

    /**
     * @dev The amount of BNB that is unbonding in the current unstaking epoch.
     * It increases when the bot initiates unbonding, and decreases when the unbonding is finished.
     * It is queried by the bot before calling unbondingFinished(), to figure out the amount that
     * needs to be moved from BBC to BSC.
     *
     * Increase, Decrease & Bot query frequency:
     *      Mainnet: Weekly
     *      Testnet: Daily
     */
    function bnbUnbonding() external view returns (uint256);

    /**
     * @dev A portion of the contract balance that is reserved in order to satisfy the claims
     * for which the cooldown period has finished. This will never be sent to BBC for staking.
     * It increases when the unbonding is finished, and decreases when any user actually claims
     * their BNB.
     *
     * Increase frequency:
     *      Mainnet: Weekly
     *      Testnet: Daily
     * Decrease frequency: anytime
     */
    function claimReserve() external view returns (uint256);

    /**
     * @dev This is called by the bot in order to transfer the stakable BNB from contract to the
     * staking address on BC.
     * Call frequency:
     *      Mainnet: Daily
     *      Testnet: Daily
     */
    function initiateDelegation() external;

    /**
     * @dev Called by the bot to update the exchange rate in contract based on the rewards
     * obtained in the BC staking address and accordingly mint fee tokens.
     * Call frequency:
     *      Mainnet: Daily
     *      Testnet: Daily
     *
     * @param bnbRewards: The amount of BNB which were received as staking rewards.
     */
    function epochUpdate(uint256 bnbRewards) external;

    /**
     * @dev This is called by the bot after it has executed the unbond transaction on BBC.
     * Call frequency:
     *      Mainnet: Weekly
     *      Testnet: Daily
     *
     * @param bnbUnbonding: The amount of BNB for which unbonding was initiated on BC.
     *                      It can be more than bnbToUnbond, but within a factor of min undelegation amount.
     */
    function unbondingInitiated(uint256 bnbUnbonding) external;

    /**
     * @dev Called by the bot after the unbonded amount for claim fulfilment is received in BBC
     * and has been transferred to the UndelegationHolder contract on BSC.
     * It calls UndelegationHolder.withdrawUnbondedBNB() to fetch the unbonded BNB to itself and
     * update `bnbUnbonding` and `claimReserve`.
     * Call frequency:
     *      Mainnet: Weekly
     *      Testnet: Daily
     */
    function unbondingFinished() external;
}