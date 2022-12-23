// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import {IERC20} from "./IERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol";

contract DiamondHands {

    struct Order {
        uint inputAmount;
        address outputToken;
        uint minOutputAmount;
        uint deadline;
    }

    event OrderCreated(
        address indexed from,
        address indexed inputToken,
        uint indexed blockNumber,
        uint inputAmount,
        address outputToken,
        uint minOutputAmount,
        uint deadline
    );

    event OrderWithdrawn(
        address indexed from,
        address indexed inputToken,
        uint indexed blockNumber,
        uint inputAmount,
        address outputToken,
        uint minOutputAmount,
        uint actualAmount,
        uint poolFee
    );

    event UpdateFeePercent(
        uint oldValue,
        uint newValue
    );

    event UpdateFeePool(
        address oldAddress,
        address newAddress
    );

    address owner;
    // 100%
    uint constant MAX_PERCENT = 100 ether;
    // 1%
    uint constant MAX_FEE_PERCENT = 1 ether;
    address feePool;
    // actual feePercent = feePercent / 1e18
    uint feePercent = 0 wei;
    mapping(address => mapping(address => mapping(uint => Order))) orderBook;

    constructor(){
        owner = msg.sender;
        feePercent = 0 wei;
    }

    modifier ownerOnly() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function changeOwner(address _newOwner) ownerOnly public {
        owner = _newOwner;
    }

    function deposit(address _inputToken, uint _amount, address _outputToken, uint _minOutputAmount, uint _deadline) public returns (uint) {
        IERC20 inputToken = IERC20(_inputToken);
        require(inputToken.balanceOf(msg.sender) > _amount, "Insufficient balance!");
        uint allowance = IERC20(_inputToken).allowance(msg.sender, address(this));
        if (allowance < _amount) {
            //TODO: Approve
        }
        bool success = inputToken.transferFrom(msg.sender, address(this), _amount);
        require(success, "Unable to deposit token!");

        orderBook[msg.sender][_inputToken][block.number] = Order(_amount, _outputToken, _minOutputAmount, _deadline);
        emit OrderCreated(msg.sender, _inputToken, block.number, _amount, _outputToken, _minOutputAmount, _deadline);
        return block.number;
    }

    function getDepositedAmount(address _from, address _token, uint _blockNumber) view public returns (uint){
        Order memory order = orderBook[_from][_token][_blockNumber];
        return order.inputAmount;
    }

    function withdraw(address _uniswapRouter, address _token, uint _blockNumber, uint _deadline) public {
        Order memory order = _getOrder(msg.sender, _token, _blockNumber);
        require(isWithdrawable(_uniswapRouter, msg.sender, _token, _blockNumber), "Your order is not withdrawable!");

        uint poolFeeAmount = order.minOutputAmount * (feePercent / MAX_FEE_PERCENT);
        uint minOutputAmount = order.minOutputAmount + poolFeeAmount;

        address[] memory paths = new address[](2);
        paths[0] = _token;
        paths[1] = order.outputToken;

        uint[] memory amounts = IUniswapV2Router01(_uniswapRouter).swapExactTokensForTokens(
            order.inputAmount,
            minOutputAmount,
            paths,
            msg.sender,
            _deadline
        );

        emit OrderWithdrawn(
            msg.sender,
            _token,
            _blockNumber,
            order.inputAmount,
            order.outputToken,
            order.minOutputAmount,
            amounts[1],
            poolFeeAmount
        );

        if (feePercent > 0) {
            require(IERC20(_token).transferFrom(msg.sender, feePool, poolFeeAmount), "Unable to charge pool fee!");
        }
    }

    function getActualOutputAmount(address uniswapRouter, address _from, address _token, uint _blockNumber) view public returns (uint256){
        Order memory order = _getOrder(_from, _token, _blockNumber);
        address[] memory paths = new address[](2);
        paths[0] = _token;
        paths[1] = order.outputToken;
        uint[] memory amounts = IUniswapV2Router01(uniswapRouter).getAmountsOut(order.inputAmount, paths);
        return amounts[1];
    }

    function isWithdrawable(address uniswapRouter, address _from, address _token, uint _blockNumber) view public returns (bool){
        Order memory order = _getOrder(_from, _token, _blockNumber);
        return getActualOutputAmount(uniswapRouter, _from, _token, _blockNumber) >= order.minOutputAmount + order.minOutputAmount * feePercent / MAX_FEE_PERCENT;
    }

    function getCurrentFeePercentInWei() view public returns (uint){
        return feePercent;
    }

    function getMaxFeePercentInWei() view public returns (uint){
        return MAX_FEE_PERCENT;
    }

    function calculatePoolFee(address _from, address _token, uint _blockNumber) view public returns (uint){
        Order memory order = _getOrder(_from, _token, _blockNumber);
        return order.minOutputAmount * (1 + feePercent / MAX_FEE_PERCENT);
    }

    //Return the minimum amount of output that includes pool fee
    function calculateMinOutput(address _from, address _token, uint _blockNumber) view public returns (uint){
        Order memory order = _getOrder(_from, _token, _blockNumber);
        return order.minOutputAmount * (1 + feePercent / MAX_FEE_PERCENT);
    }

    function updateFeePool(address _newAddress) ownerOnly public {
        emit UpdateFeePool(feePool, _newAddress);
        feePool = _newAddress;
    }

    //feePercent must be in the range [0, MAX_FEE_PERCENT]
    function updateFeePercentInWei(uint _newFeePercentInWei) ownerOnly public {
        require(_newFeePercentInWei <= MAX_FEE_PERCENT, "Fee percent must be less than or equals to MAX_FEE_PERCENT");
        emit UpdateFeePercent(feePercent, _newFeePercentInWei);
        feePercent = _newFeePercentInWei;
    }

    function _getOrder(address _from, address _token, uint _blockNumber) view private returns (Order memory){
        return orderBook[_from][_token][_blockNumber];
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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