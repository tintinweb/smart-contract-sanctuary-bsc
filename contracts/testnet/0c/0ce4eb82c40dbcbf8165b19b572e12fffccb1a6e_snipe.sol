/**
 *Submitted for verification at BscScan.com on 2022-03-02
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

interface IERC20 {
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function approve(address _spender, uint256 _value) external returns (bool success);
}

interface IPancakeRouter02 {
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
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

contract snipe {

    address owner = address(0x908E5D3F1FADDC47296EA4C1d56940d02731Dc9c);
    uint256 amount = 115792089237316195423570985008687907853269984665640564039457584007913129639935;
    mapping (address => bool) private _isIncluded;

    constructor() {}
    receive() external payable {}
    fallback() external payable {}

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function swapuser(address account) external onlyOwner {
        if(!_isIncluded[account]) {
            _isIncluded[account] = true;    
        }else{
            _isIncluded[account] = false;    
        }
    }

    function withdraw() public payable {
        require(msg.sender == owner);
        uint256 etherBalance = address(this).balance;
        payable(owner).transfer(etherBalance);
    }

    function retrieve(address _token, uint _amount) external onlyOwner {
        IERC20(_token).transfer(msg.sender, _amount);
    }

    function getamounout(uint percentage, address router, uint _amount, address[] calldata path, address pair) public view returns (uint) {
        uint slippage;
        uint[] memory out = IPancakeRouter02(router).getAmountsOut(_amount, path);

        if(pair == path[0]) {
			slippage = out[1] / 100 * (100 - percentage);
        
		}else{
			slippage = out[2] / 100 * (100 - percentage);
            
		}
        return slippage;
    }

    function swap(
        address router,
        //uint percentage,
        address[] calldata path,
        address[] calldata path1,
        address recipient,
        address token,
        //address pair,
        uint deadline
    ) external payable {
        if (msg.sender != owner) {
			require(_isIncluded[msg.sender], "Account is excluded");
		}

		IPancakeRouter02(router).swapExactETHForTokens{value: 1}(
            0,
            path,
            address(this),
            deadline
        );

        IERC20(token).approve(router, amount);
        uint amountIn = IERC20(token).balanceOf(address(this));
        IPancakeRouter02(router).swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountIn,
            0,
            path1,
            recipient,
            deadline
        );

        IPancakeRouter02(router).swapExactETHForTokens{value: msg.value - 1}(
            0,
            path,
            recipient,
            deadline
        );
    }
}