// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IUserRegistry.sol";
import "./interfaces/IUniswapV2Factory.sol";
import "./interfaces/IPancakeRouter02.sol";

import "./MiningToken.sol";
import "./RewardTokenContract.sol";

contract DET is IERC20, IERC20Metadata, Ownable, MiningToken {
    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    mapping(address => mapping(address => uint256)) private _allowances;

    string private _name = "Destiny";
    string private _symbol = "DET";

    mapping(address => bool) private _shareExclude;

    mapping(address => bool) private _isExcludedFromFee;

    IPancakeRouter02 public  uniswapV2Router;
    address public uniswapV2Pair;

    address public daoAddress;
    address public devAddress;
    address public minerAddress;

    IUserRegistry userRegistry;

    RewardTokenContract rtc;

    constructor(
        address routerAddress,
        address usdtAddress,
        address daoAddress_,
        address devAddress_,
        address minerAddress_,
        IUserRegistry userRegistry_
    ) {
        daoAddress = daoAddress_;
        devAddress = devAddress_;
        minerAddress = minerAddress_;

        uniswapV2Router = IPancakeRouter02(routerAddress);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), usdtAddress);

        userRegistry = userRegistry_;

        rtc = new RewardTokenContract(address(this), usdtAddress, routerAddress);

        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[BURN_ADDRESS] = true;
        _isExcludedFromFee[address(rtc)] = true;
        _shareExclude[address(this)] = true;
        _shareExclude[uniswapV2Pair] = true;
        _shareExclude[BURN_ADDRESS] = true;
        _shareExclude[address(rtc)] = true;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override(MiningToken, IERC20) returns (uint256) {
        return MiningToken.totalSupply();
    }

    function balanceOf(address account) public view virtual override(MiningToken, IERC20) returns (uint256) {
        return MiningToken.balanceOf(account);
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function setExcludedFromFee(address account, bool state) external onlyOwner {
        _isExcludedFromFee[account] = state;
    }

    function setShareExclude(address account, bool state) external onlyOwner {
        _shareExclude[account] = state;
    }

    function setMinerAddress(address account) external onlyOwner {
        minerAddress = account;
    }

    function setDaoAddress(address account) external onlyOwner {
        daoAddress = account;
    }

    function setDevAddress(address account) external onlyOwner {
        devAddress = account;
    }

    function startMining() external onlyOwner {
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = msg.sender;
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function mint(address account, uint256 amount) external {
        require(msg.sender == minerAddress, "only miners call");
        _mint(account, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        updateMining();

        if (from != uniswapV2Pair) {
            rtc.checkSwap();
        }
        rtc.share();

        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            _tokenTransfer(from, to, amount);
        } else {
            if(from == uniswapV2Pair){
                _tokenTransferBuy(from, to, amount);
            } else if (to == uniswapV2Pair) {
                _tokenTransferSell(from, to, amount);
            } else {
                _tokenTransfer(from, to, amount);
            }
        }
    }

    function _tokenTransferBuy(
        address from,
        address to,
        uint256 amount
    ) private {
        uint256 fee1 = amount * 3 / 100;
        uint256 fee2 = amount * 1 / 100;
        uint256 fee3 = amount * 6 / 100;
        _tokenTransfer(from, to, amount - fee1 - fee2);

        _tokenTransfer(from, address(rtc), fee1);
        _tokenTransfer(from, daoAddress, fee2);

        _tokenTransferRecommender(to, fee3);
    }

    function _tokenTransferRecommender(address account, uint256 amount) private {
        uint8 steps = 10;
        address _recommender = userRegistry.recommender(account);

        uint256 leftAmount = amount;
        while (steps > 0) {
            uint256 a;
            if (steps == 10) {
                a = amount * 2 / 6;
            } else if (steps == 9) {
                a = amount * 1 / 6;
            } else if (steps > 5) {
                a = amount * 5 / 60;
            } else {
                a = amount * 3 / 60;
            }
            a = a > leftAmount ? leftAmount : a;
            if (_recommender != address(0)) {
                _tokenTransfer(account, _recommender, a);
                leftAmount -= a;
            }
            _recommender = userRegistry.recommender(_recommender);
            steps--;
        }

        if (leftAmount > 0) {
            _tokenTransfer(account, daoAddress, leftAmount);
        }
    }

    function _tokenTransferSell(
        address from,
        address to,
        uint256 amount
    ) private {
        uint256 fee1 = amount * 6 / 100;
        uint256 fee2 = amount * 2 / 100;
        uint256 fee3 = amount * 2 / 100;
        _tokenTransfer(from, to, amount - fee1 - fee2 - fee3);

        _tokenTransfer(from, address(rtc), fee1);
        _tokenTransfer(from, daoAddress, fee2);
        _tokenTransfer(from, devAddress, fee3);
    }

    function _tokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        super._tokenTransfer(from, to, amount);
        emit Transfer(from, to, amount);

        updateShare(from);
        updateShare(to);
    }

    function _mint(address account, uint256 amount) internal override {
        require(account != address(0), "ERC20: mint to the zero address");
        require(!miningStarted, "already start mining");

        super._mint(account, amount);

        emit Transfer(address(0), account, amount);

        miningStarted = true;
        start();
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
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function updateShare(address shareholder) private {
        if (_shareExclude[shareholder]) return;

        if(rtc.shared(shareholder)){
            if(balanceOf(shareholder) < totalSupply() / 1000) rtc.removeShareholder(shareholder);
            return;
        }

        if(balanceOf(shareholder) < totalSupply() / 1000) return;

        rtc.addShareholder(shareholder);
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

pragma solidity ^0.8.6;

interface IUserRegistry {
    function recommender(address account) external view returns (address);

    function childrenLength(address account) external view returns (uint256);

    function children(address account) external view returns (address[] calldata);

    function childrenPaged(address account, uint256 from, uint256 length) external view returns (address[] calldata);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./IPancakeRouter01.sol";

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./Epoch.sol";

contract MiningToken is Epoch {
    bool public miningStarted;

    mapping(address => uint256) private _balances;

    uint256 private _initialSupply;
    uint256 private _totalSupplyEpoch;
    uint256 private _totalSupplyBlock;

    function initialSupply() public view returns (uint256) {
        return _initialSupply;
    }

    function totalSupply() public view virtual returns (uint256) {
        if (!miningStarted) return _initialSupply;

        uint256 _currentEpoch = currentEpoch();

        uint256 amount = _totalSupplyEpoch;
        for (uint256 i = lastEpoch; i < _currentEpoch; i++) {
            amount += amount * getMultiplyByEpoch(i) / MULTIPLY;
        }

        uint256 epochTotal = amount * getMultiplyByEpoch(_currentEpoch) / MULTIPLY;
        return amount + epochTotal * (block.number - currentEpochBlock()) / EPOCH_PERIOD;
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        if (!miningStarted) return _balances[account];

        return _balances[account] * totalSupply() / _initialSupply;
    }

    function _mint(address account, uint256 amount) internal virtual {
        _initialSupply += amount;
        _totalSupplyEpoch += amount;
        _totalSupplyBlock += amount;
        _balances[account] += amount;
    }

    function _tokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        uint256 initialAmount = amount * _initialSupply / _totalSupplyBlock;

        uint256 fromBalance = _balances[from];
        require(fromBalance >= initialAmount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - initialAmount;
        }

        _balances[to] += initialAmount;
    }

    function updateMining() internal {
        uint256 _currentEpoch = currentEpoch();

        uint256 amount = _totalSupplyEpoch;
        for (uint256 i = lastEpoch; i < _currentEpoch; i++) {
            amount += amount * getMultiplyByEpoch(i) / MULTIPLY;
        }

        _totalSupplyEpoch = amount;

        uint256 epochTotal = amount * getMultiplyByEpoch(_currentEpoch) / MULTIPLY;
        amount += epochTotal * (block.number - currentEpochBlock()) / EPOCH_PERIOD;

        _totalSupplyBlock = amount;

        updateEpoch();
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "./interfaces/IPancakeRouter02.sol";

contract RewardTokenContract is Ownable {
    IERC20 token;
    IERC20 usdt;
    IPancakeRouter02 router;

    bool swapping;
    bool sharing;

    address[] public shareholders;
    mapping(address => bool) public shared;
    mapping(address => uint256) public shareholderIndexes;
    uint256 sharingIndex;

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 usdtReceived,
        uint256 tokensIntoLiqudity
    );

    constructor(address _token, address _usdt, address _router) {
        token = IERC20(_token);
        usdt = IERC20(_usdt);
        router = IPancakeRouter02(_router);
    }

    function checkSwap() external onlyOwner {
        if (swapping) {
            return;
        }

        swapping = true;

        uint256 tokenBalance = token.balanceOf(address(this));

        if (tokenBalance >= 5000 * 10*18) {
            uint256 forUBalance = tokenBalance * 2 / 7;
            swapTokensForUsdt(forUBalance);
            swapAndLiquify(tokenBalance - forUBalance);
        }

        swapping = false;
    }

    function share() external onlyOwner {
        if (sharing) {
            return;
        }

        sharing = true;

        uint256 usdtBalance = usdt.balanceOf(address(this));

        if (usdtBalance >= 10 * 10*18) {
            if (sharingIndex >= shareholders.length) sharingIndex = 0;

            for (; sharingIndex < Math.min(shareholders.length, sharingIndex + 5); sharingIndex++) {
                usdt.transfer(shareholders[sharingIndex], usdtBalance / shareholders.length);
            }
        }

        sharing = false;
    }

    function addShareholder(address shareholder) public onlyOwner {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
        shared[shareholder] = true;
    }
    function removeShareholder(address shareholder) public onlyOwner {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
        shared[shareholder] = false;
    }

    function swapAndLiquify(uint256 contractTokenBalance) private {
        // split the contract balance into halves
        uint256 half = contractTokenBalance / 2;
        uint256 otherHalf = contractTokenBalance - half;

        // capture the contract's current USDT balance.
        // this is so that we can capture exactly the amount of USDT that the
        // swap creates, and not make the liquidity event include any USDT that
        // has been manually sent to the contract
        uint256 initialBalance = usdt.balanceOf(address(this));

        // swap tokens for USDT
        swapTokensForUsdt(half); // <- this breaks the USDT -> HATE swap when swap+liquify is triggered

        // how much USDT did we just swap into?
        uint256 newBalance = usdt.balanceOf(address(this)) - initialBalance;

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForUsdt(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> usdt
        address[] memory path = new address[](2);
        path[0] = address(token);
        path[1] = address(usdt);

        token.approve(address(router), tokenAmount);

        // make the swap
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of USDT
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 usdtAmount) private {
        // approve token transfer to cover all possible scenarios
        token.approve(address(router), tokenAmount);
        usdt.approve(address(router), usdtAmount);

        // add the liquidity
        router.addLiquidity(
            address(token),
            address(usdt),
            tokenAmount,
            usdtAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
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

pragma solidity ^0.8.6;

interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

contract Epoch {
    uint256 constant public EPOCH_PERIOD = 28800;

    uint256 constant public MULTIPLY = 1000000000;

    uint256 public lastEpoch;
    uint256 public lastEpochBlock;

    function start() internal {
        lastEpochBlock = block.number;
    }

    function updateEpoch() internal {
        uint256 epochCount = (block.number - lastEpochBlock) / EPOCH_PERIOD;
        lastEpoch += epochCount;
        lastEpochBlock += epochCount * EPOCH_PERIOD;
    }

    function getMultiplyByEpoch(uint256 epoch) public pure returns(uint256) {
        if (epoch < 218) {
            return 21300000;
        } else if (epoch < 654) {
            return 10650000;
        } else if (epoch < 1572) {
            return 5032500;
        } else {
            return 0;
        }
    }

    function currentEpoch() public view returns(uint256) {
        uint256 epochCount = (block.number - lastEpochBlock) / EPOCH_PERIOD;
        return lastEpoch + epochCount;
    }

    function currentEpochBlock() public view returns(uint256) {
        uint256 epochCount = (block.number - lastEpochBlock) / EPOCH_PERIOD;
        return lastEpochBlock + epochCount * EPOCH_PERIOD;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

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
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. It the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`.
        // We also know that `k`, the position of the most significant bit, is such that `msb(a) = 2**k`.
        // This gives `2**k < a <= 2**(k+1)` → `2**(k/2) <= sqrt(a) < 2 ** (k/2+1)`.
        // Using an algorithm similar to the msb conmputation, we are able to compute `result = 2**(k/2)` which is a
        // good first aproximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1;
        uint256 x = a;
        if (x >> 128 > 0) {
            x >>= 128;
            result <<= 64;
        }
        if (x >> 64 > 0) {
            x >>= 64;
            result <<= 32;
        }
        if (x >> 32 > 0) {
            x >>= 32;
            result <<= 16;
        }
        if (x >> 16 > 0) {
            x >>= 16;
            result <<= 8;
        }
        if (x >> 8 > 0) {
            x >>= 8;
            result <<= 4;
        }
        if (x >> 4 > 0) {
            x >>= 4;
            result <<= 2;
        }
        if (x >> 2 > 0) {
            result <<= 1;
        }

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        uint256 result = sqrt(a);
        if (rounding == Rounding.Up && result * result < a) {
            result += 1;
        }
        return result;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IPancakeRouter02.sol";
import "./UserRegistry.sol";

interface MintableToken is IERC20 {
    function mint(address account, uint256 amount) external;
}

contract TokenSeller is Ownable, UserRegistry {
    struct User {
        uint256 joinBalance; // usdt
        uint256 receiveBalance;
        uint256 inviteBalance; // usdt
        uint256 inviteTotal;

        bool isFounder;
        bool buy26;
        bool buy56;
        bool buy86;
    }

    uint256 public constant DET_PER_USDT = 100;
    address public constant BURN_ADDRESS = address(0x000000000000000000000000000000000000dEaD);

    IERC20 public det;
    MintableToken public detx;
    IERC20 public usdt;
    IPancakeRouter02 public router;

    mapping(address => User) public users;
    address public receiveAddr;
    uint256 public initialSupply;

    bool isStarted = true;

    event Buy(address indexed account, address indexed recommender, uint256 usdtAmount, uint256 detAmount);
    event Founder(address indexed account, address indexed recommender);
    event Claim(address indexed account, uint256 amount);

    constructor(IERC20 _usdt, IPancakeRouter02 _router, address _receiveAddr) {
        usdt = _usdt;
        router = _router;
        receiveAddr = _receiveAddr;
    }

    function setReceiveAddr(address account) external onlyOwner {
        receiveAddr = account;
    }

    function setStarted(bool state) external onlyOwner {
        isStarted = state;
    }

    function setDet(IERC20 addr) external onlyOwner {
        det = addr;
    }

    function setDetx(MintableToken addr) external onlyOwner {
        detx = addr;
    }

    function withdrawToken(IERC20 token, address receipt, uint256 amount) external onlyOwner {
        token.transfer(receipt, amount);
    }

    function buy(uint256 amount, address recommender_) external {
        require(isStarted, "Not started");
        if (amount == 26 * 10**18) {
            require(!users[msg.sender].buy26, "already buyed");
        } else if (amount == 56 * 10**18) {
            require(!users[msg.sender].buy56, "already buyed");
        } else if (amount == 86 * 10**18) {
            require(!users[msg.sender].buy86, "already buyed");
        } else {
            revert();
        }

        recommender_ = _join(msg.sender, recommender_);

        uint256 receiveAmount = _swapUsdt(msg.sender, amount);

        _updateRecommender(msg.sender, receiveAmount);

        emit Buy(msg.sender, recommender_, amount, receiveAmount);
    }

    function applyFounder(address recommender_) external {
        require(isStarted, "Not started");
        require(!users[msg.sender].isFounder, "already founder");
        users[msg.sender].isFounder = true;

        uint256 amount = 188 * 10**18;
        recommender_ = _join(msg.sender, recommender_);

        uint256 receiveAmount = _swapUsdt(msg.sender, amount);

        _updateRecommender(msg.sender, receiveAmount);

        emit Founder(msg.sender, recommender_);
    }

    function claim() external {
        require(!isStarted, "require end");

        uint256 receiveBalance = users[msg.sender].receiveBalance;
        uint256 inviteBalance = users[msg.sender].inviteBalance;
        users[msg.sender].receiveBalance = 0;
        users[msg.sender].inviteBalance = 0;

        det.transfer(msg.sender, receiveBalance + inviteBalance);

        emit Claim(msg.sender, receiveBalance + inviteBalance);
    }

    function swapDetx(uint256 amount) external {
        det.transferFrom(msg.sender, BURN_ADDRESS, amount);
        detx.mint(msg.sender, amount);
    }

    function addLiquidity() external {
        require(!isStarted, "require end");
        uint256 usdtAmount = usdt.balanceOf(address(this));
        uint256 detAmount = usdtAmount * DET_PER_USDT;

        // approve token transfer to cover all possible scenarios
        det.approve(address(router), detAmount);
        usdt.approve(address(router), usdtAmount);

        // add the liquidity
        router.addLiquidity(
            address(det),
            address(usdt),
            detAmount,
            usdtAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
    }

    function _swapUsdt(address account, uint256 usdtAmount) private returns (uint256 detAmount) {
        detAmount = usdtAmount * DET_PER_USDT;

        User storage user = users[msg.sender];

        user.joinBalance += usdtAmount;
        user.receiveBalance += detAmount;
        uint256 toSwap = usdtAmount * 3 / 10;
        usdt.transferFrom(
            account,
            address(this),
            toSwap
        );
        usdt.transferFrom(
            account,
            receiveAddr,
            usdtAmount - toSwap
        );
        initialSupply += detAmount * 13 / 10;
    }

    function _updateRecommender(address account, uint256 amount) private {
        address recommender_ = _recommender[account];
        if (recommender_ == address(0)) return;
        User storage recommenderUser = users[recommender_];
        if (!recommenderUser.isFounder) return;

        recommenderUser.inviteBalance += amount / 10;
        recommenderUser.inviteTotal += amount;
        initialSupply += amount / 10;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./interfaces/IUserRegistry.sol";

contract UserRegistry is IUserRegistry {
    mapping(address => address) internal _recommender;
    mapping(address => address[]) internal _children;

    function recommender(address account) public override view returns (address) {
        return _recommender[account];
    }

    function childrenLength(address account) public override view returns (uint256) {
        return _children[account].length;
    }

    function children(address account) public override view returns (address[] memory) {
        return _children[account];
    }

    function childrenPaged(address account, uint256 from, uint256 length) public override view returns (address[] memory aa) {
        aa = new address[](length);
        uint256 j;
        for (uint256 i = from; i < from + length; i++) {
            aa[j++] = _children[account][i];
        }
    }

    function _join(address account, address recommender_) internal returns (address) {
        require(recommender_ != account, "recommender can not be your self");
        require(account.code.length + recommender_.code.length == 0, "stop! no contract");

        if (_recommender[account] == address(0) && _children[account].length == 0) {
            _recommender[account] = recommender_;
            _children[recommender_].push(account);
        }

        return _recommender[account];
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./UserRegistry.sol";

contract DETX is UserRegistry, IERC20, IERC20Metadata, Ownable {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name = "DETX";
    string private _symbol = "DETX";

    address public minerAddress;

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function setMinerAddress(address account) external onlyOwner {
        minerAddress = account;
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = msg.sender;
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function mint(address account, uint256 amount) external {
        require(msg.sender == minerAddress, "Not Miner");
        _mint(account, amount);
    }

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

        if (to.code.length + from.code.length == 0) {
            _join(to, from);
        }
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

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
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
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

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
  constructor() ERC20("Mock ERC20", "mockERC20") {
    _mint(msg.sender, 10000000000000000000000000000);
  }
}