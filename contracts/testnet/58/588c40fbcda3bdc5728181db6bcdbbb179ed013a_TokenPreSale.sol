/**
 *Submitted for verification at BscScan.com on 2022-10-23
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract TokenPreSale is Ownable {
    // address of admin
    IERC20 public token;
    // token price variable
    //by blockdev
    // uint256 public tokensPerBNB;
    uint256 public tokensPerBNB = 50000;
    // count of token sold vaariable
    uint256 public totalsold; 
     
     // Event that log buy and sell operation
    event Buy(address sender, uint256 amountOfBNB, uint256 totalvalue); 
    event Sell(address sender, uint256 totalvalue, uint256 amountOfBNB); 
     
    
    // constructor 
    //by blockdev
    // constructor(address _tokenaddress, uint256 _tokensPerBNB){
    constructor(address _tokenaddress){
        // tokensPerBNB = _tokensPerBNB;
        token  = IERC20(_tokenaddress);
    }
   
    // buyTokens function
    function buyTokens() public payable{
        address buyer = msg.sender;
        // uint256 bnbAmount = msg.value;
        uint256 amountToBuy = msg.value * tokensPerBNB;
        // check if the contract has the tokens or not
        uint256 tokenToBuyBalance = token.balanceOf(address(this));
        require(tokenToBuyBalance >= amountToBuy,"the smart contract dont hold the enough tokens");
        // transfer the token to the user
        // token.transfer(buyer, amountToBuy);
        (bool sent) = token.transfer(buyer, amountToBuy);
        require(sent, "Failed to transfer token to the buyer");
        // increase the token sold
        totalsold += amountToBuy;

        // emit sell event for ui
        emit Buy(buyer, msg.value, amountToBuy);
    }

    // end sale
    function endsale() public onlyOwner {
        // transfer all the remaining tokens to admin
        token.transfer(msg.sender, token.balanceOf(address(this)));
        // transfer all the etherum to admin and self selfdestruct the contract
        selfdestruct(payable(msg.sender));
    }
}