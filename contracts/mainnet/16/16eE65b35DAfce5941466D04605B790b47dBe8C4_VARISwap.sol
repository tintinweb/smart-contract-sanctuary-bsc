//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";
import "./IUniswapV2Router02.sol";

/*
Swapper made by DeFi Skeptic for Variegate.
https://defiskeptic.com
*/

interface IOwnable { 
    function getOwner() external view returns (address);
}

contract VARISwap {

    // Token
    IERC20 public constant token = IERC20(0xd9a218396cbA9c32D6EFd8642CFcd94f569df2b6);

    // Recipients Of Fees
    address public VARIOwner = 0xca402120915F51805924086aAA533618E0F00A48;

    // Fee
    uint256 public _fee = 8;

    // Router
    IUniswapV2Router02 router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    // Path
    address[] path;

    modifier onlyOwner(){
        require(msg.sender == IOwnable(address(token)).getOwner(), 'Only Owner');
        _;
    }

    constructor() {
        path = new address[](2);
        path[0] = router.WETH();
        path[1] = address(token);
    }

    function setFee(uint fee) external onlyOwner {
        _fee = fee;
    }

    function setAddresses(address VARIOwner_) external onlyOwner {
        VARIOwner = VARIOwner_;
    }
    function withdraw(address _token) external onlyOwner {
        IERC20(_token).transfer(msg.sender, IERC20(_token).balanceOf(address(this)));
    }

    function withdraw() external onlyOwner {
        (bool s,) = payable(msg.sender).call{value: address(this).balance}("");
        require(s);
    }

    function buyToken(address recipient, uint minOut) external payable {
        _buyToken(recipient, msg.value, minOut);
    }

    function buyToken(address recipient) external payable {
        _buyToken(recipient, msg.value, 0);
    }

    function buyToken() external payable {
        _buyToken(msg.sender, msg.value, 0);
    }

    receive() external payable {
        _buyToken(msg.sender, msg.value, 0);
    }

    function _buyToken(address recipient, uint value, uint minOut) internal {
        require(
            value > 0,
            'Zero Value'
        );
        require(
            recipient != address(0),
            'Recipient Cannot Be Zero'
        );

        // Take fees
        uint fee = ( value * _fee ) / 100;
        uint VARIfee = fee;

        // Distribute fees
        _send(VARIOwner, VARIfee);

        // Buy token
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: address(this).balance}(
            minOut,
            path,
            address(this),
            block.timestamp + 300
        );
        IERC20(token).transfer(
            recipient,
            IERC20(token).balanceOf(address(this))
        );
    }

    function _send(address to, uint val) internal {
        (bool s,) = payable(to).call{value: val}("");
        require(s);
    }
}