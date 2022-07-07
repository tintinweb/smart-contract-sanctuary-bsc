// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import "./library/PancakeLibrary.sol";
import "./interface/IPancakeRouter.sol";
import "./interface/IPancakePair.sol";
import "./interface/IMocDAO.sol";

contract Moc is IERC20, IERC20Metadata, Ownable {
    using Address for address;
    using BitMaps for BitMaps.BitMap;

    event Rebase(
        uint24 indexed period,
        uint256 hasInterest,
        uint256 noInterest,
        uint256 total
    );

    event Fee(address indexed from, address indexed to, uint256 amount);

    address private constant ROUTER_ADDRESS =
        0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address private constant USDT_ADDRESS =
        0x55d398326f99059fF775485246999027B3197955;

    uint256 public constant PERIOD = 12 hours;

    uint256 public constant RATE = 1017;

    uint256 public constant THRESHOLD = 1000 * 1e6;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    address public sellExiAddress = address(2);

    address public sellEaiAddress = address(3);

    address public sellTreaturyAddress = address(4);

    address public buyExiAddress = address(5);

    address public buyMocAddress = address(6);

    uint256 public initTimestamp;

    IMocDAO public mocDAO;

    address public ex;

    address public pair;

    address public receiver;

    uint256 public lastNoInterest;

    uint24 public lastRebasePeriod;

    mapping(address => uint24) public lastPeriodPerAccount;

    BitMaps.BitMap private sellWhitelist;

    BitMaps.BitMap private buyWhitelist;

    constructor(address _receiver, address mocDAOAddress) {
        _name = "macroeconomics";
        _symbol = "MOC";
        initTimestamp = block.timestamp;
        mocDAO = IMocDAO(mocDAOAddress);
        pair = PancakeLibrary.pairFor(
            IPancakeRouter(ROUTER_ADDRESS).factory(),
            address(this),
            USDT_ADDRESS
        );
        uint256 amount = 59900000 * 10**decimals();
        receiver = _receiver;
        _mint(receiver, amount);
        addBuyWhitelist(receiver);
        addSellWhitelist(receiver);
    }

    function addSellWhitelist(address adr) public onlyOwner {
        sellWhitelist.set(uint256(uint160(adr)));
    }

    function removeSellWhitelist(address adr) public onlyOwner {
        sellWhitelist.unset(uint256(uint160(adr)));
    }

    function getSellWhitelist(address adr) public view returns (bool) {
        return sellWhitelist.get(uint256(uint160(adr)));
    }

    function addBuyWhitelist(address adr) public onlyOwner {
        buyWhitelist.set(uint256(uint160(adr)));
    }

    function removeBuyWhitelist(address adr) public onlyOwner {
        buyWhitelist.unset(uint256(uint160(adr)));
    }

    function getBuyWhitelist(address adr) public view returns (bool) {
        return buyWhitelist.get(uint256(uint160(adr)));
    }

    function setEx(address _ex) external onlyOwner {
        ex = _ex;
    }

    function setSellExiAddress(address adr) external onlyOwner {
        sellExiAddress = adr;
        addBuyWhitelist(adr);
        addSellWhitelist(adr);
    }

    function setSellEaiAddress(address adr) external onlyOwner {
        sellEaiAddress = adr;
        addBuyWhitelist(adr);
        addSellWhitelist(adr);
    }

    function setSellTreaturyAddress(address adr) external onlyOwner {
        sellTreaturyAddress = adr;
        addBuyWhitelist(adr);
        addSellWhitelist(adr);
    }

    function setBuyExiAddress(address adr) external onlyOwner {
        buyExiAddress = adr;
        addBuyWhitelist(adr);
        addSellWhitelist(adr);
    }

    function setBuyMocAddress(address adr) external onlyOwner {
        buyMocAddress = adr;
        addBuyWhitelist(adr);
        addSellWhitelist(adr);
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 6;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return getTotalSupply(getCurrentPriold());
    }

    function calc(uint256 balance, uint24 n) private pure returns (uint256) {
        for (uint24 i = 0; i < n; ++i) {
            balance = (balance * RATE) / 1000;
        }
        return balance;
    }

    function getCurrentPriold() private view returns (uint24) {
        return uint24((block.timestamp - initTimestamp) / PERIOD);
    }

    function canInterest(address adr) private view returns (bool) {
        if (adr.isContract() || adr == address(0) || adr == receiver) {
            return false;
        }
        return true;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        uint256 balance = _balances[account];
        if (
            canInterest(account) &&
            balance >= THRESHOLD &&
            mocDAO.balanceOf(account) >= 1e6
        ) {
            return
                calc(
                    balance,
                    getCurrentPriold() - lastPeriodPerAccount[account]
                );
        }
        return balance;
    }

    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
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
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

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

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function updateAccount(
        uint24 currentPeriod,
        uint24 lastPeriod,
        address user,
        uint256 oldBalance,
        uint256 newBalance
    ) private {
        if (currentPeriod > lastPeriod) {
            lastPeriodPerAccount[user] = currentPeriod;
        }
        if (canInterest(user)) {
            if (newBalance < THRESHOLD || mocDAO.balanceOf(user) < 1e6) {
                if (oldBalance < THRESHOLD || mocDAO.balanceOf(user) < 1e6) {
                    lastNoInterest = lastNoInterest - oldBalance + newBalance;
                } else {
                    lastNoInterest += newBalance;
                }
            } else if (oldBalance < THRESHOLD) {
                lastNoInterest -= oldBalance;
            }
        } else {
            lastNoInterest = lastNoInterest - oldBalance + newBalance;
        }
    }

    function updateDAOAccount(
        address user,
        uint256 oldBalance,
        uint256 newBalance,
        uint256 mocBalance
    ) external {
        require(msg.sender == address(mocDAO), "not allowed call");
        if (canInterest(user)) {
            if (mocBalance >= THRESHOLD) {
                if (oldBalance < 1e6 && newBalance >= 1e6) {
                    uint24 currentPeriod = rebase();
                    _balances[user] = mocBalance;
                    uint24 lastPeriod = lastPeriodPerAccount[user];
                    if (currentPeriod > lastPeriod) {
                        lastPeriodPerAccount[user] = currentPeriod;
                    }
                    lastNoInterest -= mocBalance;
                } else if (oldBalance >= 1e6 && newBalance < 1e6) {
                    uint24 currentPeriod = rebase();
                    _balances[user] = mocBalance;
                    uint24 lastPeriod = lastPeriodPerAccount[user];
                    if (currentPeriod > lastPeriod) {
                        lastPeriodPerAccount[user] = currentPeriod;
                    }
                    lastNoInterest += mocBalance;
                }
            }
        }
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        uint24 currentPeriod = rebase();
        uint256 oldB = _balances[from];
        uint256 fromBalance = balanceOf(from);
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        uint256 newB;
        unchecked {
            newB = fromBalance - amount;
            _balances[from] = newB;
        }
        updateAccount(
            currentPeriod,
            lastPeriodPerAccount[from],
            from,
            oldB,
            newB
        );

        uint256 subAmount;
        if (from != pair && to != pair && from != ex && to != ex) {
            subAmount = (amount * 15) / 100;
            _balances[address(0)] += subAmount;
            lastNoInterest += subAmount;
            emit Transfer(from, address(0), subAmount);
        }
        if (to == pair && !sellWhitelist.get(uint256(uint160(from)))) {
            (uint112 r0, uint112 r1, ) = IPancakePair(pair).getReserves();
            uint256 amountA;
            if (r0 > 0 && r1 > 0) {
                amountA = IPancakeRouter(ROUTER_ADDRESS).quote(amount, r1, r0);
            }
            uint256 balanceA = IERC20(USDT_ADDRESS).balanceOf(pair);
            if (balanceA < r0 + amountA) {
                uint256 amount50 = (amount * 50) / 1000;

                oldB = _balances[sellExiAddress];
                newB = balanceOf(sellExiAddress) + amount50;
                _balances[sellExiAddress] = newB;
                updateAccount(
                    currentPeriod,
                    lastPeriodPerAccount[sellExiAddress],
                    sellExiAddress,
                    oldB,
                    newB
                );
                emit Fee(from, sellExiAddress, amount50);

                oldB = _balances[sellEaiAddress];
                newB = balanceOf(sellEaiAddress) + amount50;
                _balances[sellEaiAddress] = newB;
                updateAccount(
                    currentPeriod,
                    lastPeriodPerAccount[sellEaiAddress],
                    sellEaiAddress,
                    oldB,
                    newB
                );
                emit Fee(from, sellEaiAddress, amount50);
                uint256 amount25 = (amount * 25) / 1000;

                _balances[address(0)] += amount25;
                lastNoInterest += amount25;
                emit Fee(from, address(0), amount25);

                oldB = _balances[sellTreaturyAddress];
                newB = balanceOf(sellTreaturyAddress) + amount25;
                _balances[sellTreaturyAddress] = newB;
                updateAccount(
                    currentPeriod,
                    lastPeriodPerAccount[sellTreaturyAddress],
                    sellTreaturyAddress,
                    oldB,
                    newB
                );
                emit Fee(from, sellTreaturyAddress, amount25);
                subAmount = amount50 + amount50 + amount25 + amount25;
            }
        }
        if (from == pair && !buyWhitelist.get(uint256(uint160(to)))) {
            (uint112 r0, uint112 r1, ) = IPancakePair(pair).getReserves();
            uint256 amountA;
            if (r0 > 0 && r1 > 0) {
                amountA = IPancakeRouter(ROUTER_ADDRESS).getAmountIn(
                    amount,
                    r0,
                    r1
                );
            }
            uint256 balanceA = IERC20(USDT_ADDRESS).balanceOf(pair);
            if (balanceA >= r0 + amountA) {
                uint256 amount50 = (amount * 50) / 1000;

                oldB = _balances[buyExiAddress];
                newB = balanceOf(buyExiAddress) + amount50;
                _balances[buyExiAddress] = newB;
                updateAccount(
                    currentPeriod,
                    lastPeriodPerAccount[buyExiAddress],
                    buyExiAddress,
                    oldB,
                    newB
                );
                emit Fee(from, buyExiAddress, amount50);

                marketReward(from, to, currentPeriod, amount, amount50);

                oldB = _balances[buyMocAddress];
                newB = balanceOf(buyMocAddress) + amount50;
                _balances[buyMocAddress] = newB;
                updateAccount(
                    currentPeriod,
                    lastPeriodPerAccount[buyMocAddress],
                    buyMocAddress,
                    oldB,
                    newB
                );
                emit Fee(from, buyMocAddress, amount50);
                subAmount = amount50 + amount50 + amount50;
            }
        }

        oldB = _balances[to];
        uint256 toAmount = amount - subAmount;
        newB = balanceOf(to) + toAmount;
        _balances[to] = newB;
        updateAccount(currentPeriod, lastPeriodPerAccount[to], to, oldB, newB);

        emit Transfer(from, to, toAmount);
    }

    function marketReward(
        address from,
        address to,
        uint24 currentPeriod,
        uint256 amount,
        uint256 restAmount
    ) private {
        address p = mocDAO.parents(to);
        uint256 oldB;
        uint256 newB;
        for (uint256 i = 1; i <= 10 && p != address(0); ++i) {
            uint256 pAmount;
            if (i == 1) {
                pAmount = (amount * 9) / 1000;
            } else if (i == 2) {
                pAmount = (amount * 7) / 1000;
            } else if (i == 3) {
                pAmount = (amount * 5) / 1000;
            } else if (i == 4) {
                pAmount = (amount * 3) / 1000;
            } else if (i == 5) {
                pAmount = amount / 1000;
            } else if (i == 6) {
                pAmount = amount / 1000;
            } else if (i == 7) {
                pAmount = (amount * 3) / 1000;
            } else if (i == 8) {
                pAmount = (amount * 5) / 1000;
            } else if (i == 9) {
                pAmount = (amount * 7) / 1000;
            } else {
                pAmount = restAmount;
            }
            oldB = _balances[p];
            newB = balanceOf(p) + pAmount;
            _balances[p] = newB;
            updateAccount(
                currentPeriod,
                lastPeriodPerAccount[p],
                p,
                oldB,
                newB
            );
            emit Fee(from, p, pAmount);
            restAmount -= pAmount;
            p = mocDAO.parents(p);
        }
        if (restAmount > 0) {
            _balances[address(0)] += restAmount;
            lastNoInterest += restAmount;
            emit Fee(from, address(0), restAmount);
        }
    }

    function getTotalSupply(uint24 currentPeriod)
        private
        view
        returns (uint256)
    {
        uint256 total = _totalSupply;
        uint256 noInterest = lastNoInterest;
        for (uint24 i = lastRebasePeriod; i < currentPeriod; ++i) {
            total = ((total - noInterest) * RATE) / 1000 + noInterest;
        }
        return total;
    }

    function rebase() public returns (uint24) {
        uint24 currentPeriod = getCurrentPriold();
        if (currentPeriod <= lastRebasePeriod) {
            return currentPeriod;
        }
        uint256 total = _totalSupply;
        uint256 noInterest = lastNoInterest;
        for (uint24 i = lastRebasePeriod; i < currentPeriod; ++i) {
            uint256 hasInterest = total - noInterest;
            total = (hasInterest * RATE) / 1000 + noInterest;
            emit Rebase(i, hasInterest, noInterest, total);
        }
        _totalSupply = total;
        lastRebasePeriod = currentPeriod;
        return currentPeriod;
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        uint24 currentPeriod = rebase();
        _totalSupply += amount;
        uint256 balance = balanceOf(account);
        uint256 newBalance = balance + amount;
        _balances[account] = newBalance;
        updateAccount(
            currentPeriod,
            lastPeriodPerAccount[account],
            account,
            balance,
            newBalance
        );

        emit Transfer(address(0), account, amount);
    }

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

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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
// OpenZeppelin Contracts v4.4.1 (utils/structs/BitMaps.sol)
pragma solidity ^0.8.0;

/**
 * @dev Library for managing uint256 to bool mapping in a compact and efficient way, providing the keys are sequential.
 * Largelly inspired by Uniswap's https://github.com/Uniswap/merkle-distributor/blob/master/contracts/MerkleDistributor.sol[merkle-distributor].
 */
library BitMaps {
    struct BitMap {
        mapping(uint256 => uint256) _data;
    }

    /**
     * @dev Returns whether the bit at `index` is set.
     */
    function get(BitMap storage bitmap, uint256 index) internal view returns (bool) {
        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        return bitmap._data[bucket] & mask != 0;
    }

    /**
     * @dev Sets the bit at `index` to the boolean `value`.
     */
    function setTo(
        BitMap storage bitmap,
        uint256 index,
        bool value
    ) internal {
        if (value) {
            set(bitmap, index);
        } else {
            unset(bitmap, index);
        }
    }

    /**
     * @dev Sets the bit at `index`.
     */
    function set(BitMap storage bitmap, uint256 index) internal {
        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        bitmap._data[bucket] |= mask;
    }

    /**
     * @dev Unsets the bit at `index`.
     */
    function unset(BitMap storage bitmap, uint256 index) internal {
        uint256 bucket = index >> 8;
        uint256 mask = 1 << (index & 0xff);
        bitmap._data[bucket] &= ~mask;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library PancakeLibrary {
    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'PancakeLibrary: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'PancakeLibrary: ZERO_ADDRESS');
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint160(uint(keccak256(abi.encodePacked(
                hex"ff",
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5'   //mainnet
            )))));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPancakeRouter {
    function factory() external pure returns (address);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IMocDAO is IERC20 {
    function parents(address user) external view returns(address);
    function root() external view returns(address);
}