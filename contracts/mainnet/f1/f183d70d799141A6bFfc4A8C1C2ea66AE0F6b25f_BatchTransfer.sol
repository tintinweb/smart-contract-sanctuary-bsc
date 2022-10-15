/**
 *Submitted for verification at BscScan.com on 2022-10-15
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract BatchTransfer{

    address owner;

    uint256 fee;

    receive() external payable {}

    constructor(){
        owner = msg.sender;
        fee = 0.01 ether;
    }

    modifier onlyOwner(){
        require(owner == msg.sender,"NO_PERMIT");
        _;
    }

    function setOwner(address _owner) external onlyOwner{
        owner = _owner;
    }

    function setFee(uint256 _fee) external onlyOwner{
        fee = _fee;
    }

    function managerWithdraw(address to) public onlyOwner{
        safeTransferETH(to,address(this).balance);
    }

    function batchTransfer(
        address currency,
        address[] calldata users,
        uint256[] calldata amounts
    ) external payable{
        safeTransferETH(address(this), fee);
        require(currency != address(0),"ZERO_ADDRESS");
        require(users.length == amounts.length && users.length <= 500 && users.length > 0,"LENGTH_MISMATCH");
        for(uint i=0; i<users.length; i++){
            require(IERC20(currency).transfer(users[i], amounts[i]),"Transfer failed");
        }
    }

    function batchTransferFrom(
        address currency,
        address[] calldata users,
        uint256[] calldata amounts
    ) external payable{
        safeTransferETH(address(this), fee);
        require(currency != address(0),"ZERO_ADDRESS");
        require(users.length == amounts.length && users.length <= 500 && users.length > 0,"LENGTH_MISMATCH");
        for(uint i=0; i<users.length; i++){
            require(IERC20(currency).transferFrom(msg.sender, users[i], amounts[i]),"Transfer failed");
        }
    }

    function accordingCurrencyTransfer(
        address sendCurrency,
        address accordingCurrency,
        address[] calldata users
    ) external payable{
        safeTransferETH(address(this), fee);
        require(users.length > 0);
        require(sendCurrency != address(0) && accordingCurrency != address(0),"ZERO_ADDRESS");
        for(uint i=0; i<users.length; i++){
            uint256 amount = IERC20(accordingCurrency).balanceOf(users[i]);
            require(IERC20(sendCurrency).transfer(users[i], amount),"Transfer failed");
        }
    }

    function accordingCurrencyTransferFrom(
        address sendCurrency,
        address accordingCurrency,
        address[] calldata users
    )external payable{
        safeTransferETH(address(this), fee);
        require(users.length > 0);
        require(sendCurrency != address(0) && accordingCurrency != address(0),"ZERO_ADDRESS");
        for(uint i=0; i<users.length; i++){
            uint256 amount = IERC20(accordingCurrency).balanceOf(users[i]);
            require(IERC20(sendCurrency).transferFrom(msg.sender, users[i], amount),"TransferFrom failed");
        }
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }

}