/**
 *Submitted for verification at BscScan.com on 2022-07-01
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Ownable {
    address internal owner;
    constructor(address _owner) { owner = _owner; }
    modifier onlyOwner() { require(isOwner(msg.sender), "!OWNER"); _; }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

contract VaultPool is Ownable {
  using SafeMath for uint256;

  mapping (address=>bool) public isAuthorize;

  mapping (address=>uint256) public _claimed;
  mapping (address=>uint256) public _count;

  address public rewardToken;

  event Withdraw(address indexed admin, address indexed recaiver, uint256 amount, uint256 nounce);

  constructor() Ownable(msg.sender) {
    rewardToken = 0xCB6a9deC8D2e508cf538C4A3781f9Be758AcF311;
    isAuthorize[owner] = true;
  }

  function Authorize(address account,bool flag) public {
    isAuthorize[account] = flag;
  }

  function updateToken(address _token) public onlyOwner {
    rewardToken = _token;
  }

  function getMessageHash(address _to,uint _amount,uint _nonce) public pure returns (bytes32) {
    return keccak256(abi.encodePacked(_to, _amount, _nonce));
  }

  function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
    return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
  }

  function verify(address _signer,address _to,uint _amount,uint _nonce,bytes memory signature) public view returns (bool) {
    bytes32 messageHash = getMessageHash(_to, _amount, _nonce);
    bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);     
    require(isAuthorize[_signer] == true,"_signer != admin");
    return recoverSigner(ethSignedMessageHash, signature) == _signer;
  }

  function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature) public pure returns (address) {
    (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
    return ecrecover(_ethSignedMessageHash, v, r, s);
  }

  function splitSignature(bytes memory sig) public pure returns (bytes32 r,bytes32 s,uint8 v) {
    require(sig.length == 65, "invalid signature length");
    assembly { 
        r := mload(add(sig, 32))
        s := mload(add(sig, 64))
        v := byte(0, mload(add(sig, 96))) }
  }

  function ClaimReward(address _admin,uint256 _amount,bytes memory _sig) external returns(bool) {
    bool success = verify(_admin,msg.sender,_amount,_count[msg.sender],_sig);
    require(success,"Revert By Vault : Claim Fail");
    require(_amount>_claimed[msg.sender]);
    uint256 claimamount = _amount.sub(_claimed[msg.sender]);
    _claimed[msg.sender] = _claimed[msg.sender].add(claimamount);
    _count[msg.sender] = _count[msg.sender].add(1);
    IBEP20 a = IBEP20(rewardToken);
    a.transfer(msg.sender,claimamount);
    return true;
  }

}