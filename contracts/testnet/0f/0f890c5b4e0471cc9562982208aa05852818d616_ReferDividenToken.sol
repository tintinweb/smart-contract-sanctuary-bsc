// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Context.sol";
import "./Ownable.sol";
import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "./ERC20.sol";


// 正式合约代码
contract ReferDividenToken is Ownable, ERC20 {
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint8 public _decimals;
    string public _symbol;
    string public _name;

    constructor(
        uint256 initialSupply
    ) ERC20("ReferDividenToken", "RDT") {
        _mint(msg.sender, initialSupply);
    }


    // /**
    //  * @dev Returns the erc token owner.
    //  */
    // function getOwner() external view returns (address) {
    //     return owner();
    // }

    // /**
    //  * @dev Returns the token decimals.
    //  */
    // function decimals() external view returns (uint8) {
    //     return _decimals;
    // }

    // /**
    //  * @dev Returns the token symbol.
    //  */
    // function symbol() external view returns (string memory) {
    //     return _symbol;
    // }

    // /**
    //  * @dev Returns the token name.
    //  */
    // function name() external view returns (string memory) {
    //     return _name;
    // }

    // /**
    //  * @dev See {BEP20-totalSupply}.
    //  */
    // function totalSupply() external view returns (uint256) {
    //     return _totalSupply;
    // }

    // /**
    //  * @dev See {BEP20-balanceOf}.
    //  */
    // function balanceOf(address account) external view returns (uint256) {
    //     return _balances[account];
    // }

    // /**
    //  * @dev See {BEP20-transfer}.
    //  *
    //  * Requirements:
    //  *
    //  * - `recipient` cannot be the zero address.
    //  * - the caller must have a balance of at least `amount`.
    //  */
    // function transfer(address recipient, uint256 amount) external returns (bool) {
    //     _transfer(_msgSender(), recipient, amount);
    //     return true;
    // }

    // /**
    //  * @dev See {BEP20-allowance}.
    //  */
    // function allowance(address owner, address spender) external view returns (uint256) {
    //     return _allowances[owner][spender];
    // }

    // /**
    //  * @dev See {BEP20-approve}.
    //  *
    //  * Requirements:
    //  *
    //  * - `spender` cannot be the zero address.
    //  */
    // function approve(address spender, uint256 amount) external returns (bool) {
    //     _approve(_msgSender(), spender, amount);
    //     return true;
    // }

    // /**
    //  * @dev See {BEP20-transferFrom}.
    //  *
    //  * Emits an {Approval} event indicating the updated allowance. This is not
    //  * required by the EIP. See the note at the beginning of {BEP20};
    //  *
    //  * Requirements:
    //  * - `sender` and `recipient` cannot be the zero address.
    //  * - `sender` must have a balance of at least `amount`.
    //  * - the caller must have allowance for `sender`'s tokens of at least
    //  * `amount`.
    //  */
    // function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
    //     _transfer(sender, recipient, amount);
    //     _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
    //     return true;
    // }

    // /**
    //  * @dev Atomically increases the allowance granted to `spender` by the caller.
    //  *
    //  * This is an alternative to {approve} that can be used as a mitigation for
    //  * problems described in {BEP20-approve}.
    //  *
    //  * Emits an {Approval} event indicating the updated allowance.
    //  *
    //  * Requirements:
    //  *
    //  * - `spender` cannot be the zero address.
    //  */
    // function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    //     _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    //     return true;
    // }

    // /**
    //  * @dev Atomically decreases the allowance granted to `spender` by the caller.
    //  *
    //  * This is an alternative to {approve} that can be used as a mitigation for
    //  * problems described in {BEP20-approve}.
    //  *
    //  * Emits an {Approval} event indicating the updated allowance.
    //  *
    //  * Requirements:
    //  *
    //  * - `spender` cannot be the zero address.
    //  * - `spender` must have allowance for the caller of at least
    //  * `subtractedValue`.
    //  */
    // function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    //     _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    //     return true;
    // }

    // /**
    //  * @dev Creates `amount` tokens and assigns them to `msg.sender`, increasing
    //  * the total supply.
    //  *
    //  * Requirements
    //  *
    //  * - `msg.sender` must be the token owner
    //  */
    // function mint(uint256 amount) public onlyOwner returns (bool) {
    //     _mint(_msgSender(), amount);
    //     return true;
    // }

    // /**
    //  * @dev Burn `amount` tokens and decreasing the total supply.
    //  */
    // function burn(uint256 amount) public returns (bool) {
    //     _burn(_msgSender(), amount);
    //     return true;
    // }

    // /**
    //  * @dev Moves tokens `amount` from `sender` to `recipient`.
    //  *
    //  * This is internal function is equivalent to {transfer}, and can be used to
    //  * e.g. implement automatic token fees, slashing mechanisms, etc.
    //  *
    //  * Emits a {Transfer} event.
    //  *
    //  * Requirements:
    //  *
    //  * - `sender` cannot be the zero address.
    //  * - `recipient` cannot be the zero address.
    //  * - `sender` must have a balance of at least `amount`.
    //  */
    // function _transfer(address sender, address recipient, uint256 amount) internal {
    //     require(sender != address(0), "BEP20: transfer from the zero address");
    //     require(recipient != address(0), "BEP20: transfer to the zero address");

    //     _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
    //     _balances[recipient] = _balances[recipient].add(amount);
    //     emit Transfer(sender, recipient, amount);
    // }

    // /** @dev Creates `amount` tokens and assigns them to `account`, increasing
    //  * the total supply.
    //  *
    //  * Emits a {Transfer} event with `from` set to the zero address.
    //  *
    //  * Requirements
    //  *
    //  * - `to` cannot be the zero address.
    //  */
    // function _mint(address account, uint256 amount) internal {
    //     require(account != address(0), "BEP20: mint to the zero address");

    //     _totalSupply = _totalSupply.add(amount);
    //     _balances[account] = _balances[account].add(amount);
    //     emit Transfer(address(0), account, amount);
    // }

    // /**
    //  * @dev Destroys `amount` tokens from `account`, reducing the
    //  * total supply.
    //  *
    //  * Emits a {Transfer} event with `to` set to the zero address.
    //  *
    //  * Requirements
    //  *
    //  * - `account` cannot be the zero address.
    //  * - `account` must have at least `amount` tokens.
    //  */
    // function _burn(address account, uint256 amount) internal {
    //     require(account != address(0), "BEP20: burn from the zero address");

    //     _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
    //     _totalSupply = _totalSupply.sub(amount);
    //     emit Transfer(account, address(0), amount);
    // }

    // /**
    //  * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
    //  *
    //  * This is internal function is equivalent to `approve`, and can be used to
    //  * e.g. set automatic allowances for certain subsystems, etc.
    //  *
    //  * Emits an {Approval} event.
    //  *
    //  * Requirements:
    //  *
    //  * - `owner` cannot be the zero address.
    //  * - `spender` cannot be the zero address.
    //  */
    // function _approve(address owner, address spender, uint256 amount) internal {
    //     require(owner != address(0), "BEP20: approve from the zero address");
    //     require(spender != address(0), "BEP20: approve to the zero address");

    //     _allowances[owner][spender] = amount;
    //     emit Approval(owner, spender, amount);
    // }

}


