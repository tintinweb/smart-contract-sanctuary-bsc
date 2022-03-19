/**
 *Submitted for verification at BscScan.com on 2022-03-19
*/

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;




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
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
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
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
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
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
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

// File: ozbasic.sol


pragma solidity ^0.8.9;


interface ICrossChainBridgeRouter {

  // addresses of other ccb-related contracts
  function bridgeChef () external returns(address);
  function bridgeERC20 () external returns(address);
  function liquidityManager () external returns(address);
  function bridgeERC721 () external returns(address);
  function liquidityMiningPools () external returns(address);
  function rewardPools () external returns(address);

    // ###################################################################################################################
  // ********************************************** BRIDGE ERC20 *******************************************************
  // ###################################################################################################################
  // ------------------------------------------------- DEPOSIT  --------------------------------------------------------

  /**
   * @notice Accepts ERC20 token deposits that should be bridged into another network
   * (effectively starting a new bridge transaction)
   *
   * @param token the ERC20 contract the to-be-bridged token was issued with
   * @param amount the amount that is being deposited
   * @param receiverAddress target address the bridged token should be sent to (in the target network)
   * @param targetChainId chain ID of the target network
   *
   * @dev emits event TokensDeposited after successful deposit
   */
  function depositERC20TokensToBridge(
    IERC20 token,
    uint256 amount,
    address receiverAddress,
    uint256 targetChainId
  ) external payable;

  /**
   * @notice Accepts native token deposits that should be bridged into another network
   * (effectively starting a new bridge transaction)
   *
   * @param amount the amount that is being deposited
   * @param receiverAddress target address the bridged token should be sent to (in the target network)
   * @param targetChainId chain ID of the target network
   * @dev emits event TokensDeposited after successful deposit
   */
  function depositNativeTokensToBridge(
    uint256 amount,
    address receiverAddress,
    uint256 targetChainId
  ) external payable;

  // ------------------------------------------------- RELEASE  --------------------------------------------------------

  /**
   * @notice Releases ERC20 tokens in this network after a deposit was made in another network
   *         (effectively completing a bridge transaction)
   *
   * @param sigV Array of recovery Ids for the signature
   * @param sigR Array of R values of the signatures
   * @param sigS Array of S values of the signatures
   * @param receiverAddress The account to receive the tokens
   * @param sourceNetworkTokenAddress the address of the ERC20 contract in the network the deposit was made
   * @param amount The amount of tokens to be released
   * @param depositChainId chain ID of the network in which the deposit was made
   * @param depositNumber The identifier of the corresponding deposit
   * @dev emits event TokensReleased after successful release
   */
  function releaseERC20TokenBridgeDeposit(
    uint8[] memory sigV,
    bytes32[] memory sigR,
    bytes32[] memory sigS,
    address receiverAddress,
    address sourceNetworkTokenAddress,
    uint256 amount,
    uint256 depositChainId,
    uint256 depositNumber
  ) external payable;

  /**
   * @notice Releases native tokens in this network that were deposited in another network
   *         (effectively completing a bridge transaction)
   *
   * @param sigV Array of recovery Ids for the signature
   * @param sigR Array of R values of the signatures
   * @param sigS Array of S values of the signatures
   * @param receiverAddress The account to receive the tokens
   * @param sourceNetworkTokenAddress the address of the ERC20 contract in the network the deposit was made
   * @param amount The amount of tokens to be released
   * @param depositChainId chain ID of the network in which the deposit was made
   * @param depositNumber The identifier of the corresponding deposit
   * @dev emits event TokensReleased after successful release
   */
  function releaseNativeTokenBridgeDeposit(
    uint8[] memory sigV,
    bytes32[] memory sigR,
    bytes32[] memory sigS,
    address receiverAddress,
    address sourceNetworkTokenAddress,
    uint256 amount,
    uint256 depositChainId,
    uint256 depositNumber
  ) external payable;

