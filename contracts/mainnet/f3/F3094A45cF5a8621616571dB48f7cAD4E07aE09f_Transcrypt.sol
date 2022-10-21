// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IERC20.sol";
import "./abstracts/Admin.sol";
import "./abstracts/FeeCollector.sol";
import "./interfaces/IDealer.sol";

contract Transcrypt is Admin, FeeCollector {
    uint256 private constant _NEW = 0;
    uint256 private constant _COMPLETED = 1;

    mapping(uint256 => uint256) public orderStatus;
    address public swapRouter;
    address public dealerContract;

    event Purchased(
        uint256 orderId,
        address indexed payer,
        address indexed merchant,
        address inputToken,
        address indexed outputToken,
        uint256 amountIn,
        uint256 amountOut,
        uint256 fee,
        address dealer
    );
    event SwapRouterChanged(address oldSwapRouter, address newSwapRouter);
    event DealerContractChanged(
        address oldDealerContract,
        address newDealerContract
    );

    constructor(
        address _router,
        address _rootAdmin,
        address _feeClaimer,
        address _dealerContract
    ) Admin(_rootAdmin) FeeCollector(_feeClaimer) {
        swapRouter = _router;
        dealerContract = _dealerContract;
    }

    function purchase(
        uint256 orderId,
        address merchant,
        address[] memory tokens,
        uint256 amountInMax,
        uint256 amountOut,
        uint256 deadline,
        address dealer
    ) public {
        require(orderStatus[orderId] == _NEW, "Order was completed");

        uint256 amountOrder;
        uint256 deductedFee;

        if (tokens.length == 2 && tokens[0] == tokens[1]) {
            IERC20(tokens[0]).transferFrom(
                msg.sender,
                address(this),
                amountOut
            );

            (amountOrder, deductedFee) = deductFee(tokens[0], amountOut);
        } else {
            uint256 swapOutput = swapTokensForExactTokens(
                tokens,
                amountOut,
                amountInMax,
                address(this),
                deadline
            );

            (amountOrder, deductedFee) = deductFee(
                tokens[tokens.length - 1],
                swapOutput
            );
        }

        if (dealer == address(0)) {
            IERC20(tokens[tokens.length - 1]).transfer(merchant, amountOrder);
        } else {
            IERC20(tokens[tokens.length - 1]).approve(
                dealerContract,
                amountOrder
            );
            IDealer(dealerContract).createOrderSellTrusted(
                tokens[tokens.length - 1],
                amountOrder,
                1,
                dealer,
                merchant
            );
        }

        orderStatus[orderId] = _COMPLETED;

        emit Purchased(
            orderId,
            msg.sender,
            merchant,
            tokens[0],
            tokens[tokens.length - 1],
            amountInMax,
            amountOrder,
            deductedFee,
            dealer
        );
    }

    function swapTokensForExactTokens(
        address[] memory tokens,
        uint256 _amountOut,
        uint256 _amountInMax,
        address _to,
        uint256 _deadline
    ) private returns (uint256) {
        IERC20(tokens[0]).transferFrom(msg.sender, address(this), _amountInMax);
        IERC20(tokens[0]).approve(swapRouter, _amountInMax);

        // Receive an exact amount of output tokens for as few input tokens as possible
        uint256[] memory amounts = IUniswapV2Router02(swapRouter)
            .swapTokensForExactTokens(
                _amountOut,
                _amountInMax,
                tokens,
                _to,
                _deadline
            );

        return amounts[amounts.length - 1];
    }

    function setFee(uint256 newFee) external onlyRootAdmin {
        _setFee(newFee);
    }

    function setFeeClaimer(address newFeeClaimer) external onlyRootAdmin {
        _setFeeClaimer(newFeeClaimer);
    }

    function setSwapRouter(address newSwapRouter) external onlyRootAdmin {
        address oldSwapRouter = swapRouter;
        swapRouter = newSwapRouter;
        emit SwapRouterChanged(oldSwapRouter, newSwapRouter);
    }

    function setDealerContract(address newDealerContract)
        external
        onlyRootAdmin
    {
        address oldDealerContract = dealerContract;
        dealerContract = newDealerContract;
        emit DealerContractChanged(oldDealerContract, newDealerContract);
    }
}

pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

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

pragma solidity >=0.5.0;

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

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "../interfaces/IAdmin.sol";

