/**
 *Submitted for verification at BscScan.com on 2022-05-06
*/

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

interface IERC20 {
   function decimals() external view returns (uint8);
  function transfer(address to, uint256 amount) external returns (bool);
}

contract SimpleFaucet {
  address public owner;
  receive() payable external {}

  mapping(address => bool) public authorized;
  mapping(address => mapping(address => uint256)) public claimedTokens;
  mapping(address => uint256) public claimedBNB;
  mapping(address => uint256) public lastRequest;

  constructor() {
    authorized[msg.sender] = true;
    owner = msg.sender;
  }

  event Droplet(address indexed recipient, address indexed token, uint256 indexed amount);
  event DropETH(address indexed recipient, uint256 indexed nextClaim);

  modifier isAuthorized {
    require(authorized[msg.sender], "Unauthorized. Ask Developer!");
    _;
  }

  modifier isOwner {
    require(msg.sender == owner, "Not Owner");
    _;
  }

  /// @notice lets an authorized user request tokens from the faucet
  /// @param to - the recipient of the tokens
  /// @param token - the token address that is requested
  /// @param amount - amount of tokens to be withdrawn. A whole number between 1 and 1,000,000
  function getTokens(address to, address token, uint256 amount) external isAuthorized {
    require(amount < 1000000, "Maximum is 1m units");
    uint256 _amount = amount * 10 ** IERC20(token).decimals();
    claimedTokens[to][token] += _amount;
    IERC20(token).transfer(to, _amount);
    emit Droplet(to, token, _amount);
  }

  /// @notice lets contract owner authorize faucet users
  /// @param _account - account to be authorized
  function authorizeAccount(address _account) external isOwner {
    authorized[_account] = true;
  }

  /// @notice lets contract owner unauthorize an account from using the faucet
  function unauthorizeAccount(address _account) external isOwner {
    authorized[_account] = false;
  }

  /// @notice transfers ownership to a new owner
  /// @param _newOwner - the new owner of the contract
  function transferOwnership(address _newOwner) external view isOwner {
    owner == _newOwner;
  }

  /// @notice lets authorized user get BNB from the faucet
  /// @param to - address where BNB will be sent 
  function getBNB(address to) external isAuthorized {
    require(lastRequest[to] + 2 hours < block.timestamp, "Try Again Soon");
    claimedBNB[to] += 0.01 ether;
    lastRequest[to] = block.timestamp;
    (bool success, ) = payable(to).call{ value: 0.01 ether }("");
    require(success, "Withdrawal Error");
    emit DropETH(to, block.timestamp + 2 hours);
  }

}