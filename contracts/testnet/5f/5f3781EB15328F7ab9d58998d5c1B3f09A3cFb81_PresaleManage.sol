// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./SharedStructs.sol";
import "./StandardToken.sol";
import "./LiquidityToken.sol";
import "./StandardTokenFactory.sol";
import "./LiquidityTokenFactory.sol";

contract CreateManage {
    struct feeInfo {
        uint256 normal;
        uint256 mint;
        uint256 burn;
        uint256 pause;
        uint256 blacklist;
        uint256 deflation;
    }

    address public owner;

    // address factory_address;
    address router_address;

    mapping(address => address[]) tokens;

    feeInfo public fee;
    StandardTokenFactory internal standardTokenFactory;
    LiquidityTokenFactory internal liquidityTokenFactory;

    event OwnerWithdrawSuccess(uint256 value);
    event CreateStandardSuccess(address);
    event setOwnerSucess(address);
    event createLiquditySuccess(address);
    event InitFeeSuccess();

    // constructor(address _owner, address factory_addr, address router_Addr) {
    constructor(
        address _owner,
        address router_Addr,
        StandardTokenFactory _standardTokenFactory,
        LiquidityTokenFactory _liquidityTokenFactory
    ) {
        owner = _owner;

        // factory_address = factory_addr;
        router_address = router_Addr;

        standardTokenFactory = _standardTokenFactory;
        liquidityTokenFactory = _liquidityTokenFactory;
    }

    function setOwner(address newowner) public {
        require(msg.sender == owner, "Only manager can do it");
        owner = newowner;
        emit setOwnerSucess(owner);
    }

    function ownerWithdraw() public {
        require(msg.sender == owner, "Only manager can withdraw");
        address payable reciever = payable(owner);
        reciever.transfer(address(this).balance);
        // owner.transfer(address(this).balance);
        emit OwnerWithdrawSuccess(address(this).balance);
    }

    function initFee(feeInfo memory _fee) public {
        fee = _fee;
        emit InitFeeSuccess();
    }

    function calcFee(SharedStructs.status memory _state)
        internal
        view
        returns (uint256)
    {
        uint256 totalfee = fee.normal;

        if (_state.mintflag > 0) {
            totalfee = totalfee + fee.mint;
        }

        if (_state.burnflag > 0) {
            totalfee = totalfee + fee.burn;
        }

        if (_state.pauseflag > 0) {
            totalfee = totalfee + fee.pause;
        }

        if (_state.blacklistflag > 0) {
            totalfee = totalfee + fee.blacklist;
        }

        return totalfee;
    }

    /*
     * @notice Creates a new Presale contract and registers it in the PresaleFactory.sol.
     */

    function createStandard(
        address creator_,
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 tokenSupply_,
        SharedStructs.status memory _state
    ) public payable {
        require(msg.value >= calcFee(_state), "Balance is insufficent");

        StandardToken token = standardTokenFactory.deploy(
            creator_,
            name_,
            symbol_,
            decimals_,
            tokenSupply_,
            _state
        );

        tokens[address(creator_)].push(address(token));

        emit CreateStandardSuccess(address(token));
    }

    function createLiquidity(
        address creator_,
        address reciever,
        string memory name_,
        string memory symbol_,
        uint8 decimal_,
        uint256 supply,
        uint256 settingflag,
        uint256[4] memory fees,
        SharedStructs.status memory _state
    ) public payable {
        require(msg.value >= calcFee(_state), "Balance is insufficent");

        LiquidityToken token = liquidityTokenFactory.deploy(
            router_address,
            creator_,
            reciever,
            name_,
            symbol_,
            decimal_,
            supply
        );
        token.setFee(settingflag, fees);
        token.setStatus(_state);
        tokens[creator_].push(address(token));

        emit createLiquditySuccess(address(token));
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getCreatedToken(address creater)
        public
        view
        returns (address[] memory)
    {
        return tokens[address(creater)];
    }
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

/**
 * @dev Collection of functions related to the address type
 */
library Address {
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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
        return functionCall(target, data, "Address: low-level call failed");
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
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
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
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SharedStructs {
    struct status {
        uint256 mintflag;
        uint256 pauseflag;
        uint256 burnflag;
        uint256 blacklistflag;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./SharedStructs.sol";

contract StandardToken is Context, IERC20, IERC20Metadata {
    // address public owner;
    address public owner;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;

    uint256 public isstandard = 1;

    bool private _paused;
    SharedStructs.status public state;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) _blacklist;

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    modifier canMint() {
        require(state.mintflag > 0, "Mintable: Disabled Mint");
        _;
    }

    modifier canPause() {
        require(state.mintflag > 0, "Pausable: Disabled Pause");
        _;
    }

    modifier canBurn() {
        require(state.burnflag > 0, "Burnable: Disabled Burn");
        _;
    }

    modifier canBlacklist() {
        require(state.blacklistflag > 0, "Blacklist: Disabled Blacklist");
        _;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    event BlacklistUpdated(address indexed user, bool value);
    event Paused(address account);
    event Unpaused(address account);

    /**
     * @dev Sets the values for {name}, {symbol} and {decimals}.
     *
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(
        address creator_,
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 tokenSupply_,
        SharedStructs.status memory _state
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        owner = creator_;

        state = _state;

        _mint(creator_, tokenSupply_);

        _paused = false;
    }

    function setStatus(SharedStructs.status memory _state) internal virtual {
        state = _state;
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
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
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
        return _decimals;
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
    function allowance(address _owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[_owner][spender];
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
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        _approve(sender, _msgSender(), currentAllowance - amount);

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
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

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
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
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
    function mint(address account, uint256 amount)
        public
        virtual
        onlyOwner
        canMint
    {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;

        emit Transfer(address(0), account, amount);
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
    function burn(uint256 amount) public virtual onlyOwner canBurn {
        require(
            _msgSender() != address(0),
            "ERC20: burn from the zero address"
        );

        _beforeTokenTransfer(_msgSender(), address(0), amount);

        uint256 accountBalance = _balances[_msgSender()];

        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");

        _balances[_msgSender()] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(_msgSender(), address(0), amount);
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
        address _owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[_owner][spender] = amount;
        emit Approval(_owner, spender, amount);
    }

    function blacklistUpdate(address user, bool value)
        public
        virtual
        onlyOwner
        canBlacklist
    {
        // require(_owner == _msgSender(), "Only owner is allowed to modify blacklist.");
        _blacklist[user] = value;
        emit BlacklistUpdated(user, value);
    }

    function isBlackListed(address user)
        public
        view
        virtual
        canBlacklist
        returns (bool)
    {
        return _blacklist[user];
    }

    function paused() public view virtual canPause returns (bool) {
        return _paused;
    }

    function _pause() public virtual onlyOwner canPause whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() public virtual onlyOwner canPause whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
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
        address sender,
        address to,
        uint256 amount
    ) internal virtual {
        // require(sender != address(0), "ERC20: transfer from the zero address");
        // require(to != address(0), "ERC20: transfer to the zero address");
        require(amount >= 0, "ERC20: transfer to the zero address");

        if (state.blacklistflag > 0) {
            require(
                !isBlackListed(sender),
                "Token transfer refused. Receiver is on blacklist"
            );
            require(
                !isBlackListed(to),
                "Token transfer refused. Receiver is on blacklist"
            );
        }

        if (state.pauseflag > 0) {
            require(!paused(), "Token is Paused.");
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./SharedStructs.sol";
import "../../interfaces/IUniswapV2Router02.sol";
import "../../interfaces/IUniswapV2Factory.sol";

contract LiquidityToken is Context, IERC20 {
    using Address for address;

    address payable public marketingAddress; // Marketing Address
    address public immutable deadAddress =
        0x000000000000000000000000000000000000dEaD;
    address public owner;
    address private manager;
    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;

    mapping(address => bool) private _isExcluded;
    address[] private _excluded;

    uint256 private constant MAX = type(uint256).max;
    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    bool private _paused;
    SharedStructs.status public state;

    mapping(address => bool) _blacklist;

    uint256 public _taxFee;
    uint256 private _previousTaxFee;

    uint256 public _liquidityFee;
    uint256 private _previousLiquidityFee;

    uint256 public marketingDivisor;

    uint256 public _maxTxAmount = 5000000 * 10**6 * 10**9;
    uint256 private minimumTokensBeforeSwap = 300000 * 10**6 * 10**9;
    uint256 private buyBackUpperLimit = 1 * 10**18;

    IUniswapV2Router02 public immutable UniswapRouter;
    address public immutable UniswapPair;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled;
    bool public buyBackEnabled;

    uint256 public isstandard = 2;

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the creator");
        _;
    }

    modifier onlyManager() {
        require(manager == _msgSender(), "Manage:caller is not the manager");
        _;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */

    modifier canMint() {
        require(state.mintflag > 0, "Mintable: Disabled Mint");
        _;
    }

    modifier canPause() {
        require(state.mintflag > 0, "Pausable: Disabled Pause");
        _;
    }

    modifier canBurn() {
        require(state.burnflag > 0, "Burnable: Disabled Burn");
        _;
    }

    modifier canBlacklist() {
        require(state.blacklistflag > 0, "Blacklist: Disabled Blacklist");
        _;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    event BlacklistUpdated(address indexed user, bool value);
    event Paused(address account);
    event Unpaused(address account);
    event BurnSuccess(uint256);
    event MintSuccess(uint256);

    event RewardLiquidityProviders(uint256 tokenAmount);
    event BuyBackEnabledUpdated(bool enabled);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    event SwapETHForTokens(uint256 amountIn, address[] path);

    event SwapTokensForETH(uint256 amountIn, address[] path);

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor(
        address creator_,
        address unirouter,
        address reciever,
        uint8 decimal_,
        uint256 supply,
        string memory name_,
        string memory symbol_
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimal_;

        IUniswapV2Router02 _UniswapRouter = IUniswapV2Router02(unirouter);
        UniswapPair = IUniswapV2Factory(_UniswapRouter.factory()).createPair(
            address(this),
            _UniswapRouter.WETH()
        );

        UniswapRouter = _UniswapRouter;
        manager = _msgSender();

        set(creator_, reciever, supply);

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function set(
        address creator_,
        address reciever,
        uint256 supply
    ) private {
        marketingAddress = payable(reciever);
        owner = creator_;
        _tTotal = supply;
        _rTotal = (MAX - (MAX % supply));

        _rOwned[creator_] = _rTotal;

        buyBackEnabled = false;
        swapAndLiquifyEnabled = false;

        _isExcludedFromFee[creator_] = true;
        _isExcludedFromFee[address(this)] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function setStatus(SharedStructs.status memory _state)
        external
        onlyManager
    {
        state = _state;
    }

    function setFee(uint256 settingflag, uint256[4] memory fee)
        external
        onlyManager
    {
        if (settingflag != 0 && settingflag != 1) {
            swapAndLiquifyEnabled = true;
        }

        if (settingflag == 1 || settingflag == 2) {
            buyBackEnabled = true;
        }

        if (settingflag != 3) {
            _taxFee = fee[0];
            marketingDivisor = fee[1];
        }

        if (settingflag == 1 || settingflag == 2) {
            marketingDivisor = fee[2];
        }

        if (settingflag == 3 || settingflag == 4) {
            _liquidityFee = fee[3];
        }

        // if(settingflag != 0) {
        //    _holdersfee = fee[0];
        //     // _buybackFee = fee[1];
        // }

        _previousTaxFee = _taxFee;
        _previousLiquidityFee = _liquidityFee;
    }

    function mint(uint256 amount) public onlyOwner canMint {
        require(_tTotal + amount <= MAX, "exceeds limit");

        _beforeTokenTransfer(msg.sender, msg.sender, amount);

        _tTotal = _tTotal + amount;
        _tFeeTotal = _tFeeTotal + amount;

        // uint256 tAmount;

        // if (_isExcluded[account]) {
        //     _tOwned[account] = _tOwned[account].add(amount);
        // } else {
        //     tAmount = tokenFromReflection(_rOwned[account]);
        //     tAmount = tAmount.add(amount);
        //     _rOwned[account] = tokenFromReflection(tAmount);
        // }

        emit MintSuccess(amount);
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
    function burn(uint256 amount) public onlyOwner canBurn {
        require(amount <= MAX, "exceeds limit");

        _beforeTokenTransfer(msg.sender, address(0), amount);

        _tTotal = _tTotal - amount;
        _tFeeTotal = _tFeeTotal + amount;

        emit BurnSuccess(amount);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _beforeTokenTransfer(msg.sender, recipient, amount);
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address _owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[_owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _beforeTokenTransfer(msg.sender, spender, amount);
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _beforeTokenTransfer(sender, recipient, amount);
        _transfer(sender, recipient, amount);
        require(
            amount <= _allowances[sender][msg.sender],
            "ERC20: transfer amount exceeds allowance"
        );
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        require(
            subtractedValue <= _allowances[msg.sender][spender],
            "ERC20: decreased allowance below zero"
        );
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender] - subtractedValue
        );
        return true;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function minimumTokensBeforeSwapAmount() public view returns (uint256) {
        return minimumTokensBeforeSwap;
    }

    function buyBackUpperLimitAmount() public view returns (uint256) {
        return buyBackUpperLimit;
    }

    function deliver(uint256 tAmount) public {
        _beforeTokenTransfer(msg.sender, msg.sender, tAmount);
        address sender = msg.sender;
        require(
            !_isExcluded[sender],
            "Excluded addresses cannot call this function"
        );
        (uint256 rAmount, , , , , ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rTotal = _rTotal - rAmount;
        _tFeeTotal = _tFeeTotal + tAmount;
    }

    function reflectionFromToken(uint256 tAmount, bool deductTransferFee)
        public
        view
        returns (uint256)
    {
        require(tAmount <= _tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount, , , , , ) = _getValues(tAmount);
            return rAmount;
        } else {
            (, uint256 rTransferAmount, , , , ) = _getValues(tAmount);
            return rTransferAmount;
        }
    }

    function tokenFromReflection(uint256 rAmount)
        public
        view
        returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount / currentRate;
    }

    function excludeFromReward(address account) public onlyOwner {
        require(!_isExcluded[account], "Account is already excluded");
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner {
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    function _approve(
        address _owner,
        address spender,
        uint256 amount
    ) private {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (from != owner && to != owner) {
            require(
                amount <= _maxTxAmount,
                "Transfer amount exceeds the maxTxAmount."
            );
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinimumTokenBalance = contractTokenBalance >=
            minimumTokensBeforeSwap;

        if (!inSwapAndLiquify && swapAndLiquifyEnabled && to == UniswapPair) {
            if (overMinimumTokenBalance) {
                contractTokenBalance = minimumTokensBeforeSwap;
                swapTokens(contractTokenBalance);
            }
            uint256 balance = address(this).balance;
            if (buyBackEnabled && balance > uint256(1 * 10**18)) {
                if (balance > buyBackUpperLimit) balance = buyBackUpperLimit;

                buyBackTokens(balance / 100);
            }
        }

        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        _tokenTransfer(from, to, amount, takeFee);
    }

    function swapTokens(uint256 contractTokenBalance) private lockTheSwap {
        uint256 initialBalance = address(this).balance;
        swapTokensForETH(contractTokenBalance);
        uint256 transferredBalance = address(this).balance - initialBalance;

        //Send to Marketing address
        transferToAddressETH(
            marketingAddress,
            (transferredBalance / _liquidityFee) * marketingDivisor
        );
    }

    function buyBackTokens(uint256 amount) private lockTheSwap {
        if (amount > 0) {
            swapETHForTokens(amount);
        }
    }

    function swapTokensForETH(uint256 tokenAmount) private {
        // generate the Uniswap pair path of token -> wETH
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = UniswapRouter.WETH();

        _approve(address(this), address(UniswapRouter), tokenAmount);

        // make the swap
        UniswapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this), // The contract
            block.timestamp
        );

        emit SwapTokensForETH(tokenAmount, path);
    }

    function swapETHForTokens(uint256 amount) private {
        // generate the Uniswap pair path of token -> wETH
        address[] memory path = new address[](2);
        path[0] = UniswapRouter.WETH();
        path[1] = address(this);

        // make the swap
        UniswapRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: amount
        }(
            0, // accept any amount of Tokens
            path,
            deadAddress, // Burn address
            block.timestamp + 300
        );

        emit SwapETHForTokens(amount, path);
    }

    function addLiquidity(uint256 tokenAmount, uint256 ETHAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(UniswapRouter), tokenAmount);

        // add the liquidity
        UniswapRouter.addLiquidityETH{value: ETHAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner,
            block.timestamp
        );
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        if (!takeFee) removeAllFee();

        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            _transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            _transferToExcluded(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            _transferBothExcluded(sender, recipient, amount);
        } else {
            _transferStandard(sender, recipient, amount);
        }

        if (!takeFee) restoreAllFee();
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferToExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferFromExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        _takeLiquidity(tLiquidity);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal - rFee;
        _tFeeTotal = _tFeeTotal + tFee;
    }

    function _getValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        (
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tLiquidity
        ) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(
            tAmount,
            tFee,
            tLiquidity,
            _getRate()
        );
        return (
            rAmount,
            rTransferAmount,
            rFee,
            tTransferAmount,
            tFee,
            tLiquidity
        );
    }

    function _getTValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 tFee = calculateTaxFee(tAmount);
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tTransferAmount = tAmount - tFee - tLiquidity;
        return (tTransferAmount, tFee, tLiquidity);
    }

    function _getRValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 tLiquidity,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 rAmount = tAmount * currentRate;
        uint256 rFee = tFee * currentRate;
        uint256 rLiquidity = tLiquidity * currentRate;
        uint256 rTransferAmount = rAmount - rFee - rLiquidity;
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _rOwned[_excluded[i]] > rSupply ||
                _tOwned[_excluded[i]] > tSupply
            ) return (_rTotal, _tTotal);
            rSupply = rSupply - _rOwned[_excluded[i]];
            tSupply = tSupply - _tOwned[_excluded[i]];
        }
        if (rSupply < _rTotal / _tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function _takeLiquidity(uint256 tLiquidity) private {
        uint256 currentRate = _getRate();
        uint256 rLiquidity = tLiquidity * currentRate;
        _rOwned[address(this)] = _rOwned[address(this)] + rLiquidity;
        if (_isExcluded[address(this)])
            _tOwned[address(this)] = _tOwned[address(this)] + tLiquidity;
    }

    function calculateTaxFee(uint256 _amount) private view returns (uint256) {
        return (_amount * _taxFee) / (10**2);
    }

    function calculateLiquidityFee(uint256 _amount)
        private
        view
        returns (uint256)
    {
        return (_amount * _liquidityFee) / (10**2);
    }

    function removeAllFee() private {
        if (_taxFee == 0 && _liquidityFee == 0) return;

        _previousTaxFee = _taxFee;
        _previousLiquidityFee = _liquidityFee;

        _taxFee = 0;
        _liquidityFee = 0;
    }

    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _liquidityFee = _previousLiquidityFee;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function blacklistUpdate(address user, bool value)
        public
        virtual
        onlyOwner
        canBlacklist
    {
        // require(_owner == msg.sender, "Only owner is allowed to modify blacklist.");
        _blacklist[user] = value;
        emit BlacklistUpdated(user, value);
    }

    function isBlackListed(address user)
        public
        view
        virtual
        canBlacklist
        returns (bool)
    {
        return _blacklist[user];
    }

    function paused() public view virtual canPause returns (bool) {
        return _paused;
    }

    function _pause() public virtual onlyOwner canPause whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    function _unpause() public virtual onlyOwner canPause whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }

    function _beforeTokenTransfer(
        address sender,
        address to,
        uint256 amount
    ) internal virtual {
        // require(sender != address(0), "ERC20: transfer from the zero address");
        // require(to != address(0), "ERC20: transfer to the zero address");
        require(amount >= 0, "ERC20: transfer to the zero address");

        if (state.blacklistflag > 0) {
            require(
                !isBlackListed(sender),
                "Token transfer refused. Receiver is on blacklist"
            );
            require(
                !isBlackListed(to),
                "Token transfer refused. Receiver is on blacklist"
            );
        }

        if (state.pauseflag > 0) {
            require(!paused(), "Token is Paused.");
        }
    }

    function transferToAddressETH(address payable recipient, uint256 amount)
        private
    {
        recipient.transfer(amount);
    }

    //to recieve ETH from UniswapRouter when swaping
    receive() external payable {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./StandardToken.sol";

contract StandardTokenFactory {
    function deploy(
        address creator_,
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 tokenSupply_,
        SharedStructs.status memory _state
    ) external returns (StandardToken) {
        return
            new StandardToken(
                creator_,
                name_,
                symbol_,
                decimals_,
                tokenSupply_,
                _state
            );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./StandardToken.sol";
import "./LiquidityToken.sol";

contract LiquidityTokenFactory {
    function deploy(
        address router_address,
        address creator_,
        address reciever,
        string memory name_,
        string memory symbol_,
        uint8 decimal_,
        uint256 supply
    ) external returns (LiquidityToken) {
        return
            new LiquidityToken(
                creator_,
                router_address,
                reciever,
                decimal_,
                supply,
                name_,
                symbol_
            );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./IUniswapV2Router01.sol";

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: UNLICENSED
// @Credits Unicrypt Network 2021

/**
    This contract creates the lock on behalf of each presale. This contract will be whitelisted to bypass the flat rate 
    ETH fee. Please do not use the below locking code in your own contracts as the lock will fail without the ETH fee
*/

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./PresaleManage.sol";
import "../../interfaces/IWETH.sol";
import "../../interfaces/IUniswapV2Factory.sol";
import "../../interfaces/IUniswapV2Router02.sol";
import "../../interfaces/IUniswapV2Pair.sol";
import "../../LiquidityLock/LPLock.sol";
import "../TransferHelper.sol";

contract PresaleLockForwarder {
    LPLocker public lplocker;
    IUniswapV2Factory public uniswapfactory;
    IUniswapV2Router02 public uniswaprouter;

    PresaleManage manage;
    IWETH public WETH;

    mapping(address => address) public locked_lp_tokens;
    mapping(address => address) public locked_lp_owner;

    constructor(
        address _manage,
        address lplock_addrress,
        address unifactaddr,
        address unirouter,
        address wethaddr
    ) public {
        lplocker = LPLocker(lplock_addrress);
        uniswapfactory = IUniswapV2Factory(unifactaddr);
        uniswaprouter = IUniswapV2Router02(unirouter);
        WETH = IWETH(wethaddr);
        manage = PresaleManage(_manage);
    }

    /**
        Send in _token0 as the PRESALE token, _token1 as the BASE token (usually WETH) for the check to work. As anyone can create a pair,
        and send WETH to it while a presale is running, but no one should have access to the presale token. If they do and they send it to 
        the pair, scewing the initial liquidity, this function will return true
    */
    function uniswapPairIsInitialised(address _token0, address _token1)
        public
        view
        returns (bool)
    {
        address pairAddress = uniswapfactory.getPair(_token0, _token1);
        if (pairAddress == address(0)) {
            return false;
        }
        uint256 balance = IERC20(_token0).balanceOf(pairAddress);
        if (balance > 0) {
            return true;
        }
        return false;
    }

    // function lockLiquidity (IERC20 _saleToken, uint256 _unlock_date, address payable _withdrawer) payable external {

    //     require(msg.value >= lplocker.price(), 'Balance is insufficient');

    //     address pair = uniswapfactory.getPair(address(WETH), address(_saleToken));

    //     uint256 totalLPTokensMinted = IUniswapV2Pair(pair).balanceOf(address(this));
    //     require(totalLPTokensMinted != 0 , "LP creation failed");

    //     TransferHelper.safeApprove(pair, address(lplocker), totalLPTokensMinted);
    //     uint256 unlock_date = _unlock_date > 9999999999 ? 9999999999 : _unlock_date;

    //     lplocker.lpLock{value:lplocker.price()}(pair, totalLPTokensMinted, unlock_date, _withdrawer );

    //     lptokens[msg.sender] = pair;
    // }

    function lockLiquidity(
        address _saleToken,
        uint256 _baseAmount,
        uint256 _saleAmount,
        uint256 _unlock_date,
        address payable _withdrawer
    ) external payable {
        require(manage.IsRegistered(msg.sender), "PRESALE NOT REGISTERED");
        require(
            msg.value >= lplocker.price() + _baseAmount,
            "Balance is insufficient"
        );

        // if (pair == address(0)) {
        //     uniswapfactory.createPair(address(WETH), address(_saleToken));
        //     pair = uniswapfactory.getPair(address(WETH), address(_saleToken));
        // }

        // require(WETH.transferFrom(msg.sender, address(this), _baseAmount), 'WETH transfer failed.');
        // TransferHelper.safeTransferFrom(address(_baseToken), msg.sender, address(pair), _baseAmount);
        TransferHelper.safeTransferFrom(
            address(_saleToken),
            msg.sender,
            address(this),
            _saleAmount
        );
        // IUniswapV2Pair(pair).mint(address(this));
        // return;
        // require(WETH.approve(address(uniswaprouter), _baseAmount), 'router approve failed.');
        // _saleToken.approve(address(uniswaprouter), _saleAmount);
        TransferHelper.safeApprove(
            address(_saleToken),
            address(uniswaprouter),
            _saleAmount
        );
        // construct token path
        // address[] memory path = new address[](2);
        // path[0] = address(WETH);
        // path[1] = address(_saleToken);

        // IUniswapV2Router02(uniswaprouter).swapExactTokensForTokens(
        //     WETH.balanceOf(address(this)).div(2),
        //     0,
        //     path,
        //     address(this),
        //     block.timestamp + 5 minutes
        // );

        // // calculate balances and add liquidity
        // uint256 wethBalance = WETH.balanceOf(address(this));
        // uint256 balance = _saleToken.balanceOf(address(this));

        // IUniswapV2Router02(uniswaprouter).addLiquidity(
        //     address(_saleToken),
        //     address(WETH),
        //     balance,
        //     wethBalance,
        //     0,
        //     0,
        //     address(this),
        //     block.timestamp + 5 minutes
        // );

        IUniswapV2Router02(address(uniswaprouter)).addLiquidityETH{
            value: _baseAmount
        }(
            address(_saleToken),
            _saleAmount,
            0,
            0,
            payable(address(this)),
            block.timestamp + 5 minutes
        );

        address pair = uniswapfactory.getPair(
            address(WETH),
            address(_saleToken)
        );

        uint256 totalLPTokensMinted = IUniswapV2Pair(pair).balanceOf(
            address(this)
        );
        require(totalLPTokensMinted != 0, "LP creation failed");

        TransferHelper.safeApprove(
            pair,
            address(lplocker),
            totalLPTokensMinted
        );
        uint256 unlock_date = _unlock_date > 9999999999
            ? 9999999999
            : _unlock_date;

        lplocker.lpLock{value: lplocker.price()}(
            pair,
            totalLPTokensMinted,
            unlock_date,
            _withdrawer
        );

        locked_lp_tokens[address(_saleToken)] = pair;
        locked_lp_owner[address(_saleToken)] = _withdrawer;

        payable(_withdrawer).transfer(address(this).balance);
    }
}

// SPDX-License-Identifier: UNLICENSED
// @Credits Unicrypt Network 2021

// This contract generates Presale01 contracts and registers them in the PresaleFactory.
// Ideally you should not interact with this contract directly, and use the Octofi presale app instead so warnings can be shown where necessary.

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "../TransferHelper.sol";
import "../PresaleSettings.sol";
import "./SharedStructs.sol";
import "./PresaleLockForwarder.sol";
import "./PresaleFactory.sol";
import "./Presale.sol";

contract PresaleManage {
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private presales;

    PresaleFactory internal presaleFactory;

    address public presale_lock_forward_addr;
    address public presale_setting_addr;
    PresaleLockForwarder _lock;

    address private uniswap_factory_address;
    address private uniswap_pair_address;

    address private weth_address;

    address payable owner;

    SharedStructs.PresaleInfo presale_info;
    SharedStructs.PresaleLink presalelink;

    PresaleSettings public settings;

    event OwnerWithdrawSuccess(uint256 value);
    event CreatePreslaeSuccess(address, address);

    constructor(
        address payable _owner,
        address lock_addr,
        address uniswapfactory_addr,
        address uniswaprouter_Addr,
        address weth_addr,
        PresaleFactory _presaleFactory
    ) {
        owner = _owner;

        uniswap_factory_address = uniswapfactory_addr;
        weth_address = weth_addr;

        _lock = new PresaleLockForwarder(
            address(this),
            lock_addr,
            uniswapfactory_addr,
            uniswaprouter_Addr,
            weth_addr
        );
        presale_lock_forward_addr = address(_lock);

        PresaleSettings _setting;

        _setting = new PresaleSettings(address(this), _owner, lock_addr);

        _setting.init(owner, 0.01 ether, owner, 10, owner, 10, owner, 10);

        presale_setting_addr = address(_setting);

        settings = PresaleSettings(presale_setting_addr);

        presaleFactory = _presaleFactory;
    }

    function ownerWithdraw() public {
        require(
            msg.sender == settings.getCreateFeeAddress(),
            "Only creater can withdraw"
        );
        address payable reciver = payable(settings.getCreateFeeAddress());
        reciver.transfer(address(this).balance);
        // owner.transfer(address(this).balance);
        emit OwnerWithdrawSuccess(address(this).balance);
    }

    /**
     * @notice Creates a new Presale contract and registers it in the PresaleFactory.sol.
     */

    function calculateAmountRequired(
        uint256 _amount,
        uint256 _tokenPrice,
        uint256 _listingRate,
        uint256 _liquidityPercent,
        uint256 _tokenFee
    ) public pure returns (uint256) {
        uint256 tokenamount = (_amount * _tokenPrice) / (10**18);
        uint256 TokenFee = (((_amount * _tokenFee) / 100) / 10**18) *
            _tokenPrice;
        uint256 liqudityrateamount = (_amount * _listingRate) / (10**18);
        uint256 liquiditytoken = (liqudityrateamount * _liquidityPercent) / 100;
        uint256 tokensRequiredForPresale = tokenamount +
            liquiditytoken +
            TokenFee;
        return tokensRequiredForPresale;
    }

    function createPresale(
        SharedStructs.PresaleInfo memory _presale_info,
        SharedStructs.PresaleLink memory _presalelink
    ) public payable {
        presale_info = _presale_info;

        presalelink = _presalelink;

        // if ( (presale_info.presale_end - presale_info.presale_start) < 1 weeks) {
        //     presale_info.presale_end = presale_info.presale_start + 1 weeks;
        // }

        // if ( (presale_info.lock_end - presale_info.lock_start) < 4 weeks) {
        //     presale_info.lock_end = presale_info.lock_start + 4 weeks;
        // }

        // Charge ETH fee for contract creation
        require(
            msg.value >= settings.getPresaleCreateFee() + settings.getLockFee(),
            "Balance is insufficent"
        );

        require(_presale_info.token_rate > 0, "token rate is invalid");
        require(
            _presale_info.raise_min < _presale_info.raise_max,
            "raise min/max in invalid"
        );
        require(
            _presale_info.softcap <= _presale_info.hardcap,
            "softcap/hardcap is invalid"
        );
        require(
            _presale_info.liqudity_percent >= 30 &&
                _presale_info.liqudity_percent <= 100,
            "Liqudity percent is invalid"
        );
        require(_presale_info.listing_rate > 0, "Listing rate is invalid");

        require(
            (_presale_info.presale_end - _presale_info.presale_start) > 0,
            "Presale start/end time is invalid"
        );
        require(
            (_presale_info.lock_end - _presale_info.lock_start) >= 4 weeks,
            "Lock end is invalid"
        );

        // Calculate required token amount
        uint256 tokensRequiredForPresale = calculateAmountRequired(
            _presale_info.hardcap,
            _presale_info.token_rate,
            _presale_info.listing_rate,
            _presale_info.liqudity_percent,
            settings.getSoldFee()
        );

        // Create New presale
        PresaleV1 newPresale = presaleFactory.deploy{
            value: settings.getLockFee()
        }(
            address(this),
            weth_address,
            presale_setting_addr,
            presale_lock_forward_addr
        );

        // newPresale.delegatecall(bytes4(sha3("destroy()")));

        if (address(newPresale) == address(0)) {
            // newPresale.destroy();
            require(false, "Create presale Failed");
        }

        TransferHelper.safeTransferFrom(
            address(_presale_info.sale_token),
            address(msg.sender),
            address(newPresale),
            tokensRequiredForPresale
        );

        newPresale.init_private(_presale_info);

        newPresale.init_link(_presalelink);

        newPresale.init_fee();

        presales.add(address(newPresale));

        emit CreatePreslaeSuccess(address(newPresale), address(msg.sender));
    }

    function getCount() external view returns (uint256) {
        return presales.length();
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getPresaleAt(uint256 index) external view returns (address) {
        return presales.at(index);
    }

    function IsRegistered(address presale_addr) external view returns (bool) {
        return presales.contains(presale_addr);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function balanceOf(address owner) external view returns (uint256);

    function decimals() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract LPLocker {
    address public owner;
    uint256 public price;
    uint256 public penaltyfee;

    struct holder {
        address holderAddress;
        mapping(address => Token) tokens;
    }

    struct Token {
        uint256 balance;
        address tokenAddress;
        uint256 unlockTime;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only available to the contract owner.");
        _;
    }

    mapping(address => holder) public holders;

    constructor(address _owner, uint256 _price) {
        owner = _owner;
        price = _price;
        penaltyfee = 10; // default value
    }

    event Hold(
        address indexed holder,
        address token,
        uint256 amount,
        uint256 unlockTime
    );

    event PanicWithdraw(
        address indexed holder,
        address token,
        uint256 amount,
        uint256 unlockTime
    );

    event Withdrawal(address indexed holder, address token, uint256 amount);

    event FeesClaimed();

    event SetOwnerSuccess(address owner);

    event SetPriceSuccess(uint256 _price);

    event SetPenaltyFeeSuccess(uint256 _fee);

    event OwnerWithdrawSuccess(uint256 amount);

    function lpLock(
        address token,
        uint256 amount,
        uint256 unlockTime,
        address withdrawer
    ) public payable {
        require(msg.value >= price, "Required price is low");

        holder storage holder0 = holders[withdrawer];
        holder0.holderAddress = withdrawer;

        Token storage lockedToken = holders[withdrawer].tokens[token];

        if (lockedToken.balance > 0) {
            lockedToken.balance += amount;

            if (lockedToken.unlockTime < unlockTime) {
                lockedToken.unlockTime = unlockTime;
            }
        } else {
            holders[withdrawer].tokens[token] = Token(
                amount,
                token,
                unlockTime
            );
        }

        IERC20(token).transferFrom(withdrawer, address(this), amount);

        emit Hold(withdrawer, token, amount, unlockTime);
    }

    function withdraw(address token) public {
        holder storage holder0 = holders[msg.sender];

        require(
            msg.sender == holder0.holderAddress,
            "Only available to the token owner."
        );

        require(
            block.timestamp > holder0.tokens[token].unlockTime,
            "Unlock time not reached yet."
        );

        uint256 amount = holder0.tokens[token].balance;

        holder0.tokens[token].balance = 0;

        IERC20(token).transfer(msg.sender, amount);

        emit Withdrawal(msg.sender, token, amount);
    }

    function panicWithdraw(address token) public {
        holder storage holder0 = holders[msg.sender];

        require(
            msg.sender == holder0.holderAddress,
            "Only available to the token owner."
        );

        uint256 feeAmount = (holder0.tokens[token].balance / 100) * penaltyfee;
        uint256 withdrawalAmount = holder0.tokens[token].balance - feeAmount;

        holder0.tokens[token].balance = 0;

        //Transfers fees to the contract administrator/owner
        // holders[address(owner)].tokens[token].balance = feeAmount;

        // Transfers fees to the token owner
        IERC20(token).transfer(msg.sender, withdrawalAmount);

        // Transfers fees to the contract administrator/owner
        IERC20(token).transfer(owner, feeAmount);

        emit PanicWithdraw(
            msg.sender,
            token,
            withdrawalAmount,
            holder0.tokens[token].unlockTime
        );
    }

    // function claimTokenListFees(address[] memory tokenList) public onlyOwner {

    //     for (uint256 i = 0; i < tokenList.length; i++) {

    //         uint256 amount = holders[owner].tokens[tokenList[i]].balance;

    //         if (amount > 0) {

    //             holders[owner].tokens[tokenList[i]].balance = 0;

    //             IERC20(tokenList[i]).transfer(owner, amount);
    //         }
    //     }
    //     emit FeesClaimed();
    // }

    // function claimTokenFees(address token) public onlyOwner {

    //     uint256 amount = holders[owner].tokens[token].balance;

    //     require(amount > 0, "No fees available for claiming.");

    //     holders[owner].tokens[token].balance = 0;

    //     IERC20(token).transfer(owner, amount);

    //     emit FeesClaimed();
    // }

    function OwnerWithdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        address payable ownerAddress = payable(owner);

        ownerAddress.transfer(amount);

        emit OwnerWithdrawSuccess(amount);
    }

    function getcurtime() public view returns (uint256) {
        return block.timestamp;
    }

    function GetBalance(address token) public view returns (uint256) {
        Token storage lockedToken = holders[msg.sender].tokens[token];
        return lockedToken.balance;
    }

    function SetOwner(address contractowner) public onlyOwner {
        owner = contractowner;
        emit SetOwnerSuccess(owner);
    }

    function SetPrice(uint256 _price) public onlyOwner {
        price = _price;
        emit SetPriceSuccess(price);
    }

    // function GetPrice() public view returns (uint256) {
    //     return price;
    // }

    function SetPenaltyFee(uint256 _penaltyfee) public onlyOwner {
        penaltyfee = _penaltyfee;
        emit SetPenaltyFeeSuccess(penaltyfee);
    }

    // function GetPenaltyFee() public view returns (uint256) {
    //     return penaltyfee;
    // }

    function GetUnlockTime(address token) public view returns (uint256) {
        Token storage lockedToken = holders[msg.sender].tokens[token];
        return lockedToken.unlockTime;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
    helper methods for interacting with ERC20 tokens that do not consistently return true/false
    with the addition of a transfer function to send eth or an erc20 token
*/
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x095ea7b3, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: APPROVE_FAILED"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FAILED"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FROM_FAILED"
        );
    }

    // sends ETH or an erc20 token
    function safeTransferBaseToken(
        address token,
        address payable to,
        uint256 value,
        bool isERC20
    ) internal {
        if (!isERC20) {
            to.transfer(value);
        } else {
            (bool success, bytes memory data) = token.call(
                abi.encodeWithSelector(0xa9059cbb, to, value)
            );
            require(
                success && (data.length == 0 || abi.decode(data, (bool))),
                "TransferHelper: TRANSFER_FAILED"
            );
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: UNLICENSED
// @Credits Unicrypt Network 2021

// Settings to initialize presale contracts and edit fees.

pragma solidity ^0.8.0;

interface ILpLocker {
    function price() external pure returns (uint256);
}

contract PresaleSettings {
    address private owner;
    address private manage;
    ILpLocker locker;

    struct SettingsInfo {
        uint256 raised_fee; // divided by 100
        uint256 sold_fee; // divided by 100
        uint256 referral_fee; // divided by 100
        uint256 presale_create_fee; // divided by 100
        address payable raise_fee_address;
        address payable sole_fee_address;
        address payable referral_fee_address; // if this is not address(0), there is a valid referral
        address payable create_fee_address; // if this is not address(0), there is a valid referral
    }

    SettingsInfo public info;

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    modifier onlyManager() {
        require(manage == msg.sender, "Ownable: caller is not the manager");
        _;
    }

    event setRaiseFeeAddrSuccess(address indexed addr);
    event setRaisedFeeSuccess(uint256 num);
    event setSoleFeeAddrSuccess(address indexed addr);
    event setSoldFeeSuccess(uint256 num);
    event setReferralFeeAddrSuccess(address addr);
    event setReferralFeeSuccess(uint256 num);
    event setCreateFeeAddrSuccess(address addr);
    event setCreateFeeSuccess(uint256 num);
    event setFeeInfoSuccess(uint256);

    constructor(
        address _manage,
        address _owner,
        address lockaddr
    ) public {
        owner = _owner;
        manage = _manage;
        locker = ILpLocker(lockaddr);
    }

    function init(
        address payable _presale_create_fee_addr,
        uint256 _presale_create_fee,
        address payable _raise_fee_addr,
        uint256 _raised_fee,
        address payable _sole_fee_address,
        uint256 _sold_fee,
        address payable _referral_fee_address,
        uint256 _referral_fee
    ) public onlyManager {
        info.presale_create_fee = _presale_create_fee;
        info.raise_fee_address = _raise_fee_addr;
        info.raised_fee = _raised_fee;
        info.sole_fee_address = _sole_fee_address;
        info.sold_fee = _sold_fee;
        info.referral_fee_address = _referral_fee_address;
        info.referral_fee = _referral_fee;
        info.create_fee_address = _presale_create_fee_addr;
    }

    function getRaisedFeeAddress()
        external
        view
        returns (address payable _raise_fee_addr)
    {
        return info.raise_fee_address;
    }

    function setRaisedFeeAddress(address payable _raised_fee_addr)
        external
        onlyOwner
    {
        info.raise_fee_address = _raised_fee_addr;
        emit setRaiseFeeAddrSuccess(info.raise_fee_address);
    }

    function getRasiedFee() external view returns (uint256) {
        return info.raised_fee;
    }

    function setRaisedFee(uint256 _raised_fee) external onlyOwner {
        info.raised_fee = _raised_fee;
        emit setRaisedFeeSuccess(info.raised_fee);
    }

    function getSoleFeeAddress()
        external
        view
        returns (address payable _sole_fee_address)
    {
        return info.sole_fee_address;
    }

    function setSoleFeeAddress(address payable _sole_fee_address)
        external
        onlyOwner
    {
        info.sole_fee_address = _sole_fee_address;
        emit setSoleFeeAddrSuccess(info.sole_fee_address);
    }

    function getSoldFee() external view returns (uint256) {
        return info.sold_fee;
    }

    function setSoldFee(uint256 _sold_fee) external onlyOwner {
        info.sold_fee = _sold_fee;
        emit setSoldFeeSuccess(info.sold_fee);
    }

    function getReferralFeeAddress() external view returns (address payable) {
        return info.referral_fee_address;
    }

    function setReferralFeeAddress(address payable _referral_fee_address)
        external
        onlyOwner
    {
        info.sole_fee_address = _referral_fee_address;
        emit setReferralFeeAddrSuccess(info.referral_fee_address);
    }

    function getRefferralFee() external view returns (uint256) {
        return info.referral_fee;
    }

    function setRefferralFee(uint256 _referral_fee) external onlyOwner {
        info.referral_fee = _referral_fee;
        emit setReferralFeeSuccess(info.referral_fee);
    }

    function getLockFee() external view returns (uint256) {
        return locker.price();
    }

    function getPresaleCreateFee() external view returns (uint256) {
        return info.presale_create_fee;
    }

    function setSetPresaleCreateFee(uint256 _presale_create_fee)
        external
        onlyOwner
    {
        info.presale_create_fee = _presale_create_fee;
        emit setCreateFeeSuccess(info.presale_create_fee);
    }

    function getCreateFeeAddress() external view returns (address payable) {
        return info.create_fee_address;
    }

    function setCreateFeeAddress(address payable _create_fee_address)
        external
        onlyOwner
    {
        info.create_fee_address = _create_fee_address;
        emit setReferralFeeAddrSuccess(info.create_fee_address);
    }

    function setFeeInfo(
        address payable _create_address,
        address payable _raise_address,
        address payable _sold_address,
        uint256 _create_fee,
        uint256 _raise_fee,
        uint256 _sold_fee
    ) external onlyOwner {
        info.create_fee_address = _create_address;
        info.raise_fee_address = _raise_address;
        info.sole_fee_address = _sold_address;

        info.presale_create_fee = _create_fee;
        info.raised_fee = _raise_fee;
        info.sold_fee = _sold_fee;

        emit setFeeInfoSuccess(1);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SharedStructs {
    struct PresaleInfo {
        address payable presale_owner;
        address sale_token; // sale token
        uint256 token_rate; // 1 base token = ? s_tokens, fixed price
        uint256 raise_min; // maximum base token BUY amount per buyer
        uint256 raise_max; // the amount of presale tokens up for presale
        uint256 hardcap; // Maximum riase amount
        uint256 softcap; //Minimum raise amount
        uint256 liqudity_percent; // divided by 1000
        uint256 listing_rate; // fixed rate at which the token will list on uniswap
        uint256 lock_end; // uniswap lock timestamp -> e.g. 2 weeks
        uint256 lock_start;
        uint256 presale_end; // presale period
        uint256 presale_start; // presale start
    }

    struct PresaleLink {
        string website_link;
        string github_link;
        string twitter_link;
        string reddit_link;
        string telegram_link;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Presale.sol";

contract PresaleFactory {
    function deploy(
        address manage,
        address wethfact,
        address setting,
        address lockaddr
    ) external payable returns (PresaleV1) {
        return
            (new PresaleV1){value: msg.value}(
                manage,
                wethfact,
                setting,
                lockaddr
            );
    }
}

// SPDX-License-Identifier: UNLICENSED
// @Credits Defi Site Network 2021

// Presale contract. Version 1

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../../interfaces/IWETH.sol";
import "../TransferHelper.sol";
import "./SharedStructs.sol";
import "./PresaleLockForwarder.sol";
import "../PresaleSettings.sol";

contract PresaleV1 is ReentrancyGuard {
    /// @notice Presale Contract Version, used to choose the correct ABI to decode the contract
    //   uint256 public contract_version = 1;

    struct PresaleFeeInfo {
        uint256 raised_fee; // divided by 100
        uint256 sold_fee; // divided by 100
        uint256 referral_fee; // divided by 100
        address payable raise_fee_address;
        address payable sole_fee_address;
        address payable referral_fee_address; // if this is not address(0), there is a valid referral
    }

    struct PresaleStatus {
        bool lp_generation_complete; // final flag required to end a presale and enable withdrawls
        bool force_failed; // set this flag to force fail the presale
        uint256 raised_amount; // total base currency raised (usually ETH)
        uint256 sold_amount; // total presale tokens sold
        uint256 token_withdraw; // total tokens withdrawn post successful presale
        uint256 base_withdraw; // total base tokens withdrawn on presale failure
        uint256 num_buyers; // number of unique participants
    }

    struct BuyerInfo {
        uint256 base; // total base token (usually ETH) deposited by user, can be withdrawn on presale failure
        uint256 sale; // num presale tokens a user is owed, can be withdrawn on presale success
    }

    struct TokenInfo {
        string name;
        string symbol;
        uint256 totalsupply;
        uint256 decimal;
    }

    SharedStructs.PresaleInfo public presale_info;
    PresaleStatus public status;
    SharedStructs.PresaleLink public link;
    PresaleFeeInfo public presale_fee_info;
    TokenInfo public tokeninfo;

    address manage_addr;

    // IUniswapV2Factory public uniswapfactory;
    IWETH private WETH;
    PresaleSettings public presale_setting;
    PresaleLockForwarder public presale_lock_forwarder;

    mapping(address => BuyerInfo) public buyers;

    event UserDepsitedSuccess(address, uint256);
    event UserWithdrawSuccess(uint256);
    event UserWithdrawTokensSuccess(uint256);
    event AddLiquidtySuccess(uint256);

    constructor(
        address manage,
        address wethfact,
        address setting,
        address lockaddr
    ) payable {
        presale_setting = PresaleSettings(setting);

        require(
            msg.value >= presale_setting.getLockFee(),
            "Balance is insufficent"
        );

        manage_addr = manage;

        // uniswapfactory = IUniswapV2Factory(uniswapfact);
        WETH = IWETH(wethfact);

        presale_lock_forwarder = PresaleLockForwarder(lockaddr);
    }

    function init_private(SharedStructs.PresaleInfo memory _presale_info)
        external
    {
        require(msg.sender == manage_addr, "Only manage address is available");

        presale_info = _presale_info;

        //Set token token info
        tokeninfo.name = IERC20Metadata(_presale_info.sale_token).name();
        tokeninfo.symbol = IERC20Metadata(_presale_info.sale_token).symbol();
        tokeninfo.decimal = IERC20Metadata(_presale_info.sale_token).decimals();
        tokeninfo.totalsupply = IERC20Metadata(_presale_info.sale_token)
            .totalSupply();
    }

    function init_link(SharedStructs.PresaleLink memory _link) external {
        require(msg.sender == manage_addr, "Only manage address is available");

        link = _link;
    }

    function init_fee() external {
        require(msg.sender == manage_addr, "Only manage address is available");

        presale_fee_info.raised_fee = presale_setting.getRasiedFee(); // divided by 100
        presale_fee_info.sold_fee = presale_setting.getSoldFee(); // divided by 100
        presale_fee_info.referral_fee = presale_setting.getRefferralFee(); // divided by 100
        presale_fee_info.raise_fee_address = presale_setting
            .getRaisedFeeAddress();
        presale_fee_info.sole_fee_address = presale_setting.getSoleFeeAddress();
        presale_fee_info.referral_fee_address = presale_setting
            .getReferralFeeAddress(); // if this is not address(0), there is a valid referral
    }

    modifier onlyPresaleOwner() {
        require(presale_info.presale_owner == msg.sender, "NOT PRESALE OWNER");
        _;
    }

    //   uint256 tempstatus;

    //   function setTempStatus(uint256 flag) public {
    //       tempstatus = flag;
    //   }

    function presaleStatus() public view returns (uint256) {
        // return tempstatus;
        if (status.force_failed) {
            return 3; // FAILED - force fail
        }
        if (
            (block.timestamp > presale_info.presale_end) &&
            (status.raised_amount < presale_info.softcap)
        ) {
            return 3;
        }
        if (status.raised_amount >= presale_info.hardcap) {
            return 2; // SUCCESS - hardcap met
        }
        if (
            (block.timestamp > presale_info.presale_end) &&
            (status.raised_amount >= presale_info.softcap)
        ) {
            return 2; // SUCCESS - preslae end and soft cap reached
        }
        if (
            (block.timestamp >= presale_info.presale_start) &&
            (block.timestamp <= presale_info.presale_end)
        ) {
            return 1; // ACTIVE - deposits enabled
        }
        return 0; // QUED - awaiting start block
    }

    // accepts msg.value for eth or _amount for ERC20 tokens
    function userDeposit() public payable nonReentrant {
        require(presaleStatus() == 1, "NOT ACTIVE"); //
        require(presale_info.raise_min <= msg.value, "balance is insufficent");
        require(presale_info.raise_max >= msg.value, "balance is too much");

        BuyerInfo storage buyer = buyers[msg.sender];

        uint256 amount_in = msg.value;
        uint256 allowance = presale_info.raise_max - buyer.base;
        uint256 remaining = presale_info.hardcap - status.raised_amount;
        allowance = allowance > remaining ? remaining : allowance;
        if (amount_in > allowance) {
            amount_in = allowance;
        }
        uint256 tokensSold = (amount_in * presale_info.token_rate) / (10**18);
        require(tokensSold > 0, "ZERO TOKENS");
        require(
            tokensSold <=
                IERC20(presale_info.sale_token).balanceOf(address(this)),
            "Token reamin error"
        );
        if (buyer.base == 0) {
            status.num_buyers++;
        }
        buyers[msg.sender].base = buyers[msg.sender].base + amount_in;
        buyers[msg.sender].sale = buyers[msg.sender].sale + tokensSold;
        status.raised_amount = status.raised_amount + amount_in;
        status.sold_amount = status.sold_amount + tokensSold;

        // return unused ETH
        if (amount_in < msg.value) {
            payable(msg.sender).transfer(msg.value - amount_in);
        }

        emit UserDepsitedSuccess(msg.sender, msg.value);
    }

    // withdraw presale tokens
    // percentile withdrawls allows fee on transfer or rebasing tokens to still work
    function userWithdrawTokens() public nonReentrant {
        require(status.lp_generation_complete, "AWAITING LP GENERATION");
        BuyerInfo storage buyer = buyers[msg.sender];
        uint256 tokensRemainingDenominator = status.sold_amount -
            status.token_withdraw;
        uint256 tokensOwed = (IERC20(presale_info.sale_token).balanceOf(
            address(this)
        ) * buyer.sale) / tokensRemainingDenominator;
        require(tokensOwed > 0, "NOTHING TO WITHDRAW");
        status.token_withdraw = status.token_withdraw + buyer.sale;
        buyers[msg.sender].sale = 0;
        buyers[msg.sender].base = 0;
        TransferHelper.safeTransfer(
            address(presale_info.sale_token),
            msg.sender,
            tokensOwed
        );

        emit UserWithdrawTokensSuccess(tokensOwed);
    }

    // on presale failure
    // percentile withdrawls allows fee on transfer or rebasing tokens to still work
    function userWithdrawBaseTokens() public nonReentrant {
        require(presaleStatus() == 3, "NOT FAILED"); // FAILED

        if (msg.sender == presale_info.presale_owner) {
            ownerWithdrawTokens();
            // return;
        }

        BuyerInfo storage buyer = buyers[msg.sender];
        uint256 baseRemainingDenominator = status.raised_amount -
            status.base_withdraw;
        uint256 remainingBaseBalance = address(this).balance;
        uint256 tokensOwed = (remainingBaseBalance * buyer.base) /
            baseRemainingDenominator;
        require(tokensOwed > 0, "NOTHING TO WITHDRAW");
        status.base_withdraw = status.base_withdraw + buyer.base;
        buyer.base = 0;
        buyer.sale = 0;

        address payable reciver = payable(msg.sender);
        reciver.transfer(tokensOwed);

        emit UserWithdrawSuccess(tokensOwed);
        // TransferHelper.safeTransferBaseToken(address(presale_info.base_token), msg.sender, tokensOwed, false);
    }

    // on presale failure
    // allows the owner to withdraw the tokens they sent for presale & initial liquidity
    function ownerWithdrawTokens() private onlyPresaleOwner {
        require(presaleStatus() == 3, "Only failed status"); // FAILED
        TransferHelper.safeTransfer(
            address(presale_info.sale_token),
            presale_info.presale_owner,
            IERC20(presale_info.sale_token).balanceOf(address(this))
        );

        emit UserWithdrawSuccess(
            IERC20(presale_info.sale_token).balanceOf(address(this))
        );
    }

    // Can be called at any stage before or during the presale to cancel it before it ends.
    // If the pair already exists on uniswap and it contains the presale token as liquidity
    // the final stage of the presale 'addLiquidity()' will fail. This function
    // allows anyone to end the presale prematurely to release funds in such a case.
    function forceFailIfPairExists() public {
        require(!status.lp_generation_complete && !status.force_failed);
        if (
            presale_lock_forwarder.uniswapPairIsInitialised(
                address(presale_info.sale_token),
                address(WETH)
            )
        ) {
            status.force_failed = true;
        }
    }

    // if something goes wrong in LP generation
    // function forceFail () external {
    //     require(msg.sender == OCTOFI_FEE_ADDRESS);
    //     status.force_failed = true;
    // }

    // on presale success, this is the final step to end the presale, lock liquidity and enable withdrawls of the sale token.
    // This function does not use percentile distribution. Rebasing mechanisms, fee on transfers, or any deflationary logic
    // are not taken into account at this stage to ensure stated liquidity is locked and the pool is initialised according to
    // the presale parameters and fixed prices.
    function addLiquidity() public nonReentrant onlyPresaleOwner {
        require(!status.lp_generation_complete, "GENERATION COMPLETE");
        require(presaleStatus() == 2, "NOT SUCCESS"); // SUCCESS
        // Fail the presale if the pair exists and contains presale token liquidity

        if (
            presale_lock_forwarder.uniswapPairIsInitialised(
                address(presale_info.sale_token),
                address(WETH)
            )
        ) {
            status.force_failed = true;
            emit AddLiquidtySuccess(0);
            return;
        }

        // require(!presale_lock_forwarder.uniswapPairIsInitialised(address(presale_info.sale_token), address(WETH)), "Liqudity exist");

        uint256 presale_raisedfee = (status.raised_amount *
            presale_setting.getRasiedFee()) / 100;

        // base token liquidity
        uint256 baseLiquidity = ((status.raised_amount - presale_raisedfee) *
            (presale_info.liqudity_percent)) / 100;

        // WETH.deposit{value : baseLiquidity}();

        // require(WETH.approve(address(presale_lock_forwarder), baseLiquidity), 'approve failed.');

        // TransferHelper.safeApprove(address(presale_info.base_token), address(presale_lock_forwarder), baseLiquidity);

        // sale token liquidity
        uint256 tokenLiquidity = (baseLiquidity * presale_info.listing_rate) /
            (10**18);
        require(tokenLiquidity > 0, "ZERO Tokens");
        TransferHelper.safeApprove(
            address(presale_info.sale_token),
            address(presale_lock_forwarder),
            tokenLiquidity
        );

        presale_lock_forwarder.lockLiquidity{
            value: presale_setting.getLockFee() + baseLiquidity
        }(
            address(presale_info.sale_token),
            baseLiquidity,
            tokenLiquidity,
            presale_info.lock_end,
            presale_info.presale_owner
        );

        uint256 presaleSoldFee = (status.sold_amount *
            presale_setting.getSoldFee()) / 100;

        address payable reciver = payable(
            address(presale_fee_info.raise_fee_address)
        );
        reciver.transfer(presale_raisedfee);

        // TransferHelper.safeTransferBaseToken(address(presale_info.base_token), presale_fee_info.raise_fee_address, presale_raisedfee, false);
        TransferHelper.safeTransfer(
            address(presale_info.sale_token),
            presale_fee_info.sole_fee_address,
            presaleSoldFee
        );

        // burn unsold tokens
        uint256 remainingSBalance = IERC20(presale_info.sale_token).balanceOf(
            address(this)
        );
        if (remainingSBalance > status.sold_amount) {
            uint256 burnAmount = remainingSBalance - status.sold_amount;
            TransferHelper.safeTransfer(
                address(presale_info.sale_token),
                0x000000000000000000000000000000000000dEaD,
                burnAmount
            );
        }

        // send remaining base tokens to presale owner
        uint256 remainingBaseBalance = address(this).balance;

        address payable presale_fee_reciver = payable(
            address(presale_info.presale_owner)
        );
        presale_fee_reciver.transfer(remainingBaseBalance);

        status.lp_generation_complete = true;
        emit AddLiquidtySuccess(1);
    }

    function destroy() public {
        require(status.lp_generation_complete, "lp generation incomplete");
        selfdestruct(presale_info.presale_owner);
    }

    //   function getTokenNmae() public view returns (string memory) {
    //       return presale_info.sale_token.name();
    //   }

    //   function getTokenSymbol() public view returns (string memory) {
    //       return presale_info.sale_token.symbol();
    //   }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
     * by making the `nonReentrant` function external, and make it call a
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

import "../ERC20.sol";
import "../../../utils/Arrays.sol";
import "../../../utils/Counters.sol";

/**
 * @dev This contract extends an ERC20 token with a snapshot mechanism. When a snapshot is created, the balances and
 * total supply at the time are recorded for later access.
 *
 * This can be used to safely create mechanisms based on token balances such as trustless dividends or weighted voting.
 * In naive implementations it's possible to perform a "double spend" attack by reusing the same balance from different
 * accounts. By using snapshots to calculate dividends or voting power, those attacks no longer apply. It can also be
 * used to create an efficient ERC20 forking mechanism.
 *
 * Snapshots are created by the internal {_snapshot} function, which will emit the {Snapshot} event and return a
 * snapshot id. To get the total supply at the time of a snapshot, call the function {totalSupplyAt} with the snapshot
 * id. To get the balance of an account at the time of a snapshot, call the {balanceOfAt} function with the snapshot id
 * and the account address.
 *
 * NOTE: Snapshot policy can be customized by overriding the {_getCurrentSnapshotId} method. For example, having it
 * return `block.number` will trigger the creation of snapshot at the begining of each new block. When overridding this
 * function, be careful about the monotonicity of its result. Non-monotonic snapshot ids will break the contract.
 *
 * Implementing snapshots for every block using this method will incur significant gas costs. For a gas-efficient
 * alternative consider {ERC20Votes}.
 *
 * ==== Gas Costs
 *
 * Snapshots are efficient. Snapshot creation is _O(1)_. Retrieval of balances or total supply from a snapshot is _O(log
 * n)_ in the number of snapshots that have been created, although _n_ for a specific account will generally be much
 * smaller since identical balances in subsequent snapshots are stored as a single entry.
 *
 * There is a constant overhead for normal ERC20 transfers due to the additional snapshot bookkeeping. This overhead is
 * only significant for the first transfer that immediately follows a snapshot for a particular account. Subsequent
 * transfers will have normal cost until the next snapshot, and so on.
 */

abstract contract ERC20Snapshot is ERC20 {
    // Inspired by Jordi Baylina's MiniMeToken to record historical balances:
    // https://github.com/Giveth/minimd/blob/ea04d950eea153a04c51fa510b068b9dded390cb/contracts/MiniMeToken.sol

    using Arrays for uint256[];
    using Counters for Counters.Counter;

    // Snapshotted values have arrays of ids and the value corresponding to that id. These could be an array of a
    // Snapshot struct, but that would impede usage of functions that work on an array.
    struct Snapshots {
        uint256[] ids;
        uint256[] values;
    }

    mapping(address => Snapshots) private _accountBalanceSnapshots;
    Snapshots private _totalSupplySnapshots;

    // Snapshot ids increase monotonically, with the first value being 1. An id of 0 is invalid.
    Counters.Counter private _currentSnapshotId;

    /**
     * @dev Emitted by {_snapshot} when a snapshot identified by `id` is created.
     */
    event Snapshot(uint256 id);

    /**
     * @dev Creates a new snapshot and returns its snapshot id.
     *
     * Emits a {Snapshot} event that contains the same id.
     *
     * {_snapshot} is `internal` and you have to decide how to expose it externally. Its usage may be restricted to a
     * set of accounts, for example using {AccessControl}, or it may be open to the public.
     *
     * [WARNING]
     * ====
     * While an open way of calling {_snapshot} is required for certain trust minimization mechanisms such as forking,
     * you must consider that it can potentially be used by attackers in two ways.
     *
     * First, it can be used to increase the cost of retrieval of values from snapshots, although it will grow
     * logarithmically thus rendering this attack ineffective in the long term. Second, it can be used to target
     * specific accounts and increase the cost of ERC20 transfers for them, in the ways specified in the Gas Costs
     * section above.
     *
     * We haven't measured the actual numbers; if this is something you're interested in please reach out to us.
     * ====
     */
    function _snapshot() internal virtual returns (uint256) {
        _currentSnapshotId.increment();

        uint256 currentId = _getCurrentSnapshotId();
        emit Snapshot(currentId);
        return currentId;
    }

    /**
     * @dev Get the current snapshotId
     */
    function _getCurrentSnapshotId() internal view virtual returns (uint256) {
        return _currentSnapshotId.current();
    }

    /**
     * @dev Retrieves the balance of `account` at the time `snapshotId` was created.
     */
    function balanceOfAt(address account, uint256 snapshotId) public view virtual returns (uint256) {
        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _accountBalanceSnapshots[account]);

        return snapshotted ? value : balanceOf(account);
    }

    /**
     * @dev Retrieves the total supply at the time `snapshotId` was created.
     */
    function totalSupplyAt(uint256 snapshotId) public view virtual returns (uint256) {
        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _totalSupplySnapshots);

        return snapshotted ? value : totalSupply();
    }

    // Update balance and/or total supply snapshots before the values are modified. This is implemented
    // in the _beforeTokenTransfer hook, which is executed for _mint, _burn, and _transfer operations.
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        if (from == address(0)) {
            // mint
            _updateAccountSnapshot(to);
            _updateTotalSupplySnapshot();
        } else if (to == address(0)) {
            // burn
            _updateAccountSnapshot(from);
            _updateTotalSupplySnapshot();
        } else {
            // transfer
            _updateAccountSnapshot(from);
            _updateAccountSnapshot(to);
        }
    }

    function _valueAt(uint256 snapshotId, Snapshots storage snapshots) private view returns (bool, uint256) {
        require(snapshotId > 0, "ERC20Snapshot: id is 0");
        require(snapshotId <= _getCurrentSnapshotId(), "ERC20Snapshot: nonexistent id");

        // When a valid snapshot is queried, there are three possibilities:
        //  a) The queried value was not modified after the snapshot was taken. Therefore, a snapshot entry was never
        //  created for this id, and all stored snapshot ids are smaller than the requested one. The value that corresponds
        //  to this id is the current one.
        //  b) The queried value was modified after the snapshot was taken. Therefore, there will be an entry with the
        //  requested id, and its value is the one to return.
        //  c) More snapshots were created after the requested one, and the queried value was later modified. There will be
        //  no entry for the requested id: the value that corresponds to it is that of the smallest snapshot id that is
        //  larger than the requested one.
        //
        // In summary, we need to find an element in an array, returning the index of the smallest value that is larger if
        // it is not found, unless said value doesn't exist (e.g. when all values are smaller). Arrays.findUpperBound does
        // exactly this.

        uint256 index = snapshots.ids.findUpperBound(snapshotId);

        if (index == snapshots.ids.length) {
            return (false, 0);
        } else {
            return (true, snapshots.values[index]);
        }
    }

    function _updateAccountSnapshot(address account) private {
        _updateSnapshot(_accountBalanceSnapshots[account], balanceOf(account));
    }

    function _updateTotalSupplySnapshot() private {
        _updateSnapshot(_totalSupplySnapshots, totalSupply());
    }

    function _updateSnapshot(Snapshots storage snapshots, uint256 currentValue) private {
        uint256 currentId = _getCurrentSnapshotId();
        if (_lastSnapshotId(snapshots.ids) < currentId) {
            snapshots.ids.push(currentId);
            snapshots.values.push(currentValue);
        }
    }

    function _lastSnapshotId(uint256[] storage ids) private view returns (uint256) {
        if (ids.length == 0) {
            return 0;
        } else {
            return ids[ids.length - 1];
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./math/Math.sol";

/**
 * @dev Collection of functions related to array types.
 */
library Arrays {
    /**
     * @dev Searches a sorted `array` and returns the first index that contains
     * a value greater or equal to `element`. If no such index exists (i.e. all
     * values in the array are strictly less than `element`), the array length is
     * returned. Time complexity O(log n).
     *
     * `array` is expected to be sorted in ascending order, and to contain no
     * repeated elements.
     */
    function findUpperBound(uint256[] storage array, uint256 element) internal view returns (uint256) {
        if (array.length == 0) {
            return 0;
        }

        uint256 low = 0;
        uint256 high = array.length;

        while (low < high) {
            uint256 mid = Math.average(low, high);

            // Note that mid will always be strictly less than high (i.e. it will be a valid array index)
            // because Math.average rounds down (it does integer division with truncation).
            if (array[mid] > element) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }

        // At this point `low` is the exclusive upper bound. We will return the inclusive upper bound.
        if (low > 0 && array[low - 1] == element) {
            return low - 1;
        } else {
            return low;
        }
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
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a / b + (a % b == 0 ? 0 : 1);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title ZionToken is the ERC20 of the ZION® Protocol. The initial landing page for the protocol will be on
 * nzft.tech .
 *
 * @dev This is a simple ERC20 mintable, pausable and snapshot token, based on Open Zeppelin contracts.
 * NOTE We will deploy vesting wallets. Token supply will be managed by the DAO via a Minion, which will be set owner of the contract
 */

contract ZION is ERC20, Ownable, Pausable, ERC20Snapshot {
    constructor() ERC20("ZION - Power to Creators", "ZION") {}

    /// @dev Snapshot calling function
    function snapshot() public onlyOwner {
        _snapshot();
    }

    /// @dev Pause calling function
    function pause() public onlyOwner {
        _pause();
    }

    /// @dev Unpause calling function
    function unpause() public onlyOwner {
        _unpause();
    }

    /// @dev Mint calling function
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20Snapshot) whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../ERC20.sol";
import "../../../security/Pausable.sol";

/**
 * @dev ERC20 token with pausable token transfers, minting and burning.
 *
 * Useful for scenarios such as preventing trades until the end of an evaluation
 * period, or having an emergency switch for freezing all token transfers in the
 * event of a large bug.
 */
abstract contract ERC20Pausable is ERC20, Pausable {
    /**
     * @dev See {ERC20-_beforeTokenTransfer}.
     *
     * Requirements:
     *
     * - the contract must not be paused.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        require(!paused(), "ERC20Pausable: token transfer while paused");
    }
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
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
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
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
        require(paused(), "Pausable: not paused");
        _;
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
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/utils/Context.sol";

abstract contract MembershipAccess is Context {
    modifier onlyTokenHolders(uint256 id) {
        require(
            IERC1155(address(this)).balanceOf(msg.sender, id) != 0,
            "Only token holders can perform this action"
        );
        _;
    }

    modifier onlyOneNFTperAddress(uint256 id) {
        address thisAddress = msg.sender;
        require(
            IERC1155(address(this)).balanceOf(msg.sender, id) < 2,
            "Members can only hold one membership token"
        );
        _;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenLocker {
    address public owner;
    uint256 public price;
    uint256 public penaltyfee;

    struct holder {
        address holderAddress;
        mapping(address => Token) tokens;
    }

    struct Token {
        uint256 balance;
        address tokenAddress;
        uint256 unlockTime;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only available to the contract owner.");
        _;
    }

    mapping(address => holder) public holders;

    constructor(address _owner, uint256 _price) {
        owner = _owner;
        price = _price;
        penaltyfee = 10; // default value
    }

    event Hold(
        address indexed holder,
        address token,
        uint256 amount,
        uint256 unlockTime
    );

    event PanicWithdraw(
        address indexed holder,
        address token,
        uint256 amount,
        uint256 unlockTime
    );

    event Withdrawal(address indexed holder, address token, uint256 amount);

    event FeesClaimed();

    event SetOwnerSuccess(address owner);

    event SetPriceSuccess(uint256 _price);

    event SetPenaltyFeeSuccess(uint256 _fee);

    event OwnerWithdrawSuccess(uint256 amount);

    function tokenLock(
        address token,
        uint256 amount,
        uint256 unlockTime,
        address withdrawer
    ) public payable {
        require(msg.value >= price, "Required price is low");

        holder storage holder0 = holders[withdrawer];
        holder0.holderAddress = withdrawer;

        Token storage lockedToken = holders[withdrawer].tokens[token];

        if (lockedToken.balance > 0) {
            lockedToken.balance += amount;

            if (lockedToken.unlockTime < unlockTime) {
                lockedToken.unlockTime = unlockTime;
            }
        } else {
            holders[withdrawer].tokens[token] = Token(
                amount,
                token,
                unlockTime
            );
        }

        IERC20(token).transferFrom(withdrawer, address(this), amount);

        emit Hold(withdrawer, token, amount, unlockTime);
    }

    function withdraw(address token) public {
        holder storage holder0 = holders[msg.sender];

        require(
            msg.sender == holder0.holderAddress,
            "Only available to the token owner."
        );

        require(
            block.timestamp > holder0.tokens[token].unlockTime,
            "Unlock time not reached yet."
        );

        uint256 amount = holder0.tokens[token].balance;

        holder0.tokens[token].balance = 0;

        IERC20(token).transfer(msg.sender, amount);

        emit Withdrawal(msg.sender, token, amount);
    }

    function panicWithdraw(address token) public {
        holder storage holder0 = holders[msg.sender];

        require(
            msg.sender == holder0.holderAddress,
            "Only available to the token owner."
        );

        uint256 feeAmount = (holder0.tokens[token].balance / 100) * penaltyfee;
        uint256 withdrawalAmount = holder0.tokens[token].balance - feeAmount;

        holder0.tokens[token].balance = 0;

        //Transfers fees to the contract administrator/owner
        // holders[address(owner)].tokens[token].balance = feeAmount;

        // Transfers fees to the token owner
        IERC20(token).transfer(msg.sender, withdrawalAmount);

        // Transfers fees to the contract administrator/owner
        IERC20(token).transfer(owner, feeAmount);

        emit PanicWithdraw(
            msg.sender,
            token,
            withdrawalAmount,
            holder0.tokens[token].unlockTime
        );
    }

    // function claimTokenListFees(address[] memory tokenList) public onlyOwner {

    //     for (uint256 i = 0; i < tokenList.length; i++) {

    //         uint256 amount = holders[owner].tokens[tokenList[i]].balance;

    //         if (amount > 0) {

    //             holders[owner].tokens[tokenList[i]].balance = 0;

    //             IERC20(tokenList[i]).transfer(owner, amount);
    //         }
    //     }
    //     emit FeesClaimed();
    // }

    // function claimTokenFees(address token) public onlyOwner {

    //     uint256 amount = holders[owner].tokens[token].balance;

    //     require(amount > 0, "No fees available for claiming.");

    //     holders[owner].tokens[token].balance = 0;

    //     IERC20(token).transfer(owner, amount);

    //     emit FeesClaimed();
    // }

    function OwnerWithdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        address payable ownerAddress = payable(owner);

        ownerAddress.transfer(amount);

        emit OwnerWithdrawSuccess(amount);
    }

    function getcurtime() public view returns (uint256) {
        return block.timestamp;
    }

    function GetBalance(address token) public view returns (uint256) {
        Token storage lockedToken = holders[msg.sender].tokens[token];
        return lockedToken.balance;
    }

    function SetOwner(address contractowner) public onlyOwner {
        owner = contractowner;
        emit SetOwnerSuccess(owner);
    }

    function SetPrice(uint256 _price) public onlyOwner {
        price = _price;
        emit SetPriceSuccess(price);
    }

    // function GetPrice() public view returns (uint256) {
    //     return price;
    // }

    function SetPenaltyFee(uint256 _penaltyfee) public onlyOwner {
        penaltyfee = _penaltyfee;
        emit SetPenaltyFeeSuccess(penaltyfee);
    }

    // function GetPenaltyFee() public view returns (uint256) {
    //     return penaltyfee;
    // }

    function GetUnlockTime(address token) public view returns (uint256) {
        Token storage lockedToken = holders[msg.sender].tokens[token];
        return lockedToken.unlockTime;
    }
}