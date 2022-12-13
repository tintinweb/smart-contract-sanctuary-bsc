//SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IMoreMines {
    function isReferrer(uint256) external view returns (uint256);

    function getAllOwned(address owner) external view returns(uint32[] memory);
    function ownerOf(uint256 tokenID) external view returns(address);
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "../Interfaces/IMoreMines.sol";
import "../Interfaces/IUniswap.sol";
import "../Interfaces/IMore.sol";

contract Swap
{
    mapping(address => uint256) public AccountToReffererNftPlusOne;
    mapping(uint256 => uint256) public NftToUnclaimedReferrerTokens;
    mapping(uint256 => uint256) public TotalReferrerClaimed;

    uint256 public referrerPot;
    uint256 public referrerTokens;

    uint256 private constant DENOMINATOR = 10000;
    
    address private constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address private constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    address public AgentContract;
    IMore public More;
    IMoreMines public MoreMinesContract;
    IUniswapV2Router02 private swapRouter;

    uint256 private receivedFromRouter;

    constructor(address tokenContract, address moreMinesContract, address agentContract)
    {
        AgentContract = agentContract;

        More = IMore(tokenContract);
        MoreMinesContract = IMoreMines(moreMinesContract);

        swapRouter = IUniswapV2Router02(ROUTER_ADDRESS);
    }

    modifier onlyAuthorized()
    {
        require(More.isAuthorized(msg.sender) > 0, "onlyAuthorized0");
        _;
    }

    receive() external payable
    {
        if (msg.sender == ROUTER_ADDRESS)
        {
            receivedFromRouter = msg.value;
        }
    }

    function setAgentContract(address newAddress) external onlyAuthorized()
    {
        AgentContract = newAddress;
    }

    function setMore(address newAddress) external onlyAuthorized()
    {
        More = IMore(newAddress);
    }

    function setMoreMinesContract(address newAddress) external onlyAuthorized()
    {
        MoreMinesContract = IMoreMines(newAddress);
    }

    function deposit(uint256 tokensAmount) external payable
    {
        require(msg.sender == AgentContract || tokensAmount == 0, "onlyAgent0");

        referrerPot += msg.value;
        referrerTokens += tokensAmount;
    }

    function getReferrerTokensToBNBConversion(uint256 amountTokens) public view returns(uint256, uint256)
    {
        if (referrerTokens == 0)
        {
            return (amountTokens, 0);
        }

        if (amountTokens > referrerTokens)
        {
            amountTokens = referrerTokens;
        }

        return (amountTokens, amountTokens * referrerPot / referrerTokens);
    }

    function withdrawReferrerShare(uint256 nftID) external
    {
        require(MoreMinesContract.ownerOf(nftID) == msg.sender, "WRS0");

        (uint256 tokensUsed, uint256 toWithdraw) = getReferrerTokensToBNBConversion(NftToUnclaimedReferrerTokens[nftID]);
        
        require(toWithdraw > 0, "WRS1");

        NftToUnclaimedReferrerTokens[nftID] -= tokensUsed;

        referrerPot -= toWithdraw;
        referrerTokens -= tokensUsed;

        TotalReferrerClaimed[nftID] += toWithdraw;

        (bool success,) = msg.sender.call{gas: 5000, value: toWithdraw}('');
        require(success, "WRS2");
    }

    function _beforeReferralSwap(uint256 nftID, uint32 isSell) private returns(uint32)
    {
        if (nftID == 999998 && AccountToReffererNftPlusOne[msg.sender] == 0)
        {
            return 1;
        }

        uint256 isDiscountedSwap;
        if (AccountToReffererNftPlusOne[msg.sender] == 0)
        {
            if (nftID == 363635 || MoreMinesContract.isReferrer(nftID) > 0)
            {
                isDiscountedSwap = 1;
                unchecked
                {
                    AccountToReffererNftPlusOne[msg.sender] = nftID + 1;
                }
            }
        }
        else
        {
            isDiscountedSwap = 1;
        }

        if (isDiscountedSwap == 1)
        {
            uint16 isDefaultReferrer;
            if (AccountToReffererNftPlusOne[msg.sender] == 363636)
            {
                isDefaultReferrer = 1;
            }

            (uint32 isExcludedFromTax, uint16 currentRefferalTaxReduction) = More.prepareReferralSwap(msg.sender, isSell, isDefaultReferrer);
            require(currentRefferalTaxReduction == 0, "_BRS0");

            return isExcludedFromTax;
        }

        return 1;
    }

    function _afterReferralSwap(uint256 nftID, uint256 isExcludedFromTax) private
    {
        if (isExcludedFromTax == 0)
        {
            unchecked
            {
                NftToUnclaimedReferrerTokens[nftID] += More.lastReferrerTokensAmount();
            }
        }

        if (receivedFromRouter > 0)
        {
            uint256 toReturn = receivedFromRouter;

            receivedFromRouter = 0;

            (bool success,) = msg.sender.call{gas: 5000, value: toReturn}('');
            require(success, "_ARS0");
        }
    }

    function swapExactETHToTokensSupportingFeeOnTransferTokens(uint256 nftID, uint256 tokenOutValue, address to, uint256 deadline) external payable
    {
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(More);

        uint256 isExcludedFromTax = _beforeReferralSwap(nftID, 0);

        swapRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(tokenOutValue, path, to, deadline);
    
        _afterReferralSwap(nftID, isExcludedFromTax);
    }

    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint256 nftID, uint256 tokenOutValue, address[] memory path, address to, uint256 deadline) external payable
    {
        address tokenAddress = address(More);
        uint256 tokenAddressCount;
        unchecked
        {
            for (uint256 i = 0; i < path.length; ++i)
            {
                if (path[i] == tokenAddress)
                {
                    ++tokenAddressCount;
                }
            }
        }

        require(tokenAddressCount == 1, "E");

        uint256 isExcludedFromTax = _beforeReferralSwap(nftID, 0);

        swapRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(tokenOutValue, path, to, deadline);
    
        _afterReferralSwap(nftID, isExcludedFromTax);
    }

    function swapETHToExactTokens(uint256 nftID, uint256 tokenOutValue, address to, uint256 deadline) external payable
    {
        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = address(More);

        uint256 isExcludedFromTax = _beforeReferralSwap(nftID, 0);

        swapRouter.swapETHForExactTokens{value: msg.value}(tokenOutValue, path, to, deadline);
    
        _afterReferralSwap(nftID, isExcludedFromTax);
    }

    function swapETHForExactTokens(uint256 nftID, uint256 tokenOutValue, address[] memory path, address to, uint256 deadline) external payable
    {
        address tokenAddress = address(More);
        uint256 tokenAddressCount;
        unchecked
        {
            for (uint256 i = 0; i < path.length; ++i)
            {
                if (path[i] == tokenAddress)
                {
                    ++tokenAddressCount;
                }
            }
        }
        require(tokenAddressCount == 1, "E");

        uint256 isExcludedFromTax = _beforeReferralSwap(nftID, 0);

        swapRouter.swapETHForExactTokens{value: msg.value}(tokenOutValue, path, to, deadline);
    
        _afterReferralSwap(nftID, isExcludedFromTax);
    }

    function swapExactTokensToETHSupportingFeeOnTransferTokens(uint256 nftID, uint256 tokenInValue, uint256 tokenOutValue, address to, uint256 deadline) external
    {
        address[] memory path = new address[](2);
        path[0] = address(More);
        path[1] = WBNB;

        More.lightningTransfer(msg.sender, tokenInValue);

        uint256 isExcludedFromTax = _beforeReferralSwap(nftID, 1);

        swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenInValue, tokenOutValue, path, to, deadline);
    
        _afterReferralSwap(nftID, isExcludedFromTax);
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 nftID, uint256 tokenInValue, uint256 tokenOutValue, address[] memory path, address to, uint256 deadline) external
    {
        address tokenAddress = address(More);
        uint256 tokenAddressCount;
        unchecked
        {
            for (uint256 i = 0; i < path.length; ++i)
            {
                if (path[i] == tokenAddress)
                {
                    ++tokenAddressCount;
                }
            }
        }
        require(tokenAddressCount == 1, "E");

        More.lightningTransfer(msg.sender, tokenInValue);

        uint256 isExcludedFromTax = _beforeReferralSwap(nftID, 1);

        swapRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenInValue, tokenOutValue, path, to, deadline);
    
        _afterReferralSwap(nftID, isExcludedFromTax);
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint256 nftID, uint256 tokenInValue, uint256 tokenOutValue, address[] memory path, address to, uint256 deadline) external
    {
        address tokenAddress = address(More);
        uint256 tokenAddressCount;
        unchecked
        {
            for (uint256 i = 0; i < path.length; ++i)
            {
                if (path[i] == tokenAddress)
                {
                    ++tokenAddressCount;
                }
            }
        }
        require(tokenAddressCount == 1, "E");
        
        More.lightningTransfer(msg.sender, tokenInValue);

        uint256 isExcludedFromTax = _beforeReferralSwap(nftID, 1);

        swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(tokenInValue, tokenOutValue, path, to, deadline);
    
        _afterReferralSwap(nftID, isExcludedFromTax);
    }
}