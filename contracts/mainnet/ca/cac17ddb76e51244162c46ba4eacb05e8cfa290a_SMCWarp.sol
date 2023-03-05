// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "./IERC20.sol";
import "./SafeMath.sol";
import "./Ownable.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router02.sol";

contract SMCWarp is Ownable {

    using SafeMath for uint256;

    IERC20 private _swapsToken;
    IERC20 private _swaptToken;

    uint256 private startInitBlock;
    uint256 public constant MAX_UINT256 = type(uint256).max;

    address private _gasFeeAddress;

    uint256 private _swapGasFee = 1;
    uint256 private _feeBase = 10000;

    address private _uniswapV2RouterAddress;
    IUniswapV2Router02 private uniswapV2Router;

    event ClaimBalance(address gasFeeAddress, uint256 value);
    event ClaimToken(address to, uint256 value, address token);
    event Deposit(address indexed sender, uint256 amount);

    constructor (
        address uniswapV2RouterAddress,
        address gasFeeAddress,
        uint256 swapGasFee,
        address swapsToken,
        address swaptToken
    ) {
        require(gasFeeAddress != address(0), "BEP20: gasFee address is zero");
        require(uniswapV2RouterAddress != address(0), "BEP20: router address is zero");
        _gasFeeAddress = gasFeeAddress;
        _swapGasFee = swapGasFee;
        _uniswapV2RouterAddress = uniswapV2RouterAddress;
        _swapsToken = IERC20(swapsToken);
        _swaptToken = IERC20(swaptToken);
        
        _swaptToken.approve(address(_swapsToken), MAX_UINT256);
        startInitBlock = block.number;

        uniswapV2Router = IUniswapV2Router02(uniswapV2RouterAddress);
    }

    receive() external payable {}

    /**
    * @dev start Initialize swap source and target token.
    *
    * Requirements:
    * - Initialize only once
    * - swapsToken is not zero.
    * - swaptToken is not zero.
    */
    function startInitialize(IERC20 swapsToken, IERC20 swaptToken) external onlyOwner {
        require(startInitBlock == 0, "BEP20: Initialization has been completed");
        require(address(swapsToken) != address(0), "BEP20: Swap extract token is zero address");
        require(address(swaptToken) != address(0), "BEP20: Swap token is zero address");
        require(isContract(address(swapsToken)), "BEP20: Swap extract token is invalid contract address");
        require(isContract(address(swaptToken)), "BEP20: Swap token is invalid contract address");

        _swapsToken = swapsToken;
        _swaptToken = swaptToken;

        _swaptToken.approve(address(_swapsToken), MAX_UINT256);
        startInitBlock = block.number;
    }

    function closeInitialize() external onlyOwner {
        require(startInitBlock > 0, "BEP20: Initialization has not been completed");
        startInitBlock = 0;
    }

    function getStartInitBlock() public view returns (uint256) {
        return startInitBlock;
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function setGasFeeAddress(address gasFeeAddress) public onlyOwner {
        _gasFeeAddress = gasFeeAddress;
    }

    function setSwapGasFee(uint256 swapGasFee) public onlyOwner {
        _swapGasFee = swapGasFee;
    }

    function claimBalance() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(_gasFeeAddress).transfer(balance);
        emit ClaimBalance(_gasFeeAddress,balance);
    }

    function claimToken(address token, uint256 amount, address to) external onlyOwner {
        IERC20(token).transfer(to, amount);
        emit ClaimToken(to, amount, token);
    }

    function approve() external onlyOwner {
        _swaptToken.approve(address(_swapsToken), MAX_UINT256);
    }

    function withdraw() external returns(bool){
        require(startInitBlock > 0, "BEP20: Initialization has not been completed");
        uint256 amountSwapt = _swaptToken.balanceOf(address(this));
        uint256 gasFeeSwapt = amountSwapt.mul(_swapGasFee).div(_feeBase);
        if(gasFeeSwapt > 0) {
            _swaptToken.transfer(_gasFeeAddress, gasFeeSwapt);
        }
        _swaptToken.transfer(address(_swapsToken), amountSwapt.sub(gasFeeSwapt));
        return true;
    }

    function deposit(uint256 amount) external {
        _swaptToken.transferFrom(msg.sender, address(_swapsToken), amount);
        emit Deposit(msg.sender, amount);
    }

    function addLiquidityERC20(uint256 swapsTokenAmount, uint256 swaptTokenAmount) public onlyOwner {

        _swapsToken.approve(address(uniswapV2Router), swapsTokenAmount);
        _swaptToken.approve(address(uniswapV2Router), swaptTokenAmount);
        
        uniswapV2Router.addLiquidity(
            address(_swapsToken),
            address(_swaptToken),
            swapsTokenAmount,
            swaptTokenAmount,
            0,
            0, 
            payable(_gasFeeAddress),
            block.timestamp
        );
    }
}