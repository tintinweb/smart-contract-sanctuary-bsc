/**
 *Submitted for verification at BscScan.com on 2022-05-30
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


interface IUniswapV2Router01 {
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

interface IUniswapV2Router02 is IUniswapV2Router01 {
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

interface IUniswapV2Pair {
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


    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

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

interface ITokenHelper {
    function claimProfit(address account, uint256 amount) external returns (bool);
    function getProfit(address account) external view returns (uint256);
}

interface IGKToken is IERC20 {
    function tokenHelper() external view returns (address);
}

contract GKBIZ is Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public uniswapV2Router;
    IUniswapV2Factory public uniswapV2Factory;

    address public gkAddress;
    address public gkTokenHelperAddress;
    address public gksAddress;
    // address public bep20usdt = 0x55d398326f99059fF775485246999027B3197955;
    address public bep20usdt = 0x853875823CacE9418c292D8B41C1c192D3Ab5f1a;
    address public liquidityReceiveAddress;
    
    uint256 public minSwapFee = 100 * 10**9;

    bool inSwapAndLiquify;
    modifier lockTheSwap() {
        require(!inSwapAndLiquify);
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    event SwapFeeAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity);

    constructor(address gksAddress_, address gkAddress_, address liquidityReceiveAddress_) {
        gksAddress = gksAddress_;
        gkAddress = gkAddress_;
        liquidityReceiveAddress = liquidityReceiveAddress_;
        // uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Router = IUniswapV2Router02(0xCc7aDc94F3D80127849D2b41b6439b7CF1eB4Ae0);
        uniswapV2Factory = IUniswapV2Factory(uniswapV2Router.factory());

        IGKToken gkInstance = IGKToken(gkAddress_);
        gkTokenHelperAddress = gkInstance.tokenHelper();
    }

    function gkProfit(address account) public view returns (uint256) {
        ITokenHelper tokenHelper = ITokenHelper(gkTokenHelperAddress);
        return tokenHelper.getProfit(account);
    }

    function mint(uint256 amount) public {
        require(gkTokenHelperAddress != address(0), "GKSTokenHelper address is not set");
        require(gkAddress != address(0), "GK address is not set");
        ITokenHelper tokenHelper = ITokenHelper(gkTokenHelperAddress);
        tokenHelper.claimProfit(_msgSender(), amount);

        // swap gk to gks
        _swapTokensForGks(amount, _msgSender());
    }
    
    function addGKSLiquidity(uint256 usdtAmount, uint256 gksAmount) lockTheSwap public {
        IERC20 usdtInstance = IERC20(bep20usdt);
        IERC20 gksInstance = IERC20(gksAddress);

        usdtInstance.transferFrom(_msgSender(), address(this), usdtAmount);
        gksInstance.transferFrom(_msgSender(), address(this), gksAmount);

        gksAmount = gksAmount.mul(91).div(100);

        // approve token transfer to cover all possible scenarios
        usdtInstance.approve(address(uniswapV2Router), usdtAmount);
        gksInstance.approve(address(uniswapV2Router), gksAmount);
        // add the liquidity
        (uint amountA, uint amountB, ) = uniswapV2Router.addLiquidity(
            gksAddress,
            bep20usdt,
            gksAmount,
            usdtAmount,
            0,
            0,
            _msgSender(),
            block.timestamp
        );
        if (gksAmount > uint256(amountA)) {
            gksInstance.transfer(_msgSender(), gksAmount.sub(amountA));
        }
        if (usdtAmount > uint256(amountB)) {
            usdtInstance.transfer(_msgSender(), usdtAmount.sub(amountB));
        }

        uint256 currGks = gksInstance.balanceOf(address(this));
        if (currGks >= minSwapFee) {
            _feeLiquidity(currGks);
        }

    }

    function _feeLiquidity(uint256 gksFeeAmount) private {
        uint256 half = gksFeeAmount.div(2);
        uint256 otherHalf = gksFeeAmount.sub(half);

        IERC20 usdtInstance = IERC20(bep20usdt);
        uint256 initUsdtBlance = usdtInstance.balanceOf(address(this));
        usdtInstance.approve(address(uniswapV2Router), otherHalf);
        _swapTokensForUsdt(otherHalf);
        uint256 usdtOut = usdtInstance.balanceOf(address(this)).sub(initUsdtBlance);

        IERC20 gksInstance = IERC20(gksAddress);
        gksInstance.approve(address(uniswapV2Router), half);

        uniswapV2Router.addLiquidity(
            gksAddress,
            bep20usdt,
            half,
            usdtOut,
            0,
            0,
            liquidityReceiveAddress,
            block.timestamp
        );
        emit SwapFeeAndLiquify(half, usdtOut, otherHalf);
    }

    function _swapTokensForUsdt(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = bep20usdt;
        // make the swap
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            address(this),
            block.timestamp
        );
    }

    function removeGKSLiquidity(uint256 lpAmount) lockTheSwap public {
        IERC20 gksInstance = IERC20(gksAddress);
        uint256 currGks = gksInstance.balanceOf(address(this));
        if (currGks >= minSwapFee) {
            _feeLiquidity(currGks);
        }
        
        address lpPair = uniswapV2Factory.getPair(gksAddress, bep20usdt);
        IUniswapV2Pair lpPairInstance = IUniswapV2Pair(lpPair);
        lpPairInstance.transferFrom(_msgSender(), address(this), lpAmount);

        lpPairInstance.approve(address(uniswapV2Router), lpAmount);

        (uint amountA, uint amountB) = uniswapV2Router.removeLiquidity(
            gksAddress, 
            bep20usdt, 
            lpAmount, 
            0, 
            0, 
            address(this),
            block.timestamp
        );
        IERC20 usdtInstance = IERC20(bep20usdt);
        usdtInstance.transfer(_msgSender(), amountB);

        uint256 outAmt =  uint256(amountA).mul(91).div(100);
        gksInstance.transfer(_msgSender(), outAmt);

    }



    function _swapTokensForGks(uint256 tokenAmount, address receiver) private {
        address[] memory path = new address[](3);
        path[0] = gkAddress;
        path[1] = bep20usdt;
        path[2] = gksAddress;

        IERC20(gkAddress).approve(address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            receiver,
            block.timestamp
        );
    }

    function setGKAddress(address address_) public onlyOwner {
        gkAddress = address_;
        IGKToken gkInstance = IGKToken(gkAddress);
        gkTokenHelperAddress = gkInstance.tokenHelper();
    }

    function setGKSAddress(address address_) public onlyOwner {
        gksAddress = address_;
    }

    function setLiquidityReceiveAddress(address address_) public onlyOwner {
        liquidityReceiveAddress = address_;
    }

    function setMinSellFee(uint256 amount_) public onlyOwner {
        minSwapFee = amount_;
    }

    function withdrawToken(address coin, address receiver, uint256 amount) public onlyOwner {
        if (address(0) == coin) {
            payable(receiver).transfer(amount);
        } else {
            IERC20 coinContract = IERC20(coin);
            coinContract.transfer(receiver, amount);
        }
    }
}