  // ------------------------------------------ GET BRIDGE FEE QUOTE ---------------------------------------------------

  /**
   * @notice Returns the estimated bridge fee for a specific ERC20 token and bridge amount
   *
   * @param tokenAddress the address of the token that should be bridged
   * @param amountToBeBridged the amount to be bridged
   * @return bridgeFee the estimated bridge fee (in to-be-bridged token)
   */
  function getERC20BridgeFeeQuote(address tokenAddress, uint256 amountToBeBridged)
    external
    view
    returns (uint256 bridgeFee);

  // ###################################################################################################################
  // ********************************************** BRIDGE ERC721 ******************************************************
  // ###################################################################################################################
  // ------------------------------------------------- DEPOSIT  --------------------------------------------------------

  /**
   * @notice Deposits an ERC721 token into the bridge (effectively starting a bridge transaction)
   *
   * @dev the collection must be whitelisted by the bridge or the call will be reverted
   *
   * @param collectionAddress the address of the ERC721 contract the collection was issued with
   * @param tokenId the (native) ID of the ERC721 token that should be bridged
   * @param receiverAddress target address the bridged token should be sent to
   * @param targetChainId chain ID of the target network
   *
   * @dev emits event TokenDeposited after successful deposit
   */
  function depositERC721TokenToBridge(
    address collectionAddress,
    uint256 tokenId,
    address receiverAddress,
    uint256 targetChainId
  ) external payable;

  // ------------------------------------------------- RELEASE  --------------------------------------------------------

  /**
   * @notice Releases an ERC721 token in this network after a deposit was made in another network
   *         (effectively completing a bridge transaction)
   *
   * @param sigV Array of recovery Ids for the signature
   * @param sigR Array of R values of the signatures
   * @param sigS Array of S values of the signatures
   * @param receiverAddress The account to receive the tokens
   * @param sourceNetworkCollectionAddress the address of the ERC721 contract in the network the deposit was made
   * @param tokenId The token id to be sent
   * @param depositChainId chain ID of the network in which the deposit was made
   * @param depositNumber The identifier of the corresponding deposit
   *
   * @dev emits event TokenReleased after successful release
   */
  function releaseERC721TokenDeposit(
    uint8[] memory sigV,
    bytes32[] memory sigR,
    bytes32[] memory sigS,
    address receiverAddress,
    address sourceNetworkCollectionAddress,
    uint256 tokenId,
    uint256 depositChainId,
    uint256 depositNumber
  ) external payable;

  // ------------------------------------------ GET BRIDGING FEE QUOTE -------------------------------------------------

  /**
   * @notice Returns the estimated fee for bridging one token of a specific ERC721 collection in native currency
   *         (e.g. ETH, BSC, MATIC, AVAX, FTM)
   *
   * @param collectionAddress the address of the collection
   * @return bridgeFee the estimated bridge fee (in network-native currency)
   */
  function getERC721BridgeFeeQuote(address collectionAddress) external view returns (uint256 bridgeFee);

  // ###################################################################################################################
  // ******************************************** MANAGE LIQUIDITY *****************************************************
  // ###################################################################################################################
  // ----------------------------------------- ADD LIQUIDITY TO BRIDGE -------------------------------------------------

  /**
   * @notice Adds ERC20 liquidity to an existing pool or creates a new one, if none exists for the provided token
   *
   * @param token the address of the token for which liquidity should be added
   * @param amount the amount of tokens to be added
   *
   * @dev emits event LiquidityPoolCreated (only if a new pool is created)
   * @dev emits event LiquidityAdded after successful deposit
   */
  function addLiquidityERC20(IERC20 token, uint256 amount) external payable;

  /**
   * @notice Adds native liquidity to an existing pool or creates a new one, if it does not exist yet
   *
   * @param amount the amount of native tokens to be added
   *
   * @dev emits event LiquidityPoolCreated (only if a new pool is created)
   * @dev emits event LiquidityAdded after successful deposit
   */
  function addLiquidityNative(uint256 amount) external payable;

