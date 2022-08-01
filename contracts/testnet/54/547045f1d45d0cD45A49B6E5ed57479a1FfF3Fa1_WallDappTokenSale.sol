// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.15;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract WallDappTokenSale {
    address public owner;
    uint private buyPrice;
    uint private sold;
    uint private toSold;
    uint private currentPhaseIndex;
    address private nullAddress = address(0);
    IERC20 private token;

    struct Phase {
        uint total;
        uint price;
        uint phase;
    }

    Phase[] private phases;

    event Sell(address _buyer, uint _amount);

    constructor(address _token) {
        owner = msg.sender;
        token = IERC20(_token);
        buyPrice = 0.001 * 10**18;
        sold = 0;
        toSold = __getAmount(500000);
        currentPhaseIndex = 0;

        // Create the phases
        for(uint phase = 1; phase <= 5; phase++) {
            phases.push(Phase(100000, phase * buyPrice, phase));
        }
    }

    // Buy tokens
    function buy(uint tokens) public payable{
        require(msg.sender != nullAddress);

        // Get the current phase
        Phase memory phase = getPhase();

        // Check if there are enough tokens left
        require(phase.total >= __getAmount(tokens), 'There are not enough tokens left');
        
        // Check if the user is sending the exact amount of BNB
        require(msg.value / phase.price == tokens, 'Error, value not match');

        // Check the balance of the token in the contract
        require(token.balanceOf(address(this)) >= __getAmount(tokens), 'Sold out');

        // Make the token's transfer
        require(token.transfer(msg.sender, __getAmount(tokens)));

        sold += tokens;
        phase.total -= tokens;

        // Check if the phase has to be changed and changing it if it's nedded
        changePhase(phase);

        // Emit event
        emit Sell(msg.sender, tokens);
    }

    // Change phase
    function changePhase(Phase memory _phase) private {
        if (_phase.total <= 1000) {
            currentPhaseIndex++;
        }
    }

    // Get the wei of an amount
    function __getAmount(uint _amount) private pure returns(uint) {
        return _amount * 10**18;
    }

    // Transform wei to int
    function __getUnAmount(uint256 _amount, uint decimals) private pure returns(uint) {
        return _amount / 10**decimals;
    }

    // Get the quantity of tokens the user have
    function getUserBalance() public view returns(uint) {
        return __getUnAmount(token.balanceOf(msg.sender), 18);
    }

    // Get the total supply of the token
    function getTotalSupply() public view returns(uint) {
        return __getUnAmount(token.totalSupply(), 18);
    }

    // Get the current token price
    function getPrice() public view returns(uint) {
        return buyPrice;
    }

    // Get how many tokens have been sold so far
    function getTokensSold() public view returns(uint) {
        return sold;
    }

    // Check which phase we are in and get it
    function getPhase() public view returns(Phase memory) {
        return phases[currentPhaseIndex];
    }

    // Get a list if the phases
    function getPhases() public view returns(Phase[] memory) {
        return phases;
    }

    // End the token sale
    function endSale() public isOwner {
        require(token.transfer(owner, token.balanceOf(address(this)))); // If not all the tokens are sold, transfer the rest to the owner
        payable(owner).transfer(address(this).balance); // Transfer all the BNB to the owner
    }

    // Check if the user is the owner of the contract
    function __isOwner() public view returns(bool) {
        return msg.sender == owner;
    }

    // Check if the user is the owner of the contract
    modifier isOwner() {
        require(msg.sender == owner);
        _;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

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