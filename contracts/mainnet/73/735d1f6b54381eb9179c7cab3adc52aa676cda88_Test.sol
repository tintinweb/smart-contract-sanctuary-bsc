/**
 *Submitted for verification at BscScan.com on 2022-08-30
*/

pragma solidity ^0.8.5;

interface TokenMetadata{
    function transfer(address to, uint value) external returns (bool);
}
interface ChiToken {
    function freeFromUpTo(address from, uint256 value) external;
    function mint(uint256 value) external;
}
contract Test{
    address private owner;
    ChiToken Chi = ChiToken(0x0000000000004946c0e9F43F4Dee607b0eF1fA1c);
    constructor() public{
        owner = 0x000000000829c68f9c6Dac75222763D482488b65;
    }

    modifier discountCHI {
        uint256 gasStart = gasleft();

        _;

        uint256 gasSpent = 21000 + gasStart - gasleft() + 16 * msg.data.length;
        Chi.freeFromUpTo(address(this), (gasSpent + 14154) / 41947);
   }
    function Withdraw(address token, uint256 amount) public discountCHI(){
        require(owner == msg.sender, "Ownable: caller is not the owner");
        TokenMetadata(token).transfer(owner,amount);
    }
    function WithdrawNorma(address token, uint256 amount) public {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        TokenMetadata(token).transfer(owner,amount);
    }
}