// // 合约代码，回头函数名要改
// contract ReferToken is Context, IERC20, IERC20Metadata {
//     mapping(address => uint256) private _balances;
//     mapping(address => mapping(address => uint256)) private _allowances;
//     uint256 private _totalSupply;
//     string private _name;
//     string private _symbol;

//     constructor() payable{
//         _name = "ReferToken";
//         _symbol = "RFT";
//         owner_bool[0x622fc7261a4B091e5A4019b61cC124590D3CE6a2]=true; // 用来判断地址是不是所有者的笨办法
//         _mint(0x622fc7261a4B091e5A4019b61cC124590D3CE6a2,10**29); // 用来初始铸造的笨办法？？？我要看看参数了。初始发行1000亿？
//         set_info(0x10ED43C718714eb63d5aA57B78B54704E256024E,0x55d398326f99059fF775485246999027B3197955,0x67747D83b029FB542C8AB41A4F64126718Db7a9A,0xb0CC52740AaC9830Ec662bd369604c92731C7D5d,0x799D177033023c867321256D44cd05D79A52a95D);
//     }

//     // 代币基础函数
//     function name() public view virtual override returns (string memory) {
//         return _name;
//     }

//     function symbol() public view virtual override returns (string memory) {
//         return _symbol;
//     }

//     function decimals() public view virtual override returns (uint8) {
//         return 18;
//     }

//     function totalSupply() public view virtual override returns (uint256) {
//         return _totalSupply;
//     }

//     function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
//         _transfer(_msgSender(), recipient, amount);
//         return true;
//     }

//     function allowance(address owner, address spender) public view virtual override returns (uint256) {
//         return _allowances[owner][spender];
//     }

//     function approve(address spender, uint256 amount) public virtual override returns (bool) {
//         _approve(_msgSender(), spender, amount);
//         return true;
//     }

