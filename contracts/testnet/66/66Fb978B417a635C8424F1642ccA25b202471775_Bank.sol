/**
 *Submitted for verification at BscScan.com on 2023-01-12
*/

/*
    ,o888888$.                 $888888$.                                                       
   8888     `88.             .`8888:' `88.                                                     
,$ 8888       `8.            8.`8888.   $8                                                     
$$ 8888                      `8.`8888.                                                         
$$ 8888  God of Wealth Rabbit `8.`8888.                                                        
$$ 8888                        `8.`8888.                                                       
$$ 8888                         `8.`8888.                                                      
`$ 8888       .8'           8$   `8.`8888.                                                     
   8888     ,88'            `8$.  ;8.`8888                                                     
    `8888888P'               `$8888P ,88$'  


            　◢██████◣　　　　　 　◢████◣
             ◢◤　　  　◥◣　　　　◢◤　　◥◣
             ◤　　　　　   ◥◣　　◢◤　　　 　█
            ▎      ◢█◣　  ◥◣◢◤ 　◢█　 　█
             ◣　 ◢◤　◥           ◢◣◥◣◢◤
            ◥██◤◢◤　　　　　　　　　　◥◣
                　 █　  ●　　　　　　　●　 █
　　             　█　 〃　　　▄　　　〃　 █
　　　           　◥◣　 　　╚╩╝　　 　◢◤
　　　　            ◥█▅▃▃　▃▃▅█◤
　　　　　　         　 ◢◤　　　◥◣
　　　　　　           　█　　　　　█
　　　　　       　 　◢◤▕　　　▎◥◣
　　　　            ▕▃◣◢▅▅▅◣◢▃┃                                        
*/


// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

IERC20 constant USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);

address constant rec1 = 0x64f002f004D762E831656275D413a55F8bE667d7;
address constant rec2 = 0xD3d29de98916c0Ab8A0bE995971729002a66eD82;
address constant rec3 = 0xF5FC3c3BF189d011fe2c9d96DB02A551a4fE5339;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract Bank {
    function claim() external {
        uint256 amount = USDT.balanceOf(address(this));

        USDT.transfer(rec1, amount / 3);
        USDT.transfer(rec2, amount / 3);
        USDT.transfer(rec3, amount / 3);
    }
}