/**
 *Submitted for verification at BscScan.com on 2022-06-30
*/

pragma solidity 0.5.16;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract MUDOL2 {
    using SafeMath for uint256;

    ///////////////////////// events /////////////////////////
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event SetDistributor(address indexed previousDistributor, address indexed newDistributor);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    ///////////////////////////////////////////////////////////

    address private _owner;

    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (bytes4 => bool) private _supportedInterfaces;

    ///////////////////////// mining /////////////////////////
    address public distributor;

    uint256 public constant totalAmount = 500000000 ether;
    uint256 public constant initialIssuanceAmount = 5000000 ether;
    uint256 public constant privateSaleAmount = 50000000 ether;
    uint256 public constant advisorAmount = 15000000 ether;
    uint256 public constant teamAmount = 60000000 ether;
    uint256 public constant vMetaTreasuryAmount = 25000000 ether;
    uint256 public constant runningBlocks = 3 * 365 * 24 * 60 * 20; // 3 years = 3 * 365 * 24 * 60 * 60 / 3

    uint256 public miningAmount; // 총 마이닝으로 배포할 수량
    uint256 public initialAmount;

    uint256 public blockAmount;
    uint256 public minableBlock;  // mining 시작 시점(block number) -- *이 블록부터* 마이닝 시작
    uint256 public lastMined;
    ///////////////////////////////////////////////////////////

    constructor(
        uint256 _minableBlock,
        address _initialSupplyClaimer
    ) public {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);

        _name = "Mudol2 Token";
        _symbol = "MUDOL2";
        _decimals = 18;

        require(_minableBlock > block.number);
        minableBlock = _minableBlock;
        lastMined = 0;

        initialAmount = initialIssuanceAmount.add(teamAmount).add(privateSaleAmount).add(advisorAmount).add(vMetaTreasuryAmount);
        miningAmount = totalAmount.sub(initialAmount);
        blockAmount = miningAmount.div(runningBlocks);

        require(_initialSupplyClaimer != address(0));
        require(initialAmount <= totalAmount);
        _mint(_initialSupplyClaimer, initialAmount);
    }

    ///////////////////////// ownable /////////////////////////
    modifier onlyOwner {
        require(msg.sender == _owner, "Ownable: caller is not the owner");
        _;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    ///////////////////////////////////////////////////////////

    ///////////////////////// distributor /////////////////////////
    modifier onlyDistributor {
        require(msg.sender == distributor);
        _;
    }

    function setDistributor(address _distributor) public onlyOwner {
        _setDistributor(_distributor);
    }

    function _setDistributor(address _distributor) internal {
        require(_distributor != address(0), "Distributor: new distributor is the zero address");
        emit SetDistributor(distributor, _distributor);
        distributor = _distributor;
    }
    ///////////////////////////////////////////////////////////

    ///////////////////////// mining /////////////////////////
    function mined() public view returns (uint256) {
        uint256 _endBlock = block.number;
        uint256 _startBlock = minableBlock;
        if (_endBlock < _startBlock) return 0;

        uint256 _curMined = ((_endBlock.sub(_startBlock)).add(1)).mul(blockAmount);

        return _curMined > miningAmount ? miningAmount : _curMined;
    }

    event Mine(uint256 miningAmount, uint256 lastMined, uint256 curMined);
    function mine() public onlyDistributor {
        uint256 _curMined = mined();
        uint256 _miningAmount = _curMined.sub(lastMined);
        
        if(_miningAmount == 0) return;

        emit Mine(_miningAmount, lastMined, _curMined);
        
        lastMined = _curMined;
        _mint(distributor, _miningAmount);
    }
    //////////////////////////////////////////////////////////

    ////////////////////// BEP20 Standard //////////////////////
    function getOwner() external view returns (address) {
        return owner();
    }

    function supportsInterface(bytes4 interfaceId) external view returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");
        
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 value) internal {
        require(account != address(0), "BEP20: burn from the zero address");

        _balances[account] = _balances[account].sub(value, "BEP20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(value);
        emit Transfer(account, address(0), value);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    ///////////////////////////////////////////////////////////
}