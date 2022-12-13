// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./public.sol";


interface pancake{
    function getAmountsOut(uint256, address[] memory) external view returns(uint256[] memory);
    function swapExactTokensForTokens(uint256, uint256, address[] memory, address, uint256) external;
}

contract order is ReentrancyGuard,Ownable {
    using SafeMath for uint256;
    uint256 constant public amount = 300E18;  // 300U
    uint256 constant public swap = 60E18;  // 60U
    address public configAddress = 0x80d0458F16B33411DdF718e7d19ea162d8d59c25; //
    address public pancakeAddress = 0x42f0436Bb97FE57F0D934D8250BCf60d98AD9dd5;


    function setConfigAddress(address _address) external onlyOwner {
        configAddress = _address;
    }
    function setPancakeAddress(address _address) external onlyOwner {
        pancakeAddress = _address;
    }
    
    // 下单
    function placeOrder() external {
        // USDT地址
        // address usdt = config(configAddress).usdt();
        // TransferHelper.safeTransferFrom(usdt, msg.sender, address(this), amount);

        swapBuy(msg.sender);

    }
    
    function swapBuy(address _user) internal {
        uint256[3] memory ratio = config(configAddress).getratios();
        address[] memory patha = config(configAddress).getPathA();
        
        uint256 _amountA = swap.mul(ratio[0]).div(100);
        uint256[] memory numOutA = pancake(pancakeAddress).getAmountsOut(_amountA, patha);
        uint256 numA = numOutA[numOutA.length-1].mul(995).div(1000);
        
        uint256 times = block.timestamp + 300;

        pancake(pancakeAddress).swapExactTokensForTokens(_amountA, numA, patha, _user, times);
    }

    function approveUsdt() external {
        address _usdt = config(configAddress).usdt();
        TransferHelper.safeApprove(_usdt, pancakeAddress, 2**256-1);
    }


    function xxx() external view returns (uint256) {
        uint256[3] memory ratio = config(configAddress).getratios();
        address[] memory patha = config(configAddress).getPathA();
        
        uint256 _amountA = swap.mul(ratio[0]).div(100);
        uint256[] memory numOutA = pancake(pancakeAddress).getAmountsOut(_amountA, patha);
        uint256 numA = numOutA[numOutA.length-1].mul(995).div(1000);
        return numA;
    }

    
    
    
}