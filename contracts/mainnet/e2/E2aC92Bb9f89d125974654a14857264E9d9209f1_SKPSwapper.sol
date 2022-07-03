//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";
import "./IUniswapV2Router02.sol";

interface IOwnable { 
    function getOwner() external view returns (address);
}

contract SKPSwapper {

    // Token
    IERC20 public constant token = IERC20(0x1234AE511876FCAaCe685fcDC292d9589A88dC2b);

    // Recipients Of Fees
    address public NFT = 0xe82d1E44a1f8a37f74A718Ee797F29Eb3aE1D84A;
    address public SKPFund = 0xCCf3a5F0B38074BaE1D3fa7736C0b97186f12B88;
    address public Marketing = 0x4d690E7adFdbf1955d89363F91a811d8D16D77E8;

    // Fee
    uint256 public _fee = 8;

    // router
    IUniswapV2Router02 router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    // path
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

    function setAddresses(address SKPFund_, address nftAddr_, address Marketing_) external onlyOwner {
        SKPFund = SKPFund_;
        NFT = nftAddr_;
        Marketing = Marketing_;
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

        // take fees
        uint fee = ( value * _fee ) / 100;
        uint sFund = ( fee * 3 ) / 8;
        uint nFund = ( fee * 3 ) / 8;
        uint mFund = ( fee * 2 ) / 8;

        // distribute fees
        _send(SKPFund, sFund);
        _send(NFT, nFund);
        _send(Marketing, mFund);

        // buy token
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