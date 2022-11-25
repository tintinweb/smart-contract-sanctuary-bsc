/**
 *Submitted for verification at BscScan.com on 2022-11-25
*/

/**
 *Submitted for verification at snowtrace.io on 2022-11-18
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

interface IERC20 {
    function decimals() external view returns (uint8);
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
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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


// the base implementation contract for the bridge-contract


contract Bridge {
    using SafeMath for uint256;
    address public admin;
    IERC20 public  token;
    uint256 public Fee = 5 ; //default 0.05%
    uint256 receivefeeAmount;
    uint256 receiveAmount;
    uint256 sendAmount;
    uint256 sendfeeAmount;
    address public feeWallet;
    address payable  public avaxFeeWallet;
    mapping(address => uint256) public TokenFeeAmount;
    uint256 public avaxFeeAmount;

    enum Step {
        Burn,
        Mint
    }

    /*
     A custom event for bridge which will be emitted when a transaction is processed(burn/mint)
     */

    event mintTransfer(
        address indexed from,
        address indexed to,
        uint256 amount0,
        uint256 amount1,
        uint16 token0,
        uint16 token1,
        uint256 date
    );

      event Transfer(
        address indexed from,
        address indexed to,
        uint256 amount,
        uint256 date,
        Step indexed step
    );

    // initializing the bridge with the token contract and the admin address
    constructor() {
        admin = msg.sender;
        feeWallet = msg.sender;
    }

    // burn some amount of tokens
    function burn(uint256 _amount, address _token) public {
        token = IERC20(_token); 
        token.transferFrom(msg.sender, address(this), _amount);
        emit Transfer(
            msg.sender,
            address(this),
            receiveAmount,
            block.timestamp,
            Step.Burn
        );
    }

    // function for minting some toknes the reciver


    function mint(
        address from,
        address reciever,
        uint256 receivedAmount,
        uint256 amount,
        uint16 token0,
        address _token
    ) external {
        sendfeeAmount = amount.mul(Fee).div(10000);
        sendAmount = amount.sub(sendfeeAmount);
        require(msg.sender == admin, "Only admin can mint tokens");
        
        token = IERC20(_token);

        token.approve(address(this), amount); // approving the amount of tokens to be minted
        token.transferFrom(address(this), reciever, sendAmount);
        token.transferFrom(address(this), feeWallet, sendfeeAmount);
        TokenFeeAmount[_token] = TokenFeeAmount[_token] + sendfeeAmount;
        emit mintTransfer(
            from,
            reciever,
            receivedAmount,
            sendAmount,
            token0,
            1,
            block.timestamp
        );
    }

    function bnbBurn() public payable {
        uint256 amount = msg.value;
        emit Transfer(
            msg.sender,
            address(this),
            amount,
            block.timestamp,
            Step.Burn
        );
    }


    function bnbMint(
        address from,
        address payable reciever,
        uint256 amount,
        uint256 receivedAmount,
        uint16 token0

    ) external {
        sendfeeAmount = amount.mul(Fee).div(10000);
        sendAmount = amount.sub(sendfeeAmount);
        require(msg.sender == admin, "Only admin can mint tokens");
    
        reciever.transfer(sendAmount);
        avaxFeeWallet.transfer(sendfeeAmount);
        avaxFeeAmount =  avaxFeeAmount + sendfeeAmount;
        emit mintTransfer(
            from,
            reciever,
            receivedAmount,
            sendAmount,
            token0,
            0,
            block.timestamp
        );
    }

    function UpdateFee(uint16 _Fee) external {
        require(msg.sender == admin, "Only admin can set fee amount");
        require( _Fee <= 10000, "Fee::  Fee can't exceed 100%" );
        Fee = _Fee;
    }

    function updateFeeWallet(address _feeWallet) external {
        require(msg.sender == feeWallet, "Only fee wallet can set fee address");
        feeWallet = _feeWallet;
    }

    function updateBNBFeeWallet(address payable _feeWallet) external {
        require(msg.sender == feeWallet, "Only fee wallet can set fee address");
        avaxFeeWallet = _feeWallet;
    }

    function transferOwnerShip(address _owner) external {
        require(msg.sender == admin, "Only admin can set admin wallet");
        admin = _owner;
    }

 

    receive() payable external {}
}