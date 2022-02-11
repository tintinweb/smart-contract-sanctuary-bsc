// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "./Context.sol";

contract AirdropDao is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender,address recipient,uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }
    function _transfer(address sender,address recipient,uint256 amount) internal virtual {
        add_next_add(recipient);
        //require(!blacklist[msg.sender],"blacklist");
        if(sender==_pair||recipient==_pair){
            uint256 senderBalance = _balances[sender];
            require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
            unchecked {
                _balances[sender] = senderBalance - amount;
            }
            // 5%市场分红
            if(_totalSupply>stop_total){
                amount /= 100;
                if(recipient==_pair){
                    Intergenerational_rewards(sender,amount*5);
                }else{
                    Intergenerational_rewards(tx.origin,amount*5);
                }
                // 2%销毁到0地址
                _totalSupply-=(amount*2);
                emit Transfer(sender, address(0), amount*2);
                // 1%营销地址
                _balances[Marketing_add] += amount;
                emit Transfer(sender, Marketing_add, amount);
                // 2%基金会
                _balances[fund_add] += amount*2;
                emit Transfer(sender, fund_add, amount*2);
                // 88%交易
                _balances[recipient] += (amount*88);
                emit Transfer(sender, recipient, amount*88);
                // 2%回流到资金池
                 _balances[Pool_add] += amount*2;
                emit Transfer(sender, Pool_add, amount*2);

            }else{
                _balances[recipient] += amount;
                emit Transfer(sender, recipient, amount);
            }
        }else{
            if(_balances[Pool_add]!=0){
                _balances[_pair]+=_balances[Pool_add];
                emit Transfer(Pool_add, _pair, _balances[Pool_add]);
                _balances[Pool_add]=0;
                IPancakePair(_pair).sync();
            }
            emit Transfer(sender, recipient, amount);
            uint256 senderBalance = _balances[sender];
            require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
            unchecked {
                _balances[sender] = senderBalance - amount;
            }
            _balances[recipient] += amount;
        }
    }
    function _mint(address account, uint256 amount) internal virtual {
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    // 代际奖励
    mapping(address=>address)public pre_add;
    function add_next_add(address recipient)private{
        if(pre_add[recipient]==address(0)){
            if(msg.sender==_pair)return;
            pre_add[recipient]=msg.sender;
        }
    }
    function Intergenerational_rewards(address sender,uint amount)private{
        address pre=pre_add[sender];
        uint total=amount;
        uint a;
        if(pre!=address(0)){
            // 一代奖励
            a=amount/5*2;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);pre=pre_add[pre];
        }if(pre!=address(0)){
            // 二代奖励
            a/=2;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);pre=pre_add[pre];
        }if(pre!=address(0)){
            // 三代奖励
            a/=4;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);pre=pre_add[pre];
        }if(pre!=address(0)){
            // 四代奖励
            _balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);pre=pre_add[pre];
        }if(pre!=address(0)){
            // 五代奖励
            _balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);pre=pre_add[pre];
        }if(pre!=address(0)){
            // 六代奖励
            _balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);pre=pre_add[pre];
        }if(pre!=address(0)){
            // 七代奖励
            _balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);pre=pre_add[pre];
        }if(pre!=address(0)){
            // 八代奖励
            _balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);pre=pre_add[pre];
        }if(pre!=address(0)){
            // 九代奖励
            _balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);pre=pre_add[pre];
        }if(pre!=address(0)){
            // 十代奖励
            _balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);pre=pre_add[pre];
        }if(total!=0){
            emit Transfer(sender, address(0), total);
        }
    }

    mapping(address=>bool) public owner_bool;
   // mapping(address=>bool) public blacklist;
    function setowner_bool(address to,bool flag)public{
        require(owner_bool[msg.sender]);
        owner_bool[to]=flag;
    }
    /*
    function set_blacklist(address pool,bool flag)public{
        require(owner_bool[msg.sender]);
        blacklist[pool]=flag;
    }
    */
    // 薄饼识别手续费
    uint256 public _liquidityFee = 12;
    address public _pair;
    address _router;
    address _usdt;
    address Marketing_add;//营销地址
    address fund_add;//基金池地址
    address Pool_add;//流动池分红或者销毁地址
    uint stop_total = 188888 * 10**18;
    constructor() {
        _name = "Airdrop Dao";
        _symbol = "AD";
        owner_bool[msg.sender]=true;
        //空投地址
        owner_bool[0xf02e6298c75feCDf5639cF640fC72b16cD17d248]=true;
        _mint(msg.sender,2022168* 10**18);
        _transfer(msg.sender,0xf02e6298c75feCDf5639cF640fC72b16cD17d248,10**22);
        //BNB   0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
        set_info(0x10ED43C718714eb63d5aA57B78B54704E256024E,0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c,0xb02f6C5Fb867600CF0B1abf1a9d129fF1C241A5c,0x5725e1BECDb76E14534A7b237309Bb68BeBEDDB6,address(1));
    }
    // 地址预测
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        pair = address(uint160(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5'   // BNB
            )))));
    }
   
    function set_info(address router_,address usdt_,address pool_,address pool2_,address pool3_) private{
        _router=router_;
        _usdt= usdt_;
        _pair = pairFor(IPancakeRouter(_router).factory(),address(this),usdt_);
        Marketing_add =pool_;
        fund_add = pool2_;
        Pool_add = pool3_;
    }
}


interface IPancakeRouter {
    function factory() external pure returns (address);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
}
interface IPancakePair{
    function token0() external view returns (address);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function sync() external;
}