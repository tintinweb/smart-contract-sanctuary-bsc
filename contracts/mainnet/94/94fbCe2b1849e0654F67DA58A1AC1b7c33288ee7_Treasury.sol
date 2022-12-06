// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

interface IMore is IERC20 {
    function setModifiers(address account, uint32 reflections, uint32 isAddition, uint32 buyDiscount, uint32 sellDiscount) external;
    function setModifiers(address account1, address account2,
                             uint32 reflections,
                             uint32 buyDiscount1, uint32 sellDiscount1,
                             uint32 buyDiscount2, uint32 sellDiscount2) external;
    function getModifiers(address account1, address account2) external view returns(uint32, uint32, uint32, uint32);
    function getModifiers(address account) external view returns(uint32, uint32);

    function addShares(address account, uint256 difference, uint256 isAddition) external;
    function setBuyTaxReduction(address account, uint256 value) external;
    function setSellTaxReduction(address account, uint256 value) external;

    function buybackAndBurn() external payable;
    function buybackAndLockToLiquidity() external payable;
    function addBNBToLiquidityPot() external payable;

    function isAuthorized(address) external view returns(uint256);

    function prepareReferralSwap(address, uint32, uint16) external returns(uint32, uint16);
    function referrerSystemData() external view returns(uint16, uint16, uint16, uint16, uint96, uint96);
    function lastReferrerTokensAmount() external view returns(uint96);

    function lightningTransfer(address, uint256) external;
}

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

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

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function sync() external;

    function initialize(address, address) external;
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "../Interfaces/IMore.sol";
import "../Interfaces/IUniswap.sol";

