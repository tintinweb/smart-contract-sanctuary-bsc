/**
 *Submitted for verification at BscScan.com on 2022-09-15
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

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

interface IERC20 {

    function totalSupply() external view returns (uint256);
    
    function symbol() external view returns(string memory);
    
    function name() external view returns(string memory);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
    
    /**
     * @dev Returns the number of decimal places
     */
    function decimals() external view returns (uint8);

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

/**
 * @title Owner
 * @dev Set & change owner
 */
contract Ownable {

    address private owner;
    
    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    // modifier to check if caller is owner
    modifier onlyOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }

    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) public onlyOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }
}

interface IXUSD {
    function sell(uint256 amount) external returns (uint256);
}

contract Arby is Ownable {

    // token info    
    IUniswapV2Router02 private constant router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address private constant xUSD = 0xfc62b18CAC1343bd839CcbEDB9FC3382a84219B9;
    address private constant busd = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public ARBY = 0x80A124fBBC1fE3860B29fa1f9824d85216854D07;
    address public Recipient = 0x45F8F3a7A91e302935eB644f371bdE63D0b1bAc6;
    
    // paths
    address[] buyPath;
    address[] sellPath;

    // BUSD -> BNB
    address[] busdBNB;
    
    // cost to run cycle + incentive
    uint256 public gasCost = 24 * 10**14;

    // denom for profits
    uint256 public denom = 5;
    
    constructor() {
        buyPath = new address[](2);
        buyPath[0] = router.WETH();
        buyPath[1] = xUSD;
        sellPath = new address[](2);
        sellPath[0] = xUSD;
        sellPath[1] = router.WETH();
        busdBNB = new address[](2);
        busdBNB[0] = busd;
        busdBNB[1] = router.WETH();
    }

    function setArby(address ARBY_) external onlyOwner {
        ARBY = ARBY_;
    }

    function setRecipient(address recipient_) external onlyOwner {
        Recipient = recipient_;
    }

    function setGasCost(uint256 gasCost_) external onlyOwner {
        gasCost = gasCost_;
    }

    function setDenom(uint256 denom_) external onlyOwner {
        denom = denom_;
    }

    function withdraw(address token) external onlyOwner {
        uint256 bal = IERC20(token).balanceOf(address(this));
        require(bal > 0, 'Zero Tokens');
        IERC20(token).transfer(msg.sender, bal);
    }
    
    function withdrawBNB() external onlyOwner {
        (bool s,) = payable(msg.sender).call{value:address(this).balance}("");
        require(s, 'Failure on BNB Withdrawal');
    }
    
    function buyCycle() external payable {
        _buyCycle(msg.value);
    }
    
    function sellCycle() external payable {
        _sellCycle(msg.value);
    }

    function _buyCycle(uint256 amountBNB) private {
        _buyXUSD(amountBNB, true);
        _sellXUSD(IERC20(xUSD).balanceOf(address(this)), false);
        _swapBUSDForBNB(IERC20(busd).balanceOf(address(this)));
        uint256 forBot = amountBNB + gasCost;
        uint256 leftOver = address(this).balance - forBot;
        (bool s,) = payable(ARBY).call{value: forBot + ( leftOver / denom )}("");
        require(s, 'F0');
        (bool s1,) = payable(Recipient).call{value: address(this).balance}("");
        require(s1, 'F1');
    }
    
    function _sellCycle(uint256 amount) private {
        _buyXUSD(amount, false);
        _sellXUSD(IERC20(xUSD).balanceOf(address(this)), true);
        (bool s,) = payable(ARBY).call{value: amount + gasCost}("");
        require(s, 'F0');
        (bool s1,) = payable(Recipient).call{value: address(this).balance}("");
        require(s1, 'F1');
    }

    function _swapBUSDForBNB(uint256 nBUSD) internal {
        IERC20(busd).approve(address(router), nBUSD);
        router.swapExactTokensForETH(
            nBUSD,
            0,
            busdBNB,
            address(this),
            block.timestamp + 30
        );
    }
    
    function _buyXUSD(uint256 amountBNB, bool PCS) internal {
        if (PCS) {
            // buy XUSD on PCS
            router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amountBNB}(
                0,
                buyPath,
                address(this),
                block.timestamp + 30
            );
        } else {
            // buy XUSD with BNB
            (bool s,) = payable(xUSD).call{value: amountBNB}("");
            require(s, 'Failure on XUSD Purchase');
        }
    }

    function _sellXUSD(uint256 amount, bool PCS) internal {
        if (PCS) {
            IERC20(xUSD).approve(address(router), amount);
            router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                amount,
                0,
                sellPath,
                address(this),
                block.timestamp + 30
            );
        } else {
            // sell XUSD
            IXUSD(xUSD).sell(amount);
        }
    }
    
    receive() external payable {}
    
}