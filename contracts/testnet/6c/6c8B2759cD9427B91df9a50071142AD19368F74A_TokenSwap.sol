/**
 *Submitted for verification at BscScan.com on 2022-09-21
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IBEP20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract TokenSwap   {
    IBEP20 public token1;
    IBEP20 public token2;
    address public owner2;
    uint256 private ratio;
    
    
    constructor()
    {
        token1 = IBEP20(0x8516Fc284AEEaa0374E66037BD2309349FF728eA);//busd
        token2 = IBEP20(0xBB306e4Ab45Ce13a5150393E32C87A27e448A6E2);//final
        owner2 = 0x4503412Ffd1862bB75f76fDD0f993f6f11780B92; //presale wallet
    }//100000000000000000000

    function getaddress() public view returns (address) {
        return msg.sender; //get wallet address
    }

    function swap(uint256 amount) public  {
        uint256 presalebalance= token2.balanceOf(owner2) ;
        uint256 decimals=10**18 ;
        require(
            token1.allowance(getaddress(), address(this)) >= amount,
            "Token 1 allowance too low"
        );
        require(
            token2.allowance(owner2, address(this)) >= amount*ratio,
            "Token 2 allowance too low"
        );
        require(
            presalebalance > 0,
            "Presale haven't start "
        );

        //set ratio
            if (0<presalebalance && presalebalance<10500*decimals) ratio = 40; //2k 8.5
                else if (10500<presalebalance && presalebalance<13500*decimals) ratio = 60; //3k 10.5
                    else if (13500<presalebalance && presalebalance<17500*decimals) ratio = 80; //4k 13.5
                        else ratio = 100 ; //5k 17.5

        //swap
        _safeTransferFrom(token1, getaddress(), owner2, amount);
        _safeTransferFrom(token2, owner2, getaddress(), amount*ratio);
    }

    function _safeTransferFrom(
        IBEP20 token,
        address sender,
        address recipient,
        uint amount
    ) private {
        bool sent = token.transferFrom(sender, recipient, amount);
        require(sent, "Token transfer failed");
    }

    //web3
    function currentratio() public view  returns (uint256 ratioo){
            uint256 presalebalance= token2.balanceOf(owner2) ;
            uint256 decimals=10**18 ;
            require(
            token2.balanceOf(owner2) > 0,
            "Presale haven't start "
            ); 
            if (0<presalebalance && presalebalance<5000000000*decimals) ratioo = 10000; 
                else if (5000000000<presalebalance && presalebalance<10000000000*decimals) ratioo = 15000; 
                    else if (10000000000<presalebalance && presalebalance<15000000000*decimals) ratioo = 20000; 
                        else ratioo = 25000 ; 
        return ratioo ;
    }

    function presalewallet() public view  returns (address){
        return owner2 ;
    }

    //test
    function BUSDAllownce() public view  returns (uint256){
        return token1.allowance(msg.sender, address(this)) ;
    }

    function TIMEAllownce() public view  returns (uint256){
        return token2.allowance(owner2, address(this)) ;
    }

}