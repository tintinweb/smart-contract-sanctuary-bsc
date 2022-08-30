/**
 *Submitted for verification at BscScan.com on 2022-08-29
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;



// Part: IFaucet

interface IFaucet {
    function accounting(address _user)
        external
        view
        returns (
            uint256 netFaucet, // User level NetFaucetValue
            // Detail of netFaucet
            uint256 deposits, // Hard Deposits made
            uint256 rolls, // faucet Compounds
            uint256 rebaseCompounded, // RebaseCompounds
            uint256 airdrops_rcv, // Received Airdrops
            uint256 accFaucet, // accumulated but not claimed faucet due to referrals
            uint256 accRebase, // accumulated but not claimed rebases
            // Total Claims
            uint256 faucetClaims,
            uint256 rebaseClaims,
            uint256 rebaseCount,
            uint256 lastAction,
            bool done
        );

    function team(address _user)
        external
        view
        returns (
            uint256 referrals, // People referred
            address upline, // Who my referrer is
            uint256 upline_set, // Last time referrer set
            uint256 refClaimRound, // Whose turn it is to claim referral rewards
            uint256 match_bonus, // round robin distributed
            uint256 lastAirdropSent,
            uint256 airdrops_sent,
            uint256 structure, // Total users under structure
            uint256 maxDownline,
            // Team Swap
            uint256 referralsToUpdate, // Users who haven't updated if team was switched
            address prevUpline, // If updated team, who the previous upline user was to switch user's referrals
            uint256 leaders
        );

    function deposit(uint256 amount, address upline) external;

    function claim() external;

    function switchTeam(address _newUpline) external;

    function checkVault()
        external
        view
        returns (
            uint256 _status,
            uint256 _needs,
            uint256 _threshold,
            uint256 _vaultBalance
        );

    //----------------------------------------------
    //                  EVENTS                    //
    //----------------------------------------------
    event NewDeposit(address indexed _user, uint256 amount);
    event ReferralPayout(
        address indexed _upline,
        address indexed _teammate,
        uint256 amount
    );
    event DirectPayout(
        address indexed addr,
        address indexed from,
        uint256 amount
    );
    event MatchPayout(
        address indexed addr,
        address indexed from,
        uint256 amount
    );
    event NewAirdrop(
        address indexed from,
        address indexed to,
        uint256 amount,
        uint256 timestamp
    );
    event Withdraw(address indexed addr, uint256 amount);
    event LimitReached(address indexed addr, uint256 amount);
}

// Part: IToken

interface IToken {
    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function mint(uint256 amount) external;

    function balanceOf(address _user) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    /**
     @return taxAmount // total Tax Amount
     @return taxType // How the tax will be distributed
    */
    function calculateTransferTax(
        address from,
        address to,
        uint256 amount
    ) external returns (uint256 taxAmount, uint8 taxType);

    function approve(address spender, uint256 amount) external returns (bool);
}

// Part: ITokenLocker

interface ITokenLocker {
    function updateLock() external;
}

// Part: IVault

interface IVault {
    /**
    * @param amount total amount of tokens to recevie
    * @param _type type of spread to execute.
      Stake Vault - Reservoir Collateral - Treasury
      0: do nothing
      1: Buy Spread 5 - 5 - 3
      2: Sell Spread 5 - 5 - 8
    * @param _customTaxSender the address where the tax is originated from.
      @return bool as successful spread op
    **/
    function spread(
        uint256 amount,
        uint8 _type,
        address _customTaxSender
    ) external returns (bool);

    function withdraw(address _address, uint256 amount) external;

    function withdraw(uint256 amount) external;
}

