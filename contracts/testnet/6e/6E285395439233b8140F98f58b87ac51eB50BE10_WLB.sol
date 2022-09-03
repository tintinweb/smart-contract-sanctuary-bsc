// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./erc20/BEP40Token.sol";
import "./wlb/WLBModel.sol";

contract WLB is WLBModel {

    constructor()  {
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../libs/Context.sol";
import "../libs/Ownable.sol";
import "../interface/IBEP40.sol";
import "../libs/SafeMath.sol";
import "./CustomBEP40.sol";


abstract contract BEP40Token is Context, IBEP40, Ownable,CustomBEP40 {
    using SafeMath for uint256;

    // mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) internal _allowances;

    uint256 internal _totalSupply;
    uint256 internal _decimals;
    string internal _symbol;
    string internal _name;

    constructor()  {
        _name = "WLB";
        _symbol = "WLB";
        _decimals = 18;
        _totalSupply = 21000000000000000000000000000; //210亿
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    /**
     * @dev Returns the bep token owner.
   */
    function getOwner() override external view returns (address) {
        return owner();
    }

    /**
     * @dev Returns the token decimals.
   */
    function decimals() override external view returns (uint256) {
        return _decimals;
    }

    /**
     * @dev Returns the token symbol.
   */
    function symbol() override external view returns (string memory) {
        return _symbol;
    }

    /**
    * @dev Returns the token name.
  */
    function name() override external view returns (string memory) {
        return _name;
    }

    /**
     * @dev See {BEP40-totalSupply}.
   */
    function totalSupply() override external view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {BEP40-balanceOf}.
   */
    function balanceOf(address account) override external view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {BEP40-transfer}.
   *
   * Requirements:
   *
   * - `recipient` cannot be the zero address.
   * - the caller must have a balance of at least `amount`.
   */
    // function transfer(address recipient, uint256 amount) override external returns (bool) {
    //     _transfer(_msgSender(), recipient, amount);
    //     return true;
    // }

    /**
     * @dev See {BEP40-allowance}.
   */
    function allowance(address owner, address spender) override external view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {BEP40-approve}.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
    function approve(address spender, uint256 amount) override external returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {BEP40-transferFrom}.
   *
   * Emits an {Approval} event indicating the updated allowance. This is not
   * required by the EIP. See the note at the beginning of {BEP40};
   *
   * Requirements:
   * - `sender` and `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   * - the caller must have allowance for `sender`'s tokens of at least
   * `amount`.
   */
    // function transferFrom(address sender, address recipient, uint256 amount) override external returns (bool) {
    //     _transfer(sender, recipient, amount);
    //     _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP40: transfer amount exceeds allowance"));
    //     return true;
    // }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {BEP40-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {BEP40-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   * - `spender` must have allowance for the caller of at least
   * `subtractedValue`.
   */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP40: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Creates `amount` tokens and assigns them to `msg.sender`, increasing
   * the total supply.
   *
   * Requirements
   *
   * - `msg.sender` must be the token owner
   */
    function mint(uint256 amount) public onlyOwner returns (bool) {
        _mint(_msgSender(), amount);
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
    // functitransfer amount exceeds allowanceon _transfer(address sender, address recipient, uint256 amount) internal {
    //     require(sender != address(0), "BEP40: transfer from the zero address");
    //     require(recipient != address(0), "BEP40: transfer to the zero address");

    //     _balances[sender] = _balances[sender].sub(amount, "BEP40: transfer amount exceeds balance");
    //     _balances[recipient] = _balances[recipient].add(amount);
    //     emit Transfer(sender, recipient, amount);
    // }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
   * the total supply.
   *
   * Emits a {Transfer} event with `from` set to the zero address.
   *
   * Requirements
   *
   * - `to` cannot be the zero address.
   */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP40: mint to the zero address");

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
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP40: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "BEP40: burn amount exceeds balance");
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
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP40: approve from the zero address");
        require(spender != address(0), "BEP40: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
   * from the caller's allowance.
   *
   * See {_burn} and {_approve}.
   */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP40: burn amount exceeds allowance"));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../libs/SafeMath.sol";
import "../interface/IBEP40.sol";
import "../libs/Ownable.sol";
import "./WLBSwap.sol";
import "../erc20/BEP40Token.sol";

abstract contract WLBModel is WLBSwap, BEP40Token {
    using SafeMath for uint256;

    event BalanceEvent(address account, uint256 banance);
    //万分之一状态
    event TenThousandthEvent(address account, uint256 banance, uint status);

    constructor() {}

    /**
     * @dev See {BEP20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
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
        uint256 amount
    ) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "BEP20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "ERC20: Transfer amount must be greater than zero");
        //被禁账号
        require(!_marketList[sender], "ERC20: market is not enabled");
        require(!_marketList[recipient], "ERC20: market is not enabled");

        address fromAddr;
        uint256 fee = 0;
        //        bool taskFee=true;
        if (pairs[sender] == true) {
            fee = 1000;
            fromAddr = recipient;
            _setBuy(recipient, amount);
        } else if (pairs[recipient] == true && sender != owner()) {
            _verifySell(sender, amount);
            fee = 1500;
            fromAddr = sender;
        }

        _balances[sender] = _balances[sender].sub(amount);
        emit BalanceEvent(sender, _balances[sender]);

        dividend(fromAddr, amount.div(10000).mul(fee));
        uint256 recipientRate = 10000 - fee;
        _balances[recipient] = _balances[recipient].add(
            amount.div(10000).mul(recipientRate)
        );
        emit Transfer(sender, recipient, amount.div(10000).mul(recipientRate));
        emit BalanceEvent(recipient, _balances[recipient]);
        _verifyTenThousand(sender);
        _verifyTenThousand(recipient);
    }

    function _verifyTenThousand(address account) internal {
        if (account == owner()) return;
        //万分之一
        uint256 ten = _totalSupply / (10000 * 10**_decimals);

        if (_balances[account] >= ten) {
            if (tenThousandStatus(account) == false) {
                _addTenThousand(account);
                emit TenThousandthEvent(account, _balances[account], 1);
            }
        } else {
            if (tenThousandStatus(account)) {
                _removeTenThousand(account);
                emit TenThousandthEvent(account, _balances[account], 0);
            }
        }
    }

    // 分润    产生分润的用户       分润金额
    function dividend(address sender, uint256 amount) internal {
        if (amount == 0) return;
        _dividendBigDao(sender, amount.div(10000).mul(bigDaoFee));
        _dividendSmallDao(sender, amount.div(10000).mul(smallDaoFee));
        _dividendTenThousand(sender, amount.div(10000).mul(tenThousand));
        _dividendTenThousandDynamic(
            sender,
            amount.div(10000).mul(tenThousandDynamic)
        );
        _dividendLp(sender, amount.div(10000).mul(lpFee));
        _dividendPlatform(sender, amount.div(10000).mul(platformFee));
    }

    //  提走U
    function withdrawUSDT(uint256 amount) public onlyOwner returns (bool) {
        if (amount == 0) {
            amount = IBEP40(usdtAddress).balanceOf(owner());
        }
        return IBEP40(usdtAddress).transfer(owner(), amount);
    }

    //余额增值  增值的账户地址
    function balanceAdded(address[] memory addresses, uint256 rate)
        public
        onlyOwner
        returns (bool)
    {
        require(rate > 0, "ERC20: balanceAdded rate must be greater than zero");
        require(
            addresses.length > 0,
            "ERC20: balanceAdded addresses length than zero"
        );
        address owner = _msgSender();
        for (uint i = 0; i < addresses.length; i++) {
            address account = addresses[i];
            if (owner != account) {
                //账户余额
                uint256 amount = _balances[account];
                //增值比例
                uint256 rateFee = amount.div(10000).mul(rate);
                _balances[owner] = _balances[owner].sub(rateFee);
                _balances[account] = _balances[account].add(rateFee);
                emit Transfer(owner, account, rateFee);
                //余额变动事件
                emit BalanceEvent(account, _balances[account]);

                _verifyTenThousand(owner);
                _verifyTenThousand(account);
            }
        }
        return true;
    }

    /**
     * lp 平均加权分红
     */
    function lpDividendFee(address[] memory addrs, uint256[] memory wlbs)
        public
        onlyOwner
    {
        for (uint i = 0; i < addrs.length; i++) {
            address to = addrs[i];
            uint256 amount = wlbs[i];
            _balances[lpFeeAddr] = _balances[lpFeeAddr].sub(amount);
            _balances[address(0)] = _balances[address(0)].add(amount);
            emit Transfer(lpFeeAddr, address(0), amount);
            emit BalanceEvent(lpFeeAddr, _balances[lpFeeAddr]);
            emit BalanceEvent(address(0), _balances[address(0)]);
            uint256 div = amount.div(wlbUsdt);
            if (IBEP40(usdtAddress).balanceOf(address(this)) > div) {
                IBEP40(usdtAddress).transfer(to, div);
            } else IBEP40(usdtAddress).transfer(to, 0);
        }
    }
    /**
     * 变动万分之一动态分润钱包
     */
    function setTenThousandDynamicAddr(address addr)
        public
        onlyOwner
        returns (bool)
    {
        if (_balances[tenThousandDynamicAddr] > 0) {
            _balances[addr] = _balances[addr].add(
                _balances[tenThousandDynamicAddr]
            );
            emit Transfer(
                tenThousandDynamicAddr,
                addr,
                _balances[tenThousandDynamicAddr]
            );

            emit BalanceEvent(
                tenThousandDynamicAddr,
                _balances[tenThousandDynamicAddr]
            );
            emit BalanceEvent(addr, _balances[addr]);
        }

        tenThousandDynamicAddr = addr;
        return true;
    }

    /**
     * 变动LP 手续费钱包
     */
    function setLpAddr(address addr) public onlyOwner returns (bool) {
        if (_balances[lpFeeAddr] > 0) {
            _balances[addr] = _balances[addr].add(
                _balances[lpFeeAddr]
            );
            emit Transfer(
                lpFeeAddr,
                addr,
                _balances[lpFeeAddr]
            );

            emit BalanceEvent(
                lpFeeAddr,
                _balances[lpFeeAddr]
            );
            emit BalanceEvent(addr, _balances[addr]);
        }

        lpFeeAddr = addr;
        return true;
    }
    /**
     * 变动平台收费钱包
     */
    function setPlatformFeeAddr(address addr) public onlyOwner returns (bool) {
        if (_balances[platformFeeAddr] > 0) {
            _balances[addr] = _balances[addr].add(
                _balances[platformFeeAddr]
            );
            emit Transfer(
                platformFeeAddr,
                addr,
                _balances[platformFeeAddr]
            );

            emit BalanceEvent(
                platformFeeAddr,
                _balances[platformFeeAddr]
            );
            emit BalanceEvent(addr, _balances[addr]);
        }
        platformFeeAddr = addr;
        return true;
    }

    //大Dao主 分 U
    function _dividendBigDao(address sender, uint256 amount) private {
        if (amount == 0) return;
        _balances[address(0)] = _balances[address(0)].add(amount);
        emit Transfer(sender, address(0), amount);

        if (bigDaoArr.length == 0) {
            return;
        }
        //平均没人分红
        uint256 div = amount.div(wlbUsdt).div(bigDaoArr.length);
        for (uint i = 0; i < bigDaoArr.length; i++) {
            address addr = bigDaoArr[i];
            if (IBEP40(usdtAddress).balanceOf(address(this)) > div) {
                IBEP40(usdtAddress).transfer(addr, div);
            } else IBEP40(usdtAddress).transfer(addr, 0);
        }
    }

    //小dao分 wlb
    function _dividendSmallDao(address sender, uint256 amount) private {
        if (amount == 0) return;
        if (smallDaoArr.length == 0) {
            _balances[address(0)] = _balances[address(0)].add(amount);
            emit Transfer(sender, address(0), amount);
            return;
        }
        //平均没人分红
        uint256 div = amount.div(smallDaoArr.length);
        for (uint i = 0; i < smallDaoArr.length; i++) {
            address addr = smallDaoArr[i];
            _balances[addr] = _balances[addr].add(div);
            emit Transfer(sender, addr, div);
            emit BalanceEvent(addr, _balances[addr]);
            _verifyTenThousand(addr);
        }
    }

    //万分之一  分 usdt
    function _dividendTenThousand(address sender, uint256 amount) private {
        if (amount == 0) return;
        _balances[address(0)] = _balances[address(0)].add(amount);
        emit Transfer(sender, address(0), amount);

        if (tenThousandArr.length == 0) {
            return;
        }
        //平均没人分红
        uint256 div = amount.div(wlbUsdt).div(tenThousandArr.length);
        for (uint i = 0; i < tenThousandArr.length; i++) {
            address addr = tenThousandArr[i];
            if (IBEP40(usdtAddress).balanceOf(address(this)) > div) {
                IBEP40(usdtAddress).transfer(addr, div);
            } else IBEP40(usdtAddress).transfer(addr, 0);
        }
    }

    //万分之一 动态分润
    function _dividendTenThousandDynamic(address sender, uint256 amount)
        private
    {
        if (amount == 0) return;

        _balances[tenThousandDynamicAddr] = _balances[tenThousandDynamicAddr]
            .add(amount);
        emit Transfer(sender, tenThousandDynamicAddr, amount);
        emit BalanceEvent(
            tenThousandDynamicAddr,
            _balances[tenThousandDynamicAddr]
        );
    }

    //流动池
    function _dividendLp(address sender, uint256 amount) private {
        if (amount == 0) return;
        _balances[lpFeeAddr] = _balances[lpFeeAddr].add(amount);
        emit Transfer(sender, lpFeeAddr, amount);
        emit BalanceEvent(lpFeeAddr, _balances[lpFeeAddr]);
    }

    //平台分红
    function _dividendPlatform(address sender, uint256 amount) private {
        if (amount == 0) return;
        _balances[platformFeeAddr] = _balances[platformFeeAddr].add(amount);
        emit Transfer(sender, platformFeeAddr, amount);
        emit BalanceEvent(platformFeeAddr, _balances[platformFeeAddr]);
    }

    /**
     * 验证 买一 卖5
     */
    function _verifySell(address sender, uint256 amount) internal {
        uint256 sell = sellAmount[sender];
        //没有卖出条件
        require(sell >= amount, "WLB: Buy one sell five conditions");
        sellAmount[sender] = sellAmount[sender].sub(amount);
        emit BuySellEvent(sender, 1, sellAmount[sender]);
    }

    /**
     * 追加买入金额
     */
    function _setBuy(address sender, uint256 amount) internal {
        uint256 newAmount = amount.mul(5);
        sellAmount[sender] = sellAmount[sender].add(newAmount);

        emit BuySellEvent(sender, 0, sellAmount[sender]);
    }

    function _wlbToUsdt(uint256 amount) internal view returns (uint256) {
        return amount.mul(wlbUsdt).div(10**18);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () { }

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
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
import "./Context.sol";

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IBEP40 {
    /**
     * @dev Returns the amount of tokens in existence.
   */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
   */
    function decimals() external view returns (uint256);

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
   * a call to {approve}. `value` is the new allowance.
   */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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
   * - Addition cannot overflow.
   */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
        require(c / a == b, "SafeMath: multiplication overflow");

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
   * - The divisor cannot be zero.
   */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
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
   * - The divisor cannot be zero.
   */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
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
   * - The divisor cannot be zero.
   */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
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
   * - The divisor cannot be zero.
   */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract CustomBEP40 {

    mapping(address => uint256) internal _balances;

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
   * another (`to`).
   *
   * Note that `value` may be zero.
   */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
    * 买一卖5事件 , tye=0 买  , tye=1 卖
    */
    event BuySellEvent(address indexed sender, uint tye, uint256 value);

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../interface/IUniswapV2Factory.sol";
import "../interface/IUniswapV2Pair.sol";
import "../interface/IUniswapV2Router01.sol";
import "../interface/IUniswapV2Router02.sol";
import "./WLBConfig.sol";

abstract contract WLBSwap is WLBConfig {
    address public  uniswapV2Pair;
    IUniswapV2Router02 public immutable uniswapV2Router;
    //其他币种的交易对
    mapping(address => bool) public pairs;

    constructor() {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            swapRouterAddress
        );
        // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(this), usdtAddress);
        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;
        pairs[uniswapV2Pair] = true;
    }

    /**
     * 设置交易对,
     * 不是本平台的交易对
     */
    function setPairs(address pair, bool status) public onlyOwner {
        pairs[pair] = status;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
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

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
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

    function mint(address to) external returns (uint256 liquidity);

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

import "../libs/SafeMath.sol";
import "../libs/Ownable.sol";

contract WLBConfig is Ownable {
    using SafeMath for uint256;

    //黑名单地址
    mapping(address => bool) internal _marketList;

    //测试网络  BUSDT 0x337610d27c682E347C9cD60BD4b3b107C9d34dDd
    //正式网  BUSDT 0x55d398326f99059fF775485246999027B3197955
    address public usdtAddress = 0x337610d27c682E347C9cD60BD4b3b107C9d34dDd;
    //正式网 0x10ED43C718714eb63d5aA57B78B54704E256024E
    //测试网 0xD99D1c33F9fC3444f8101754aBC46c52416550D1
    address public swapRouterAddress =
        0xD99D1c33F9fC3444f8101754aBC46c52416550D1;

    //大道主用户
    address[] internal bigDaoArr;
    mapping(address => bool) internal mapBigDaoArr;

    //小道主 用户
    address[] internal smallDaoArr;
    mapping(address => bool) internal mapSmallDaoArr;

    //万分之 持币者
    address[] internal tenThousandArr;
    mapping(address => bool) internal mapTenThousandArr;

    //大道主手续费
    uint256 public bigDaoFee = 800;
    //小Dao 收费
    uint256 public smallDaoFee = 2000;
    //万分之一
    uint256 public tenThousand = 2000;
    //万分之动态分润
    uint256 public tenThousandDynamic = 2400;
    //池子费率
    uint256 public lpFee = 1200;
    //平台费率
    uint256 public platformFee = 1600;

    //万分之动态分润
    address public tenThousandDynamicAddr =
        0x96C5D20b2a975c050e4220BE276ACe4892f4b41A;
    //池子费率
    address public lpFeeAddr = 0x61E7C0dA429eD878Aa02cbe55E21A5d1d61dBa1a;
    //平台费率
    address public platformFeeAddr = 0x2cb78F0f545b3e5A265b86700344FefBBEB12b1c;

    //记录用户允许卖出最大金额
    mapping(address => uint256) public sellAmount;

    //wlb 兑U 汇率
    uint256 public wlbUsdt = 360000000000000;

    constructor() {}

    function bigDaoStatus(address addr) public view returns (bool) {
        return mapBigDaoArr[addr];
    }

    function smallDaoStatus(address addr) public view returns (bool) {
        return mapSmallDaoArr[addr];
    }

    function tenThousandStatus(address addr) public view returns (bool) {
        return mapTenThousandArr[addr];
    }

    //设置wlb对U的价格
    function setWlbRate(uint256 wlbRate_) public onlyOwner returns (bool) {
        wlbUsdt = wlbRate_;
        return true;
    }

    function setLpFee(uint256 fee) public onlyOwner returns (bool) {
        lpFee = fee;
        return true;
    }

    function setBigDaoFee(uint256 fee) public onlyOwner returns (bool) {
        bigDaoFee = fee;
        return true;
    }

    function setSmallDaoFee(uint256 fee) public onlyOwner returns (bool) {
        smallDaoFee = fee;
        return true;
    }

    function setTenThousandFee(uint256 fee) public onlyOwner returns (bool) {
        tenThousand = fee;
        return true;
    }

    function setTenThousandDynamicFee(uint256 fee)
        public
        onlyOwner
        returns (bool)
    {
        tenThousandDynamic = fee;
        return true;
    }

    function setPlatformFee(uint256 fee) public onlyOwner returns (bool) {
        platformFee = fee;
        return true;
    }



    function deleteBigDao(address big) public onlyOwner returns (bool) {
        if (bigDaoArr.length < 1) return false;
        address[] memory array;
        uint j = 0;
        for (uint i = 0; i < bigDaoArr.length; i++) {
            if (bigDaoArr[i] != big) {
                array[j] = bigDaoArr[i];
                j++;
            }
        }
        mapBigDaoArr[big] = false;
        bigDaoArr = array;
        return true;
    }

    function deleteSmallDao(address small) public onlyOwner returns (bool) {
        if (smallDaoArr.length < 1) return false;
        address[] memory array;
        uint j = 0;
        for (uint i = 0; i < smallDaoArr.length; i++) {
            if (smallDaoArr[i] != small) {
                array[j] = smallDaoArr[i];
                j++;
            }
        }
        mapSmallDaoArr[small] = false;
        smallDaoArr = array;
        return true;
    }

    function deleteTenThousand(address addr) public onlyOwner returns (bool) {
        _removeTenThousand(addr);
        return true;
    }

    function addBigDao(address addr) public onlyOwner returns (bool) {
        bigDaoArr.push(addr);
        mapBigDaoArr[addr] = true;
        deleteSmallDao(addr);
        return true;
    }

    function addSmallDao(address addr) public onlyOwner returns (bool) {
        smallDaoArr.push(addr);
        mapSmallDaoArr[addr] = true;
        return true;
    }

    /**
     * 删除万分之一用户
     * 所有者调用
     */
    function addTenThousand(address addr) public onlyOwner returns (bool) {
        _addTenThousand(addr);
        return true;
    }

    /**
     * 删除万分之一用户
     * 内部调用
     */
    function _removeTenThousand(address addr) internal {
        if (tenThousandArr.length < 1) return;
        address[] memory array;
        uint j = 0;
        for (uint i = 0; i < tenThousandArr.length; i++) {
            if (tenThousandArr[i] != addr) {
                array[j] = tenThousandArr[i];
                j++;
            }
        }
        mapTenThousandArr[addr] = false;
        tenThousandArr = array;
    }

    /**
     * 添加万分之一用户
     * 内部调用
     */
    function _addTenThousand(address addr) internal {
        tenThousandArr.push(addr);
        mapTenThousandArr[addr] = true;
    }

    function setBigDao(address[] memory addr) public onlyOwner returns (bool) {
        for (uint i = 0; i < bigDaoArr.length; i++) {
            mapBigDaoArr[bigDaoArr[i]] = false;
        }
        bigDaoArr = addr;
        for (uint i = 0; i < bigDaoArr.length; i++) {
            mapBigDaoArr[bigDaoArr[i]] = true;
        }
        return true;
    }

    function setSmallDao(address[] memory addr)
        public
        onlyOwner
        returns (bool)
    {
        for (uint i = 0; i < smallDaoArr.length; i++) {
            mapSmallDaoArr[smallDaoArr[i]] = false;
        }
        smallDaoArr = addr;
        for (uint i = 0; i < smallDaoArr.length; i++) {
            mapSmallDaoArr[smallDaoArr[i]] = true;
        }
        return true;
    }

    function setTenThousand(address[] memory addr)
        public
        onlyOwner
        returns (bool)
    {
        for (uint i = 0; i < tenThousandArr.length; i++) {
            mapTenThousandArr[tenThousandArr[i]] = false;
        }
        tenThousandArr = addr;
        for (uint i = 0; i < tenThousandArr.length; i++) {
            mapTenThousandArr[tenThousandArr[i]] = true;
        }
        return true;
    }
}