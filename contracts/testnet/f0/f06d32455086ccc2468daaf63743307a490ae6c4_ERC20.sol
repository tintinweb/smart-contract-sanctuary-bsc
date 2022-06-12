/**
 *Submitted for verification at BscScan.com on 2022-06-11
*/

pragma solidity ^0.4.20;
//导入文件,在主网部署的时候还是需要把导入的整个接口都拷贝到代码里面
//import './erc20interface.sol';
//继承erc20interface
contract ERC20Interface {
    string public name;
    string public symbol;
    uint8 public decimals;//几位小数点，最小可转账0.1个代币即为1
uint public totalSupply;

    function balanceOf(address tokenOwner) public view returns (uint balance);

    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    //委托别人操作自己的账户，委托成功后别人就可以调用transfer函数操作本人代币
    function approve(address spender, uint tokens) public returns (bool success);

    function transfer(address to, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);


    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}
contract ERC20 is ERC20Interface {


    string public  name;
    string public constant symbol = "SYM";
    uint8 public constant decimals = 18;  // 18 is the most common number of decimal places
    // 0.0000000000000000001  个代币
    
     uint public totalSupply;
     
    // 对自动生成对应的balanceOf方法
    mapping(address => uint256) internal _balances;

    // allowed保存每个地址（第一个address） 授权给其他地址(第二个address)的额度（uint256）
    mapping(address => mapping(address => uint256)) allowed;
//name等参数需要在定义合约的时候就确定
    constructor(string memory _name) public {
       name = _name;  // "UpChain";也可以直接name="UpChain";
       totalSupply = 1000000;
       _balances[msg.sender] = totalSupply;
    }

    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return _balances[tokenOwner];
    }

  // 转账函数
  function transfer(address _to, uint256 _value)  public returns (bool success) {
      require(_to != address(0));//目标账号不能为空账号
      require(_balances[msg.sender] >= _value);//发送者账号余额足够付款
      require(_balances[ _to] + _value >= _balances[ _to]);   // 防止溢出


      _balances[msg.sender] -= _value;
      _balances[_to] += _value;

      // 发送事件
      emit Transfer(msg.sender, _to, _value);

      return true;
  }


  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
      require(_to != address(0));
 //被允许的金额要大于转账金额，映射是_from授权给函数调用者的金额   
      require(allowed[_from][msg.sender] >= _value);
      require(_balances[_from] >= _value);
      require(_balances[ _to] + _value >= _balances[ _to]);
//钱还是在授权者的地址中
      _balances[_from] -= _value;
      _balances[_to] += _value;
//被允许调用的金额减少了
      allowed[_from][msg.sender] -= _value;

      emit Transfer(msg.sender, _to, _value);
      return true;
  }
//一个账号授权给其他账号可以转账的限额
  function approve(address _spender, uint256 _value) public returns (bool success) {
      allowed[msg.sender][_spender] = _value;

      emit Approval(msg.sender, _spender, _value);
      return true;
  }

  function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
      return allowed[_owner][_spender];
  }

}