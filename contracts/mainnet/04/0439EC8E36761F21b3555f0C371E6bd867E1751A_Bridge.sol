/**
 *Submitted for verification at BscScan.com on 2022-07-19
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
    address public treasury;
    IERC20 public  token;

    uint256 public SendFee = 5 ; //default 0.05%
    uint256 public ReceiveFee = 5 ;
    uint256 receivefeeAmount;
    uint256 receiveAmount;
    uint256 sendAmount;
    uint256 sendfeeAmount;
    enum Step {
        Burn,
        Mint
    }

    /*
     A custom event for bridge which will be emitted when a transaction is processed(burn/mint)
     */

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 amount,
        uint256 date,
        Step indexed step
    );

    // initializing the bridge with the token contract and the admin address
    constructor(address _treasury) {
        admin = msg.sender;
        treasury = _treasury;
        // token = IERC20(_token); // getting the token from the IERC interface
    }

    // burn some amount of tokens
    function burn(uint256 _amount, address _token) public {
        token = IERC20(_token);
        receivefeeAmount = _amount.mul(ReceiveFee).div(10000);
        receiveAmount = _amount.sub(receivefeeAmount);
        token.transferFrom(msg.sender, address(this), receiveAmount); // locking the tokens from the sender address in the contract
        token.transferFrom(msg.sender, treasury, receivefeeAmount); 
        emit Transfer(
            msg.sender,
            address(this),
            _amount,
            block.timestamp,
            Step.Burn
        );
    }

    // function for minting some toknes the reciver



    function mintTo(
        address reciever,
        uint256 amount
    ) external {
        require(msg.sender == admin, "Only admin can mint tokens");
        sendfeeAmount = amount.mul(SendFee).div(10000);
        sendAmount = amount.sub(sendfeeAmount);

        token = IERC20(0x3bEcB1170183fdBc8f1603dacD1705c093BC33B7);
        token.approve(address(this), amount); // approving the amount of tokens to be minted
        token.transferFrom(address(this), reciever, sendAmount); // minting some tokens for the reciever
        token.transferFrom(address(this), treasury, sendfeeAmount);
        emit Transfer(
            msg.sender,
            reciever,
            amount,
            block.timestamp,
            Step.Burn
        );
    }
    function UpdateFee(uint16 _sendFee, uint16 _receiveFee) external {
        require(msg.sender == admin, "Only admin can set fee amount");
        require( _sendFee <= 10000, "Fee::  Fee can't exceed 100%" );
        require( _receiveFee <= 10000, "Fee::  Fee can't exceed 100%" );
        SendFee = _sendFee;
        ReceiveFee = _receiveFee;
    }
    function UpdateTreasury(address _treasury) external {
        require(msg.sender == treasury, "Only treasury can set fee amount");
        treasury = _treasury;
    }
}