/**
 *Submitted for verification at BscScan.com on 2022-12-07
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface IERC20{
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract Ownable{    
  address private _owner;
  
  constructor(){
    _owner = msg.sender;
  }
  
  function owner() public view returns(address){
    return _owner;
  }
  
  modifier onlyOwner(){
    require(isOwner(), "Function accessible only by the owner !!");
    _;
  }
  
  function isOwner() public view returns(bool){
    return msg.sender == _owner;
  }
}

contract DaraVaultProxy is Ownable {
    address public busdTokenAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    uint256 public busdFee = 1*10**18;

    address public bnbTokenAddress = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    uint256 public bnbFee = 1*10**18;

    address public batTokenAddress = 0x101d82428437127bF1608F699CD651e6Abf9766E;
    uint256 public batFee = 5*10**18;

    address public daraTokenAddress = 0x0255af6c9f86F6B0543357baCefA262A2664f80F;
    uint256 public daraFee = 30*10**18;
    
    address public treasury = 0x917b59218AE506f782d092493BC2302711DCD972;

    mapping (address => bool) public blacklisted;

    constructor() {
        
    }
    
    function setBlacklisted(address account, bool state) external onlyOwner{
        require(blacklisted[account] != state, "Value already set");
        blacklisted[account] = state;
    }

    function setTokenFee(uint256 _newFee, string memory _token) external onlyOwner{
        if (keccak256(abi.encodePacked('BUSD')) == keccak256(abi.encodePacked(_token))) {
            busdFee = _newFee;
        }else if (keccak256(abi.encodePacked('BNB')) == keccak256(abi.encodePacked(_token))) {
            bnbFee = _newFee;
        }else if (keccak256(abi.encodePacked('BAT')) == keccak256(abi.encodePacked(_token))) {
            batFee = _newFee;
        }else if (keccak256(abi.encodePacked('DARA')) == keccak256(abi.encodePacked(_token))) {
            daraFee = _newFee;
        }
    }
    
    function setTreasury(address _newTreasury) external onlyOwner{
        treasury = _newTreasury;
    }

    function storeToVault(string memory _token, string memory _blob) external returns (bool){
        require(!blacklisted[msg.sender], "blacklisted");
        bool success = false;
        if (keccak256(abi.encodePacked('BUSD')) == keccak256(abi.encodePacked(_token))) {
            IERC20(busdTokenAddress).transferFrom(address(msg.sender), address(treasury), busdFee);
            success = true;
        }else if (keccak256(abi.encodePacked('BNB')) == keccak256(abi.encodePacked(_token))) {
            IERC20(bnbTokenAddress).transferFrom(address(msg.sender), address(treasury), bnbFee);
            success = true;
        }else if (keccak256(abi.encodePacked('BAT')) == keccak256(abi.encodePacked(_token))) {
            IERC20(batTokenAddress).transferFrom(address(msg.sender), address(treasury), batFee);
            success = true;
        }else if (keccak256(abi.encodePacked('DARA')) == keccak256(abi.encodePacked(_token))) {
            IERC20(daraTokenAddress).transferFrom(address(msg.sender), address(treasury), daraFee);
            success = true;
        }
        return success;
    }

}