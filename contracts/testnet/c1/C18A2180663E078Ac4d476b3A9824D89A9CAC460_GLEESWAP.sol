// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IERC20 {
    function transfer(address _to, uint256 _amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract GLEESWAP {
    address public platform;
    uint256 public gleePrice;
    address glee = 0x68e020950218Bd1d4cB3Afe7a4dB50F612B66a9f;

    constructor()   {
        gleePrice = 0.00079 ether;
        platform = msg.sender;
    }

    modifier onlyPlatform() {
        require(msg.sender == platform, "Platform owner only");
        _;
    }

    function setPlatform(address owner) public onlyPlatform {
        platform = owner;
    }

    function setPrice(uint256 _gleePrice)
        public
        onlyPlatform
    {
        gleePrice = _gleePrice;
    }

    function withdraw(uint256 amount) public onlyPlatform {
        payable(platform).transfer(amount);
    }

    receive() external payable{
        require(msg.value > 0);
        uint256 amountToSend = (msg.value / gleePrice) * 1000000000000000000;
        IERC20 tokenContract = IERC20(glee);
        require(amountToSend <= tokenContract.balanceOf(address(this)), "balance");
       tokenContract.transfer(msg.sender, amountToSend);
    }
}