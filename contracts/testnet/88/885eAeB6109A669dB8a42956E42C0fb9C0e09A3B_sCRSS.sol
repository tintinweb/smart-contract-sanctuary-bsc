// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

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
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
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
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
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
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
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
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
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
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
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

interface IsCRSS is IERC20 {
    function enter(uint256 _amount) external;

    function leave(uint256 _amount) external;

    function enterFor(uint256 _amount, address _to) external;

    function killswitch() external;

    function rescueToken(address _token, uint256 _amount) external;

    function rescueETH(uint256 _amount) external;

    function impactFeeStatus(bool _value) external;

    function setImpactFeeReceiver(address _feeReceiver) external;

    function changeControlCenter(address _address) external;

    function CRSStoSCRSS(uint256 _crssAmount, bool _impactFeeOn)
        external
        view
        returns (
            uint256 crssAmount,
            uint256 swapFee,
            uint256 impactFee
        );

    function sCRSStoCRSS(uint256 _sCrssAmount, bool _impactFeeOn)
        external
        view
        returns (
            uint256 crssAmount,
            uint256 swapFee,
            uint256 impactFee
        );

    event TradingHalted(uint256 timestamp);
    event TradingResumed(uint256 timestamp);
}

interface IControlCenter {
    function getAddress(uint256 _pid) external view returns (address);
}