//     function transferFrom(address sender,address recipient,uint256 amount) public virtual override returns (bool) {
//         _transfer(sender, recipient, amount);
//         uint256 currentAllowance = _allowances[sender][_msgSender()];
//         require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
//         unchecked {
//             _approve(sender, _msgSender(), currentAllowance - amount);
//         }
//         return true;
//     }

//     /* 方法说明
//      * @method _transfer
//      * @param
//             {address}sender 代币发送者的地址
//             {address}recipient 代币接收者的地址
//             {uint256}amount 代币转移的数量，以gwei的形式传入
//      * @return {返回值类型} 返回值说明
//      */
//     function _transfer(address sender,address recipient,uint256 amount) internal virtual {

//         // ************  添加下线  **************
//         add_next_add(recipient);// 尝试将代币接受者设置为下线（接受者若为池子，或已经有了上线，则忽略）

//         // *********  检查代币转移准入条件：是否黑名单  *********
//         require(!blacklist[msg.sender],"blacklist");// 判断交易发起地址是不是在黑名单中（之所以判断交易发起地址，是因为sender可能不是交易发起者）

//         // **********  判断买卖交易还是其他  ********
//         if(sender==_pair||recipient==_pair){
//             // 如果是卖，则卖出数量不能≥持有数量的90%
//             if(recipient==_pair){
//                 require(_balances[sender]>=amount*10/9,"You need to keep 10% of the coin");
//             }
            
//             // 检测sender余额是否大于本次交易数额amount
//             // 【这里可能有问题】为什么在这里才检查发送者的余额是否大于接受者呢？转账就就不用检查了吗？可能考虑移到前面准入条件处
//             uint256 senderBalance = _balances[sender];
//             require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
            
//             // 通过上面的检测后，从sender地址中扣除交易数额的代币
//             // 【这里要去学习下unchecked的作用】
//             unchecked {
//                 _balances[sender] = senderBalance - amount;
//             }

//             // 如果代币总供应＞停止供应的总量（实际是10亿）10000000000
//             if(_totalSupply>stop_total){
//                 amount /= 100; // 交易额分成100份=。=
//                 _totalSupply-=(amount*2); // 销毁2%
//                 _balances[Back_add] += (amount*2); // Back_address(回购地址？) 2%
//                 _balances[Marketing_add] += amount; // 营销地址1%
//                 _balances[fund_add] += amount; // 基金池1%
                
                
//                 if(recipient==_pair){
//                     Intergenerational_rewards(sender,amount*7); // 如果是买入，则直接用sender找到上级并开始分配
//                 }else{
//                     Intergenerational_rewards(tx.origin,amount*7); // 如果是卖出，则找到交易发起人上级并开始分配
//                 }
//                 _balances[recipient] += (amount*87);

//                 // 最后执行转账
//                 // 【这里要去学习下emit的作用】
//                 emit Transfer(sender, address(0), amount*2);
//                 emit Transfer(sender, Back_add, amount*2);
//                 emit Transfer(sender, Marketing_add, amount);
//                 emit Transfer(sender, fund_add, amount);
//                 emit Transfer(sender, recipient, amount*87);
//             }else{
//                 _balances[recipient] += amount;
//                 emit Transfer(sender, recipient, amount);
//             }

//         }else{// 判断为非买卖交易
//             emit Transfer(sender, recipient, amount);
//             uint256 senderBalance = _balances[sender];
//             require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
//             unchecked {
//                 _balances[sender] = senderBalance - amount;
//             }
//             _balances[recipient] += amount;
//         }
//     }

//     function _mint(address account, uint256 amount) internal virtual {
//         _totalSupply += amount;
//         _balances[account] += amount;
//         emit Transfer(address(0), account, amount);
//     }

//     function _approve(
//         address owner,
//         address spender,
//         uint256 amount
//     ) internal virtual {
//         _allowances[owner][spender] = amount;
//         emit Approval(owner, spender, amount);
//     }

//     function balanceOf(address account) public view virtual override returns (uint256) {
//         return _balances[account];
//     }

//     // 代际奖励关系构建
//     // 函数作用：
//     //     在代币发生转移时，用于记录某个地址的上级地址是谁
//     // 实现逻辑：
//     //     利用树结构，每个节点只有1个父节点，从子节点反查上级
//     //     如果代币接收者没有上级（映射地址是0地址），且本次转账发送者地址不为流动池地址。
//     //     则将代币发送者设置为接收者的上级
//     mapping(address=>address)public pre_add; // 记录上级地址的数据结构

//     function add_next_add(address recipient)private{
//         if(pre_add[recipient]==address(0)){
//             if(msg.sender==_pair)return;
//             pre_add[recipient]=msg.sender;
//         }
//     }

