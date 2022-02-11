// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

/*
    _    _  ___  _   _ _   _ ____
   | \  / |/ _ \| | | | \ | |  _ \
   | |\/| | | | | | | |  \| | | | \
   | |  | | |_| | |_| | |\  | |_| /
   |_|  |_|\___/ \___/|_| \_|____/


*
* MIT License
* ===========
*
* Copyright (c) 2021 MOUND FINANCE
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*/

interface IMoundToken {
    struct PortfolioInfo {
        address token;
        address strategy;
    }

    function tvl() external view returns (uint);

    function mint(address account, uint amount) external;

    function addPortfolio(address token, address strategy) external;

    function updatePortfolioStrategy(address token, address strategy) external;

    function deposit(address token, uint amount) external payable;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

/*
    _    _  ___  _   _ _   _ ____
   | \  / |/ _ \| | | | \ | |  _ \
   | |\/| | | | | | | |  \| | | | \
   | |  | | |_| | |_| | |\  | |_| /
   |_|  |_|\___/ \___/|_| \_|____/


*
* MIT License
* ===========
*
* Copyright (c) 2021 MOUND FINANCE
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

import "@pancakeswap/pancake-swap-lib/contracts/token/BEP20/SafeBEP20.sol";

import "./interfaces/IMoundToken.sol";
import "./interfaces/IPriceCalculator.sol";
import "./interfaces/IRewardPool.sol";
import "./interfaces/IStrategyPayable.sol";
import "./library/BEP20Upgradeable.sol";
import "./library/SafeToken.sol";


contract MoundTokenBSC is IMoundToken, BEP20Upgradeable {
    using SafeToken for address;
    using SafeBEP20 for IBEP20;

    /* ========== CONSTANT ========== */

    IPriceCalculator public constant priceCalculator = IPriceCalculator(0xF5BF8A9249e3cc4cB684E3f23db9669323d4FB7d);
    IRewardPool public constant MND_VAULT = IRewardPool(0x7a7f11ef54fD7ce28808ec3F0C4178aFDfc91493);

    uint public constant RESERVE_RATIO = 15;

    /* ========== STATE VARIABLES ========== */

    mapping(address => bool) public minters;

    address[] private _portfolioList;
    mapping(address => PortfolioInfo) public portfolios;

    address public keeper;

    mapping(address => uint) private _profitSupply;

    /* ========== EVENTS ========== */

    event Deposited(address indexed user, address indexed token, uint amount);

    receive() external payable {}

    /* ========== MODIFIERS ========== */

    modifier onlyMinter() {
        require(owner() == msg.sender || minters[msg.sender], "MoundToken: caller is not the minter");
        _;
    }

    modifier onlyKeeper() {
        require(keeper == msg.sender || owner() == msg.sender, "MoundToken: caller is not keeper");
        _;
    }

    /* ========== INITIALIZER ========== */

    function initialize() external initializer {
        __BEP20__init("Mound Token", "MND", 18);
    }

    /* ========== VIEWS ========== */

    function tvl() public view override returns (uint valueInUSD) {
        valueInUSD = 0;

        for (uint i = 0; i < _portfolioList.length; i++) {
            valueInUSD = valueInUSD.add(portfolioValueOf(_portfolioList[i]));
        }
    }

    function portfolioValueOf(address token) public view returns (uint) {
        uint price;
        if (token == address(0)) {
            price = priceCalculator.priceOfBNB();
        } else {
            (, price) = priceCalculator.valueOfAsset(token, 1e18);
        }

        return portfolioBalanceOf(token).mul(price).div(1e18);
    }

