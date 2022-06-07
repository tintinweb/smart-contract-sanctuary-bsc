// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SafeMath.sol";
import "./Ownable.sol";
import "./ISunswapV2Router02.sol";
import "./IERC20.sol";



contract Convert is Ownable{
    using SafeMath for uint256;

    ISunswapV2Router02 public sunswapV2Router;
    address public  sunswapV2Pair;
    address public USDT;
    address public TB ;
    address public TRX ;

    mapping(address => bool) public operators;

    modifier onlyOperator() {
        require(operators[msg.sender], "Operator: caller is not the operator");
        _;
    }
    //事件xxx事件xxx事件xxx
    event ConvertEvent(uint256 indexed tbHolderTokens, address indexed to);
    event SwapAndLiquify(uint256 tokensSwapped,uint256 ethReceived,uint256 tokensIntoLiqudity);

    constructor() {
        operators[msg.sender] = true;
    }

    receive() external payable {  }

    function setOperator(address _operator, bool _enabled) public onlyOwner {
        operators[_operator] = _enabled;
    }

    function initData(address _sunswapV2Pair,address _sunswapV2Router,address _USDT,address _TB,address _TRX) external onlyOperator{
        sunswapV2Pair = _sunswapV2Pair;
        sunswapV2Router = ISunswapV2Router02(_sunswapV2Router);
        USDT = _USDT;
        TB = _TB;
        TRX = _TRX;
    }

    function TBToTrxToDivide(uint256 tbHolderTokens,address to) external onlyOperator{
        if (tbHolderTokens > 0){
            address[] memory path = new address[](3);
            path[0] = TB;
            path[1] = USDT;
            path[2] = TRX;
            IERC20(TB).approve(address(sunswapV2Router), tbHolderTokens);
            // make the swap
            sunswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                tbHolderTokens,
                0, //
                path,
                to,
                block.timestamp
            );
        }
        emit ConvertEvent(tbHolderTokens, to);
       
    }

    //--------------------------------------------------------------------------------
    function swapAndLiquify(uint256 tokens) external onlyOperator {
        // split the contract balance into halves
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);
        uint256 initialBalance = IERC20(USDT).balanceOf(address(this));
        // swap tokens for USDT
        swapTokensForUSDT(half); // <- this breaks the USDT -> HATE swap when swap+liquify is triggered
        // how much ETH did we just swap into?
        uint256 newBalance = IERC20(USDT).balanceOf(address(this)).sub(initialBalance);
        // add liquidity to uniswap
        addUSDTLiquidity(otherHalf, newBalance);
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function swapTokensForUSDT(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = TB;
        path[1] = USDT;
        IERC20(TB).approve(address(sunswapV2Router),tokenAmount);
        // make the swap
        sunswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function addUSDTLiquidity(uint256 tokenAmount, uint256 usdtAmount) private {
        // approve token transfer to cover all possible scenarios
        IERC20(TB).approve(address(sunswapV2Router),tokenAmount);
        IERC20(USDT).approve(address(sunswapV2Router),usdtAmount);
        sunswapV2Router.addLiquidity(
            TB,
            USDT,
            tokenAmount,
            usdtAmount,
            0,
            0,
            owner(),
            block.timestamp
        );
    }

}