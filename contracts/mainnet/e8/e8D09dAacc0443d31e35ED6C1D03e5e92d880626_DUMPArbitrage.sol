/**
 *Submitted for verification at BscScan.com on 2022-07-20
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

interface IDUMP {
    function sell(uint256 tokenAmount) external returns (address, uint256);
}

contract DUMPArbitrage is Ownable {

    IUniswapV2Router02 private constant router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    address private constant PUMP = 0x91Ebe3E0266B70be6AE41b8944170A27A08E3C2e;

    address private constant DUMP = 0x6b8a384DDe6FC779342Fbb2E4a8EcF73eD18D151;

    address private constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    address public DUMPRecipient = 0xc5D5c35E65ce327D15b4923cE01dB3FF4c5a1350;
    address public xSurgeRecipient = 0x13DDe481A8b2F5D9c43ED566d852612CcCB1AbeC;
    
    // cost to run cycle + incentive
    uint256 public gasCost = 25 * 10**14;

    address[] private BNBToPump;
    address[] private PumpToBNB;

    address[] private pumpToDump;
    address[] private dumpToPump;

    
    constructor() {

        BNBToPump = new address[](2);
        BNBToPump[0] = WBNB;
        BNBToPump[1] = PUMP;

        PumpToBNB = new address[](2);
        PumpToBNB[0] = PUMP;
        PumpToBNB[1] = WBNB;

        pumpToDump = new address[](2);
        pumpToDump[0] = PUMP;
        pumpToDump[1] = DUMP;

        dumpToPump = new address[](2);
        dumpToPump[0] = DUMP;
        dumpToPump[1] = PUMP;

        doApprovals();
    }

    function setDUMPRecipient(address recipient_) external onlyOwner {
        DUMPRecipient = recipient_;
    }

    function setxSurgeRecipient(address recipient_) external onlyOwner {
        xSurgeRecipient = recipient_;
    }

    function setGasCost(uint256 gasCost_) external onlyOwner {
        gasCost = gasCost_;
    }

    function extractProfits() public {

        (bool s,) = payable(xSurgeRecipient).call{value: ( address(this).balance * 25 ) / 100 }("");
        require(s, 'F');

        (bool s2,) = payable(DUMPRecipient).call{value:address(this).balance}("");
        require(s2, 'F');
    }

    function withdraw(address token) external onlyOwner {
        uint256 bal = IERC20(token).balanceOf(address(this));
        require(bal > 0, 'Zero Tokens');
        IERC20(token).transfer(msg.sender, bal);
    }

    function doApprovals() public {
        IERC20(DUMP).approve(address(router), 10**70);
        IERC20(PUMP).approve(address(router), 10**70);
    }
    
    function buyCycle() external payable {

        // BNB -> PUMP
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: address(this).balance}(
            0,
            BNBToPump,
            address(this),
            block.timestamp + 10
        );

        // PUMP -> DUMP
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            IERC20(PUMP).balanceOf(address(this)),
            0,
            pumpToDump,
            address(this),
            block.timestamp + 10
        );

        // DUMP -> stable
        (address stable,) = IDUMP(DUMP).sell(IERC20(DUMP).balanceOf(address(this)));

        // build stable path
        address[] memory stablePath = new address[](2);
        stablePath[0] = stable;
        stablePath[1] = WBNB;

        // stable -> BNB
        IERC20(stable).approve(address(router), 10**65);
        router.swapExactTokensForETH(
            IERC20(stable).balanceOf(address(this)),
            0,
            stablePath,
            address(this),
            block.timestamp
        );

        // Send Initiator their value plus gas cost
        (bool s,) = payable(msg.sender).call{value: msg.value + gasCost}("");
        require(s, 'Not Profitable');

        // take profits
        extractProfits();
        delete stablePath;
    }
    
    function sellCycle() external payable {

        // Buy DUMP
        (bool s,) = payable(DUMP).call{value: address(this).balance}("");
        require(s);

        // DUMP -> PUMP
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            IERC20(DUMP).balanceOf(address(this)),
            0,
            dumpToPump,
            address(this),
            block.timestamp + 10
        );

        // PUMP -> BNB
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            IERC20(PUMP).balanceOf(address(this)),
            0,
            PumpToBNB,
            address(this),
            block.timestamp
        );

        // Send Initiator their value plus gas cost
        (bool s2,) = payable(msg.sender).call{value: msg.value + gasCost}("");
        require(s2, 'Not Profitable');

        // take profits
        extractProfits();
    }
 
    receive() external payable {}
    
}