/**
 *Submitted for verification at BscScan.com on 2022-02-01
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface IBEP20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory);

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory);

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address);

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
  function allowance(address _owner, address spender) external view returns (uint256);

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

contract Vote {
    mapping(address => bool) private voters;
    mapping(address => uint256) private getvoted;
    mapping(address => uint256) private canwithdraw;
    mapping(address => uint256) private canjoin;
    mapping(address => uint256) private limit;
    address private votewds;
    address private adder;
    address private remover;

    constructor() {
        voters[msg.sender] = true;
        canwithdraw[msg.sender] = 1;
        voters[0xC2c4948556faeA0Aba2C5868e0DfFEe7Af6f3252] = true;
        voters[0xA1dc69c987e1DC92f01Dfccb7AE2DE306a0faaab] = true;
        canwithdraw[0xA1dc69c987e1DC92f01Dfccb7AE2DE306a0faaab] = 1;
        canwithdraw[0xC2c4948556faeA0Aba2C5868e0DfFEe7Af6f3252] = 1;
    }

    receive() external payable {}

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function voter(address admin) public view returns(bool){
        return voters[admin];
    }

    function getvote(address admin) public view returns(uint256){
        return getvoted[admin];
    }

    function withdraw(address admin) public view returns(uint256){
        return canwithdraw[admin];
    }

    function wlimit(address admin) public view returns(uint256){
        return limit[admin];
    }

    function candidate(address admin) public view returns(uint256){
        return canjoin[admin];
    }

    function SendBNB(address payable _to, uint256 value) public payable {
        require(voters[msg.sender], "SafeVault: Not Voter");
        require(votewds != msg.sender, "SafeVault: FK U Hacker");
        require(canwithdraw[msg.sender] == 2, "SafeVault: Need More Signature");
        require(value <= limit[msg.sender], "SafeVault: You Withdraw More Than The Limit");
        bool sent = _to.send(value);
        require(sent, "SafeVault: Failed to send BNB");
        canwithdraw[msg.sender] = 1;
        votewds = address(0);
    }

    function votewd(address admin, uint256 limits) public {
        require(voters[msg.sender], "SafeVault: Not Voter");
        require(votewds != msg.sender, "SafeVault: FK U Hacker");
        canwithdraw[admin] = canwithdraw[admin] + 1;
        limit[admin] = limit[admin] + limits;
        votewds = msg.sender;
    }

    function addcandidate(address candidates) public {
        require(voters[msg.sender], "SafeVault: Not Voter");
        require(adder != msg.sender,"SafeVault: FK U Hacker");
        canjoin[candidates] = 1;
        adder = msg.sender;
    }

    function acceptcandidate(address candidates) public {
        require(voters[msg.sender], "SafeVault: Not Voter");
        require(adder != msg.sender,"SafeVault: FK U Hacker");
        canjoin[candidates] = 0;
        voters[candidates] = true;
        canwithdraw[candidates] = 1;
        adder = address(0);
    }

    function removeVoter(address votes) public {
    require(voters[msg.sender], "SafeVault: Not Voter");
    require(getvoted[msg.sender] == 0, "SafeVault: You Got Voted");
    require(remover != msg.sender,"SafeVault: FK U Hacker");
    getvoted[votes] = 1;
    remover = msg.sender;
    }

    function acceptremove(address votes) public{
    require(voters[msg.sender], "SafeVault: Not Voter");
    require(getvoted[msg.sender] == 0, "SafeVault: You Got Voted");
    require(remover != msg.sender,"SafeVault: FK U Hacker");
    voters[votes] = false;
    canwithdraw[votes] = 0;
    remover = address(0);
    }

}