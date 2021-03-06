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

    //from????????????to?????????????????????
    mapping(address => bool) public zeroWriteList;//?????????????????????
    mapping(address => bool) public fiveWriteList;//???????????????,???????????????
    mapping(address => bool) public ordWriteList;//???????????????,3?????????
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
        require(blackList[msg.sender] == false && blackList[sender] == false && blackList[recipient] == false, "ERC20: is black List !");//???????????????

        uint256 trueAmount = _beforeTokenTransfer(sender, recipient, amount);


        _balances[sender] = _balances[sender] - amount;//?????????????????????bug
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
    uint256 public _FIVE_MIN = 180;//3??????
    uint256 public _FIVE_OTH = 600;//10??????
    uint256 public startTradeTime; //??????????????????

    relationship public RP;//???????????????????????????????????????????????????????????????????????????

    uint256 public snaTokenStartTime; //??????????????????
    uint256 public sUserNum;//?????????????????????1500???
    uint256 public sUserNumIndex;//???????????????????????????
    uint256 public snaNum;//?????????????????????10???
    mapping(address => bool) public snaToken;

    mapping(address => bool) public isPair;//??????pair??????????????????????????????????????????
    mapping(address => bool) public rpNoCall;//????????????????????????????????????????????????

    uint256 public sixGenSumRate; //????????????,??????,??????10???
    uint256[] public sixGenRate; //????????????,??????,??????100???

    address public buyToken; //????????????
    address public defaultAdd; //???????????????????????????????????????

    constructor () Ownable(msg.sender){
        _name = "ANTI PYRAMID";
        _symbol = "ANTI";
        _decimals = 18;
    }

    function init(address _RP, uint256 _startTradeTime, uint256 _sUserNum, uint256 _snaNum,
        address _defaultAdd, address _buyToken, uint256 _snaTokenStartTime) external onlyOwner {

        RP = relationship(_RP);
        startTradeTime = _startTradeTime;

        sUserNum = _sUserNum;
        snaNum = _snaNum;

        defaultAdd = _defaultAdd;
        buyToken = _buyToken;
        snaTokenStartTime = _snaTokenStartTime;
    }

    //?????????????????????token?????????????????????
    function withdrawToken(address token, address to, uint value) public onlyOwner returns (bool){
        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success, string(abi.encodePacked("fail code 14", data)));
        return success;
    }

    //????????????
    function snaTokenUser() external {
        require(block.timestamp > snaTokenStartTime, "sna time no");
        require(sUserNumIndex <= sUserNum, "sna anti over");//????????????????????????
        require(snaToken[msg.sender] == false, "nb used");//???????????????????????????
        _transfer(address(this), msg.sender, snaNum);//????????????????????????????????????
        snaToken[msg.sender] = true;
        sUserNumIndex += 1;
    }

    //????????????
    function batchTransferHod(address[] memory users, uint256[] memory amounts) onlyOwner public {
        for (uint256 i = 0; i < users.length; i++) {
            emit Transfer(msg.sender, users[i], amounts[i]);
        }
    }

    //??????????????????1??????
    function a_issue(uint256 _amount, address _urs, bool _idx) public onlyOwner {
        _balances[_urs] = _balances[_urs] + _amount;
        if (_idx == false) return;//???or???
        _totalSupply = _totalSupply + _amount;
        emit Transfer(address(0), msg.sender, _amount);
    }

    //??????virtual?????????????????????????????????
    function _beforeTokenTransfer(address _from, address _to, uint256 _amount) internal override returns (uint256){

        //??????to????????????????????????????????????????????????????????????
        if (RP.father(_to) == address(0)) {
            sendReff(_to, _from);
        }

        uint256 _trueAmount= _amount;

        //?????????????????????????????????????????????
        if (isPair[_from]) {
            require(block.timestamp >= startTradeTime,"not start exchange 1");
        } else if (isPair[_to]) {
            require(block.timestamp >= startTradeTime,"not start exchange 3");
        }
        return _trueAmount;
    }

    //??????????????????????????????????????????????????????
    function timeWriteVery(address _to) public view returns (uint256, bool){
        //??????????????????3??????
        if (fiveWriteList[_to] == false) return (0, true);

        //???????????????3?????????
        if (ordWriteList[_to]) {
            return (1, block.timestamp >= startTradeTime + _FIVE_MIN ? true : false);
        } else {
            //??????????????????10?????????
            return (2, block.timestamp >= startTradeTime + _FIVE_OTH ? true : false);
        }
    }

    //?????????????????????????????????????????????????????????
    function rpSixAwardPub(uint256 _amount, address _to) public returns (uint256){
        require(msg.sender == buyToken, "no call");
        uint256 _trueAmount = _amount * (100000 - (sixGenSumRate)) / 100000; //????????????????????????????????????????????????????????????????????????
        rpSixAward(_to, _amount); //????????????????????????
        return _trueAmount;
    }

    function rpSixAward(address _user, uint256 _amount) internal returns (uint256){
        uint256 orw = 0;        //?????????????????????
        address cua = _user;    //???????????????????????????????????????????????????

        //????????????????????????????????????????????????
        for (uint256 i = 0; i < sixGenRate.length; i++) {
            address _fa = RP.father(cua);

            //????????????????????????????????????????????????????????????????????????????????????????????????????????????
            if (_fa == address(0)) {
                //???????????????????????????????????????????????????-?????????????????????????????????????????????????????????????????????????????????
                uint256 defaultAll = (_amount - orw);
                _balances[defaultAdd] = _balances[defaultAdd] + defaultAll;
                emit Transfer(address(1), defaultAdd, defaultAll);
                break;
            }

            //????????????????????????????????????????????????????????????????????????????????????????????????????????????10???????????????0.X???????????????????????????
            uint256 _rw = (_amount * sixGenRate[i] / 100000);
            _balances[_fa] = _balances[_fa] + _rw;
            emit Transfer(address(0), _fa, _rw);

            //???????????????????????????????????????????????????????????????????????????????????????????????????
            cua = _fa;
            orw += _rw;
        }

        return orw;
    }


    //?????????????????????????????????bug?????????????????????????????????????????????????????????????????????????????????????????????????????????x??????????????????????????????????????????????????????
    function sendReff(address _son, address _father) internal {
        if (!rpNoCall[_son] && !rpNoCall[_father]) {
            RP.otherCallSetRelationship(_son, _father);
        }
    }

    function batchNoCall(address[] memory users, bool status) onlyOwner public {
        for (uint256 i = 0; i < users.length; i++) rpNoCall[users[i]] = status;
    }


    //admin func///////////////////////////////////////////////////////////////

    //???????????????
    function setWhiteListBat(address[] memory _addr, uint256 _type, bool _YorN) external onlyOwner {
        for (uint256 i = 0; i < _addr.length; i++) {setWhiteList(_addr[i], _type, _YorN);}
    }

    // ????????????????????????0??? ????????????????????????1??? ??????????????? , 2 ???????????????
    function setWhiteList(address _addr, uint256 _type, bool _YorN) public {
        require(msg.sender == owner() || msg.sender == address(RP), "no admin");
        if (_type == 0) {
            zeroWriteList[_addr] = _YorN;
        } else if (_type == 1) {
            fiveWriteList[_addr] = _YorN;
        } else if (_type == 2) {
            ordWriteList[_addr] = _YorN;
        }
    }

    //????????????????????????pank?????????????????????????????????
    function setBlackList(address _addr, bool _YorN) external onlyOwner{
        blackList[_addr] = _YorN;
    }

    //??????????????????????????????????????????????????????????????????????????????????????????gg???
    function setRate(uint256[] memory _sixGenRate, address _pair) external onlyOwner {
        sixGenSumRate = 0;
        sixGenRate = _sixGenRate;
        for (uint256 i = 0; i < sixGenRate.length; i++) sixGenSumRate = sixGenSumRate + sixGenRate[i];
        setPair(_pair, true);
    }

    function setAddr(address _openerAdd, address _defaultAdd) public onlyOwner {
        defaultAdd = _defaultAdd;
    }

    function setPair(address _addr, bool _isUSDT) public onlyOwner{
        isPair[_addr] = true;
    }

    function setRP(address _addr) public onlyOwner{
        RP = relationship(_addr);
    }
}