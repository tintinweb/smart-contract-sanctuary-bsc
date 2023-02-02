/**
 *Submitted for verification at BscScan.com on 2023-02-02
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


pragma solidity 0.8.17;
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }


    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }


    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

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

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}


contract StableCoinStaking is Ownable,ReentrancyGuard {
    using SafeMath for uint256;

    
    uint256 private MAX_INT = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    IERC20 public stableCoin;
    address public stableCoinAddress;
    address public targetAddress;
    address public addresRewardsFrom;



    struct Stake {
        uint256 stakeOptionId;
        uint256 startTS;
        uint256 endTS;
        uint256 amountStaked;
        uint256 rewardAmountAtEnd;
        uint256 counter;
        bool claimed;
        uint256 claimedTS;
        bool claimedEmergency;
        uint256 emergencyWithdrawnAmount;
        uint256 globalStakeId;        
    }

    struct globalStake {
        address staker;
        uint256 stakerCounter;
    }

    struct Staker {
        mapping (uint256 => Stake) stakes;
        bool isBlacklisted;
        bool isDeclared;
        uint256 stakeCounter;
    }

    struct StakeOption {
        uint256 periodInSeconds;
        bool canStake;
        bool canWithdraw;
        uint256 rewardMultiplicatorMilions;
        uint256 totalTokensStaked;
        uint256 activeTokensStaked;
        uint256 totalTokensRewarded;
        uint256 totalTokensClaimed;
        uint256 activeStakers;
    }
    

    mapping(address => Staker) private stakers;
    mapping(uint256 => StakeOption) public stakeOptions;
    mapping(uint256 => globalStake) public globalStakes;
    mapping(uint256 => globalStake) public globalWithdraws;


    uint256 public stakeOptionsCounter = 0;

    uint256 public globalStakeCounter = 0;
    uint256 public globalWithdrawCounter = 0;
    uint256 public emergencyWithdrawMultiplier = 500; //50%


    event STAKED(address indexed from, uint indexed counter, uint256 amount);
    event CLAIMED(address indexed from, uint indexed counter, uint256 amount);
    event EMERGENCY_WITHDRAWN(address indexed from, uint indexed counter, uint256 amount);


    function STAKE(uint256 stakeOptionId, uint256 tokens)
        external
        nonReentrant
        returns (bool)
    {
        require (!(stakers[msg.sender].isBlacklisted), "you are blacklisted");
        require(tokens > 0, "Stake amount should be correct");
        require(stakeOptions[stakeOptionId].canStake,"Stake option is not allowed to stake");
        require(stakeOptionId < stakeOptionsCounter,"Stake doesnot exist");

        require(
            stableCoin.transferFrom (
                msg.sender,
                targetAddress,
                tokens
            ),
            "Tokens cannot be transferred"
        );

        addStaker(stakeOptionId, msg.sender, tokens, block.timestamp);
        emit STAKED(msg.sender, stakers[msg.sender].stakeCounter.sub(1), tokens);        
        return true;
    }

    function addStaker(uint256 stakeOptionId, address addr, uint256 tokens, uint256 startPeriod) private {
       
        if(!stakers[addr].isDeclared) {
            stakers[addr].isBlacklisted = false;
            stakers[addr].isDeclared = true;
            stakers[addr].stakeCounter = 0;
        }
        stakers[addr].stakes[stakers[addr].stakeCounter] = Stake({
            stakeOptionId: stakeOptionId,
            startTS: startPeriod,
            endTS: startPeriod +
                stakeOptions[stakeOptionId].periodInSeconds,
            amountStaked: tokens,
            rewardAmountAtEnd: tokens.mul(
                stakeOptions[stakeOptionId].rewardMultiplicatorMilions
            ).div(1000000),
            claimed: false,
            counter: stakers[addr].stakeCounter,
            claimedTS: 0,
            globalStakeId: globalStakeCounter,
            claimedEmergency: false,
            emergencyWithdrawnAmount: 0
        });

        globalStakes[globalStakeCounter] = globalStake({
            staker: addr,
            stakerCounter: stakers[addr].stakeCounter
            }
        );

        stakers[addr].stakeCounter = stakers[addr].stakeCounter + 1;
        stakeOptions[stakeOptionId].totalTokensStaked = stakeOptions[
            stakeOptionId
        ].totalTokensStaked.add(tokens);
        stakeOptions[stakeOptionId].activeTokensStaked = stakeOptions[
            stakeOptionId
        ].activeTokensStaked.add(tokens);
        stakeOptions[stakeOptionId].activeStakers = stakeOptions[stakeOptionId].activeStakers + 1;
        globalStakeCounter = globalStakeCounter + 1;

    }

    function setAddressRewardsFrom(address newValue) external onlyOwner{
        addresRewardsFrom = newValue;
    }

    function setEmergencyWithdrawMultiplier(uint256 newValue) external onlyOwner {
        emergencyWithdrawMultiplier = newValue;
    }

    function setTargetAddress(address newValue) external onlyOwner{
        targetAddress = newValue;
    }

    function CLAIM(uint256 stakeId) external returns (bool) {
        require (!(stakers[msg.sender].isBlacklisted), "you are blacklisted");
        require(stakers[msg.sender].isDeclared, "You are not staker");
        require(
            stakers[msg.sender].stakes[stakeId].endTS < block.timestamp,
            "Stake Time is not over yet"
        );
        require(
            stakers[msg.sender].stakes[stakeId].claimed == false,
            "Already claimed"
        );

        uint256 stakeOptionId = stakers[msg.sender]
            .stakes[stakeId]
            .stakeOptionId;

        require(
            stakeOptions[stakeOptionId].canWithdraw,
            "Stake option is not allowed to claim"
        );

        uint256 rewardAmount = stakers[msg.sender]
            .stakes[stakeId]
            .rewardAmountAtEnd;


        uint256 amountStaked = stakers[msg.sender].stakes[stakeId].amountStaked;

        require(
            stableCoin.transferFrom(
                addresRewardsFrom,
                msg.sender,
                rewardAmount
            ),
            "Tokens cannot be transferred from wallet"
        );

        stakers[msg.sender].stakes[stakeId].claimed = true;
        stakers[msg.sender].stakes[stakeId].claimedTS = block.timestamp;

        stakeOptions[stakeOptionId].activeTokensStaked = stakeOptions[
            stakeOptionId
        ].activeTokensStaked.sub(amountStaked);
        stakeOptions[stakeOptionId].totalTokensRewarded = stakeOptions[
            stakeOptionId
        ].totalTokensRewarded.add(rewardAmount).sub(amountStaked);
        stakeOptions[stakeOptionId].totalTokensClaimed = stakeOptions[
            stakeOptionId
        ].totalTokensClaimed.add(rewardAmount);

        stakeOptions[stakeOptionId].activeStakers = stakeOptions[stakeOptionId].activeStakers - 1;

        globalWithdraws[globalWithdrawCounter] = globalStake({
            staker: msg.sender,
            stakerCounter: stakeId
            }
        );

        globalWithdrawCounter = globalWithdrawCounter + 1;

        emit CLAIMED(msg.sender, stakeId, rewardAmount);

        return true;
    }


    function EMERGENCY_WITHDRAW(uint256 stakeId) external returns (bool) {
        require (!(stakers[msg.sender].isBlacklisted), "you are blacklisted");
        require(stakers[msg.sender].isDeclared, "You are not staker");
        require(
            stakers[msg.sender].stakes[stakeId].endTS >= block.timestamp,
            "Stake Time has finished. Use classic CLAIM!"
        );
        require(
            stakers[msg.sender].stakes[stakeId].claimed == false,
            "Already claimed"
        );

        uint256 stakeOptionId = stakers[msg.sender]
            .stakes[stakeId]
            .stakeOptionId;

        require(
            stakeOptions[stakeOptionId].canWithdraw,
            "Stake option is not allowed to claim"
        );

        uint256 amountStaked = stakers[msg.sender].stakes[stakeId].amountStaked;
        uint256 rewardAmount = amountStaked.mul(emergencyWithdrawMultiplier).div(1000);

        require(
            stableCoin.transferFrom(
                addresRewardsFrom,
                msg.sender,
                rewardAmount
            ),
            "Tokens cannot be transferred from wallet"
        );

        stakers[msg.sender].stakes[stakeId].claimed = true;
        stakers[msg.sender].stakes[stakeId].claimedTS = block.timestamp;
        stakers[msg.sender].stakes[stakeId].emergencyWithdrawnAmount = rewardAmount;
        stakers[msg.sender].stakes[stakeId].claimedEmergency = true;


        stakeOptions[stakeOptionId].activeTokensStaked = stakeOptions[
            stakeOptionId
        ].activeTokensStaked.sub(amountStaked);


        stakeOptions[stakeOptionId].activeStakers = stakeOptions[stakeOptionId].activeStakers - 1;

        globalWithdraws[globalWithdrawCounter] = globalStake({
            staker: msg.sender,
            stakerCounter: stakeId
            }
        );

        globalWithdrawCounter = globalWithdrawCounter + 1;
        
        emit EMERGENCY_WITHDRAWN(msg.sender, stakeId, rewardAmount);

        return true;
    }

    function getStakerCounter(address addr) external view returns (uint256) {
        return stakers[addr].stakeCounter;
    }

    function getStake(address addr, uint256 index) external view returns (Stake memory) {
        return stakers[addr].stakes[index];
    }


    function addStakeOption( uint256 periodInSeconds, uint256 rewardMultiplicatorMilions) external onlyOwner {
        stakeOptions[stakeOptionsCounter].periodInSeconds = periodInSeconds;
        stakeOptions[stakeOptionsCounter].canStake = false;
        stakeOptions[stakeOptionsCounter].canWithdraw = false;
        stakeOptions[stakeOptionsCounter].rewardMultiplicatorMilions = rewardMultiplicatorMilions;
        stakeOptionsCounter++;
    }

    function setCanStake(uint256 stakeOptionId, bool newValue) external onlyOwner{
        stakeOptions[stakeOptionId].canStake = newValue;
    }
    function setCanWithdraw(uint256 stakeOptionId, bool newValue) external onlyOwner{
        stakeOptions[stakeOptionId].canWithdraw = newValue;
    }
    function setRewardMultiplicatorMilions(uint256 stakeOptionId, uint256 newValue) external onlyOwner{
        stakeOptions[stakeOptionId].rewardMultiplicatorMilions = newValue;
    }

    function setPeriodInSeconds(uint256 stakeOptionId, uint256 newValue) external onlyOwner {
        stakeOptions[stakeOptionId].periodInSeconds = newValue;
    }


    constructor() {}   

    function setStableCoinAddress(address _tokenAddress) external onlyOwner {
            stableCoinAddress = _tokenAddress;
            stableCoin = IERC20(_tokenAddress);
    }

    function recoverTokens(address tokenAddress, address receiver) external onlyOwner {
        IERC20(tokenAddress).approve(address(this), MAX_INT);
        IERC20(tokenAddress).transferFrom(
                            address(this),
                            receiver,
                            IERC20(tokenAddress).balanceOf(address(this))
        );
    }

}



pragma solidity 0.8.17;

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }


    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);
        return a / b;
    }

 
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

  
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }


    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }


    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}

pragma solidity 0.8.17;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }


    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

pragma solidity 0.8.17;
library SafeMathUint {
  function toInt256Safe(uint256 a) internal pure returns (int256) {
    int256 b = int256(a);
    require(b >= 0);
    return b;
  }
}

interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}