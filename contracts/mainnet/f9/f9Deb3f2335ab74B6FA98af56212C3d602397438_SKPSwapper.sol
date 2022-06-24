//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";
import "./IUniswapV2Router02.sol";

interface IOwnable { 
    function getOwner() external view returns (address);
}

contract SKPSwapper {

    // MDB Token
    address public immutable token;

    // Fees
    uint256 public _fee = 8;
    address public burnFund;
    address public NFTAddr;

    // router
    IUniswapV2Router02 router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    // path
    address[] path;

    modifier onlyOwner(){
        require(msg.sender == IOwnable(token).getOwner(), 'Only Owner');
        _;
    }

    constructor(address token_, address burnFund_, address NFTAddr_) {
        path = new address[](2);
        path[0] = router.WETH();
        path[1] = token_;
        token = token_;
        burnFund = burnFund_;
        NFTAddr = NFTAddr_;
    }
    function setFee(uint fee) external onlyOwner {
        _fee = fee;
    }
    function setAddresses(address burnFund_, address nftAddr_) external onlyOwner {
        burnFund = burnFund_;
        NFTAddr = nftAddr_;
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

        uint fee = ( value * _fee ) / 100;
        uint bFund = ( fee * 5 ) / 8;

        _send(burnFund, bFund);
        _send(NFTAddr, fee - bFund);

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