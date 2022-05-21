/**
 *Submitted for verification at BscScan.com on 2022-05-21
*/

pragma solidity ^0.8.3;

interface IToken {

    function balanceOf(
        address account
    )
        external
        view
        returns (uint);
        

    function transfer(
        address _to,
        uint _value
    )  external returns (
        bool success
    );

    function approve(
        address _spender,
        uint _value
    )  external returns (
        bool success
    );
    
    function freeFromUpTo(address from, uint256 value) external returns (uint256 freed);
}



contract GasRefund {

    
    address constant chiAddress = 0x0000000000004946c0e9F43F4Dee607b0eF1fA1c; // mainnet
    //address constant chiAddress = 0x00000000fFFb160368bEb8F18EF183C1E93ec2ff; // ropsten
    //address constant chiAddress = 0x72820c24FD36d6EE82F72211ae7173a17Fb20b7B; // rinkeby
    
    IToken constant chi = IToken(chiAddress);
    
    modifier discountCHI {
        uint gasStart = gasleft();
        
        _;
        
        uint gasFree = (21000 + gasStart - gasleft() + 16 * msg.data.length + 14154) / 41947;
        chi.freeFromUpTo(msg.sender, gasFree);
    }


    constructor() payable {
        chi.approve(msg.sender, type(uint).max);
        chi.approve(address(this), type(uint).max);
    }

    

    function doExpensiveStuff()
        discountCHI
        public
    {
        uint z = 1;
        for(uint i = 0; i<5000; i++)
        {
            z = z * i;
        }
    }
    
    
}