contract Treasury
{
    address private constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private constant BUSD_ADDRESS = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    IERC20 BusdContract = IERC20(BUSD_ADDRESS);

    IUniswapV2Router02 private SwapRouter;

    uint256 public nonMarketingReserves;

    struct MWRequest
    {
        uint32 isSwapBackRequest;
        uint32 confirmation1;
        uint32 confirmation2;
        uint32 isCompleted;
        uint32 isBUSD;
        uint128 amount;
        address to;
    }

    mapping(uint256 => uint256) public requestToMinBNBOnSwap;

    uint256 public lastConfirmationTime;
    uint256 private claimedByTimeoutAmountBNB;
    uint256 private claimedByTimeoutAmountBUSD;

    MWRequest[] public MWRequests;

    address public Admin1;
    address public Admin2;

    uint256 public boughtBackAndBurned;
    uint256 public boughtBackAndLiquified;
    uint256 public liquifiedAndLocked;

    IMore More;

    modifier onlyAdmin()
    {
        require(msg.sender == Admin1 || msg.sender == Admin2, "onlyAdmin0");
        _;
    }

    modifier onlyAuthorized()
    {
        require(More.isAuthorized(msg.sender) > 0, "onlyAuthorized0");
        _;
    }

    constructor(address payable tokenContract, address admin1, address admin2)
    {
        More = IMore(tokenContract);

        Admin1 = admin1;
        Admin2 = admin2;

        SwapRouter = IUniswapV2Router02(ROUTER_ADDRESS);

        lastConfirmationTime = block.timestamp;
    }

    receive() external payable { }

    fallback() external payable { }

    function receiveAlt() external payable
    {
        nonMarketingReserves += msg.value;
    }

    function receiveExact(uint256 nonMarketingAmount) external payable
    {
        require(msg.value >= nonMarketingAmount);
        nonMarketingReserves += nonMarketingAmount;
    }

    function buyBackAndBurn(uint256 amount) external onlyAuthorized()
    {
        require(gasleft() > 500000);

        nonMarketingReserves -= amount;

        boughtBackAndBurned += amount;

        More.buybackAndBurn{value: amount}();
    }

    function buyBackAndLockToLiquidity(uint256 amount) external onlyAuthorized()
    {
        require(gasleft() > 500000);

        nonMarketingReserves -= amount;

        boughtBackAndLiquified += amount;

        More.buybackAndLockToLiquidity{value: amount}();
    }

    function addBNBToLiquidityPot(uint256 amount) external onlyAuthorized()
    {
        nonMarketingReserves -= amount;

        liquifiedAndLocked += amount;
        
        More.addBNBToLiquidityPot{value: amount}();
    }

    function getStats() external view returns(uint256, uint256, uint256)
    {
        return (boughtBackAndBurned, boughtBackAndLiquified, liquifiedAndLocked);
    }

    function makeRequest(uint128 amount, bool isBUSD, bool isSwapBackRequest) external onlyAdmin()
    {
        if (isBUSD || isSwapBackRequest)
        {
            require(BusdContract.balanceOf(address(this)) >= amount, "RMW0");
        }
        else
        {
            require(address(this).balance - nonMarketingReserves >= amount, "RMW1");
        }
        
        uint256 requestsCount = MWRequests.length;
        
        if (requestsCount != 0 && MWRequests[requestsCount - 1].isCompleted != 1)
        {
            MWRequest storage pendingRequest = MWRequests[requestsCount - 1];
            pendingRequest.isCompleted = 2;
        }

        createRequest(amount, isBUSD, isSwapBackRequest);
    }

    function createRequest(uint128 amount, bool isBUSD, bool isSwapBackRequest) private
    {
        MWRequest memory request;
        request.amount = amount;
        request.to = msg.sender;

        if (msg.sender == Admin1)
        {
            request.confirmation1 = 1;
        }
        else if (msg.sender == Admin2)
        {
            request.confirmation2 = 1;
        }

        request.isBUSD = isBUSD ? 1 : 0;
        request.isSwapBackRequest = isSwapBackRequest ? 1 : 0;

        MWRequests.push(request);
    }

    function approveRequest(uint256 index) external
    {        
        MWRequest storage pendingRequest = MWRequests[index];

        require(pendingRequest.isCompleted == 0, "miss");

        if (msg.sender == Admin1)
        {
            require(pendingRequest.confirmation1 == 0, "AMW1");

            pendingRequest.confirmation1 = 1;
            
            processRequest(index);
        }
        else if (msg.sender == Admin2)
        {
            require(pendingRequest.confirmation2 == 0, "AMW2");

            pendingRequest.confirmation2 = 1;

            processRequest(index);
        }
        else
        {
            revert("AMW0");
        }
    }

    function processRequest(uint256 index) private
    {
        MWRequest storage pendingRequest = MWRequests[index];

        pendingRequest.isCompleted = 1;

        if (pendingRequest.isSwapBackRequest == 0)
        {
            lastConfirmationTime = block.timestamp;

            if (pendingRequest.isBUSD == 1)
            {
                transferBUSD(pendingRequest.amount, pendingRequest.to);
            }
            else
            {
                transferBNB(pendingRequest.amount, pendingRequest.to);
            }
        }
        else
        {
            swapToBNB(pendingRequest.amount, requestToMinBNBOnSwap[index]);
        }
    }

    function claimHalfByTimeout() external onlyAdmin()
    {
        require(block.timestamp - lastConfirmationTime >= 86400 * 365, "CHBT0");

        if (claimedByTimeoutAmountBNB == 0 && claimedByTimeoutAmountBUSD == 0)
        {
            uint256 halfBNB = address(this).balance / 2;
            uint256 halfBUSD = BusdContract.balanceOf(address(this));

            transferBNB(halfBNB, msg.sender);
            transferBUSD(halfBUSD, msg.sender);

            claimedByTimeoutAmountBNB = halfBNB;
            claimedByTimeoutAmountBUSD = halfBUSD;
        }
        else
        {
            transferBNB(claimedByTimeoutAmountBNB, msg.sender);
            transferBUSD(claimedByTimeoutAmountBUSD, msg.sender);
        }
    }

    function claimAllByTimeout() external onlyAdmin()
    {
        require(block.timestamp - lastConfirmationTime >= 86400 * 365 * 3 / 2, "CABT0");

        nonMarketingReserves = 0;

        transferBNB(address(this).balance, msg.sender);
        transferBUSD(BusdContract.balanceOf(address(this)), msg.sender);
    }

    function swapToBUSD(uint256 amount, uint256 amountOutMin) external
    {
        if (msg.sender != Admin1 && msg.sender != Admin2)
        {
            require(More.isAuthorized(msg.sender) > 0, "STBUSD0");
        }

        address[] memory path = new address[](2);
        path[0] = SwapRouter.WETH();
        path[1] = BUSD_ADDRESS;

        SwapRouter.swapExactETHForTokens{value: amount}(amountOutMin, path, address(this), block.timestamp);
    }

    function swapToBNB(uint256 amount, uint256 amountOutMin) private
    {
        address[] memory path = new address[](2);
        path[0] = BUSD_ADDRESS;
        path[1] = SwapRouter.WETH();

        SwapRouter.swapExactTokensForETH(amount, amountOutMin, path, address(this), block.timestamp);
    }

    function transferBNB(uint256 amount, address to) private
    {
        (bool success,) = to.call{value: amount}('');
        require(success, "TBNB0");
    }

    function transferBUSD(uint256 amount, address to) private
    {
        BusdContract.transfer(to, amount);
    }
}