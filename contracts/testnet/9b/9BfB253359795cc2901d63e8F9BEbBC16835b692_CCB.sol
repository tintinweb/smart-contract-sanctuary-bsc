// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address public _owner;

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
   
    function renounceOwnership() public  onlyOwner {
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public  onlyOwner {
        require(newOwner != address(0),"Ownable: new owner is thezeroAddress address");
        _owner = newOwner;
    }
}

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not beingzeroAddress, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Pair {}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {}

contract CCB is IERC20, Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint8 private _decimals = 6;
    string private _name = "CCB Token";
    string private _symbol = "CCB";

    uint256 private _fundFee;
    uint256 private _ecology1Fee;
    uint256 private _ecology2Fee;
    uint256 private _businessFee;
    uint256 private _nodeFee;
    uint256 private _relation1;
    uint256 private _relation2;
    uint256 private _relation3;
    uint256 private _totalSupply;

    address private zeroAddress = address(0);
    address private fundAddress = 0x2010Cef841a348b10cb31c69C69624DFaB266C4b;
    address private ecology1Address = 0x6228174d5E50F2987607Ea94b7aC3E77E09Ea269;
    address private ecology2Address = 0x59F37A306C1Bbf3Fa0803ae747a0CDdF933eDEAc;
    address private businessAddress = 0x0e0f35F0f4269E5167d920652ebFCF78E6b18375;
    address private nodeAddress = 0x155c19877fee0443543c648271e5DFF02647551e;

    IUniswapV2Pair public immutable uniswapV2Pair;

    mapping (address => Relation) _relationShip;

    struct Relation{
        address one;
        address two;
        address three;
        address four;
        address five;
        address six;
        address seven;
        address eight;
    }

    constructor (address router_, address usdt_){
        _owner = msg.sender;
        _totalSupply = 10000000*10**_decimals;
        _balances[_owner] = _totalSupply;
        _fundFee = 10;
        _ecology1Fee = 10;
        _ecology2Fee = 10;
        _businessFee = 10;
        _nodeFee = 20;
        _relation1 = 10;
        _relation2 = 6;
        _relation3 = 4;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router_);
        uniswapV2Pair = IUniswapV2Pair(IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), usdt_));
    }

    function name() public view  returns (string memory) {
        return _name;
    }

    function symbol() public view  returns (string memory) {
        return _symbol;
    }

    function decimals() public view  returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance belowzeroAddress");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != zeroAddress, "ERC20: approve from thezeroAddress address");
        require(spender != zeroAddress, "ERC20: approve to thezeroAddress address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != zeroAddress, "ERC20: transfer from thezeroAddress address");
        require(recipient != zeroAddress, "ERC20: transfer to thezeroAddress address");
        require(amount > 0, "Transfer amount must be greater thanzeroAddress");
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        _balances[sender] = senderBalance.sub(amount);

        if (recipient != address(uniswapV2Pair) && sender != address(uniswapV2Pair)){
            _relationEstablish(sender, recipient);
        }

        if (sender == address(uniswapV2Pair)){
            uint256 fundFee = amount.mul(_fundFee).div(1000);
            uint256 ecology1Fee = amount.mul(_ecology1Fee).div(1000);
            uint256 ecology2Fee = amount.mul(_ecology2Fee).div(1000);
            uint256 businessFee = amount.mul(_businessFee).div(1000);
            uint256 nodeFee = amount.mul(_nodeFee).div(1000);
            uint256 relation1 = amount.mul(_relation1).div(1000);
            uint256 relation2 = amount.mul(_relation2).div(1000);
            uint256 relation3 = amount.mul(_relation3).div(1000);
           
            _transferToken(sender, fundAddress, fundFee);
            _transferToken(sender, ecology1Address, ecology1Fee);
            _transferToken(sender, ecology2Address, ecology2Fee);
            _transferToken(sender, businessAddress, businessFee);
            _transferToken(sender, nodeAddress, nodeFee);
            _relationTransfer(sender, recipient, fundAddress, relation1, relation2, relation3);

            {// avoids stack too deep errors
            uint256 totalFee = fundFee + ecology1Fee + ecology2Fee + businessFee + nodeFee + relation1 + relation2 + relation3*6;
            uint256 recipientAmount = amount.sub(totalFee);
            _transferToken(sender, recipient, recipientAmount);
            }
        } else {
            _transferToken(sender, recipient, amount);
        }
    }


    function _relationEstablish(address sender, address recipient) internal {
        if (_relationShip[recipient].one == zeroAddress){
            _relationShip[recipient].one = sender;
            if (_relationShip[recipient].two == zeroAddress && _relationShip[sender].one != zeroAddress){
            _relationShip[recipient].two = _relationShip[sender].one;
            }
            if (_relationShip[recipient].three == zeroAddress && _relationShip[sender].two != zeroAddress){
                _relationShip[recipient].three = _relationShip[sender].two;
            }
            if (_relationShip[recipient].four == zeroAddress && _relationShip[sender].three != zeroAddress){
                _relationShip[recipient].four = _relationShip[sender].three;
            }
            if (_relationShip[recipient].five == zeroAddress && _relationShip[sender].four != zeroAddress){
                _relationShip[recipient].five = _relationShip[sender].four;
            }
            if (_relationShip[recipient].six == zeroAddress && _relationShip[sender].five != zeroAddress){
                _relationShip[recipient].six = _relationShip[sender].five;
            }
            if (_relationShip[recipient].seven == zeroAddress && _relationShip[sender].six != zeroAddress){
                _relationShip[recipient].seven = _relationShip[sender].six;
            }
            if (_relationShip[recipient].eight == zeroAddress && _relationShip[sender].seven != zeroAddress){
                _relationShip[recipient].eight = _relationShip[sender].seven;
            }
        }
    }

    function _relationTransfer(address sender, address recipient, address fund, uint256 first,  uint256 second, uint256 three) internal {

        if (_relationShip[recipient].one != zeroAddress){
            _transferToken(sender, _relationShip[recipient].one, first);
        } else {
            _transferToken(sender, fund, first + second + three*6);
            return;
        }

        if (_relationShip[recipient].two != zeroAddress){
            _transferToken(sender, _relationShip[recipient].two, second);
        }else {
            _transferToken(sender, fund, second + three*6);
            return;
        }

        if (_relationShip[recipient].three != zeroAddress){
            _transferToken(sender, _relationShip[recipient].three, three);
        }else {
            _transferToken(sender, fund, three*6);
            return;
        }

        if (_relationShip[recipient].four != zeroAddress){
            _transferToken(sender, _relationShip[recipient].four, three);
        }else {
            _transferToken(sender, fund, three*5);
            return;
        }

        if (_relationShip[recipient].five != zeroAddress){
            _transferToken(sender, _relationShip[recipient].five, three);
        }else {
            _transferToken(sender, fund, three*4);
            return;
        }

        if (_relationShip[recipient].six != zeroAddress){
            _transferToken(sender, _relationShip[recipient].six, three);
        }else {
            _transferToken(sender, fund, three*3);
            return;
        }

        if (_relationShip[recipient].seven != zeroAddress){
            _transferToken(sender, _relationShip[recipient].seven, three);
        }else {
            _transferToken(sender, fund, three*2);
            return;
        }

        if (_relationShip[recipient].eight != zeroAddress){
            _transferToken(sender, _relationShip[recipient].eight, three);
        }else {
            _transferToken(sender, fund, three);
        }
    }

    function _transferToken(address sender, address recipient, uint256 amount) internal {
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

}