/**
 *Submitted for verification at BscScan.com on 2022-07-04
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

library SafeMath {
 
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, "SafeMath: subtraction overflow");
    uint256 c = a - b;

    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
   
    if (a == 0 || b == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0, "SafeMath: division by zero");
    uint256 c = a / b;

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0, "SafeMath: modulo by zero");
    return a % b;
  }
}

contract Mod {
    using SafeMath for uint256;

    struct Tree {
        string name;
        string longitude;
        string latitude;
        address projectAddr;
    }

    address payable public owner;
    uint256 _treePoolSize;
    uint256 _planterNumber;

    mapping(address => Tree[]) public _treePool;
    mapping(address => bool) _planters;

    event LogInfo(address indexed planter, string message);
    event LogInfoUint256(string message, uint256 intMessage);

    constructor() {
        owner = payable(msg.sender);
        _treePoolSize = 0;
        _planterNumber = 0;
    }

    modifier _accessValidator() {
        require(msg.sender == owner, "Contract validation: Access denied!.");
        _;
    }

    modifier _walletValidator(address _addr) {
        require(_addr != address(0), "Contract validation: Invalid wallet address!.");
        _;
    }
    
    function plant(address _planter, string calldata name, string calldata longitude, 
                string calldata latitude, address projectAddr) 
    public _accessValidator _walletValidator(_planter){
        if(!_planters[_planter]) {
            _planterNumber = _planterNumber.add(1);
        } else {
            _planters[_planter] = true;
        }

        emit LogInfo(_planter, "Contract Log: Planting the tree!.");
        _treePool[_planter].push(Tree(name, longitude, latitude, projectAddr));
        _treePoolSize = _treePoolSize.add(1);

        emit LogInfo(_planter, "Contract Log: Planted the tree!.");
    }

    function getTrees(address _planter) public _walletValidator(_planter) returns(Tree[] memory) {
        // Get planter`s trees
        emit LogInfo(_planter, "Contract Log: Getting planter`s trees from contract!...");
        return _treePool[_planter];
    }

    function getTreePoolSize() public returns(uint) {
        emit LogInfoUint256("Contract Function Log: Tree Pool Size was retrieved...", _treePoolSize);
        return _treePoolSize;
    }

    function getPlanterNumber() public returns(uint) {
        emit LogInfoUint256("Contract Function Log: Planter Number was retrieved...", _planterNumber);
        return _planterNumber;
    }

    function isPlanter(address _planter) public view returns(bool) {
        return _planters[_planter];
    }
   
}