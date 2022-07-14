//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract WdappTokenSale {
    
    address public owner; //direccion del dueno del contrato 
    uint private buyPrice; 
    uint private sold; 
    uint private toSold; // cantidad detokes que se van a vender 
    address private noOne = address(0);
    IERC20 private token; 
    uint private currentPhaseIndex;

    struct Phase {

        uint total; 
        uint price; 
        uint phase; 
    }

    Phase [] private phases; 

    event Sell(address _buyer, uint _amount); 

    constructor(address _token){
        owner = msg.sender; 
        token = IERC20(_token);
        buyPrice = 0.000005 * 10**18;
        currentPhaseIndex = 0; 
        sold = 0; 
        toSold = __amount(1000000);

        //vendemos en 10 fases, de 100.000 cada una para vender los 1.000.000 tokens 
        for(uint i=1; i<=10; i++){
            phases.push(Phase(100000, i*buyPrice, i));
        }
    }

    function buy(uint tokens) public payable{
        require(msg.value / phase(currentPhaseIndex).price == tokens, 'Error value not match');
        require(phase(currentPhaseIndex).total <= __amount(tokens), 'Error low balance');
        require(token.balanceOf(address(this)) >= __amount(tokens), 'Sold out');
        require(token.transfer(msg.sender, __amount(tokens)));

        sold += tokens; 
        phases[currentPhaseIndex].total -= tokens; 
        if(phase(currentPhaseIndex).total <= 0)
            currentPhaseIndex++; 

        buyPrice = phase(currentPhaseIndex).price; 

        emit Sell(msg.sender, tokens); 

    }

    //recibe la cantidad en wei y retorna la cantidad en tokes 
    function __unAmount(uint256 _amount, uint decimals) private pure returns(uint){
        return _amount / (10**decimals);
    }

        // cuantos tokens tiene el usuario que llama la funcion 
    function __tokens() public view returns (uint){
        return __unAmount(token.balanceOf(msg.sender), 18);
    }

    function __tokenPrice() public view returns(uint){
        return buyPrice; 
    }


    function endSale() public isOwner{
        require(token.transfer(owner, token.balanceOf(address(this))));
        payable(owner).transfer(address(this).balance);
    }

    function phase (uint phase_id) public view returns(Phase memory){
        return phases[phase_id];
    }

    function __amount (uint _amount) private pure returns(uint){
        return _amount * (10 ** 18); 
    }

    function tokensSold() public view returns(uint){
        return sold;
    }

    function totalTokens () public view returns (uint){
        return __unAmount(token.totalSupply(), 18);
    }

    function __phases() public view returns (Phase [] memory){
        return phases; 
    }

    function currentPhase() public view returns (Phase memory){
        return phase(currentPhaseIndex);
    }

    function __isOwner() public view returns (bool){
        return msg.sender == owner; 
    }

    modifier isOwner(){
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