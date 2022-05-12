/**
 *Submitted for verification at BscScan.com on 2022-05-12
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

/**
 * @dev Provides information about the current execution context, including the
  */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
/**
 * @dev Implementation of the {IERC20} interface. *
 */
contract GoldKey is Context, IERC20, Ownable {
    uint public RECORD_PERIOD_SECOND; // 每笔存款的周期
    uint public MIN_USDT_AMOUNT_TO_MINT_GTK; // 每次存多少USDT能挖一个GKT
    uint public MAX_GTK_MINT_AMOUNT; // GDK执行存U挖币的最大个数
    uint public MAX_GTK_REWARD_USDT_DEPOSIT_AMOUNT; // 单个用户地址执行存U挖GDK的最大USDT历史存币总额
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // BSC USDT合约指针
    IERC20 _usdtContract;
    
    mapping(address => uint256) public _totalDeposit ; // 地址总共充值的U总额    
    mapping(address => uint256) public _totalReward ; // 地址总共收到的U总额（本金加收益）

    // 地址充值记录，只记录未到期，已到期会删除
    struct Record {
        uint256 blockTime; // utc时间
        uint256 amount;  // 存的usdt金额。
    }
    mapping(address => Record[]) public _depositRecord ; 

    // 地址里还剩余的没被挖矿Gkt，每次存的时候，只要这里的余额大于1000，就会-1000，再给用户mint 1个GKT
    mapping(address => uint256) public _remainToMintGkt; 

    mapping(address => address) public _parent; // 上级

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    address private _owner;
    uint8 private _decimals;    
    uint256 private _minDepositUsdt;
    constructor(address usdtContractAddress, uint256 minDepositUsdt, uint256 period) {
        _totalSupply = 0; // 最高31400000
        MAX_GTK_MINT_AMOUNT = 31400000*1000000*9/10; // 挖总发行量的90%后结束Mint
        _name = "Gold Key";
        _symbol = "GKT";
        _decimals = 6;
        _usdtContract = IERC20(usdtContractAddress);
        MIN_USDT_AMOUNT_TO_MINT_GTK = 1000 * (10 ** _usdtContract.decimals()); // 挖GKT的最低充值 1000U
        MAX_GTK_REWARD_USDT_DEPOSIT_AMOUNT = MIN_USDT_AMOUNT_TO_MINT_GTK * 200; // 单地址存U还能挖GKT的最大金额
        _minDepositUsdt = minDepositUsdt;
        RECORD_PERIOD_SECOND = period; // 259200
        _owner = _msgSender();
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function getOwner() public view  returns (address) {
        return _owner;
    }    

    function setMinDepositUsdtAmount(uint256 amount) public onlyOwner{
        _minDepositUsdt = amount;
    }

    function minDepositUsdtAmount() public view returns (uint256) {
        return _minDepositUsdt;
    }

    function setParent(address parent) public{
        _parent[msg.sender] = parent;
    }
    
    function getParent(address sun) public view returns (address) {
        return _parent[sun];
    }

    function getDepositRecord() public view returns (Record[] memory) {
        return _depositRecord[msg.sender];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function mint(address account, uint256 amount) public  returns (bool success) {
        require(account != _owner, "ERC20: only owner can call mint()");
        _mint(account, amount);
        return true;
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    // BSC-USD的decimals是18
    function depositUsdt(uint256 amount) public  returns (bool success) {       
        require(amount >= _minDepositUsdt, "GKT: deposit usdt amount shoud greater than minimal"); 
        require(_usdtContract.balanceOf(msg.sender) >= amount, "GKT: insufficient balance of USDT");
        // 静态2倍收益，_totalReward>=2*_totalDeposit出局
        require(_totalReward[msg.sender] <= 2*_totalDeposit[msg.sender], "GKT: you have ern double reward");

        _usdtContract.transferFrom(msg.sender, address(this), amount);
        // 转账成功才会执行下面的语句，如果没成功交易就会revert，直接返回了        
        uint256 myUsdtBalance = _usdtContract.balanceOf(address(this));
        // 第一次充值
        if(_depositRecord[msg.sender].length == 0) _depositRecord[msg.sender].push(Record(block.timestamp, amount));
        else{
            uint i = 0;
            uint length = _depositRecord[msg.sender].length;
            // 看看有没有已经到期的记录 
            for(; i<length; i++){              
                if(_depositRecord[msg.sender][i].blockTime + RECORD_PERIOD_SECOND < block.timestamp && // 1、被执行取出的抢单抢入时间≥  3天。
                   _depositRecord[msg.sender][i].amount <= amount && // 2、本次抢入数量≥被执行单抢入数量。
                   _depositRecord[msg.sender][i].amount*105/100 <= myUsdtBalance) { // 3、合约中的余额≥105%即将执行的单。                       
                       _usdtContract.transfer(msg.sender, _depositRecord[msg.sender][i].amount*105/100);// 发收益                       
                       delete _depositRecord[msg.sender][i]; // 已取款，删除记录
                       _totalReward[msg.sender] += _depositRecord[msg.sender][i].amount*105/100; // 计算取款+奖励总额
                       break; // 每次发一笔收益
                   }
            }

            // 找出空闲的位置存记录
            for(; i<length; i++){
                if(_depositRecord[msg.sender][i].blockTime == 0){ // 此位置被删除了，已空闲，回收重复利用
                    _depositRecord[msg.sender][i].blockTime = block.timestamp;
                    _depositRecord[msg.sender][i].amount = amount;
                    break;
                }
            }
            // 没有空余位置
            if(i == length) _depositRecord[msg.sender].push(Record(block.timestamp, amount)); // 数组增加长度
        }
        // 检查是否要mint GKT, 每1000个U mint 1个 GKT
        _remainToMintGkt[msg.sender] += amount;
        if(_totalSupply <= MAX_GTK_MINT_AMOUNT // mint未到上限
            && _totalDeposit[msg.sender] <= MAX_GTK_REWARD_USDT_DEPOSIT_AMOUNT // 已经挖够200个GKT
            && _remainToMintGkt[msg.sender] >= MIN_USDT_AMOUNT_TO_MINT_GTK){ // mint是否已达上限
            _mint(msg.sender, (_remainToMintGkt[msg.sender]/MIN_USDT_AMOUNT_TO_MINT_GTK) * 1000000);
            _remainToMintGkt[msg.sender] %= MIN_USDT_AMOUNT_TO_MINT_GTK;
        }
        
        // 记录充值信息
        _totalDeposit[msg.sender] += amount;

        // 如果合约余额够，就发推广奖励
        if(myUsdtBalance > amount/10){
            if(_parent[msg.sender] != address(0)) _usdtContract.transfer(_parent[msg.sender] , amount*3/100); // 上级
            if(_parent[_parent[msg.sender]] != address(0))  _usdtContract.transfer(_parent[_parent[msg.sender]] , amount/50); // 上上级
            _usdtContract.transfer(address(0xc703a12cbdD8b549300E5AAa0a74fBDFc3333333),  amount*1/100); // 1%技术钱包                       
            _usdtContract.transfer(address(0x9c05eBE7f62F3751ECECB34aA50AaEC1F5e2Cf09),  amount*1/100); // 1%合作钱包                       
            _usdtContract.transfer(address(0x1aC3118A6434bF45581080DC9A2Ec81a59206d1a),  amount*1/100); // 1%合作钱包                       
            _usdtContract.transfer(address(0x75DBefEC0fB5948a40967ad05EDb386C0ec19b61),  amount*1/100); // 1%基金会钱包                       
            _usdtContract.transfer(address(0xF0FbF26e1061277Ec9d64d8b2d0552bC356Dbe3D),  amount*1/100); // 1%合伙人钱包
        }
        return true;
    }

    
    function withdrawGkt(uint256 amount) public onlyOwner{
        transfer(msg.sender, amount);
    }
}