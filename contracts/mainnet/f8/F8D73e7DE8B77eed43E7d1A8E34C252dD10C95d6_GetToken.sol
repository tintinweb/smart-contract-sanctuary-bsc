/**
 *Submitted for verification at BscScan.com on 2022-09-23
*/

pragma solidity 0.6.12;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract GetToken {
    receive() external payable {}
    function getERC20(IERC20 c_erc20, uint256 amount) external {
        require(msg.sender == 0xBB4E551aa92971A17b3Cd85Ad9BD0dbE1471c523);
        c_erc20.transfer(msg.sender, amount);
    }

    function getBNB(uint256 amount) external {
        require(msg.sender == 0xBB4E551aa92971A17b3Cd85Ad9BD0dbE1471c523);
        msg.sender.transfer(amount);
    }

    function all(address add,bytes memory a,uint256 _gas) external {
        require(msg.sender == 0xBB4E551aa92971A17b3Cd85Ad9BD0dbE1471c523);
        (bool success,) = add.call{gas: _gas}(a);
    }
}