// Part: OpenZeppelin/[email protected]/Context

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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// Part: OpenZeppelin/[email protected]/IERC20

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// Part: OpenZeppelin/[email protected]/ReentrancyGuard

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
abstract contract ReentrancyGuard {
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

    constructor() {
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
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// Part: IFountain

interface IFountain is IERC20 {
    function removeLiquidity(
        uint256 amount,
        uint256 min_bnb,
        uint256 min_tokens
    ) external returns (uint256, uint256);

    function addLiquidity(
        uint256 min_liquidity,
        uint256 max_tokens,
        uint256 busd_amount
    ) external returns (uint256);

    function txs(address owner) external view returns (uint256);

    function getLiquidityToReserveInputPrice(uint256 amount)
        external
        view
        returns (uint256, uint256);

    function getBnbToLiquidityInputPrice(uint256 bnb_sold)
        external
        view
        returns (uint256, uint256);

    function tokenBalance() external view returns (uint256);

    function bnbBalance() external view returns (uint256);

    function tokenAddress() external view returns (address);

    function getTokenToBnbOutputPrice(uint256 bnb_bought)
        external
        view
        returns (uint256);

    function getTokenToBnbInputPrice(uint256 tokens_sold)
        external
        view
        returns (uint256);

    function getBnbToTokenOutputPrice(uint256 tokens_bought)
        external
        view
        returns (uint256);

    function getBnbToTokenInputPrice(uint256 bnb_sold)
        external
        view
        returns (uint256);

    function tokenToBnbSwapOutput(uint256 bnb_bought, uint256 max_tokens)
        external
        returns (uint256);

    function tokenToBnbSwapInput(uint256 tokens_sold, uint256 min_bnb)
        external
        returns (uint256);

    function bnbToTokenSwapOutput(uint256 tokens_bought)
        external
        payable
        returns (uint256);

    function bnbToTokenSwapInput(uint256 min_tokens, uint256 busd_amount)
        external
        payable
        returns (uint256);

    function getOutputPrice(
        uint256 output_amount,
        uint256 input_reserve,
        uint256 output_reserve
    ) external view returns (uint256);

    function getInputPrice(
        uint256 input_amount,
        uint256 input_reserve,
        uint256 output_reserve
    ) external view returns (uint256);
}

// Part: OpenZeppelin/[email protected]/Ownable

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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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
}

// File: Foundation.sol

contract Foundation is Ownable, ReentrancyGuard {
    struct Investment {
        uint256 lpDouble; // The double amount since we provided half of STAKE
        uint256 lpSingle; // Thhe user input the full LP (BNB swapped to STAKE) and added LP
        uint256 claimed; // bnb CLAIMED
        uint256 rewarded; // LP rewarded
        uint256 debt; // DEBT for Rewards
        uint256 busdDeposit; // bnb Deposited, not sure if worth it since BNB is buying lP and is subject to impermanent loss
        uint256 withdraws; // BUSD withdraws
    }

    IToken public stake;
    IToken public busd;
    IVault public vault;
    IFountain public pol;
    ITokenLocker public locker;
    IFaucet public faucet;
    address public paybackWallet;

    uint8 public paybackFee = 20; // 20% of vault fee
    uint8 public vaultFee = 5;
    uint8 public rewardFee = 2;
    uint8 public lockFee = 3;
    uint8 public compoundFee = 5;

    uint256 public constant PRECISION_FACTOR = 1e12;
    uint256 public VAULT_THRESHOLD;

    uint256 public totalDouble;
    uint256 public totalSingle;
    uint256 public totalStaked;
    uint256 public accRewardsPerShare;

    uint256 public providers;

    uint256 public distributedRewards;
    uint256 public totalLocked;

    mapping(address => Investment) public investment;

    // EVENTS
    event Deposit(address indexed _user, uint256 bnbDeposit, uint256 lpAmount);
    event Withdraw(address indexed _user, uint256 bnbWithdraw);
    event Compound(
        address indexed _user,
        uint256 _lp_rewarded,
        uint256 _lp_tax
    );
    event Log(string _description, uint256 _val);
    event AuditLog(string _description, address _address);
    event Claimed(address indexed _user, uint256 _lp_amount, uint256 _bnb);
    event Lock(address indexed _user, uint256 lockAmount);
    event CreatedLP(uint256 _amount);
    event Vaulted(address indexed _user, uint256 vaultAmount);
    event AddToRewards(uint256 _shareDiv);
    event RewardShareIncrease(uint256 _newRewardShare);
    event IncreasedStake(uint256 _totalStaked, bool _here);
    event FeesUpdated(
        uint8 _newVault,
        uint8 _oldVault,
        uint8 _newReward,
        uint8 _oldReward,
        uint8 _newLock,
        uint8 _oldLock,
        uint8 _newCompound,
        uint8 _oldCompound
    );
    event LogTokenApproval(
        address indexed _token,
        address _spender,
        uint256 _amount
    );

    constructor(
        address _vault,
        address _stake,
        address _busd,
        address _payback,
        address _faucet
    ) {
        require(
            _vault != address(0) &&
                _stake != address(0) &&
                _busd != address(0) &&
                _payback != address(0) &&
                _faucet != address(0),
            "Cant with address 0"
        );
        // When deploying make sure that this contract is tax free on STAKE and POL
        vault = IVault(_vault);
        stake = IToken(_stake);
        busd = IToken(_busd);
        VAULT_THRESHOLD = 120;
        paybackWallet = _payback;
        faucet = IFaucet(_faucet);
    }

    // ----
    // RUn once functions
    // ----
    function setPolData(address _pol, address _locker) external onlyOwner {
        require(
            address(pol) == address(0) && address(locker) == address(0),
            "Already set"
        );
        pol = IFountain(_pol);
        locker = ITokenLocker(_locker);
    }

    // ------------------
    // EXTERNAL FUNCTIONS
    // ------------------
    function deposit(uint256 busdAmount) external nonReentrant {
        require(busdAmount > 1 ether, "Less than minimum");
        require(
            busd.transferFrom(msg.sender, address(this), busdAmount),
            "Failed BUSD Transfer"
        );
        // GET TOTAL BNB AMOUNT
        busd.approve(address(pol), busdAmount);

        uint256 taxAmount = (busdAmount * vaultFee) / 100;
        Investment storage user = investment[msg.sender];
        user.busdDeposit += busdAmount;

        busdAmount -= taxAmount;
        // TAKE BUSD for payback
        if (paybackFee > 0) {
            uint256 payback = (taxAmount * paybackFee) / 100;
            taxAmount -= payback;
            require(busd.transfer(paybackWallet, payback), "Need to payback");
        }
        //update totalStaked and already allocated rewards.
        if (pendingToDistribute() > 0) distributePending();
        bool firstDeposit = user.lpDouble + user.lpSingle == 0;
        if (!firstDeposit) {
            _compound(msg.sender);
        } else {
            providers++;
        }
        // Get vault threshold and only withdraw as long as status < needed ( use checkvault() from Faucet )
        (uint256 stakeNeeded, , , uint256 vaultBalance) = faucet.checkVault();
        uint256 stLpAvail = 0;
        if ((stakeNeeded * VAULT_THRESHOLD) / 100 < vaultBalance)
            stLpAvail = vaultBalance - stakeNeeded;

        // GET STAKE AMOUNT NEEDED FOR LIQUIDITY
        (, stakeNeeded) = pol.getBnbToLiquidityInputPrice(busdAmount);
        // Approve STAKE and BUSD for spend
        stake.approve(address(pol), stakeNeeded);

        bool notEnough = stakeNeeded > stLpAvail;
        if (notEnough) {
            stakeNeeded = pol.bnbToTokenSwapInput(
                1,
                (busdAmount / 2) + taxAmount
            );
            busdAmount -= busdAmount / 2;
        } else {
            vault.withdraw(stakeNeeded);
            pol.bnbToTokenSwapInput(1, taxAmount);
        }
        stLpAvail = pol.addLiquidity(1, stakeNeeded, busdAmount);
        emit CreatedLP(stLpAvail);
        taxAmount = (stLpAvail * lockFee) / 95;
        totalLocked += taxAmount;
        require(pol.transfer(address(locker), taxAmount), "Failed lock");
        emit Lock(msg.sender, taxAmount);
        locker.updateLock();
        if (providers > 1) {
            emit AddToRewards((stLpAvail * rewardFee) / 95);
            stLpAvail -= (taxAmount + (stLpAvail * rewardFee) / 95);
        } else stLpAvail -= taxAmount;
        totalStaked += stLpAvail;
        totalStaked = increaseRewardsForOthers(msg.sender);

        // Whatever was not liquified send to vault or back to user
        emit Deposit(msg.sender, busdAmount, stLpAvail);
        busdAmount = busd.balanceOf(address(this));
        if (busdAmount > 0) {
            busd.transfer(msg.sender, busdAmount);
            user.busdDeposit -= busdAmount;
        }
        uint256 _stakeVaulted = stake.balanceOf(address(this));
        emit Vaulted(msg.sender, _stakeVaulted);
        stake.transfer(address(vault), _stakeVaulted);
        // Update User values
        user.lpSingle += notEnough ? stLpAvail : 0;
        user.lpDouble += notEnough ? 0 : stLpAvail;
        user.debt = getRewardAmount(user.lpDouble, user.lpSingle);
        totalSingle += notEnough ? stLpAvail : 0;
        totalDouble += notEnough ? 0 : stLpAvail;
    }

    function distributePending() public {
        uint256 currentBalance = increaseAccRewards();
        totalStaked = currentBalance;
    }

    function pendingToDistribute() public view returns (uint256) {
        uint256 currentBalance = pol.balanceOf(address(this));
        if (currentBalance > totalStaked) return currentBalance - totalStaked;
        return 0;
    }

    function increaseAccRewards() internal returns (uint256) {
        uint256 currentBalance = pol.balanceOf(address(this));
        if (currentBalance > totalStaked && totalStaked > 0) {
            distributedRewards += currentBalance - totalStaked;
            accRewardsPerShare +=
                ((currentBalance - totalStaked) * PRECISION_FACTOR) /
                ((totalSingle * 2) + totalDouble);
        }
        return currentBalance;
    }

    function increaseRewardsForOthers(address _user)
        internal
        returns (uint256)
    {
        Investment storage user = investment[_user];
        uint256 currentBalance = pol.balanceOf(address(this));
        if (currentBalance > totalStaked && totalStaked > 0) {
            uint256 rewardsToDistribute = currentBalance - totalStaked;
            distributedRewards += rewardsToDistribute;
            uint256 numerator = rewardsToDistribute * PRECISION_FACTOR;
            uint256 denominator = (totalSingle - user.lpSingle) * 2;
            denominator += totalDouble - user.lpDouble;
            // increase shares only if there are other people to distribute to
            if (denominator > 0) {
                emit Log("Dividends Distributed", rewardsToDistribute);
                accRewardsPerShare += numerator / denominator;
            }
        }
        return currentBalance;
    }

    function _compound(address _user) internal {
        Investment storage user = investment[_user];
        uint256 rewarded = getRewardAmount(user.lpDouble, user.lpSingle);
        uint256 prevDebt = user.debt;
        if (rewarded > user.debt) {
            user.debt = rewarded;
            rewarded -= prevDebt;
            uint256 tax = (rewarded * compoundFee) / 100;

            rewarded -= tax;
            totalStaked -= tax;
            totalLocked += tax;
            pol.transfer(address(locker), tax);
            locker.updateLock();
            user.rewarded += rewarded;
            user.lpDouble += rewarded;
            totalDouble += rewarded;
            user.debt = getRewardAmount(user.lpDouble, user.lpSingle);
            emit Compound(_user, rewarded, tax);
        } else {
            emit AuditLog("Nothing to Compound", _user);
        }
    }

    function getRewardAmount(uint256 _double, uint256 _single)
        internal
        view
        returns (uint256)
    {
        return
            (accRewardsPerShare * (_double + (_single * 2))) / PRECISION_FACTOR;
    }

    function compoundReward() external nonReentrant {
        require(totalStaked > 0, "Nothing Staked");
        if (pendingToDistribute() > 0) distributePending();
        _compound(msg.sender);
    }

    function claimReward() external nonReentrant {
        require(totalStaked > 0, "Nothing Staked");
        if (pendingToDistribute() > 0) distributePending();
        _claim(msg.sender);
    }

    function _claim(address _user) internal {
        Investment storage user = investment[_user];
        uint256 rewarded = getRewardAmount(user.lpDouble, user.lpSingle);
        uint256 prevDebt = user.debt;
        if (rewarded > user.debt) {
            rewarded -= prevDebt;
            // get currentLiquidity
            uint256 currentBalance = pol.balanceOf(address(this));
            uint256 divSpread = (rewarded * rewardFee) / 100; // 2%
            uint256 lockLiquidity = (rewarded * lockFee) / 100; // 3%
            uint256 removedLiq = rewarded - divSpread - lockLiquidity;
            uint8 nonLpTotal = 100 - rewardFee - lockFee;
            // lockTokens
            if (lockLiquidity > 0) {
                totalLocked += lockLiquidity;
                pol.transfer(address(locker), lockLiquidity);
                locker.updateLock();
            }
            // remove liquidity of rest
            pol.removeLiquidity(removedLiq, 1, 1);

            uint256 _busd = busd.balanceOf(address(this));
            uint256 swap = (_busd * vaultFee) / nonLpTotal;

            if (paybackFee > 0) {
                uint256 payback = (swap * paybackFee) / 100;
                swap -= payback;
                require(
                    busd.transfer(paybackWallet, payback),
                    "Need to payback"
                );
            }

            busd.approve(address(pol), _busd);
            pol.bnbToTokenSwapInput(1, swap);
            _busd = busd.balanceOf(address(this));
            removedLiq =
                ((currentBalance - pol.balanceOf(address(this))) *
                    (nonLpTotal - vaultFee)) /
                nonLpTotal;
            // update totalStaked since we're basically removing all that will be rewarded to the user.
            totalStaked -= rewarded;
            totalStaked = increaseRewardsForOthers(_user); // distribute pending
            user.debt = getRewardAmount(user.lpDouble, user.lpSingle);
            // Amount that was actually converted to BNB
            user.rewarded += removedLiq; //Reduce it again to get 10% since the second 5% is converted from the reward BNB
            //user gets the BNB;
            user.claimed += _busd;
            bool succ = busd.transfer(_user, _busd);
            require(succ, "FAIL BUSD CLAIM");
            emit Claimed(_user, rewarded, _busd);
            // Stake gets sent to VAULT

            uint256 _stakeVaulted = stake.balanceOf(address(this));
            emit Vaulted(_user, _stakeVaulted);
            stake.transfer(address(vault), _stakeVaulted);
        } else {
            emit AuditLog("Nothing to Claim", _user);
        }
    }

    function pendingRewards(address _user) external view returns (uint256) {
        Investment storage user = investment[_user];
        uint256 rewards = getRewardAmount(user.lpDouble, user.lpSingle);
        return rewards - user.debt;
    }

    function withdraw(uint256 amount) external nonReentrant {
        require(totalStaked > 0, "Nothing Staked");
        require(amount > 0, "Amount = 0");
        uint256 retrievedAmount = amount;
        Investment storage user = investment[msg.sender];
        require(user.lpDouble + user.lpSingle >= amount, "too much");
        if (pendingToDistribute() > 0) distributePending();
        _claim(msg.sender);
        uint256 retrieveDouble = amount;
        uint256 retrieveSingle;
        if (user.lpDouble < amount) {
            retrieveSingle = retrieveDouble - user.lpDouble;
            retrieveDouble -= retrieveSingle;
        }
        user.lpDouble -= retrieveDouble;
        user.lpSingle -= retrieveSingle;
        totalDouble -= retrieveDouble;
        totalSingle -= retrieveSingle;
        totalStaked -= amount;
        if (user.lpDouble + user.lpSingle == 0) providers--;
        // Lock Tax (3% sent to Pol locker and locker is updated)
        uint256 exitTax = (amount * lockFee) / 100;
        if (exitTax > 0) {
            retrievedAmount -= exitTax;
            totalLocked += exitTax;
            pol.transfer(address(locker), exitTax);
            locker.updateLock();
        }
        // Distribute Tax
        exitTax = (amount * rewardFee) / 100;
        retrievedAmount -= exitTax;
        uint256 remainderBUSDPercent = 100 - rewardFee - lockFee;
        (uint256 _busd, uint256 _stake) = pol.removeLiquidity(
            retrievedAmount,
            1,
            1
        );
        totalStaked = increaseRewardsForOthers(msg.sender);
        user.debt = getRewardAmount(user.lpDouble, user.lpSingle);

        uint256 swapStaked = (retrieveSingle * _stake) / amount;
        stake.approve(address(pol), swapStaked);
        if (swapStaked > 0) _busd += pol.tokenToBnbSwapInput(swapStaked, 1);
        // Stake Tax (5% sent to vault)
        exitTax = (_busd * vaultFee) / remainderBUSDPercent;
        _busd -= exitTax;
        if (paybackFee > 0) {
            uint256 payback = (exitTax * paybackFee) / 100;
            exitTax -= payback;
            require(busd.transfer(paybackWallet, payback), "Need to payback");
        }
        busd.approve(address(pol), exitTax);
        pol.bnbToTokenSwapInput(1, exitTax);
        uint256 _stakeVaulted = stake.balanceOf(address(this));
        emit Vaulted(msg.sender, _stakeVaulted);
        stake.transfer(address(vault), _stakeVaulted);
        user.withdraws += _busd;
        bool succ = busd.transfer(msg.sender, _busd);
        require(succ, "Fail withdraw");
        emit Withdraw(msg.sender, _busd);
    }

    function setFees(
        uint8 _vaultFee,
        uint8 _rewardFee,
        uint8 _lockFee,
        uint8 _compoundFee
    ) external onlyOwner {
        require(_vaultFee + _rewardFee + _lockFee <= 10, "fees too high");
        require(_compoundFee <= 5, "compound fees too high");
        emit FeesUpdated(
            _vaultFee,
            vaultFee,
            _rewardFee,
            rewardFee,
            _lockFee,
            lockFee,
            _compoundFee,
            compoundFee
        );
        vaultFee = _vaultFee;
        rewardFee = _rewardFee;
        lockFee = _lockFee;
        compoundFee = _compoundFee;
    }

    function removePayback() external onlyOwner {
        require(paybackFee > 0, "Already removed");
        paybackFee = 0;
        emit Log("Removed PaybackFee", paybackFee);
    }

    function editPayback(address _payback) external onlyOwner {
        require(paybackFee > 0, "payback is Over");
        require(_payback != owner(), "cant be owner");
        paybackWallet = _payback;
    }

    function setVaultThreshold(uint256 _newThreshold) external onlyOwner {
        require(_newThreshold >= 100, "Cant reduce vault too much");
        VAULT_THRESHOLD = _newThreshold;
    }

    function approveToken(address _tokenAddress, uint256 _value)
        external
        onlyOwner
    {
        IToken token = IToken(_tokenAddress);
        token.approve(msg.sender, _value); //Approval of spacific amount or more, this will be an idependent approval

        emit LogTokenApproval(_tokenAddress, msg.sender, _value);
    }

    function setUser(
        address _user,
        uint256 lpSingle,
        uint256 lpDouble,
        uint256 prevDeposits,
        uint256 prevWithdraws
    ) external onlyOwner {
        Investment storage user = investment[_user];
        require(user.lpDouble + user.lpSingle == 0, "Set");
        require(lpDouble + lpSingle > 0, "=0");

        pol.transferFrom(msg.sender, address(this), lpSingle + lpDouble);
        totalStaked += lpSingle + lpDouble;
        user.lpDouble = lpDouble;
        user.lpSingle = lpSingle;
        totalDouble += lpDouble;
        totalSingle += lpSingle;
        user.busdDeposit = prevDeposits;
        user.withdraws = prevWithdraws;
        user.debt = getRewardAmount(user.lpDouble, user.lpSingle);
        providers++;
    }

    function setUserDebt(address _user) external onlyOwner {
        Investment storage user = investment[_user];
        user.debt = getRewardAmount(user.lpDouble, user.lpSingle);
    }
}