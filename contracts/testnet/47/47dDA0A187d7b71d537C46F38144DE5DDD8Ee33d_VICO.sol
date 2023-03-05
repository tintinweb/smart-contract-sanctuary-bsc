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

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

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
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
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

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

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

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.2;

interface IPancakeRouter01 {
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

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.2;

import "./IPancakeRouter01.sol";

interface IPancakeRouter02 is IPancakeRouter01 {
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
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "./Context.sol";

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

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./Ownable.sol";
import "./IPancakeFactory.sol";
import "./IPancakeRouter01.sol";
import "./IPancakeRouter02.sol";
import "./IPancakePair.sol";

contract VICO is Context, IERC20, Ownable {
    string private constant _name = "VICO TOKEN";
    string private constant _symbol = "VICO";
    uint8 private constant _decimals = 18;

    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _tTotal = 10000000 ether;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));
    uint256 private _tFeeTotal;

    address[] private _excluded;
    address public referralFeeReceiver;
    address public superNodeFeeReceiver;

    uint256 public referralFee = 0; 
    uint256 public superNodeFee = 10; 
    uint256 public liquidityFee = 2;  
    uint256 public taxFee = 0; 
    uint256 public swapThreshold = _tTotal * 1/1000; // 0.1% of total supply

    uint public count;
    
    // auto liquidity
    bool public _swapAndLiquifyEnabled = true;
    bool _inSwapAndLiquify;

    IPancakeRouter02 public _pancakeRouter;
    address public _pancakePair;

    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcluded;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public _isExcludedFromAutoLiquidity;

    modifier lockTheSwap {
        _inSwapAndLiquify = true;
        _;
        _inSwapAndLiquify = false;
    }
    
    constructor () {
        _rOwned[_msgSender()] = _rTotal;
        
        //pancakeswap
        //Testnet 0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        //Mainnet 0x10ED43C718714eb63d5aA57B78B54704E256024E
        IPancakeRouter02 pancakeRouter = IPancakeRouter02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        _pancakeRouter = pancakeRouter;
        _pancakePair = IPancakeFactory(pancakeRouter.factory())
            .createPair(address(this), pancakeRouter.WETH());
        
        // exclude system contracts
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        _isExcludedFromAutoLiquidity[_pancakePair] = true;
        _isExcludedFromAutoLiquidity[address(_pancakeRouter)] = true;

        referralFeeReceiver = 0xf660993844a749Bd75E033cc2B8bd398eA9657a9;
        superNodeFeeReceiver = 0xf660993844a749Bd75E033cc2B8bd398eA9657a9;
        

        //25% to main wallet
        emit Transfer(address(0), address(0xC50eB145d6cB1F1Ceb23e03E39d1f1B2808c469f), _tTotal * 25/100);
        //20% to presale wallet
        emit Transfer(address(0), address(0xB9dEA2B175585258dDF41079FB38d0807cA2332C), _tTotal * 20/100);
        //20% listing wallet
        emit Transfer(address(0), address(0xb9db95F6C559341fe794F0FfE1dBD91C2e4F188D), _tTotal * 20/100);
        //5% airdrop wallet
        emit Transfer(address(0), address(0x73b68F2b30943Bc6A5cC4b8D88ef80E41665d977), _tTotal * 5/100);
        //5% marketing wallet
        emit Transfer(address(0), address(0x751B6E4621342Cb56b6D13B1bD1FA3013CD837C8), _tTotal * 5/100);
        //5% development wallet
        emit Transfer(address(0), address(0xCdD4f13075281f56eEFABc0Ba3e1717Fc752E6CD), _tTotal * 5/100);
        //20% future development wallet
        emit Transfer(address(0), address(0xaA7671E02E2bbF7ECced23970A9b0A6A535cb860), _tTotal * 20/100);

    }

    function increment() external {
        count += 1;
    }

    function name() external pure returns (string memory) {
        return _name;
    }

    function symbol() external pure returns (string memory) {
        return _symbol;
    }

