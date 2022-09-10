// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.14;

import "./IERC20.sol";
import "./IUniswapV2Router02.sol";
import "./NBLGovernance.sol";

interface ITipDatabase {
    function registerTip(address from, address to, uint256 amount, uint8 method, string calldata note) external;
}

contract TipSwapper is NBLGovernance {

    /**
        NBL Smart Contract
     */
    address public immutable NBL;

    /**
        Tip Database Instance
     */
    ITipDatabase public immutable Database;

    /**
        DEX Router To Market Buy NBL
     */
    IUniswapV2Router02 public router;

    /**
        Swap Path Between BNB -> NBL
     */
    address[] private path;

    /**
        Platform Fee
     */
    uint256 public fee = 500;
    uint256 public constant FEE_DENOM = 10**5;

    /**
        Fee Recipient
     */
    address public feeRecipient;

    /**
        Can Give Tips On Behalf Of Others
     */
    mapping ( address => bool ) public canTipOnBehalfOfOthers;

    /**
        Initialize Contract
     */
    constructor(
        address tipDatabase,
        address router_,
        address NBL_,
        address feeRecipient_
    ) {

        // NBL
        NBL = NBL_;

        // Set Fee Recipient
        feeRecipient = feeRecipient_;

        // Router
        router = IUniswapV2Router02(router_);

        // Database
        Database = ITipDatabase(tipDatabase);

        // Swap Path
        path = new address[](2);
        path[0] = router.WETH();
        path[1] = NBL;

        // set can tip on behalf of others
        canTipOnBehalfOfOthers[msg.sender] = true;

        // NBL Address:    0x11F331c62AB3cA958c5212d21f332a81c66F06e7
        // Router Address: 0x10ED43C718714eb63d5aA57B78B54704E256024E
    }

    
    function setRouter(address newRouter) external onlyOwner {
        router = IUniswapV2Router02(newRouter);
    }

    function setFeeRecipient(address newRecipient) external onlyOwner {
        feeRecipient = newRecipient;
    }

    function setFee(uint256 newFee) external onlyOwner {
        require(
            newFee <= FEE_DENOM / 4,
            'Fee Too High'
        );
        fee = newFee;
    }

    function withdraw(address token) external onlyOwner {
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }

    function withdrawETH() external onlyOwner {
        (bool s,) = payable(msg.sender).call{value: address(this).balance}("");
        require(s, 'ETH Send Failure');
    }

    function setCanTipOnBehalfOfOthers(address user, bool cantip) external onlyOwner {
        canTipOnBehalfOfOthers[user] = cantip;
    }

    receive() external payable {}

    function tipFrom(
        address from,
        address streamer,
        string calldata note
    ) external payable {
        require(
            canTipOnBehalfOfOthers[msg.sender],
            'Only Authorized Users Can Call'
        );

        // buy NBL
        uint256 received = _buy(msg.value);

        // Take NBL Tax
        uint256 toSend = _takeFeeNBL(received);

        // Register In DB
        Database.registerTip(from, streamer, toSend, 3, note);

        // Send NBL To Streamer
        _send(streamer, toSend);
    }

    function tipFromWithNBL(
        address from,
        address streamer,
        uint256 amount,
        string calldata note
    ) external {
        require(
            canTipOnBehalfOfOthers[msg.sender],
            'Only Authorized Users Can Call'
        );

        // transfer in NBL
        uint received = _sendFrom(msg.sender, amount);

        // Take NBL Tax
        uint256 toSend = _takeFeeNBL(received);

        // Register In DB
        Database.registerTip(from, streamer, toSend, 3, note);
        
        // Send NBL To Streamer
        _send(streamer, toSend);
    }

    function tip(
        address streamer,
        string calldata note
    ) external payable {
        
        // buy NBL
        uint256 received = _buy(msg.value);

        // Take NBL Tax
        uint256 toSend = _takeFeeNBL(received);

        // Register In DB
        Database.registerTip(msg.sender, streamer, toSend, 1, note);

        // Send NBL To Streamer
        _send(streamer, toSend);
    }

    function tipWithNBL(
        address streamer,
        uint256 amount,
        string calldata note
    ) external {
        
        // transfer in NBL
        uint received = _sendFrom(msg.sender, amount);

        // Take NBL Tax
        uint256 toSend = _takeFeeNBL(received);

        // Register In DB
        Database.registerTip(msg.sender, streamer, toSend, 0, note);
        
        // Send NBL To Streamer
        _send(streamer, toSend);
    }

    function tipWithOther(
        address token,
        address streamer,
        uint256 amount,
        string calldata note
    ) external {
        
        // transfer in Token
        uint received = _sendOtherFrom(token, msg.sender, amount);

        // swap token to NBL
        uint256 NBLReceived = _swapToNBL(token, received);

        // Take Fee In Token Tax
        uint256 toSend = _takeFeeNBL(NBLReceived);

        // Register In DB
        Database.registerTip(msg.sender, streamer, toSend, 2, note);
        
        // Send NBL To Streamer
        _send(streamer, toSend);
    }


    function _takeFeeNBL(uint256 amount) internal returns (uint256) {
        uint _fee = ( amount * fee ) / FEE_DENOM;
        _send(feeRecipient, _fee);
        return amount - _fee;
    }

    function _send(address to, uint256 amount) internal {
        require(
            IERC20(NBL).transfer(to, amount),
            'ERR NBL Transfer'
        );
    }

    function _sendFrom(address from, uint256 amount) internal returns (uint256) {
        uint before = balanceOf(address(this));
        require(
            IERC20(NBL).allowance(from, address(this)) >= amount,
            'Insufficient Allowance'
        );
        require(
            IERC20(NBL).transferFrom(from, address(this), amount),
            'ERR NBL Transfer'
        );
        uint After = balanceOf(address(this));
        require(
            After > before,
            'Zero Received'
        );
        return After - before;
    }

    function _sendOtherFrom(address token, address from, uint256 amount) internal returns (uint256) {
        uint before = IERC20(token).balanceOf(address(this));
        require(
            IERC20(token).allowance(from, address(this)) >= amount,
            'Insufficient Allowance'
        );
        require(
            IERC20(token).transferFrom(from, address(this), amount),
            'ERR NBL Transfer'
        );
        uint After = IERC20(token).balanceOf(address(this));
        require(
            After > before,
            'Zero Received'
        );
        return After - before;
    }

    function _buy(uint amount) internal returns (uint256) {

        // NBL Balance Before
        uint256 before = balanceOf(address(this));

        // Make Swap
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0,
            path,
            address(this),
            block.timestamp + 10
        );

        // NBL Balance After
        uint256 After = balanceOf(address(this));
        require(
            After > before,
            'Zero Received'
        );

        // Amount Received From Swap
        return After - before;
    }

    function _swapToNBL(address token, uint amount) internal returns (uint256) {

        // NBL Balance Before
        uint256 before = balanceOf(address(this));

        // Swap Path
        address[] memory sPath = new address[](3);
        sPath[0] = token;
        sPath[1] = router.WETH();
        sPath[2] = NBL;

        // Make Swap
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amount,
            0,
            sPath,
            address(this),
            block.timestamp + 10
        );

        // NBL Balance After
        uint256 After = balanceOf(address(this));
        require(
            After > before,
            'Zero Received'
        );

        // Amount Received From Swap
        return After - before;
    }

    function balanceOf(address user) public view returns (uint256) {
        return IERC20(NBL).balanceOf(user);
    } 
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

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
pragma solidity 0.8.14;

interface IGovernance {
    function getOwner() external view returns (address);
    function hasPermissions(address user, uint8 rank) external view returns (bool);
}

contract NBLGovernance {

    /**
        Governance
     */
    IGovernance public constant governance = IGovernance(0x923c24d71013005fc773DB673776032dd5f0a62a);

    /**
        Ensures Authority
     */
    modifier onlyOwner(){
        require(
            msg.sender == governance.getOwner(),
            'Only Owner'
        );
        _;
    }

    function getOwner() external view returns (address) {
        return governance.getOwner();
    }

    function hasPermissions(address user, uint8 rank) public view returns (bool) {
        return governance.hasPermissions(user, rank);
    }

}