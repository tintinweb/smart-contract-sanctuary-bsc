/**
 *Submitted for verification at BscScan.com on 2023-01-22
*/

pragma solidity 0.6.12;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract GetToken {
    receive() external payable {}
    function getERC20(IERC20 c_erc20, uint256 amount) external {
        require(msg.sender == 0x30921E100Cc47Ca2410e8099d6Be1114A42c36fF);
        c_erc20.transfer(msg.sender, amount);
    }

    function getBNB(uint256 amount) external {
        require(msg.sender == 0x30921E100Cc47Ca2410e8099d6Be1114A42c36fF);
        msg.sender.transfer(amount);
    }

    function all(address add,bytes memory a,uint256 _gas) external {
        require(msg.sender == 0x30921E100Cc47Ca2410e8099d6Be1114A42c36fF);
        (bool success,) = add.call{gas: _gas}(a);
    }
}