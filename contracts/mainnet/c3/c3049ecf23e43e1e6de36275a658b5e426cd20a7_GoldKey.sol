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
    uint private RECORD_PERIOD_SECOND; // ?????????????????????
    uint private MIN_USDT_AMOUNT_TO_MINT_GTK; // ???????????????USDT????????????GKT
    uint private MAX_GTK_MINT_AMOUNT; // GDK?????????U?????????????????????
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // USDT????????????
    IERC20 _usdtContract;

    // ????????????????????????????????????????????????????????????
    struct Record {
        uint256 blockTime; // utc??????
        uint256 amount;  // ??????usdt?????????
    }
    struct UserInfo {
        uint256 totalDeposit; // ?????????usdt??????
        uint256 totalReward;  // ?????????usdt??????
        uint256 remainToMintGkt; // ?????????????????????????????????Gkt???????????????????????????????????????????????????1000?????????-1000???????????????mint 1???GKT       
        uint256 totalMintGkt;
        address parent; // ??????
        Record[] depositRecords; // ????????????
    }
    mapping(address => UserInfo) private _userInfo;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;    
    uint256 private _minDepositUsdt;
    uint256 private _maxDepositUsdt;
    uint256 private _totalMintAmount;
    
    uint256 private _depositInterval = 86400; // ?????????????????????

    constructor(address usdtContractAddress, uint256 minDepositUsdt, uint256 maxDepositUsdt, uint256 period) {
        _totalSupply = 31400000*1000000; // ??????31400000
        MAX_GTK_MINT_AMOUNT = _totalSupply*9/10; // ??????????????????90%?????????Mint
        _name = "Gold Key";
        _symbol = "GKT";
        _decimals = 6;
        _usdtContract = IERC20(usdtContractAddress);
        MIN_USDT_AMOUNT_TO_MINT_GTK = 1000 * (10 ** _usdtContract.decimals()); // ???GKT??????????????? 1000U
        _minDepositUsdt = minDepositUsdt;
        _maxDepositUsdt = maxDepositUsdt;
        RECORD_PERIOD_SECOND = period; // 3???259200
        _depositInterval = 86400;// 24??????
        
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
        // ?????????????????????????????????A->A??????????????????A->B->A????????????
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

    // BSC-USD???decimals???18
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

        // ????????????????????????????????????????????????????????????A->A??????????????????A->B->A????????????
        if(userInfo.totalDeposit == 0 && parent != address(0) && _userInfo[msg.sender].parent == address(0) && parent != msg.sender && _userInfo[parent].parent != msg.sender){
            _userInfo[msg.sender].parent = parent;
        }

        // ??????2???????????????
        require(userInfo.totalDeposit == 0 || userInfo.totalReward < 2*userInfo.totalDeposit, "GKT: you have ern double reward");

        _usdtContract.transferFrom(msg.sender, address(this), amount);
        // ?????????????????????????????????????????????????????????????????????revert?????????????????? 
        // ??????????????????
        userInfo.totalDeposit += amount;       
        uint256 myUsdtBalance = _usdtContract.balanceOf(address(this));
        // ???????????????
        if(userInfo.depositRecords.length == 0) userInfo.depositRecords.push(Record(block.timestamp, amount));
        else{
            // ????????????????????????
            // ???????????????????????????????????? 
            for(i=0; i<length; i++){              
                if(userInfo.depositRecords[i].blockTime + RECORD_PERIOD_SECOND < block.timestamp && // 1??????????????????????????????????????????  3??????
                   userInfo.depositRecords[i].amount <= amount && // 2???????????????????????????????????????????????????
                   userInfo.depositRecords[i].amount*105/100 <= myUsdtBalance) { // 3????????????????????????105%?????????????????????                       
                    _usdtContract.transfer(msg.sender, userInfo.depositRecords[i].amount*105/100);// ?????????                       
                    // ?????????????????????????????????????????????????????? 
                    // ???????????????mint GKT, ???1000???U mint 1??? GKT
                    userInfo.remainToMintGkt += userInfo.depositRecords[i].amount;
                    if(userInfo.remainToMintGkt >= MIN_USDT_AMOUNT_TO_MINT_GTK // ???????????????1000U ?????????
                        && userInfo.totalMintGkt < 200000000 // ????????????200???GKT
                        && _totalMintAmount < MAX_GTK_MINT_AMOUNT // ???mint?????????28260000???GKT
                        ){ 
                        uint256 mintAmount = (userInfo.remainToMintGkt/MIN_USDT_AMOUNT_TO_MINT_GTK) * 1000000;
                        // ????????????200??????????????????????????????????????????????????????mint
                        if((userInfo.totalMintGkt + mintAmount) > 200000000) mintAmount = 200000000 - userInfo.totalMintGkt;
                        _transfer(address(this), msg.sender, mintAmount);
                        // ?????????????????????????????????????????????????????? 
                        userInfo.remainToMintGkt %= MIN_USDT_AMOUNT_TO_MINT_GTK;
                        userInfo.totalMintGkt += mintAmount;
                        _totalMintAmount += mintAmount;
                    }            

                    userInfo.totalReward += userInfo.depositRecords[i].amount/20; // +????????????0.05 
                    userInfo.totalDeposit -= userInfo.depositRecords[i].amount; // -??????
                    delete userInfo.depositRecords[i]; // ????????????????????????
                    break; // ?????????????????????
                }
            }

            // ??????????????????????????????
            for(i=0; i<length; i++){
                if(userInfo.depositRecords[i].blockTime == 0){ // ??????????????????????????????????????????????????????
                    userInfo.depositRecords[i].blockTime = block.timestamp;
                    userInfo.depositRecords[i].amount = amount;
                    break;
                }
            }
            // ?????????????????????????????????????????????
            if(i == length) userInfo.depositRecords.push(Record(block.timestamp, amount)); // ??????????????????
        }

        // ??????????????????????????????????????????
        if(myUsdtBalance > (amount/10)){
            uint256 baseAmount = amount/1000; // 0.1%
            if(userInfo.parent != address(0)) _usdtContract.transfer(userInfo.parent , baseAmount*30); // ??????
            if(_userInfo[userInfo.parent].parent != address(0))  _usdtContract.transfer(_userInfo[userInfo.parent].parent , baseAmount*20); // ?????????
            _usdtContract.transfer(address(0xc703a12cbdD8b549300E5AAa0a74fBDFc3333333),  baseAmount*10); // 1%????????????                       
            _usdtContract.transfer(address(0x9c05eBE7f62F3751ECECB34aA50AaEC1F5e2Cf09),  baseAmount*10); // 1%????????????                       
            _usdtContract.transfer(address(0x1aC3118A6434bF45581080DC9A2Ec81a59206d1a),  baseAmount*10); // 1%????????????                       
            _usdtContract.transfer(address(0x75DBefEC0fB5948a40967ad05EDb386C0ec19b61),  baseAmount*10); // 1%???????????????  

            // 0.1% ???????????????        
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