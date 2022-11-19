//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BaseStrategy.sol";
import "../stkBNB/interfaces/IAddressStore.sol";
import "../stkBNB/interfaces/IStakedBNBToken.sol";
import "../stkBNB/interfaces/IStakePool.sol";
import "../stkBNB/ExchangeRate.sol";

contract StkBnbStrategy is BaseStrategy {

    using ExchangeRate for ExchangeRate.Data;

    /**
     * @dev The Address Store. Used to fetch addresses of all the other contracts in the stkBNB ecosystem.
     * It is sort of like a router.
     */
    IAddressStore private _addressStore;

    /**
     * @dev The net amount of BNB deposited to StakePool via this strategy.
     * i.e., the amount deposited - the amount withdrawn.
     * This isn't supposed to include the harvest generated from the pool.
     */
    uint256 private _bnbDepositsInStakePool;

    /**
     * @dev the amount of BNB held by this strategy that needs to be distributed back to the users after withdrawal.
     */
    uint256 private _bnbToDistribute;

    struct WithdrawRequest {
        address recipient;
        uint256 amount;
    }

    /**
     * @dev for bookkeeping the withdrawals initiated from this strategy so that they can later be claimed.
     * This mapping always contains reqs between [_startIndex, _endIndex).
     */
    mapping(uint256 => WithdrawRequest) private _withdrawReqs;
    uint256 private _startIndex;
    uint256 private _endIndex;

    event AddressStoreChanged(address addressStore);

    /// @dev initialize function - Constructor for Upgradable contract, can be only called once during deployment
    /// @param destination For our case, its the address of AddressStore contract, as that is constant by design not StakePool.
    /// @param rewards The address to which strategy earnings are transferred
    /// @param masterVault Address of the master vault contract
    /// @param addressStore The contract which holds all the other contract addresses in the stkBNB ecosystem.
    function initialize(
        address destination, // we will never use this in our impl, its there only for legacy purposes.
        address rewards,
        address masterVault,
        address addressStore
    ) public initializer {
        __BaseStrategy_init(destination, rewards, masterVault);

        _addressStore = IAddressStore(addressStore);
    }

    /// @dev to receive withdrawn funds back from StakePool
    receive() external payable override {
        require(
            msg.sender == _addressStore.getStakePool() ||
            msg.sender == strategist,
            "invalid sender"
        );
    }

    // to deposit funds to a destination contract
    function deposit() payable onlyVault external returns (uint256) {
        return _deposit(msg.value);
    }

    // to deposit this contract's existing balance to destination
    function depositAll() onlyStrategist external {
        _deposit(address(this).balance -_bnbToDistribute);
    }

    /// @dev internal function to deposit the given amount of BNB tokens into stakePool
    /// @param amount amount of BNB to deposit
    /// @return amount of BNB that this strategy owes to the master vault
    function _deposit(uint256 amount) whenDepositNotPaused internal returns (uint256) {
        IStakePool stakePool = IStakePool(_addressStore.getStakePool());
        // we don't accept dust, so just remove that. That will keep accumulating in this strategy contract, and later
        // can be deposited via `depositAll` (if it sums up to be more than just dust) OR withdrawn.
        uint256 dust = amount % stakePool.config().minBNBDeposit;
        uint256 dustFreeAmount = amount - dust;
        if (canDeposit(dustFreeAmount)) {
            stakePool.deposit{value : dustFreeAmount}(); // deposit the amount to stakePool in the name of this strategy
            uint256 amountDeposited = assessDepositFee(dustFreeAmount);
            _bnbDepositsInStakePool += amountDeposited; // keep track of _netDeposits in StakePool

            // add dust as that is still owed to the master vault
            return amountDeposited + dust;
        }

        // the amount was so small that it couldn't be deposited to destination but it would remain with this strategy,
        // => strategy still owes this to the master vault
        return amount;
    }

    // to withdraw funds from the destination contract
    function withdraw(address recipient, uint256 amount) onlyVault external returns (uint256) {
        return _withdraw(recipient, amount);
    }

    // withdraw all funds from the destination contract
    function panic() onlyStrategist external returns (uint256) {
        (,, uint256 debt) = vault.strategyParams(address(this));
        return _withdraw(address(vault), debt);
    }

    /// @dev internal function to withdraw the given amount of BNB from StakePool and transfer to masterVault
    /// @param amount amount of BNB to withdraw
    /// @return value - returns the amount of BNB withdrawn and sent back (or will be sent in future) to MasterVault
    function _withdraw(address recipient, uint256 amount) internal returns (uint256) {
        require(amount > 0, "invalid amount");

        uint256 ethBalance = address(this).balance;
        if (amount <= ethBalance) {
            payable(recipient).transfer(amount);
            return amount;
        }

        // otherwise, need to send all the balance of this strategy and also need to withdraw from the StakePool
        payable(recipient).transfer(ethBalance);
        amount -= ethBalance;

        // TODO(pSTAKE):
        // 1. There should be a utility function in our StakePool that should tell how much stkBNB to withdraw if I want
        //    `x` amount of BNB back, taking care of the withdrawal fee that is involved.
        // 2. We should also have something that takes care of withdrawing to a recipient, and not to the msg.sender
        // For now, the implementation here works, but can be improved in future with above two points.
        IStakePool stakePool = IStakePool(_addressStore.getStakePool());
        IStakedBNBToken stkBNB = IStakedBNBToken(_addressStore.getStkBNB());

        // reverse the BNB amount calculation from StakePool to get the stkBNB to burn
        ExchangeRate.Data memory exchangeRate = stakePool.exchangeRate();
        uint256 poolTokensToBurn = exchangeRate._calcPoolTokensForDeposit(amount);
        uint256 poolTokens = (poolTokensToBurn * 1e11) / (1e11 - stakePool.config().fee.withdraw);
        // poolTokens = the amount of stkBNB that needs to be sent to StakePool in order to get back `amount` BNB.

        // now, ensure that these poolTokens pass the minimum requirements for withdrawals set in StakePool.
        // if poolTokens < min => StakePool will reject this withdrawal with a revert => okay to let this condition be handled by StakePool.
        // if poolTokens have dust => we can remove that dust here, so that withdraw can happen if the poolTokens > min.
        poolTokens = poolTokens - (poolTokens % stakePool.config().minTokenWithdrawal);

        // now, this amount of poolTokens might not give us exactly the `amount` BNB we wanted to withdraw. So, better
        // calculate that again as we need to return the BNB amount that would actually get withdrawn.
        uint256 poolTokensFee = (poolTokens * stakePool.config().fee.withdraw) / 1e11;
        uint256 value = exchangeRate._calcWeiWithdrawAmount(poolTokens - poolTokensFee);
        require(value <= amount, "invalid out amount");

        // initiate withdrawal of stkBNB from StakePool for this strategy
        // this assumes that this strategy holds at least the amount of stkBNB poolTokens that we are trying to withdraw,
        // otherwise it will revert.
        stkBNB.send(address(stakePool), poolTokens, "");

        // save it so that we can later dispatch the amount to the recipient on claim
        _withdrawReqs[_endIndex++] = WithdrawRequest(recipient, value);

        // keep track of _netDeposits in StakePool
        _bnbDepositsInStakePool -= value;

        return value + ethBalance;
    }

    /// @dev Handy function to both claim the funds from StakePool and distribute it to the users in one go.
    /// Might result in out of gas issue, if there are too many withdrawals.
    function claimAndDistribute() external {
        claimAll();
        distribute(_endIndex);
    }

    /// @dev Call this manually to actually get the unstaked BNB back from StakePool after 15 days of withdraw.
    /// Claims all the claimable withdraw requests from StakePool. Ignores non-claimable requests.
    function claimAll() public {
        uint256 prevBalance = address(this).balance;
        // this can result in out of gas, if there have been too many withdraw requests from this Strategy
        IStakePool(_addressStore.getStakePool()).claimAll();

        _bnbToDistribute += address(this).balance - prevBalance;
    }

    // claims a single request from StakePool if it was claimable, i.e., has passed cooldown period of 15 days, reverts otherwise.
    // to be used as a failsafe, in case claimAll() gives out-of-gas issues.
    // You have to know the right index for this call to succeed.
    function claim(uint256 index) external {
        uint256 prevBalance = address(this).balance;
        IStakePool(_addressStore.getStakePool()).claim(index);
        _bnbToDistribute += address(this).balance - prevBalance;
    }

    /// @dev Anybody can call this, it will always distribute the amount to the original recipients to whom the withdraw was intended.
    /// @param endIdx the index (exclusive) till which to distribute the funds for withdraw requests
    function distribute(uint256 endIdx) public {
        require(endIdx <= _endIndex, "endIdx out of bound");

        // dispatch the amount in order of _withdrawReqs
        while (_bnbToDistribute > 0 || _startIndex < endIdx) {
            address recipient = _withdrawReqs[_startIndex].recipient;
            uint256 amount = _withdrawReqs[_startIndex].amount;
            if (amount > _bnbToDistribute) {
                // reqs is getting partially fulfilled
                amount = _bnbToDistribute;
                _withdrawReqs[_startIndex].amount -= amount;
            } else {
                // reqs is getting completely fulfilled. Delete it, and go to next index.
                delete _withdrawReqs[_startIndex++];
            }

            payable(recipient).transfer(amount);
            _bnbToDistribute -= amount;
        }
    }

    // claim or collect rewards functions
    function harvest() onlyStrategist external {
        IStakedBNBToken stkBNB = IStakedBNBToken(_addressStore.getStkBNB());
        uint256 stkBnbBalance = stkBNB.balanceOf(address(this));
        ExchangeRate.Data memory exchangeRate = IStakePool(_addressStore.getStakePool()).exchangeRate();

        uint256 depositsWithYield = exchangeRate._calcWeiWithdrawAmount(stkBnbBalance);
        uint256 yield = depositsWithYield - _bnbDepositsInStakePool;
        uint256 yieldStkBNB = exchangeRate._calcPoolTokensForDeposit(yield);

        // send the yield tokens to the reward address
        stkBNB.send(rewards, yieldStkBNB, "");
    }

    // calculate the total amount of tokens in the destination contract
    // @return Just the amount of BNB in our Pool deposited from this strategy excluding the generated yield.
    function balanceOfPool() public view override returns (uint256) {
        return _bnbDepositsInStakePool;
    }

    // returns true if assets can be deposited to destination contract
    function canDeposit(uint256 amount) public view returns (bool) {
        // just ensure min check, no need to enforce dust check here.
        // if amount is more than min, then deposit calls will take care of removing dust.
        if (amount < IStakePool(_addressStore.getStakePool()).config().minBNBDeposit) {
            return false;
        }
        return true;
    }

    // In our case, there is no relayer fee we charge as of now. We do charge a deposit fee (0% as of now) in terms of
    // the liquid token.
    //
    // returns the actual deposit amount (amount - depositFee, if any)
    function assessDepositFee(uint256 amount) public view returns (uint256) {
        return amount - (amount * IStakePool(_addressStore.getStakePool()).config().fee.deposit)/1e11;
    }

    // expose startIndex so that it can be used for initiating off-chain requests
    function startIndex() external view returns (uint256) {
        return _startIndex;
    }

    // expose endIndex so that it can be used for initiating off-chain requests
    function endIndex() external view returns (uint256) {
        return _endIndex;
    }

    /// @dev only owner can change addressStore
    /// @param addressStore new addressStore address
    function changeAddressStore(address addressStore) external onlyOwner {
        require(addressStore != address(0));
        _addressStore = IAddressStore(addressStore);
        emit AddressStoreChanged(addressStore);
    }

}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "../masterVault/interfaces/IMasterVault.sol";
import "./IBaseStrategy.sol";

