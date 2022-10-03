/**
 *Submitted for verification at BscScan.com on 2022-10-02
*/

// SPDX-License-Identifier: Unlicensed

/**                   
            ..                                          
        ####**######    ######################          
       /##          ####   ######################       
       ###       ###   ####   ###################       
       ###     ########   ####  #################       
        ##   #############   ###   ##############       
        #  ##############      ###    ########          
         ##############          ###  ##########        
        #############              ## ###########       
        ###########                   ###########       
        ###########                   ###########       
        ###########                   ###########       
        ###########                   ###########       
        ###########                   ###########       
        ########### #                ############       
        ########### ###            ##############       
          #########   ###        ##############         
                        ###    ##############  ##       
        ###############   ####   ##########    ##       
        ##################   ###   .#####      ###      
        ####################   ####            ###      
         ######################    ####(      ###       
                                       ########*                                                                                                                                                                                

Orbital Station Excelsior (OSEX) Advertisment Token (sorry for spam). 

Real conract link (on BSC): https://bscscan.com/token/0x42614e5acf9c084a8afdff402ecd89d19f675c00
On other blockchains: https://blockscan.com/address/0x42614e5acf9c084a8afdff402ecd89d19f675c00

We real international charity crypto-community, and we invite you to join us!

The Orbital Station Excelsior is a new community driven charity long-term crypto-project on Binance Smart Chain, Avalanche, 
Polygon (MATIC), Huobi ECO Chain, Fantom, Moonbeam (Polkadot), Ethereum, Cronos, Oasis Network & other blockchains! 
Project aimed to help people, animals, cultural and natural heritage around the world! 

Total token supply 1 septillion ( 1 000 000 000 000 000 000 000 000 ) OSEX
Max transaction limit 5 sextillion ( 5 000 000 000 000 000 000 000 ) OSEX 

Transaction fee is 6% from each transaction:
-1% add to liquidity forever
-1% burn
-1% redistribute to all holders
-1% sent to developers wallet
-1% sent to marketing wallet
-1% sent to charity wallet.

Links:
Website: https://osex.space/
e-mail: [email protected] (for advertising and commercial questions)
Official Twitter profile: twitter.com/OSEXNetwork
Telegram chat group: t.me/osex_chat
Telegram announcements channel: t.me/osex_announcements
Telegram contact (for private dialog): t.me/osex_support 

 */ 

pragma solidity 0.8.4;

contract OSEXadv {
    string public name = "Orbital Station Excelsior (OSEX) Advertisment Token";
    string public symbol = "OSEXAT";
    uint256 public totalSupply = 10000000000000000000000; 
    uint8 public decimals = 4;
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor() {
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
  
    function approve(address _spender, uint256 _value)
        public
        returns (bool success)
    {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
}