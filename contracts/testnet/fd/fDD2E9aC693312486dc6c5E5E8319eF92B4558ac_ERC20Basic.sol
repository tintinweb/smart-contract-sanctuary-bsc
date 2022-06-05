/**
 *Submitted for verification at BscScan.com on 2022-06-04
*/

//SPDX-License-Identifier: MIT

pragma solidity 0.8.14;


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

contract ERC20Basic is IERC20{

    address private thisOwner;

    string public constant name = "CryptoDanil";

    string public constant symbol = "CD";

    uint8 public constant decimals = 18;

    
    mapping (address => uint) balances;

    mapping (address => mapping (address => uint)) allowed;

    uint256 totalSupply_;

    modifier onlyOwner() {
        require(msg.sender == thisOwner, "Caller is not owner");
        _;
    }

    constructor (uint256 initialSupply) {

        thisOwner = msg.sender;

        totalSupply_ = initialSupply;

        balances[thisOwner] = totalSupply_;

    }

    function totalSupply() public override view returns (uint256){

        return totalSupply_;

    }

    function increaseTotalSupply(uint newTokensAmount) public onlyOwner {

        totalSupply_ += newTokensAmount;

        balances[msg.sender] += newTokensAmount;

    }

    function balanceOf(address tokenOwner) public override view returns (uint256){

        return balances[tokenOwner];

    }

    function allowance(address owner, address delegate) public override view returns (uint256){

        return allowed[owner][delegate];

    }

     function transfer(address recipient, uint256 numTokens) public override returns (bool){

        require(numTokens <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender] - numTokens;

        balances[recipient] = balances[recipient] + numTokens;

        emit Transfer(msg.sender, recipient, numTokens);

        return true;

    }

    function approve(address delegate, uint256 numTokens) public override returns (bool){

        allowed[msg.sender][delegate] = numTokens;

        emit Approval(msg.sender, delegate, numTokens);

        return true;

    }

    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool){

        require(numTokens <= balances[owner]);

        require(numTokens <= allowed[owner][msg.sender]);

 

        balances[owner] = balances[owner] - numTokens;

        allowed[owner][msg.sender] = allowed[owner][msg.sender] - numTokens;

        balances[buyer] = balances[buyer] + numTokens;

        emit Transfer(owner, buyer, numTokens);

        return true;

    }

//     _totalSupply += amount;

// _balances[msg.sender] += amount;

// emit Transfer(address(0), account, amount);

    // function setBalance(address userAddres, uint balance) internal {

    // balances[msg.sender] = balance;

    // }

}

// contract Lesson2_5{

//     //mapping (address => uint) public _balances;

    
//     function setBalance(address userAddres, uint balance) internal {

//     balances[userAddres] = balance;

//     }

//     function changeTotalPoints(uint a) public virtual {
//         setBalance(msg.sender, balances[msg.sender] += a);
       
//     }

//     function changeSubPoints(uint b) public {
//         setBalance(msg.sender, balances[msg.sender] -= b);
//     }
    
   
// }


// contract Premium is Lesson2_5{

//     function changeTotalPoints(uint a) public override {
//          setBalance(msg.sender, _balances[msg.sender] += a*2);
//         }

//     }


// contract VIP is Lesson2_5{

//     function changeTotalPoints(uint a) public override {
//         setBalance(msg.sender, _balances[msg.sender] += a*5);
//         }


//     }