contract Admin is IAdmin {

    uint256 private constant _NOT_ADMIN = 0;
    uint256 private constant _ADMIN = 1;

    address public override rootAdmin;
    mapping(address => uint256) public override isAdmin;

    event RootAdminChanged(address indexed oldRoot, address indexed newRoot);
    event AdminUpdated(address indexed account, uint256 indexed isAdmin);

    constructor(address _rootAdmin) {
        rootAdmin = _rootAdmin;
    }

    modifier onlyRootAdmin() {
        require(msg.sender == rootAdmin, "must be root admin");
        _;
    }

    modifier onlyAdmin() {
        require(isAdmin[msg.sender] == _ADMIN , "must be admin");
        _;
    }

    function changeRootAdmin(address _newRootAdmin) public onlyRootAdmin {
        address oldRoot = rootAdmin;
        rootAdmin = _newRootAdmin;
        emit RootAdminChanged(oldRoot, rootAdmin);
    }

    function addAdmin(address _admin) public onlyRootAdmin {
        isAdmin[_admin] = _ADMIN;
        emit AdminUpdated(_admin, _ADMIN);
    }

    function removeAdmin(address _admin) public onlyRootAdmin {
        isAdmin[_admin] = _NOT_ADMIN;
        emit AdminUpdated(_admin, _NOT_ADMIN);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@uniswap/v2-periphery/contracts/interfaces/IERC20.sol";
import "../interfaces/IFeeCollector.sol";

abstract contract FeeCollector is IFeeCollector {
  uint256 public constant override feeDecimals = 4;
  uint256 public constant override shifter = 10**feeDecimals;
  uint256 public override fee = 50; // 4 decimals => 0.005 * 10^4
  address public override feeClaimer;

  mapping(address => uint256) public override tokenFeeReserves;

  event FeeCollected(
    address indexed beneficiary,
    address indexed token,
    uint256 amount
  );
  event FeeClaimerChanged(
    address indexed oldFeeClaimer,
    address indexed newFeeClaimer
  );
  event FeeChanged(uint256 oldFee, uint256 newFee);

  modifier onlyFeeCalimer() {
    require(msg.sender == feeClaimer, "Only fee claimer");
    _;
  }

  constructor(address feeClaimer_) {
    feeClaimer = feeClaimer_;
  }

  function deductFee(address token, uint256 amount)
    internal
    returns (uint256, uint256)
  {
    uint256 collectedFee = (amount * fee) / shifter;
    uint256 output = amount - collectedFee;
    tokenFeeReserves[token] += collectedFee;
    return (output, collectedFee);
  }

  function collectFee(
    address token,
    uint256 amount,
    address beneficiary
  ) external override onlyFeeCalimer {
    uint256 withdrewAmount = amount >= tokenFeeReserves[token]
      ? tokenFeeReserves[token]
      : amount;
    IERC20(token).transfer(beneficiary, withdrewAmount);
    tokenFeeReserves[token] -= withdrewAmount;
    emit FeeCollected(beneficiary, token, withdrewAmount);
  }

  function _setFeeClaimer(address newFeeClaimer) internal {
    address oldFeeCalimer = feeClaimer;
    feeClaimer = newFeeClaimer;
    emit FeeClaimerChanged(oldFeeCalimer, feeClaimer);
  }

  function _setFee(uint256 newFee) internal {
    uint256 oldFee = fee;
    fee = newFee;
    emit FeeChanged(oldFee, fee);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

// TODO: make interface

interface IDealer {
    function createOrderSellTrusted(
        address _tokenAddress,
        uint256 _amount,
        uint256 _feeType,
        address _buyer,
        address _seller
    ) external;
}

pragma solidity >=0.6.2;

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

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface IAdmin {
    function rootAdmin() external view returns (address);
    function isAdmin(address account) external returns (uint256);

    function changeRootAdmin(address _newRootAdmin) external;
    function addAdmin(address _newAdmin) external;
    function removeAdmin(address _admin) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

interface IFeeCollector {
    function feeClaimer() external returns (address);

    function feeDecimals() external returns (uint256);

    function shifter() external returns (uint256);

    function fee() external returns (uint256);

    function tokenFeeReserves(address token) external returns (uint256);

    function collectFee(
        address token,
        uint256 amount,
        address beneficiary
    ) external;

    function setFeeClaimer(
        address newFeeClaimer
    ) external;

    function setFee(uint256 newFee) external;
}