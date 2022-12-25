// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import {IERC20} from "./IERC20.sol";
import {IUniswapV2Router01} from "./IUniswapV2Router01.sol";

contract DiamondHands {

    struct Order {
        uint inputAmount;
        address outputToken;
        uint minOutputAmount;
        uint deadline;
        uint feePercent;
        bool completed;
    }

    event OrderCreated(
        address indexed from,
        address indexed inputToken,
        uint indexed index,
        uint inputAmount,
        address outputToken,
        uint minOutputAmount,
        uint deadline,
        uint feePercent
    );

    event OrderCompleted(
        address indexed from,
        address indexed inputToken,
        uint indexed index,
        address uniswapRouter,
        address[] paths,
        uint actualOutputAmount
    );

    event UpdateFeePercent(
        uint oldValue,
        uint newValue
    );

    event UpdateFeePool(
        address oldAddress,
        address newAddress
    );

    uint constant MAX_INT = 115792089237316195423570985008687907853269984665640564039457584007913129639935;
    uint constant ONE_HUNDRED_PERCENT = 100 ether;
    // 1%
    uint constant MAX_FEE_PERCENT = 1 ether;
    // 100%
    address feePool;
    // actual feePercent = feePercent / 1e18
    uint feePercent = 0 wei;
    // owner => input_token => index
    mapping(address => mapping(address => mapping(uint => Order))) orderBook;
    address owner;

    constructor(){
        owner = msg.sender;
        feePool = msg.sender;
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
        require(_amount > 0, "Amount must be greater than 0!");
        require(inputToken.transferFrom(msg.sender, address(this), _amount), "Unable to deposit token!");

        uint index = _getNextTokenIndex(msg.sender, _inputToken);
        orderBook[msg.sender][_inputToken][index] = Order(_amount, _outputToken, _minOutputAmount, _deadline, feePercent, false);
        emit OrderCreated(msg.sender, _inputToken, index, _amount, _outputToken, _minOutputAmount, _deadline, feePercent);
        return index;
    }

    function getDepositedAmount(address _from, address _token, uint _index) view public returns (uint){
        Order memory order = _getOrderM(_from, _token, _index);
        return order.inputAmount;
    }

    function withdraw(address _uniswapRouter, address _token, uint _index, address[] memory _paths) public {
        Order storage order = _getOrderS(msg.sender, _token, _index);
        require(order.completed == false, "This order has been withdrawn!");
        uint[] memory amounts = IUniswapV2Router01(_uniswapRouter).getAmountsOut(order.inputAmount, _paths);
        uint actualOutputAmount = amounts[1];
        require(actualOutputAmount >= order.minOutputAmount, "Actual output amount is less than min output amount!");

        uint poolFeeAmount = order.inputAmount * order.feePercent / ONE_HUNDRED_PERCENT;
        uint actualReceivedAmount = order.inputAmount - poolFeeAmount;
        require(
            IERC20(order.outputToken).transferFrom(address(this), msg.sender, actualReceivedAmount),
            "Failed to transfer from contract to sender"
        );

        emit OrderCompleted(
            msg.sender,
            _token,
            _index,
            _uniswapRouter,
            _paths,
            actualReceivedAmount
        );

        order.completed = true;
    }

    function isWithdrawable(
        address uniswapRouter,
        address _from,
        address _token,
        uint _index,
        address[] memory _paths
    ) view public returns (bool){
        Order memory order = _getOrderM(_from, _token, _index);
        if (order.completed) {
            return false;
        }
        return getActualOutputAmount(uniswapRouter, _from, _token, _index, _paths) >= order.minOutputAmount;
    }

    function getActualOutputAmount(
        address _uniswapRouter,
        address _from,
        address _token,
        uint _index,
        address[] memory _paths
    ) view public returns (uint256){
        Order memory order = _getOrderM(_from, _token, _index);
        uint[] memory amounts = IUniswapV2Router01(_uniswapRouter).getAmountsOut(order.inputAmount, _paths);
        return amounts[1];
    }

    function orderCompleted(address _from, address _token, uint _index) view public returns (bool){
        Order memory order = _getOrderM(_from, _token, _index);
        return order.completed;
    }

    function getCurrentFeePercentInWei() view public returns (uint){
        return feePercent;
    }

    function maxFeePercentInWei() pure public returns (uint){
        return MAX_FEE_PERCENT;
    }

    function calculatePoolFee(address _from, address _token, uint _index) view public returns (uint){
        Order memory order = _getOrderM(_from, _token, _index);
        return order.minOutputAmount * feePercent / ONE_HUNDRED_PERCENT;
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

    function _getOrderM(address _from, address _token, uint _index) view internal returns (Order memory){
        Order memory order = orderBook[_from][_token][_index];
        return order;
    }

    function _getOrderS(address _from, address _token, uint _index) view internal returns (Order storage){
        Order storage order = orderBook[_from][_token][_index];
        return order;
    }

    function isOrderExists(address _from, address _token, uint _index) view internal returns (bool){
        return _getOrderM(_from, _token, _index).inputAmount > 0;
    }

    function _getNextTokenIndex(address _from, address _token) view internal returns (uint){
        uint i = 1;
        while (i <= MAX_INT) {
            if (isOrderExists(_from, _token, i)) {
                i++;
            } else {
                return i;
            }
        }
        revert("You can not create more order for this token!");
    }
}

// SPDX-License-Identifier: MIT
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