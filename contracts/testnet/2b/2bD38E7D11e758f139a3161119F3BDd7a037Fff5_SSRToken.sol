// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBEP20 {
    function totalSupply() external view returns (uint256);


    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Context {
    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Ownable is Context {
    address _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Pair {
    function totalSupply() external view returns (uint);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
}

contract SSRToken is Context, IBEP20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint8 public _decimals;
    string public _symbol;
    string public _name;

    mapping(address => uint256) private _erc20Balance;
    mapping(address => bool) private _isReceive;
    mapping(address => uint256) private _bnbBalance;
    mapping(address => uint256) private _buyBalance;
    mapping(address => Relation) private _relation;
    mapping(address => AirdropRelation) private _aridropRelation;

    address private _collectionAddress;
    address private _fund;
    address private _lastBuyAddress;

    uint256 private _lastBuyTime;
    uint256 private _preAmount;
    uint256 private _preBnbTotalAmount;

    IUniswapV2Router02 public immutable uniswapV2Router;
    IUniswapV2Pair public immutable uniswapV2Pair;

    struct Relation {
        address one;
        address two;
        address three;
    }

    struct AirdropRelation{
        uint256 airM;
        uint256 airLimit;
        uint256 preM;
    }

    event Airdrop(address indexed sender, uint256 amount);
    event Buy(address indexed sender, uint256 amount);
    event Withdraw(address indexed sender, uint256 amount);

    constructor(address collectionAddress_, address router_, address fund_) {
        _name = "SSR MONEY TOKEN";
        _symbol = "SSR";
        _decimals = 18;
        _totalSupply = 1888888*10**_decimals;
        _balances[msg.sender] = _totalSupply;

        _collectionAddress = collectionAddress_;
        _fund = fund_;
        _preAmount = 5666664*10**(_decimals - 1);

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router_);
        uniswapV2Pair = IUniswapV2Pair(IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH()));
        uniswapV2Router = _uniswapV2Router;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function getOwner() external view override returns (address) {
        return owner();
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256){
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool){
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256){
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool){
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool){
        _approve(_msgSender(),spender,_allowances[_msgSender()][spender].sub(subtractedValue,"BEP20: decreased allowance below zero"));
        return true;
    }

    function mint(uint256 amount) public onlyOwner returns (bool) {
        _mint(_msgSender(), amount);
        return true;
    }

    function burn(uint256 amount) public returns (bool) {
        _burn(_msgSender(), amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount,"BEP20: transfer amount exceeds balance");

        uint totalLP = uniswapV2Pair.totalSupply();

        if (recipient == address(uniswapV2Pair) && totalLP == 0){
            require(sender == _owner, "BEP20: Only Owner can add the flow pool for the first time");
        }


        if (sender == address(uniswapV2Pair)){
            uint256 fee = _relationTransfer(sender, recipient, amount);
            _balances[recipient] = _balances[recipient].add(amount.sub(fee));
            emit Transfer(sender, recipient, amount);
        } else if(recipient == address(uniswapV2Pair)) {
            uint256 fee = amount.mul(4).div(100);
            _balances[recipient] = _balances[recipient].add(amount.sub(fee));
            _balances[_fund] = _balances[_fund].add(fee);
            _burn(recipient, fee);
            emit Transfer(sender, recipient, amount.sub(fee));
            emit Transfer(sender, recipient, fee);
        } else {
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
        }
        
    }

    function _relationTransfer(address sender, address recipient, uint256 amount) internal returns(uint256 totalFee) {
        uint256 fee1 = amount.mul(5).div(100);
        uint256 fee2 = amount.mul(2).div(100);
        uint256 fee3 = amount.mul(1).div(100);
        totalFee = fee1 + fee2 + fee3;
        if (_relation[recipient].one != address(0)){
            _balances[_relation[recipient].one] = _balances[_relation[recipient].one].add(fee1);
            emit Transfer(sender, _relation[recipient].one, amount);
            if (_relation[recipient].two != address(0)){
                _balances[_relation[recipient].two] = _balances[_relation[recipient].two].add(fee2);
                emit Transfer(sender, _relation[recipient].two, amount);
                if (_relation[recipient].three != address(0)){
                    _balances[_relation[recipient].three] = _balances[_relation[recipient].three].add(fee3);
                    emit Transfer(sender, _relation[recipient].three, amount);
                }else{
                    _balances[_fund] = _balances[_fund].add(fee3);
                    emit Transfer(sender, _fund, fee3);
                }
            }else{
                _balances[_fund] = _balances[_fund].add(fee2+fee3);
                emit Transfer(sender, _fund, fee2+fee3);
            }
        } else {
            _balances[_fund] = _balances[_fund].add(totalFee);
            emit Transfer(sender, _fund, totalFee);
        }

        
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account,_msgSender(),_allowances[account][_msgSender()].sub(amount,"BEP20: burn amount exceeds allowance"));
    }

    function getERC20Balance(address owner_) external view returns (uint256) {
        return _erc20Balance[owner_];
    }

    function getIsReceive(address owner_) external view returns (bool) {
        return _isReceive[owner_];
    }

    function getBalance(address owner_) external view returns (uint256) {
        return _bnbBalance[owner_];
    }

    function getCanBuyBalance(address owner_) external view returns (uint256) {
        uint256 buyBalance = _buyBalance[owner_];
        return (5 * 10**_decimals).sub(buyBalance);
    }

    function getLastBuyAddressAndTime() external view returns (address, uint256){
        return (_lastBuyAddress, _lastBuyTime);
    }

    function getPreBnbTotalAmount() external view returns (uint256){
        return _preBnbTotalAmount;
    }

    function setNewCollectionAddress(address _new) external onlyOwner {
        require(_new != address(0), "BEP20: cannot be zero address");
        _collectionAddress = _new;
    }


    function _establishRelation(address recomm) internal {
        if (_relation[msg.sender].one == address(0) && recomm != address(0)) {
            _relation[msg.sender].one = recomm;
            _relation[msg.sender].two = _relation[recomm].one;
            _relation[msg.sender].three = _relation[recomm].two;
        }
    }

    function airdrop(address recomm) external {
        _establishRelation(recomm);
        address sender = msg.sender;
        require(!_isReceive[sender],"BEP20: The airdrop has been received and cannot be received again");
        uint256 airdropAmount = 10 * 10**_decimals;
        if (recomm != address(0)) {
            _aridropRelation[recomm].airM = _aridropRelation[recomm].airM + 1;
            if (_aridropRelation[recomm].airLimit < 1500*10**_decimals){
                _erc20Balance[recomm] = _erc20Balance[recomm].add(airdropAmount);
                _aridropRelation[recomm].airLimit = _aridropRelation[recomm].airLimit + airdropAmount;
            }
        }
        _isReceive[sender] = true;
        _erc20Balance[sender] =_erc20Balance[sender].add(airdropAmount);
        emit Airdrop(sender, airdropAmount);
    }

    function buy(address recomm) external payable {
        _establishRelation(recomm);
        uint256 buyAmount = msg.value;
        uint256 price = 113333268; // div 1000

        uint256 amount = buyAmount.mul(price).div(10000);
        uint256 buyBalance = _buyBalance[msg.sender];
        require(_preAmount >= amount, "BEP20: Insufficient pre-sale surplus");
        require(buyAmount <= 5*10**18 && buyAmount >= 10**17,"BEP20: Minimum 0.1 BNB, maximum 5 BNB");
        require((5*10**_decimals).sub(buyBalance) >= buyAmount,"BEP20: The purchase quantity has been operated 5 BNB");

        uint256 recommFree;
        if (recomm != address(0)) {
            recommFree = buyAmount.mul(10).div(100);
            _bnbBalance[recomm] = _bnbBalance[recomm].add(recommFree);
            _aridropRelation[recomm].preM = _aridropRelation[recomm].preM + 1;
        }
        _buyBalance[msg.sender] = buyBalance.add(buyAmount);

        uint256 fee = amount.mul(5).div(100);

        _transfer(_owner, msg.sender, amount.sub(fee));
        _transfer(_owner, _fund, fee);
        payable(_collectionAddress).transfer(buyAmount.sub(recommFree));
        
        _lastBuyAddress = msg.sender;
        _lastBuyTime = block.timestamp;
        _preAmount -= amount;
        _preBnbTotalAmount += buyAmount;
        emit Buy(msg.sender, buyAmount);
    }

    function withdraw() external {
        uint256 balance = _bnbBalance[msg.sender];
        require(balance > 0, "BEP20: The balance is unstable");
        require(_aridropRelation[msg.sender].preM >= 5, "BEP20: The number of invitees is less than 5 and cannot be collected");
        _bnbBalance[msg.sender] = 0;
        payable(msg.sender).transfer(balance);
        emit Withdraw(msg.sender, balance);
    }

    function withdrawOnlyOwner() external onlyOwner{
        require(address(this).balance > 0, "BEP20: Balance is not enough");
        payable(msg.sender).transfer(address(this).balance);
        emit Withdraw(msg.sender, address(this).balance);
    }

    function transfer() external {
        uint256 balance = _erc20Balance[msg.sender];
        require(_aridropRelation[msg.sender].airM >= 5, "BEP20: The number of invitees is less than 5 and cannot be collected");
        require(balance > 0, "BEP20: The balance is unstable");
        _erc20Balance[msg.sender] = 0;
        _transfer(_owner, msg.sender, balance);
        emit Transfer(_owner, msg.sender, balance);
    }
}