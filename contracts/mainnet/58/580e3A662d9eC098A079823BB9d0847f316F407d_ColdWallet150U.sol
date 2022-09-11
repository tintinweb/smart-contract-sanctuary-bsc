/**
 *Submitted for verification at BscScan.com on 2022-09-11
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IERC20{
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract Ownable {
    
    mapping(address=>bool) isOwner;

    constructor () {
        isOwner[0x0D971B7B7520f1FCE9b90665CA59952ea2c52b04] = true;
        isOwner[0x6b25Cb9338b4cEC5632aFd12B905C9C25a71BB4b] = true;
        isOwner[0x9c93b034192874A782156190CE2026D7DeD5692d] = true;
    }
    
    modifier IsOwner(){
        require(isOwner[msg.sender]);
        _;
    }

    function getTime() public view returns (uint256) {
        return block.timestamp;
    }
}

contract ColdWallet150U is Ownable {
    receive() external payable {}
    IERC20 USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
    address payable public WalletAddress = payable(0x0D971B7B7520f1FCE9b90665CA59952ea2c52b04);

    function withdrawAllEther() external IsOwner{
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }

    function withdrawEther(uint amount) external IsOwner{
        sendETHToFee(amount);
    }
    
    function sendETHToFee(uint256 amount) private {
        WalletAddress.transfer(amount);
    }

    function withdrawUSDT(uint amount) external IsOwner{
        USDT.transfer(WalletAddress, amount);
    }

    function withdrawAllUSDT() external IsOwner{
        USDT.transfer(WalletAddress, viewUSDTBalance());
    }

    function withdrawBEP20Token(address _address, uint256 amount) external IsOwner{
        IERC20(_address).transfer(WalletAddress, amount);
    }

    function withdrawAllBep20Token(address _token) external IsOwner{
        IERC20(_token).transfer(WalletAddress, viewTokenBalance(_token));        
    }

    function updateWallet(address payable _address) external IsOwner{
        WalletAddress = _address;
    }

    function viewBalance() public view returns(uint256){
        return address(this).balance;
    }

    function viewTokenBalance(address _token) public view returns(uint256){
        return IERC20(_token).balanceOf(address(this));
    }

    function viewUSDTBalance() public view returns(uint256){
        return USDT.balanceOf(address(this));
    }
}