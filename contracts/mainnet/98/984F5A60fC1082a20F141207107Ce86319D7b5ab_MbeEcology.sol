/**
 *Submitted for verification at BscScan.com on 2022-12-01
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-26
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
}
/*
pragma solidity >=0.6.8;


library Utils {
    function swapTokensForEth(
        address routerAddress,
        uint256 tokenAmount
    ) public {
        IRouter pancakeRouter = IRouter(routerAddress);

        // generate the pancake pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeRouter.WETH();

        // make the swap
        pancakeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of BNB
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(
        address routerAddress,
        address owner,
        uint256 tokenAmount,
        uint256 ethAmount
    ) public {
        IRouter pancakeRouter = IRouter(routerAddress);

        // add the liquidity
        pancakeRouter.addLiquidityETH{value : ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner,
            block.timestamp + 360
        );
    }
}
*/
contract MbeEcology {
    // ERC20
    string private _name;
    string private _symbol;
    uint256 private _decimals;
    uint256 private _totalSupply;
    mapping (address => uint256) private balances;
    mapping (address => mapping (address => uint256)) private allowances;
    mapping (address => uint256) public start;//记录前5000个购买人
    mapping (address => bool) public last;//映射
    address public owner;
    uint256 public start10000;//前5000个博饼购买ID
    address public pir;
    address public MBE=0x086DDd008e20dd74C4FB216170349853f8CA8289;
    address public WBNB=0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    // Events
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    // ================= Initial value ===============

    constructor () public {
        owner=msg.sender;
        _name = "MbeEcology";
        _symbol = "M1";
        _decimals = 18;
        _totalSupply = 1000000000000000000000000;// 10_00000000.mul(10 ** uint256(18));
        balances[msg.sender] = _totalSupply;
        emit Transfer(address(this), msg.sender, _totalSupply);
        IRouter _pancakeRouter = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        // Create a pancake pair for this new token
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
    function setList(address addr)public{
     require(msg.sender == owner);
       last[addr]=true;
    }
    function sellMbe(uint mbe)public  view returns (uint){
        if(ERC20(address(WBNB)).balanceOf(pir) > 0){
            address[] memory path = new address[](2);
            uint[] memory amount;
            path[0]=address(this);
            path[1]=WBNB;
            amount=IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E).getAmountsOut(mbe,path); 
            return amount[1];
        }else {
            return 0; 
        }
    }
    // ================= Pair transfer ===============

    function _transfer(address _sender, address _recipient, uint256 _amount) internal {
        require(_amount <= balances[_sender],"Transfer: insufficient balance of from address");
        //这里限制了，LP底池小于500BNB必须持有大于等于200MBE才能买卖M-1
        require((ERC20(address(MBE)).balanceOf(_sender) >= 200 ether && _recipient == pir) || (_sender==pir && ERC20(address(MBE)).balanceOf(_recipient) >= 200 ether) || ERC20(address(WBNB)).balanceOf(pir) >= 500 ether || _sender==address(this) || last[_sender] || last[_recipient],"Transfer: insufficient balance of from address");
        //require(ERC20(address(MBE)).balanceOf(_sender) >= 200 ether || ERC20(address(MBE)).balanceOf(_recipient) >= 200 ether || ERC20(address(WBNB)).balanceOf(pir) >= 500 ether || _recipient == pir || _sender==address(this),"Transfer: insufficient balance of from address");
        require(_amount < 108 ether || _sender==owner || _recipient == owner || ERC20(address(WBNB)).balanceOf(pir) >= 500 ether || _sender == address(this) || last[_sender] || last[_recipient]);
        require((start[_recipient]==0 && _sender == pir) || start10000 >=10000 || _sender != pir || _sender == address(this) || last[_sender] || last[_recipient]);//前10000个购买人限购一次,如果卖出，这个地址就不能购买，需要满10000个地址后才能购买
        if(_sender != address(this) && _sender != pir){
            toPdex(50 ether);//回流LP底池
        }
        if(_sender == pir && start[_recipient]==0){
            start10000++;//LP底池购买人计数
            start[_recipient]=1;//记录已经购买
        }
        if(_sender==owner || _recipient == owner || _sender == address(this) || last[_sender] || last[_recipient]){
            balances[_sender] -= _amount;
            balances[_recipient] += _amount;
            emit Transfer(_sender, _recipient, _amount);  
        }else {
            balances[_sender] -= _amount;
            balances[_recipient] += _amount*97/100;
            balances[address(this)] += _amount*3/100;
            emit Transfer(_sender, _recipient, _amount*97/100);
            emit Transfer(_sender, address(this), _amount*3/100);
        }
        
    }
    function toPdex(uint mm)private {
        if(balances[address(this)] >= 100 ether) {
            //回流LP池子
            uint256 pooledM1 = mm;
            // now is to lock into staking pool
            swapTokensForEth(address(0x10ED43C718714eb63d5aA57B78B54704E256024E), pooledM1);
            uint256 deltaBalance = address(this).balance;
            // add liquidity to pancake
            addLiquidity(address(0x10ED43C718714eb63d5aA57B78B54704E256024E), address(0x24a9F21390B7Cdd9FC6A2D153Fe01f2Ea7851DC8), pooledM1, deltaBalance);
        }
    }
   function swapTokensForEth(
        address routerAddress,
        uint256 tokenAmount
    ) private  {
        IRouter pancakeRouter = IRouter(routerAddress);

        // generate the pancake pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeRouter.WETH();

        // make the swap
        pancakeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of BNB
            path,
            address(this),
            block.timestamp
        );
    }
    function addLiquidity(
        address routerAddress,
        address owner,
        uint256 tokenAmount,
        uint256 ethAmount
    ) private {
        IRouter pancakeRouter = IRouter(routerAddress);

        // add the liquidity
        pancakeRouter.addLiquidityETH{value : ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner,
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