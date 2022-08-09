/**
 *Submitted for verification at BscScan.com on 2022-08-09
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

    function name() public override view virtual returns (string memory) {return _name;}
    function symbol() public override view virtual returns (string memory) {return _symbol;}
    function decimals() public override view virtual returns (uint256) {return _decimals;}
    function totalSupply() public override view virtual returns (uint256) {return _totalSupply;}
    function balanceOf(address account)public view virtual override returns (uint256){return _balances[account];}
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) { return _allowances[owner][spender];}
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom( address sender, address recipient, uint256 amount ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve( sender, _msgSender(), _allowances[sender][_msgSender()].sub( amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve( _msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve( _msgSender(), spender, _allowances[_msgSender()][spender].sub( subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    function _transfer( address sender, address recipient, uint256 amount ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(sender, recipient, amount);
        _balances[sender] = _balances[sender].sub(amount,"ERC20: transfer amount exceeds balance");
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
        _balances[account] = _balances[account].sub( amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
    function _approve( address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _beforeTokenTransfer(address from, address to, uint256 amount ) internal virtual {}
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

contract TNP is ERC20, Auth {
    using SafeMath for uint256;
    using Address for address;

    string public mName = "Trading Network Protocol";
    string public mSymbol = "TNP";
    uint8 public mDecimals = 6;
    uint256 public mTotalSupply = 1_000_000 * (10 ** mDecimals);

    IDEXRouter public router;
    address public pair;
    address public treasuryAddress = 0x87edDd3E66Ace175ECC1aa585e1e3c8B411e8486;
    address public rewardAddress = 0x23306A6353221e1c2Ee67A4A58CcE26e56D6E63F;

    uint256 public buyRate = 60;
    uint256 public buyRewardRate = 18;
    uint256 public sellRate = 60;
    uint256 public sellRewardRate = 18;

    mapping (address => uint256) public preOrderList;
    bool tradeFlag = false;

    address constant USDTAddress = 0x55d398326f99059fF775485246999027B3197955;
    IERC20 public USDT = IERC20(USDTAddress);
    address constant routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    mapping (address => bool) private _isExcluded;

    event RewardInfo(address indexed form,uint256 price,uint256 buyOrSell,uint256 originAmount,uint256 rewardAmount,uint256 treasuryAmount);

    constructor() Auth(msg.sender) ERC20(mName, mSymbol ,mTotalSupply,mDecimals) {
        router = IDEXRouter(routerAddress);
        pair = IDEXFactory(router.factory()).createPair(USDTAddress,address(this));
        _allowances[address(this)][address(router)] = uint256(2**256-1);

        _isExcluded[msg.sender] = true;

        _balances[msg.sender] = mTotalSupply;
        emit Transfer(address(0), msg.sender, mTotalSupply);
    }

    function _transfer(address from,address to,uint256 amount) internal virtual override {
        if(amount == 0 || (from != pair && to != pair) || _isExcluded[from] || _isExcluded[to]){ 
            return super._transfer(from, to, amount);
        }
        (uint256 rate, ) = getPrice();
        if(!tradeFlag){
            if(from == pair && preOrderList[to] > 0){
                uint256 usdtAmount = amount.mul(rate);
                require(preOrderList[to] >= usdtAmount,"Insufficient quota usdt");
                preOrderList[to] = preOrderList[to].sub(usdtAmount);
            }else{
                revert("wait start trade");
            }
        }
        
        uint256 treasuryAmount = 0;
        uint256 rewardAmount = 0;
        uint256 buyOrSell = 1;
        address realFromAddress = from;
        if(to == pair){
            buyOrSell = 2;
            treasuryAmount = amount.mul(sellRate.sub(sellRewardRate)).div(1000);
            rewardAmount = amount.mul(sellRewardRate).div(1000);
        }else{
            treasuryAmount = amount.mul(buyRate.sub(buyRewardRate)).div(1000);
            rewardAmount = amount.mul(buyRewardRate).div(1000);
            realFromAddress = to;
        }
        uint256 originAmount = amount;
        if(rewardAmount > 0){
            amount = amount.sub(rewardAmount);
            _balances[rewardAddress] = _balances[rewardAddress].add(rewardAmount);
            emit Transfer(from, rewardAddress, rewardAmount);  
        }
        if(treasuryAmount > 0){
            amount = amount.sub(treasuryAmount);
            _balances[treasuryAddress] = _balances[treasuryAddress].add(treasuryAmount);
            emit Transfer(from, treasuryAddress, treasuryAmount);
        }

        emit RewardInfo(realFromAddress,rate, buyOrSell,originAmount, rewardAmount, treasuryAmount);
        super._transfer(from, to, amount);
    }

    function getPrice() public view returns(uint256 rate,uint256 diffDecimals){
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

    function setPreOrderList(address[] memory _addressList,uint256[] memory _amountList) external authorized {
        for(uint i = 0; i < _addressList.length; i++) {
            preOrderList[_addressList[i]] = _amountList[i];
        }
    }

    function setTrade(bool flag) external authorized {
        tradeFlag = flag;
    }
    function setFeeAddress(address _treasury,address _reawrd) external authorized {
        treasuryAddress = _treasury;
        rewardAddress = _reawrd;
    }
    function setExcluded(address account, bool excluded) external authorized {
        _isExcluded[account] = excluded;
    }
    function setBuyRate(uint256 _buyRate,uint256 _rewardRate) external authorized{ 
        buyRate = _buyRate;
        buyRewardRate = _rewardRate;
    }
    function setSellRate(uint256 _sellRate,uint256 _rewardRate) external authorized{ 
        sellRate = _sellRate;
        sellRewardRate = _rewardRate;
    }
    function setPairAddress(address _pair) external authorized{
        require(_pair != pair, "The pair already has that address");
        pair = _pair;
    }
    
}