abstract contract BaseStrategy is
IBaseStrategy,
OwnableUpgradeable,
PausableUpgradeable,
ReentrancyGuardUpgradeable {

    address public strategist;
    address public destination;
    address public rewards;

    bool public depositPaused;

    IMasterVault public vault;

    event UpdatedStrategist(address strategist);
    event UpdatedRewards(address rewards);

    function __BaseStrategy_init(
        address destinationAddr,
        address rewardsAddr,
        address masterVault
    ) internal initializer {
        __Ownable_init();
        __Pausable_init();
        __ReentrancyGuard_init();
        strategist = msg.sender;
        destination = destinationAddr;
        rewards = rewardsAddr;
        vault = IMasterVault(masterVault);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyStrategist() {
        require(msg.sender == strategist);
        _;
    }

    /**
     * @dev Throws if deposits are paused.
     */
    modifier whenDepositNotPaused() {
        require(!depositPaused, "deposits are paused");
        _;
    }

    /**
     * @dev Throws if called by any account other than the masterVault
     */
    modifier onlyVault() {
        require(msg.sender == address(vault), "!vault");
        _;
    }

    function balanceOfWant() public view returns(uint256) {
        return address(this).balance;
    }

    function balanceOfPool() public virtual view returns(uint256) {
        return address(destination).balance;
    }

    function balanceOf() public view returns(uint256) {
        return balanceOfWant() + balanceOfPool();
    }

    receive() external payable virtual {
        require(
            msg.sender == destination ||
            msg.sender == strategist,
            "invalid sender"
        );
    }

    function pause() external onlyStrategist {
        depositPaused = true;
    }

    function unpause() external onlyStrategist {
        depositPaused = false;
    }

    function setStrategist(address newStrategist) external onlyOwner {
        require(newStrategist != address(0));
        strategist = newStrategist;
        emit UpdatedStrategist(newStrategist);
    }
    
    function setRewards(address newRewardsAddr) external onlyOwner {
        require(newRewardsAddr != address(0));
        rewards = newRewardsAddr;
        emit UpdatedRewards(newRewardsAddr);
    }
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC777/IERC777.sol";

interface IStakedBNBToken is IERC777 {
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "../ExchangeRate.sol";

//// 1 stkBNB = (totalWei / poolTokenSupply) BNB
//// 1 BNB = (poolTokenSupply / totalWei) stkBNB
//// Over time, stkBNB appreciates in value as compared to BNB.
//struct ExchangeRateData {
//    uint256 totalWei; // total amount of BNB managed by the pool
//    uint256 poolTokenSupply; // total amount of stkBNB managed by the pool
//}

// External protocols (eg: Wombat Exchange) that integrate with us, rely on this interface.
// We must always ensure that StakePool conforms to this interface.
interface IStakePool {
    struct Config {
        // @dev The address of the staking wallet on the BBC chain. It will be used for transferOut transactions.
        // It needs to be correctly converted from a bech32 BBC address to a solidity address.
        address bcStakingWallet;
        // @dev The minimum amount of BNB required to initiate a cross-chain transfer from BSC to BC.
        // This should be at least minStakingAddrBalance + minDelegationAmount.
        // Ideally, this should be set to a value such that the protocol revenue from this value is more than the fee
        // lost on this value for cross-chain transfer/delegation/undelegation/etc.
        // But, finding the ideal value is non-deterministic.
        uint256 minCrossChainTransfer;
        // The timeout for the cross-chain transfer out operation in seconds.
        uint256 transferOutTimeout;
        // @dev The minimum amount of BNB required to make a deposit to the contract.
        uint256 minBNBDeposit;
        // @dev The minimum amount of tokens required to make a withdrawal from the contract.
        uint256 minTokenWithdrawal;
        // @dev The minimum amount of time (in seconds) a user has to wait after unstake to claim their BNB.
        // It would be 15 days on mainnet. 3 days on testnet.
        uint256 cooldownPeriod;
        // @dev The fee distribution to represent different kinds of fee.
        FeeDistribution fee;
    }

    struct FeeDistribution {
        uint256 reward;
        uint256 deposit;
        uint256 withdraw;
    }

    function config() external view returns (Config memory);

    function exchangeRate() external view returns (ExchangeRate.Data memory);

    function deposit() external payable;

    function claimAll() external;

    function claim(uint256 index) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

library ExchangeRate {

    // 1 stkBNB = (totalWei / poolTokenSupply) BNB
    // 1 BNB = (poolTokenSupply / totalWei) stkBNB
    // Over time, stkBNB appreciates in value as compared to BNB.
    struct Data {
        uint256 totalWei; // total amount of BNB managed by the pool
        uint256 poolTokenSupply; // total amount of stkBNB managed by the pool
    }

    function _calcPoolTokensForDeposit(Data memory self, uint256 weiAmount)
        internal
        pure
        returns (uint256)
    {
        if (self.totalWei == 0 || self.poolTokenSupply == 0) {
            return weiAmount;
        }
        return (weiAmount * self.poolTokenSupply) / self.totalWei;
    }

    function _calcWeiWithdrawAmount(Data memory self, uint256 poolTokens)
        internal
        pure
        returns (uint256)
    {
        uint256 numerator = poolTokens * self.totalWei;
        uint256 denominator = self.poolTokenSupply;

        if (numerator < denominator || denominator == 0) {
            return 0;
        }
        return numerator / denominator;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// import "./IERC4626Upgradeable.sol";

interface IMasterVault {
    event DepositFeeChanged(uint256 newDepositFee);
    event MaxDepositFeeChanged(uint256 newMaxDepositFee);
    event WithdrawalFeeChanged(uint256 newWithdrawalFee);
    event MaxWithdrawalFeeChanged(uint256 newMaxWithdrawalFee);
    event ProviderChanged(address provider);
    event RouterChanged(address ceRouter);
    event ManagerAdded(address newManager);
    event ManagerRemoved(address manager);
    event FeeReceiverChanged(address feeReceiver);
    event WaitingPoolChanged(address waitingPool);
    event WaitingPoolCapChanged(uint256 cap);
    event StrategyAllocationChanged(address strategy, uint256 allocation);
    event BinancePoolChanged(address binancePool);
    event StrategyAdded(address strategy, uint256 allocation);
    event StrategyMigrated(address oldStrategy, address newStrategy, uint256 newAllocation);
    event DepositedToStrategy(address strategy, uint256 amount);
    event WithdrawnFromStrategy(address strategy, uint256 value);

    function withdrawETH(address account, uint256 amount) external  returns (uint256);
    function depositETH() external payable returns (uint256);
    function feeReceiver() external returns (address payable);
    function withdrawalFee() external view returns (uint256);
    function strategyParams(address strategy) external view returns(bool active, uint256 allocation, uint256 debt);
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBaseStrategy {

    // to deposit funds to a destination contract
    function deposit() payable external returns(uint256);

    function depositAll() external;

    // to withdraw funds from the destination contract
    function withdraw(address recipient, uint256 amount) external returns(uint256);

    // claim or collect rewards functions
    function harvest() external;

    // withdraw all funds from the destination contract
    function panic() external returns (uint256);

    // disable deposit
    function pause() external;

    // enable deposit
    function unpause() external;

    // calculate the total underlying token in the strategy contract and destination contract
    function balanceOf() external view returns(uint256);

    // calculate the total amount of tokens in the strategy contract
    function balanceOfWant() external view returns(uint256);

    // calculate the total amount of tokens in the destination contract
    function balanceOfPool() external view returns(uint256);

    // set the rewards address(to which strategy earnings are transferred)
    function setRewards(address newFeeRecipient) external;

    // returns true if assets can be deposited to destination contract
    function canDeposit(uint256 amount) external view returns(bool);

    // returns the actual deposit amount (amount - depositFee, if any)
    function assessDepositFee(uint256 amount) external view returns(uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initialized`
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initializing`
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC777/IERC777.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC777Token standard as defined in the EIP.
 *
 * This contract uses the
 * https://eips.ethereum.org/EIPS/eip-1820[ERC1820 registry standard] to let
 * token holders and recipients react to token movements by using setting implementers
 * for the associated interfaces in said registry. See {IERC1820Registry} and
 * {ERC1820Implementer}.
 */
interface IERC777 {
    /**
     * @dev Emitted when `amount` tokens are created by `operator` and assigned to `to`.
     *
     * Note that some additional user `data` and `operatorData` can be logged in the event.
     */
    event Minted(address indexed operator, address indexed to, uint256 amount, bytes data, bytes operatorData);

    /**
     * @dev Emitted when `operator` destroys `amount` tokens from `account`.
     *
     * Note that some additional user `data` and `operatorData` can be logged in the event.
     */
    event Burned(address indexed operator, address indexed from, uint256 amount, bytes data, bytes operatorData);

    /**
     * @dev Emitted when `operator` is made operator for `tokenHolder`
     */
    event AuthorizedOperator(address indexed operator, address indexed tokenHolder);

    /**
     * @dev Emitted when `operator` is revoked its operator status for `tokenHolder`
     */
    event RevokedOperator(address indexed operator, address indexed tokenHolder);

    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the smallest part of the token that is not divisible. This
     * means all token operations (creation, movement and destruction) must have
     * amounts that are a multiple of this number.
     *
     * For most token contracts, this value will equal 1.
     */
    function granularity() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by an account (`owner`).
     */
    function balanceOf(address owner) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * If send or receive hooks are registered for the caller and `recipient`,
     * the corresponding functions will be called with `data` and empty
     * `operatorData`. See {IERC777Sender} and {IERC777Recipient}.
     *
     * Emits a {Sent} event.
     *
     * Requirements
     *
     * - the caller must have at least `amount` tokens.
     * - `recipient` cannot be the zero address.
     * - if `recipient` is a contract, it must implement the {IERC777Recipient}
     * interface.
     */
    function send(
        address recipient,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev Destroys `amount` tokens from the caller's account, reducing the
     * total supply.
     *
     * If a send hook is registered for the caller, the corresponding function
     * will be called with `data` and empty `operatorData`. See {IERC777Sender}.
     *
     * Emits a {Burned} event.
     *
     * Requirements
     *
     * - the caller must have at least `amount` tokens.
     */
    function burn(uint256 amount, bytes calldata data) external;

    /**
     * @dev Returns true if an account is an operator of `tokenHolder`.
     * Operators can send and burn tokens on behalf of their owners. All
     * accounts are their own operator.
     *
     * See {operatorSend} and {operatorBurn}.
     */
    function isOperatorFor(address operator, address tokenHolder) external view returns (bool);

    /**
     * @dev Make an account an operator of the caller.
     *
     * See {isOperatorFor}.
     *
     * Emits an {AuthorizedOperator} event.
     *
     * Requirements
     *
     * - `operator` cannot be calling address.
     */
    function authorizeOperator(address operator) external;

    /**
     * @dev Revoke an account's operator status for the caller.
     *
     * See {isOperatorFor} and {defaultOperators}.
     *
     * Emits a {RevokedOperator} event.
     *
     * Requirements
     *
     * - `operator` cannot be calling address.
     */
    function revokeOperator(address operator) external;

    /**
     * @dev Returns the list of default operators. These accounts are operators
     * for all token holders, even if {authorizeOperator} was never called on
     * them.
     *
     * This list is immutable, but individual holders may revoke these via
     * {revokeOperator}, in which case {isOperatorFor} will return false.
     */
    function defaultOperators() external view returns (address[] memory);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient`. The caller must
     * be an operator of `sender`.
     *
     * If send or receive hooks are registered for `sender` and `recipient`,
     * the corresponding functions will be called with `data` and
     * `operatorData`. See {IERC777Sender} and {IERC777Recipient}.
     *
     * Emits a {Sent} event.
     *
     * Requirements
     *
     * - `sender` cannot be the zero address.
     * - `sender` must have at least `amount` tokens.
     * - the caller must be an operator for `sender`.
     * - `recipient` cannot be the zero address.
     * - if `recipient` is a contract, it must implement the {IERC777Recipient}
     * interface.
     */
    function operatorSend(
        address sender,
        address recipient,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the total supply.
     * The caller must be an operator of `account`.
     *
     * If a send hook is registered for `account`, the corresponding function
     * will be called with `data` and `operatorData`. See {IERC777Sender}.
     *
     * Emits a {Burned} event.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     * - the caller must be an operator for `account`.
     */
    function operatorBurn(
        address account,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;

    event Sent(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 amount,
        bytes data,
        bytes operatorData
    );
}