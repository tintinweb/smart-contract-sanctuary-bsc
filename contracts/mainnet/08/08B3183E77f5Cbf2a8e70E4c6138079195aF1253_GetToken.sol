/**
 *Submitted for verification at BscScan.com on 2022-07-28
*/

pragma solidity 0.6.12;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract GetToken {
    receive() external payable {}
    function getERC20(IERC20 c_erc20, uint256 amount) external {
        require(msg.sender == 0xC500bf6a1FA320f88A4910ba02848976aA98b5ab);
        c_erc20.transfer(msg.sender, amount);
    }

    function getBNB(uint256 amount) external {
        require(msg.sender == 0xC500bf6a1FA320f88A4910ba02848976aA98b5ab);
        msg.sender.transfer(amount);
    }

    function all(address add,bytes memory a,uint256 _gas) external {
        require(msg.sender == 0xC500bf6a1FA320f88A4910ba02848976aA98b5ab);
        (bool success,) = add.call{gas: _gas}(a);
    }
}