  // TODO CONTINUE HERE
  // --------------------------------------- REMOVE LIQUIDITY FROM BRIDGE ----------------------------------------------
  /**
   * @notice Burns LP tokens and removes previously provided ERC20 liquidity from the bridge
   *
   * @param token the token for which liquidity should be removed from this pool
   *
   * @dev emits event LiquidityRemoved
   */
  function withdrawLiquidityERC20(IERC20 token, uint256 amount) external payable;

  /**
   * @notice Removes native (i.e. in the network-native token) liquidity from a liquidity pool
   *
   * @param amount the amount of liquidity to be removed
   *
   * @dev emits event LiquidityRemoved
   */
  function withdrawLiquidityNative(uint256 amount) external payable;

  // -------------------------------- REMOVE LIQUIDITY & BRIDGE TO ANOTHER NETWORK -------------------------------------
  /**
   * @notice Burns LP tokens and creates a bridge deposit in the amount of "burned LPTokens - withdrawal fee"
   *         For cases when no liquidity is available on the network the user provided liquidity in
   *
   * @param token the address of the ERC20 token in which liquidity was provided
   * @param amount the amount of the withdrawal
   * @param receiverAddress target address the bridged token should be sent to (in the target network)
   * @param targetChainId chain ID of the target network
   *
   * @dev emits event TokensDeposited after successful deposit
   */
  function withdrawLiquidityInAnotherNetwork(
    IERC20 token,
    uint256 amount,
    address receiverAddress,
    uint256 targetChainId
  ) external payable;

  // ---------------------------------------- GET LIQUIDITY WITHDRAWAL FEE ---------------------------------------------
  /**
   * @notice Returns the liquidity withdrawal fee amount for the given token
   *
   * @param token the address of the ERC20 token in which liquidity was provided
   * @param withdrawalAmount the amount of tokens to be withdrawn
   *
   */
  function getLiquidityWithdrawalFeeAmount(IERC20 token, uint256 withdrawalAmount) external view returns (uint256);

  // ###################################################################################################################
  // ***************************************** LIQUIDITY MINING POOLS **************************************************
  // ###################################################################################################################
  // ------------------------------------- STAKE LP TOKENS IN MINING POOLS ---------------------------------------------
  /**
   * @notice Adds LP tokens to the liquidity mining pool of the given token
   *
   * @param tokenAddress the address of the underlying token of the pool
   * @param amount the amount of LP tokens that should be staked
   *
   * @dev emits event StakeAdded
   */
  function stakeLpTokensInMiningPool(address tokenAddress, uint256 amount) external payable;

  // ----------------------------------- UNSTAKE LP TOKENS FROM MINING POOLS -------------------------------------------
  /**
   * @notice Withdraws staked LP tokens from the liquidity mining pool after harvesting available rewards, if any
   *
   * @param tokenAddress the address of the underlying token of the liquidity mining pool
   * @param amount the amount of LP tokens that should be unstaked
   *
   * @dev emits event RewardsHarvested, if rewards are available for harvesting
   * @dev emits event StakeAdded
   */
  function unstakeLpTokensFromMiningPool(address tokenAddress, uint256 amount) external payable;

  // -------------------------------- CHECK & HARVEST REWARDS FROM MINING POOLS ----------------------------------------
  /**
   * @notice Returns the amount of unharvested rewards for a specific address in the given liquidity mining pool
   *
   * @param tokenAddress the address of the underlying token of the reward pool
   * @param stakerAddress the address of the staker for which pending rewards should be returned
   * @return the unharvested reward amount
   */
  function pendingMiningPoolRewards(address tokenAddress, address stakerAddress) external view returns (uint256);

  /**
   * @notice Distributes unharvested staking rewards from the given liquidity mining pool
   *
   * @param tokenAddress the address of the underlying token of the pool
   * @param stakerAddress the address for which the unharvested rewards should be distributed
   *
   * @dev emits event RewardsHarvested
   */
  function harvestFromMiningPool(address tokenAddress, address stakerAddress) external payable;

