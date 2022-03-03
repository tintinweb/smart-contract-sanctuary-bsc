/**
 *Submitted for verification at BscScan.com on 2022-03-03
*/

pragma solidity 0.8.12;

interface ERC20 {
    function transferFrom(address from, address to, uint value) external returns (bool);
}

contract multitransfer {
    
    constructor() {
    }
    
    function kkMultiEtherTransfer(address[] calldata _contributors,uint[] calldata _balances) external payable {
        uint i = 0;
        for (i; i < _contributors.length; i++) {
            payable(_contributors[i]).transfer(_balances[i]);
        }
    }
    
    function kkMultiTokenTransfer(address token,address[] calldata _contributors,uint[] calldata _balances) external payable {
        ERC20 erc20token = ERC20(token);
        uint i = 0;
        for (i; i < _contributors.length; i++) {
            erc20token.transferFrom(msg.sender, _contributors[i], _balances[i]);
        }
    }
    
    function kkMultiTokenTransferSingleAmount(address token,address[] calldata _contributors,uint _balances) external {
        ERC20 erc20token = ERC20(token);
        uint i = 0;
        for (i; i < _contributors.length; i++) {
            erc20token.transferFrom(msg.sender, _contributors[i], _balances);
        }
    }
}