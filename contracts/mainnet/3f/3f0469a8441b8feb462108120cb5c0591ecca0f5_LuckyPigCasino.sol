/**
 *Submitted for verification at BscScan.com on 2022-02-13
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;


interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function decimals() external pure returns (uint8);
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
   
}

contract LuckyPigCasino {

    address private owner;
    event TransferReceived(address _from, uint _amount, uint _balance);
    bool private paused;
    IERC20 private token;
    //uint token_Decimals = 9;

    constructor(IERC20 _token) {
        token = _token;
        owner=msg.sender;
    }


    // Modifiers can take inputs. This modifier checks that the
    // address passed in is not the zero address.
    modifier validAddress(address _addr) {
        require(_addr != address(0), "Not valid address");
        _;
    }
    modifier whenNotPaused(){
        require(!paused, "Contract is Paused at the moment");
        _;
    }
    modifier onlyOwner(){
        require (msg.sender== owner, "Only owner of the contract is allowed to invoke this function");
        _;
    }

    function transferERC20(IERC20 _token, uint256 amount) public onlyOwner{
        require(msg.sender == owner, "Only owner can withdraw tokens"); 
        uint256 balance = _token.balanceOf(address(this));
        require(amount <= balance, "Token balance is low");
        _token.transfer(owner, amount);
    }

    function sendLuckyPigTokensToUser(uint256 _numberOfTokens, address recipient) external onlyOwner{
        uint256 balance = token.balanceOf(address(this));
        require(_numberOfTokens <= balance, "Token balance is low");
        require(token.transfer(recipient, _numberOfTokens), "TRNSFR FAILED");
        emit TransferReceived(msg.sender, _numberOfTokens,balance);
    }

    function depositLuckyPigTokensFromUser(uint256 _numberOfTokens) public whenNotPaused {
        uint balance = token.balanceOf(address(msg.sender));
        require(_numberOfTokens <= balance, "User Token balance is low");
        require(token.transferFrom(msg.sender, address(this), _numberOfTokens),"Deposit Failed");
        emit TransferReceived(msg.sender, _numberOfTokens, balance);
    }
   
    //Getter and setters
    //View function as it reads blockchain data. Whereas pure functions are defined when no data is read from blockchain
    function getToken() public view returns(IERC20){
        return token;
    }
    function setToken(IERC20 _token) external onlyOwner {
        token = _token;
    }

    function setOwner(address _newOwner) external onlyOwner validAddress(_newOwner)  {
        owner = _newOwner;
    }
    function getOwner() public view returns(address){
        return owner;
    }
    // Important Functions
    receive() external payable {}
    fallback() external payable {}
    function getBalance() public view returns(uint){
        return address(this).balance;
    }
    function kill() external onlyOwner{
        if (msg.sender == owner) 
            selfdestruct(payable(owner));
    }
    function withraw(uint withdraw_amount) external onlyOwner{
        payable(owner).transfer(withdraw_amount);
    }
    function setPause(bool _paused) external onlyOwner {
        paused = _paused;
    }
   
}