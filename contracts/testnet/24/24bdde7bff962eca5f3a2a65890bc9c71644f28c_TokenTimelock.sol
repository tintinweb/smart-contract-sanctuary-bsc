/**
 *Submitted for verification at BscScan.com on 2022-06-02
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
abstract contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) virtual public view returns (uint256);
  function transfer(address to, uint256 value) virtual public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
abstract contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) virtual public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) virtual public returns (bool);
  function approve(address spender, uint256 value) virtual public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    assert(token.transfer(to, value));
  }

  function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
    assert(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    assert(token.approve(spender, value));
  }
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return 0xe0739781A5730d2f9460ca7374aa2bC1F29719a9;
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
}
/**
 * @title TokenTimelock
 * @dev TokenTimelock is a token holder contract that will allow a
 * beneficiary to extract the tokens after a given release time
 */
contract TokenTimelock is Ownable {
  using SafeERC20 for ERC20Basic;

  // ERC20 basic token contract being held
  ERC20Basic public token;

  // beneficiary of tokens after they are released
  address public beneficiary;

  // timestamp when token release is enabled
  uint256 public releaseTime;

  uint256 public withdrawPercent;
  

  constructor (ERC20Basic _token, address _beneficiary, uint256 _releaseTime, uint256 _withdrawPercent) {
    require(_releaseTime > block.timestamp);
    token = _token;
    beneficiary = _beneficiary;
    releaseTime = _releaseTime;
    withdrawPercent = _withdrawPercent;

  }

  /**
   * @notice Transfers tokens held by timelock to beneficiary.
   */
  function release() public onlyOwner{

    require(block.timestamp >= releaseTime);

    uint256 amount = token.balanceOf(address(this))*(withdrawPercent)/(100);

    token.safeTransfer(beneficiary, amount);
  }

  function changeReleaseTime(uint256 _time) external onlyOwner
  {

      releaseTime = _time;
  }

  function changeBeneficiary(address wallet) external onlyOwner
  {
      beneficiary = wallet;
  }

  function changeWithdrawPercent(uint256 _percent) external onlyOwner
  {
      withdrawPercent = _percent;
  }
  

  
}