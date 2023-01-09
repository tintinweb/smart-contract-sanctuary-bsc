// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity >=0.8.10 <0.9.0;

import "ERC4626.sol";
import "PartiallyUpgradable.sol";

/// @notice Yagger ERC4646 tokenized vault implementation.
/// @author kader 

contract YG4626 is ERC4626, PartiallyUpgradable {

    event LockStatus(bool _status);
    event WhiteList(address _contract, bool _status);

    bool public isLocked;
    uint256 public lockPeriod;
    mapping (address=>bool) public whiteList; // contracts which are whitelisted for receiving locked funds
    mapping (address=>uint256) public lockedTimestamp;

    /// @notice Creates a new vault that accepts a specific underlying token.
    /// @param _underlying The ERC20 compliant token the vault should accept.
    /// @param _name The name for the vault token.
    /// @param _symbol The symbol for the vault token.
    
    constructor(
        ERC20 _underlying,
        string memory _name,
        string memory _symbol
    ) ERC4626(address(_underlying), _name, _symbol) {
        isLocked = true;
        lockPeriod = 7776000;
    }

    function setLock(bool _status) external onlyOwner {
        isLocked = _status;
        emit LockStatus(_status);
    }
    
    function lock(address _account, uint256 timestamp) public onlyOwner {
        lockedTimestamp[_account] = timestamp;
    }

    function setWhiteList(address _contract, bool _status) external onlyOwner {
        if (_status) {
            whiteList[_contract] = _status;
        } else {
            delete whiteList[_contract];
        }
        emit WhiteList(_contract, _status);
    }
    
    function setLockPeriod(uint256 _lockPeriod) public onlyOwner {
        lockPeriod = _lockPeriod;
    }

    /**
     * @dev similar to ERC20 balanceOf but returns 
     * the balance of the account reflected in wrapped Token (underlying token)
     */
    function rbalanceOf(address _account) public view returns (uint256) {
        return assetsOf(_account);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from_,
        address to_,
        uint256 amount_
    ) internal override {
        super._beforeTokenTransfer(from_, to_, amount_);

        if (isLocked) {
            if (from_ != address(0)) {
                // This is a transfer or burn
                if (whiteList[to_] == false) {
                    require(lockedTimestamp[from_]<=block.timestamp, "Token is locked");
                }
            } else {
                // this is a mint
            }
        }   
    }

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
        address from_,
        address to_,
        uint256 amount_
    ) internal override {
        super._afterTokenTransfer(from_, to_, amount_);

        if (to_ != address(0)) {
            if (from_ == address(0)) {
                // mint
                if (whiteList[to_] == false) {
                    lockedTimestamp[to_] = block.timestamp + lockPeriod;
                }
            }          
        }
    }
}

// SPDX-License-Identifier: AGPL-3.0-only

pragma solidity >=0.8.10 <0.9.0;

import "IERC20.sol";
import "IERC4626.sol";
import "ERC20Permit.sol";
import {Owned} from  "Owned.sol";

/// @notice Yagger ERC4646 tokenized vault implementation.
/// @author Kader https://github.com/aallamaa 

