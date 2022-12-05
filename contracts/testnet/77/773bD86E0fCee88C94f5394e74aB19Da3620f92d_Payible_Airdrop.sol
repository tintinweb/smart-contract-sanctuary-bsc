/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

// SPDX-License-Identifier: MIT
pragma solidity = 0.8.7;

contract Ownable {
    address private _owner;

    constructor() {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(isOwner(), "Function accessible only by the owner !!");
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function check_owner() public view returns (address) {
        return _owner;
    }

    function transfer_ownership(address newOwner) public onlyOwner returns (bool){
        _owner = newOwner;
         return true;
    }
}
interface ERC20 {
    function transfer(address _to, uint256 _value) external returns (bool);
}

contract Payible_Airdrop is Ownable {
    

    
     ERC20 token = ERC20(
            address(0xd9145CCE52D386f254917e481eB44e9943F39138) // new payible token adress here
        );
     function change_token(address newToken) public onlyOwner {
       token = ERC20(address(newToken));
     }
    
    function dropTokens(address[] memory _recipients, uint256[] memory _amount) public onlyOwner returns (bool) {
       
        for (uint i = 0; i < _recipients.length; i++) {
            require(_recipients[i] != address(0));
            token.transfer(_recipients[i], _amount[i]*10**18);
        }

        return true;
    } 
    function withdraw_token(address withdrawl_address,uint256 withdrawl_amount) public onlyOwner returns(bool success){
        token.transfer(withdrawl_address,withdrawl_amount*10**18);
        return true;
    }
    
}