  // ###################################################################################################################
  // ******************************************* BRIDGE CHEF FARMS *****************************************************
  // ###################################################################################################################
  // ----------------------------------------- STAKE LP TOKENS IN FARMS ------------------------------------------------

  /**
   * @notice Adds liquidity provider (LP) tokens to the given farm for the user to start earning BRIDGE tokens
   *
   * @param farmId the ID of the liquidity farm
   * @param amount LP token amount to be deposited
   *
   * @dev emits event DepositAdded after the deposit was successfully added
   */
  function stakeLpTokensInFarm(uint256 farmId, uint256 amount) external payable;

  // --------------------------------------- UNSTAKE LP TOKENS FROM FARMS ----------------------------------------------

  /**
   * @notice Withdraws liquidity provider (LP) tokens from the given farm
   *
   * @param farmId the ID of the liquidity farm
   * @param amount LP token amount to withdraw
   *
   * @dev emits event FundsWithdrawn after successful withdrawal
   */
  function unstakeLpTokensFromFarm(uint256 farmId, uint256 amount) external payable;

  // --------------------------------- CHECK & HARVEST BRIDGE REWARDS FROM FARMS ---------------------------------------

  /**
   * @notice Returns the amount of BRIDGE tokens that are ready for harvesting for the given user and farm
   *
   * @param farmId The index of the farm
   * @param user the address of the user to query the info for
   * @return returns the amount of bridge tokens that are ready for harvesting
   */
  function pendingFarmRewards(uint256 farmId, address user) external view returns (uint256);

  /**
   * @notice Harvests BRIDGE rewards and sends them to the caller of this function
   *
   * @param farmId the ID of the farm for which rewards should be harvested
   *
   * @dev emits event RewardsHarvested after the rewards have been transferred to the caller
   */
  function harvestFarmRewards(uint256 farmId) external payable;

  // ###################################################################################################################
  // ********************************************* REWARD POOLS ********************************************************
  // ###################################################################################################################
  // ----------------------------------- STAKE BRIDGE TOKENS IN REWARD POOLS -------------------------------------------
  /**
   * @notice Stakes BRIDGE tokens in the given staking pool
   *
   * NOTE: Withdrawals are subject to a fee {see unstakeBRIDGEFromRewardPools()}
   *
   * @param tokenAddress the address of the underlying token of the reward pool
   * @param amount the amount of bridge tokens that should be staked
   *
   * @dev emits event StakeAdded
   */
  function stakeBRIDGEInRewardPool(address tokenAddress, uint256 amount) external payable;

  // --------------------------------- UNSTAKE BRIDGE TOKENS FROM REWARD POOLS -----------------------------------------
  /**
   * @notice Unstakes BRIDGE tokens from the given reward pool
   *
   * Please note: Unstaking BRIDGE tokens is subject to a withdrawal fee.
   * To check the current fee rate, please refer to the following variables/functions
   *   1) check for custom withdrawal fee (if > 0 then this fee applies) : rewardPoolWithdrawalFees(tokenAddress)
   *   2) if no custom withdrawal fee applies, then default fee applies  : defaultRewardPoolWithdrawalFee()
   *
   * @param tokenAddress the address of the underlying token of the reward pool
   * @param amount the amount of bridge tokens that should be unstaked
   * @dev emits event StakeWithdrawn
   */
  function unstakeBRIDGEFromRewardPool(address tokenAddress, uint256 amount) external payable;

  // -------------------------------- CHECK & HARVEST REWARDS FROM REWARD POOLS ----------------------------------------
  /**
   * @notice Returns the amount of unharvested rewards for a specific address in the given reward pool
   *
   * @param tokenAddress the address of the underlying token of the reward pool
   * @param stakerAddress the address of the staker for which pending rewards should be returned
   * @return the unharvested reward amount
   */
  function pendingRewardPoolRewards(address tokenAddress, address stakerAddress) external view returns (uint256);

