/**
 *Submitted for verification at BscScan.com on 2022-06-17
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;



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

contract Foundation is Ownable {
    struct Investment {
        uint256 lpDouble; // The double amount since we provided half of STAKE
        uint256 lpSingle; // Thhe user input the full LP (BNB swapped to STAKE) and added LP
        uint256 claimed; // bnb CLAIMED
        uint256 rewarded; // LP rewarded
        uint256 debt; // DEBT for Rewards
        uint256 busdDeposit; // bnb Deposited, not sure if worth it since BNB is buying lP and is subject to impermanent loss
    }

    IToken public stake;
    IToken public busd;
    IVault public vault;
    IFountain public pol;
    ITokenLocker public locker;

    uint256 public constant PRECISION_FACTOR = 1e12;
    uint256 public VAULT_THRESHOLD;

    uint256 public totalDouble;
    uint256 public totalSingle;
    uint256 public totalStaked;
    uint256 public accRewardsPerShare;

    uint256 public constant DIV = 1000;
    uint256 public depositTax = 100; // 10% vs DIV
    uint256 public withdrawTax = 100; // 10% vs DIV
    uint256 public compoundTax = 50; // 5% vs DIV

    uint256 public distributedRewards;

    mapping(address => Investment) public investment;

    // EVENTS
    event Deposit(address indexed _user, uint256 bnbDeposit, uint256 lpAmount);
    event Withdraw(address indexed _user, uint256 bnbWithdraw);
    event Compound(
        address indexed _user,
        uint256 _lp_rewarded,
        uint256 _lp_tax
    );
    event Claimed(address indexed _user, uint256 _lp_amount, uint256 _bnb);
    event Lock(address indexed _user, uint256 lockAmount);
    event CreatedLP(uint256 _amount);
    event Vaulted(address indexed _user, uint256 vaultAmount);
    event AddToRewards(uint256 _shareDiv);
    event RewardShareIncrease(uint256 _newRewardShare);
    event IncreasedStake(uint256 _totalStaked, bool _here);

    constructor(
        address _vault,
        address _stake,
        address _busd
    ) {
        // When deploying make sure that this contract is tax free on STAKE and POL
        vault = IVault(_vault);
        stake = IToken(_stake);
        busd = IToken(_busd);
        VAULT_THRESHOLD = 10;
    }

    // ----
    // RUn once functions
    // ----
    function setPolData(address _pol, address _locker) external onlyOwner {
        require(address(pol) == address(0), "Already set");
        pol = IFountain(_pol);
        locker = ITokenLocker(_locker);
    }

    // ------------------
    // EXTERNAL FUNCTIONS
    // ------------------
    function deposit(uint256 busdAmount) external {
        bool succ = busd.transferFrom(msg.sender, address(this), busdAmount);
        require(succ, "Failed BUSD Transfer");
        // GET TOTAL BNB AMOUNT
        busd.approve(address(pol), busdAmount);

        require(busdAmount > 0.01 ether, "Less than minimum");
        uint256 taxAmount = (busdAmount * 5) / 100;
        Investment storage user = investment[msg.sender];
        user.busdDeposit += busdAmount;

        busdAmount -= taxAmount;
        //update totalStaked and already allocated rewards.
        distributePending();
        bool firstDeposit = user.lpDouble + user.lpSingle == 0;
        if (!firstDeposit) {
            _compound(msg.sender);
        }
        // GET STAKE AMOUNT NEEDED FOR LIQUIDITY
        (, uint256 stakeNeeded) = pol.getBnbToLiquidityInputPrice(busdAmount);
        uint256 stLpAvail = (stake.balanceOf(address(vault)) *
            VAULT_THRESHOLD) / 100;
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
        taxAmount = (stLpAvail * 3) / 95;
        require(pol.transfer(address(locker), taxAmount), "Failed lock");
        emit Lock(msg.sender, taxAmount);
        locker.updateLock();
        if (totalStaked > 0) {
            emit AddToRewards((stLpAvail * 2) / 95);
            stLpAvail -= (taxAmount + (stLpAvail * 2) / 95);
        } else stLpAvail -= taxAmount;
        totalStaked += stLpAvail;
        distributePending();

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
        if (firstDeposit)
            user.debt = getRewardAmount(user.lpDouble, user.lpSingle);
        totalSingle += notEnough ? stLpAvail : 0;
        totalDouble += notEnough ? 0 : stLpAvail;
    }

    function distributePending() public {
        uint256 currentBalance = increaseAccRewards();
        totalStaked = currentBalance;
    }

    function pendingToDistribute() external view returns (uint256) {
        uint256 currentBalance = pol.balanceOf(address(this));
        return currentBalance - totalStaked;
    }

    function increaseAccRewards() internal returns (uint256) {
        uint256 currentBalance = pol.balanceOf(address(this));
        if (currentBalance > totalStaked && totalStaked > 0) {
            distributedRewards += currentBalance - totalStaked;
            accRewardsPerShare +=
                ((currentBalance - totalStaked) * PRECISION_FACTOR) /
                ((totalSingle * 2) + totalDouble);
            return currentBalance;
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
            uint256 tax = (rewarded * 5) / 100;

            rewarded -= tax;
            pol.transfer(address(locker), tax);
            locker.updateLock();
            user.rewarded += rewarded;
            user.lpDouble += rewarded;
            totalDouble += rewarded;
            emit Compound(_user, rewarded, tax);
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

    function compoundReward() external {
        distributePending();
        _compound(msg.sender);
    }

    function claimReward() external {
        distributePending();
        _claim(msg.sender);
    }

    function _claim(address _user) internal {
        Investment storage user = investment[_user];
        uint256 rewarded = getRewardAmount(user.lpDouble, user.lpSingle);
        uint256 prevDebt = user.debt;
        if (rewarded > user.debt) {
            user.debt = rewarded;
            rewarded -= prevDebt;
            // get currentLiquidity

            uint256 currentBalance = pol.balanceOf(address(this));
            uint256 divSpread = (rewarded * 2) / 100; // 5%
            uint256 lockLiquidity = (rewarded * 3) / 100;
            uint256 removedLiq = rewarded - divSpread - lockLiquidity;
            pol.removeLiquidity(removedLiq, 1, 1);
            uint256 _busd = busd.balanceOf(address(this));
            uint256 swap = (_busd * 5) / 95;
            busd.approve(address(pol), _busd);
            pol.bnbToTokenSwapInput(1, swap);
            _busd = busd.balanceOf(address(this));
            removedLiq = currentBalance - pol.balanceOf(address(this));
            // tax is transfered to locker
            pol.transfer(address(locker), lockLiquidity);
            locker.updateLock();
            totalStaked -= removedLiq + lockLiquidity;
            distributePending(); // distribute pending
            // Amount that was actually converted to BNB
            user.rewarded += removedLiq - divSpread - lockLiquidity; //Reduce it again to get 10% since the second 5% is converted from the reward BNB
            //user gets the BNB;
            user.claimed += _busd;
            bool succ = busd.transfer(msg.sender, _busd);
            require(succ, "FAIL BUSD CLAIM");
            emit Claimed(_user, rewarded, _busd);
            // Stake gets sent to VAULT

            uint256 _stakeVaulted = stake.balanceOf(address(this));
            emit Vaulted(msg.sender, _stakeVaulted);
            stake.transfer(address(vault), _stakeVaulted);
        }
    }

    function pendingRewards(address _user) external view returns (uint256) {
        Investment storage user = investment[_user];
        uint256 rewards = getRewardAmount(user.lpDouble, user.lpSingle);
        return rewards - user.debt;
    }

    function withdraw(uint256 amount) external {
        require(amount > 0, "Amount = 0");
        uint256 retrievedAmount = amount;
        Investment storage user = investment[msg.sender];
        require(user.lpDouble + user.lpSingle >= amount, "too much");
        distributePending();
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
        // Lock Tax (3% sent to Pol locker and locker is updated)
        uint256 exitTax = (amount * 3) / 100;
        retrievedAmount -= exitTax;
        pol.transfer(address(locker), exitTax);
        locker.updateLock();
        // Distribute Tax
        exitTax = (amount * 2) / 100;
        retrievedAmount -= exitTax;

        (uint256 _busd, uint256 _stake) = pol.removeLiquidity(
            retrievedAmount,
            1,
            1
        );
        distributePending();

        uint256 swapStaked = (retrieveSingle * _stake) / amount;
        if (swapStaked > 0) _busd += pol.tokenToBnbSwapInput(swapStaked, 0);
        // Stake Tax (5% sent to vault)
        exitTax = (_busd * 5) / 95;
        _busd -= exitTax;
        busd.approve(address(pol), exitTax);
        pol.bnbToTokenSwapInput(1, exitTax);
        uint256 _stakeVaulted = stake.balanceOf(address(this));
        emit Vaulted(msg.sender, _stakeVaulted);
        stake.transfer(address(vault), _stakeVaulted);
        bool succ = busd.transfer(msg.sender, _busd);
        require(succ, "Fail withdraw");
        emit Withdraw(msg.sender, _busd);
    }
}