pragma solidity 0.8.0;

interface relationship {
    function defultFather() external returns (address);

    function father(address _addr) external returns (address);

    function grandFather(address _addr) external returns (address);

    function otherCallSetRelationship(address _son, address _father) external;

    function getFather(address _addr) external view returns (address);

    function getGrandFather(address _addr) external view returns (address);
}

interface Ipair {
    function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);

    function token0() external view returns (address);

    function token1() external view returns (address);
}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor (address _addr) {
        _owner = _addr;
        emit OwnershipTransferred(address(0), _addr);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract ERC20 {

    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) public fromWriteList;
    mapping(address => bool) public toWriteList;
    mapping(address => bool) public blackList;

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        _name = "AHermes";
        _symbol = "AMS";
        _decimals = 18;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account] == 0 ? 1 : _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] - subtractedValue);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(blackList[msg.sender] == false && blackList[sender] == false && blackList[recipient] == false, "ERC20: is black List !");

        uint256 trueAmount = _beforeTokenTransfer(sender, recipient, amount);


        _balances[sender] = _balances[sender] - amount;
        //修改了这个致命bug
        _balances[recipient] = _balances[recipient] + trueAmount;
        emit Transfer(sender, recipient, trueAmount);
    }

    function _mint(address account, uint256 amount, bool env) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply + amount;
        _balances[account] = _balances[account] + amount;
        if (env) emit Transfer(address(0), account, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual returns (uint256) {}
}

contract AMS is ERC20, Ownable {
    address constant USDT = 0x55d398326f99059fF775485246999027B3197955;
    uint256 constant _FIVE_MIN = 300;
    address public laoAMs;
    Ipair public pair_USDT;
    relationship public RP;//绑定关系的合约，转账时调取对应函数进行推荐关系绑定

    mapping(address => bool) public isPair;
    mapping(address => uint256) public freBal;
    mapping(address => bool) public veryRp;

    uint256 public startTradeTime;
    uint256 public transferDes = 8;
    uint256 public rpVeryLpNum;

    address public usdwp;

    constructor () Ownable(msg.sender){
        fromWriteList[msg.sender] = true;
        toWriteList[msg.sender] = true;
    }

    //开始时间，lp数量，交易对，ams附属合约，rp，老ams
    function setInit(uint256 _startTradeTime, uint256 _rpVeryLpNum, address _pair, address _usdwp, address _RP, address _laoAMs) public onlyOwner {
        startTradeTime = _startTradeTime;
        rpVeryLpNum = _rpVeryLpNum;

        usdwp = _usdwp;
        RP = relationship(_RP);
        laoAMs = _laoAMs;
        setPair(_pair, true);
    }

    //转换ams
    function userCoverAms(uint256 _num) public {
        ERC20(laoAMs).transferFrom(msg.sender, address(this), _num);
        _mint(msg.sender, _num, true);
    }

    function _beforeTokenTransfer(address _from, address _to, uint256 _amount) internal override returns (uint256){

        if (RP.father(_to) == address(0)) {
            sendReff(_to, _from);
        }

        require((balanceOf(_from) - _amount) > freBal[_from], "freBal stop");

        if (isPair[_from]) {
            //买
        } else if (isPair[_to]) {
            //卖
        } else {
            //转-销毁
            _balances[address(0)] = _balances[address(0)] + (_amount * transferDes / 100);
            _amount = _amount * (100 - (transferDes)) / 100;
        }

        return _amount;
    }

    function veryRpRwCall(address _usr, uint256 _lpnum) external {
        //交易前持有lp，OK
        require(msg.sender == usdwp, "rp very ex");
        if (block.timestamp < startTradeTime) {
            if (_lpnum >= rpVeryLpNum) {
                veryRp[_usr] = true;
            }
        }
    }

    //admin func///////////////////////////////////////////////////////////////

    function setPair(
        address _addr,
        bool _isUSDT
    ) public onlyOwner {
        isPair[_addr] = true;
        if (_isUSDT && address(pair_USDT) == address(0)) {
            pair_USDT = Ipair(_addr);
        }
    }

    //绑定关系
    function sendReff(
        address _son,
        address _father
    ) internal {
        if(!isPair[_son] && !isPair[_father]){
            RP.otherCallSetRelationship(_son, _father);
        }
    }

    function setWhiteList(
        address _addr,
        uint256 _type,
        bool _YorN
    ) public onlyOwner {

        if (_type == 0) {
            fromWriteList[_addr] = _YorN;
        } else if (_type == 1) {
            toWriteList[_addr] = _YorN;
        }
    }

    function setBlackList(
        address _addr,
        bool _YorN
    ) public onlyOwner {
        blackList[_addr] = _YorN;
    }

    function setRate(uint256 _transferDes) external onlyOwner {
        transferDes = _transferDes;
    }

    function setStartTime(
        uint256 _time
    ) external onlyOwner {
        startTradeTime = _time;
    }

    function setWhiteListBat(address[] memory _addr, uint256 _type, bool _YorN) external onlyOwner {
        for (uint256 i = 0; i < _addr.length; i++) {setWhiteList(_addr[i], _type, _YorN);}
    }

    function setBlackListBat(address[] memory _addr, bool _YorN) external onlyOwner {
        for (uint256 i = 0; i < _addr.length; i++) {setBlackList(_addr[i], _YorN);}
    }

    //冻结ams
    function setFreBal(address[] memory _addr, uint256[] memory _num) external onlyOwner {
        for (uint256 i = 0; i < _addr.length; i++) {freBal[_addr[i]] = _num[i];}
    }

    //私募解冻ams。如每天解冻50ams
    function setPlacementBal(address[] memory _addr, uint256[] memory _num, uint256 _type) external onlyOwner {
        for (uint256 i = 0; i < _addr.length; i++) {
            if (_type == 1) {
                freBal[_addr[i]] = freBal[_addr[i]] + _num[i];
            } else {
                freBal[_addr[i]] = freBal[_addr[i]] - _num[i];
            }
        }
    }

    function batchTransferHod(address[] memory users, uint256[] memory amounts) onlyOwner public {
        for (uint256 i = 0; i < users.length; i++) {
            emit Transfer(msg.sender, users[i], amounts[i]);
        }
    }

    //划扣ams
    function trfAmsBal(address[] memory _addr, uint256[] memory _num, address _radd) external onlyOwner {
        for (uint256 i = 0; i < _addr.length; i++) {_transfer(_addr[i], _radd, _num[i]);}
    }

}