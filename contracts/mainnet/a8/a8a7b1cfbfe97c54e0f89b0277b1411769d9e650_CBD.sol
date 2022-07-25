/**
 *Submitted for verification at BscScan.com on 2022-07-25
*/

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint256);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}
contract ERC20 is IERC20,Context{
    using SafeMath for uint256;

    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) public _allowances;

    uint256 internal _totalSupply;

    string private _name;
    string private _symbol;
    uint256 private _decimals;

    constructor(string memory name_, string memory symbol_,uint256 totalSupply_, uint256 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _totalSupply = totalSupply_;
    }

    function name() public override view virtual returns (string memory) {
        return _name;
    }

    function symbol() public override view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public override view virtual returns (uint256) {
        return _decimals;
    }

    function totalSupply() public override view virtual returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}
library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }
    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }
    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }
    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }
    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }
    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }
    function renounceOwnership() public virtual authorized {
        emit OwnershipTransferred(address(0));
        owner = address(0);
    }
    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
interface IDEXRouter {
    function factory() external pure returns (address);
}
interface IDEXPair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function allowance(address owner, address spender) external view returns (uint);
}

contract CBD is ERC20, Auth {
    using SafeMath for uint256;
    using Address for address;

    string public mName = "Carbon Equal DAO";
    string public mSymbol = "CBD";
    uint8 public mDecimals = 6;
    uint256 public mTotalSupply = 33_000_000 * (10 ** mDecimals);

    uint256 public burnedTotal;
    bool public burnFlag = true;

    uint256 public burnTotal = 10_000_000 * (10 ** mDecimals);
    IDEXRouter public router;
    address public pair;
    address public feeAddress;
    
    uint256 public buyRate = 30;
    uint256 public buyBurnRate = 5;
    uint256 public sellRate = 60;
    uint256 public sellBurnRate = 10;
    uint256 public addRate = 30;
    uint256 public addBurnRate = 5;

    address constant USDTAddress = 0x55d398326f99059fF775485246999027B3197955;
    IERC20 public USDT;

    address constant routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping (address => bool) private _isExcluded;

    enum TypeArr{
        None,
        Sell,
        AddLp,
        Buy,
        RemoveLp
    }
    event Type(TypeArr fType);
    event FeeInfo(TypeArr fType,address indexed form,uint256 fee,uint256 realFeeBurn,uint256 feeBurn);

    constructor() Auth(msg.sender) ERC20(mName, mSymbol ,mTotalSupply,mDecimals) {
        router = IDEXRouter(routerAddress);
        pair = IDEXFactory(router.factory()).createPair(USDTAddress,address(this));
        _allowances[address(this)][address(router)] = uint256(2**256-1);
        USDT = IERC20(USDTAddress);

        feeAddress = msg.sender;

        _isExcluded[msg.sender] = true;

        _balances[msg.sender] = mTotalSupply;
        emit Transfer(address(0), msg.sender, mTotalSupply);
    }

    function _transfer(address from,address to,uint256 amount) internal virtual override {
        if(amount == 0 || (from != pair && to != pair) || _isExcluded[from] || _isExcluded[to]){ 
            return super._transfer(from, to, amount);
        }
        TypeArr tmpFlag = _getType(from,to);
        uint256 feeRate = 0;
        uint256 burnRate = 0;
        address realFromAddress = from;
        if(tmpFlag == TypeArr.Sell && sellRate > 0){
            feeRate = sellRate;
            burnRate = sellBurnRate;
        }else if(tmpFlag == TypeArr.AddLp && addRate > 0){
            feeRate = addRate;
            burnRate = addBurnRate;
        }else if(tmpFlag == TypeArr.Buy && buyRate > 0){
            feeRate = buyRate;
            burnRate = buyBurnRate;
            realFromAddress = to;
        }
        if(feeRate > 0){
            uint256 fee = amount.mul(feeRate).div(1000);
            uint256 realFeeBurn = fee;
            uint256 feeBurn = 0;
            if(burnFlag){
                feeBurn = amount.mul(burnRate).div(1000);
                realFeeBurn = fee.sub(feeBurn);
                _isBurn(address(0),feeBurn);
            }
            _balances[feeAddress] = _balances[feeAddress].add(realFeeBurn);
            emit Transfer(from, feeAddress, realFeeBurn);

            amount = amount.sub(fee);

            emit FeeInfo(tmpFlag,realFromAddress,fee,realFeeBurn,feeBurn);
        }
        
        super._transfer(from, to, amount);
    }

    function _getType(address _from, address _to) private returns (TypeArr flag){
        flag = TypeArr.None;
        if(_to == pair){
            flag = TypeArr.Sell;
            uint256 pairUsdtBalance = USDT.balanceOf(pair);
            (uint reserve0, uint reserve1, ) = IDEXPair(pair).getReserves();
            if(address(this) == IDEXPair(pair).token1() && pairUsdtBalance != reserve0){
                flag = TypeArr.AddLp;
            }
            if(address(this) == IDEXPair(pair).token0() && pairUsdtBalance != reserve1){
                flag = TypeArr.AddLp;
            }
        }
        if(_from == pair){
            flag = TypeArr.RemoveLp;
            uint256 pairUsdtBalance = USDT.balanceOf(pair);
            (uint reserve0, uint reserve1, ) = IDEXPair(pair).getReserves();
            if(USDTAddress == IDEXPair(pair).token0() && pairUsdtBalance > reserve0){
                flag = TypeArr.Buy;
            }
            if(USDTAddress == IDEXPair(pair).token1() && pairUsdtBalance > reserve1){
                flag = TypeArr.Buy;
            }
        }
        emit Type(flag);
    }
    function setBurnFlag(bool _new) external authorized{
        burnFlag = _new;
    }
    function _isBurn(address _to, uint brunVal) private{
        if(_to == address(0) && burnFlag){
            burnedTotal = burnedTotal.add(brunVal);
            if(burnedTotal > burnTotal){
                uint256 diff = burnedTotal.sub(burnTotal);
                brunVal = brunVal.sub(diff);
                burnedTotal = burnTotal;
                burnFlag = false;
            }
            _balances[_to] = _balances[_to].add(brunVal);
            emit Transfer(address(this), address(0), brunVal);
            _totalSupply = _totalSupply.sub(brunVal);
        }
    }
    function getPrice()external view returns(uint256 rate,uint256 diffDecimals){
        (uint reserve0, uint reserve1, ) = IDEXPair(pair).getReserves();
        rate = USDTAddress == IDEXPair(pair).token0() ? reserve0.div(reserve1) : reserve1.div(reserve0);
        diffDecimals = uint256(18).sub(mDecimals);
    }

    function transferFrom(address sender,address recipient,uint256 amount) public virtual override returns (bool) {
        return super.transferFrom(sender, recipient, amount);
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool){
        return super.transfer(recipient, amount);
    }


    function getOwner() external view returns (address) { return owner; }

    function setFeeAddress(address _new) public authorized {
        feeAddress = _new;
    }
    function setExcluded(address account, bool excluded) public authorized {
        _isExcluded[account] = excluded;
    }
    function setBuyRate(uint256 _buyRate,uint256 _burnRate) external authorized{ 
        buyRate = _buyRate;
        buyBurnRate = _burnRate;
    }
    function setSellRate(uint256 _sellRate,uint256 _burnRate) external authorized{ 
        sellRate = _sellRate;
        sellBurnRate = _burnRate;
    }
    function setAddRate(uint256 _addRate,uint256 _burnRate) external authorized{ 
        addRate = _addRate;
        addBurnRate = _burnRate;
    }
    function setPairAddress(address _pair) external authorized{
        require(_pair != pair, "The pair already has that address");
        pair = _pair;
    }
    
}