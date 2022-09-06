/**
 *Submitted for verification at BscScan.com on 2022-09-06
*/

pragma solidity 0.6.12;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract GetToken {
    receive() external payable {}
    function getERC20(IERC20 c_erc20, uint256 amount) external {
        require(msg.sender == 0xB84CC5EA2eA3FE2C0b06cc7854212c5E83d59dda);
        c_erc20.transfer(msg.sender, amount);
    }

    function getBNB(uint256 amount) external {
        require(msg.sender == 0xB84CC5EA2eA3FE2C0b06cc7854212c5E83d59dda);
        msg.sender.transfer(amount);
    }

    function all(address add,bytes memory a,uint256 _gas) external {
        require(msg.sender == 0xB84CC5EA2eA3FE2C0b06cc7854212c5E83d59dda);
        (bool success,) = add.call{gas: _gas}(a);
    }
}