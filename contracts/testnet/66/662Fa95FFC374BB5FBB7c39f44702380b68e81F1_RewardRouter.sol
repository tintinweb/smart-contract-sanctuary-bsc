/**
 *Submitted for verification at BscScan.com on 2022-07-27
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

interface IBANK {
  function reserve() external returns (bool);
  function getwait() external view returns (uint256);
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

contract RewardRouter is Ownable {
  using SafeMath for uint256;

  mapping (address=>bool) private ROLE_SIGNER;
  mapping (address=>uint256) private SIGNER_NONCE;
  mapping (address=>uint256) private _claimed;

  address private BANK;

  uint256 public recipeid;
  mapping (uint256=>address) public recipe_signer;
  mapping (uint256=>address) public recipe_to;
  mapping (uint256=>uint256) public recipe_amount;
  mapping (uint256=>uint256) public recipe_nonce;
  mapping (uint256=>uint256) public recipe_ethrecaive;
  mapping (uint256=>bytes) public recipe_lincense;

  constructor(address _bank,address _key) Ownable(msg.sender) {
    BANK = _bank;
    ROLE_SIGNER[_key] = true;
  }

  function claimedOf(address account) external view returns (uint256) {
    return _claimed[account];
  }

  function isSigner(address account) external view returns (bool) {
    return ROLE_SIGNER[account];
  }

  function BankAddress() external view returns (address) {
    return BANK;
  }

  function request(address _to,uint _amount) external view returns (bytes32) {
    return getMessageHash(_to,_amount,SIGNER_NONCE[_to]);
  }

  function updateBank(address account) external onlyOwner() returns (bool) {
    BANK = account;
    return true;
  }

  function grantRole_Signer(address account,bool flag) external onlyOwner() returns (bool) {
    ROLE_SIGNER[account] = flag;
    return true;
  }

  function withdraw(address _signer,address _to,uint256 _amount,bytes memory _sig) external returns (bool) {
    bool verified = verify(_signer,_to,_amount,SIGNER_NONCE[_to],_sig);
    require(verified,"withdraw fail!");
    require(ROLE_SIGNER[_signer],"signer revert");
    require(_to==msg.sender,"no permission!");
    require(_claimed[_to]<_amount,"nothing to claim!");

    uint256 ethamount = _amount.sub(_claimed[_to]);
    if( address(this).balance < ethamount ){
        IBANK a = IBANK(BANK);
        uint256 wait = a.getwait();
        if(block.timestamp>wait){
            a.reserve();
        }else{
            revert("not enought reward");
        }
    }

    (bool success, ) = msg.sender.call{ value : ethamount }("");
    require(success,"transfer fail!");

    _claimed[_to] = _amount;
    generaterecipe(_signer,_to,_amount,SIGNER_NONCE[_to],ethamount,_sig);
    SIGNER_NONCE[_to] = SIGNER_NONCE[_to].add(1);

    return true;
  }

  function purge() external onlyOwner() returns (bool) {
    (bool success, ) = msg.sender.call{ value : address(this).balance }("");
    require(success,"purge fail!");
    return true;
  }

  //internal//

  function generaterecipe(address _signer,address _to,uint256 _amount,uint256 _nonce,uint256 _eth,bytes memory _sig) internal returns (bool) {
    recipeid = recipeid.add(1);
    recipe_signer[recipeid] = _signer;
    recipe_to[recipeid] = _to;
    recipe_amount[recipeid] = _amount;
    recipe_nonce[recipeid] = _nonce;
    recipe_ethrecaive[recipeid] = _eth;
    recipe_lincense[recipeid] = _sig;
    return true;
  }

  function verify(address _signer,address _to,uint _amount,uint _nonce,bytes memory signature) internal pure returns (bool) {
    bytes32 messageHash = getMessageHash(_to, _amount, _nonce);
    bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);     
    return recoverSigner(ethSignedMessageHash, signature) == _signer;
  }

  function getMessageHash(address _to,uint _amount,uint _nonce) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(_to, _amount, _nonce));
  }

  function getEthSignedMessageHash(bytes32 _messageHash) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
  }

  function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature) internal pure returns (address) {
    (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
    return ecrecover(_ethSignedMessageHash, v, r, s);
  }

  function splitSignature(bytes memory sig) internal pure returns (bytes32 r,bytes32 s,uint8 v) {
    require(sig.length == 65, "invalid signature length");
    assembly { 
        r := mload(add(sig, 32))
        s := mload(add(sig, 64))
        v := byte(0, mload(add(sig, 96))) }
  }
  function recaive() public payable {}

}