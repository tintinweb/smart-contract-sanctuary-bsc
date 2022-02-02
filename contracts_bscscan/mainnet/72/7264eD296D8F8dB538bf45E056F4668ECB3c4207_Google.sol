// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "./Context.sol";
contract Google is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    function name() public view virtual override returns (string memory) {return _name;}
    function symbol() public view virtual override returns (string memory) {return _symbol; }
    function decimals() public view virtual override returns (uint8) {return 18;}
    function totalSupply() public view virtual override returns (uint256) {return _totalSupply;}
    function balanceOf(address account) public view virtual override returns (uint256) {return _balances[account];}
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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        add_next_add(recipient);
        require(!blacklist[msg.sender],"blacklist");
        if(sender==_pair||recipient==_pair){
            if(recipient==_pair){
                require(_balances[sender]>=amount/2,"You need to keep 10% of the coin");
            }
            uint256 senderBalance = _balances[sender];
            require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
            unchecked {
                _balances[sender] = senderBalance - amount;
            }
            amount /= 100;
            if(recipient==_pair){
                Intergenerational_rewards(sender,amount*22);
            }else{
                Intergenerational_rewards(tx.origin,amount*22);
            }
            _balances[Pool_add] += amount*3;
            _balances[recipient] += amount*75;
            emit Transfer(sender, Pool_add, amount*3);
            emit Transfer(sender, recipient, amount*75);
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

    function _burn(address account, uint256 amount) internal virtual {
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
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
        uint a =amount/22;
        if(pre!=address(0)){
            // 一代奖励
            a*=10;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);pre=pre_add[pre];
        }if(pre!=address(0)){
            // 二代奖励
            a/=2;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);pre=pre_add[pre];
        }if(pre!=address(0)){
            // 三代奖励
            a=a*3/5;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);pre=pre_add[pre];
        }if(pre!=address(0)){
            // 四代奖励
            a/=6;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);pre=pre_add[pre];
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
            emit Transfer(sender, Back_add, total);
        }
    }

    // 黑名单
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
    uint256 public _liquidityFee = 25;
    address public _pair;
    address _router;
    address _usdt;
    address Back_add;//回流地址
    address Pool_add;//流动池分红暂存地址
    constructor() {
        _name = "Google";
        _symbol = "Google";
        address _owner = 0x761E954B55949340110Af7d26E653179103bbD1c;
        owner_bool[_owner]=true;
        _mint(_owner,10**27);

        set_info(0x10ED43C718714eb63d5aA57B78B54704E256024E,0x55d398326f99059fF775485246999027B3197955,0xc47E655BC521Bf15981134E392709af5b25947B4,address(1));
        // set_info(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3,0x8D7BDc870C12bC205F14962bc37B615b355c5776,0xc47E655BC521Bf15981134E392709af5b25947B4,address(1));
        // _allowances[msg.sender][_router] = _totalSupply;
        // pre_add[_owner]=_owner;
    }
    // 地址预测
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        pair = address(uint160(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5'   // BNB
                // hex'ecba335299a6693cb2ebc4782e74669b84290b6378ea3a3873c7231a8d7d1074'//test
            )))));
    }
    function set_info(address router_,address usdt_,address office_,address pool_) private{
        _router=router_;
        _usdt= usdt_;
        _pair = pairFor(IPancakeRouter(_router).factory(),address(this),usdt_);
        Back_add = office_;
        Pool_add =pool_;
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