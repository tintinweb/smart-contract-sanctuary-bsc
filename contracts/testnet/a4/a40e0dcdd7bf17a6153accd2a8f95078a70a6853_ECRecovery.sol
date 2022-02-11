/**
 *Submitted for verification at BscScan.com on 2022-02-07
*/

pragma solidity ^0.4.23;
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


contract Feeless {
    
    address internal msgSender;
    mapping(address => uint256) public nonces;
    
    modifier feeless {
        if (msgSender == address(0)) {
            msgSender = msg.sender;
            _;
            msgSender = address(0);
        } else {
            _;
        }
    }

    function performFeelessTransaction(address sender, address target, bytes data, uint256 nonce, bytes sig) public payable {
        require(this == target);
        
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 hash = keccak256(prefix, keccak256(target, data, nonce));
        msgSender = ECRecovery.recover(hash, sig);
        require(msgSender == sender);
        require(nonces[msgSender]++ == nonce);
        
        require(target.call.value(msg.value)(data));
        msgSender = address(0);
    }
    
}

// ----------------------------------------------------------------------------
// 'AYAM' token contract
//
// Deployed to : 0xf0717511aB2f82beD57ea756A092F092736cFAfc
// Symbol      : AYAM
// Name        : AYAM
// Total supply: 100000
// Decimals    : 8
// Deployed By PandaEver
//

// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
contract SafeMath {
    function add(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) public pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}
contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}
contract AYAM is ERC20Interface, Owned, SafeMath,Feeless {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    constructor() public {
        symbol = "AYAM";
        name = "AYAM";
        decimals = 8;
        _totalSupply = 10000000000000;
        balances[0xf0717511aB2f82beD57ea756A092F092736cFAfc] = _totalSupply;
        emit Transfer(address(0), 0xf0717511aB2f82beD57ea756A092F092736cFAfc, _totalSupply);
    }
    function totalSupply() public constant returns (uint) {
        return _totalSupply  - balances[address(0)];
    }
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }
    function transfer(address _to, uint256 _value)
        public
        feeless
        returns(bool)
    {
        balances[msg.sender] = balances[msg.sender] - (_value);
        balances[_to] = balances[_to] + (_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    function transferWithFee(address _to, uint256 _value, uint256 _fee)
    public
    feeless
    returns(bool)
{
    balances[msgSender] = balances[msgSender] - (_value);
    balances[_to] = balances[_to] + (_value);
    emit Transfer(msg.sender, _to, _value);
    balances[msg.sender] = balances[msg.sender] - (_fee);
    balances[msg.sender] = balances[msg.sender] + (_fee);
    emit Transfer(msgSender, msg.sender, _fee);
    return true;
}
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = sub(balances[from], tokens);
        allowed[from][msg.sender] = sub(allowed[from][msg.sender], tokens);
        balances[to] = add(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }
    function () public payable {
        revert();
    }
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}