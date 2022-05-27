/**
 *Submitted for verification at BscScan.com on 2022-05-27
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-17
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// import './modules/Context.sol';
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; 
        return msg.data;
    }
}

// import './modules/Ownable.sol';
abstract contract Ownable is Context {
    
    address private _owner;
    bytes4 private constant SELECTOR_TRANSFER = bytes4(keccak256(bytes('transfer(address,uint256)')));
    bytes4 private constant SELECTOR_TRANSFERFROM = bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    
    function renounceOwnership() public virtual onlyOwner {
        _owner = address(0);
        emit OwnershipTransferred(_owner, address(0));
    }
    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        
        _owner = newOwner;
        emit OwnershipTransferred(_owner, newOwner);
    }
    
    function withdraw(address payable to, uint256 amount) external onlyOwner {
        require(to != address(0), "Warning: address cannot be zero.");
        require(address(this).balance >= amount, "Warning: insufficient balance.");
        to.transfer(amount);
    }
    
    function withdrawToken(address token, address to, uint256 amount) public onlyOwner {
        _safeTransfer(token, to, amount);
    }
    
    function _safeTransfer(address token, address spender, uint256 amount) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR_TRANSFER, spender, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'Warning: Transaction failed.');
    }

    function _safeTransferFrom(address token, address sender, address recipient, uint256 amount) internal returns (bool) {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR_TRANSFERFROM, sender, recipient, amount));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'Warning: TransferFrom failed.');
        
        return success;
    }
}

// import './libraries/SafeMath.sol';

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

// import './interfaces/IERC20.sol';
interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract PC is Context, Ownable, IERC20 {
    
    using SafeMath for uint256;

    struct Owned {
        uint256 balanceOf;
        uint256 level;
        address referrer;
        bool lockRef;
        bool active;
    }

    address[] ownedList;
    mapping(address => Owned) private _owned;
    mapping(address => mapping(address => uint256)) private _allowances;

    address[] private _excludedFromRewardList;
    mapping(address => bool) private _isExcludedFromReward;

    address[] private _excludedFromFeeList;
    mapping(address => bool) private _isExcludedFromFee;
    
    string public name = "Pickled Cabbage";
    string public symbol = "PC";
    uint256 public decimals = 18;
    uint256 override public totalSupply = 1000 * 10**8 * 10**18;
    address public ecologicalFund;
    bool private _feeIt = true;

      uint256 private _taxBuy = 8;
      uint256 private _feeShareByMarketRewardBuy = 1;
      uint256 private _feeShareByLpsBuy = 4;
      uint256 private _feeShareBySuperPartnerBuy = 2;
      uint256 private _feeShareByTechBuy = 1;

      uint256 private _taxSell = 12;
      uint256 private _feeShareByMarketRewardSell = 2;
      uint256 private _feeShareByLpsSell = 5;
      uint256 private _feeShareBySuperPartnerSell = 2;
      uint256 private _feeShareByTechSell = 1;
      uint256 private _feeShareByFund = 1;


    address public marketingWalletAddress;
    address public LpsWalletAddress;
    address public SuperPartnerWalletAddress;
    address public TechWalletAddress;
    address public FundWalletAddress;
    address public PcRouter;

    uint256 private enterCount = 0;
   
    mapping(address => bool) private stores;
    mapping(address => bool) private operators;

   // address constant pancakeSwapRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant pancakeSwapRouter = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
    
    // modifier
    modifier onlyStore{
        require(stores[_msgSender()], "Warning: No permissions.");
        _;
    }

    modifier onlyOperator{
        require(operators[_msgSender()], "Warning: No permissions.");
        _;
    }
    
    modifier transferCounter {
        enterCount = enterCount.add(1);
        _;
        enterCount = enterCount.sub(1, "transfer counter");
    }
    
     constructor() payable { 
        emit Transfer(address(0), _msgSender(), totalSupply);
        _owned[_msgSender()].balanceOf = totalSupply;
    }

    // set 
    function setMarketingWallet(address payable wallet) external onlyOwner{
        marketingWalletAddress = wallet;
    }
    function setLpsWallet(address payable wallet) external onlyOwner{
        LpsWalletAddress = wallet;
    }
    function setSuperPartnerWallet(address payable wallet) external onlyOwner{
        SuperPartnerWalletAddress = wallet;
    }
    function setFundWallet(address payable wallet) external onlyOwner{
        FundWalletAddress = wallet;
    }
    function setTechWallet(address payable wallet) external onlyOwner{
        TechWalletAddress = wallet;
    }
    function setPcRouter(address payable wallet) external onlyOwner{
        PcRouter = wallet;
    }
    
    function setOperator(address account, bool isEnable) external onlyOwner {
        require(account != address(0), "Warning: This address cannot be zero.");
        require(account != owner(), "Warning: The owner's permissions cannot be changed.");
        operators[account] = isEnable;
    }
    
    function setStore(address account, bool isEnable) external onlyOwner {
        require(account != address(0), "Warning: This address cannot be zero.");
        require(account != owner(), "Warning: The owner's permissions cannot be changed.");
        stores[account] = isEnable;
    }

    function excludeFromReward(address account) public onlyOperator {
        require(!_isExcludedFromReward[account], "Account is already excluded");
        _isExcludedFromReward[account] = true;
        _excludedFromRewardList.push(account);
    }

    function includeInReward(address account) external onlyOperator {
        require(_isExcludedFromReward[account], "Account is already excluded");
        for (uint256 i = 0; i < _excludedFromRewardList.length; i++) {
            if (_excludedFromRewardList[i] == account) {
                _excludedFromRewardList[i] = _excludedFromRewardList[_excludedFromRewardList.length - 1];
                _isExcludedFromReward[account] = false;
                _excludedFromRewardList.pop();
                break;
            }
        }
    }
    
    function excludeFromFee(address account) public onlyOperator {
        _isExcludedFromFee[account] = true;
        _excludedFromFeeList.push(account);
    }

    function includeInFee(address account) public onlyOperator {
        _isExcludedFromFee[account] = false;
        
        for (uint256 i = 0; i < _excludedFromFeeList.length; i++) {
            if (_excludedFromFeeList[i] == account) {
                _excludedFromFeeList[i] = _excludedFromFeeList[_excludedFromFeeList.length - 1];
                _excludedFromFeeList.pop();
                break;
            }
        }
    }
 
    // erc20 function
    function balanceOf(address account) external view override returns (uint256) {
        return _owned[account].balanceOf;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool){
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256){
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool){
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool){
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool){
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    // get
    
    function getOperator(address account) external view returns (bool){
        return operators[account];
    }

    function getRefByOwend(address account) external view returns (address) {
        return _owned[account].referrer;
    }

    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcludedFromReward[account];
    }
    
    function getExcludedFromRewardList() external view returns(address[] memory){
        return _excludedFromRewardList;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }
    
    function getExcludedFromFeeList() external view returns(address[] memory){
        return _excludedFromFeeList;
    }

    function getAllOwend() public view returns(address[] memory){
        return ownedList;
    }

    // pay
    receive() external payable {}

    // private
    function _removeAllFee() private {
        if (!_feeIt) return;
        _feeIt = false;
    }

    function _restoreAllFee() private {
        _feeIt = true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private transferCounter {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        if (!takeFee) _removeAllFee();
        
        _transferStandard(from, to, amount);

        if (!takeFee) _restoreAllFee();
    }

    function _transferStandard(address sender, address recipient, uint256 amount) private {
       
        _owned[sender].balanceOf = _owned[sender].balanceOf.sub(amount, "sub1 amount");
      
        if (_feeIt) {

            if(sender == PcRouter) {
                uint256 afterReward = ((amount * (100 - _taxBuy)) / 100);
                emit Transfer(sender, recipient, afterReward);
                _owned[recipient].balanceOf = _owned[recipient].balanceOf.add(afterReward);

                uint256 marketRewardAmount = ((amount * _feeShareByMarketRewardSell) / 100);
                if(marketRewardAmount > 0) emit Transfer(sender, marketingWalletAddress, marketRewardAmount);
                _owned[marketingWalletAddress].balanceOf = _owned[marketingWalletAddress].balanceOf.add(marketRewardAmount);

                uint256 LpsRewardAmount = ((amount * _feeShareByLpsSell) / 100);
                if(LpsRewardAmount > 0) emit Transfer(sender, LpsWalletAddress, LpsRewardAmount);
                _owned[LpsWalletAddress].balanceOf = _owned[LpsWalletAddress].balanceOf.add(marketRewardAmount);

                uint256 SuperPartnerRewardAmount = ((amount * _feeShareBySuperPartnerSell) / 100);
                if(SuperPartnerRewardAmount > 0) emit Transfer(sender, SuperPartnerWalletAddress, SuperPartnerRewardAmount);
                _owned[SuperPartnerWalletAddress].balanceOf = _owned[SuperPartnerWalletAddress].balanceOf.add(SuperPartnerRewardAmount);

                uint256 TechRewardAmount = ((amount * _feeShareByTechSell) / 100);
                if(TechRewardAmount > 0) emit Transfer(sender, TechWalletAddress, TechRewardAmount);
                _owned[TechWalletAddress].balanceOf = _owned[TechWalletAddress].balanceOf.add(TechRewardAmount);

                uint256 FundRewardAmount = ((amount * _feeShareByFund) / 100);
                if(FundRewardAmount > 0) emit Transfer(sender, FundWalletAddress, FundRewardAmount);
                _owned[FundWalletAddress].balanceOf = _owned[FundWalletAddress].balanceOf.add(FundRewardAmount);

                
                
            } else if(recipient == PcRouter) {
                uint256 afterReward = ((amount * (100 - _taxSell)) / 100);
                emit Transfer(sender, recipient, afterReward);
                _owned[recipient].balanceOf = _owned[recipient].balanceOf.add(afterReward);

                uint256 marketRewardAmount = ((amount * _feeShareByMarketRewardBuy) / 100);
                if(marketRewardAmount > 0) emit Transfer(sender, marketingWalletAddress, marketRewardAmount);
                _owned[marketingWalletAddress].balanceOf = _owned[marketingWalletAddress].balanceOf.add(marketRewardAmount);

                uint256 LpsRewardAmount = ((amount * _feeShareByLpsBuy) / 100);
                if(LpsRewardAmount > 0) emit Transfer(sender, LpsWalletAddress, LpsRewardAmount);
                _owned[LpsWalletAddress].balanceOf = _owned[LpsWalletAddress].balanceOf.add(LpsRewardAmount);

                uint256 SuperPartnerRewardAmount = ((amount * _feeShareBySuperPartnerBuy) / 100);
                if(SuperPartnerRewardAmount > 0) emit Transfer(sender, SuperPartnerWalletAddress, SuperPartnerRewardAmount);
                _owned[SuperPartnerWalletAddress].balanceOf = _owned[SuperPartnerWalletAddress].balanceOf.add(SuperPartnerRewardAmount);

                uint256 TechRewardAmount = ((amount * _feeShareByTechBuy) / 100);
                if(TechRewardAmount > 0) emit Transfer(sender, TechWalletAddress, TechRewardAmount);
                _owned[TechWalletAddress].balanceOf = _owned[TechWalletAddress].balanceOf.add(TechRewardAmount);

            } else {
                 emit Transfer(sender, recipient, amount);
                 _owned[recipient].balanceOf = _owned[recipient].balanceOf.add(amount);
            }
        }
    }
 

}