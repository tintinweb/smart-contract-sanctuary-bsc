/**
 *Submitted for verification at BscScan.com on 2022-04-30
*/

// SPDX-License-Identifier: Unlicensed

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
        _owner = 0x8435A92302a5E41F7683A7707f7dB3a7E711C5DD;
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








contract AIRDROP is Ownable{

    
    
    receive() external payable {}
    

    // AIRDROP TOKEN TO HOLDER LIST - ADDS DECIMALS! 
    function AirDrop_Standard(address Token_CA, uint256 Decimals, address[] calldata Wallets, uint256[] calldata Tokens) external onlyOwner {

        require(Wallets.length <= 500, "Limit sending to 500 to reduce errors"); 
        require(Wallets.length == Tokens.length, "Token and Wallet count missmatch!");

        uint256 checkQuantity;

        for(uint i=0; i < Wallets.length; i++){
        checkQuantity = checkQuantity + Tokens[i];
        }

        require(IERC20(Token_CA).balanceOf(address(this)) >= checkQuantity, "Not Enough Tokens!");

        for (uint i=0; i < Wallets.length; i++) {
            IERC20(Token_CA).transfer(Wallets[i], Tokens[i]*10**Decimals);
        }
    }


    // SAME TO ALL
    function Airdrop_Same_To_All(address Token_CA, uint256 Decimals, uint256 Amount, address[] calldata Wallets) external onlyOwner {
        require(Wallets.length <= 500, "Limit sending to 500 to reduce errors"); 
        for (uint i=0; i < Wallets.length; i++) {
            IERC20(Token_CA).transfer(Wallets[i], Amount*10**Decimals);
        }
    }



    // SAME TO ALL
    function Airdrop_Same_To_All_No_Decimals(address Token_CA, uint256 Amount, address[] calldata Wallets) external onlyOwner {
        require(Wallets.length <= 500, "Limit sending to 500 to reduce errors"); 
        for (uint i=0; i < Wallets.length; i++) {
            IERC20(Token_CA).transfer(Wallets[i], Amount);
        }
    }






    // UPDATE REFLECTIONS BY AIRDRIOPPING 1 TOKEN TO HOLDERS
    function Airdrop_1_Token(address Token_CA, uint256 Decimals, address[] calldata Wallets) external onlyOwner {
        require(Wallets.length <= 500, "Limit sending to 500 to reduce errors"); 
        for (uint i=0; i < Wallets.length; i++) {
            IERC20(Token_CA).transfer(Wallets[i], 1*10**Decimals);
        }
    }


    // UPDATE REFLECTIONS BY AIRDRIOPPING 1 SPECK OF DUST TOKEN TO HOLDERS
    function Airdrop_Dust(address Token_CA, address[] calldata Wallets) external onlyOwner {
        require(Wallets.length <= 500, "Limit sending to 500 to reduce errors"); 
        for (uint i=0; i < Wallets.length; i++) {
            IERC20(Token_CA).transfer(Wallets[i], 1);
        }
    }





    // PURGE BNB
    function Purge_BNB(address payable _to) public onlyOwner {
        uint256 BNB = address(this).balance;
        if (BNB > 0) {
        _to.transfer(BNB);
        }
    }





    
    // PURGE TOKENS
    function Purge_Tokens(address Token_CA, uint256 Percent) public onlyOwner returns(bool _sent){
        uint256 totalRandom = IERC20(Token_CA).balanceOf(address(this));
        uint256 removeRandom = totalRandom * Percent / 100;
        _sent = IERC20(Token_CA).transfer(msg.sender, removeRandom);
    }


   
        









        
    }