abstract contract ERC4626 is IERC4626, ERC20Permit, Owned {

    /* IMMUTABLES */

    /// @notice The underlying token the vault accepts.
    address public immutable asset;

    /// @notice The base unit of the underlying token and hence vault.
    /// @dev Equal to 10 ** decimals. Used for fixed point arithmetic.
    uint256 internal immutable baseUnit;

    /// @dev deployment timestamp of the smart contract
    uint256 public immutable deployTS;

    /// @dev Funds used for yield generation
    uint256 public usedFunds;

    /// @notice Creates a new vault that accepts a specific underlying token.
    /// @param _asset The ERC20 compliant token the vault should accept.
    /// @param _name The name for the vault token.
    /// @param _symbol The symbol for the vault token.

    constructor(
        address _asset,
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol, IERC20(_asset).decimals()) {
        asset = _asset;
        deployTS = block.timestamp;
        baseUnit = 10**_decimals;
    }

    function _safeTransferFrom(address _owner, address _receiver, uint256 amount) internal returns (uint256 finalAmount) {
        uint256 initialBalance = IERC20(asset).balanceOf(_receiver);
        IERC20(asset).transferFrom(_owner, _receiver, amount);
        finalAmount = IERC20(asset).balanceOf(_receiver) - initialBalance;
    }

    /*///////////////////////////////////////////////////////////////
                        DEPOSIT/WITHDRAWAL LOGIC
    ///////////////////////////////////////////////////////////////*/

    /// @notice Maximum amount of the underlying asset that can be deposited into the Vault for the receiver, through a deposit call.
    /// @return maxAssets max amount that can be deposited by caller
    function maxDeposit(address) public pure returns (uint256 maxAssets) {
        maxAssets = type(uint256).max;
    }
    
    /// @notice Allows an on-chain or off-chain user to simulate the effects of their deposit 
    /// @notice at the current block, given current on-chain conditions.
    /// @param assets The amount of underlying assets to deposit
    /// @return shares The amount of the underlying asset.
    function convertToShares(uint256 assets) public view returns (uint256 shares) {
        shares = (assets * baseUnit) / assetsPerShare();
    }

    /// @notice Allows an on-chain or off-chain user to simulate the effects of their mint
    /// @notice at the current block, given current on-chain conditions.
    /// @param shares The amount of the shares.
    /// @return assets The amount of underlying assets to deposit
    function convertToAssets(uint256 shares) public view returns (uint256 assets) {
        if (_totalSupply == 0) {return 0;}
        assets = (shares * assetsPerShare()) / baseUnit;

    }

    /// @notice Allows an on-chain or off-chain user to simulate the effects of their deposit 
    /// @notice at the current block, given current on-chain conditions.
    /// @param assets The amount of underlying assets to deposit
    /// @return shares The amount of the underlying asset.
    function previewDeposit(uint256 assets) external view virtual returns (uint256 shares) {
        return convertToShares(assets);
    }

    /// @notice Deposit a specific amount of underlying assets.
    /// @param assets The amount of the underlying asset to deposit.
    /// @param receiver The address to receive shares corresponding to the deposit
    function _deposit(uint256 assets, address receiver) internal returns (uint256 shares) {
        uint256 exchangeRate_ = assetsPerShare();
        // Transfer in underlying tokens from the user.
        // Determine the real amount of underlying token received .
        uint256 realAssets = _safeTransferFrom(_msgSender(), address(this), assets);
        shares = (realAssets * baseUnit) / exchangeRate_;
        require((shares!=0), "ZERO_SHARES");
        // Determine the equivalent amount of shares and mint them.
        _mint(receiver, shares);
        // Should we state realUnderlyingAmount or underlyingAmount in the Deposit event
        emit Deposit(_msgSender(), receiver, realAssets, shares);
        // This will revert if the user does not have the amount specified.
        
    }

    /// @notice Deposit a specific amount of underlying assets.
    /// @param assets The amount of the underlying asset to deposit.
    /// @param receiver The address to receive shares corresponding to the deposit
    function deposit(uint256 assets, address receiver) external virtual returns (uint256 shares) {
        return _deposit(assets, receiver);
    }    

    function depositWithPermit(uint256 assets, address receiver, uint deadline, uint8 v, bytes32 r, bytes32 s) external virtual returns (uint256 shares) {
        IERC2612Permit(asset).permit(_msgSender(), address(this), assets, deadline, v, r, s);
        return _deposit(assets, receiver);
    }


    /// @notice Returns Total number of underlying shares that caller can be mint..
    /// @return maxShares max amount that can be deposited by caller
    function maxMint(address) public pure returns (uint256 maxShares) {
        maxShares = type(uint256).max;
    }

    /// @notice Allows an on-chain or off-chain user to simulate the effects of their mint
    /// @notice at the current block, given current on-chain conditions.
    /// @param shares The amount of the shares.
    /// @return assets The amount of underlying assets to deposit
    function previewMint(uint256 shares) public view returns (uint256 assets) {
        assets = (shares * assetsPerShare()) / baseUnit;
    }

    /// @notice Deposit a specific amount of underlying assets.
    /// @param assets The amount of the underlying asset to deposit.
    /// @param receiver The address to receive shares corresponding to the deposit
    function mint(uint256 shares, address receiver) public virtual returns (uint256 assets) {
        uint256 targetAssets = previewMint(shares);
        uint256 exchangeRate_ = assetsPerShare();
        // Transfer in underlying assets from the user.
        // Determine the real amount of underlying token received .
        assets = _safeTransferFrom(_msgSender(), address(this), targetAssets);
        uint256 finalShares = (assets * baseUnit) / exchangeRate_;
        require((finalShares!=0), "ZERO_SHARES");
        // Determine the equivalent amount of shares and mint them.
        _mint(receiver, finalShares);
        // Should we state realUnderlyingAmount or underlyingAmount in the Deposit event
        emit Deposit(_msgSender(), receiver, assets, finalShares);
    }
    
    
    function maxWithdraw(address user) public view virtual returns (uint256 maxAssets) {
        return assetsOf(user);
    }

    function previewWithdraw(uint256 assets) public view virtual returns (uint256 shares) {
        if (_totalSupply == 0) {return 0;}
        shares = (assets * baseUnit ) / assetsPerShare();
        // if (convertToAssets(shares) < assets) {
        //     shares += 1;
        // }
    }
    
    /// @notice Withdraw a specific amount of underlying assets.
    /// @param assets The amount of underlying assets to withdraw.
    /// @param receiver The address to receive underlying assets corresponding to the withdrawal.
    /// @param owner The address from which shares are withdrawn.
    function withdraw(uint256 assets, address receiver, address owner) external virtual returns (uint256 shares) {
        shares = previewWithdraw(assets);
        address caller = _msgSender();
        if (caller != owner) {
            _spendAllowance(owner, caller, shares);
        }
        // Determine the equivalent assets of shares and burn them.
        // This will revert if the user does not have enough shares.
        _burn(owner, shares);
        emit Withdraw(caller, receiver, owner, assets, shares);
        require(totalAssets() >= assets, "funds are not availables (usedFunds)");
        IERC20(asset).transfer(receiver, assets);
    }

    function maxRedeem(address user) public view virtual returns (uint256 maxShares) {
        return _balances[user];
    }

    function previewRedeem(uint256 shares) public view virtual returns (uint256 assets) {
        return convertToAssets(shares);
    }

    /// @notice Redeem a specific amount of shares for underlying tokens.
    /// @param shares The amount of shares to redeem for underlying tokens.
    /// @param receiver The address to receive underlying tokens corresponding to the withdrawal.
    /// @param owner The address from which shares are withdrawn.
    /// @return assets number of assets redeemed
    function redeem(uint256 shares, address receiver, address owner) external virtual returns (uint256 assets) {
        address caller = _msgSender();
        if (caller != owner) {
            _spendAllowance(owner, caller, shares);
        }
        // Determine the equivalent amount of underlying assets.
        require((assets = previewRedeem(shares)) != 0, "ZERO_ASSETS");
        // Withdraw from strategies if needed and transfer.
        require(totalAssets() >= assets, "funds are not availables (usedFunds)");
        // Burn the provided amount of shares.
        // This will revert if the user does not have enough shares.
        _burn(owner, shares);

        emit Withdraw(caller, receiver, owner, assets, shares);

        IERC20(asset).transfer(receiver, assets);
    }


    /*///////////////////////////////////////////////////////////////
                        VAULT ACCOUNTING LOGIC
    //////////////////////////////////////////////////////////////*/


    /// @notice Returns a user's Vault balance in underlying assets.
    /// @param depositor The user to get the underlying balance of.
    /// @return assets The user's Vault balance in underlying assets.
    function assetsOf(address depositor) public view returns (uint256 assets) {
        assets = (_balances[depositor] * assetsPerShare()) / baseUnit;
    }

    /// @notice Returns the amount of underlying asset a share can be redeemed for.
    /// @return assetsPerUnitShare The amount of underlying assets a share can be redeemed for.
    function assetsPerShare() public view returns (uint256 assetsPerUnitShare) {
        // Get the total supply of shares.
        uint256 shareSupply = _totalSupply;

        // If there are no shares in circulation, return an exchange rate of 1:1.
        if (shareSupply == 0) return baseUnit;

        // Calculate the exchange rate by dividing the total holdings by the share supply.
        assetsPerUnitShare = (totalAssets() * baseUnit) / shareSupply;
    }

    /// @notice Calculates the total amount of underlying asset the Vault holds.
    /// @return totalAssets The total amount of underlying asset the Vault holds.

    /// scenario 1: on repaie plus que ce qu'on a emprunté
    /// totalAssets = 100
    /// on emprunte 20
    /// totalAssets = 100 (balance = 80 + 20 usedFunds)

    /// avec les 20 on a généré 25
    /// totalAssets = 125 (balance = 105, usedFunds = 0)


    function totalAssets() public view virtual returns (uint256) {
        return usedFunds + IERC20(asset).balanceOf(address(this));
    }

    function addFunds(uint256 original_amount, uint256 repaid_amount) public onlyOwner returns (uint256 final_repaid_amount) {
        final_repaid_amount = _safeTransferFrom(_msgSender(), address(this), repaid_amount);
        usedFunds -= original_amount;
    }

    function removeFunds(uint256 amount) public onlyOwner {
        usedFunds += amount;
        IERC20(asset).transfer(_msgSender(), amount);
        //emit Withdraw(address(this), _msgSender(), amount);
    }

    function apy() external view returns (uint256 _apy, uint256 precision, uint256 duration) {
        // 31536000 is number of seconds in a year
        // APY = (1 + apy / precision ) ^ (31536000 / duration) * 100 - 100  
        precision = baseUnit;
        _apy = assetsPerShare() - precision;
        duration = (block.timestamp - deployTS);
    }

}

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {

    function decimals() external view returns (uint8);

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0;
import "IERC20.sol";
import "ERC20.sol";

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC4626 is IERC20 {

    /* EVENTS */

    /// @notice Emitted after a successful deposit.
    /// @param sender The address that deposited into the Vault.
    /// @param receiver The address that received deposit shares.
    /// @param assets The amount of underlying assets that were deposited.
    /// @param shares The amount of shares minted in exchange for the assets.
    event Deposit(address indexed sender, address indexed receiver, uint256 assets, uint256 shares);

    /// @notice Emitted after a successful withdrawal.
    /// @param caller The address that withdrew from the Vault.
    /// @param receiver The destination for withdrawn tokens.
    /// @param owner The address from which tokens were withdrawn.
    /// @param assets The amount of underlying assets that were withdrawn.
    /// @param shares The amount of shares burnt in exchange for the assets.
    event Withdraw(address indexed caller, address indexed receiver, address indexed owner, uint256 assets, uint256 shares);

    function asset() external view returns (address);
    function maxDeposit(address receiver) external view returns (uint256 maxAssets);
    function convertToShares(uint256 assets) external view returns (uint256 shares);
    function previewDeposit(uint256 assets) external view returns (uint256 shares);
    function deposit(uint256 assets, address receiver) external  returns (uint256 shares);
    function maxMint(address caller) external view returns (uint256 maxShares);
    function convertToAssets(uint256 shares) external view returns (uint256 assets);
    function previewMint(uint256 shares) external view returns (uint256 assets);
    function mint(uint256 shares, address receiver) external  returns (uint256 assets);
    function maxWithdraw(address user) external view returns (uint256 maxAssets);
    function previewWithdraw(uint256 assets) external view  returns (uint256 shares);
    function withdraw(uint256 assets, address receiver, address owner) external  returns (uint256 shares);
    function maxRedeem(address owner) external view returns (uint256 maxShares);
    function previewRedeem(uint256 shares) external view  returns (uint256 assets);
    function redeem(uint256 shares, address to, address from) external returns (uint256 amount);
    function assetsOf(address depositor) external view returns (uint256 assets);
    function assetsPerShare() external view returns (uint256 assetsPerUnitShare);
    function totalAssets() external view returns (uint256);
    function addFunds(uint256 original_amount, uint256 repaid_amount) external returns (uint256);
    function removeFunds(uint256 amount) external ;
    function apy() external view returns (uint256 _apy, uint256 precision, uint256 duration);

}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.4 <0.9.0;

import "Context.sol";
import "IERC20.sol";

abstract contract ERC20 is Context, IERC20 {
    // TODO comment actual hash value.
    bytes32 private constant ERC20TOKEN_ERC1820_INTERFACE_ID =
        keccak256("ERC20Token");

    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) internal _allowances;

    uint256 internal _totalSupply;

    string internal  _name;

    string internal _symbol;

    uint8 internal _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
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
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
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
        address spender = _msgSender();
        _spendAllowance(sender, spender, amount);
        _transfer(sender, recipient, amount);
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
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
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
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
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
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
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
     * - `to` cannot be the zero address.
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
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    // Considering deprication to reduce size of bytecode as changing _decimals to internal acheived the same functionality.
    // function _setupDecimals(uint8 decimals_) internal {
    //     _decimals = decimals_;
    // }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from_,
        address to_,
        uint256 amount_
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
// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

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

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.4 <0.9.0;

import "IERC2612Permit.sol";

import "ERC20.sol";
import "Counters.sol";

abstract contract ERC20Permit is ERC20, IERC2612Permit {
    using Counters for Counters.Counter;

    mapping(address => Counters.Counter) private _nonces;

    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    // bytes32 public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

    bytes32 public DOMAIN_SEPARATOR;

    string public constant EIP712_REVISION = "1";
    bytes32 public constant EIP712_DOMAIN =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
    bytes32 public constant PERMIT_TYPEHASH =
        keccak256(
            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );


    constructor() {

        uint256 chainID;
        assembly {
            chainID := chainid()
        }

        DOMAIN_SEPARATOR = keccak256(abi.encode(
            EIP712_DOMAIN,
            keccak256(bytes(name())),
            keccak256(bytes(EIP712_REVISION)),
            chainID,
            address(this)
        ));
    }

    /**
     * @dev See {IERC2612Permit-permit}.
     *
     */
    function permit(
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual override {
        require(block.timestamp <= deadline, "Permit: expired deadline");

        bytes32 permitDataDigest =
            keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, amount, _nonces[owner].current(), deadline));

        bytes32 _hash = keccak256(abi.encodePacked(uint16(0x1901), DOMAIN_SEPARATOR, permitDataDigest));

        address signer = ecrecover(_hash, v, r, s);
        require(signer != address(0) && signer == owner, "ZeroSwapPermit: Invalid signature");

        _nonces[owner].increment();
        _approve(owner, spender, amount);
    }

    /**
     * @dev See {IERC2612Permit-nonces}.
     */
    function nonces(address owner) public view override returns (uint256) {
        return _nonces[owner].current();
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0;

interface IERC2612Permit {
    /**
     * @dev Sets `amount` as the allowance of `spender` over `owner`'s tokens,
     * given `owner`'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current ERC2612 nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Counters.sol)

pragma solidity >=0.8.4 <0.9.0;

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

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.4 <0.9.0;

import "Context.sol";
import "IERC20.sol";

contract Owned is Context {

    event OwnershipTransferred(address indexed from, address indexed to);
    event Received(address, uint);
    
    address owner;

    constructor() Context() { owner = _msgSender(); }
    
    
    modifier onlyOwner {
        require(_msgSender() == owner);
        _;
    }

    function getOwner() public view virtual returns (address) {
        return owner;
    }
    
    function transferOwnership(address _newOwner) public onlyOwner {
        require (_msgSender() != address(0), 'Transfer to a real address');
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }

    function xtransfer(address _token, address _creditor, uint256 _value) public onlyOwner returns (bool) {
        return IERC20(_token).transfer(_creditor, _value);
    }
    
    function xapprove(address _token, address _spender, uint256 _value) public onlyOwner returns (bool) {
        return IERC20(_token).approve(_spender, _value);
    }

    function withdrawEth() public onlyOwner returns (bool) {
        address payable ownerPayable = payable(owner);
        return ownerPayable.send(address(this).balance);
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.4 <0.9.0;

import "Owned.sol";

contract PartiallyUpgradable is Owned {

    address public partialUpgrade;

    function partialUpgradable(address _partialUpgrade) public onlyOwner {
        partialUpgrade = _partialUpgrade;
    }

    /**
     * @dev Fallback function that delegates calls to the address returned by `_implementation()`. Will run if no other
     * function in the contract matches the call data.
     */
    fallback() external payable virtual {
        address _partialUpgrade = partialUpgrade;
        if (_partialUpgrade != address(0)) {
            assembly {
                calldatacopy(0, 0, calldatasize())
                let result := delegatecall(gas(), _partialUpgrade, 0, calldatasize(), 0, 0)
                returndatacopy(0, 0, returndatasize())
                switch result
                case 0 {
                    revert(0, returndatasize())
                }
                default {
                    return(0, returndatasize())
                }
            }

        } else {
            revert('No such function');
        }
    }


}