  /**
   * @notice Distributes unharvested staking rewards from the given reward pool
   *
   * @param tokenAddress the address of the underlying token of the pool
   * @param stakerAddress the address for which the unharvested rewards should be distributed
   * @dev emits event RewardsHarvested
   */
  function harvestFromRewardPool(address tokenAddress, address stakerAddress) external payable;

  // ------------------------------------ CHECK REWARD POOL WITHDRAWAL FEES --------------------------------------------
  /**
   * @notice Returns the specific withdrawal fee for the given token in parts per million (ppm)
   *
   * Example for ppm values:
   * 300,000  = 30%
   *  10,000 =   1%
   *
   * @return the withdrawal fee percentage in ppm
   */
  function rewardPoolWithdrawalFee(address tokenAddress) external view returns (uint256);

  // ###################################################################################################################
  // ******************************** LIST/DE-LIST YOUR ERC20/ERC721 TOKEN *********************************************
  // ****************** FOR PROJECTS THAT WANT TO USE OUR BRIDGE FOR THEIR TOKEN/COLLECTION ****************************
  // ###################################################################################################################
  // ------------------------------------------------- ERC20  ----------------------------------------------------------
  // For new ERC20 token listings on the bridge there are two cases:
  // 1) the token contracts have same addresses across all networks that should be connected
  // 2) the token contracts have different addresses across the networks that should be connected
  //
  // In case of 1), you need to add liquidity in each network (see section "MANAGE LIQUIDITY")
  // In case of 2), same as 1) plus you need to add token mappings in each network (see below)

  /**
   * @notice Adds a token contract mapping for an ERC20 token
   *
   * @param sourceNetworkTokenAddress the address of the token in another network that should be mapped to the target
   * @param targetTokenAddress the address of the target token in this network
   *
   * @dev only accepts new token mappings. To update an existing mapping, please contact support
   * @dev the token contract must have a public owner() function that returns the address of the owner
   * @dev if this is not possible, you can contact support to add your mapping
   * @dev emits event PeggedTokenMappingAdded
   */
  function addERC20TokenContractMapping(address sourceNetworkTokenAddress, address targetTokenAddress) external payable;

  /**
   * @notice Removes a token contract mapping for an ERC20 token
   *
   * @param sourceNetworkTokenAddress the address of the token in another network that should be mapped to the target
   *
   * @dev can only be called by the owner of the target token contract
   * @dev only accepts new token mappings. To update an existing mapping, please contact support
   * @dev the token contract must have a public owner() function that returns the address of the owner
   * @dev if this is not possible, you can contact support to add your mapping
   */
  function removeERC20TokenContractMapping(address sourceNetworkTokenAddress) external payable;

  /**
  * @notice Initial setup for a new ERC20 token. Creates all pools required by the bridge ecosystem.
  *         Can be called from a constructor of an ERC20 token to prepare token for bridging.
  *
  * @param createLiquidityPool creates a liquidity pool and a LP token, if true
  * @param createMiningPool creates a liquidity mining pool, if true
  * @param createRewardPool creates a reward pool, if true
  *
  * @dev emits events LiquidityPoolCreated, LiquidityMiningPoolCreated, RewardPoolCreated
  */
  function createPools(address tokenAddress, bool createLiquidityPool, bool createMiningPool, bool createRewardPool) external payable;

  // ------------------------------------------------  ERC721  ---------------------------------------------------------
  // For new ERC721 collection listings on the bridge there are two cases:
  // 1) the collection contracts have same addresses across all networks that should be connected
  // 2) the collection contracts have different addresses across the networks that should be connected
  //
  // In case of 1), you need to add your collection to the whitelist (see below)
  // In case of 2), same as 1) plus you need to add collection mappings in each network (see below)