contract sCRSS is Context, IsCRSS {
    IERC20 public crssToken;

    string private _name = "sCRSS Token";
    string private _symbol = "sCRSS";
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public controlCenter; //control center
    address public adminSetter;
    address public impactFeeReceiver;
    address public accountant;
    bool public priceImpactFeeIsOn;
    bool public tradingHalted;

    constructor(IERC20 _crssToken) {
        crssToken = _crssToken;

        priceImpactFeeIsOn = true;

        //temp
        impactFeeReceiver = 0xD8f9c299b13584757109a7C37Adbb897CEb7207F;
        accountant = 0x9ECdb621DC5A26203B6bCD9c074C2B56A7B66B2D;
        controlCenter = msg.sender;
        adminSetter = msg.sender;

        // _mint(address(this), 100000 * (10**18));
    }

    receive() external payable {}

    // Enter staking. Pay some CRSS. Earn some shares.
    // Locks CRSS and mints sCRSS
    function enter(uint256 _amount) public override {
        // Gets the amount of CRSS locked in the contract
        uint256 totalCrss = crssToken.balanceOf(address(this));
        // Gets the amount of sCRSS in existence
        uint256 totalShares = totalSupply();
        // Send CRSS to the contract
        //in the frontend we should add approve functionality which gets triggered if(allowance(msg.sender, address(this)) < type(uint).max), this way users will only need to approve once,
        //since there will be no way for the contract to abuse approved user funds, we can safely make them approve max amount to save gas without security concerns
        crssToken.transferFrom(msg.sender, address(this), _amount);

        // If no sCRSS exists, mint it 1:1 to the amount put in
        if (totalShares == 0 || totalCrss == 0) {
            _mint(msg.sender, _amount);
        } else {
            // Calculate and mint the amount of sCRSS the CRSS is worth. The ratio will change overtime, as sCRSS is burned/minted and CRSS deposited + gained from fees / withdrawn.
            //0.25% CRSS swap fee, all earnings go to sCRSS dividends
            uint256 swapFee = (_amount * 25) / 10000;
            uint256 feeAdjustedAmount = _amount - swapFee;
            //initial rate
            uint256 amount0 = (feeAdjustedAmount * totalShares) / totalCrss;

            if (priceImpactFeeIsOn) {
                uint256 kRatio = totalShares * totalCrss;
                uint256 impactAdjustedSupply = kRatio /
                    (totalCrss + feeAdjustedAmount);
                //rate after swap
                uint256 amount1 = (feeAdjustedAmount * impactAdjustedSupply) /
                    (totalCrss + feeAdjustedAmount);
                //anti whale protection
                uint256 midRate = (amount0 + amount1) / 2;

                //mints medium rate amount between before and after swap, this accounts for price impact, difference sent to IFReceiver

                _mint(impactFeeReceiver, amount0 - midRate);
                amount0 = midRate;
            }
            _mint(msg.sender, amount0);
            crssToken.transfer(accountant, swapFee);
        }
    }

    // Leave staking. Claim back your CRSS.
    // Unlocks the staked + gained CRSS and burns sCRSS
    function leave(uint256 _amount) public override {
        // Gets the amount of CRSS locked in the contract
        uint256 totalCrss = crssToken.balanceOf(address(this));
        // Gets the amount of sCRSS in existence
        uint256 totalShares = totalSupply();
        _burn(msg.sender, _amount);
        //initial rate
        uint256 swapFee = (_amount * 25) / 10000;
        uint256 feeAdjustedAmount = _amount - swapFee;
        //initial rate
        _mint(accountant, swapFee);
        uint256 amount0 = (feeAdjustedAmount * totalCrss) / totalShares;
        if (priceImpactFeeIsOn) {
            uint256 kRatio = totalShares * totalCrss;
            uint256 impactAdjustedSupply = kRatio / (totalCrss - amount0);
            //rate after swap
            uint256 amount1 = (feeAdjustedAmount * (totalCrss - amount0)) /
                impactAdjustedSupply;
            //anti whale protection
            uint256 midRate = (amount0 + amount1) / 2;

            //mints medium rate amount between before and after swap, this accounts for price impact, difference sent to IFReceiver

            //_mint(impactFeeReceiver, amount0 - midRate);
            crssToken.transfer(impactFeeReceiver, amount0 - midRate);
            amount0 = midRate;
        }

        crssToken.transfer(msg.sender, amount0);
    }

    function enterFor(uint256 _amount, address _to) public override {
        // Gets the amount of CRSS locked in the contract
        uint256 totalCrss = crssToken.balanceOf(address(this));
        // Gets the amount of sCRSS in existence
        uint256 totalShares = totalSupply();
        // Send CRSS to the contract
        //in the frontend we should add approve functionality which gets triggered if(allowance(msg.sender, address(this)) < type(uint).max), this way users will only need to approve once,
        //since there will be no way for the contract to abuse approved user funds, we can safely make them approve max amount to save gas without security concerns
        if (crssToken.allowance(msg.sender, address(this)) < _amount) {
            crssToken.approve(address(this), _amount);
        }
        crssToken.transferFrom(msg.sender, address(this), _amount);

        // If no sCRSS exists, mint it 1:1 to the amount put in
        if (totalShares == 0 || totalCrss == 0) {
            _mint(_to, _amount);
        } else {
            // Calculate and mint the amount of sCRSS the CRSS is worth. The ratio will change overtime, as sCRSS is burned/minted and CRSS deposited + gained from fees / withdrawn.
            //0.25% CRSS swap fee, all earnings go to sCRSS dividends
            uint256 swapFee = (_amount * 25) / 10000;
            uint256 feeAdjustedAmount = _amount - swapFee;
            //initial rate
            uint256 amount0 = (feeAdjustedAmount * totalShares) / totalCrss;

            if (priceImpactFeeIsOn) {
                uint256 kRatio = totalShares * totalCrss;
                uint256 impactAdjustedSupply = kRatio /
                    (totalCrss + feeAdjustedAmount);
                //rate after swap
                uint256 amount1 = (feeAdjustedAmount * impactAdjustedSupply) /
                    (totalCrss + feeAdjustedAmount);
                //anti whale protection
                uint256 midRate = (amount0 + amount1) / 2;

                //mints medium rate amount between before and after swap, this accounts for price impact, difference sent to IFReceiver

                _mint(impactFeeReceiver, amount0 - midRate);
                amount0 = midRate;
            }
            _mint(_to, amount0);
            crssToken.transfer(accountant, swapFee);
        }
    }

    modifier onlyControlCenter() {
        require(_msgSender() == controlCenter, "sCRSS:Only Control center");
        _;
    }

    function getControlCenter() public view returns (address) {
        return controlCenter;
    }

    function getAccountant() public view returns (address) {
        return accountant;
    }

    function getAdminSetter() public view returns (address) {
        return adminSetter;
    }

    function killswitch() external override onlyControlCenter {
        bool isHalted = tradingHalted;
        if (isHalted == false) {
            isHalted = true;
            emit TradingHalted(block.timestamp);
        } else {
            isHalted = false;
            emit TradingResumed(block.timestamp);
        }
    }

    function changeControlCenter(address _address) public override {
        require(
            _msgSender() == adminSetter || _msgSender() == controlCenter,
            "CRSS:Only admin setter and CC"
        );
        require(controlCenter != _address, "sCRSS:Already set value");
        controlCenter = _address;
    }

    function impactFeeStatus(bool _value) external override onlyControlCenter {
        require(_value != priceImpactFeeIsOn, "sCRSS:Already set value");
        priceImpactFeeIsOn = _value;
    }

    function sCRSStoCRSS(uint256 _sCrssAmount, bool _impactFeeOn)
        public
        view
        override
        returns (
            uint256 crssAmount,
            uint256 swapFee,
            uint256 impactFee
        )
    {
        // Gets the amount of CRSS locked in the contract
        uint256 totalCrss = crssToken.balanceOf(address(this));
        // Gets the amount of sCRSS in existence
        uint256 totalShares = totalSupply();
        // _burn(msg.sender, _amount);
        //initial rate
        swapFee = (_sCrssAmount * 25) / 10000;
        uint256 feeAdjustedAmount = _sCrssAmount - swapFee;
        //initial rate
        // _mint(accountant, swapFee);
        crssAmount = (feeAdjustedAmount * totalCrss) / totalShares;
        impactFee = 0;
        if (_impactFeeOn) {
            uint256 kRatio = totalShares * totalCrss;
            uint256 impactAdjustedSupply = kRatio / (totalCrss - crssAmount);
            //rate after swap
            uint256 amount1 = (feeAdjustedAmount * (totalCrss - crssAmount)) /
                impactAdjustedSupply;
            //anti whale protection
            uint256 midRate = (crssAmount + amount1) / 2;

            //mints medium rate amount between before and after swap, this accounts for price impact, difference sent to IFReceiver

            //_mint(impactFeeReceiver, amount0 - midRate);
            impactFee = crssAmount - midRate;
            crssAmount = midRate;
        }
    }

    function CRSStoSCRSS(uint256 _crssAmount, bool _impactFeeOn)
        public
        view
        override
        returns (
            uint256 sCrssAmount,
            uint256 swapFee,
            uint256 impactFee
        )
    {
        // Gets the amount of CRSS locked in the contract
        uint256 totalCrss = crssToken.balanceOf(address(this));
        // Gets the amount of sCRSS in existence
        uint256 totalShares = totalSupply();

        // Calculate and mint the amount of sCRSS the CRSS is worth. The ratio will change overtime, as sCRSS is burned/minted and CRSS deposited + gained from fees / withdrawn.
        //0.25% CRSS swap fee, all earnings go to sCRSS dividends
        swapFee = (_crssAmount * 25) / 10000;
        uint256 feeAdjustedAmount = _crssAmount - swapFee;
        //initial rate
        sCrssAmount = (feeAdjustedAmount * totalShares) / totalCrss;
        impactFee = 0;

        if (_impactFeeOn) {
            uint256 kRatio = totalShares * totalCrss;
            uint256 impactAdjustedSupply = kRatio /
                (totalCrss + feeAdjustedAmount);
            //rate after swap
            uint256 sCrssAdjustedAmount = (feeAdjustedAmount *
                impactAdjustedSupply) / (totalCrss + feeAdjustedAmount);
            //anti whale protection
            uint256 midRate = (sCrssAmount + sCrssAdjustedAmount) / 2;

            //mints medium rate amount between before and after swap, this accounts for price impact, difference sent to IFReceiver

            //_mint(impactFeeReceiver, amount0 - midRate);
            impactFee = sCrssAmount - midRate;
            sCrssAmount = midRate;
        }
        //_mint(msg.sender, amount0);
        //crssToken.transfer(accountant, swapFee);
    }

    function setImpactFeeReceiver(address _feeReceiver)
        public
        override
        onlyControlCenter
    {
        impactFeeReceiver = _feeReceiver;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue);
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        return true;
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount);
        _approve(sender, _msgSender(), currentAllowance - amount);
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(tradingHalted != true, "sCRSS:Trading temporarily halted");

        require(sender != address(0), "sCRSS:Sender is address zero");
        require(recipient != address(0), "sCRSS:Recipient is address zero");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "sCRSS:Insufficient balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0));
        require(spender != address(0));
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _mint(address account, uint256 amount) private {
        require(account != address(0));
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) private {
        require(account != address(0), "MFF: burn from the zero address");
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "MFF: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    //these rescue functions will allow the owner to extract any non CRSS/sCRSS tokens that might get stuck inside the contract over time
    //no security/centralization implications since the contract is designed to work with CRSS only
    function rescueToken(address _token, uint256 _amount)
        external
        override
        onlyControlCenter
    {
        require(
            _token != address(crssToken) && _token != address(this),
            "Can't rescue CRSS or sCRSS"
        );
        IERC20(_token).transfer(msg.sender, _amount);
    }

    function rescueETH(uint256 _amount) external override onlyControlCenter {
        payable(msg.sender).transfer(_amount);
    }

    function _add(uint256 a, uint256 b) private pure returns (uint256) {
        return a + b;
    }

    function _subtract(uint256 a, uint256 b) private pure returns (uint256) {
        return a - b;
    }
}