/**
 *Submitted for verification at BscScan.com on 2022-09-22
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-17
*/

pragma solidity ^0.6.0;
// SPDX-License-Identifier: Unlicensed

 
 
    interface Erc20Token {//konwnsec//ERC20 接口
        function transferFrom(address _from, address _to, uint256 _value) external;
    }


    contract Base {
        Erc20Token   public ABC = Erc20Token(0x9F6E25BbCefC1d5ed1FA7711BdF184dd8C72e782);
        address public _owner;
        modifier onlyOwner() {
            require(msg.sender == _owner, "Permission denied"); _;
        }
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        _owner = newOwner;
    }
    receive() external payable {}  
}
contract ABC is Base{

     mapping(address => string) public _playerMap; 
    function pledge(uint256 quantity) public {
         ABC.transferFrom(msg.sender,address(_owner), quantity);
    }

    function binding(string calldata superior) public {
        _playerMap[msg.sender] =superior;
    }
    constructor()public {
        _owner = msg.sender; 
    }
}