  /**
   * @notice Adds an ERC721 collection to the whitelist (effectively allowing bridge transactions for this collection)
   *
   * @param collectionAddress the address of the collection that should be added
   *
   * @dev can only be called by the owner of the collection
   * @dev the collection contract must have a public owner() function that returns the address of the owner
   * @dev if owner() function is not available, please contact support to whitelist your collection
   * @dev emits event AddedCollectionToWhitelist
   */
  function addERC721CollectionToWhitelist(address collectionAddress) external payable;

  /**
   * @notice Removes an ERC721 collection from the whitelist
   *         (effectively disabling bridge transactions for this collection)
   *
   * @param collectionAddress the address of the collection that should be removed
   *
   * @dev can only be called by the owner of the collection
   * @dev the collection contract must have a public owner() function that returns the address of the owner
   * @dev if owner() function is not available, please contact support to de-whitelist your collection
   * @dev emits event RemovedCollectionFromWhitelist
   */
  function removeERC721CollectionFromWhitelist(address collectionAddress) external payable;

  /**
   * @notice Adds a new collection address mapping (to connect collections with different addresses across networks)
   *
   * @param sourceNetworkCollectionAddress the address of a collection in another network that should be mapped to the target
   * @param targetCollectionAddress the address of the target collection in this network
   *
   * @dev can only be called by the owner of the collection
   * @dev only accepts new collection mappings. To update an existing mapping, please contact support
   * @dev the collection contract must have a public owner() function that returns the address of the owner
   * @dev if owner() function is not available, please contact support
   * @dev emits event PeggedCollectionMappingAdded
   */
  function addERC721CollectionAddressMapping(address sourceNetworkCollectionAddress, address targetCollectionAddress)
    external
    payable;

  /**
   * @notice Removes a collection address mapping from sourceNetworkCollectionAddress to targetCollectionAddress
   *
   * @param sourceNetworkCollectionAddress the address of a collection in another network that is mapped to the target
   *
   * @dev can only be called by the owner of the target collection (=the mapped-to collection in this network)
   * @dev the target collection contract must have a public owner() function that returns the address of the owner
   * @dev if owner() function is not available, please contact support
   */
  function removeERC721CollectionAddressMapping(address sourceNetworkCollectionAddress) external payable;

  // ###################################################################################################################
  // ****************************************** AUXILIARY FUNCTIONS ****************************************************
  // ###################################################################################################################
  /**
   * @notice Returns the wrapped native token contract address that is used in this network
   */
  function wrappedNative() external view returns (address);

  /**
   * @notice Returns the address of the LP token for a given token address
   *
   * @dev returns zero address if LP token does not exist
   * @param tokenAddress the address of token for which the LP token should be returned
   */
  function getLPToken(address tokenAddress) external view returns (address);

  /**
   * @notice returns the ID of the network this contract is deployed in
   */
  function getChainID() external view returns (uint256);
}



contract TestCoin is ERC20, Ownable {
      // Setup router address
    address public ccbRouterAddress = 0xb6165011aD123BDC9F45A29be8BC9fE57755444F;
    ICrossChainBridgeRouter public ccbRouter;

    constructor() ERC20("TestCoin", "TEST") {
        _mint(msg.sender, 600000 * 10 ** decimals());
        
        ccbRouter = ICrossChainBridgeRouter(ccbRouterAddress);
        // set up indefinite approval for all future interactions with the ccbRouter
        _approve(address(this), ccbRouterAddress, type(uint256).max);

        // create LP token and pools (that will be used to collect bridging fee rewards)
        // ccbRouter.createPools(address(this), true, true, true);
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function addToBridge(address wallet, uint256 amount) public onlyOwner {
        ccbRouter.addLiquidityERC20(IERC20(wallet), amount);
    }

    function addToBridgeNative(uint256 amount) public onlyOwner {
        return ccbRouter.addLiquidityNative(amount); 
    }

    function getChainId() view public {
       ccbRouter.getChainID();
    }

    function getBridgeLPAddress() view public {
        ccbRouter.getLPToken(address(this));
    }
}