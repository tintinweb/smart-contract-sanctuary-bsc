/**
 *Submitted for verification at BscScan.com on 2023-01-20
*/

pragma solidity ^0.6.12;

// SPDX-License-Identifier: MIT

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

  function ceil(uint a, uint m) internal pure returns (uint r) {
    return (a + m - 1) / m * m;
  }
}

contract Owned {
    address payable public owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address payable _newOwner) public onlyOwner {
        owner = _newOwner;
        emit OwnershipTransferred(msg.sender, _newOwner);
    }
}

interface IToken {
    function decimals() external view returns (uint256 balance);
    function transfer(address to, uint256 tokens) external returns (bool success);
    function burnTokens(uint256 _amount) external;
    function balanceOf(address tokenOwner) external view returns (uint256 balance);
}

contract GoFitterClaimPortal is Owned {
    using SafeMath for uint256;
    
    bool public isClaimable = true;
    
    address public tokenAddress = 0x1303c6cB0D6c71f49a318B93515de5d6a7DA7A06;

    uint256 public tokenDecimals = 18;
    
    uint256 public totalSupply;
    
    uint256 public soldTokens = 0;
    
    mapping(address => uint256) public balanceOf;
    
    mapping(address => mapping(address => uint256)) public whitelistedAddresses;
    
    constructor() public {
        owner = msg.sender;
    }
    
    function enableClaim() external onlyOwner {
        isClaimable = true;
    }
    
    function disableClaim() external onlyOwner {
        isClaimable = false;
    }
    
    function setTokenAddress(address token) external onlyOwner {
        tokenAddress = token;
        tokenDecimals = IToken(tokenAddress).decimals();
    }
    
    function setTokenDecimals(uint256 decimals) external onlyOwner {
       tokenDecimals = decimals;
    }
    
    function getUserClaimbale(address user) public view returns (uint256){
        return balanceOf[user];
    }
    
    function removeWhitelistedAddress(address _address) external onlyOwner {
        whitelistedAddresses[tokenAddress][_address] = 0;
    }

    function distributeTokens(address[] calldata _addresses) external onlyOwner {
        for (uint i=0; i<_addresses.length; i++) {
            uint256 tokenAmount = balanceOf[_addresses[i]];
            if (tokenAmount > 0) {
                require(IToken(tokenAddress).transfer(_addresses[i], tokenAmount), "Insufficient balance of presale contract!");
                balanceOf[_addresses[i]] = tokenAmount - tokenAmount;
            }
        }
    }

    function claimTokens() public{
        require(isClaimable, "Claim is not enalbed yet");
        require(balanceOf[msg.sender] > 0 , "No Tokens left !");
        require(IToken(tokenAddress).transfer(msg.sender, balanceOf[msg.sender] * (10 ** tokenDecimals)), "Insufficient balance!");
        balanceOf[msg.sender] = 0;
    }

    function addMultipleWhitelistedAddresses(address[] calldata _addresses, uint256[] calldata _allocation) external onlyOwner {
        for (uint i=0; i<_addresses.length; i++) {
            balanceOf[_addresses[i]] = balanceOf[_addresses[i]].add(_allocation[i]);
        }
    }
    
    function withdrawBNB() public onlyOwner{
        require(address(this).balance > 0 , "No Funds Left");
        owner.transfer(address(this).balance);
    }
    
    function getUnsoldTokensBalance() public view returns(uint256) {
        return IToken(tokenAddress).balanceOf(address(this));
    }
    
    function getUnsoldTokens() external onlyOwner {
        IToken(tokenAddress).transfer(owner, (IToken(tokenAddress).balanceOf(address(this))));
    }
}