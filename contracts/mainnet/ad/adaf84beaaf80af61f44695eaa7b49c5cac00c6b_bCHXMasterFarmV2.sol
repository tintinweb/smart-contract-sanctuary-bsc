// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

/**
 * @notice This contract is used to manage farms for which bCHX is provided as a reward. Contract owner
 * can add any number of farms which are based on ERC20 tokens. Initial intent is to only accept LP tokens,
 * but smart contract can accept any ERC20 token for farm establishment. Users deposit their tokens in the farm,
 * and are rewareded with bCHX token in return.
 *
 * Fixed amount of bCHX, determined by contract owner, is distributed in every block and is divided accross all farms,
 * in ratio defined by weight of every farm. All users who deposited token in the farm receive reward proportional
 * to amount they have deposited in current block. 
 */
contract bCHXMasterFarmV2 is Ownable {

    struct UserInfo 
    {  
        bool initialized;
        uint depositedAmount;
        uint earnedReward;
    }

    struct FarmInfo 
    { 
        uint farmWeight; 
        uint lastBlock;
        address[] userList;
        mapping(address => UserInfo) users;
        bool initialized;
    }

    mapping(address => FarmInfo) public farms;
    address[] public farmList;
    
    ERC20 public rewardToken;
    uint public rewardPerBlock;
    uint public totalFarmWeight;

    constructor(address _rewardToken, uint _rewardPerBlock)
    {
        rewardToken = ERC20(_rewardToken);
        rewardPerBlock = _rewardPerBlock;
        totalFarmWeight = 0;
        farmList = new address[](0);
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // Farm management
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    /**
     * @notice Allows contract owner to add new farm. Reward earned up to that moment is calculated
     * using previous distribution of farm weight.
     */
    /// @param _lpToken Address of LP token which will be farmed
    /// @param _farmWeight Weight of newly added farm
    function addFarm(address _lpToken, uint _farmWeight) 
        external
        onlyOwner
    {
        require(!farms[_lpToken].initialized, "Farm already exists.");
        collectRewards();

        FarmInfo storage farm = farms[_lpToken];
        farm.farmWeight = _farmWeight;
        farm.lastBlock = block.number;
        farm.userList = new address[](0);
        farm.initialized = true;

        farmList.push(_lpToken);
        totalFarmWeight += _farmWeight;
    }

    /**
     * @notice Allows contract owner to change farm weight. Reward earned up to that moment is calculated
     * using previous distribution of farm weight. By setting farm weight to 0, it is effectively deactivated
     * and further deposits are blocked.
     */
    /// @param _lpToken Address of LP token whose farm weight is updated 
    /// @param _farmWeight New weight of the farm
    function setFarmWeight(address _lpToken, uint _farmWeight) 
        external
        onlyOwner
    {
        require(farms[_lpToken].initialized, "Farm does not exist.");
        collectRewards();

        uint oldFarmWeight = farms[_lpToken].farmWeight;
        farms[_lpToken].farmWeight = _farmWeight;
        totalFarmWeight = totalFarmWeight + _farmWeight - oldFarmWeight;
    }

    /**
     * @notice Allows contract owner to change reward distributed in each block. Reward earned up to that moment
     * is calculated using previous reward per block.
     */
    /// @param _rewardPerBlock New reward per block
    function setReward(uint _rewardPerBlock) 
        external
        onlyOwner
    {
        collectRewards();
        rewardPerBlock = _rewardPerBlock;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // Staking
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    /**
     * @notice Allows liquidity providers to deposit LP tokens to earn reward. In order that deposit succeeds,
     * farm for specific LP token needs to be added by contract owner and liquidity provider needs to approve
     * farm as spender of their LP tokens, at least to amount they wish to deposit.
     */
    /// @param _lpToken Address of LP token which is being deposited
    /// @param _amount Amount of LP tokens that is being deposited
    function deposit(address _lpToken, uint _amount) 
        external
    {
        require(farms[_lpToken].farmWeight != 0, "Farm does not exist.");
        collectRewardsForFarm(_lpToken);

        require(ERC20(_lpToken).transferFrom(_msgSender(), address(this), _amount), "Transfer failed");

        UserInfo storage userInfo = farms[_lpToken].users[_msgSender()];
        if (!userInfo.initialized) {
            userInfo.initialized = true;
            farms[_lpToken].userList.push(_msgSender());
        }
        userInfo.depositedAmount += _amount;
    }

    /**
     * @notice Allows liquidity providers to withdraw deposited LP tokens. In order that withdraw succeeds,
     * farm for specific LP token needs to be added by contract owner and amount of LP tokens already deposited
     * needs to be equal or greater than amount they wish to withdraw.
     */
    /// @param _lpToken Address of LP token which is being withdrawn 
    /// @param _amount Amount of LP tokens that is being withdrawn
    function withdraw(address _lpToken, uint _amount) 
        external
    {
        require(farms[_lpToken].initialized, "Farm does not exist.");
        collectRewardsForFarm(_lpToken);
        
        UserInfo storage userInfo = farms[_lpToken].users[_msgSender()];
        require(userInfo.depositedAmount >= _amount, "Withdrawal amount is greater than deposited.");
        userInfo.depositedAmount -= _amount;

        require(ERC20(_lpToken).transfer(_msgSender(), _amount), "Transfer failed");
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // Redeeming reward
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    /**
     * @notice Allows liquidity providers to harvest their reward from depositing LP tokens. Farm for specific
     * LP token needs to be added by contract owner and liquidity provider needs to have some tokens already deposited.
     * Specified amount to be harvested needs to be smaller or equal to reward collected through specific farm.
     * As a result, specified amount of reward token will be transferred to liquidity provider's wallet.
     */
    /// @param _lpToken Address of LP token for which reward is calculated
    /// @param _amount Amount of reward token that is being harvested
    function harvest(address _lpToken, uint _amount) 
        external
    {
        require(farms[_lpToken].initialized, "Farm does not exist.");
        collectRewardsForFarm(_lpToken);
        
        UserInfo storage userInfo = farms[_lpToken].users[_msgSender()];
        require(userInfo.earnedReward >= _amount, "Harvest amount is greater than collected.");
        userInfo.earnedReward -= _amount;

        require(rewardToken.transfer(_msgSender(), _amount), "Transfer failed");
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // Reading functions
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    /// @param _lpToken Address of LP token which is being farmed
    /// @param _user Address of liquidity provider for who reward is calculated
    /// @return Earned amount of reward token
    function getEarnedReward(address _lpToken, address _user) 
        external
        view
        returns (uint)
    {
        uint farmBalance = ERC20(_lpToken).balanceOf(address(this));
        uint blockNumber = block.number - farms[_lpToken].lastBlock;

        UserInfo memory userInfo = farms[_lpToken].users[_user];
        uint newReward = totalFarmWeight == 0 || farmBalance == 0 ?
            0 :
            userInfo.depositedAmount * farms[_lpToken].farmWeight * rewardPerBlock * blockNumber / (totalFarmWeight * farmBalance); 
        uint totalReward = userInfo.earnedReward + newReward;

        return totalReward;
    }

    /// @param _lpToken Address of LP token which is being farmed
    /// @param _user Address of liquidity provider/user
    /// @return Amount of LP tokens deposited by specified user
    function getDepositedAmount(address _lpToken, address _user) 
        external
        view
        returns (uint)
    {
        return farms[_lpToken].users[_user].depositedAmount;
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // Helper functions
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    function collectRewardsForFarm(address _lpToken) 
        private
    {
        FarmInfo storage farmInfo = farms[_lpToken];
        uint farmBalance = ERC20(_lpToken).balanceOf(address(this));
        uint blockNumber = block.number - farmInfo.lastBlock;

        if (totalFarmWeight != 0 && farmBalance != 0) {
            for(uint i = 0; i < farmInfo.userList.length; i++) 
            {
                UserInfo storage userInfo = farmInfo.users[farmInfo.userList[i]];

                uint reward = userInfo.depositedAmount * farmInfo.farmWeight * rewardPerBlock * blockNumber / (totalFarmWeight * farmBalance); 

                userInfo.earnedReward = userInfo.earnedReward + reward;
            }
        }

        farmInfo.lastBlock = block.number;
    }

    function collectRewards()
        private
    {
        for(uint i = 0; i < farmList.length; i++) 
        {
            collectRewardsForFarm(farmList[i]);
        }
    }

    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // Miscellaneous
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    /**
     * @notice Enable recovery of ether sent by mistake to this contract's address.
     */
    function drainStrayEther(uint _amount)
        external
        onlyOwner
        returns (bool)
    {
        payable(owner()).transfer(_amount);
        return true;
    }

    /**
     * @notice Enable recovery of any ERC20 compatible token sent by mistake to this contract's address.
     * The only token that cannot be drained is LP token for which farm is established.
     */
    function drainStrayTokens(IERC20 _token, uint _amount)
        external
        onlyOwner
        returns (bool)
    {
        require(!farms[address(_token)].initialized, "LP tokens cannot be drained");
        return _token.transfer(owner(), _amount);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

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
        }
        _balances[to] += amount;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

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