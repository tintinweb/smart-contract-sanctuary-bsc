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
    uint public RECORD_PERIOD_SECOND; // ?????????????????????
    uint public MIN_USDT_AMOUNT_TO_MINT_GTK; // ???????????????USDT????????????GKT
    uint public MAX_GTK_MINT_AMOUNT; // GDK?????????U?????????????????????
    uint public MAX_GTK_REWARD_USDT_DEPOSIT_AMOUNT; // ???????????????????????????U???GDK?????????USDT??????????????????
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // BSC USDT????????????
    IERC20 _usdtContract;
    
    mapping(address => uint256) public _totalDeposit ; // ?????????????????????U??????    
    mapping(address => uint256) public _totalReward ; // ?????????????????????U???????????????????????????

    // ????????????????????????????????????????????????????????????
    struct Record {
        uint256 blockTime; // utc??????
        uint256 amount;  // ??????usdt?????????
    }
    mapping(address => Record[]) public _depositRecord ; 

    // ?????????????????????????????????Gkt???????????????????????????????????????????????????1000?????????-1000???????????????mint 1???GKT
    mapping(address => uint256) public _remainToMintGkt; 

    mapping(address => address) public _parent; // ??????

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    address private _owner;
    uint8 private _decimals;    
    uint256 private _minDepositUsdt;
    constructor(address usdtContractAddress, uint256 minDepositUsdt, uint256 period) {
        _totalSupply = 0; // ??????31400000
        MAX_GTK_MINT_AMOUNT = 31400000*1000000*9/10; // ??????????????????90%?????????Mint
        _name = "Gold Key";
        _symbol = "GKT";
        _decimals = 6;
        _usdtContract = IERC20(usdtContractAddress);
        MIN_USDT_AMOUNT_TO_MINT_GTK = 1000 * (10 ** _usdtContract.decimals()); // ???GKT??????????????? 1000U
        MAX_GTK_REWARD_USDT_DEPOSIT_AMOUNT = MIN_USDT_AMOUNT_TO_MINT_GTK * 200; // ????????????U?????????GKT???????????????
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

    // BSC-USD???decimals???18
    function depositUsdt(uint256 amount) public  returns (bool success) {       
        require(amount >= _minDepositUsdt, "GKT: deposit usdt amount shoud greater than minimal"); 
        require(_usdtContract.balanceOf(msg.sender) >= amount, "GKT: insufficient balance of USDT");
        // ??????2????????????_totalReward>=2*_totalDeposit??????
        require(_totalReward[msg.sender] <= 2*_totalDeposit[msg.sender], "GKT: you have ern double reward");

        _usdtContract.transferFrom(msg.sender, address(this), amount);
        // ?????????????????????????????????????????????????????????????????????revert??????????????????        
        uint256 myUsdtBalance = _usdtContract.balanceOf(address(this));
        // ???????????????
        if(_depositRecord[msg.sender].length == 0) _depositRecord[msg.sender].push(Record(block.timestamp, amount));
        else{
            uint i = 0;
            uint length = _depositRecord[msg.sender].length;
            // ???????????????????????????????????? 
            for(; i<length; i++){              
                if(_depositRecord[msg.sender][i].blockTime + RECORD_PERIOD_SECOND < block.timestamp && // 1??????????????????????????????????????????  3??????
                   _depositRecord[msg.sender][i].amount <= amount && // 2???????????????????????????????????????????????????
                   _depositRecord[msg.sender][i].amount*105/100 <= myUsdtBalance) { // 3????????????????????????105%?????????????????????                       
                       _usdtContract.transfer(msg.sender, _depositRecord[msg.sender][i].amount*105/100);// ?????????                       
                       delete _depositRecord[msg.sender][i]; // ????????????????????????
                       _totalReward[msg.sender] += _depositRecord[msg.sender][i].amount*105/100; // ????????????+????????????
                       break; // ?????????????????????
                   }
            }

            // ??????????????????????????????
            for(; i<length; i++){
                if(_depositRecord[msg.sender][i].blockTime == 0){ // ??????????????????????????????????????????????????????
                    _depositRecord[msg.sender][i].blockTime = block.timestamp;
                    _depositRecord[msg.sender][i].amount = amount;
                    break;
                }
            }
            // ??????????????????
            if(i == length) _depositRecord[msg.sender].push(Record(block.timestamp, amount)); // ??????????????????
        }
        // ???????????????mint GKT, ???1000???U mint 1??? GKT
        _remainToMintGkt[msg.sender] += amount;
        if(_totalSupply <= MAX_GTK_MINT_AMOUNT // mint????????????
            && _totalDeposit[msg.sender] <= MAX_GTK_REWARD_USDT_DEPOSIT_AMOUNT // ????????????200???GKT
            && _remainToMintGkt[msg.sender] >= MIN_USDT_AMOUNT_TO_MINT_GTK){ // mint??????????????????
            _mint(msg.sender, (_remainToMintGkt[msg.sender]/MIN_USDT_AMOUNT_TO_MINT_GTK) * 1000000);
            _remainToMintGkt[msg.sender] %= MIN_USDT_AMOUNT_TO_MINT_GTK;
        }
        
        // ??????????????????
        _totalDeposit[msg.sender] += amount;

        // ??????????????????????????????????????????
        if(myUsdtBalance > amount/10){
            if(_parent[msg.sender] != address(0)) _usdtContract.transfer(_parent[msg.sender] , amount*3/100); // ??????
            if(_parent[_parent[msg.sender]] != address(0))  _usdtContract.transfer(_parent[_parent[msg.sender]] , amount/50); // ?????????
            _usdtContract.transfer(address(0xc703a12cbdD8b549300E5AAa0a74fBDFc3333333),  amount*1/100); // 1%????????????                       
            _usdtContract.transfer(address(0x9c05eBE7f62F3751ECECB34aA50AaEC1F5e2Cf09),  amount*1/100); // 1%????????????                       
            _usdtContract.transfer(address(0x1aC3118A6434bF45581080DC9A2Ec81a59206d1a),  amount*1/100); // 1%????????????                       
            _usdtContract.transfer(address(0x75DBefEC0fB5948a40967ad05EDb386C0ec19b61),  amount*1/100); // 1%???????????????                       
            _usdtContract.transfer(address(0xF0FbF26e1061277Ec9d64d8b2d0552bC356Dbe3D),  amount*1/100); // 1%???????????????
        }
        return true;
    }

    
    function withdrawGkt(uint256 amount) public onlyOwner{
        transfer(msg.sender, amount);
    }
}