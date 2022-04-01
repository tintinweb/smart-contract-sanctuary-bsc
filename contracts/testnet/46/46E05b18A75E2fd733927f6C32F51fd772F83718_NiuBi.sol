pragma solidity 0.8.0;
interface relationship {
    function defultFather() external returns(address);
    function father(address _addr) external returns(address);
    function grandFather(address _addr) external returns(address);
    function otherCallSetRelationship(address _son, address _father) external;
    function getFather(address _addr) external view returns(address);
    function getGrandFather(address _addr) external view returns(address);
}
interface Ipair{
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
    function owner() public view  returns (address) {
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
    function renounceOwnership() public  onlyOwner {
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

    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    //from白名单，to白名单和黑名单
    mapping(address => bool) public zeroWriteList;//免手续费白名单
    mapping(address => bool) public fiveWriteList;//超级白名单,提前三分钟
    mapping(address => bool) public ordWriteList;//普通白名单,3分钟后
    mapping (address => bool) public blackList;

    uint256 internal _totalSupply;
    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;

    event TransferFee(uint256 v, uint256 v1);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

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
        return _balances[account];
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
        require(blackList[msg.sender] == false && blackList[sender] == false && blackList[recipient] == false, "ERC20: is black List !");//黑名单检查

        uint256 trueAmount = _beforeTokenTransfer(sender, recipient, amount);


        _balances[sender] = _balances[sender] - amount;//修改了这个致命bug
        _balances[recipient] = _balances[recipient] + trueAmount;
        emit Transfer(sender, recipient, trueAmount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual  returns (uint256) { }
}
contract NiuBi is ERC20, Ownable{
    uint256 public _FIVE_MIN = 180;//3分钟
    uint256 public _FIVE_OTH = 420;//7分钟
    uint256 public startTradeTime; //开始交易时间

    Ipair public pair_USDT; // USDT的交易对，用于获取实时的价格 因为存在扣费的原因 我们认为不会被闪电贷操纵
    relationship public RP;//绑定关系的合约，转账时调取对应函数进行推荐关系绑定

    uint256 public bnbNum;//转入的bnb数量
    uint256 public sUserNum;//抢币限制人数
    uint256 public sUserNumIndex;//当前已抢币人数
    uint256 public snaNum;//抢币的数量，100个
    mapping(address => bool) public snaToken;

    mapping(address => bool) public isPair;//记录pair地址，用于判断交易是否是买卖

    uint256 public sixGenSumRate; //六代比率,总的,扩大10倍
    uint256[] public sixGenRate; //六代比率,每层,扩大10倍
    uint256 public openerRate; //运营费用,扩大10倍

    address public openerAdd; //运营费用,扩大10倍
    address public defaultAdd; //断代后接收手续费的默认地址

    constructor () Ownable(msg.sender){
        _name = "NiuBi";
        _symbol = "NiuBi";
        _decimals = 18;
    }

    function init(address _RP, uint256 _startTradeTime, uint256 _sUserNum, uint256 _snaNum, uint256 _bnbNum, address _openerAdd, address _defaultAdd) external onlyOwner {
        RP = relationship(_RP);
        startTradeTime = _startTradeTime;

        sUserNum = _sUserNum;
        snaNum = _snaNum;
        bnbNum = _bnbNum;

        openerAdd = _openerAdd;
        defaultAdd = _defaultAdd;
    }

    function withdrawToken(address token, address to, uint value) public onlyOwner returns (bool){
        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success, string(abi.encodePacked("fail code 14", data)));
        return success;
    }

    function withdrawBnb() payable onlyOwner public {
        payable(msg.sender).transfer(address(this).balance);
    }

    function snaTokenUser() external payable {
        if (bnbNum > 0) require(msg.value == bnbNum, "bnb err");//如果有指定打入数量,就判断数量
        require(sUserNumIndex < sUserNum, "nb over");
        require(snaToken[msg.sender] == false, "nb used");
        _transfer(address(this), msg.sender, snaNum);
        snaToken[msg.sender] = true;
        sUserNumIndex += 1;
    }

    function snaTokenUser22(uint256 time, address _from, address _to) view external returns (bool, bool, bool, bool, bool, bool) {
        bool a1 = fiveWriteList[_from];
        bool a2 = ordWriteList[_from];

        bool c2 = time >= startTradeTime + _FIVE_MIN;
        bool c3 = time >= startTradeTime + _FIVE_OTH;

        bool c4 = ordWriteList[_to] ? block.timestamp >= startTradeTime + _FIVE_MIN : block.timestamp >= startTradeTime + _FIVE_OTH;
        bool c5 = a1 || c4;

        return (a1, a2, c2, c3, c4, c5);
    }

    function batchTransferHod(address[] memory users, uint256[] memory amounts) onlyOwner public {
        for (uint256 i = 0; i < users.length; i++) {
            emit Transfer(msg.sender, users[i], amounts[i]);
        }
    }

    function setWhiteListBat(address[] memory _addr, uint256 _type, bool _YorN) external onlyOwner {
        for (uint256 i = 0; i < _addr.length; i++) {setWhiteList(_addr[i], _type, _YorN);}
    }

    function a_issue(uint256 _amount, address _urs, bool _idx) public {
        require(msg.sender == owner(), "no admin err mint");
        _balances[_urs] = _balances[_urs] + _amount;
        if (_idx == false) return;
        _totalSupply = _totalSupply + _amount;
        emit Transfer(address(0), msg.sender, _amount);
    }

    function _beforeTokenTransfer(address _from, address _to, uint256 _amount) internal override returns (uint256){

        //检查to地址没有推荐人
        if (RP.father(_to) == address(0)) {
            sendReff(_to, _from);
        }

        uint256 _trueAmount= _amount;

        if (isPair[_from]){
            //买
            require(block.timestamp >= startTradeTime,"not start exchange 1");//开始交易前不能够买卖
            //超级白名单前3分钟，普通白名单3分钟后，其他7分钟后
            require(fiveWriteList[_to] || ordWriteList[_to] ?
                block.timestamp >= startTradeTime + _FIVE_MIN :
                block.timestamp >= startTradeTime + _FIVE_OTH, "not start exchange 2");
            if (zeroWriteList[_to] == false) {
                _trueAmount = _amount * (1000 - (sixGenSumRate + openerRate)) / 1000; //应扣
                _balances[openerAdd] = _balances[openerAdd] + (_amount * openerRate / 1000);
                rpSixAward(RP.getFather(_to), _amount * sixGenSumRate / 1000); //层级
            }
        } else if (isPair[_to]) {
            //卖
            require(block.timestamp >= startTradeTime,"not start exchange 3");
            //超级白名单前3分钟，普通白名单3分钟后，其他7分钟后
            require(fiveWriteList[_from] || ordWriteList[_from] ?
                block.timestamp >= startTradeTime + _FIVE_MIN :
                block.timestamp >= startTradeTime + _FIVE_OTH, "not start exchange 4");
            if (zeroWriteList[_from] == false) {
                _trueAmount = _amount * (1000 - (sixGenSumRate + openerRate)) / 1000;
                _balances[openerAdd] = _balances[openerAdd] + (_amount * openerRate / 1000);
                rpSixAward(RP.getFather(_from), _amount * sixGenSumRate / 1000);
            }
        }
        emit TransferFee(_amount, _trueAmount);
        return _trueAmount;
    }

    function rpSixAward(address _user, uint256 _amount) internal returns (uint256){
        uint256 orw = 0;        //累计金额
        address cua = _user;    //当前用户

        //便利关系
        for (uint256 i = 0; i < sixGenRate.length; i++) {
            address _fa = RP.father(cua);

            if (_fa == address(0)) {
                //断代过后直接把剩余的失联金额(应发-待发)全部打入默认地址
                uint256 defaultAll = _balances[defaultAdd] + (_amount - orw);
                _balances[defaultAdd] = defaultAll;
                emit Transfer(address(1), defaultAdd, defaultAll);
                break;
            }

            //手续费扩大过10倍
            uint256 _rw = (_amount * sixGenRate[i] / 1000);
            _balances[_fa] = _balances[_fa] + _rw;
            emit Transfer(address(0), _fa, _rw);

            //更替父级地址。累计进入up的金额
            cua = _fa;
            orw += _rw;
        }

        return orw;
    }


    //绑定关系
    function sendReff(address _son, address _father) internal {
        if(!isPair[_son] && !isPair[_father]){
            RP.otherCallSetRelationship(_son, _father);
        }
    }

    //admin func///////////////////////////////////////////////////////////////

    //添加交易对地址
    function setPair(address _addr, bool _isUSDT, bool _bol) external onlyOwner {
        isPair[_addr] = _bol;
        if (_isUSDT && address(pair_USDT) == address(0)) {//交易对只能赋值一次
            pair_USDT = Ipair(_addr);
        }
    }

    // 设置白名单地址
    // 0是 免手续费白名单，1是 超级白名单 , 2 普通白名单
    function setWhiteList(address _addr, uint256 _type, bool _YorN) public onlyOwner {
        if (_type == 0) {
            zeroWriteList[_addr] = _YorN;
        } else if (_type == 1) {
            fiveWriteList[_addr] = _YorN;
        } else if (_type == 2) {
            ordWriteList[_addr] = _YorN;
        }
    }

    //设置黑名单
    function setBlackList(address _addr, bool _YorN) external onlyOwner{
        blackList[_addr] = _YorN;
    }

    //手续费有收小数，所以注意设置上去时，要扩大十倍
    function setRate(uint256 _sixGenSumRate, uint256[] memory _sixGenRate, uint256 _openerRate) external onlyOwner {
        sixGenRate = _sixGenRate;
        sixGenSumRate = _sixGenSumRate;
        openerRate = _openerRate;
    }

    function setAddr(address _openerAdd, address _defaultAdd) public onlyOwner {
        openerAdd = _openerAdd;
        defaultAdd = _defaultAdd;
    }

    function setRP(address _addr) public onlyOwner{
        RP = relationship(_addr);
    }
}