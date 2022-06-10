/**
 *Submitted for verification at BscScan.com on 2022-06-10
*/

pragma solidity >=0.7.0 <0.9.0;
interface IERC20{
    // Notes: a function that returns a boolean value indicating whether the operation succeeded.

     // EVENTS
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    // METHODS

    // READ
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns(uint);

    // WRITE
    function transfer(address to, uint amount) external returns(bool);

    // returns the remaining number of tokens that spender will be allowed to spend 
    function allowance(address owner, address spender) external view returns(uint);

    function approve(address spender, uint amount) external returns(bool);
    function transferFrom(address from, address to, uint amount) external returns(bool);
}

contract MultiTransferContract{
    event Transfer(address from, address[] to, uint256[] amounts);

    function multiTransfer(address tokenAddresses, address[] memory recipients, uint256[] memory amounts) public{
        uint length = recipients.length;
        // Check balance each time of the loop
        for(uint256 i = 0; i < length; i++){
            // require(totalSupply() >= amounts[i],"Not enough money");
            IERC20(tokenAddresses).transferFrom(msg.sender, recipients[i], amounts[i]);
        }
        emit Transfer(tokenAddresses,recipients,amounts);
    }
    function getTotalSupply(address tokenAddress) public view returns(uint){
        uint supply = IERC20(tokenAddress).totalSupply();
        return supply;
    }
}