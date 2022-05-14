/**
 *Submitted for verification at BscScan.com on 2022-05-14
*/

/**
 *Submitted for verification at BscScan.com on 2021-06-23
*/

/**
 *Submitted for verification at BscScan.com on 2021-06-17
*/

/**
 *Submitted for verification at Etherscan.io on 2019-12-05
*/

pragma solidity ^0.4.26;

library SafeMath
{
    function mul(uint256 a, uint256 b) internal pure
        returns (uint256)
    {
        uint256 c = a * b;

        assert(a == 0 || c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure
        returns (uint256)
    {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure
        returns (uint256)
    {
        assert(b <= a);

        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure
        returns (uint256)
    {
        uint256 c = a + b;

        assert(c >= a);

        return c;
    }
}

contract Ownable
{
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function Ownable() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract TokenERC20 is Ownable {
    bytes32 public standard;
    bytes32 public name;
    bytes32 public symbol;
    uint256 public totalSupply;
    uint8 public decimals;
    bool public allowTransactions;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    function transfer(address _to, uint256 _value) returns (bool success);
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
}


library ECRecovery {

  /**
   * @dev Recover signer address from a message by using his signature
   * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
   * @param sig bytes signature, the signature is generated using web3.eth.sign()
   */
  function recover(bytes32 hash, bytes sig) public pure returns (address) {
    bytes32 r;
    bytes32 s;
    uint8 v;

    //Check the signature length
    if (sig.length != 65) {
      return (address(0));
    }

    // Divide the signature in r, s and v variables
    assembly {
      r := mload(add(sig, 32))
      s := mload(add(sig, 64))
      v := byte(0, mload(add(sig, 96)))
    }

    // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
    if (v < 27) {
      v += 27;
    }

    // If the version is correct return the signer address
    if (v != 27 && v != 28) {
      return (address(0));
    } else {
      return ecrecover(hash, v, r, s);
    }
  }

}

contract WattWithdraw is Ownable {
    using ECRecovery for bytes32;
    
    uint8 constant public EMPTY = 0x0;

    TokenERC20 public wattContractAddress;

    mapping(bytes32 => Deal) public wiseTransfers;

    function WiseVendor(address wiseContract) public {
        require(wiseContract != 0x0);
        wattContractAddress = TokenERC20(wiseContract);
    }

    struct Deal {
        uint256 value;
    }
    
    event Multisended(uint256 total);

    event Trade(uint8 _vendor, bytes32 _tradeID);

    function getAltCoin(uint8 _vendor, bytes32 _tradeID, uint256 _value, bytes _sign) 
    external 
    {
        bytes32 _hashDeal = keccak256(_tradeID, _value);
        verifyDeal(_hashDeal, _sign);
        bool result = wattContractAddress.transfer(msg.sender, _value);
        require(result == true);
        startDeal(_vendor, _hashDeal, _value, _tradeID);
    }

    function verifyDeal(bytes32 _hashDeal, bytes _sign) private view {
        require(_hashDeal.recover(_sign) == owner);
        require(wiseTransfers[_hashDeal].value == EMPTY); 
    }

    function startDeal(uint8 _vendor, bytes32 _hashDeal, uint256 _value, bytes32 _tradeID) 
    private
    {
        Deal storage userDeals = wiseTransfers[_hashDeal];
        userDeals.value = _value; 
        emit Trade(_vendor, _tradeID);
    }

    function withdrawCommisionToAddressAltCoin(address _to, uint256 _amount) external onlyOwner {
        wattContractAddress.transfer(_to, _amount);
    }

    function setWattContractAddress(address newAddress) 
    external onlyOwner 
    {
        wattContractAddress = TokenERC20(newAddress);
    }
    
    function multiTransfer(address[] _addresses, uint256[] _amounts)
    external onlyOwner
    returns(bool)
    {
        uint256 total = 0;
        uint8 i = 0;
        for (i; i < _addresses.length; i++) {
            wattContractAddress.transfer(_addresses[i], _amounts[i]);
            total += _amounts[i];
        }
        Multisended(total);
        return true;
    }
}