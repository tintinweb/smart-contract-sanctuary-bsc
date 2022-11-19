/**
 *Submitted for verification at BscScan.com on 2022-11-18
*/

/**
                                                 ,,                  █
                                                 ▐▌                  █
                                                 ▐▌     ▓          ▓▓▓▓█
                                           ▄   ,,▐▌,,   ▓     ]▄   ▓▓▓▓█
                                           ▓   ▓▓▓▓▓█ ▄▄▓▄▄   ▐▌   ▓▓▓▓█
                                           ▓   ▓███▓█ ▓▓▓▓▓⌐  ▐▌   ▓▓▓▓█
                    ╒▄                  j▓█▀",╓╥╗╖╓," ▀▓▓▓▓⌐╔▄▄█▄▄ ▓▓▓▓█
                    ▐▓                   ,g╣╢Ñ▒╢▓╣╢▒▒▓@╖ ╙▀`╟▓▓▓▓▓ ╚▀█▀▀
                    ▐▓     &           ╓╣╝`  ]`╙     ║║▒▒╣Ñ@╖╓▀▀█▓   █
                    ▐▓     ▓         ╥╣`            "        `╙%╖╙   █
                   ▓▓▓▓▌ ,,▓,,     ╓╣`                           ╙╗
                   ▓▓▓▓▌ ▓▓▓▓▓   ╓╣╝                ,           ,  ╣
            ,    , ▀█▓▓▌ ▓▓▓▓▓ ╓Ñ╫╣               ╙╣▒▒▒▒╢╣@╗╖   @  ╢▒╣%╗╗╗^
            █⌐  ╔╝╣╗,▀█▌ ▓▓▀,@╜  ╝                  ╙╣╣╚▒▒▓║▒   ╙@, ╙╝╣╢╓╓╗@`
            █-,╣`   ╙╣╖` ╙╓M`                         ╚╗ ╣]▒▒╖    "╙╨@M²╙`
             ╔╝  ╓╣╖   ╙%╜                 %╖          ╙╕  ▒▒▒╕   ▓ ╓╛
         ▐▀,╣` g╢╜ ╫╣╗         ╟          ╓╗,╟╣@╗╗╥╗@╣  ╫  ╟▒▒┘   ╓Ñ`
          ╔╝,@╝,     ╫╢╗      Æ@,    ,╓╗@╢▒▒▒▒▒▒Ñ"` "▒U ╟  ╟╣` ]╣╜
        ,╣╢Ñ╜▄█▓    ▐▄ ╫╢N  ╓╣▒▒▒▒▒▒▒▒▒╢╣Ñ╝╝╜`      ╔╢ ╓╝  ╙╨╝╜
       ╔▓╜╓▄█▓▓▓    ▐▓   ╫╢Ñ╜║ ,╓▄▄▄           ╟`║╣▒╢,#`
     ,╜  ▐▓▓▓▓▓▓    ▐▓   ▄,▄▓▓ ▓▓▓▓▓           @╓╣╝`
         ╘▀▀█▀▀▀    └▀   ▓▓▓▓▓ ▀▀▓▀▀
            █⌐             ▓     ▓
            █-             ▓     ▀
                           `
**/

pragma solidity 0.8.7;
// SPDX-License-Identifier: MIT

contract TradingCash {
    //Create ref percent bonus 
    uint256 constant private CLASSIC_REF = 20;
    uint256 constant private VIP_REF = 40;
    uint256 constant private PREMIUM_REF = 60;

    uint256 constant private PREMIUM_PRICE = 0.549 ether;
    uint256 constant private VIP_PRICE = 0.366 ether;
    uint256 constant private CLASSIC_PRICE = 0.1828 ether;
    
    // ceo addr 
    address payable public ceoWallet;
    
    //set user
     struct User {     
        address payable referrer;
        uint256 buy;
        uint256 buy_type;    
    }
    mapping (address => User) internal users;

    // setting ceo wallet there will send money
    constructor(address payable ceoAddr) {      
          ceoWallet = ceoAddr;
    }

    //buy book funtion
     function buyBook(address payable refAddr, uint256 typeBook) public payable {
        User storage user = users[msg.sender];
        if(refAddr == address(0)){
            if(typeBook == 1){
                require(msg.value >= CLASSIC_PRICE, "less then min amount");
                user.buy_type = 1;
            }
            if(typeBook == 2){
                require(msg.value >= VIP_PRICE, "less then min amount");
                user.buy_type = 2;
            }
            if(typeBook == 3){
                require(msg.value >= PREMIUM_PRICE, "less then min amount");
                user.buy_type = 3;
            }
            user.buy = 1;
            ceoWallet.transfer(msg.value);
        } else {
            User storage reffer = users[refAddr];
            user.referrer = refAddr;
            if(reffer.buy == 1){
                if(typeBook == 1){
                require(msg.value >= CLASSIC_PRICE, "less then min amount");
                user.buy_type = 1;
                refAddr.transfer((msg.value * CLASSIC_REF) / 100);
                ceoWallet.transfer(msg.value - ((msg.value * CLASSIC_REF) / 100) - ((msg.value * 10) / 100));   
            }
            if(typeBook == 2){
                require(msg.value >= VIP_PRICE, "less then min amount");
                user.buy_type = 2;
                refAddr.transfer((msg.value * VIP_REF) / 100);
               
                ceoWallet.transfer(msg.value - ((msg.value * VIP_REF) / 100) - ((msg.value * 10) / 100));
            }
            if(typeBook == 3){
                require(msg.value >= PREMIUM_PRICE, "less then min amount");
                user.buy_type = 3;
                refAddr.transfer((msg.value * PREMIUM_REF) / 100);
                
                ceoWallet.transfer(msg.value - ((msg.value * PREMIUM_REF) / 100) - ((msg.value * 10) / 100));
            }    
            } else {
                     if(typeBook == 1){
                        require(msg.value >= CLASSIC_PRICE, "less then min amount");
                        user.buy_type = 1;
                    }   
                    if(typeBook == 2){
                        require(msg.value >= VIP_PRICE, "less then min amount");
                        user.buy_type = 2;
                    }
                    if(typeBook == 3){
                        require(msg.value >= PREMIUM_PRICE, "less then min amount");
                        user.buy_type = 3;
                    }
                    user.buy = 1;    
            }
             
        }
     }

     function getBuy(address addr) public view returns(uint256){
        return users[addr].buy_type;
    }
}