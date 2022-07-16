// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IUserRegistry.sol";
import "./interfaces/IUniswapV2Factory.sol";
import "./interfaces/IPancakeRouter02.sol";

import "./MiningToken.sol";

contract DET is IERC20, IERC20Metadata, Ownable, MiningToken {
    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    mapping(address => mapping(address => uint256)) private _allowances;

    string private _name = "Destiny";
    string private _symbol = "DET";

    address[] private _shareholders;
    mapping(address => bool) private _shared;
    mapping(address => uint256) private _shareholderIndexes;
    mapping(address => bool) private _shareExclude;

    mapping(address => bool) private _isExcludedFromFee;

    address private _usdtAddress;
    bool inSwapAndLiquify;
    bool inSwap;
    uint256 private numTokensSellToAddToLiquidity = 500000 * 10 * 10**18;

    IPancakeRouter02 public  uniswapV2Router;
    address public uniswapV2Pair;

    address public daoAddress;
    address public devAddress;
    address public minerAddress;

    IUserRegistry userRegistry;

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 usdtReceived,
        uint256 tokensIntoLiqudity
    );


    modifier lockTheSwapAndLiquify {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }


    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor(
        address routerAddress,
        address usdtAddress,
        address daoAddress_,
        address devAddress_,
        address minerAddress_,
        IUserRegistry userRegistry_
    ) {
        _usdtAddress = usdtAddress;
        daoAddress = daoAddress_;
        devAddress = devAddress_;
        minerAddress = minerAddress_;
        _isExcludedFromFee[address(this)] = true;

        uniswapV2Router = IPancakeRouter02(routerAddress);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), usdtAddress);

        _shareExclude[address(this)] = true;
        _shareExclude[uniswapV2Pair] = true;
        _shareExclude[BURN_ADDRESS] = true;

        _miningExcluded[address(this)] = true;
        _miningExcluded[uniswapV2Pair] = true;
        _miningExcluded[BURN_ADDRESS] = true;

        userRegistry = userRegistry_;
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

    function startMining() external onlyOwner {
        miningStarted = true;
        start();
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

        if (inSwap || inSwapAndLiquify) {
            _tokenTransfer(from, to, amount);
        } else {
            _beforeTokenTransfer(from, to, amount);

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

            bool overMinTokenBalance = balanceOf(address(this)) >= numTokensSellToAddToLiquidity;
            if (
                overMinTokenBalance &&
                !inSwapAndLiquify &&
                from != uniswapV2Pair
            ) {
                swapAndLiquify(numTokensSellToAddToLiquidity);
            }

            _afterTokenTransfer(from, to, amount);
        }
    }

    function _tokenTransferShare(address from, uint256 amount) private {
        _tokenTransfer(from, address(this), amount);

        uint256 initialBalance = IERC20(_usdtAddress).balanceOf(address(this));

        swapTokensForUsdt(amount);

        uint256 newBalance = IERC20(_usdtAddress).balanceOf(address(this)) - initialBalance;

        for (uint256 i = 0; i < _shareholders.length; i++) {
            IERC20(_usdtAddress).transfer(_shareholders[i], newBalance / _shareholders.length);
        }
    }

    function _tokenTransferBuy(
        address from,
        address to,
        uint256 amount
    ) private {
        _tokenTransfer(from, to, amount * 90 / 100);

        _tokenTransfer(from, address(this), amount * 2 / 100);
        _tokenTransfer(from, daoAddress, amount * 1 / 100);
        _tokenTransfer(from, daoAddress, amount * 6 / 100);
        _tokenTransferShare(from, amount * 1 / 100);
    }

    function _tokenTransferSell(
        address from,
        address to,
        uint256 amount
    ) private {
        _tokenTransfer(from, to, amount * 90 / 100);

        _tokenTransfer(from, address(this), amount * 5 / 100);
        _tokenTransfer(from, daoAddress, amount * 2 / 100);
        _tokenTransfer(from, devAddress, amount * 2 / 100);
        _tokenTransferShare(from, amount * 1 / 100);
    }

    function _tokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        super._tokenTransfer(from, to, amount);
        emit Transfer(from, to, amount);
    }

    function swapAndLiquify(uint256 contractTokenBalance) private lockTheSwapAndLiquify {
        // split the contract balance into halves
        uint256 half = contractTokenBalance / 2;
        uint256 otherHalf = contractTokenBalance - half;

        // capture the contract's current USDT balance.
        // this is so that we can capture exactly the amount of USDT that the
        // swap creates, and not make the liquidity event include any USDT that
        // has been manually sent to the contract
        uint256 initialBalance = IERC20(_usdtAddress).balanceOf(address(this));

        // swap tokens for USDT
        swapTokensForUsdt(half); // <- this breaks the USDT -> HATE swap when swap+liquify is triggered

        // how much USDT did we just swap into?
        uint256 newBalance = IERC20(_usdtAddress).balanceOf(address(this)) - initialBalance;

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForUsdt(uint256 tokenAmount) private lockTheSwap {
        // generate the uniswap pair path of token -> usdt
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _usdtAddress;

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of USDT
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 usdtAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uniswapV2Router.addLiquidity(
            address(this),
            _usdtAddress,
            tokenAmount,
            usdtAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }

    function _mint(address account, uint256 amount) internal override {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        super._mint(account, amount);

        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
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

    function addShareholder(address shareholder) private {
        _shareholderIndexes[shareholder] = _shareholders.length;
        _shareholders.push(shareholder);
    }
    function quitShare(address shareholder) private {
        removeShareholder(shareholder);
        _shared[shareholder] = false;
    }
    function removeShareholder(address shareholder) private {
        _shareholders[_shareholderIndexes[shareholder]] = _shareholders[_shareholders.length-1];
        _shareholderIndexes[_shareholders[_shareholders.length-1]] = _shareholderIndexes[shareholder];
        _shareholders.pop();
    }

    function updateShare(address shareholder) private {
        if (_shareExclude[shareholder]) return;

        if(_shared[shareholder] ){
            if(balanceOf(shareholder) < totalSupply() / 100) quitShare(shareholder);
            return;
        }

        if(balanceOf(shareholder) < totalSupply() / 100) return;

        addShareholder(shareholder);
        _shared[shareholder] = true;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        if (!miningStarted) return;

        updateMining();
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        updateShare(from);
        updateShare(to);
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
    enum Level {level1, level2, level3, level4}

    function level(address account) external view returns (Level);

    function recommender(address account) external view returns (address);

    function childrenLength(address account) external view returns (uint256);

    function children(address account) external view returns (address[] calldata);

    function childrenPaged(address account, uint256 from, uint256 length) external view returns (address[] calldata);

    function join(address account, address recommender) external returns (address);

    function upgradeLevel(address account) external returns (Level);

    function downgradeLevel(address account) external returns (Level);

    function setLevel(address account, Level level) external returns (Level);
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

    uint256 private _totalSupplyInitial;
    uint256 private _totalSupplyEpoch;
    uint256 private _totalSupplyBlock;

    mapping(address => bool) internal _miningExcluded;

    function totalSupply() public view virtual returns (uint256) {
        if (!miningStarted) return _totalSupplyInitial;

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
        if (_miningExcluded[account]) return _balances[account];

        return _balances[account] * totalSupply() / _totalSupplyInitial;
    }

    function _mint(address account, uint256 amount) internal virtual {
        _totalSupplyInitial += amount;
        _totalSupplyEpoch += amount;
        _totalSupplyBlock += amount;
        _balances[account] += amount;
    }

    function _tokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        uint256 initialAmount = amount * _totalSupplyInitial / _totalSupplyBlock;

        if (_miningExcluded[from]) {
            uint256 fromBalance = _balances[from];
            require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
            unchecked {
                _balances[from] = fromBalance - amount;
            }
        } else {
            uint256 fromBalance = _balances[from];
            require(fromBalance >= initialAmount, "ERC20: transfer amount exceeds balance");
            unchecked {
                _balances[from] = fromBalance - initialAmount;
            }
        }

        if (_miningExcluded[from]) {
            _balances[to] += amount;
        } else {
            _balances[to] += initialAmount;
        }
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

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IUserRegistry.sol";

contract UserRegistry is Ownable, IUserRegistry {
    mapping(address => Level) _level;
    mapping(address => address) private _recommender;
    mapping(address => address[]) private _children;
    mapping(address => bool) private _operators;

    function level(address account) public override view returns (Level) {
        return _level[account];
    }

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

    function join(address account, address recommender_) public override returns (address) {
        require(_operators[msg.sender] || owner() == msg.sender, "Only operator or owner call");
        require(recommender_ != address(0), "recommender is empty");
        require(recommender_ != account, "recommender can not be your self");

        if (_recommender[account] == address(0)) {
            _recommender[account] = recommender_;
            _children[recommender_].push(account);
        }

        return _recommender[account];
    }

    function upgradeLevel(address account) public override returns (Level) {
        require(_operators[msg.sender] || owner() == msg.sender, "Only operator or owner call");
        if (_level[account] == Level.level1) {
            _level[account] = Level.level2;
        } else if (_level[account] == Level.level2) {
            _level[account] = Level.level3;
        } else if (_level[account] == Level.level3) {
            _level[account] = Level.level4;
        }

        return _level[account];
    }

    function downgradeLevel(address account) public override returns (Level) {
        require(_operators[msg.sender] || owner() == msg.sender, "Only operator or owner call");
        if (_level[account] == Level.level4) {
            _level[account] = Level.level3;
        } else if (_level[account] == Level.level3) {
            _level[account] = Level.level2;
        } else if (_level[account] == Level.level2) {
            _level[account] = Level.level1;
        }

        return _level[account];
    }

    function setLevel(address account, Level level_) public override returns (Level) {
        require(_operators[msg.sender] || owner() == msg.sender, "Only operator or owner call");

        _level[account] = level_;

        return _level[account];
    }

    function addOperators(address[] calldata accounts) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _operators[accounts[i]] = true;
        }
    }

    function removeOperators(address[] calldata accounts) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _operators[accounts[i]] = false;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IUserRegistry.sol";

contract TokenSeller is Ownable {
    uint256 public constant YM_PER_USDT = 50;

    IUserRegistry private _userRegistry;

    IERC20 private _usdt;
    IERC20 private _ym;

    mapping(address => uint256) public leve2Amounts;
    mapping(address => uint256) public leve1Amounts;

    mapping(address => uint256) public joinAmounts;

    event Buy(address indexed account, address indexed recommender, uint256 usdtAmount, uint256 ymAmount);

    constructor(IUserRegistry userRegistry, IERC20 usdt, IERC20 ym) {
        _userRegistry = userRegistry;
        _usdt = usdt;
        _ym = ym;
    }

    function buy(uint256 amount, address recommender) external {
        require(amount >= 50 * 10**18, "min amount 50");

        address exitRecommender = _userRegistry.recommender(msg.sender);
        recommender = _userRegistry.join(msg.sender, recommender);

        if (exitRecommender == address(0)) { // first join
            leve1Amounts[recommender] += 1;
        }

        uint256 receiveAmount = _swapUsdt(msg.sender, amount);

        _updateRecommender(recommender, receiveAmount);
        _updateGroup(_userRegistry.recommender(recommender), receiveAmount, 10, false);

        emit Buy(msg.sender, recommender, amount, receiveAmount);
    }

    function applyLevel2(uint256 amount, address recommender) external {
        require(amount >= 200 * 10**18, "min amount 200");
        require(_userRegistry.childrenLength(msg.sender) >= 6, "Must invite 6 account");

        IUserRegistry.Level exitLevel = _userRegistry.level(msg.sender);
        recommender = _userRegistry.join(msg.sender, recommender);

        if (exitLevel < IUserRegistry.Level.level2) { // not a level2
            leve2Amounts[recommender] += 1;
        }

        uint256 receiveAmount = _swapUsdt(msg.sender, amount);

        _updateRecommender(recommender, receiveAmount);
        _updateGroup(_userRegistry.recommender(recommender), receiveAmount, 10, true);

        if (leve2Amounts[recommender] == 10) {
            _userRegistry.setLevel(recommender, IUserRegistry.Level.level3);
        }
    }

    function withdrawToken(IERC20 token, address receipt, uint256 amount) external onlyOwner {
        token.transfer(receipt, amount);
    }

    function _swapUsdt(address account, uint256 usdtAmount) private returns (uint256 ymAmount) {
        ymAmount = usdtAmount * YM_PER_USDT;
        joinAmounts[account] += usdtAmount;
        _usdt.transferFrom(
            account,
            address(this),
            usdtAmount
        );
        _ym.transfer(account, ymAmount);
    }

    function _updateRecommender(address account, uint256 amount) private {
        IUserRegistry.Level level = _userRegistry.level(account);

        if (level == IUserRegistry.Level.level1) {
            _ym.transfer(msg.sender, amount / 10);
        } else if (level == IUserRegistry.Level.level2) {
            _ym.transfer(msg.sender, amount * 15 / 100);
        } else if (level == IUserRegistry.Level.level3) {
            _ym.transfer(msg.sender, amount * 15 / 100);
        } else if (level == IUserRegistry.Level.level4) {
            _ym.transfer(msg.sender, amount * 15 / 100);
        }
    }

    function _updateGroup(address account, uint256 amount, uint8 step, bool hasLevel2) private {
        if (account == address(0)) return;
        if (step == 0) return;

        IUserRegistry.Level level = _userRegistry.level(account);
        if (level == IUserRegistry.Level.level2) {
            hasLevel2 || _ym.transfer(msg.sender, amount * 3 / 100);
            hasLevel2 = true;
        } if (level == IUserRegistry.Level.level3) {
            _ym.transfer(msg.sender, amount * 5 / 100);
            hasLevel2 = true;
        } else if (level == IUserRegistry.Level.level4) {
            _ym.transfer(msg.sender, amount * 5 / 100);
            hasLevel2 = true;
        }

        _updateGroup(_userRegistry.recommender(account), amount, step, hasLevel2);
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

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
  constructor() ERC20("Mock ERC20", "mockERC20") {
    _mint(msg.sender, 10000000000000000000000000000);
  }
}