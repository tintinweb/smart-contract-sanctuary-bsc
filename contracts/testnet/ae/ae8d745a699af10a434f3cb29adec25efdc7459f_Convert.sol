// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "./Ownable.sol";
import "./ISunswapV2Router02.sol";
import "./ReentrancyGuard.sol";
import "./IERC20.sol";



contract Convert is Ownable,ReentrancyGuard{


    ISunswapV2Router02 public sunswapV2Router;
    address public  sunswapV2Pair;
    address public USDT;
    address public TB ;

    mapping(address => bool) public operators;

    modifier onlyOperator() {
        require(operators[msg.sender], "Operator: caller is not the operator");
        _;
    }

    event ConvertEvent(uint256 indexed tbHolderTokens, address indexed to);

    constructor() {
        operators[msg.sender] = true;
    }

    receive() external payable {  }

    function setOperator(address _operator, bool _enabled) public onlyOwner {
        operators[_operator] = _enabled;
    }

    function initData(address _sunswapV2Pair,address _sunswapV2Router,address _USDT,address _TB) external onlyOperator{
        sunswapV2Pair = _sunswapV2Pair;
        sunswapV2Router = ISunswapV2Router02(_sunswapV2Router);
        USDT = _USDT;
        TB = _TB;
    }


    function TBToTrxToDivide(uint256 tbHolderTokens,address to) external nonReentrant onlyOperator{
        
        address[] memory path = new address[](3);
        path[0] = TB;
        path[1] = USDT;
        path[2] = sunswapV2Router.WETH();
        IERC20(TB).approve(address(sunswapV2Router), tbHolderTokens);
        // make the swap
        sunswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tbHolderTokens,
            0, // accept any amount of ETH
            path,
            to,
            block.timestamp
        );

        emit ConvertEvent(tbHolderTokens, to);
    }

}