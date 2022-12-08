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

contract DaraVault is Ownable {
    address public busdAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    uint256 public busdFee = 1*10**18;

    address public bnbAddress = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    uint256 public bnbFee = 1*10**18;

    address public batAddress = 0x101d82428437127bF1608F699CD651e6Abf9766E;
    uint256 public batFee = 5*10**18;

    address public daraAddress = 0xB9209b547fd051D9b9717dA386f2eD6113561468;
    uint256 public daraFee = 30*10**18;
    
    address public vaultTreasury = 0x917b59218AE506f782d092493BC2302711DCD972;

    mapping (address => bool) public blacklisted;

    constructor() {

    }
    
    function setBlacklisted(address account, bool state) external onlyOwner{
        require(blacklisted[account] != state, "Value already set");
        blacklisted[account] = state;
    }

    function setTreasuryAddress(address newAddress) external onlyOwner{
        vaultTreasury = newAddress;
    }

    function setTokenAddress(string memory token, address newTokenAddress) external onlyOwner{
        if (keccak256(abi.encodePacked('BUSD')) == keccak256(abi.encodePacked(token))) {
            busdAddress = newTokenAddress;
        }else if (keccak256(abi.encodePacked('BNB')) == keccak256(abi.encodePacked(token))) {
            bnbAddress = newTokenAddress;
        }else if (keccak256(abi.encodePacked('BAT')) == keccak256(abi.encodePacked(token))) {
            batAddress = newTokenAddress;
        }else if (keccak256(abi.encodePacked('DARA')) == keccak256(abi.encodePacked(token))) {
            daraAddress = newTokenAddress;
        }
    }

    function setTokenFee(uint256 newFee, string memory token) external onlyOwner{
        if (keccak256(abi.encodePacked('BUSD')) == keccak256(abi.encodePacked(token))) {
            busdFee = newFee;
        }else if (keccak256(abi.encodePacked('BNB')) == keccak256(abi.encodePacked(token))) {
            bnbFee = newFee;
        }else if (keccak256(abi.encodePacked('BAT')) == keccak256(abi.encodePacked(token))) {
            batFee = newFee;
        }else if (keccak256(abi.encodePacked('DARA')) == keccak256(abi.encodePacked(token))) {
            daraFee = newFee;
        }
    }
    
    function addTweetToVault(string memory currency, string memory tweetAuthor, string memory tweetContent, string memory tweetDate, string memory tweetID, string memory tweetRaw) external returns (bool){
        require(!blacklisted[msg.sender], "blacklisted");
        bool success = false;
        if (keccak256(abi.encodePacked('BUSD')) == keccak256(abi.encodePacked(currency))) {
            IERC20(busdAddress).transferFrom(address(msg.sender), address(vaultTreasury), busdFee);
            success = true;
        }else if (keccak256(abi.encodePacked('BNB')) == keccak256(abi.encodePacked(currency))) {
            IERC20(bnbAddress).transferFrom(address(msg.sender), address(vaultTreasury), bnbFee);
            success = true;
        }else if (keccak256(abi.encodePacked('BAT')) == keccak256(abi.encodePacked(currency))) {
            IERC20(batAddress).transferFrom(address(msg.sender), address(vaultTreasury), batFee);
            success = true;
        }else if (keccak256(abi.encodePacked('DARA')) == keccak256(abi.encodePacked(currency))) {
            IERC20(daraAddress).transferFrom(address(msg.sender), address(vaultTreasury), daraFee);
            success = true;
        }
        return success;
    }

}