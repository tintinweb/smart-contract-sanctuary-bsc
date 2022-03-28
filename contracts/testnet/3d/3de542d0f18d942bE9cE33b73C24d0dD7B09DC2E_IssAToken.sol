// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./SafeMath.sol";
import "./SafeERC20.sol";
import "./Ownable.sol";
import "./Config.sol";
interface IPancakeRouter01 {
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

contract IssAToken is  Ownable {
    using SafeMath for uint256;
    using Address for address;
    using SafeERC20 for IERC20;
    Config public config;
    bool isPledge = true; 
    uint256 public totalPledgeAmount; 
    uint256 public totalProfixAmount; 
    uint public price;
    uint256 public minPledge = 10000000000;
    struct PledgeOrder {
        bool isExist; 
        uint256 value; 
        uint256 tokenValue;
    }
    mapping(address => PledgeOrder) public orders;

    event log(uint256 num ,uint256 _value);
    event Pledge(address indexed _user,uint256 _value ,uint256 _tokenValue);

    
 

    function changeMinPledge(uint256 _minPledge) public onlyOwner {
        minPledge = _minPledge;
    }

    function changeIsPledge(bool _isPledge) public onlyOwner {
        isPledge = _isPledge;
    }

    function createOrder(uint256 value,uint256 tokenValue) private {
        orders[msg.sender] = PledgeOrder(
            true,
            value,
            tokenValue
        );
    }
    function getTokenValue(uint256 amount) private returns (uint256){
      uint256 tokenAmount=  amount.mul(10**6).div(price);
    }

    function pledge(uint256 amount) public {
        require(isPledge, "is disable");
        require(amount >= minPledge, "less pledge");
        uint256 tokenAmount=amount;
        if (orders[msg.sender].isExist == false) {
            orders[msg.sender]=PledgeOrder(true,amount,tokenAmount);
        } else {
            PledgeOrder storage order = orders[msg.sender];
            order.value = order.value.add(amount);
            order.tokenValue = order.tokenValue.add(tokenAmount);
        }
        IERC20(config.getAddressMap("USDT")).safeTransferFrom(msg.sender,address(this),amount);
        IERC20(config.getAddressMap("ISSA")).safeTransferFrom(msg.sender,address(this),tokenAmount);
        totalPledgeAmount = totalPledgeAmount.add(amount);
        totalProfixAmount = totalProfixAmount.add(tokenAmount);
        emit Pledge(msg.sender,amount ,tokenAmount);
    }
    function setConfig(Config _config) public onlyOwner {
        config = _config;
    }
}