    function portfolioBalanceOf(address token) public view returns (uint) {
        uint balance = token == address(0) ? address(this).balance : IBEP20(token).balanceOf(address(this));
        uint stakedBalance = portfolios[token].strategy == address(0)
        ? 0
        : IStrategy(portfolios[token].strategy).balanceOf(address(this));
        return stakedBalance.add(balance);
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function mint(address account, uint amount) public override onlyMinter {
        _mint(account, amount);
        _mint(owner(), amount.mul(RESERVE_RATIO).div(100));
    }

    function setMinter(address account, bool isMinter) external onlyOwner {
        minters[account] = isMinter;
    }

    function setKeeper(address _keeper) external onlyOwner {
        require(_keeper != address(0), "MoundToken: invalid address");
        keeper = _keeper;
    }

    function addPortfolio(address token, address strategy) external override onlyOwner {
        require(portfolios[token].token == address(0), "MoundToken: portfolio is already set");
        portfolios[token] = PortfolioInfo(token, strategy);
        _portfolioList.push(token);

        if (token != address(0) && strategy != address(0)) {
            IBEP20(token).safeApprove(strategy, 0);
            IBEP20(token).safeApprove(strategy, uint(-1));
        }
    }

    function updatePortfolioStrategy(address token, address strategy) external override onlyOwner {
        require(strategy != address(0), "MoundToken: strategy must not be zero");

        uint _before = token == address(0) ? address(this).balance : IBEP20(token).balanceOf(address(this));
        if (portfolios[token].strategy != address(0) &&
            IStrategy(portfolios[token].strategy).balanceOf(address(this)) > 0) {
            IStrategy(portfolios[token].strategy).withdrawAll();
        }
        uint migrationAmount = token == address(0) ? address(this).balance.sub(_before) : IBEP20(token).balanceOf(address(this)).sub(_before);

        if (portfolios[token].strategy != address(0) && token != address(0)) {
            IBEP20(token).approve(portfolios[token].strategy, 0);
        }

        portfolios[token].strategy = strategy;

        if (token != address(0)) {
            IBEP20(token).safeApprove(strategy, 0);
            IBEP20(token).safeApprove(strategy, uint(-1));
        }

        if (migrationAmount > 0) {
            if (token == address(0)) {
                IStrategyPayable(strategy).deposit{ value: migrationAmount }(migrationAmount);
            } else {
                IStrategyPayable(strategy).deposit(migrationAmount);
            }
        }
    }

    function harvest() external onlyKeeper {
        address[] memory rewards = MND_VAULT.rewardTokens();
        uint[] memory amounts = new uint[](rewards.length);
        for(uint i = 0; i < rewards.length; i++) {
            address token = rewards[i];
            if (portfolios[token].strategy != address(0)) {
                uint beforeBalance = IBEP20(token).balanceOf(address(this));

                if (IStrategy(portfolios[token].strategy).earned(address(this)) > 0) {
                    IStrategy(portfolios[token].strategy).getReward();
                }

                uint profit = IBEP20(token).balanceOf(address(this)).add(_profitSupply[token]).sub(beforeBalance);
                _profitSupply[token] = 0;
                IBEP20(token).safeTransfer(address(MND_VAULT), profit);
                amounts[i] = profit;
            }
        }

        MND_VAULT.notifyRewardAmounts(amounts);
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function deposit(address token, uint amount) external payable override onlyKeeper {
        if (token == address(0)) {
            amount = msg.value;
            if (portfolios[token].strategy != address(0)) {
                IStrategy(portfolios[token].strategy).depositAll{ value: amount }();
            }
        } else {
            IBEP20(token).safeTransferFrom(msg.sender, address(this), amount);
            if (portfolios[token].strategy != address(0)) {
                IStrategy(portfolios[token].strategy).depositAll();
            }
        }

        emit Deposited(msg.sender, token, amount);
    }

    function depositRest(address token, uint amount) external onlyKeeper {
        if (portfolios[token].strategy != address(0)) {
            if (token == address(0) && address(this).balance >= amount) {
                IStrategyPayable(portfolios[token].strategy).deposit{ value: amount }(amount);
            } else if (IBEP20(token).balanceOf(address(this)) >= amount) {
                IStrategyPayable(portfolios[token].strategy).deposit(amount);
            }
        }
    }

    function supplyProfit(address token, uint amount) external payable onlyKeeper {
        require(portfolios[token].token != address(0), "MoundToken: invalid token");
        if (token != address(0)) {
            IBEP20(token).safeTransferFrom(msg.sender, address(this), amount);
        }
        _profitSupply[token] = token != address(0) ? amount : msg.value;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import './IBEP20.sol';
import '../../math/SafeMath.sol';
import '../../utils/Address.sol';

/**
 * @title SafeBEP20
 * @dev Wrappers around BEP20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeBEP20 for IBEP20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            'SafeBEP20: approve from non-zero to non-zero allowance'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            'SafeBEP20: decreased allowance below zero'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, 'SafeBEP20: low-level call failed');
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), 'SafeBEP20: BEP20 operation did not succeed');
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

/*
  ___                      _   _
 | _ )_  _ _ _  _ _ _  _  | | | |
 | _ \ || | ' \| ' \ || | |_| |_|
 |___/\_,_|_||_|_||_\_, | (_) (_)
                    |__/

*
* MIT License
* ===========
*
* Copyright (c) 2020 BunnyFinance
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*/

interface IPriceCalculator {
    struct ReferenceData {
        uint lastData;
        uint lastUpdated;
    }

    function pricesInUSD(address[] memory assets) external view returns (uint[] memory);

    function valueOfAsset(address asset, uint amount) external view returns (uint valueInBNB, uint valueInUSD);

    function unsafeValueOfAsset(address asset, uint amount) external view returns (uint valueInBNB, uint valueInUSD);

    function priceOfBunny() external view returns (uint);

    function priceOfBNB() external view returns (uint);

    function setPrices(address[] memory assets, uint[] memory prices) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

import "./IStrategy.sol";

interface IRewardPool is IStrategy {
    function totalSupply() external view returns (uint);
    function rewardTokens() external view returns (address [] memory);

    function notifyRewardAmounts(uint[] memory amounts) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "./IStrategy.sol";

interface IStrategyPayable is IStrategy {
    function deposit(uint amount) external payable;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "@pancakeswap/pancake-swap-lib/contracts/token/BEP20/IBEP20.sol";
import "@pancakeswap/pancake-swap-lib/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

abstract contract BEP20Upgradeable is IBEP20, OwnableUpgradeable {
    using SafeMath for uint;

    mapping(address => uint) private _balances;
    mapping(address => mapping(address => uint)) private _allowances;
    uint private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint[50] private __gap;

    /**
     * @dev sets initials supply and the owner
     */
    function __BEP20__init(
        string memory name,
        string memory symbol,
        uint8 decimals
    ) internal initializer {
        __Ownable_init();
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view override returns (address) {
        return owner();
    }

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the token name.
     */
    function name() external view override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {BEP20-totalSupply}.
     */
    function totalSupply() public view override returns (uint) {
        return _totalSupply;
    }

    /**
     * @dev See {BEP20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint) {
        return _balances[account];
    }

    /**
     * @dev See {BEP20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint amount) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {BEP20-allowance}.
     */
    function allowance(address owner, address spender) external view override returns (uint) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {BEP20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {BEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance")
        );
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint subtractedValue) public returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero")
        );
        return true;
    }

    /**
     * @dev Burn `amount` tokens and decreasing the total supply.
     */
    function burn(uint amount) public returns (bool) {
        _burn(_msgSender(), amount);
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
        uint amount
    ) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
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
        uint amount
    ) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint amount) internal {
        _burn(account, amount);
        _approve(
            account,
            _msgSender(),
            _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance")
        );
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

interface ERC20Interface {
    function balanceOf(address user) external view returns (uint);
}

library SafeToken {
    function myBalance(address token) internal view returns (uint) {
        return ERC20Interface(token).balanceOf(address(this));
    }

    function balanceOf(address token, address user) internal view returns (uint) {
        return ERC20Interface(token).balanceOf(user);
    }

    function safeApprove(
        address token,
        address to,
        uint value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "!safeApprove");
    }

    function safeTransfer(
        address token,
        address to,
        uint value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "!safeTransfer");
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "!safeTransferFrom");
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success, ) = to.call{ value: value }(new bytes(0));
        require(success, "!safeTransferETH");
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.4.0;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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

pragma solidity >=0.4.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, 'SafeMath: modulo by zero');
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.2;

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
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
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
        require(address(this).balance >= amount, 'Address: insufficient balance');

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
        return functionCall(target, data, 'Address: low-level call failed');
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
        return _functionCallWithValue(target, data, 0, errorMessage);
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
        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
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
        require(address(this).balance >= value, 'Address: insufficient balance for call');
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), 'Address: call to non-contract');

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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
pragma solidity 0.6.12;

/*
    _    _  ___  _   _ _   _ ____
   | \  / |/ _ \| | | | \ | |  _ \
   | |\/| | | | | | | |  \| | | | \
   | |  | | |_| | |_| | |\  | |_| /
   |_|  |_|\___/ \___/|_| \_|____/


*
* MIT License
* ===========
*
* Copyright (c) 2021 MOUND FINANCE
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

interface IStrategy {
    function balanceOf(address account) external view returns (uint);
    function principalOf(address account) external view returns (uint);
    function earned(address account) external view returns (uint);

    function depositAll() external payable;

    function withdrawAll() external;
    function getReward() external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/Initializable.sol";
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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
import "../proxy/Initializable.sol";

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line compiler-version
pragma solidity >=0.4.24 <0.8.0;

import "../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/Math.sol";
import "@pancakeswap/pancake-swap-lib/contracts/token/BEP20/SafeBEP20.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

import "./library/SafeToken.sol";
import "./library/PausableUpgradeable.sol";

import "./interfaces/IPriceCalculator.sol";
import "./interfaces/IZap.sol";
import "./interfaces/IStrategyPayable.sol";

contract VaultQubitCompensation is PausableUpgradeable, ReentrancyGuardUpgradeable {
    using SafeBEP20 for IBEP20;
    using SafeMath for uint;
    using SafeToken for address;

    /* ========== CONSTANTS ============= */

    IPriceCalculator public constant priceCalculator = IPriceCalculator(0xF5BF8A9249e3cc4cB684E3f23db9669323d4FB7d);
    IZap public constant zap = IZap(0xdC2bBB0D33E0e7Dea9F5b98F46EDBaC823586a0C);

    address public constant BUNNY_POOL = 0x4fd0143a3DA1E4BA762D42fF53BE5Fab633e014D;
    address public constant QUBIT_LOCKER = 0xB8243be1D145a528687479723B394485cE3cE773;

    address public constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public constant ETH = 0x2170Ed0880ac9A755fd29B2688956BD959F933F8;
    address public constant BTCB = 0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c;
    address public constant USDT = 0x55d398326f99059fF775485246999027B3197955;
    address public constant USDC = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;
    address public constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public constant BUNNY = 0xC9849E6fdB743d08fAeE3E34dd2D1bc69EA11a51;
    address public constant QBT = 0x17B7163cf1Dbd286E262ddc68b553D899B93f526;
    address public constant CAKE = 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82;

    struct DepositRequest {
        address to;
        uint amount;
    }

    /* ========== STATE VARIABLES ========== */

    uint public pendingRewards;
    uint public harvestBountyBps;

    uint public periodFinish;
    uint public rewardRate;
    uint public rewardsDuration;
    uint public lastUpdateTime;
    uint public rewardPerTokenStored;
    uint public totalRewardsPaidInUSD;
    uint public totalCompensationInUSD;

