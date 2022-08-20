// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./interfaces/IConeLens.sol";
import "./libraries/Math.sol";
import "./interfaces/IVoterProxy.sol";
import "./interfaces/IBribe.sol";
import "./interfaces/ITokensAllowlist.sol";
import "./interfaces/IUserProxy.sol";
import "./interfaces/IUnkwnPoolFactory.sol";

/**
 * @title UnkwnPool
 * @author Unknown
 * @dev For every Cone pool there is a corresponding UnkwnPool
 * @dev unkwnPools represent a 1:1 ERC20 wrapper of a Cone LP token
 * @dev For every unkwnPool there is a corresponding Synthetix MultiRewards contract
 * @dev unkwnPool LP tokens can be staked into the Synthetix MultiRewards contracts to allow LPs to earn fees
 */
contract UnkwnPool is ERC20 {
    /*******************************************************
     *                     Configuration
     *******************************************************/

    // Public addresses
    address public unkwnPoolFactoryAddress;
    address public conePoolAddress;
    address public stakingAddress;
    address public gaugeAddress;
    address public unkwnPoolAddress;
    address public bribeAddress;
    address public tokensAllowlistAddress;

    // Token name and symbol
    string internal tokenName;
    string internal tokenSymbol;

    // Reward tokens allowlist sync mechanism variables
    uint256 public allowedTokensLength;
    mapping(uint256 => address) public rewardTokenByIndex;
    mapping(address => uint256) public indexByRewardToken;
    uint256 public bribeSyncIndex;
    uint256 public bribeNotifySyncIndex;
    uint256 public bribeOrFeesIndex;
    uint256 public nextClaimConeTimestamp;
    uint256 public nextClaimFeeTimestamp;
    mapping(address => uint256) public nextClaimBribeTimestamp;

    // Internal helpers
    IUnkwnPoolFactory internal _unkwnPoolFactory;
    ITokensAllowlist internal _tokensAllowlist;
    IBribe internal _bribe;
    IVoterProxy internal _voterProxy;
    IConeLens internal _coneLens;
    IConeLens.Pool internal _conePoolInfo;

    /*******************************************************
     *                  oxPool Implementation
     *******************************************************/

    /**
     * @notice Return information about the Solid pool associated with this oxPool
     */
    function conePoolInfo() external view returns (IConeLens.Pool memory) {
        return _conePoolInfo;
    }

    /**
     * @notice Initialize oxPool
     * @dev This is called by oxPoolFactory upon creation
     * @dev We need to initialize rather than create using constructor since oxPools are deployed using EIP-1167
     */
    function initialize(
        address _unkwnPoolFactoryAddress,
        address _conePoolAddress,
        address _stakingAddress,
        string memory _tokenName,
        string memory _tokenSymbol,
        address _bribeAddress,
        address _tokensAllowlistAddress
    ) external {
        require(unkwnPoolFactoryAddress == address(0), "Already initialized");
        bribeAddress = _bribeAddress;
        _bribe = IBribe(bribeAddress);
        unkwnPoolFactoryAddress = _unkwnPoolFactoryAddress;
        conePoolAddress = _conePoolAddress;
        stakingAddress = _stakingAddress;
        tokenName = _tokenName;
        tokenSymbol = _tokenSymbol;
        _unkwnPoolFactory = IUnkwnPoolFactory(unkwnPoolFactoryAddress);
        address coneLensAddress = _unkwnPoolFactory.coneLensAddress();
        _coneLens = IConeLens(coneLensAddress);
        _conePoolInfo = _coneLens.poolInfo(conePoolAddress);
        gaugeAddress = _conePoolInfo.gaugeAddress;
        unkwnPoolAddress = address(this);
        tokensAllowlistAddress = _tokensAllowlistAddress;
        _tokensAllowlist = ITokensAllowlist(tokensAllowlistAddress);
        _voterProxy = IVoterProxy(_unkwnPoolFactory.voterProxyAddress());
    }

    /**
     * @notice Set up ERC20 token
     */
    constructor(string memory _tokenName, string memory _tokenSymbol)
        ERC20(_tokenName, _tokenSymbol)
    {}

    /**
     * @notice ERC20 token name
     */
    function name() public view override returns (string memory) {
        return tokenName;
    }

    /**
     * @notice ERC20 token symbol
     */
    function symbol() public view override returns (string memory) {
        return tokenSymbol;
    }

    /*******************************************************
     * Core deposit/withdraw logic (taken from ERC20Wrapper)
     *******************************************************/

    /**
     * @notice Deposit Cone LP and mint oxPool receipt token to msg.sender
     * @param amount The amount of Cone LP to deposit
     */
    function depositLp(uint256 amount) public syncOrClaim {
        // Transfer Cone LP from sender to oxPool
        IERC20(conePoolAddress).transferFrom(msg.sender, address(this), amount);

        // Mint oxPool receipt token
        _mint(unkwnPoolAddress, amount);

        // Transfer oxPool receipt token to msg.sender
        IERC20(unkwnPoolAddress).transfer(msg.sender, amount);

        // Transfer LP to voter proxy
        IERC20(conePoolAddress).transfer(address(_voterProxy), amount);

        // Stake Cone LP into Cone gauge via voter proxy
        _voterProxy.depositInGauge(conePoolAddress, amount);
    }

    /**
     * @notice Withdraw Cone LP and burn msg.sender's oxPool receipt token
     */
    function withdrawLp(uint256 amount) public syncOrClaim {
        // Withdraw Cone LP from gauge
        _voterProxy.withdrawFromGauge(conePoolAddress, amount);

        // Burn oxPool receipt token
        _burn(_msgSender(), amount);

        // Transfer Cone LP back to msg.sender
        IERC20(conePoolAddress).transfer(msg.sender, amount);
    }

    /*******************************************************
     *                 Reward tokens sync mechanism
     *******************************************************/

    /**
     * @notice Fetch current number of rewards for associated bribe
     * @return Returns number of bribe tokens
     */
    function bribeTokensLength() public view returns (uint256) {
        return IBribe(bribeAddress).rewardTokensLength();
    }

    /**
     * @notice Check a given token against the global allowlist and update state in oxPool allowlist if state has changed
     * @param bribeTokenAddress The address to check
     */
    function updateTokenAllowedState(address bribeTokenAddress) public {
        // Detect state changes
        uint256 currentRewardTokenIndex = indexByRewardToken[bribeTokenAddress];
        bool tokenWasPreviouslyAllowed = currentRewardTokenIndex > 0;
        bool tokenIsNowAllowed = _tokensAllowlist.tokenIsAllowed(
            bribeTokenAddress
        );
        bool allowedStateDidntChange = tokenWasPreviouslyAllowed ==
            tokenIsNowAllowed;

        // Allowed state didn't change, don't do anything
        if (allowedStateDidntChange) {
            return;
        }

        // Detect whether a token was added or removed
        bool tokenWasAdded = tokenWasPreviouslyAllowed == false &&
            tokenIsNowAllowed == true;
        bool tokenWasRemoved = tokenWasPreviouslyAllowed == true &&
            tokenIsNowAllowed == false;

        if (tokenWasAdded) {
            // Add bribe token
            allowedTokensLength++;
            indexByRewardToken[bribeTokenAddress] = allowedTokensLength;
            rewardTokenByIndex[allowedTokensLength] = bribeTokenAddress;
        } else if (tokenWasRemoved) {
            // Remove bribe token
            address lastBribeAddress = rewardTokenByIndex[allowedTokensLength];
            uint256 currentIndex = indexByRewardToken[bribeTokenAddress];
            indexByRewardToken[bribeTokenAddress] = 0;
            rewardTokenByIndex[currentIndex] = lastBribeAddress;
            allowedTokensLength--;
        }
    }

    /**
     * @notice Return a list of whitelisted tokens for this oxPool
     * @dev This list updates automatically (upon user interactions with oxPools)
     * @dev The allowlist is based on a global allowlist
     */
    function bribeTokensAddresses() public view returns (address[] memory) {
        address[] memory _bribeTokensAddresses = new address[](
            allowedTokensLength
        );
        for (
            uint256 bribeTokenIndex;
            bribeTokenIndex < allowedTokensLength;
            bribeTokenIndex++
        ) {
            _bribeTokensAddresses[bribeTokenIndex] = rewardTokenByIndex[
                bribeTokenIndex + 1
            ];
        }
        return _bribeTokensAddresses;
    }

    /**
     * @notice Sync bribe token allowlist
     * @dev Syncs "bribeTokensSyncPageSize" (governance configurable) number of tokens at a time
     * @dev Once all tokens have been synced the index is reset and token syncing begins again from the start index
     */
    function syncBribeTokens() public {
        uint256 virtualSyncIndex = bribeSyncIndex;
        uint256 _bribeTokensLength = bribeTokensLength();
        uint256 _pageSize = _tokensAllowlist.bribeTokensSyncPageSize();
        uint256 syncSize = Math.min(_pageSize, _bribeTokensLength);
        bool stopLoop;
        for (
            uint256 syncIndex;
            syncIndex < syncSize && !stopLoop;
            syncIndex++
        ) {
            if (virtualSyncIndex >= _bribeTokensLength) {
                virtualSyncIndex = 0;

                //break loop when we reach the end so pools with a small number of bribes don't loop over and over in one tx
                stopLoop = true;
            }
            address bribeTokenAddress = _bribe.rewardTokens(virtualSyncIndex);
            updateTokenAllowedState(bribeTokenAddress);
            virtualSyncIndex++;
        }
        bribeSyncIndex = virtualSyncIndex;
    }

    /**
     * @notice Notify rewards on allowed bribe tokens
     * @dev Notify reward for "bribeTokensNotifyPageSize" (governance configurable) number of tokens at a time
     * @dev Once all tokens have been notified the index is reset and token notifying begins again from the start index
     */
    function notifyBribeOrFees() public {
        uint256 virtualSyncIndex = bribeOrFeesIndex;
        (uint256 bribeFrequency, uint256 feeFrequency) = _tokensAllowlist
            .notifyFrequency();
        if (virtualSyncIndex >= bribeFrequency + feeFrequency) {
            virtualSyncIndex = 0;
        }
        if (virtualSyncIndex < feeFrequency) {
            notifyFeeTokens();
        } else {
            notifyBribeTokens();
        }
        virtualSyncIndex++;
        bribeOrFeesIndex = virtualSyncIndex;
    }

    /**
     * @notice Notify rewards on allowed bribe tokens
     * @dev Notify reward for "bribeTokensNotifyPageSize" (governance configurable) number of tokens at a time
     * @dev Once all tokens have been notified the index is reset and token notifying begins again from the start index
     */
    function notifyBribeTokens() public {
        uint256 virtualSyncIndex = bribeNotifySyncIndex;
        uint256 _pageSize = _tokensAllowlist.bribeTokensNotifyPageSize();
        uint256 syncSize = Math.min(_pageSize, allowedTokensLength);
        address[] memory notifyBribeTokenAddresses = new address[](syncSize);
        bool stopLoop;
        for (
            uint256 syncIndex;
            syncIndex < syncSize && !stopLoop;
            syncIndex++
        ) {
            if (virtualSyncIndex >= allowedTokensLength) {
                virtualSyncIndex = 0;

                //break loop when we reach the end so pools with a small number of bribes don't loop over and over in one tx
                stopLoop = true;
            }
            address bribeTokenAddress = rewardTokenByIndex[
                virtualSyncIndex + 1
            ];
            if (block.timestamp > nextClaimBribeTimestamp[bribeTokenAddress]) {
                notifyBribeTokenAddresses[syncIndex] = bribeTokenAddress;
            }
            virtualSyncIndex++;
        }

        (, bool[] memory claimed) = _voterProxy.getRewardFromBribe(
            unkwnPoolAddress,
            notifyBribeTokenAddresses
        );

        //update next timestamp for claimed tokens
        for (uint256 i; i < claimed.length; i++) {
            if (claimed[i]) {
                nextClaimBribeTimestamp[notifyBribeTokenAddresses[i]] =
                    block.timestamp +
                    _tokensAllowlist.periodBetweenClaimBribe();
            }
        }
        bribeNotifySyncIndex = virtualSyncIndex;
    }

    /**
     * @notice Notify rewards on fee tokens
     */
    function notifyFeeTokens() public {
        //if fee claiming is disabled for this pool or it's not time to claim yet, return
        if (
            _tokensAllowlist.feeClaimingDisabled(unkwnPoolAddress) ||
            block.timestamp < nextClaimFeeTimestamp
        ) {
            return;
        }

        // if claimed, update next claim timestamp
        bool claimed = _voterProxy.getFeeTokensFromBribe(unkwnPoolAddress);
        if (claimed) {
            nextClaimFeeTimestamp =
                block.timestamp +
                _tokensAllowlist.periodBetweenClaimFee();
        }
    }

    /**
     * @notice Sync a specific number of bribe tokens
     * @param startIndex The index to start at
     * @param endIndex The index to end at
     * @dev If endIndex is greater than total number of reward tokens, use reward token length as end index
     */
    function syncBribeTokens(uint256 startIndex, uint256 endIndex) public {
        uint256 _bribeTokensLength = bribeTokensLength();
        if (endIndex > _bribeTokensLength) {
            endIndex = _bribeTokensLength;
        }
        for (
            uint256 syncIndex = startIndex;
            syncIndex < endIndex;
            syncIndex++
        ) {
            address bribeTokenAddress = _bribe.rewardTokens(syncIndex);
            updateTokenAllowedState(bribeTokenAddress);
        }
    }

    /**
     * @notice Batch update token allowed states given a list of tokens
     * @param bribeTokensAddresses A list of addresses to update
     */
    function updateTokensAllowedStates(address[] memory bribeTokensAddresses)
        public
    {
        for (
            uint256 bribeTokenIndex;
            bribeTokenIndex < bribeTokensAddresses.length;
            bribeTokenIndex++
        ) {
            address bribeTokenAddress = bribeTokensAddresses[bribeTokenIndex];
            updateTokenAllowedState(bribeTokenAddress);
        }
    }

    /*******************************************************
     *                  Modifiers
     *******************************************************/
    modifier syncOrClaim() {
        syncBribeTokens();
        notifyBribeOrFees();
        _;
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
pragma solidity 0.8.11;

interface IConeLens {
    struct Pool {
        address id;
        string symbol;
        bool stable;
        address token0Address;
        address token1Address;
        address gaugeAddress;
        address bribeAddress;
        address[] bribeTokensAddresses;
        address fees;
        uint256 totalSupply;
    }

    struct PoolReserveData {
        address id;
        address token0Address;
        address token1Address;
        uint256 token0Reserve;
        uint256 token1Reserve;
        uint8 token0Decimals;
        uint8 token1Decimals;
    }

    struct PositionVe {
        uint256 tokenId;
        uint256 balanceOf;
        uint256 locked;
    }

    struct PositionBribesByTokenId {
        uint256 tokenId;
        PositionBribe[] bribes;
    }

    struct PositionBribe {
        address bribeTokenAddress;
        uint256 earned;
    }

    struct PositionPool {
        address id;
        uint256 balanceOf;
    }

    function poolsLength() external view returns (uint256);

    function voterAddress() external view returns (address);

    function veAddress() external view returns (address);

    function poolsFactoryAddress() external view returns (address);

    function gaugesFactoryAddress() external view returns (address);

    function minterAddress() external view returns (address);

    function coneAddress() external view returns (address);

    function vePositionsOf(address) external view returns (PositionVe[] memory);

    function bribeAddresByPoolAddress(address) external view returns (address);

    function gaugeAddressByPoolAddress(address) external view returns (address);

    function poolsPositionsOf(address)
        external
        view
        returns (PositionPool[] memory);

    function poolsPositionsOf(
        address,
        uint256,
        uint256
    ) external view returns (PositionPool[] memory);

    function poolInfo(address) external view returns (Pool memory);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

library Math {
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function abs(int256 x) internal pure returns (uint256) {
        return uint256(x >= 0 ? x : -x);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IVoterProxy {
    function depositInGauge(address, uint256) external;

    function withdrawFromGauge(address, uint256) external;

    function getRewardFromGauge(address _conePool, address[] memory _tokens)
        external;

    function depositNft(uint256) external;

    function veAddress() external returns (address);

    function veDistAddress() external returns (address);

    function lockCone(uint256 amount) external;

    function primaryTokenId() external view returns (uint256);

    function vote(address[] memory, int256[] memory) external;

    function votingSnapshotAddress() external view returns (address);

    function coneInflationSinceInception() external view returns (uint256);

    function getRewardFromBribe(
        address conePoolAddress,
        address[] memory _tokensAddresses
    ) external returns (bool allClaimed, bool[] memory claimed);

    function getFeeTokensFromBribe(address conePoolAddress)
        external
        returns (bool allClaimed);

    function claimCone(address conePoolAddress)
        external
        returns (bool _claimCone);

    function setVoterProxyAssetsAddress(address _voterProxyAssetsAddress)
        external;

    function detachNFT(uint256 startingIndex, uint256 range) external;

    function claim() external;

    function whitelist(address tokenAddress) external;

    function whitelistingFee() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IBribe {
    function rewardTokensLength() external view returns (uint256);

    function rewardTokens(uint256) external view returns (address);

    function earned(address, uint256) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface ITokensAllowlist {
    function tokenIsAllowed(address) external view returns (bool);

    function bribeTokensSyncPageSize() external view returns (uint256);

    function bribeTokensNotifyPageSize() external view returns (uint256);

    function bribeSyncLagLimit() external view returns (uint256);

    function notifyFrequency()
        external
        view
        returns (uint256 bribeFrequency, uint256 feeFrequency);

    function feeClaimingDisabled(address) external view returns (bool);

    function periodBetweenClaimCone() external view returns (uint256);

    function periodBetweenClaimFee() external view returns (uint256);

    function periodBetweenClaimBribe() external view returns (uint256);

    function tokenIsAllowedInPools(address) external view returns (bool);

    function setTokenIsAllowedInPools(
        address[] memory tokensAddresses,
        bool allowed
    ) external;

    function oogLoopLimit() external view returns (uint256);

    function notifyConeThreshold() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IUserProxy {
    struct PositionStakingPool {
        address stakingPoolAddress;
        address unkwnPoolAddress;
        address conePoolAddress;
        uint256 balanceOf;
        RewardToken[] rewardTokens;
    }

    function initialize(
        address,
        address,
        address,
        address[] memory
    ) external;

    struct RewardToken {
        address rewardTokenAddress;
        uint256 rewardRate;
        uint256 rewardPerToken;
        uint256 getRewardForDuration;
        uint256 earned;
    }

    struct Vote {
        address poolAddress;
        int256 weight;
    }

    function convertNftToUnCone(uint256) external;

    function convertConeToUnCone(uint256) external;

    function depositLpAndStake(address, uint256) external;

    function depositLp(address, uint256) external;

    function stakingAddresses() external view returns (address[] memory);

    function initialize(address, address) external;

    function stakingPoolsLength() external view returns (uint256);

    function unstakeLpAndWithdraw(
        address,
        uint256,
        bool
    ) external;

    function unstakeLpAndWithdraw(address, uint256) external;

    function unstakeLpWithdrawAndClaim(address) external;

    function unstakeLpWithdrawAndClaim(address, uint256) external;

    function withdrawLp(address, uint256) external;

    function stakeUnkwnLp(address, uint256) external;

    function unstakeUnkwnLp(address, uint256) external;

    function ownerAddress() external view returns (address);

    function stakingPoolsPositions()
        external
        view
        returns (PositionStakingPool[] memory);

    function stakeUnCone(uint256) external;

    function unstakeUnCone(uint256) external;

    function unstakeUnCone(address, uint256) external;

    function convertConeToUnConeAndStake(uint256) external;

    function convertNftToUnConeAndStake(uint256) external;

    function claimUnConeStakingRewards() external;

    function claimPartnerStakingRewards() external;

    function claimStakingRewards(address) external;

    function claimStakingRewards(address[] memory) external;

    function claimStakingRewards() external;

    function claimVlUnkwnRewards() external;

    function depositUnkwn(uint256, uint256) external;

    function withdrawUnkwn(bool, uint256) external;

    function voteLockUnkwn(uint256, uint256) external;

    function withdrawVoteLockedUnkwn(uint256, bool) external;

    function relockVoteLockedUnkwn(uint256) external;

    function removeVote(address) external;

    function registerStake(address) external;

    function registerUnstake(address) external;

    function resetVotes() external;

    function setVoteDelegate(address) external;

    function clearVoteDelegate() external;

    function vote(address, int256) external;

    function vote(Vote[] memory) external;

    function votesByAccount(address) external view returns (Vote[] memory);

    function migrateUnConeToPartner() external;

    function stakeUnConeInUnkwnV1(uint256) external;

    function unstakeUnConeInUnkwnV1(uint256) external;

    function redeemUnkwnV1(uint256) external;

    function redeemAndStakeUnkwnV1(uint256) external;

    function whitelist(address) external;

    function implementationsAddresses()
        external
        view
        returns (address[] memory);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IUnkwnPoolFactory {
    function unkwnPoolsLength() external view returns (uint256);

    function isUnkwnPool(address) external view returns (bool);

    function isUnkwnPoolOrLegacyUnkwnPool(address) external view returns (bool);

    function UNKWN() external view returns (address);

    function syncPools(uint256) external;

    function unkwnPools(uint256) external view returns (address);

    function unkwnPoolByConePool(address) external view returns (address);

    function vlUnkwnAddress() external view returns (address);

    function conePoolByUnkwnPool(address) external view returns (address);

    function syncedPoolsLength() external returns (uint256);

    function coneLensAddress() external view returns (address);

    function voterProxyAddress() external view returns (address);

    function rewardsDistributorAddress() external view returns (address);

    function tokensAllowlist() external view returns (address);
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