/**
 *Submitted for verification at BscScan.com on 2022-04-30
*/

// SPDX-License-Identifier: Unlicensed

/*

Check balance on loads of wallets

*/

pragma solidity 0.8.10;



interface IERC20 {
    
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

}




abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; 
        return msg.data;
    }
}


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        _owner = 0xD05895EDF847e1712721Cc9e0427Aa26289A6Bc5;
        emit OwnershipTransferred(address(0), _owner);
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }




    
}








contract BALANCE is Ownable{

    uint256 token_balance = 0;
    uint256 total_balance = 0;


   



    function Check_Balance(address Token_CA, address[] calldata Wallets) public returns(uint256) {

        for (uint i=0; i < Wallets.length; i++) {

            token_balance = IERC20(Token_CA).balanceOf(Wallets[i]);
            total_balance = total_balance + token_balance;
            token_balance = 0;

        }

        return total_balance;

    }


   
        









        
    }