    mapping(address => uint) public rewards;
    mapping(address => uint) public userRewardPerTokenPaid;
    mapping(address => uint) public userRewardPaidAmount;

    mapping(address => uint) private _shares;

    address[] private _tokensToSwap;

    /* ========== EVENTS ========== */

    event SetShare(address indexed user, uint amount);
    event Deposited(address indexed pool, uint amount);

    event RewardsAdded(uint amount, uint value);
    event RewardsPaid(address indexed user, uint amount);
    event Recovered(address indexed token, uint amount);
    event RewardsDurationUpdated(uint256 newDuration);

    receive() payable external {
        pendingRewards = pendingRewards.add(msg.value);
    }

    /* ========== MODIFIERS ========== */

    modifier updateRewards(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    /* ========== INITIALIZER ========== */

    function initialize() external initializer {
        __PausableUpgradeable_init();
        __ReentrancyGuard_init();

        rewardsDuration = 1;
        harvestBountyBps = 5;

        _tokensToSwap.push(ETH);
        _tokensToSwap.push(BTCB);
        _tokensToSwap.push(USDT);
        _tokensToSwap.push(USDC);
        _tokensToSwap.push(BUSD);
        _tokensToSwap.push(BUNNY);
        _tokensToSwap.push(CAKE);

        IBEP20(BUNNY).safeApprove(BUNNY_POOL, uint(- 1));
        IBEP20(QBT).safeApprove(QUBIT_LOCKER, uint(- 1));

        IBEP20(ETH).safeApprove(address(zap), uint(- 1));
        IBEP20(BTCB).safeApprove(address(zap), uint(- 1));
        IBEP20(USDT).safeApprove(address(zap), uint(- 1));
        IBEP20(USDC).safeApprove(address(zap), uint(- 1));
        IBEP20(BUSD).safeApprove(address(zap), uint(- 1));
        IBEP20(BUNNY).safeApprove(address(zap), uint(- 1));
        IBEP20(CAKE).safeApprove(address(zap), uint(- 1));
    }

    /* ========== VIEW FUNCTIONS ========== */

    function totalShare() public view returns (uint) {
        return totalCompensationInUSD;
    }

    function shareOf(address account) public view returns (uint) {
        return _shares[account];
    }

    function earned(address account) public view returns (uint) {
        return _shares[account].mul(rewardPerToken().sub(userRewardPerTokenPaid[account])).div(1e18).add(rewards[account]);
    }

    function rewardPerToken() public view returns (uint) {
        if (totalShare() == 0) return rewardPerTokenStored;
        return rewardPerTokenStored.add(lastTimeRewardApplicable().sub(lastUpdateTime).mul(rewardRate).mul(1e18).div(totalShare()));
    }

    function lastTimeRewardApplicable() public view returns (uint) {
        return Math.min(block.timestamp, periodFinish);
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function setRewardsDuration(uint _rewardsDuration) external onlyOwner {
        require(periodFinish == 0 || block.timestamp > periodFinish, "VaultComp: invalid rewards duration");
        rewardsDuration = _rewardsDuration;

        emit RewardsDurationUpdated(rewardsDuration);
    }

    function setHarvestBountyBps(uint _bps) external onlyOwner {
        require(_bps <= 10000, "VaultComp: invalid bps");
        harvestBountyBps = _bps;
    }

    function depositOnBehalf(address _token, uint _amount) external onlyOwner {
        if (_token == BUNNY) {
            uint _before = IBEP20(BUNNY).balanceOf(address(this));
            IBEP20(BUNNY).safeTransferFrom(msg.sender, address(this), _amount);
            _amount = IBEP20(BUNNY).balanceOf(address(this)).sub(_before);
            IStrategyPayable(BUNNY_POOL).deposit(_amount);
            emit Deposited(BUNNY_POOL, _amount);
        }

        if (_token == QBT) {
            uint _before = IBEP20(QBT).balanceOf(address(this));
            IBEP20(QBT).safeTransferFrom(msg.sender, address(this), _amount);
            _amount = IBEP20(QBT).balanceOf(address(this)).sub(_before);
            IStrategyPayable(QUBIT_LOCKER).deposit(_amount);
            emit Deposited(QUBIT_LOCKER, _amount);
        }
    }

    function setShareBehalfBulk(DepositRequest[] memory request) external onlyOwner {
        for (uint i = 0; i < request.length; i++) {
            address to = request[i].to;
            uint amount = request[i].amount;
            _shares[to] = _shares[to].add(amount);
            totalCompensationInUSD = totalCompensationInUSD.add(amount);

            emit SetShare(to, amount);
        }
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function getReward() public nonReentrant updateRewards(msg.sender) {
        uint reward = earned(msg.sender);
        if (reward > 0) {
            rewards[msg.sender] = 0;

            userRewardPaidAmount[msg.sender] = userRewardPaidAmount[msg.sender].add(reward);
            SafeToken.safeTransferETH(msg.sender, reward);

            emit RewardsPaid(msg.sender, reward);
        }
    }

    function harvest() public nonReentrant returns (uint rewardAmount, uint harvestBounty) {
        rewardAmount = 0;
        harvestBounty = 0;
        //        IStrategy(BUNNY_POOL).getReward();
        //        IStrategy(QUBIT_LOCKER).getReward();
        //
        //        _convertRewardToken();
        //
        //        harvestBounty = pendingRewards.mul(harvestBountyBps).div(10000);
        //        rewardAmount = pendingRewards.sub(harvestBounty);
        //
        //        _notifyRewardAmounts(rewardAmount);
        //        pendingRewards = 0;
        //
        //        SafeToken.safeTransferETH(msg.sender, harvestBounty);
    }

    /* ========== PRIVATE FUNCTION ========== */

    function _notifyRewardAmounts(uint amount) private updateRewards(address(0)) {
        if (amount > 0) {
            if (block.timestamp >= periodFinish) {
                rewardRate = amount.div(rewardsDuration);
            } else {
                uint remaining = periodFinish.sub(block.timestamp);
                uint leftover = remaining.mul(rewardRate);
                rewardRate = amount.add(leftover).div(rewardsDuration);
            }

            // Ensure the provided reward amount is not more than the balance in the contract.
            // This keeps the reward rate in the right range, preventing overflows due to
            // very high values of rewardRate in the earned and rewardsPerToken functions;
            // Reward + leftover must be less than 2^256 / 10^18 to avoid overflow.

            uint _balance = address(this).balance;
            require(rewardRate <= _balance.div(rewardsDuration), "VaultComp: invalid rewards amount");

            (, uint valueInUSD) = priceCalculator.valueOfAsset(WBNB, amount);

            totalRewardsPaidInUSD = totalRewardsPaidInUSD.add(valueInUSD);

            lastUpdateTime = block.timestamp;
            periodFinish = block.timestamp.add(rewardsDuration);
            emit RewardsAdded(amount, valueInUSD);
        }
    }

    function _convertRewardToken() private {
        for (uint i = 0; i < _tokensToSwap.length; i++) {
            address token = _tokensToSwap[i];
            uint tokenBalance = IBEP20(token).balanceOf(address(this));
            if (token != WBNB && tokenBalance > 0) {
                zap.zapOut(token, tokenBalance);
            }
        }
    }

    /* ========== SALVAGE PURPOSE ONLY ========== */

    function recoverToken(address _token, uint amount) external onlyOwner {
        for (uint i = 0; i < _tokensToSwap.length; i++) {
            require(_token != _tokensToSwap[i], "VaultComp: cannot recover token to be reward");
        }
        IBEP20(_token).safeTransfer(owner(), amount);
        emit Recovered(_token, amount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
import "../proxy/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}

/*
   ____            __   __        __   _
  / __/__ __ ___  / /_ / /  ___  / /_ (_)__ __
 _\ \ / // // _ \/ __// _ \/ -_)/ __// / \ \ /
/___/ \_, //_//_/\__//_//_/\__/ \__//_/ /_\_\
     /___/

* Docs: https://docs.synthetix.io/
*
*
* MIT License
* ===========
*
* Copyright (c) 2020 Synthetix
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";


abstract contract PausableUpgradeable is OwnableUpgradeable {
    uint public lastPauseTime;
    bool public paused;

    event PauseChanged(bool isPaused);

    modifier notPaused {
        require(!paused, "PausableUpgradeable: cannot be performed while the contract is paused");
        _;
    }

    function __PausableUpgradeable_init() internal initializer {
        __Ownable_init();
        require(owner() != address(0), "PausableUpgradeable: owner must be set");
    }

    function setPaused(bool _paused) external onlyOwner {
        if (_paused == paused) {
            return;
        }

        paused = _paused;
        if (paused) {
            lastPauseTime = now;
        }

        emit PauseChanged(paused);
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

interface IZap {
    function zapOut(address _from, uint amount) external;
    function zapIn(address _to) external payable;
    function zapInToken(address _from, uint amount, address _to) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

/*
    _    _  ___  _   _ _   _ ____
   | \  / |/ _ \| | | | \ | |  _ \
   | |\/| | | | | | | |  \| | | | \
   | |  | | |_| | |_| | |\  | |_| /
   |_|  |_|\___/ \___/|_| \_|____/


*
* MIT License
* ===========
*
* Copyright (c) 2021 MOUND FINANCE
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@pancakeswap/pancake-swap-lib/contracts/math/SafeMath.sol";
import "@pancakeswap/pancake-swap-lib/contracts/token/BEP20/SafeBEP20.sol";

import "./library/PausableUpgradeable.sol";
import "./library/WhitelistUpgradeable.sol";

import "./interfaces/IStrategy.sol";
import "./interfaces/IQore.sol";
import "./interfaces/IQToken.sol";
import "./library/SafeToken.sol";
import "./interfaces/IStrategyPayable.sol";

contract StrategyQBT is IStrategy, WhitelistUpgradeable, PausableUpgradeable, ReentrancyGuardUpgradeable{
    using SafeBEP20 for IBEP20;
    using SafeMath for uint;
    using SafeToken for address;

    /* ========== CONSTANT ========== */

    IQore private constant QORE = IQore(0xF70314eb9c7Fe7D88E6af5aa7F898b3A162dcd48);
    IStrategyPayable public constant QUBIT_LOCKER = IStrategyPayable(0xB8243be1D145a528687479723B394485cE3cE773);

    address private constant QBT = 0x17B7163cf1Dbd286E262ddc68b553D899B93f526;
    address private constant qQBT = 0xcD2CD343CFbe284220677C78A08B1648bFa39865;
    address private constant MND = 0x4c97c901B5147F8C1C7Ce3c5cF3eB83B44F244fE;

    uint private constant DUST = 1000;

    /* ========== STATE VARIABLES ========== */

    mapping(address => uint) public principals;

    /* ========== EVENT ========== */

    event Deposited(address indexed user, uint amount);
    event Withdrawn(address indexed user, uint amount);
    event ProfitPaid(address indexed user, uint amount);

    /* ========== INITIALIZER ========== */

    function initialize() external initializer {
        __PausableUpgradeable_init();
        __WhitelistUpgradeable_init();
        __ReentrancyGuard_init();

        // approve QBT
        QBT.safeApprove(qQBT, uint(-1));

        // enter the qQBT market
        address[] memory qubitMarket = new address[](1);
        qubitMarket[0] = qQBT;
        QORE.enterMarkets(qubitMarket);
    }

    /* ========== VIEWS ========== */

    function balance() public view returns (uint) {
        return IQToken(qQBT).underlyingBalanceOf(address(this));
    }

    function balanceOf(address account) public view override returns (uint) {
        require(account != address(0), "StrategyQBT: invalid account!");
        return balance();
    }

    function principalOf(address account) public view override returns (uint) {
        return principals[account];
    }

    function earned(address account) public view override returns (uint) {
        uint profit = rewardProfit();
        if (balanceOf(account) > principals[account] + DUST) {
            profit = profit.add(balanceOf(account).sub(principals[account]));
        }
        return profit;
    }

    function rewardProfit() public view returns (uint) {
        return QORE.accruedQubit(qQBT, address(this));
    }

    /* ========== RESTRICTED FUNCTION ========== */

    function deposit(uint _amount) public onlyWhitelisted nonReentrant {
        uint _before = QBT.balanceOf(address(this));
        QBT.safeTransferFrom(msg.sender, address(this), _amount);
        uint amountQBT = QBT.balanceOf(address(this)).sub(_before);

        principals[msg.sender] = principals[msg.sender].add(amountQBT);

        // supply QBT
        if (IBEP20(QBT).allowance(address(this), address(QUBIT_LOCKER)) == 0) {
            QBT.safeApprove(address(QUBIT_LOCKER), uint(-1));
        }
        QUBIT_LOCKER.deposit(amountQBT);

        emit Deposited(msg.sender, amountQBT);
    }

    function depositAll() public payable override onlyWhitelisted {
        uint amount = QBT.balanceOf(msg.sender);
        deposit(amount);
    }

    function withdrawUnderlying(uint _amount) public onlyWhitelisted nonReentrant {
        require(_amount <= principals[msg.sender], "StrategyQBT: Invalid input amount");

        uint _before = QBT.balanceOf(address(this));

        // TODO deprecated, change qLocker
        QORE.redeemUnderlying(qQBT, _amount);

        uint amountQBT = QBT.balanceOf(address(this)).sub(_before);

        principals[msg.sender] = principals[msg.sender].sub(amountQBT);

        QBT.safeTransfer(msg.sender, amountQBT);

        emit Withdrawn(msg.sender, amountQBT);
    }

    function withdrawAll() public override onlyWhitelisted {
        uint _before = QBT.balanceOf(address(this));

        // TODO deprecated, change qLocker
        QORE.redeemToken(qQBT, IQToken(qQBT).balanceOf(address(this)));
        QORE.claimQubit(qQBT);

        uint amountQBT = QBT.balanceOf(address(this)).sub(_before);

        delete principals[msg.sender];

        QBT.safeTransfer(msg.sender, amountQBT);
        emit Withdrawn(msg.sender, amountQBT);
    }

    function getReward() public override onlyWhitelisted {
        uint _before = QBT.balanceOf(address(this));

        // supply interest
        if (balanceOf(msg.sender) > principals[msg.sender] + DUST) {
            QORE.redeemUnderlying(qQBT, balanceOf(msg.sender).sub(principals[msg.sender]));
        }

        // supply reward
        QORE.claimQubit(qQBT);
        uint claimedQBT = QBT.balanceOf(address(this)).sub(_before);

        QBT.safeTransfer(msg.sender, claimedQBT);
        emit ProfitPaid(msg.sender, claimedQBT);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

/*
    _    _  ___  _   _ _   _ ____
   | \  / |/ _ \| | | | \ | |  _ \
   | |\/| | | | | | | |  \| | | | \
   | |  | | |_| | |_| | |\  | |_| /
   |_|  |_|\___/ \___/|_| \_|____/


*
* MIT License
* ===========
*
* Copyright (c) 2021 MOUND FINANCE
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract WhitelistUpgradeable is OwnableUpgradeable {
    mapping (address => bool) private _whitelist;
    bool private _disable;                      // default - false means whitelist feature is working on. if true no more use of whitelist

    event Whitelisted(address indexed _address, bool whitelist);
    event EnableWhitelist();
    event DisableWhitelist();

    modifier onlyWhitelisted {
        require(_disable || _whitelist[msg.sender], "Whitelist: caller is not on the whitelist");
        _;
    }

    function __WhitelistUpgradeable_init() internal initializer {
        __Ownable_init();
    }

    function isWhitelist(address _address) public view returns(bool) {
        return _whitelist[_address];
    }

    function setWhitelist(address _address, bool _on) external onlyOwner {
        _whitelist[_address] = _on;

        emit Whitelisted(_address, _on);
    }

    function disableWhitelist(bool disable) external onlyOwner {
        _disable = disable;
        if (disable) {
            emit DisableWhitelist();
        } else {
            emit EnableWhitelist();
        }
    }

    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

/*
      ___       ___       ___       ___       ___
     /\  \     /\__\     /\  \     /\  \     /\  \
    /::\  \   /:/ _/_   /::\  \   _\:\  \    \:\  \
    \:\:\__\ /:/_/\__\ /::\:\__\ /\/::\__\   /::\__\
     \::/  / \:\/:/  / \:\::/  / \::/\/__/  /:/\/__/
     /:/  /   \::/  /   \::/  /   \:\__\    \/__/
     \/__/     \/__/     \/__/     \/__/

*
* MIT License
* ===========
*
* Copyright (c) 2021 QubitFinance
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/


import "../library/QConstant.sol";

interface IQore {
    function qValidator() external view returns (address);

    function allMarkets() external view returns (address[] memory);
    function marketListOf(address account) external view returns (address[] memory);
    function marketInfoOf(address qToken) external view returns (QConstant.MarketInfo memory);
    function checkMembership(address account, address qToken) external view returns (bool);
    function accountLiquidityOf(address account) external view returns (uint collateralInUSD, uint supplyInUSD, uint borrowInUSD);

    function distributionInfoOf(address market) external view returns (QConstant.DistributionInfo memory);
    function accountDistributionInfoOf(address market, address account) external view returns (QConstant.DistributionAccountInfo memory);
    function apyDistributionOf(address market, address account) external view returns (QConstant.DistributionAPY memory);
    function distributionSpeedOf(address qToken) external view returns (uint supplySpeed, uint borrowSpeed);
    function boostedRatioOf(address market, address account) external view returns (uint boostedSupplyRatio, uint boostedBorrowRatio);

    function closeFactor() external view returns (uint);
    function liquidationIncentive() external view returns (uint);
    function getTotalUserList() external view returns (address[] memory);

    function accruedQubit(address market, address account) external view returns (uint);
    function accruedQubit(address account) external view returns (uint);

    function enterMarkets(address[] memory qTokens) external;
    function exitMarket(address qToken) external;

    function supply(address qToken, uint underlyingAmount) external payable returns (uint);
    function redeemToken(address qToken, uint qTokenAmount) external returns (uint redeemed);
    function redeemUnderlying(address qToken, uint underlyingAmount) external returns (uint redeemed);
    function borrow(address qToken, uint amount) external;
    function repayBorrow(address qToken, uint amount) external payable;
    function repayBorrowBehalf(address qToken, address borrower, uint amount) external payable;
    function liquidateBorrow(address qTokenBorrowed, address qTokenCollateral, address borrower, uint amount) external payable;

    function claimQubit() external;
    function claimQubit(address market) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

/*
      ___       ___       ___       ___       ___
     /\  \     /\__\     /\  \     /\  \     /\  \
    /::\  \   /:/ _/_   /::\  \   _\:\  \    \:\  \
    \:\:\__\ /:/_/\__\ /::\:\__\ /\/::\__\   /::\__\
     \::/  / \:\/:/  / \:\::/  / \::/\/__/  /:/\/__/
     /:/  /   \::/  /   \::/  /   \:\__\    \/__/
     \/__/     \/__/     \/__/     \/__/

*
* MIT License
* ===========
*
* Copyright (c) 2021 QubitFinance
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

import "../library/QConstant.sol";


interface IQToken {
    function underlying() external view returns (address);

    function totalSupply() external view returns (uint);

    function accountSnapshot(address account) external view returns (QConstant.AccountSnapshot memory);

    function underlyingBalanceOf(address account) external view returns (uint);

    function borrowBalanceOf(address account) external view returns (uint);

    function borrowRatePerSec() external view returns (uint);

    function supplyRatePerSec() external view returns (uint);

    function totalBorrow() external view returns (uint);

    function exchangeRate() external view returns (uint);

    function getCash() external view returns (uint);

    function getAccInterestIndex() external view returns (uint);

    function accruedAccountSnapshot(address account) external returns (QConstant.AccountSnapshot memory);

    function accruedUnderlyingBalanceOf(address account) external returns (uint);

    function accruedBorrowBalanceOf(address account) external returns (uint);

    function accruedTotalBorrow() external returns (uint);

    function accruedExchangeRate() external returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address dst, uint amount) external returns (bool);

    function transferFrom(
        address src,
        address dst,
        uint amount
    ) external returns (bool);

    function supply(address account, uint underlyingAmount) external payable returns (uint);

    function redeemToken(address account, uint qTokenAmount) external returns (uint);

    function redeemUnderlying(address account, uint underlyingAmount) external returns (uint);

    function borrow(address account, uint amount) external returns (uint);

    function repayBorrow(address account, uint amount) external payable returns (uint);

    function repayBorrowBehalf(
        address payer,
        address borrower,
        uint amount
    ) external payable returns (uint);

    function liquidateBorrow(
        address qTokenCollateral,
        address liquidator,
        address borrower,
        uint amount
    ) external payable returns (uint qAmountToSeize);

    function seize(
        address liquidator,
        address borrower,
        uint qTokenAmount
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

/*
      ___       ___       ___       ___       ___
     /\  \     /\__\     /\  \     /\  \     /\  \
    /::\  \   /:/ _/_   /::\  \   _\:\  \    \:\  \
    \:\:\__\ /:/_/\__\ /::\:\__\ /\/::\__\   /::\__\
     \::/  / \:\/:/  / \:\::/  / \::/\/__/  /:/\/__/
     /:/  /   \::/  /   \::/  /   \:\__\    \/__/
     \/__/     \/__/     \/__/     \/__/

*
* MIT License
* ===========
*
* Copyright (c) 2021 QubitFinance
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

library QConstant {
    uint public constant CLOSE_FACTOR_MIN = 5e16;
    uint public constant CLOSE_FACTOR_MAX = 9e17;
    uint public constant COLLATERAL_FACTOR_MAX = 9e17;

    struct MarketInfo {
        bool isListed;
        uint borrowCap;
        uint collateralFactor;
    }

    struct BorrowInfo {
        uint borrow;
        uint interestIndex;
    }

    struct AccountSnapshot {
        uint qTokenBalance;
        uint borrowBalance;
        uint exchangeRate;
    }

    struct AccrueSnapshot {
        uint totalBorrow;
        uint totalReserve;
        uint accInterestIndex;
    }

    struct DistributionInfo {
        uint supplySpeed;
        uint borrowSpeed;
        uint totalBoostedSupply;
        uint totalBoostedBorrow;
        uint accPerShareSupply;
        uint accPerShareBorrow;
        uint accruedAt;
    }

    struct DistributionAccountInfo {
        uint accruedQubit;
        uint boostedSupply; // effective(boosted) supply balance of user  (since last_action)
        uint boostedBorrow; // effective(boosted) borrow balance of user  (since last_action)
        uint accPerShareSupply; // Last integral value of Qubit rewards per share. ∫(qubitRate(t) / totalShare(t) dt) from 0 till (last_action)
        uint accPerShareBorrow; // Last integral value of Qubit rewards per share. ∫(qubitRate(t) / totalShare(t) dt) from 0 till (last_action)
    }

    struct DistributionAPY {
        uint apySupplyQBT;
        uint apyBorrowQBT;
        uint apyAccountSupplyQBT;
        uint apyAccountBorrowQBT;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

/*
      ___       ___       ___       ___       ___
     /\  \     /\__\     /\  \     /\  \     /\  \
    /::\  \   /:/ _/_   /::\  \   _\:\  \    \:\  \
    \:\:\__\ /:/_/\__\ /::\:\__\ /\/::\__\   /::\__\
     \::/  / \:\/:/  / \:\::/  / \::/\/__/  /:/\/__/
     /:/  /   \::/  /   \::/  /   \:\__\    \/__/
     \/__/     \/__/     \/__/     \/__/

*
* MIT License
* ===========
*
* Copyright (c) 2021 QubitFinance
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

import "../library/QConstant.sol";

interface IQDistributor {
    function accruedQubit(address[] calldata markets, address account) external view returns (uint);
    function distributionInfoOf(address market) external view returns (QConstant.DistributionInfo memory);
    function accountDistributionInfoOf(address market, address account) external view returns (QConstant.DistributionAccountInfo memory);
    function apyDistributionOf(address market, address account) external view returns (QConstant.DistributionAPY memory);
    function boostedRatioOf(address market, address account) external view returns (uint boostedSupplyRatio, uint boostedBorrowRatio);

    function notifySupplyUpdated(address market, address user) external;
    function notifyBorrowUpdated(address market, address user) external;
    function notifyTransferred(address qToken, address sender, address receiver) external;

    function claimQubit(address[] calldata markets, address account) external;
    function kick(address user) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

/*
    _    _  ___  _   _ _   _ ____
   | \  / |/ _ \| | | | \ | |  _ \
   | |\/| | | | | | | |  \| | | | \
   | |  | | |_| | |_| | |\  | |_| /
   |_|  |_|\___/ \___/|_| \_|____/


*
* MIT License
* ===========
*
* Copyright (c) 2021 MOUND FINANCE
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

import "@openzeppelin/contracts/math/Math.sol";
import "@pancakeswap/pancake-swap-lib/contracts/math/SafeMath.sol";

import "./library/RewardsDistributionRecipientUpgradeable.sol";
import "./library/VaultConstant.sol";

import "./interfaces/IPriceCalculator.sol";
import "./interfaces/IRewardPool.sol";

contract VaultMNDMirror is RewardsDistributionRecipientUpgradeable {
    using SafeMath for uint;

    /* ========== CONSTANT ========== */

    IRewardPool public constant VAULT_MND = IRewardPool(0x7a7f11ef54fD7ce28808ec3F0C4178aFDfc91493);

    /* ========== STATE VARIABLES ========== */

    uint public periodFinish;
    uint public rewardsDuration;
    uint public lastUpdateTime;
    uint public rewardRate;

    address public keeper;
    uint public rewardPerTokenStored;
    mapping(address => uint) public balances;
    mapping(address => uint) public rewards;
    mapping(address => uint) public userRewardPerTokenPaid;
    mapping(address => uint) public syncedAt;

    /* ========== EVENTS ========== */

    event RewardAdded(uint amount);

    modifier onlyVaultMND() {
        require(msg.sender == address(VAULT_MND), "VaultMNDMirror: only vault mnd");
        _;
    }

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    modifier onlyKeeper() {
        require(msg.sender == keeper || msg.sender == owner(), "VaultController: caller is not the owner or keeper");
        _;
    }

    /* ========== INITIALIZER ========== */

    function initialize() external initializer {
        __RewardsDistributionRecipient_init();

        rewardsDuration = 30 days;
    }

    /* ========== VIEWS ========== */

    function totalSupply() public view returns (uint) {
        return VAULT_MND.totalSupply();
    }

    function balanceOf(address account) public view returns (uint) {
        return balances[account];
    }

    function lastTimeRewardApplicable() public view returns (uint) {
        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint) {
        uint _totalSupply = totalSupply();
        if (_totalSupply == 0) {
            return 0;
        }

        return rewardPerTokenStored.add(
            lastTimeRewardApplicable().sub(lastUpdateTime).mul(rewardRate).mul(1e18).div(_totalSupply)
        );
    }

    function earned(address account) public view returns (uint) {
        return balances[account].mul(rewardPerToken().sub(userRewardPerTokenPaid[account])).div(1e18).add(rewards[account]);
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function notifyRewardAmount(uint reward) override external onlyRewardsDistribution {
        if (block.timestamp >= periodFinish) {
            rewardRate = reward.div(rewardsDuration);
        } else {
            uint remaining = periodFinish.sub(block.timestamp);
            uint leftover = remaining.mul(rewardRate);
            rewardRate = reward.add(leftover).div(rewardsDuration);
        }

        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(rewardsDuration);
        emit RewardAdded(reward);
    }

    function setRewardsDuration(uint _rewardsDuration) external onlyOwner {
        require(periodFinish == 0 || block.timestamp > periodFinish, "VaultMNDMirror: period");
        rewardsDuration = _rewardsDuration;
    }

    function setKeeper(address _keeper) external onlyOwner {
        keeper = _keeper;
    }

    function sync(address[] memory accounts) external onlyKeeper {
        for (uint i = 0; i < accounts.length; i++) {
            address account = accounts[i];
            if (syncedAt[account] == 0) {
                _deposit(VAULT_MND.balanceOf(account), account);
                syncedAt[account] = block.timestamp;
            }
        }
    }

    /* ========== MUTATE FUNCTIONS ========== */

    function deposit(uint _amount, address _to) external onlyVaultMND {
        _deposit(_amount, _to);
    }

    function withdraw(uint _amount, address _to) external onlyVaultMND updateReward(_to) {
        require(_amount <= balances[_to], "VaultMNDMirror: invalid amount");
        balances[_to] = balances[_to].sub(_amount);
    }

    /* ========== PRIVATE FUNCTIONS ========== */

    function _deposit(uint _amount, address _to) private updateReward(_to) {
        balances[_to] = balances[_to].add(_amount);
    }
}

/*
   ____            __   __        __   _
  / __/__ __ ___  / /_ / /  ___  / /_ (_)__ __
 _\ \ / // // _ \/ __// _ \/ -_)/ __// / \ \ /
/___/ \_, //_//_/\__//_//_/\__/ \__//_/ /_\_\
     /___/

* Docs: https://docs.synthetix.io/
*
*
* MIT License
* ===========
*
* Copyright (c) 2020 Synthetix
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

abstract contract RewardsDistributionRecipientUpgradeable is OwnableUpgradeable {
    address public rewardsDistribution;

    modifier onlyRewardsDistribution() {
        require(msg.sender == rewardsDistribution, "PausableUpgradeable: caller is not the rewardsDistribution");
        _;
    }

    function __RewardsDistributionRecipient_init() internal initializer {
        __Ownable_init();
    }

    function notifyRewardAmount(uint256 reward) virtual external;

    function setRewardsDistribution(address _rewardsDistribution) external onlyOwner {
        rewardsDistribution = _rewardsDistribution;
    }

    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

/*
    _    _  ___  _   _ _   _ ____
   | \  / |/ _ \| | | | \ | |  _ \
   | |\/| | | | | | | |  \| | | | \
   | |  | | |_| | |_| | |\  | |_| /
   |_|  |_|\___/ \___/|_| \_|____/


*
* MIT License
* ===========
*
* Copyright (c) 2021 MOUND FINANCE
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

library VaultConstant {

    struct RewardInfo {
        address token;
        uint rewardPerTokenStored;
        uint rewardRate;
        uint lastUpdateTime;
    }

    struct UserReward {
        address token;
        uint amount;
        uint usd;
    }

    struct VaultInfo {
        uint balance;
        uint balanceInUSD;
        uint totalSupply;
        uint tvl;
        UserReward[] rewards;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

/*
    _    _  ___  _   _ _   _ ____
   | \  / |/ _ \| | | | \ | |  _ \
   | |\/| | | | | | | |  \| | | | \
   | |  | | |_| | |_| | |\  | |_| /
   |_|  |_|\___/ \___/|_| \_|____/


*
* MIT License
* ===========
*
* Copyright (c) 2021 MOUND FINANCE
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@pancakeswap/pancake-swap-lib/contracts/math/SafeMath.sol";
import "@pancakeswap/pancake-swap-lib/contracts/token/BEP20/SafeBEP20.sol";

import "./library/PausableUpgradeable.sol";
import "./library/SafeToken.sol";
import "./library/WhitelistUpgradeable.sol";
import {VaultConstant} from "./library/VaultConstant.sol";
import "./library/VaultConstant.sol";

import "./interfaces/IPriceCalculator.sol";
import "./interfaces/IVaultMirror.sol";


contract VaultMND is PausableUpgradeable, WhitelistUpgradeable, ReentrancyGuardUpgradeable {
    using SafeBEP20 for IBEP20;
    using SafeMath for uint;
    using SafeToken for address;

    /* ========== CONSTANT ========== */

    IPriceCalculator public constant priceCalculator = IPriceCalculator(0xF5BF8A9249e3cc4cB684E3f23db9669323d4FB7d);
    address public constant MND = 0x4c97c901B5147F8C1C7Ce3c5cF3eB83B44F244fE;

    /* ========== STATE VARIABLES ========== */

    IBEP20 public stakingToken;

    address public rewardsDistribution;

    uint public periodFinish;
    uint public rewardsDuration;
    uint public totalSupply;

    address[] private _rewardTokens;
    mapping(address => VaultConstant.RewardInfo) public rewards;
    mapping(address => mapping(address => uint)) public userRewardPerToken;
    mapping(address => mapping(address => uint)) public userRewardPerTokenPaid;

    mapping(address => uint) private _balances;

    address public mirror;

    /* ========== EVENTS ========== */

    event Deposited(address indexed user, uint amount);
    event Withdrawn(address indexed user, uint amount);

    event RewardsAdded(uint[] amounts);
    event RewardsPaid(address indexed user, address token, uint amount);
    event Recovered(address token, uint amount);

    /* ========== INITIALIZER ========== */

    function initialize(address _stakingToken) external initializer {
        __PausableUpgradeable_init();
        __ReentrancyGuard_init();

        stakingToken = IBEP20(_stakingToken);
        rewardsDuration = 30 days;
    }

    /* ========== MODIFIERS ========== */

    modifier onlyRewardsDistribution() {
        require(msg.sender == rewardsDistribution, "VaultMND: caller is not the rewardsDistribution");
        _;
    }

    modifier updateRewards(address account) {
        for (uint i = 0; i < _rewardTokens.length; i++) {
            VaultConstant.RewardInfo storage rewardInfo = rewards[_rewardTokens[i]];
            rewardInfo.rewardPerTokenStored = rewardPerToken(rewardInfo.token);
            rewardInfo.lastUpdateTime = lastTimeRewardApplicable();

            if (account != address(0)) {
                userRewardPerToken[account][rewardInfo.token] = earnedPerToken(account, rewardInfo.token);
                userRewardPerTokenPaid[account][rewardInfo.token] = rewardInfo.rewardPerTokenStored;
            }
        }
        _;
    }

    /* ========== VIEWS ========== */

    function balanceOf(address account) public view returns (uint) {
        return _balances[account];
    }

    function earned(address account) public view returns (uint[] memory) {
        uint[] memory pendingRewards = new uint[](_rewardTokens.length);
        for (uint i = 0; i < _rewardTokens.length; i++) {
            pendingRewards[i] = earnedPerToken(account, _rewardTokens[i]);
        }
        return pendingRewards;
    }

    function earnedPerToken(address account, address token) public view returns (uint) {
        return _balances[account].mul(
            rewardPerToken(token).sub(userRewardPerTokenPaid[account][token])
        ).div(1e18).add(userRewardPerToken[account][token]);
    }

    function rewardTokens() public view returns (address[] memory) {
        return _rewardTokens;
    }

    function rewardPerToken(address token) public view returns (uint) {
        if (totalSupply == 0) return rewards[token].rewardPerTokenStored;
        return rewards[token].rewardPerTokenStored.add(
            lastTimeRewardApplicable().sub(rewards[token].lastUpdateTime).mul(rewards[token].rewardRate).mul(1e18).div(totalSupply)
        );
    }

    function lastTimeRewardApplicable() public view returns (uint) {
        return Math.min(block.timestamp, periodFinish);
    }

    function infoOf(address account) public view returns (VaultConstant.VaultInfo memory vaultInfo) {
        (, uint priceOfMND) = priceCalculator.valueOfAsset(MND, 1e18);
        vaultInfo.balance = balanceOf(account);
        vaultInfo.balanceInUSD = balanceOf(account).mul(priceOfMND).div(1e18);
        vaultInfo.totalSupply = totalSupply;
        vaultInfo.tvl = totalSupply.mul(priceOfMND).div(1e18);
        vaultInfo.rewards = new VaultConstant.UserReward[](_rewardTokens.length);
        for (uint i = 0; i < _rewardTokens.length; i++) {
            vaultInfo.rewards[i].token = _rewardTokens[i];
            uint _earned = earnedPerToken(account, _rewardTokens[i]);
            vaultInfo.rewards[i].amount = _earned;
            (, uint usd) = priceCalculator.valueOfAsset(_rewardTokens[i], _earned);
            vaultInfo.rewards[i].usd = usd;
        }
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function addRewardsToken(address _rewardsToken) external onlyOwner {
        require(_rewardsToken != address(0), "VaultMND: invalid zero address");
        require(rewards[_rewardsToken].token == address(0), "VaultMND: duplicated rewards token");
        rewards[_rewardsToken] = VaultConstant.RewardInfo(_rewardsToken, 0, 0, 0);
        _rewardTokens.push(_rewardsToken);
    }

    function setRewardsDuration(uint _rewardsDuration) external onlyOwner {
        require(periodFinish == 0 || block.timestamp > periodFinish, "VaultMND: invalid rewards duration");
        rewardsDuration = _rewardsDuration;
    }

    function setRewardsDistribution(address _rewardsDistribution) external onlyOwner {
        rewardsDistribution = _rewardsDistribution;
    }

    function setMirror(address _mirror) external onlyOwner {
        mirror = _mirror;
    }

    function notifyRewardAmounts(uint[] memory amounts) external onlyRewardsDistribution updateRewards(address(0)) {
        for (uint i = 0; i < _rewardTokens.length; i++) {
            VaultConstant.RewardInfo storage rewardInfo = rewards[_rewardTokens[i]];
            if (block.timestamp >= periodFinish) {
                rewardInfo.rewardRate = amounts[i].div(rewardsDuration);
            } else {
                uint remaining = periodFinish.sub(block.timestamp);
                uint leftover = remaining.mul(rewardInfo.rewardRate);
                rewardInfo.rewardRate = amounts[i].add(leftover).div(rewardsDuration);
            }
            rewardInfo.lastUpdateTime = block.timestamp;

            // Ensure the provided reward amount is not more than the balance in the contract.
            // This keeps the reward rate in the right range, preventing overflows due to
            // very high values of rewardRate in the earned and rewardsPerToken functions;
            // Reward + leftover must be less than 2^256 / 10^18 to avoid overflow.

            require(rewardInfo.rewardRate <= IBEP20(rewardInfo.token).balanceOf(address(this)).div(rewardsDuration), "VaultMND: invalid rewards amount");
        }

        periodFinish = block.timestamp.add(rewardsDuration);
        emit RewardsAdded(amounts);
    }

    /* ========== MUTATE FUNCTIONS ========== */

    function deposit(uint _amount) public {
        _deposit(_amount, msg.sender);
    }

    function depositAll() public {
        _deposit(stakingToken.balanceOf(msg.sender), msg.sender);
    }

    function withdraw(uint _amount) public nonReentrant notPaused updateRewards(msg.sender) {
        require(_amount > 0, "VaultMND: invalid amount");

        totalSupply = totalSupply.sub(_amount);
        _balances[msg.sender] = _balances[msg.sender].sub(_amount);
        if (mirror != address(0)) {
            IVaultMirror(mirror).withdraw(_amount, msg.sender);
        }

        stakingToken.safeTransfer(msg.sender, _amount);
        emit Withdrawn(msg.sender, _amount);
    }

    function withdrawAll() external {
        uint amount = _balances[msg.sender];
        if (amount > 0) {
            withdraw(amount);
        }

        getReward();
    }

    function getReward() public nonReentrant updateRewards(msg.sender) {
        for (uint i = 0; i < _rewardTokens.length; i++) {
            uint reward = userRewardPerToken[msg.sender][_rewardTokens[i]];
            if (reward > 0) {
                userRewardPerToken[msg.sender][_rewardTokens[i]] = 0;
                IBEP20(_rewardTokens[i]).safeTransfer(msg.sender, reward);
                emit RewardsPaid(msg.sender, _rewardTokens[i], reward);
            }
        }
    }

    /* ========== PRIVATE FUNCTIONS ========== */

    function _deposit(uint _amount, address _to) private nonReentrant notPaused updateRewards(_to) {
        stakingToken.safeTransferFrom(msg.sender, address(this), _amount);

        totalSupply = totalSupply.add(_amount);
        _balances[_to] = _balances[_to].add(_amount);
        if (mirror != address(0)) {
            IVaultMirror(mirror).deposit(_amount, _to);
        }

        emit Deposited(_to, _amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

interface IVaultMirror {
    function deposit(uint _amount, address _to) external;
    function withdraw(uint _amount, address _to) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

/*
    _    _  ___  _   _ _   _ ____
   | \  / |/ _ \| | | | \ | |  _ \
   | |\/| | | | | | | |  \| | | | \
   | |  | | |_| | |_| | |\  | |_| /
   |_|  |_|\___/ \___/|_| \_|____/


*
* MIT License
* ===========
*
* Copyright (c) 2021 MOUND FINANCE
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*/

import "@openzeppelin/contracts/math/Math.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@pancakeswap/pancake-swap-lib/contracts/token/BEP20/SafeBEP20.sol";
import "@pancakeswap/pancake-swap-lib/contracts/math/SafeMath.sol";

import "./interfaces/IMoundToken.sol";
import "./interfaces/IPriceCalculator.sol";

contract MoundOfferingBSC is OwnableUpgradeable {
    using SafeBEP20 for IBEP20;
    using SafeMath for uint;

    /* ========== CONSTANT ========== */

    address public constant BUNNY = 0xC9849E6fdB743d08fAeE3E34dd2D1bc69EA11a51;

    uint public constant DIST_THRESHOLD = 500;

    /* ========== STATE VARIABLES ========== */

    address public offeringToken;

    bool public archived;
    uint public startAt;
    uint public closeAt;
    uint public totalSupply;

    uint public totalUserCount;
    uint private _distributionCursor;
    address[] private _userList;
    mapping(address => bool) private _depositedUsers;

    uint public defaultTotalBalance;
    mapping(address => uint) public defaultBalances;

    uint private _boostedTotalBalance;
    mapping(address => uint) private _boostedBalances;

    /* ========== EVENTS ========== */

    event Deposited(address indexed user, address indexed token, uint amount);
    event Distributed(uint count, uint remain);
    event Recovered(address token, uint amount);

    /* ========== INITIALIZER ========== */

    function initialize() external initializer {
        __Ownable_init();
    }

    /* ========== VIEWS ========== */

    function getBoostRate() public view returns (uint) {
        uint weekNum = uint(-1);

        if (startAt <= block.timestamp && block.timestamp <= closeAt) {
            weekNum = block.timestamp.sub(startAt).div(7 days);
        }

        if (weekNum == 0) return 150e16;
        if (weekNum == 1) return 125e16;
        if (weekNum == 2) return 110e16;
        return 100e16;
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function schedule(uint _startAt, uint _closeAt) external onlyOwner {
        require(_closeAt > _startAt, "!schedule");
        startAt = _startAt;
        closeAt = _closeAt;
    }

    function offer(address _offeringToken, uint _totalSupply) external onlyOwner {
        require(_offeringToken != address(0) && _totalSupply > 0, "!offer");
        offeringToken = _offeringToken;
        totalSupply = _totalSupply;

        IBEP20(BUNNY).approve(_offeringToken, uint(-1));
    }

    function archive() external onlyOwner {
        require(offeringToken != address(0), "!offeringToken");
        require(block.timestamp > closeAt, "!archive");
        archived = true;

        IBEP20(BUNNY).approve(offeringToken, 0);
    }

    function distribute() external onlyOwner {
        require(offeringToken != address(0), "!offeringToken");
        require(archived, "archived");

        uint start = _distributionCursor;
        uint remain = totalUserCount > _distributionCursor ? totalUserCount - _distributionCursor : 0;
        uint length = Math.min(remain, DIST_THRESHOLD);
        for (uint i = start; i < start + length; i++) {
            address user = _userList[i];
            uint share = _boostedBalances[user].mul(1e18).div(_boostedTotalBalance);
            uint amount = totalSupply.mul(share).div(1e18);

            delete defaultBalances[user];
            delete _boostedBalances[user];

            IMoundToken(offeringToken).mint(user, amount);
            _distributionCursor++;
        }

        remain = totalUserCount > _distributionCursor ? totalUserCount - _distributionCursor : 0;
        emit Distributed(length, remain);
    }

    function transferReserves() external onlyOwner {
        require(offeringToken != address(0), "!offeringToken");
        require(archived, "archived");
        IBEP20(offeringToken).safeTransfer(owner(), IBEP20(offeringToken).balanceOf(address(this)));
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function deposit(address token, uint amount) external {
        require(!archived, "archived");
        require(startAt <= block.timestamp && block.timestamp <= closeAt, "!schedule");
        require(token == BUNNY, "!token");

        IBEP20(token).safeTransferFrom(msg.sender, address(this), amount);
        IMoundToken(offeringToken).deposit(token, amount);

        uint boostAmount = amount.mul(getBoostRate()).div(1e18);

        defaultBalances[msg.sender] = defaultBalances[msg.sender].add(amount);
        defaultTotalBalance = defaultTotalBalance.add(amount);

        _boostedBalances[msg.sender] = _boostedBalances[msg.sender].add(boostAmount);
        _boostedTotalBalance = _boostedTotalBalance.add(boostAmount);

        if (!_depositedUsers[msg.sender]) {
            _depositedUsers[msg.sender] = true;
            _userList.push(msg.sender);
            totalUserCount++;
        }
        emit Deposited(msg.sender, token, amount);
    }

    /* ========== SALVAGE PURPOSE ONLY ========== */

    function recoverToken(address _token, uint amount) external virtual onlyOwner {
        IBEP20(_token).safeTransfer(owner(), amount);

        emit Recovered(_token, amount);
    }
}