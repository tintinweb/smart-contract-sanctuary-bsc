/**
 *Submitted for verification at BscScan.com on 2022-08-31
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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

interface IBEP20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function burn(uint256 amount, bytes32 to) external;
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

interface IPancakeswapRouter{
    function factory() external view returns (address);
    function WETH() external view returns (address);

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

contract TSwap is Ownable {
    using SafeMath for uint256;

    IPancakeswapRouter public pancakeSwap = IPancakeswapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    IBEP20 public busdToken;

    address[] public teamTokens;

    uint256 public burnFee = 120;
    uint256 public profitFee = 10;
    address public DEAD = 0x000000000000000000000000000000000000dEaD;
    address public profitaddress = 0xa8c8af95deB2FB63d55a0B9c66471A06f11E79D2;

    address public prizeAddress = 0xa8c8af95deB2FB63d55a0B9c66471A06f11E79D2;
    address public marketingAddress = 0xa8c8af95deB2FB63d55a0B9c66471A06f11E79D2;
    address public treasuryAddress = 0xa8c8af95deB2FB63d55a0B9c66471A06f11E79D2;

    uint256 public prizeFee = 4;
    uint256 public liquidityFee = 3;
    uint256 public marketingFee = 2;
    uint256 public treasuryFee = 1;
    uint256 public totalFee = prizeFee + liquidityFee + marketingFee + treasuryFee;

    constructor (address _busdToken) {
        busdToken = IBEP20(_busdToken);
    }
    
    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, 'PancakeRouter: EXPIRED');
        _;
    }

    function checkBUSDAproval() public view returns (uint256 approval) {
        approval = busdToken.allowance(address(pancakeSwap), address(this));
    }

    function addTeamToken(address _address) public onlyOwner {
        teamTokens.push(_address);
    }

    function isTeamToken(address _address) private view returns (bool result) {
        result = false;

        for (uint i=0; i<teamTokens.length; i++) {
            if (teamTokens[i] == _address) result = true;
        }
    }

    function setPrizeAddress(address _address) public onlyOwner {
        prizeAddress = _address ;
    }

    function setMarketingAddress(address _address) public onlyOwner {
        marketingAddress = _address ;
    }

    function setTreasuryAddress(address _address) public onlyOwner {
        treasuryAddress = _address ;
    }

    function setPrizeFee(uint _fee) public onlyOwner {
        prizeFee = _fee;
    }

    function setLiquidityFee(uint _fee) public onlyOwner {
        liquidityFee = _fee;
    }

    function setMarketingFee(uint _fee) public onlyOwner {
        marketingFee = _fee;
    }

    function setTreasuryFee(uint _fee) public onlyOwner {
        treasuryFee = _fee;
    }
    
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external virtual ensure(deadline) returns (uint amountA, uint amountB, uint liquidity) {
        require(isTeamToken(tokenA) || isTeamToken(tokenB) || tokenA == address(busdToken) || tokenB == address(busdToken), "Token is not correct");

        IBEP20(tokenA).transferFrom(msg.sender, address(this), amountADesired);
        IBEP20(tokenB).transferFrom(msg.sender, address(this), amountBDesired);

        (amountA, amountB, liquidity) = pancakeSwap.addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin, to, deadline);
    }

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) public virtual onlyOwner ensure(deadline) onlyOwner returns (uint amountA, uint amountB) {
        (amountA, amountB) = pancakeSwap.removeLiquidity(tokenA, tokenB, liquidity, amountAMin, amountBMin, to, deadline);
    }

    struct SwapVariables {
        uint256 liquidityAmount;
        address[] pathEth;
        address[] pathToken;
        uint256[] desiredTokenAmounts;
    }

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts) {
        uint256 initialBalance = address(this).balance; 

        if (isTeamToken(path[0])){
            SwapVariables memory variables;

            IBEP20(path[0]).transferFrom(msg.sender, address(this), amountIn);

            IBEP20(path[0]).transfer(prizeAddress, amountIn.mul(prizeFee).div(100));
            IBEP20(path[0]).transfer(marketingAddress, amountIn.mul(marketingFee).div(100));
            IBEP20(path[0]).transfer(treasuryAddress, amountIn.mul(treasuryFee).div(100));

            variables.liquidityAmount = amountIn.mul(liquidityFee).div(100);

            variables.pathEth = new address[](2);
            variables.pathEth[0] = path[0];
            variables.pathEth[1] = pancakeSwap.WETH();

            pancakeSwap.swapExactTokensForETHSupportingFeeOnTransferTokens(
                variables.liquidityAmount.div(2),
                0,
                variables.pathEth,
                address(this),
                block.timestamp + 5 minutes
            );

            variables.pathToken = new address[](2);
            variables.pathToken[0] = address(pancakeSwap.WETH());
            variables.pathToken[1] = address(path[0]);

            variables.desiredTokenAmounts = pancakeSwap.getAmountsOut(address(this).balance - initialBalance, variables.pathToken);

            pancakeSwap.addLiquidityETH{value: address(this).balance - initialBalance}(
                address(path[0]),
                variables.desiredTokenAmounts[1],
                0,
                0,
                payable(address(this)),
                block.timestamp + 5 minutes
            );

            ( amounts ) = pancakeSwap.swapExactTokensForTokens(amountIn.mul(100 - totalFee).div(100), amountOutMin, path, to, deadline);

        } else {
            SwapVariables memory variables;

            busdToken.transferFrom(msg.sender, address(this), amountIn);

            busdToken.transfer(prizeAddress, amountIn.mul(prizeFee).div(100));
            busdToken.transfer(marketingAddress, amountIn.mul(marketingFee).div(100));
            busdToken.transfer(treasuryAddress, amountIn.mul(treasuryFee).div(100));

            variables.liquidityAmount = amountIn.mul(liquidityFee).div(100);

            variables.pathEth = new address[](2);
            variables.pathEth[0] = address(busdToken);
            variables.pathEth[1] = pancakeSwap.WETH();

            pancakeSwap.swapExactTokensForETHSupportingFeeOnTransferTokens(
                variables.liquidityAmount.div(2),
                0,
                variables.pathEth,
                address(this),
                block.timestamp + 5 minutes
            );

            variables.pathToken = new address[](2);
            variables.pathToken[0] = address(pancakeSwap.WETH());
            variables.pathToken[1] = address(path[1]);

            uint[] memory amountToken;
            (amountToken) = pancakeSwap.swapExactTokensForTokens(variables.liquidityAmount.div(2), amountOutMin, path, to, deadline);

            IBEP20(path[1]).approve(address(pancakeSwap), IBEP20(path[1]).totalSupply());

            variables.desiredTokenAmounts = pancakeSwap.getAmountsOut(address(this).balance - initialBalance, variables.pathToken);

            pancakeSwap.addLiquidityETH{value: address(this).balance - initialBalance}(
                address(path[1]),
                variables.desiredTokenAmounts[1],
                0,
                0,
                payable(address(this)),
                block.timestamp + 5 minutes
            );

            ( amounts ) = pancakeSwap.swapExactTokensForTokens(amountIn.mul(100 - totalFee).div(100), amountOutMin, path, to, deadline);
        }
    }
}