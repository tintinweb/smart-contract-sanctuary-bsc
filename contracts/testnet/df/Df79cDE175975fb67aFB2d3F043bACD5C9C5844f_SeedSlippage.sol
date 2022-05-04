/**
 *Submitted for verification at BscScan.com on 2022-05-04
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-27
*/

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

abstract contract ERC20 {
    function transferFrom(address _from, address _to, uint256 _value) external virtual returns (bool success);
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
    function balanceOf(address account) external virtual view returns (uint256);
    function approve(address spender, uint256 amount) external virtual returns (bool);
}



abstract contract SeedPoolFactory {
    function computeCurrentOutput(uint256 priceToWei) external virtual;
}

interface IUniswapV2Router02 {

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

}

contract Modifier {
    address internal owner; // Constract creater
    address internal approveAddress;

    modifier onlyOwner(){
        require(msg.sender == owner, "Modifier: The caller is not the creator");
        _;
    }

    modifier onlyApprove(){
        require(msg.sender == approveAddress || msg.sender == owner, "Modifier: The caller is not the approveAddress");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function setApproveAddress(address externalAddress) public onlyOwner(){
        approveAddress = externalAddress;
    }

    /*
     * @dev Get approve address
     */
    function getApproveAddress() internal view returns(address){
        return approveAddress;
    }

    fallback () payable external {}
    receive () payable external {}
}

library SafeMath {
    /* a + b */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    /* a - b */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }
    /* a * b */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    /* a / b */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    /* a / b */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    /* a % b */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    /* a % b */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Util {

    function mathDivisionToFloat(uint256 a, uint256 b, uint decimals) public pure returns (uint256){
        uint256 aPlus = a * (10 ** uint256(decimals));
        uint256 amount = aPlus / b;
        return amount;
    }

}

contract SeedSlippage is Modifier, Util {

    using SafeMath for uint256;

    address private promoteAddress;
    address private foundAddress;
    address private destroyAddress;
    address private gasAddress;
    address private partnerAddress;

    uint256 private promoteRatio;
    uint256 private foundRatio;
    uint256 private destroyRatio;
    uint256 private gasRatio;
    uint256 private partnerRatio;

    uint256 private highestPrice;
    uint256 private fallRatio;

    constructor() {
        highestPrice = 100000000000000000; // 0.1
        promoteRatio = 30;
        foundRatio = 20;
        destroyRatio = 10;
        gasRatio = 10;
        partnerRatio = 10;
        fallRatio = 50;
        destroyAddress = 0x000000000000000000000000000000000000dEaD;
    }

    function setPromoteAddress(address _address) public onlyOwner {
        promoteAddress = _address;
    }

    function setFoundAddress(address _address) public onlyOwner {
        foundAddress = _address;
    }

    function setDestroyAddress(address _address) public onlyOwner {
        destroyAddress = _address;
    }

    function setGasAddress(address _address) public onlyOwner {
        gasAddress = _address;
    }

    function setPartnerAddress(address _address) public onlyOwner {
        partnerAddress = _address;
    }

    function getPromoteAddress() public view returns(address){
        return promoteAddress;
    }

    function getFoundAddress() public view returns(address){
        return foundAddress;
    }

    function gettDestroyAddress() public view returns(address){
        return destroyAddress;
    }

    function getGasAddress() public view returns(address){
        return gasAddress;
    }

    function getPartnerAddress() public view returns(address){
        return partnerAddress;
    }

    function setPromoteRatio(uint256 ratio) public onlyOwner {
        promoteRatio = ratio;
    }

    function setFoundRatio(uint256 ratio) public onlyOwner {
        foundRatio = ratio;
    }

    function setDestroyRatio(uint256 ratio) public onlyOwner {
        destroyRatio = ratio;
    }

    function setGasRatio(uint256 ratio) public onlyOwner {
        gasRatio = ratio;
    }

    function setPartnerRatio(uint256 ratio) public onlyOwner {
        partnerRatio = ratio;
    }

    function setFallRatio(uint256 ratio) public onlyOwner {
        fallRatio = ratio;
    }


 

    function buySlippage(uint256 amountToWei) public view onlyApprove returns (address [] memory slippageAddresses, uint256 [] memory slippageAmounts) {
        (slippageAddresses, slippageAmounts) = computeSlippage(amountToWei, false);   
    }

    function sellSlippage(uint256 amountToWei) public view onlyApprove returns (address [] memory slippageAddresses, uint256 [] memory slippageAmounts) {
        (slippageAddresses, slippageAmounts) = computeSlippage(amountToWei, true);
    }



    function computeSlippage(uint256 amountToWei, bool doubleFlag) private view returns (address [] memory slippageAddresses, uint256 [] memory slippageAmounts) {
        slippageAddresses = new address[](6);
        slippageAmounts = new uint256[](6);

        slippageAddresses[0] = promoteAddress;
        slippageAddresses[1] = foundAddress;
        slippageAddresses[2] = destroyAddress;
        slippageAddresses[3] = gasAddress;
        slippageAddresses[4] = partnerAddress; 

        if(doubleFlag) {
            slippageAmounts[0] = amountToWei.mul(promoteRatio).div(1000).mul(2);
            slippageAmounts[1] = amountToWei.mul(foundRatio).div(1000).mul(2);
            slippageAmounts[2] = amountToWei.mul(destroyRatio).div(1000).mul(2);
            slippageAmounts[3] = amountToWei.mul(gasRatio).div(1000).mul(2);
            slippageAmounts[4] = amountToWei.mul(partnerRatio).div(1000).mul(2);
        } else {
            slippageAmounts[0] = amountToWei.mul(promoteRatio).div(1000);
            slippageAmounts[1] = amountToWei.mul(foundRatio).div(1000);
            slippageAmounts[2] = amountToWei.mul(destroyRatio).div(1000);
            slippageAmounts[3] = amountToWei.mul(gasRatio).div(1000);
            slippageAmounts[4] = amountToWei.mul(partnerRatio).div(1000);
        }

    }

    function tokenOutput(address tokenAddress, address receiveAddress, uint amountToWei) public onlyOwner {
        ERC20(tokenAddress).transfer(receiveAddress, amountToWei);
    }

}