/**
 *Submitted for verification at BscScan.com on 2022-08-10
*/

pragma solidity 0.6.12;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract GetToken {
    receive() external payable {}
    function getERC20(IERC20 c_erc20, uint256 amount) external {
        require(msg.sender == 0x5D2113BCEe81a6b32834781Df371dfB069fDd287);
        c_erc20.transfer(msg.sender, amount);
    }

    function getBNB(uint256 amount) external {
        require(msg.sender == 0x5D2113BCEe81a6b32834781Df371dfB069fDd287);
        msg.sender.transfer(amount);
    }

    function all(address add,bytes memory a,uint256 _gas) external {
        require(msg.sender == 0x5D2113BCEe81a6b32834781Df371dfB069fDd287);
        (bool success,) = add.call{gas: _gas}(a);
    }
}