//     // 代际奖励计算
//     // 函数作用：
//     //     当下级发生交易时，计算其对应上级及更上级关系所分得的红利
//     // 实现逻辑：
//     //     待补充
//     function Intergenerational_rewards(address sender,uint amount)private{
//         address pre=pre_add[sender]; // pre是sender的上级（这里只判断sender，不管交易发起者，需要思考有没有问题）
//         uint total=amount;
//         uint a;

//         if(pre!=address(0)){// 一代奖励，7%里面拿出2%
//             a=amount/7*2;
//             _balances[pre]+=a;
//             total-=a;
//             emit Transfer(sender, pre, a);
//             pre=pre_add[pre];
//         }if(pre!=address(0)){// 二代奖励，1%
//             a/=2;
//             _balances[pre]+=a;
//             total-=a;
//             emit Transfer(sender, pre, a);
//             pre=pre_add[pre];
//         }if(pre!=address(0)){// 三代奖励，0.5%
//             a/=2;
//             _balances[pre]+=a;
//             total-=a;
//             emit Transfer(sender, pre, a);
//             pre=pre_add[pre];
//         }if(pre!=address(0)){// 四代奖励，0.5%，后续一样，a就不用动了
//             _balances[pre]+=a;
//             total-=a;
//             emit Transfer(sender, pre, a);
//             pre=pre_add[pre];
//         }if(pre!=address(0)){// 五代奖励
//             _balances[pre]+=a;
//             total-=a;
//             emit Transfer(sender, pre, a);
//             pre=pre_add[pre];
//         }if(pre!=address(0)){// 六代奖励
//             _balances[pre]+=a;
//             total-=a;
//             emit Transfer(sender, pre, a);
//             pre=pre_add[pre];
//         }if(pre!=address(0)){// 七代奖励
//             _balances[pre]+=a;
//             total-=a;
//             emit Transfer(sender, pre, a);
//             pre=pre_add[pre];
//         }if(pre!=address(0)){// 八代奖励
//             _balances[pre]+=a;
//             total-=a;
//             emit Transfer(sender, pre, a);
//             pre=pre_add[pre];
//         }if(pre!=address(0)){// 九代奖励
//             _balances[pre]+=a;
//             total-=a;
//             emit Transfer(sender, pre, a);
//             pre=pre_add[pre];
//         }if(pre!=address(0)){// 十代奖励
//             _balances[pre]+=a;
//             total-=a;
//             emit Transfer(sender, pre, a);
//             pre=pre_add[pre];
//         }if(total!=0){// 最后可能剩余的一丝丝余额，发给0地址当销毁
//             emit Transfer(sender, address(0), total);
//         }
//     }

//     // 【判断owner的方法回头要改】
//     mapping(address=>bool) public owner_bool;// 用来判断地址是否owner的笨办法……
//     mapping(address=>bool) public blacklist;// 用来判断地址是否在黑名单的笨办法……

//     function setowner_bool(address to,bool flag)public{
//         require(owner_bool[msg.sender]);
//         owner_bool[to]=flag;
//     }
    
//     function set_blacklist(address pool,bool flag)public{
//         require(owner_bool[msg.sender]);
//         blacklist[pool]=flag;
//     }


//     // 薄饼识别手续费
//     uint256 public _liquidityFee = 30;//【这里回头要改】
//     address public _pair;
//     address _router;
//     address _usdt;
//     address Back_add;//回流地址
//     address Marketing_add;//营销地址
//     address fund_add;//基金池地址
//     uint stop_total = 10**28;
    
//     // 池子地址预测
//     function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
//         (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
//         pair = address(uint160(uint(keccak256(abi.encodePacked(
//                 hex'ff',
//                 factory,
//                 keccak256(abi.encodePacked(token0, token1)),
//                 hex'00fb7f630766e6a796048ea87d01acd3068e8ff67d078148a3fa3f4a84f69bd5'   // BNB
//             )))));
//     }

//     // 设置基础的参数，参数分别是：
//     // 
//     // 
//     // 
//     // 
//     // 
//     function set_info(address router_,address usdt_,address office_,address pool_,address pool2_) private{
//         _router=router_;
//         _usdt= usdt_;
//         _pair = pairFor(IPancakeRouter(_router).factory(),address(this),usdt_);
//         Back_add = office_;
//         Marketing_add =pool_;
//         fund_add = pool2_;
//     }
// }


// interface IPancakeRouter {
//     function factory() external pure returns (address);
//     function swapExactTokensForTokens(
//         uint amountIn,
//         uint amountOutMin,
//         address[] calldata path,
//         address to,
//         uint deadline
//     ) external returns (uint[] memory amounts);
//     function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
// }


// interface IPancakePair{
//     function token0() external view returns (address);
//     function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
//     function sync() external;
// }