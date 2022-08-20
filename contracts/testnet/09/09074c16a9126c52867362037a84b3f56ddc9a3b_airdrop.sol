// SPDX-License-Identifier: MIT
import "./TokenListing.sol";

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

contract airdrop is Ownable, ReentrancyGuard, token_listing{
    using SafeMath for uint256;

    uint256 public airdropTokens;
    uint256 public totalClaimed;
    uint256 public amountOfTokens;
    mapping (address => bool) public tokensReceived;
    mapping (address => bool) public airdropAgent;
    IERC20 public token;

    function fixAirdropAmount(uint256 _amount) public {
        totalClaimed = 0;
        amountOfTokens = _amount;
    }

    // Send a static number of tokens to each user in an array (e.g. each user receives 100 tokens)
    function airdropStatic(address[] calldata _recipients, uint256 token_selected) public onlyAirdropAgent {  
        require(token_selected == token_list[token_selected].token_id, "Token does not exist");

        Token_List memory t_listing = token_list[token_selected];
        IERC20 token_use = t_listing.token_address;

        for (uint256 i = 0; i < _recipients.length; i++) {
            require(token_use.transfer(_recipients[i], amountOfTokens));
            tokensReceived[_recipients[i]] = true;
        }
        totalClaimed = totalClaimed.add(amountOfTokens * _recipients.length);
    }

    // Send a dynamic number of tokens to each user in an array (e.g. each user receives 10% of their original contribution) 
    function airdropDynamic(address[] calldata _recipients, uint256[] calldata _amount, uint256[] calldata token_selected) public onlyAirdropAgent {
        // require(token_selected == token_list[token_selected].token_id, "Token does not exist");

        for (uint256 i = 0; i < _recipients.length; i++) {
            for(i = 0; i <  token_selected.length; i++){
                if(token_selected[i] == token_list[i].token_id){
                    IERC20 token_use = token_list[token_selected[i]].token_address;
                    require(token_use.transfer(_recipients[i], _amount[i]));
                    tokensReceived[_recipients[i]] = true; 
                    totalClaimed = totalClaimed.add(_amount[i]);    
                }
            }  
        } 
    }

    // Allow this agent to call the airdrop functions
    function setAirdropAgent(address _agentAddress, bool state) public onlyOwner {
        airdropAgent[_agentAddress] = state;
    }
    
    // Specify the ERC20 token address
    function setTokenAddress(address _tokenAddress) public onlyAirdropAgent {
        token = IERC20(_tokenAddress);
    }

    // Set the amount of tokens to send each user for a static airdrop
    function setTokenAmount(uint256 _amount) public onlyAirdropAgent {
        amountOfTokens = _amount;
    }

    modifier onlyAirdropAgent() {
        require(airdropAgent[msg.sender]);
         _;
        
    }
}