/**
 *Submitted for verification at BscScan.com on 2022-05-10
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

contract DFT is Context, Ownable, IERC20 {
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
    
    string public name = "Design For Testability";
    string public symbol = "DFT";
    uint256 public decimals = 18;
    uint256 override public totalSupply = 2.1 * 10**8 * 10**18;

    uint256 public minCirculation = 2100000;
    uint256 public blackholeLimit = totalSupply - minCirculation;
    
    address public ecologicalFund;
    address public constant blackhole = 0x0000000000000000000000000000000000000001;

    bool private _feeIt = true;
    uint256 private _tax = 9;
    uint256 private _feeShareByBlackhole = 11;
    uint256 private _feeShareByMarketReward = 89;

    uint256 private _feeShareByLps = 56;
    uint256 private _feeShareByOwned = 33;
    uint256 private _feeShareBySuperPartner = 0;
    uint256 private _feeShareByCommunityPartner = 0;
    uint256 private _feeShareByEcologicalFund = 0;

    uint256 private enterCount = 0;
    uint256 private constant DIVIDING = 100 * 10**18;

    mapping(address => bool) private stores;
    mapping(address => bool) private operators;

    address[] superPartnerList;
    uint256 public superPartnerCount;
    uint256 public constant SUPER_PARTNER_LIMIT = 19;

    address[] communityPartnerList;
    uint256 public communityPartnerCount;
    uint256 public constant COMMUNITY_PARTNER_LIMIT = 199;

    address[] liquidityRewardAccountList;
    mapping(address => bool) liquidityRewardAccounts;

    uint256[8] marketRewardPercents = [40, 20, 10, 10, 5, 5, 5, 5];
    address constant pancakeSwapRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    
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

    // constructor
    constructor(address _ecologicalFund) {

        ecologicalFund = _ecologicalFund;
        _owned[_msgSender()].balanceOf = totalSupply;

        operators[_msgSender()] = true;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        emit Transfer(address(0), _msgSender(), totalSupply);
    }

    // set 

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
    
    function setEcologicalFund(address account) public onlyOperator {
        require(account != address(0), "Warning: This address cannot be zero.");
        ecologicalFund = account;
        _isExcludedFromFee[account] = true;
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

    function addLiquidityRewardAccount(address[] memory accounts) public onlyOperator {
        for(uint256 i = 0; i < accounts.length; i++){
            address account = accounts[i];
            if(!liquidityRewardAccounts[account]){
                liquidityRewardAccounts[account] = true;
                liquidityRewardAccountList.push(account);
            }
        }
    }

    function removeLiquidityRewardAccount(address account) public onlyOperator {

        liquidityRewardAccounts[account] = false;
        for(uint256 i = 0; i < liquidityRewardAccountList.length; i++){
            if(liquidityRewardAccountList[i] == account){
                liquidityRewardAccountList[i] = liquidityRewardAccountList[liquidityRewardAccountList.length - 1];
                liquidityRewardAccountList.pop();
                break;
            }
        }
    }

    function updateOwned(address account, address ref, uint256 level) public onlyStore {
        require(account != address(0), "Warning: Can not be a zero");

        if(level == 1){
            require(communityPartnerCount <= COMMUNITY_PARTNER_LIMIT, "Warning: The number of recruits has reached the upper limit.");
            communityPartnerList.push(account);
            communityPartnerCount += 1;

            _owned[account].level = level;
        }

        if(level == 2){
            require(superPartnerCount <= SUPER_PARTNER_LIMIT, "Warning: The number of recruits has reached the upper limit.");
            superPartnerList.push(account);
            superPartnerCount += 1;

            _owned[account].level = level;
        }

        if(_owned[account].referrer == address(0)){
            _owned[account].referrer = ref;
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

    function getStore(address account) external view returns (bool){
        return stores[account];
    }
    
    function getOperator(address account) external view returns (bool){
        return operators[account];
    }

    function getOwend(address account) external view returns (Owned memory) {
        return _owned[account];
    }

    function getRefByOwend(address account) external view returns (address) {
        return _owned[account].referrer;
    }
    
    function getAllSuperPartners() public view returns(address[] memory){
        return superPartnerList;
    }

    function getAllCommunityPartners() public view returns(address[] memory){
        return communityPartnerList;
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

    function getLiquidityRewardAccount(address account) public view returns(bool) {
        return liquidityRewardAccounts[account];
    }

    function getAllLiquidityRewardAccount() public view returns(address[] memory) {
        return liquidityRewardAccountList;
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

        if(!_owned[to].active){
            _owned[to].active = true;
            ownedList.push(to);
        }

        if (!takeFee) _restoreAllFee();
    }

    function _transferStandard(address sender, address recipient, uint256 amount) private {
        (uint256 amountAfterTax, uint256 tax) = _getTxValues(amount);
        
        _owned[sender].balanceOf = _owned[sender].balanceOf.sub(amount, "sub1 amount");
        _owned[recipient].balanceOf = _owned[recipient].balanceOf.add(amountAfterTax);

        if (amount >= DIVIDING && _owned[recipient].lockRef == false){
            _owned[recipient].referrer = sender;
            _owned[recipient].lockRef = true;
        }
        
        emit Transfer(sender, recipient, amountAfterTax);
        
        if (_feeIt) {

            if(sender == pancakeSwapRouter) {

                uint256 blackholeAmount = ((tax * _feeShareByBlackhole) / 100);
                uint256 atferBlackholeDestruction = _blackholeMechanism(blackholeAmount);
                _owned[ecologicalFund].balanceOf = _owned[ecologicalFund].balanceOf.add(atferBlackholeDestruction);

                uint256 marketRewardAmount = ((tax * _feeShareByMarketReward) / 100);
                uint256 atferMarketRewardAmount = _rewardReferrers(recipient, marketRewardAmount);
                _owned[ecologicalFund].balanceOf = _owned[ecologicalFund].balanceOf.add(atferMarketRewardAmount);

            } else {
                uint256 ecologicalFundAmount = 0;

                // blackhole
                uint256 blackholeAmount = ((tax * _feeShareByBlackhole) / 100);
                uint256 atferBlackholeDestruction = _blackholeMechanism(blackholeAmount);
                ecologicalFundAmount += atferBlackholeDestruction;

                // superPartner
                uint256 superPartnerAmount = ((tax * _feeShareBySuperPartner) / 100);
                uint256 atferSuperPartnerDividend = _superPartnerDividend(superPartnerAmount);
                ecologicalFundAmount += atferSuperPartnerDividend;

                // community
                uint256 communityPartnerAmount = ((tax * _feeShareByCommunityPartner) / 100);
                uint256 atferCommunityPartnerDividend = _communityPartnerDividend(communityPartnerAmount);
                ecologicalFundAmount += atferCommunityPartnerDividend;

                // owend
                uint256 owendAmount = ((tax * _feeShareByOwned) / 100);
                uint256 atferOwendDividend = _ownedDividend(owendAmount);
                ecologicalFundAmount += atferOwendDividend;

                // LPS
                uint256 lpsAmount = ((tax * _feeShareByLps) / 100);
                uint256 atferLpsDividend = _lpsDividend(lpsAmount);
                ecologicalFundAmount += atferLpsDividend;

                // ecologicalFund
                ecologicalFundAmount += ((tax * _feeShareByEcologicalFund) / 100);
                _owned[ecologicalFund].balanceOf = _owned[ecologicalFund].balanceOf.add(ecologicalFundAmount);
            }
        }
    }

    function _rewardReferrers(address account, uint256 amount) internal returns(uint256 amountAfterDeduction){

        uint256 refReward;
        address currentAccount = account;
        amountAfterDeduction = amount;

        for(uint256 i = 0; i < marketRewardPercents.length; i++){
            address ref = _owned[currentAccount].referrer;
            if(ref == address(0)){
                break;
            }

            if(_checkIterationCount(ref) < i.add(1)) {
                continue;
            }

            refReward = ((amount * marketRewardPercents[i]) / 100);
            _owned[ref].balanceOf += refReward;

            currentAccount = ref;
            amountAfterDeduction = amount - refReward;
        }

        return amountAfterDeduction;
    }

    function _checkIterationCount(address ref) internal view returns (uint256 i) {

        if(_owned[ref].balanceOf >= 100 * 10**18){
            if(_owned[ref].balanceOf >= 1000 * 10**18){
                if(_owned[ref].balanceOf >= 10000 * 10**18){
                    if(_owned[ref].balanceOf >= 100000  * 10**18){
                        return 8;
                    } else {
                        return 6;
                    }
                } else {
                    return 4;
                }
            } else {
                return 2;
            }
        } else {
            return 0;
        }
    }

    function _getTxValues(uint256 amount) private view returns (uint256 amountAfterTax, uint256 tax){
        
        if (!_feeIt) {
            return (amount, 0);
        }
        
        tax = ((amount * _tax) / 100); 
        amountAfterTax = amount - tax;
    }

    function _blackholeMechanism(uint256 amount) internal returns (uint256 atferBlackholeDestruction){
        atferBlackholeDestruction = amount;
        uint256 blackholeBalanceOf = _owned[blackhole].balanceOf;
        
        if(blackholeBalanceOf <= blackholeLimit){
            uint256 destructionAmount = ((atferBlackholeDestruction * _feeShareByBlackhole) / 100);

            if((blackholeBalanceOf + destructionAmount) <= blackholeLimit){
                _owned[blackhole].balanceOf += destructionAmount;
                atferBlackholeDestruction -= destructionAmount;
                return atferBlackholeDestruction;
            } else {
                destructionAmount = ((blackholeBalanceOf + destructionAmount) - blackholeLimit);
                _owned[blackhole].balanceOf += destructionAmount;
                atferBlackholeDestruction -= destructionAmount;
                return atferBlackholeDestruction;
            }
        }

        return atferBlackholeDestruction;
    }

    function _superPartnerDividend(uint256 amount) internal returns(uint256 unallocateAmount){

        uint256 allocateAmount = 0;
        if(superPartnerList.length > 0 && amount > 0){
            uint256 avgAmount = amount/superPartnerList.length;
            for(uint256 i = 0; i < superPartnerList.length; i++){
                _owned[superPartnerList[i]].balanceOf = _owned[superPartnerList[i]].balanceOf.add(avgAmount);
                allocateAmount += avgAmount;
            }
        }

        unallocateAmount = amount - allocateAmount;

        return unallocateAmount;
    }

    function _communityPartnerDividend(uint256 amount) internal returns(uint256 unallocateAmount){

        uint256 allocateAmount = 0;
        if(communityPartnerList.length > 0 && amount > 0){
            uint256 avgAmount = amount/communityPartnerList.length;
            for(uint256 i = 0; i < communityPartnerList.length; i++){
                _owned[communityPartnerList[i]].balanceOf = _owned[communityPartnerList[i]].balanceOf.add(avgAmount);
                allocateAmount += avgAmount;
            }
        }

        unallocateAmount = amount - allocateAmount;

        return unallocateAmount;
    }

    function _ownedDividend(uint256 amount) internal returns(uint256 unallocateAmount){

        uint256 allocateAmount = 0;
        if(ownedList.length > 0 && amount > 0){
            uint256 avgAmount = amount/ownedList.length;

            for(uint256 i = 0; i < ownedList.length; i++){
                _owned[ownedList[i]].balanceOf = _owned[ownedList[i]].balanceOf.add(avgAmount);
                allocateAmount += avgAmount;
            }
        }

        unallocateAmount = amount - allocateAmount;

        return unallocateAmount;
    }

    // liquidity Reward Account
    function _lpsDividend(uint256 amount) internal returns(uint256 unallocateAmount){

        uint256 allocateAmount = 0;
        if(liquidityRewardAccountList.length > 0 && amount > 0){
            uint256 avgAmount = amount/liquidityRewardAccountList.length;

            for(uint256 i = 0; i < liquidityRewardAccountList.length; i++){
                _owned[liquidityRewardAccountList[i]].balanceOf = _owned[liquidityRewardAccountList[i]].balanceOf.add(avgAmount);
                allocateAmount += avgAmount;
            }
        }

        unallocateAmount = amount - allocateAmount;

        return unallocateAmount;
    }

}