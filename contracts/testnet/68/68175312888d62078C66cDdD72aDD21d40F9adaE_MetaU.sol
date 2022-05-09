/**
 *Submitted for verification at BscScan.com on 2022-05-09
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

contract MetaU is Context, Ownable, IERC20 {
    
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
    
    string public name = "Meta U";
    string public symbol = "MU";
    uint256 public decimals = 18;

    uint256 public minCirculation;
    uint256 public blackholeLimit;
    uint256 override public totalSupply = 2100 * 10**8 * 10**18;

    bool private _feeIt = true;
    uint256 private _tax = 8;

    address public blackhole;
    uint256 private _feeShareByBlackhole = 20;
    
    address public marketRewardPool;
    uint256 private _feeShareByMarketReward = 80;

    // lps reward
    address public lpsRewardPool;
    uint256 private _feeShareByLps = 30;

    // owned reward
    address public ownedRewardPool;
    uint256 private _feeShareByOwned = 20;

    // super partner reward
    address public superPartnerRewardPool;
    uint256 private _feeShareBySuperPartner = 10;

    // community partner reward
    address public communityPartnerRewardPool;
    uint256 private _feeShareByCommunityPartner = 10;

    // ecologicalFund reward
    address public ecologicalFundRewardPool;
    uint256 private _feeShareByEcologicalFund = 10;

    // sales channel
    address[] private salesChannelList;
    mapping(address => bool) private salesChannel;

    // super partner limit
    uint256 public superPartnerCount;
    uint256 public superPartnerLimit;
    address[] private superPartnerList;

    // Community partner limit
    uint256 public communityPartnerCount;
    uint256 public communityPartnerLimit;
    address[] private communityPartnerList;

    uint256 private enterCount = 0;
    uint256 private constant DIVIDING = 100 * 10**18;

    mapping(address => bool) private stores;
    mapping(address => bool) private operators;

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
        enterCount += 1;
        _;
        enterCount -= 1;
    }

    // event

    event BlackholeDestruction(uint256 destructionAmount);
    event RewardCommunityPartner(address indexed pool, uint256 amount);
    event RewardEcologicalFund(address indexed pool, uint256 amount);
    event RewardLps(address indexed pool, uint256 amount);
    event RewardMarket(address indexed pool, uint256 amount);
    event RewardOwend(address indexed pool, uint256 amount);
    event RewardSuperPartner(address indexed pool, uint256 amount);
    
    // constructor
    constructor() {

        _owned[_msgSender()].balanceOf = totalSupply;

        operators[_msgSender()] = true;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        superPartnerLimit = 19;
        communityPartnerLimit = 199;
        blackhole = 0x0000000000000000000000000000000000000001;

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
    
    function setMinCirculation(uint256 _amount) external onlyOperator {
        require(_amount > 0 , "Warning: This amount must be greater than zero.");
        require(totalSupply - _amount >= _owned[blackhole].balanceOf, "Warning: overflow.");

        minCirculation = _amount;
        blackholeLimit = totalSupply - minCirculation;
    }

    function setBlackhole(address _blackhole) external onlyOperator {
        require(_blackhole != address(0), "Warning: This address cannot be zero.");
        blackhole = _blackhole;
        _owned[blackhole].lockRef = true;
    }
 
    function setMarketRewardPool(address _address) external onlyOperator {
        require(_address != address(0), "Warning: This address cannot be zero.");

        marketRewardPool = _address;
        _isExcludedFromFee[_address] = true;
    }

    function setLpsRewardPool(address _address) external onlyOperator {
        require(_address != address(0), "Warning: This address cannot be zero.");

        lpsRewardPool = _address;
        _isExcludedFromFee[_address] = true;
    }

    function setOwnedRewardPool(address _address) external onlyOperator {
        require(_address != address(0), "Warning: This address cannot be zero.");

        ownedRewardPool = _address;
        _isExcludedFromFee[_address] = true;
    }

    function setSuperPartnerRewardPool(address _address) external onlyOperator {
        require(_address != address(0), "Warning: This address cannot be zero.");

        superPartnerRewardPool = _address;
        _isExcludedFromFee[_address] = true;
    }

    function setCommunityPartnerRewardPool(address _address) external onlyOperator {
        require(_address != address(0), "Warning: This address cannot be zero.");

        communityPartnerRewardPool = _address;
        _isExcludedFromFee[_address] = true;
    }

    function setEcologicalFundRewardPool(address _address) external onlyOperator {
        require(_address != address(0), "Warning: This address cannot be zero.");

        ecologicalFundRewardPool = _address;
        _isExcludedFromFee[_address] = true;
    }

    function addSalesChannel(address _address) external onlyOperator {
        require(_address != address(0), "Warning: This address cannot be zero.");
        require(!salesChannel[_address], "Warning: This address already exists.");

        salesChannel[_address] = true;
        salesChannelList.push(_address);
        _isExcludedFromFee[_address] = true;
    }

    function removeSalesChannel(address _address) external onlyOperator {
        require(_address != address(0), "Warning: This address cannot be zero.");
        require(salesChannel[_address], "Warning: This address does not exist.");

        salesChannel[_address] = false;
        _isExcludedFromFee[_address] = false;

       for (uint256 i = 0; i < salesChannelList.length; i++) {
            if (salesChannelList[i] == _address) {
                salesChannelList[i] = salesChannelList[salesChannelList.length - 1];
                salesChannelList.pop();
                break;
            }
        }

    }

    function setSuperPartnerLimit(uint256 _upperLimit) external onlyOperator {
        require(_upperLimit > superPartnerCount, "Warning: The upper limit must be greater than the existing quantity.");
        superPartnerLimit = _upperLimit;
    }

    function setCommunityPartnerLimit(uint256 _upperLimit) external onlyOperator {
        require(_upperLimit > communityPartnerCount, "Warning: The upper limit must be greater than the existing quantity.");
        communityPartnerLimit = _upperLimit;
    }

    function excludeFromReward(address account) external onlyOperator {
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
    
    function excludeFromFee(address account) external onlyOperator {
        _isExcludedFromFee[account] = true;
        _excludedFromFeeList.push(account);
    }

    function includeInFee(address account) external onlyOperator {
        _isExcludedFromFee[account] = false;
        
        for (uint256 i = 0; i < _excludedFromFeeList.length; i++) {
            if (_excludedFromFeeList[i] == account) {
                _excludedFromFeeList[i] = _excludedFromFeeList[_excludedFromFeeList.length - 1];
                _excludedFromFeeList.pop();
                break;
            }
        }
    }

    // add owner
    function addOwner(address _account, address _ref, uint256 _level, bool _lockRef) external onlyOperator {
        require(_account != address(0), "Warning: This address cannot be zero.");
        require(!_owned[_account].active, "Warning: This address already exists.");

        _owned[_account] = Owned({
                balanceOf: 0,
                level: _level,
                referrer: _ref,
                lockRef: _lockRef,
                active: true
            });
            
        ownedList.push(_account);
    }

    // update owned level by operator
    function updateOwnedByOperator(address _address, uint256 _level) external onlyOperator {
        require(_address != address(0), "Warning: This address cannot be zero.");
        require(_owned[_address].active, "Warning: This address does not exist.");

        if(_level == 1){
            require(communityPartnerCount <= communityPartnerLimit, "Warning: The number of recruits has reached the upper limit.");
            communityPartnerList.push(_address);
            communityPartnerCount += 1;

            _owned[_address].level = _level;
        }

        if(_level == 2){
            require(superPartnerCount <= superPartnerLimit, "Warning: The number of recruits has reached the upper limit.");
            superPartnerList.push(_address);
            superPartnerCount += 1;

            _owned[_address].level = _level;
        }

    }

    // update owned by store
    function updateOwned(address account, address ref, uint256 level) external onlyStore {
        require(account != address(0), "Warning: Can not be a zero");

        if(level == 1){
            require(communityPartnerCount <= communityPartnerLimit, "Warning: The number of recruits has reached the upper limit.");
            communityPartnerList.push(account);
            communityPartnerCount += 1;

            _owned[account].level = level;
        }

        if(level == 2){
            require(superPartnerCount <= superPartnerLimit, "Warning: The number of recruits has reached the upper limit.");
            superPartnerList.push(account);
            superPartnerCount += 1;

            _owned[account].level = level;
        }

        if(_owned[account].referrer == address(0)){
            _owned[account].referrer = ref;
        }

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
    
    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcludedFromReward[account];
    }
    
    function getExcludedFromRewardList() external view returns(address[] memory) {
        return _excludedFromRewardList;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }
    
    function getExcludedFromFeeList() external view returns(address[] memory) {
        return _excludedFromFeeList;
    }

    function getOwendByPaging(uint256 _startPage, uint256 _endPage) public view returns(address[100] memory results) {
        require(_endPage > _startPage, "Warning: The end page needs to be larger than the start page.");
        require(_startPage > ownedList.length, "Warning: The start page needs to be larger than the list length.");
        require(_endPage - _startPage <= 100, "Warning: Up to 100 results.");

        if(ownedList.length < _endPage){
            _endPage = ownedList.length;
        }

        for(uint256 i = _startPage; i <= _endPage; i++){
            results[i] = ownedList[i];
        }

        return results;
    }

    function getSalesChannel(address _address) external view returns (bool) {
        return salesChannel[_address];
    }

    function getAllSalesChannel() external view returns (address[] memory) {
        return salesChannelList;
    }

    function getAllSuperPartners() external view returns(address[] memory) {
        return superPartnerList;
    }

    function getSuperPartnersLength() external view returns(uint256) {
        return superPartnerList.length;
    }

    function getAllCommunityPartners() external view returns(address[] memory) {
        return communityPartnerList;
    }

    function getCommunityPartnersLength() external view returns(uint256) {
        return communityPartnerList.length;
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
        _approve(sender, _msgSender(), (_allowances[sender][_msgSender()] - amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool){
        _approve(_msgSender(), spender, (_allowances[_msgSender()][spender] + addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool){
        _approve(_msgSender(), spender, (_allowances[_msgSender()][spender] - subtractedValue));
        return true;
    }
    
    // private

    function _approve(address owner, address spender, uint256 amount) private {
        
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _removeAllFee() private {
        if (!_feeIt) return;
        _feeIt = false;
    }

    function _restoreAllFee() private {
        _feeIt = true;
    }

    function _transfer(address from, address to, uint256 amount) private transferCounter {
        require(from != address(0), "ERC20: transfer from the zero address.");
        require(to != address(0), "ERC20: transfer to the zero address.");
        require(amount > 0, "Warning: Transfer amount must be greater than zero.");

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

        // calculate after-tax amount
        (uint256 amountAfterTax, uint256 tax) = _getTxValues(amount);
        
        // update balance
        _owned[sender].balanceOf -= amount;
        _owned[recipient].balanceOf += amountAfterTax;

        // lock the referrer, when the transfer amount is greater than 100
        if (amount >= DIVIDING && _owned[recipient].lockRef == false){
            _owned[recipient].referrer = sender;
            _owned[recipient].lockRef = true;
        }
        
        emit Transfer(sender, recipient, amountAfterTax);
        
        // calculate tax share
        if (_feeIt) {

            if(salesChannel[sender]) {
                
                // blackhole destruction
                uint256 blackholeAmount = ((tax * _feeShareByBlackhole) / 100);
                uint256 atferBlackholeDestruction = _blackholeMechanism(blackholeAmount);

                if(atferBlackholeDestruction > 0){
                    _owned[ecologicalFundRewardPool].balanceOf += atferBlackholeDestruction;
                    emit RewardEcologicalFund(ecologicalFundRewardPool, atferBlackholeDestruction);
                }
                
                // reward market
                uint256 marketRewardAmount = ((tax * _feeShareByMarketReward) / 100);
                _owned[marketRewardPool].balanceOf += marketRewardAmount;
                emit RewardMarket(marketRewardPool, marketRewardAmount);
                

            } else {

                // blackhole destruction
                uint256 blackholeAmount = ((tax * _feeShareByBlackhole) / 100);
                uint256 atferBlackholeDestruction = _blackholeMechanism(blackholeAmount);

                if(atferBlackholeDestruction > 0){
                    _owned[ecologicalFundRewardPool].balanceOf += atferBlackholeDestruction;
                    emit RewardEcologicalFund(ecologicalFundRewardPool, atferBlackholeDestruction);
                }

                // super
                uint256 superPartnerAmount = ((tax * _feeShareBySuperPartner) / 100);
                _owned[superPartnerRewardPool].balanceOf += superPartnerAmount;
                emit RewardSuperPartner(superPartnerRewardPool, superPartnerAmount);

                // community
                uint256 communityPartnerAmount = ((tax * _feeShareByCommunityPartner) / 100);
                _owned[communityPartnerRewardPool].balanceOf += communityPartnerAmount;
                emit RewardCommunityPartner(communityPartnerRewardPool, communityPartnerAmount);

                // owend
                uint256 owendAmount = ((tax * _feeShareByOwned) / 100);
                _owned[ownedRewardPool].balanceOf += owendAmount;
                emit RewardOwend(ownedRewardPool, owendAmount);

                // LPS
                uint256 lpsAmount = ((tax * _feeShareByLps) / 100);
                _owned[lpsRewardPool].balanceOf += lpsAmount;
                emit RewardLps(lpsRewardPool, lpsAmount);

                // ecologicalFund
                uint256 ecologicalFundAmount = ((tax * _feeShareByEcologicalFund) / 100);
                _owned[ecologicalFundRewardPool].balanceOf += ecologicalFundAmount;
                emit RewardEcologicalFund(ecologicalFundRewardPool, ecologicalFundAmount);
            }
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
        
        uint256 blackholeBalanceOf = _owned[blackhole].balanceOf;
        
        if(blackholeBalanceOf < blackholeLimit){
            if((blackholeBalanceOf + amount) <= blackholeLimit){
                _owned[blackhole].balanceOf += amount;
                emit BlackholeDestruction(amount);

                atferBlackholeDestruction = 0;
                return atferBlackholeDestruction;
            } else {
                uint256 maxDestructionAmount = blackholeLimit - blackholeBalanceOf;
                _owned[blackhole].balanceOf += maxDestructionAmount;
                emit BlackholeDestruction(maxDestructionAmount);

                atferBlackholeDestruction = amount - maxDestructionAmount;
                return atferBlackholeDestruction;
            }
        } else {
            atferBlackholeDestruction = amount;
        }

        return atferBlackholeDestruction;
    }

}