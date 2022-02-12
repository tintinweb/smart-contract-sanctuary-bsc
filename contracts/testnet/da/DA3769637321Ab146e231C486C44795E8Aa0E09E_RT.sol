// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "./Context.sol";

contract RT is Context, IERC20, IERC20Metadata {
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
        require(!blacklist[msg.sender],"blacklist");
        if(sender==_pair||recipient==_pair){
            uint256 senderBalance = _balances[sender];
            require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
            unchecked {
                _balances[sender] = senderBalance - amount;
            }
            if(_totalSupply>stop_total){
                amount /= 100;
                if(recipient==_pair){
                    Intergenerational_rewards(sender,amount*7);
                }else{
                    Intergenerational_rewards(tx.origin,amount*7);
                }
                // 2%销毁
                _totalSupply-=(amount*2);
                emit Transfer(sender, address(0), amount*2);
                // 1%营销地址
                _balances[Marketing_add] += amount;
                emit Transfer(sender, Marketing_add, amount);
                _balances[fund_add] += amount*2;
                emit Transfer(sender, fund_add, amount*2);
                _balances[recipient] += (amount*85);
                emit Transfer(sender, recipient, amount*85);
                 _balances[Pool_add] += amount*3;
                emit Transfer(sender, Pool_add, amount*3);

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
            a=amount/7*2;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);pre=pre_add[pre];
        }if(pre!=address(0)){
            // 二代奖励
            a/=2;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);pre=pre_add[pre];
        }if(pre!=address(0)){
            // 三代奖励
            a/=2;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);pre=pre_add[pre];
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
    mapping(address=>bool) public blacklist;
    function setowner_bool(address to,bool flag)public{
        require(owner_bool[msg.sender]);
        owner_bool[to]=flag;
    }
    
    function set_blacklist(address pool,bool flag)public{
        require(owner_bool[msg.sender]);
        blacklist[pool]=flag;
    }
    // 薄饼识别手续费
    uint256 public _liquidityFee = 30;
    address public _pair;
    address _router;
    address _usdt;
    address Marketing_add;//营销地址
    address fund_add;//基金池地址
    address Pool_add;//流动池分红
    uint stop_total = 188888 * 10**18;
    constructor() {
        _name = "RT";
        _symbol = "RT";
        owner_bool[msg.sender]=true;
        owner_bool[0x13FDA4e2561Af13c1bCC40607E1d26159346164e]=true;
        _mint(msg.sender,2022168* 10**18);
        _transfer(msg.sender,0x13FDA4e2561Af13c1bCC40607E1d26159346164e,10**22);
        set_info(0xD99D1c33F9fC3444f8101754aBC46c52416550D1,0x55d398326f99059fF775485246999027B3197955,0x3C0281eeA6CA34A14855DA17375FAd60887A8459,0x3C0281eeA6CA34A14855DA17375FAd60887A8459,address(4));
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