    function decimals() external pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() external pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()] - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - subtractedValue);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 contractTokenBalance = balanceOf(address(this));
        
        bool isOverMinTokenBalance = contractTokenBalance >= swapThreshold;
        if (
            isOverMinTokenBalance &&
            !_inSwapAndLiquify &&
            !_isExcludedFromAutoLiquidity[from] &&
            _swapAndLiquifyEnabled
        ) {
            swapAndLiquify(contractTokenBalance);
        }

        bool takeFee = true;
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }
        tokenTransfer(from, to, amount, takeFee);
    }

    function swapAndLiquify(uint256 contractTokenBalance) internal lockTheSwap {
        // split the contract balance into halves
        uint256 half = contractTokenBalance / 2;
        uint256 otherHalf = contractTokenBalance - half;

        // capture the contract's current BNB balance.
        // this is so that we can capture exactly the amount of BNB that the
        // swap creates, and not make the liquidity event include any BNB that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for BNB
        swapTokensForBnb(half); // <- this breaks the BNB -> HATE swap when swap+liquify is triggered

        // how much BNB did we just swap into?
        uint256 newBalance = address(this).balance - initialBalance;

        // add liquidity to uniswap
        addLiquidity(otherHalf, newBalance);
        
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForBnb(uint256 tokenAmount) internal {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _pancakeRouter.WETH();

        _approve(address(this), address(_pancakeRouter), tokenAmount);

        // make the swap
        _pancakeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of BNB
            path,
            address(this),
            block.timestamp
        );

        emit SwapTokensForBnb(tokenAmount);
    }

    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) internal {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(_pancakeRouter), tokenAmount);

        // add the liquidity
        _pancakeRouter.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );

        emit AddLiquidity(tokenAmount, bnbAmount);
    }

    function deliver(uint256 tAmount) external {
        address sender = _msgSender();
        require(!_isExcluded[sender], "Excluded addresses cannot call this function");

        (, uint256 tFee, uint256 tLiquidity, uint256 tReferral, uint256 tSuperNode) = getTValues(tAmount);
        uint256 currentRate = getRate();
        (uint256 rAmount,,, uint256 rReferralFee, uint256 rSuperNodeFee) = getRValues(tAmount, tFee, tLiquidity, tReferral, tSuperNode, currentRate);

        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[referralFeeReceiver] = _rOwned[referralFeeReceiver] + rReferralFee;
        _rOwned[superNodeFeeReceiver] = _rOwned[superNodeFeeReceiver] + rSuperNodeFee;
        _rTotal = _rTotal - rAmount;
        _tFeeTotal = _tFeeTotal + tAmount;

        emit Deliver(tAmount);
    }

    function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
        require(rAmount <= _rTotal, "Amount must be less than total reflections");

        uint256 currentRate = getRate();
        return rAmount / currentRate;
    }

    function tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) internal {
        uint256 previousTaxFee = taxFee;
        uint256 previousLiquidityFee = liquidityFee;
        uint256 previousReferralFee = referralFee;
        uint256 previousSuperNodeFee = superNodeFee;
        
        if (!takeFee) {
            taxFee = 0;
            liquidityFee = 0;
            referralFee = 0;
            superNodeFee = 0;
        }
        
        if (_isExcluded[sender] && !_isExcluded[recipient]) {
            transferFromExcluded(sender, recipient, amount);
        } else if (!_isExcluded[sender] && _isExcluded[recipient]) {
            transferToExcluded(sender, recipient, amount);
        } else if (_isExcluded[sender] && _isExcluded[recipient]) {
            transferBothExcluded(sender, recipient, amount);
        } else {
            transferStandard(sender, recipient, amount);
        }
        
        if (!takeFee) {
            taxFee = previousTaxFee;
            liquidityFee = previousLiquidityFee;
            referralFee = previousReferralFee;
            superNodeFee = previousSuperNodeFee;
        }
    }

    function transferStandard(address sender, address recipient, uint256 tAmount) internal {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity, uint256 tReferral, uint256 tSuperNode) = getTValues(tAmount);
        uint256 currentRate = getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee,,) = getRValues(tAmount, tFee, tReferral, tSuperNode, tLiquidity, currentRate);

        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;

        takeTransactionFee(superNodeFeeReceiver, tSuperNode, currentRate);
        reflectFee(rFee, tFee);

        emit Transfer(sender, recipient, tTransferAmount);
    }

    function transferBothExcluded(address sender, address recipient, uint256 tAmount) internal {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity, uint256 tReferral, uint256 tSuperNode) = getTValues(tAmount);
        uint256 currentRate = getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee,,) = getRValues(tAmount, tFee, tReferral, tSuperNode, tLiquidity, currentRate);

        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;

        takeTransactionFee(address(this), tLiquidity, currentRate);
        reflectFee(rFee, tFee);

        emit Transfer(sender, recipient, tTransferAmount);
    }

    function transferToExcluded(address sender, address recipient, uint256 tAmount) internal {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity, uint256 tReferral, uint256 tSuperNode) = getTValues(tAmount);
        uint256 currentRate = getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee,,) = getRValues(tAmount, tFee, tReferral, tSuperNode, tLiquidity, currentRate);

        _rOwned[sender] = _rOwned[sender] - rAmount;
        _tOwned[recipient] = _tOwned[recipient] + tTransferAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;

        takeTransactionFee(address(this), tLiquidity, currentRate);
        reflectFee(rFee, tFee);

        emit Transfer(sender, recipient, tTransferAmount);
    }

    function transferFromExcluded(address sender, address recipient, uint256 tAmount) internal {
        (uint256 tTransferAmount, uint256 tFee, uint256 tLiquidity, uint256 tReferral, uint256 tSuperNode) = getTValues(tAmount);
        uint256 currentRate = getRate();
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee,,) = getRValues(tAmount, tFee, tReferral, tSuperNode, tLiquidity, currentRate);

        _tOwned[sender] = _tOwned[sender] - tAmount;
        _rOwned[sender] = _rOwned[sender] - rAmount;
        _rOwned[recipient] = _rOwned[recipient] + rTransferAmount;
        
        takeTransactionFee(address(this), tLiquidity, currentRate);
        reflectFee(rFee, tFee);

        emit Transfer(sender, recipient, tTransferAmount);
    }

    function reflectFee(uint256 rFee, uint256 tFee) internal {
        _rTotal    = _rTotal - rFee;
        _tFeeTotal = _tFeeTotal + tFee;
    }

    function takeTransactionFee(address to, uint256 tAmount, uint256 currentRate) internal {
        if (tAmount <= 0) { return; }

        uint256 rAmount = tAmount * currentRate;
        _rOwned[to] = _rOwned[to] + rAmount;
        if (_isExcluded[to]) {
            _tOwned[to] = _tOwned[to] + tAmount;
        }

        emit Transfer(address(this), to, tAmount);
    }
    
    function calculateFee(uint256 amount, uint256 fee) internal pure returns (uint256) {
        return amount * fee / 100;
    }

    function totalFees() external view returns (uint256) {
        return _tFeeTotal;
    }
    
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function isExcludedFromReward(address account) external view returns (bool) {
        return _isExcluded[account];
    }

    function rescueToken(address tokenAddress, address to) external onlyOwner {
        uint256 contractBalance = IERC20(tokenAddress).balanceOf(address(this));
        IERC20(tokenAddress).transfer(to, contractBalance);
    }

    receive() external payable {}

    // ===================================================================
    // GETTERS
    // ===================================================================

    function getTValues(uint256 tAmount) internal view returns (uint256, uint256, uint256, uint256, uint256) {
        uint256 tFee = calculateFee(tAmount, taxFee);
        uint256 tLiquidity = calculateFee(tAmount, liquidityFee);
        uint256 tReferral = calculateFee(tAmount, referralFee);
        uint256 tSuperNode = calculateFee(tAmount, superNodeFee);
        uint256 tTransferAmount = tAmount - (tFee + tLiquidity + tReferral + tSuperNode);
        return (tTransferAmount, tFee, tLiquidity, tReferral, tSuperNode);
    }

    function getRValues(uint256 tAmount, uint256 tFee, uint256 tLiquidity, uint256 tReferral, uint256 tSuperNode, uint256 currentRate) 
    internal pure returns (uint256, uint256, uint256, uint256, uint256) {
        uint256 rAmount = tAmount * currentRate;
        uint256 rFee = tFee * currentRate;
        uint256 rLiquidity = tLiquidity * currentRate;
        uint256 rReferral = tReferral * currentRate;
        uint256 rSuperNode = tSuperNode * currentRate;
        uint256 rTransferAmount = rAmount - (rFee + rLiquidity + rReferral + rSuperNode);
        return (rAmount, rTransferAmount, rFee, rReferral, rSuperNode);
    }

    function getRate() internal view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = getCurrentSupply();
        return rSupply / tSupply;
    }

    function getCurrentSupply() internal view returns(uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;      
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply - _rOwned[_excluded[i]];
            tSupply = tSupply - _tOwned[_excluded[i]];
        }
        if (rSupply < _rTotal / _tTotal) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    // ===================================================================
    // SETTERS
    // ===================================================================

    function setExcludeFromReward(address account) external onlyOwner {
        require(account != address(0), "Address zero");
        require(!_isExcluded[account], "Account is already excluded");

        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);

        emit SetExcludeFromReward(account);
    }

    function setIncludeInReward(address account) external onlyOwner {
        require(account != address(0), "Address zero");
        require(_isExcluded[account], "Account is not excluded");

        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }

        emit SetIncludeInReward(account);
    }

    function setReferralFeeReceiver(address newReferralFeeReceiver) external onlyOwner {
        require(newReferralFeeReceiver != address(0), "Address zero");
        referralFeeReceiver = newReferralFeeReceiver;

        emit SetReferralFeeReceiver(newReferralFeeReceiver);
    }

    function setSuperNodeFeeReceiver(address newSuperNodeFeeReceiver) external onlyOwner {
        require(newSuperNodeFeeReceiver != address(0), "Address zero");
        superNodeFeeReceiver = newSuperNodeFeeReceiver;

        emit SetSuperNodeFeeReceiver(newSuperNodeFeeReceiver);
    }

    function setExcludedFromFee(address addr, bool e) external onlyOwner {
        require(addr != address(0), "Address zero");
        _isExcludedFromFee[addr] = e;

        emit SetExcludedFromFee(addr, e);
    }
    
    function setTaxFeePercent(uint256 newTaxFee) external onlyOwner {
        require(newTaxFee <= 5, "Exceeded 5 percent");
        taxFee = newTaxFee;

        emit SetTaxFeePercent(newTaxFee);
    }

    function setLiquidityFeePercent(uint256 newLiquidityFee) external onlyOwner {
        require(newLiquidityFee <= 5, "Exceeded 5 percent");
        liquidityFee = newLiquidityFee;

        emit SetLiquidityFeePercent(newLiquidityFee);
    }

    function setReferralFeePercent(uint256 newReferralFee) external onlyOwner {
        require(newReferralFee <= 5, "Exceeded 5 percent");
        referralFee = newReferralFee;

        emit SetReferralFeePercent(newReferralFee);
    }

    function setSuperNodeFeePercent(uint256 newSuperNodeFee) external onlyOwner {
        require(newSuperNodeFee <= 5, "Exceeded 5 percent");
        superNodeFee = newSuperNodeFee;

        emit SetSuperNodeFeePercent(newSuperNodeFee);
    }

    function setSwapAndLiquifyEnabled(bool e) external onlyOwner {
        _swapAndLiquifyEnabled = e;

        emit SwapAndLiquifyEnabledUpdated(e);
    }

    function setSwapThreshold(uint256 newSwapThreshold) external onlyOwner {
        require(newSwapThreshold > 0, "must be larger than zero");
        swapThreshold = newSwapThreshold;

        emit SetSwapThreshold(newSwapThreshold);
    }
    
    function setUniswapRouter(address newUniswapRouter) external onlyOwner {
        require(newUniswapRouter != address(0), "Address zero");
        IPancakeRouter02 pancakeRouter = IPancakeRouter02(newUniswapRouter);
        _pancakeRouter = pancakeRouter;

        emit SetUniswapRouter(newUniswapRouter);
    }

    function setUniswapPair(address newUniswapPair) external onlyOwner {
        require(newUniswapPair != address(0), "Address zero");
        _pancakePair = newUniswapPair;

        emit SetUniswapPair(newUniswapPair);
    }

    function setExcludedFromAutoLiquidity(address addr, bool b) external onlyOwner {
        require(addr != address(0), "Address zero");
        _isExcludedFromAutoLiquidity[addr] = b;

        emit SetExcludedFromAutoLiquidity(addr, b);
    }

    // ===================================================================
    // EVENTS
    // ===================================================================

    event Deliver(uint256 tAmount);
    event SetExcludeFromReward(address account);
    event SetIncludeInReward(address account);
    event SetReferralFeeReceiver(address referralWallet);
    event SetSuperNodeFeeReceiver(address superNodeWallet);
    event SetExcludedFromFee(address account, bool e);
    event SetTaxFeePercent(uint256 taxFee);
    event SetLiquidityFeePercent(uint256 liquidityFee);
    event SetReferralFeePercent(uint256 referralFee);
    event SetSuperNodeFeePercent(uint256 superNodeFee);
    event SetSwapAndLiquifyEnabled(bool e);
    event SetSwapThreshold(uint256 swapThreshold);
    event SetUniswapRouter(address uniswapRouter);
    event SetUniswapPair(address uniswapPair);
    event SetExcludedFromAutoLiquidity(address a, bool b);
    event RescueToken(address tokenAddress, address to);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapTokensForBnb(uint256 tokenAmount);
    event AddLiquidity(uint256 tokenAmount, uint256 bnbAmount);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 bnbReceived, uint256 tokensIntoLiquidity);
}