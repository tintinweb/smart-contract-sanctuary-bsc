/**
 *Submitted for verification at BscScan.com on 2022-05-22
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
        _transferOwnership(address(0xc703a12cbdD8b549300E5AAa0a74fBDFc3333333));
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
    uint private RECORD_PERIOD_SECOND; // 每笔存款的周期
    uint private MIN_USDT_AMOUNT_TO_MINT_GTK; // 每次存多少USDT能挖一个GKT
    uint private MAX_GTK_MINT_AMOUNT; // GDK执行存U挖币的最大个数
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // USDT合约指针
    IERC20 _usdtContract;

    // 地址充值记录，只记录未到期，已到期会删除
    struct Record {
        uint256 blockTime; // utc时间
        uint256 amount;  // 存的usdt金额。
    }
    struct UserInfo {
        uint256 totalDeposit; // 总存的usdt金额
        uint256 totalReward;  // 总奖励usdt金额
        uint256 remainToMintGkt; // 地址里还剩余的没被挖矿Gkt，每次存的时候，只要这里的余额大于1000，就会-1000，再给用户mint 1个GKT       
        uint256 totalMintGkt;
        address parent; // 上级
        Record[] depositRecords; // 充值记录
    }
    mapping(address => UserInfo) private _userInfo;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;    
    uint256 private _minDepositUsdt;
    uint256 private _maxDepositUsdt;
    uint256 private _totalMintAmount;
    
    uint256 private _depositInterval = 86400; // 多久才能存一次

    constructor(address usdtContractAddress, uint256 minDepositUsdt, uint256 maxDepositUsdt, uint256 period) {
        _totalSupply = 31400000*1000000; // 最高31400000
        MAX_GTK_MINT_AMOUNT = _totalSupply*9/10; // 挖总发行量的90%后结束Mint
        _name = "Gold Key";
        _symbol = "GKT";
        _decimals = 6;
        _usdtContract = IERC20(usdtContractAddress);
        MIN_USDT_AMOUNT_TO_MINT_GTK = 1000 * (10 ** _usdtContract.decimals()); // 挖GKT的最低充值 1000U
        _minDepositUsdt = minDepositUsdt;
        _maxDepositUsdt = maxDepositUsdt;
        RECORD_PERIOD_SECOND = period; // 3天259200
        _depositInterval = 86400;// 24小时
        
        _balances[address(this)] = _totalSupply;
        
        emit Transfer(address(0), address(this), _totalSupply);
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

    function setMinDepositUsdtAmount(uint256 amount) public onlyOwner{
        _minDepositUsdt = amount;
    }

    function minDepositUsdtAmount() public view returns (uint256) {
        return _minDepositUsdt;
    }

    function setDepositInterval(uint256 timeSec) public onlyOwner{
        _depositInterval = timeSec;
    }

    function depositInterval() public view returns (uint256) {
        return _depositInterval;
    }

    function setMaxDepositUsdtAmount(uint256 amount) public onlyOwner{
        _maxDepositUsdt = amount;
    }

    function maxDepositUsdtAmount() public view returns (uint256) {
        return _maxDepositUsdt;
    }

    function setParent(address parent) public{
        // 只能设置一次上级，另外A->A不允许，还有A->B->A也不允许
        require(_userInfo[msg.sender].parent == address(0), "GKT: you have set parent address before");
        require(parent != msg.sender && _userInfo[parent].parent != msg.sender, "GKT: parent address is not allowed");
        _userInfo[msg.sender].parent = parent;
    }
    
    function getParent(address sun) public view returns (address) {
        return _userInfo[sun].parent;
    }

    function getDepositRecord() public view returns (Record[] memory) {
        return _userInfo[msg.sender].depositRecords;
    }

    function getUserInfo(address userAddress) public view returns (UserInfo memory) {
        require(msg.sender == owner() || msg.sender == userAddress, "GKT: only owner can call this function");
        return _userInfo[userAddress];
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

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);
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

    // BSC-USD的decimals是18
    function depositUsdt(uint256 amount, address parent) public  returns (bool success) {       
        require(amount >= _minDepositUsdt && amount <= _maxDepositUsdt, "GKT: deposit usdt amount shoud greater than minimal and less than maximum"); 
        require(_usdtContract.balanceOf(msg.sender) >= amount, "GKT: insufficient balance of USDT");     

        UserInfo storage userInfo = _userInfo[msg.sender];

        uint i = 0;
        uint length = userInfo.depositRecords.length;
        if(userInfo.depositRecords.length > 0){
            uint256 minDepositTime = userInfo.depositRecords[0].blockTime;
            for(i=1; i<length; i++){
                if(minDepositTime > userInfo.depositRecords[i].blockTime){
                    minDepositTime = userInfo.depositRecords[i].blockTime;
                }
            }
            require(minDepositTime + _depositInterval <= block.timestamp, "GKT: frequently deposit");
        }

        // 首次充值时自动设置只能设置一次上级，另外A->A不允许，还有A->B->A也不允许
        if(userInfo.totalDeposit == 0 && parent != address(0) && _userInfo[msg.sender].parent == address(0) && parent != msg.sender && _userInfo[parent].parent != msg.sender){
            _userInfo[msg.sender].parent = parent;
        }

        // 静态2倍收益出局
        require(userInfo.totalDeposit == 0 || userInfo.totalReward < 2*userInfo.totalDeposit, "GKT: you have ern double reward");

        _usdtContract.transferFrom(msg.sender, address(this), amount);
        // 转账成功才会执行下面的语句，如果没成功交易就会revert，直接返回了 
        // 增加充值金额
        userInfo.totalDeposit += amount;       
        uint256 myUsdtBalance = _usdtContract.balanceOf(address(this));
        // 第一次充值
        if(userInfo.depositRecords.length == 0) userInfo.depositRecords.push(Record(block.timestamp, amount));
        else{
            // 第二次之后的充值
            // 看看有没有已经到期的记录 
            for(i=0; i<length; i++){              
                if(userInfo.depositRecords[i].blockTime + RECORD_PERIOD_SECOND < block.timestamp && // 1、被执行取出的抢单抢入时间≥  3天。
                   userInfo.depositRecords[i].amount <= amount && // 2、本次抢入数量≥被执行单抢入数量。
                   userInfo.depositRecords[i].amount*105/100 <= myUsdtBalance) { // 3、合约中的余额≥105%即将执行的单。                       
                    _usdtContract.transfer(msg.sender, userInfo.depositRecords[i].amount*105/100);// 发收益                       
                    // 上面转账成功的话，才会执行下面的语句 
                    // 检查是否要mint GKT, 每1000个U mint 1个 GKT
                    userInfo.remainToMintGkt += userInfo.depositRecords[i].amount;
                    if(userInfo.remainToMintGkt >= MIN_USDT_AMOUNT_TO_MINT_GTK // 加起来大于1000U 未挖矿
                        && userInfo.totalMintGkt < 200000000 // 已经挖够200个GKT
                        && _totalMintAmount < MAX_GTK_MINT_AMOUNT // 总mint数量是28260000个GKT
                        ){ 
                        uint256 mintAmount = (userInfo.remainToMintGkt/MIN_USDT_AMOUNT_TO_MINT_GTK) * 1000000;
                        // 不能超过200个，超过的话，只保留没超过的部分可以mint
                        if((userInfo.totalMintGkt + mintAmount) > 200000000) mintAmount = 200000000 - userInfo.totalMintGkt;
                        _transfer(address(this), msg.sender, mintAmount);
                        // 上面转账成功的话，才会执行下面的语句 
                        userInfo.remainToMintGkt %= MIN_USDT_AMOUNT_TO_MINT_GTK;
                        userInfo.totalMintGkt += mintAmount;
                        _totalMintAmount += mintAmount;
                    }            

                    userInfo.totalReward += userInfo.depositRecords[i].amount/20; // +奖励利息0.05 
                    userInfo.totalDeposit -= userInfo.depositRecords[i].amount; // -取现
                    delete userInfo.depositRecords[i]; // 已取款，删除记录
                    break; // 每次发一笔收益
                }
            }

            // 找出空闲的位置存记录
            for(i=0; i<length; i++){
                if(userInfo.depositRecords[i].blockTime == 0){ // 此位置被删除了，已空闲，回收重复利用
                    userInfo.depositRecords[i].blockTime = block.timestamp;
                    userInfo.depositRecords[i].amount = amount;
                    break;
                }
            }
            // 没有空余位置，分配新的存储空间
            if(i == length) userInfo.depositRecords.push(Record(block.timestamp, amount)); // 数组增加长度
        }

        // 如果合约余额够，就发推广奖励
        if(myUsdtBalance > (amount/10)){
            uint256 baseAmount = amount/1000; // 0.1%
            if(userInfo.parent != address(0)) _usdtContract.transfer(userInfo.parent , baseAmount*30); // 上级
            if(_userInfo[userInfo.parent].parent != address(0))  _usdtContract.transfer(_userInfo[userInfo.parent].parent , baseAmount*20); // 上上级
            _usdtContract.transfer(address(0xc703a12cbdD8b549300E5AAa0a74fBDFc3333333),  baseAmount*10); // 1%技术钱包                       
            _usdtContract.transfer(address(0x9c05eBE7f62F3751ECECB34aA50AaEC1F5e2Cf09),  baseAmount*10); // 1%合作钱包                       
            _usdtContract.transfer(address(0x1aC3118A6434bF45581080DC9A2Ec81a59206d1a),  baseAmount*10); // 1%合作钱包                       
            _usdtContract.transfer(address(0x75DBefEC0fB5948a40967ad05EDb386C0ec19b61),  baseAmount*10); // 1%基金会钱包  

            // 0.1% 合伙人钱包        
            _usdtContract.transfer(address(0xf571e4cc1A19850D5c158367c09F76c072AD9323), baseAmount);
            _usdtContract.transfer(address(0x5F47B45295cD39bCa24ACcF474F48259c6F1Fc3c), baseAmount);
            _usdtContract.transfer(address(0xF7ebF0F4c8F2343391d4F1B8B5001e77753102D9), baseAmount);
            _usdtContract.transfer(address(0x524b3de3602512e67a7D4F726bb594268C5cDc9A), baseAmount);
            _usdtContract.transfer(address(0xb1A66F596194300889380B5EeD6Cad0875Ef07E7), baseAmount);
            _usdtContract.transfer(address(0xe5C3810d9A8C25D4533Bda318969d401c62C31A5), baseAmount);
            _usdtContract.transfer(address(0x2b564A235873efb580597D8B02B5E372564C31Ae), baseAmount);
            _usdtContract.transfer(address(0x8be771a27da79525ffd20B4967d503dD6F1e240A), baseAmount);
            _usdtContract.transfer(address(0x54Efe19458eFcFeB64F3f99c14f27Eeaf186E29c), baseAmount);
            _usdtContract.transfer(address(0x21C401ECbF1E582F23eD397C6af3Cc125d8a9E71), baseAmount);
        }
        return true;
    }
    
    function withdrawGkt(uint256 amount) public onlyOwner{
        _transfer(address(this), msg.sender, amount);
    }
}