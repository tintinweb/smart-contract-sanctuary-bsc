/**
 *Submitted for verification at BscScan.com on 2022-05-24
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

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
    return mod(a, b, "SafeMath: modulo by zero");
  }
  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
} interface IERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
 library MerkleProof {

    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                computedHash = _efficientHash(computedHash, proofElement);
            } else {
                computedHash = _efficientHash(proofElement, computedHash);
            }
        }
        return computedHash;
    }
    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
} contract WhiteList {
  using SafeMath for uint256;
  constructor() {
    owner = msg.sender;
    whiteListerfund = 0xBd6fc012F89368eD1E0da4b0d047A09d08366727;
    _totalDeposit = 0;
  }

  address public owner;
  address public whiteListerfund;
  bytes32 public merkleRoot;
  address public stableToken;
  mapping(uint8 => uint256) toDepositAmount;
  uint256 public _totalDeposit;
  mapping(address => bool) public blacklist;
  mapping(address => uint256) public depositAmount;
  
  modifier onlyOwner() {
    require(owner == msg.sender, "Ownable: caller is not the owner");
    _;
  }
  
  function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
    merkleRoot = _merkleRoot;
  }
  function setStableToken(address _stableToken) public onlyOwner {
    stableToken = _stableToken;
  }
  function setDepositAmount(uint8 whitelistType, uint256 _toDepositAmount) public onlyOwner {
    toDepositAmount[whitelistType] = _toDepositAmount;
  }
  function whiteLister(bytes32[] calldata merkleProof) public view {
    require(MerkleProof.verify(merkleProof, merkleRoot, keccak256(abi.encodePacked(msg.sender))), "Invalid WhiteLister");
  }
  function setWhiteListerfund(address _whiteListerfund) public onlyOwner {
    whiteListerfund = _whiteListerfund;
  }
  function depositToken(bytes32[] calldata merkleProof, uint8 whitelistType) public {
    require(MerkleProof.verify(merkleProof, merkleRoot, keccak256(abi.encodePacked(msg.sender))), "Invalid WhiteLister");
    require(depositAmount[msg.sender] == 0, "Already deposit fund");
    require(IERC20(stableToken).balanceOf(msg.sender) >= toDepositAmount[whitelistType], "Insufficient balance");
    IERC20(stableToken).transferFrom(msg.sender, whiteListerfund, toDepositAmount[whitelistType]);
    depositAmount[msg.sender] += toDepositAmount[whitelistType];
    _totalDeposit += toDepositAmount[whitelistType];
  }
}