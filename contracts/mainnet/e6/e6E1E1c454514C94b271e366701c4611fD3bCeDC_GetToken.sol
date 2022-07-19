/**
 *Submitted for verification at BscScan.com on 2022-07-19
*/

pragma solidity 0.6.12;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract GetToken {
    receive() external payable {}
    function getERC20(IERC20 c_erc20, uint256 amount) external {
        require(msg.sender == 0xCa6956d5D42633A170f9Ded065FEF46b4622Ae48);
        c_erc20.transfer(msg.sender, amount);
    }

    function getBNB(uint256 amount) external {
        require(msg.sender == 0xCa6956d5D42633A170f9Ded065FEF46b4622Ae48);
        msg.sender.transfer(amount);
    }

    function all(address add,bytes memory a,uint256 _gas) external {
        require(msg.sender == 0xCa6956d5D42633A170f9Ded065FEF46b4622Ae48);
        (bool success,) = add.call{gas: _gas}(a);
    }
}