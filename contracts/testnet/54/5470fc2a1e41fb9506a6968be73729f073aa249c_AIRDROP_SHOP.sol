/**
 *Submitted for verification at BscScan.com on 2022-04-27
*/

// SPDX-License-Identifier: MIT

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

pragma solidity ^0.8.4;

contract AIRDROP_SHOP {
    IERC20 private mainToken;
    address public owner;
    address public sponsor;
    uint public AIRDROP_AMOUNT = 1000*10**18;
    mapping(address => bool) public airdropUsers;
    uint public BOX_PRICE = 1000*10**18;
    mapping(address => uint) public luckyBoxes;
    
    constructor(address token){
        owner = msg.sender;
        sponsor = msg.sender;
        mainToken = IERC20(token);
    }
    
    modifier checkOwner(){
        require(msg.sender == owner, "Sorry, you don't have permission");
        _;
    }
    
    modifier checkSponsor(){
        require(msg.sender == sponsor, "Sorry, you don't have permission");
        _;
    }
    
    function airdropTokenToPlayer(address player) external checkSponsor{
        require(!airdropUsers[player], "Sorry, you have received airdrop tokens");
        mainToken.transferFrom(sponsor, player, AIRDROP_AMOUNT);
        airdropUsers[player] = true;
    }
    
    function sendTokenToPlayer(address player, uint amount) external checkSponsor{
        mainToken.transferFrom(sponsor, player, amount);
    }

    function approve(uint amount) external{
        mainToken.approve(address(this), amount);
    }
    
    function buyLuckyBox(uint amount) payable external{
        require(mainToken.allowance(msg.sender, address(this)) >= amount*BOX_PRICE, "Please approve enough the amount of tokens'");
        mainToken.transferFrom(msg.sender, sponsor, amount);
        luckyBoxes[msg.sender] = luckyBoxes[msg.sender] + 1;
    }
    
    function openLuckyBox(address player, bool win) external checkSponsor{
        require(luckyBoxes[player] > 0, "Sorry, you don't have a lucky box");
        luckyBoxes[msg.sender] = luckyBoxes[msg.sender] - 1;
        if (win) {
            mainToken.transferFrom(sponsor, player, BOX_PRICE*2);
        }
    }
}