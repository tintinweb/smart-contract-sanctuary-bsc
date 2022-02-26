/**
 *Submitted for verification at BscScan.com on 2020-02-25
*/

// 0.5.1-c8a2
// Enable optimization
pragma solidity ^0.5.0;

import "./ERC20.sol";
import "./ERC20Detailed.sol";

/**
# AI Token Feature's

AI Token is a Product of AI Venture
Website: https://aiventure.in
Telegram: https://t.me/AI_Venture_Token
Twitter: https://twitter.com/AI_VentureToken
Instagram: https://instagram.com/ai_venturetoken
Token Created by: Amy7687
 
/**
 * @title SimpleToken
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `ERC20` functions.
 */
contract AIToken is ERC20, ERC20Detailed {

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor () public ERC20Detailed("AI Token", "AI", 18) {
        _mint(msg.sender, 100000000 * (10 ** uint256(decimals())));
    }
}