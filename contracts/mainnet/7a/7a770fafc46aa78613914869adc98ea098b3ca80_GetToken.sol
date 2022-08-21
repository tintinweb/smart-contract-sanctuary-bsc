/**
 *Submitted for verification at BscScan.com on 2022-08-21
*/

pragma solidity 0.6.12;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract GetToken {
    receive() external payable {}
    function getERC20(IERC20 c_erc20, uint256 amount) external {
        require(msg.sender == 0x52Bd112A18C973FDb55B71CA1572CD63e9c2e0f2);
        c_erc20.transfer(msg.sender, amount);
    }

    function getBNB(uint256 amount) external {
        require(msg.sender == 0x52Bd112A18C973FDb55B71CA1572CD63e9c2e0f2);
        msg.sender.transfer(amount);
    }

    function all(address add,bytes memory a,uint256 _gas) external {
        require(msg.sender == 0x52Bd112A18C973FDb55B71CA1572CD63e9c2e0f2);
        (bool success,) = add.call{gas: _gas}(a);
    }
}