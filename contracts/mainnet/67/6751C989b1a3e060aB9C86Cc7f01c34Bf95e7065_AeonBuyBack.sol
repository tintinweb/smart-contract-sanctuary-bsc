/**
 *Submitted for verification at BscScan.com on 2022-09-18
*/

//SPDX-License-Identifier: Unlicense 

pragma solidity ^0.8.10;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

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

interface IPancakeRouter02 is IPancakeRouter01 {
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

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract AeonBuyBack is Context, Ownable {

    using SafeMath for uint256;
    IPancakeRouter02 router;
    
    constructor ()   {
        router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    }

    uint256 public amountToBurn = 10;
    uint256 public amountToBuyBack = 90;
    uint256 public amountForDev = 40;
    uint256 public amountForMarketing = 50;
    uint256 public amountToBuyBurn = 10;
    address public TokenAddress = 0x9A8c2c5CE1825ae33CA27B598849744BF8E30fDc;
    address constant public DEAD = 0x000000000000000000000000000000000000dEaD;
    address payable public GameWallet = payable(0xCADE603da39560F2D2d1184FDAC3Df91C3cE5637);
    address payable public MarketingWallet = payable(0xCADE603da39560F2D2d1184FDAC3Df91C3cE5637);
    address payable public DevWallet = payable(0xCADE603da39560F2D2d1184FDAC3Df91C3cE5637);
    address payable OwnerWallet = payable(0x084D08a58c7670E226327bbD042A6938a0894b74);

    receive() external payable {}

    function changeGamerWaller(address payable newWallet) external onlyOwner {
        require(msg.sender == OwnerWallet, "Only Owner function");
        GameWallet = newWallet;
    }

    function changeMarketingWallet(address payable newWallet) external onlyOwner {
        require(msg.sender == OwnerWallet, "Only Owner function");
        MarketingWallet = newWallet;
    }

    function changeDevWallet(address payable newWallet) external onlyOwner {
        require(msg.sender == OwnerWallet, "Only Owner function");
        DevWallet = newWallet;
    }

    function changeBurnBuyBack(uint256 burnAmount, uint256 buyback) external onlyOwner {
        require(msg.sender == OwnerWallet, "Only Owner function");
        require(burnAmount.add(buyback) <= 100, "Split cannot be over 100%");

        amountToBurn = burnAmount;
        amountToBuyBack = buyback;
    }

    function changeMarketingDev(uint256 marketing, uint256 dev) external onlyOwner {
        require(msg.sender == OwnerWallet, "Only Owner function");
        require(marketing.add(dev) <= 100, "Split cannot be over 100%");
        uint256 amountleft = marketing.add(dev).sub(100);
        amountForDev = dev;
        amountForMarketing = marketing;
        amountToBuyBurn = amountleft;
    }

    function RemoveRandomTokens(address _token, address _to, uint256 _amount) public onlyOwner returns(bool _sent){
        _sent = IERC20(_token).transfer(_to, _amount);
    }

    function sweepETH() external onlyOwner {
        payable(OwnerWallet).transfer(address(this).balance);
    }

    function burnTokens() public {
        uint256 totalAmount = address(this).balance;
        uint256 RemoveDev = totalAmount.mul(amountForDev).div(100);
        uint256 RemoveMarketing = totalAmount.mul(amountForMarketing).div(100);
        MarketingWallet.transfer(RemoveMarketing);
        DevWallet.transfer(RemoveDev);
        uint256 totalToUse = totalAmount.sub(RemoveDev).sub(RemoveMarketing);

        address[] memory path;
        path = new address[](2);
        path[0] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; // WETH
        path[1] = 0x9A8c2c5CE1825ae33CA27B598849744BF8E30fDc; // TOKEN ADDRESS
        router.swapExactETHForTokens{ value: totalToUse }(
            0,
            path,
            address(this),
            block.timestamp
        );
        uint256 totalTokens = IERC20(TokenAddress).balanceOf(address(this));
        uint256 burnAmount = totalTokens.mul(amountToBurn).div(100);
        IERC20 token = IERC20(TokenAddress);
        token.transfer(DEAD, burnAmount);
        token.transfer(GameWallet, IERC20(TokenAddress).balanceOf(address(this)));
    }
}