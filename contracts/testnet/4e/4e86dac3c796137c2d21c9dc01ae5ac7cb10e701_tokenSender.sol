/**
 *Submitted for verification at BscScan.com on 2022-03-27
*/

pragma solidity ^0.5.7;

/**
 * ERC20 contract functions
*/
contract ERC20 {
    function transfer(address receiver, uint256 amount) public;
    function balanceOf(address _owner) public view returns (uint256 balance);
    function burnFrom(address from, uint256 value) public;
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
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
  
}

contract owned {
        address public owner;

        constructor() public {
            owner = msg.sender;
        }

        modifier onlyOwner {
            require(msg.sender == owner);
            _;
        }

        function transferOwnership(address newOwner) onlyOwner public {
            owner = newOwner;
        }
}

contract tokenSender is owned {
    using SafeMath for uint256;

    event Multisended(uint256 total, address tokenAddress);
    event ClaimedTokens(address token, address owner, uint256 balance);

    function multiTransferToken_a4A(
        address _token,
        address[] calldata _addresses,
        uint256[] calldata _amounts
    ) payable external {
        ERC20 token = ERC20(_token);
        for (uint8 i; i < _addresses.length; i++) {
            token.transfer(_addresses[i], _amounts[i]);
        }
    }

    function claimTokens(address _token) public onlyOwner {
        ERC20 erc20token = ERC20(_token);
        uint256 balance = erc20token.balanceOf(address(this));
        erc20token.transfer(owner, balance);
        emit ClaimedTokens(_token, owner, balance);
    }
}