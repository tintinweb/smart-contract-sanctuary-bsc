/**
 *Submitted for verification at BscScan.com on 2022-11-11
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.1;
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
contract VoteBattleReward {
  string public name = "Vote Battle Reward";
  address public owner;
  address public treasuryAddress;
  address public depositAddress;
  address public signer;
  address public corkAddress;
  mapping(address => bool) public withdrawTokensWhitelist;
  mapping(address => uint256) public nonce;
  bool public paused;
  event Withdraw(address user, address token, uint256 amount);
  event Deposit(address wallet, uint256 amount);
  constructor(
    address _treasuryAddress,
    address _depositAddress,
    address _corkToken,
    address _signer
  ) {
    signer = _signer;
    owner = msg.sender;
    treasuryAddress = _treasuryAddress;
    depositAddress = _depositAddress;
    corkAddress = _corkToken;
    paused = false;
    withdrawTokensWhitelist[_corkToken] = true;
  }
  function setPause(bool _paused) public onlyOwner {
    paused = _paused;
  }
  function setSigner(address _signer) public onlyOwner {
    signer = _signer;
  }
  function setTreasuryAddress(address _treasuryAddress) public onlyOwner {
    require(_treasuryAddress != address(0), "Address cant be zero");
    treasuryAddress = _treasuryAddress;
  }
  function reOwner(address _newOwner) public onlyOwner {
    owner = _newOwner;
  }
  function addWhiteListWithdrawTokens(address[] calldata _tokens) public onlyOwner {
    for (uint256 i = 0; i < _tokens.length; i++) {
      require(_tokens[i] != address(0), "Address cant be 0");
      withdrawTokensWhitelist[_tokens[i]] = true;
    }
  }
  function delWhiteListDealTokens(address[] calldata _tokens) public onlyOwner {
    for (uint256 i = 0; i < _tokens.length; i++) {
      delete withdrawTokensWhitelist[_tokens[i]];
    }
  }
  function deposit(uint256 _amount) public whenNotPaused {
    require(_amount > 0, "Amount cannot be 0");
    IERC20(corkAddress).transferFrom(msg.sender, depositAddress, _amount);
    emit Deposit(msg.sender, _amount);
  }
  function verifyMessage(
    address _withdrawToken,
    uint256 _value,
    address _sender,
    uint256 _timeout,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  ) internal returns (bool) {
    bytes memory prefix = "\x19Ethereum Signed Message:\n32";
    bytes32 hashedMessage = keccak256(
      abi.encode(_withdrawToken, _value, _sender, _timeout, nonce[_sender]++)
    );
    bytes32 prefixedHashMessage = keccak256(abi.encodePacked(prefix, hashedMessage));
    address signedAddress = ecrecover(prefixedHashMessage, _v, _r, _s);
    return signedAddress == signer;
  }
  function withdrawPermit(
    address _withdrawToken,
    uint256 _amount,
    address _address,
    uint256 _timeout,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  ) public validWithdrawToken(_withdrawToken) whenNotPaused {
    require(_amount > 0, "Amount cannot be 0");
    require(block.timestamp < _timeout, "Timeout");
    require(msg.sender == _address, "Not same user");
    require(verifyMessage(_withdrawToken, _amount, _address, _timeout, _v, _r, _s), "Not Accepted");
    require(!paused, "Contract end");
    // Transfer token
    IERC20(_withdrawToken).transferFrom(treasuryAddress, _address, _amount);
    emit Withdraw(msg.sender, _withdrawToken, _amount);
  }
  modifier whenNotPaused() {
    require(!paused, "Paused!");
    _;
  }
  modifier onlyOwner() {
    require(msg.sender == owner, "Only the owner of contract can call this function");
    _;
  }
  modifier validWithdrawToken(address _token) {
    require(withdrawTokensWhitelist[_token], "Deal token not available");
    _;
  }
}