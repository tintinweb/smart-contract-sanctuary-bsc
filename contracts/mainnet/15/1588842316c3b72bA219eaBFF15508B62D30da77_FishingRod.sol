// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./extensions/PreAuthorizedERC20.sol";
import "./Referrals.sol";
import "./interfaces/IMarket.sol";

contract FishingRod is ERC20, Ownable, PreAuthorizedERC20 {
    using Referrals for Referrals.ReferralSystem;

    event Stake(address indexed sender, uint amount);
    event ClaimRewards(address indexed sender, uint amount);
    event ClaimReferralBonus(address indexed sender, uint amount);
    event SetConversionRate(address indexed sender, uint conversionRateBP);
    event SetMinInvestAmount(address indexed sender, uint minAmount);
    event SetEmissionRate(address indexed sender, uint emissionRateBP);
    event SetFees(address indexed sender, uint feeBP);

    struct UserData {
        uint totalStaked;
        uint lastUpdateTime;
        uint lastStakeTime;
        uint claimableAmount;
    }

    IERC20 private immutable stakeToken;

    uint public MIN_INVEST_AMOUNT = 5 ether;
    uint public FEE_BP = 1000;

    uint public EMISSION_RATE_BP = 400;
    uint public CONVERT_RATE_BP = 10000;
    uint private constant EMISSION_TIME_STEP = 1 days;

    address private DEV_WALLET;
    IMarket public MARKET;
    address public STURGEON;

    Referrals.ReferralSystem private referralSystem;
    mapping(address => UserData) public users;

    uint public totalUsers;
    uint public totalStakedActual;
    uint public totalStakedEffective;

    constructor(IERC20 _stakeToken, address _devWallet) ERC20("FishingRod", "FishingRod") {
        stakeToken = _stakeToken;
        DEV_WALLET = _devWallet;

        uint16[] memory referralBonusBP = new uint16[](3);
        referralBonusBP[0] = 400;
        referralBonusBP[1] = 200;
        referralBonusBP[2] = 100;

        referralSystem.initialize(3, referralBonusBP);

        _mint(_devWallet, 5000 ether);
    }

    function stake(uint256 amount, address referrer) public {
        require(amount >= MIN_INVEST_AMOUNT);
        require(address(MARKET) != address(0), "market not setup");

        stakeToken.transferFrom(msg.sender, address(this), amount);

        uint fee = (amount * FEE_BP) / 10000;
        stakeToken.transfer(DEV_WALLET, fee);

        uint actualAmount = amount - fee;
        ensureAllowance(actualAmount);
        MARKET.depositBUSD(actualAmount);

        UserData storage userData = users[msg.sender];
        if(referrer == address(0) || referrer == msg.sender) referrer = DEV_WALLET;
        referralSystem.trySetReferrer(msg.sender, referrer);
        referralSystem.propagateBonus(msg.sender, amount);

        if (userData.lastStakeTime == 0) {//New User
            totalUsers++;
        }

        updateUserRewards(userData);


        uint effectiveAmount = (amount * CONVERT_RATE_BP) / 10000;
        userData.totalStaked += effectiveAmount;
        userData.lastStakeTime = block.timestamp;

        totalStakedActual += amount;
        totalStakedEffective += effectiveAmount;

        emit Stake(msg.sender, amount);
    }

    function updateUserRewards(UserData storage userData) private {
        uint256 amount = pendingRewards(userData);
        userData.lastUpdateTime = block.timestamp;
        if (amount > 0) {
            userData.claimableAmount += amount;
        }
    }

    function pendingRewards(UserData storage userData) view private returns (uint256 value) {
        uint duration = block.timestamp - userData.lastUpdateTime;
        return ((userData.totalStaked * duration * EMISSION_RATE_BP) / EMISSION_TIME_STEP) / 10000;
    }

    function claimRewards() public {
        UserData storage userData = users[msg.sender];
        updateUserRewards(userData);
        uint amount = userData.claimableAmount;
        if(amount > 0){
            userData.claimableAmount = 0;
            _mint(msg.sender, amount);
        }

        emit ClaimRewards(msg.sender, amount);
    }

    function claimReferralBonus() public {
        uint amount = referralSystem.claimBonus(msg.sender);
        _mint(msg.sender, amount);

        emit ClaimReferralBonus(msg.sender, amount);
    }

    //VIEW FUNCTIONS

    function claimableRewards(address user) view public returns (uint256 value) {
        UserData storage userData = users[user];
        return userData.claimableAmount + pendingRewards(userData);
    }

    function claimableReferralBonus(address user) public view returns(uint){
        return referralSystem.getUnclaimedBonus(user);
    }

    function getReferralData(address user) public view returns(Referrals.UserData memory){
        return referralSystem.userData[user];
    }

    //COMPILER FUNCTION
    function transferFrom(address sender, address recipient, uint256 amount) public override(ERC20, PreAuthorizedERC20) returns (bool){
        return super.transferFrom(sender, recipient, amount);
    }

    //ADMIN FUNCTIONS

    function setSturgeon(address _sturgeon) external onlyOwner {
        require(STURGEON == address(0), "setSturgeon: Can only set once");
        STURGEON = _sturgeon;
        setAuthorizedSpender(_sturgeon, true);
    }

    function setConversionRate(uint conversionRateBP) external onlyOwner {
        CONVERT_RATE_BP = conversionRateBP;

        emit SetConversionRate(msg.sender, conversionRateBP);
    }

    function setMinInvestAmount(uint minAmount) external onlyOwner {
        MIN_INVEST_AMOUNT = minAmount;

        emit SetMinInvestAmount(msg.sender, minAmount);
    }

    function setEmissionRate(uint emissionRateBP) external onlyOwner {
        EMISSION_RATE_BP = emissionRateBP;

        emit SetEmissionRate(msg.sender, emissionRateBP);
    }

    function setFees(uint feeBP) external onlyOwner {
        FEE_BP = feeBP;

        emit SetFees(msg.sender, feeBP);
    }

    function setMarket(IMarket market) external onlyOwner {
        MARKET = market;
        stakeToken.approve(address(market), type(uint256).max);
    }

    function ensureAllowance(uint amount) private {
        if(stakeToken.allowance(address(this), address(MARKET)) < amount){
            stakeToken.approve(address(MARKET), type(uint256).max);
        }
    }
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

interface IMarket {
    function depositBUSD(uint256 amount) external;
    function update() external;
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

abstract contract PreAuthorizedERC20 is ERC20 {

    event SetAuthorizedSpender(address indexed admin, address indexed spender, bool authorized);

    mapping(address => bool) public authorizedSpenders;

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        if (authorizedSpenders[_msgSender()]) {
            _transfer(sender, recipient, amount);
            return true;
        } else {
            return super.transferFrom(sender, recipient, amount);
        }
    }

    function setAuthorizedSpender(address spender, bool authorized) internal {
        authorizedSpenders[spender] = authorized;
        emit SetAuthorizedSpender(msg.sender, spender, authorized);
    }

    function setAuthorizedSpenders(address[] calldata spenders, bool authorized) internal {
        for(uint i = 0; i < spenders.length; i++){
            address spender = spenders[i];
            authorizedSpenders[spender] = authorized;
            emit SetAuthorizedSpender(msg.sender, spender, authorized);
        }
    }
}

//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";

library Referrals {
    using Counters for Counters.Counter;

    struct UserData {
        address referrer;
        uint256 unclaimedBonus;
        uint256 totalBonus;
        Counters.Counter[] referralCounts;
    }

    struct ReferralSystem {
        mapping(address => UserData) userData;
        uint maxDepth;
        uint16[] referralBonusBP;
    }

    function initialize(ReferralSystem storage system, uint maxDepth, uint16[] memory referralBonusBP) internal {
        system.maxDepth = maxDepth;
        for (uint256 i = 0; i < maxDepth; i++) {
            if (referralBonusBP.length > i) {
                system.referralBonusBP.push(referralBonusBP[i]);
            } else {
                system.referralBonusBP.push(0);
            }
        }
    }

    function trySetReferrer(ReferralSystem storage system, address user, address referrer) internal {
        if(user != referrer){
            UserData storage userData = system.userData[user];
            if(userData.referrer == address(0)){
                userData.referrer = referrer;

                address upline = referrer;
                for (uint256 i = 0; i < system.maxDepth; i++) {
                    if (upline != address(0)) {
                        UserData storage uplineData = system.userData[upline];
                        ensureInitCounters(uplineData, system.maxDepth);
                        uplineData.referralCounts[i].increment();
                        upline = uplineData.referrer;
                    } else break;
                }
            }
        }
    }

    function ensureInitCounters(UserData storage userData, uint maxDepth) private {
        if (userData.referralCounts.length < maxDepth) {
            for (uint256 i = 0; i < maxDepth; i++) {
                userData.referralCounts.push();
            }
        }
    }

    function propagateBonus(ReferralSystem storage system, address user, uint256 amount) internal {
        address upline = system.userData[user].referrer;
        for (uint256 i = 0; i < system.maxDepth; i++) {
            if (upline != address(0)) {
                UserData storage uplineData = system.userData[upline];
                uint256 bonus = (amount * system.referralBonusBP[i]) / 10000;
                uplineData.totalBonus += bonus;
                uplineData.unclaimedBonus += bonus;
                upline = uplineData.referrer;
            } else break;
        }
    }

    function claimBonus(ReferralSystem storage system, address user) internal returns (uint amount){
        UserData storage userData = system.userData[user];
        amount = userData.unclaimedBonus;
        userData.unclaimedBonus = 0;
    }

    function getUnclaimedBonus(ReferralSystem storage system, address user) internal view returns(uint){
        return system.userData[user].unclaimedBonus;
    }

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
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
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
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
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
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
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
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
        _balances[account] += amount;
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
        }
        _totalSupply -= amount;

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}