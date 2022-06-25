/**
 *Submitted for verification at BscScan.com on 2022-06-25
*/

/*
 *
 * Liquidity Tokens will come here
 * And will be transferred at adding liquidity
 *
 * The Web3 Project
 * TG: https://t.me/TheWeb3Project
 * Website: https://theweb3project.com
 * Dev: https://t.me/ALLCOINLAB
 *
 *
 * 
 * $$$$$$$$\ $$\                       $$\      $$\           $$\        $$$$$$\        $$$$$$$\                                                $$\     
 * \__$$  __|$$ |                      $$ | $\  $$ |          $$ |      $$ ___$$\       $$  __$$\                                               $$ |    
 *    $$ |   $$$$$$$\   $$$$$$\        $$ |$$$\ $$ | $$$$$$\  $$$$$$$\  \_/   $$ |      $$ |  $$ | $$$$$$\   $$$$$$\  $$\  $$$$$$\   $$$$$$$\ $$$$$$\   
 *    $$ |   $$  __$$\ $$  __$$\       $$ $$ $$\$$ |$$  __$$\ $$  __$$\   $$$$$ /       $$$$$$$  |$$  __$$\ $$  __$$\ \__|$$  __$$\ $$  _____|\_$$  _|  
 *    $$ |   $$ |  $$ |$$$$$$$$ |      $$$$  _$$$$ |$$$$$$$$ |$$ |  $$ |  \___$$\       $$  ____/ $$ |  \__|$$ /  $$ |$$\ $$$$$$$$ |$$ /        $$ |    
 *    $$ |   $$ |  $$ |$$   ____|      $$$  / \$$$ |$$   ____|$$ |  $$ |$$\   $$ |      $$ |      $$ |      $$ |  $$ |$$ |$$   ____|$$ |        $$ |$$\ 
 *    $$ |   $$ |  $$ |\$$$$$$$\       $$  /   \$$ |\$$$$$$$\ $$$$$$$  |\$$$$$$  |      $$ |      $$ |      \$$$$$$  |$$ |\$$$$$$$\ \$$$$$$$\   \$$$$  |
 *    \__|   \__|  \__| \_______|      \__/     \__| \_______|\_______/  \______/       \__|      \__|       \______/ $$ | \_______| \_______|   \____/ 
 *                                                                                                              $$\   $$ |                              
 *      
 */


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract TheWeb3ProjectLiquifier {
    constructor () {}

    function transfer(address tokenAdr) external {
        address WEB3 = address(0x1AEb3f66d96bFaF74fCBD15Dc21798De36F6F933);
        require(msg.sender == WEB3, "Only The Web3 Project Contract can call this");

        uint balance = IERC20(tokenAdr).balanceOf(address(this));
        IERC20(tokenAdr).transfer(WEB3, balance);
    }
}