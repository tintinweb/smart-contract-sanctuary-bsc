/**
 *Submitted for verification at BscScan.com on 2022-08-30
*/

// SPDX-License-Identifier: MIT
 pragma solidity ^0.8.16;
 
interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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
 
 abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return (msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {
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

    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided (seconds)
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp> _lockTime , "Contract is still locked");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }

}

contract AllianceProxy is Context, Ownable  {

    IUniswapV2Router02 public pancakeSwapRouterV2;
    IUniswapV2Router02 public allianceRouterV2;

    mapping(address => bool) allianceTokens;
    mapping(address => address) rewardTokens1;
    mapping(address => address) rewardTokens2;
    mapping(address => uint8) rewardPercent1;
    mapping(address => uint8) rewardPercent2;

    modifier onlyAllianceSwap() {
        require(address(allianceRouterV2) == _msgSender(), "Caller is not the alliance router");
        _;
    }


    constructor(address pancakeSwapRouterV2_, address allianceRouterV2_)  {
        pancakeSwapRouterV2 = IUniswapV2Router02(pancakeSwapRouterV2_);
        allianceRouterV2 = IUniswapV2Router02(allianceRouterV2_);
    }
        receive() external payable {
        require(msg.sender == address(allianceRouterV2) || msg.sender == address(pancakeSwapRouterV2), "Not allowed to send BNB here"); // only accept ETH from alliance router
    }

    function updateAllianceRouter(address router_) external onlyOwner {
        require(address(allianceRouterV2) != router_, "The router has already this address");
        allianceRouterV2 = IUniswapV2Router02(router_);
    }

    function updatePancakeSwapRouter(address router_) external onlyOwner {
        require(address(pancakeSwapRouterV2) != router_, "The router has already this address");
        pancakeSwapRouterV2 = IUniswapV2Router02(router_);
    }



    function updateAllianceToken(address token_, bool value_) external onlyOwner {
        require(allianceTokens[token_] != value_, "The token has already this value");
        allianceTokens[token_] = value_;
    }
    function updateRewardsFromAllianceToken(address allianceToken_, address rewardToken1_, uint8 rewardPercent_1, address rewardToken2_, uint8 rewardPercent_2) external onlyOwner {
        require(rewardPercent_1 + rewardPercent_2 <= 100, "The sum of percents must be maximum 100");
        rewardTokens1[allianceToken_] = rewardToken1_;
        rewardTokens2[allianceToken_] = rewardToken2_;
        rewardPercent1[allianceToken_] = rewardPercent_1;
        rewardPercent2[allianceToken_] = rewardPercent_2;
    }

    function swap(address allianceToken_, uint amoutOutMin_, address to_) external onlyAllianceSwap payable {
        require(allianceTokens[allianceToken_], "The token must be part of the alliance");
        uint bnbAmount = msg.value;

        uint bnbAmountReward1 = bnbAmount * rewardPercent1[allianceToken_] / 100;
        uint bnbAmountReward2 = bnbAmount * rewardPercent2[allianceToken_] / 100;
        uint bnbAmountAllianceToken = bnbAmount - bnbAmountReward1 - bnbAmountReward2;

        uint newAmountOutMin = amoutOutMin_ * (100 - rewardPercent1[allianceToken_] - rewardPercent2[allianceToken_]) / 100;
        uint256 initialAllianceTokenBalance = IERC20(allianceToken_).balanceOf(address(this));
        if(bnbAmountAllianceToken > 0) swapBnbForTokens(bnbAmountAllianceToken,allianceToken_,newAmountOutMin,address(this));
        IERC20(allianceToken_).transfer(to_,IERC20(allianceToken_).balanceOf(address(this)) - initialAllianceTokenBalance);
        if(bnbAmountReward1 > 0) swapBnbForTokens(bnbAmountReward1,rewardTokens1[allianceToken_],0,to_);
        if(bnbAmountReward2 > 0) swapBnbForTokens(bnbAmountReward2,rewardTokens2[allianceToken_],0,to_);
    }

    function swapBnbForTokens(uint256 bnbAmount_, address tokenAddress_, uint amoutOutMin_, address to_) private {
        address[] memory path = new address[](2);
        path[0] = pancakeSwapRouterV2.WETH();
        path[1] = tokenAddress_;

        IERC20(pancakeSwapRouterV2.WETH()).approve(address(pancakeSwapRouterV2), bnbAmount_);

        pancakeSwapRouterV2.swapExactETHForTokens{value: bnbAmount_}(
        amoutOutMin_,
        path,
        to_,
        block.timestamp); 
    }


    function withdrawStuckBnb(address payable to) external onlyOwner {
        require(address(this).balance > 0, "There are no BNBs in the contract");
        (bool success, ) = to.call{value: address(this).balance}("");
        require(success, "Unable to send BNB");    
    } 

    function withdrawStuckBep20Tokens(address token, address to) external onlyOwner {
        require(IERC20(token).balanceOf(address(this)) > 0, "CPH: There are no tokens in the contract");
        IERC20(token).transfer(to, IERC20(token).balanceOf(address(this)));
    }

}