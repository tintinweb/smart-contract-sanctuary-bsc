//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import "./IERC20.sol";
import "./IUniswapV2Router02.sol";

interface IOwnedContract {
    function getOwner() external view returns (address);
}

interface IXUSD {
    function sell(uint256 tokenAmount, address desiredToken) external returns (address, uint256);
}

interface IDUMP {
    function sell(uint256 tokenAmount) external returns (address, uint256);
}

interface IPUMP {
    function burn(uint256 amount) external;
}

contract FeeReceiver {

    // Token
    address public constant PUMP = 0x91Ebe3E0266B70be6AE41b8944170A27A08E3C2e;
    address public constant XUSD = 0x324E8E649A6A3dF817F97CdDBED2b746b62553dD;
    address public constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address public immutable DUMP;

    // Recipients Of Fees
    address public addr0 = 0xED1E4936af3ceCc822358Ab3e96f44b16E358EA5;
    address public addr1 = 0x15F62C92c5a1b3172B071E3391C82bF815c5e4C8;
    address public addr2 = 0xb49844F55c08C0aF57A9FBf71Fb5747aDe7dA8c4;
    address public addr3 = 0xd28D5abC74E58da8c6288fAa1dc9Fdb7b631a2FE;

    // Fee Percentages
    uint private constant denom = 650;

    // Token -> BNB
    address[] private path;

    // bounty percent
    uint256 public bountyPercent = 1;

    // router
    IUniswapV2Router02 public constant router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    modifier onlyOwner(){
        require(
            msg.sender == IOwnedContract(DUMP).getOwner(),
            'Only Token Owner'
        );
        _;
    }

    constructor(address DUMP_) {
        DUMP = DUMP_;
        path = new address[](2);
        path[0] = router.WETH();
        path[1] = PUMP;
    }

    function trigger() external {

        // Bounty Reward For Triggerer
        uint bounty = currentBounty();
        if (bounty > 0) {
            IERC20(DUMP).transfer(msg.sender, bounty);
        }

        // sell dump for BNB
        _dumpToBNB();

        // amount for fee receivers
        uint256 bal = address(this).balance;
        uint p0 = ( bal * 200 ) / denom;
        uint p1 = ( bal * 225 ) / denom;
        uint p2 = ( bal * 25 )  / denom;

        // 2% portions
        _send(addr0, p0);
        _send(addr1, p0);
        
        // 2.25% portion
        _send(addr2, p1);

        // 0.25% portions
        _send(addr3, p2);
    }

    function _dumpToBNB() internal {

        // Sell Dump For Stable
        (address token,) = IDUMP(DUMP).sell(IERC20(DUMP).balanceOf(address(this)));

        // Swap Stable for BNB
        uint stableBal = IERC20(token).balanceOf(address(this));
        address[] memory sPath = new address[](2);
        sPath[0] = token;
        sPath[1] = router.WETH();
        
        // make the swap
        IERC20(token).approve(address(router), stableBal);
        router.swapExactTokensForETH(
            stableBal,
            0,
            sPath,
            address(this),
            block.timestamp + 300
        );
        delete sPath;
    }

    function _buyBurnPump(uint amount) internal {
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0,
            path,
            address(this),
            block.timestamp + 300
        );
        IPUMP(PUMP).burn(IERC20(PUMP).balanceOf(address(this)));
    }

    function setBountyPercent(uint256 bountyPercent_) external onlyOwner {
        require(bountyPercent_ < 100);
        bountyPercent = bountyPercent_;
    }

    function withdraw() external onlyOwner {
        (bool s,) = payable(msg.sender).call{value: address(this).balance}("");
        require(s);
    }
    
    function withdraw(address _token) external onlyOwner {
        IERC20(_token).transfer(msg.sender, IERC20(_token).balanceOf(address(this)));
    }

    receive() external payable {}
    
    function _send(address recipient, uint amount) internal {
        (bool s,) = payable(recipient).call{value: amount}("");
        require(s);
    }

    function currentBounty() public view returns (uint256) {
        uint balance = IERC20(DUMP).balanceOf(address(this));
        return ((balance * bountyPercent ) / 100);
    }
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;



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

//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

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