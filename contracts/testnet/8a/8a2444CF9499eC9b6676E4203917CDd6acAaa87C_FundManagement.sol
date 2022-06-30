/**
 *Submitted for verification at BscScan.com on 2022-06-29
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0 ;

interface IERC20 {
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address _spender, uint256 _value) external returns (bool);
    function burn(uint256 amount) external returns (bool);
}

interface IFile {
    function queryStrAddr(string memory _str) external view returns (address);
}

interface IMerchantSales {
    function updateRecommender(address _sender, uint256 _recommenderId) external returns(bool);
}

interface Router {
     function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (
        uint256[] memory amounts
    );
}

interface IFundManagement {
    function addLianchuangAccount(address[] calldata _addrs, uint256[] calldata _recommenderIds) external;
    function addLianchuangWhitelist(address[] calldata _addrs, uint256[] calldata _recommenderIds) external;
    function buyLianchuangAccount() external;
    function buyLianchuangWhitelist() external;
    function skillfulnessWithdrawFee() external;
    function recordHandlingFee(uint256 fee) external returns (bool);
    function updateComputingPower(address _addr, uint256 _amount) external returns(bool);
    function withdrawtoken(uint256 _type) external;
    function lianchuangWithdrawFee(uint256 _day, uint256 _type) external;
}

abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

contract Ownable is Initializable{
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the management contract as the initial owner.
     */
    function __Ownable_init_unchained() internal initializer {
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
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
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
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract FundManagement  is Initializable,Ownable,IFundManagement {
    using SafeMath for uint256;
    uint256 public threeDays;
    uint256 public communityFund;
    uint256 public technologyFund;
    uint256 public lianchuangAccountFund;
    uint256 public lianchuangWhitelistFund;
    uint256 public lianchuangAccountNum;
    uint256 public lianchuangWhitelistNum;
    uint256 public lianchuangAccountPrice;
    uint256 public lianchuangWhitelistPrice;
    uint256 public unlockTime;
    IFile public file;
    IERC20 public cmmToken;
    IERC20 public usdtToken;
    Router public routerContract;
    IMerchantSales public merchantSalesContract;
    Data lianchuangAccount;  
    Data lianchuangWhitelist; 
    mapping(address => WithdrawData) communityFundWithdraw;
    mapping(address => WithdrawData) technologyFundWithdraw;
    mapping(address => WithdrawData) lianchuangAccountWithdraw;
    mapping(address => WithdrawData) lianchuangWhitelistWithdraw;
    uint256 public stageNum;
    uint256 public startStage;
    mapping(uint256 => uint256) public stageAccountFee;
    mapping(uint256 => uint256) public stageWhitelistFee;
    mapping(uint256 => ComputingPowerData) computingPowerData;
    mapping(uint256 => ComputingPowerWhitelistData) computingPowerWhitelistData;
    mapping(address => WithdrawFee) withdrawAccountFee;
    mapping(address => WithdrawFee) withdrawWhitelistFee;
    mapping(address => uint256) withdrawSkillfulnessFee;

    event AddLianchuangAccount(address[] nodeAddrs);
    event DeleteLianchuangAccount(address[] nodeAddrs);
    event AddLianchuangWhitelist(address[] nodeAddrs);
    event DeleteLianchuangWhitelist(address[] nodeAddrs);
    event Withdrawtoken(address _sender, uint256 _type, uint256 _amount);
    event RecordHandlingFee(uint256 fee);
    event AddComputingPower(address addr, uint256 amount);
    event LianchuangWithdrawFee(address addr, uint256 amount);
    
    struct Data {
        uint256 num;                           
        mapping(address => uint256) addrIndex;  
        mapping(uint256 => address) indexAddr;
        mapping(address => bool) addrSta;
    }
    
    struct ComputingPowerData {
        uint256 sum;      
        uint256 lastSum;     
        uint256 averageShare;   
        uint256 num;                        
        mapping(address => uint256) addrIndex;  
        mapping(uint256 => address) indexAddr;                 
        mapping(address => uint256) computingPower; 
    }
    
    struct ComputingPowerWhitelistData {
        uint256 sum;    
        uint256 averageShare;         
        mapping(address => uint256) computingPower; 
    }

    struct WithdrawData {
        uint256 startTime;  
        uint256 withdrawAmount; 
    }

    struct WithdrawFee {
        uint256 withdrawStageNum;
        uint256 withdrawFee;
    }

    modifier onlyMerchantSalesContract() {
        require(msg.sender == address(merchantSalesContract), "FundManagement: Call without permission");
        _;
    }

    modifier onlyCMMToken() {
        require(msg.sender == address(cmmToken), "FundManagement: Call without permission");
        _;
    }

    function init(address _file)  external initializer{
        __Ownable_init_unchained();
        __FundManagement_init_unchained(_file);
    }

    function __FundManagement_init_unchained(address _file) internal initializer{
        require( _file != address(0),"cmmToken address cannot be 0");
        file = IFile(_file);
        address _MerchantSales = file.queryStrAddr("MerchantSales");
        address _CMMToken = file.queryStrAddr("CMMToken");
        address _USDTToken = file.queryStrAddr("USDTToken");
        address _RouterContract = file.queryStrAddr("RouterContract");
        address _CommunityFundAddr = file.queryStrAddr("CommunityFundAddr");
        address _TechnologyFundAddr = file.queryStrAddr("TechnologyFundAddr");
        require(
            _MerchantSales != address(0x0) && 
            _CMMToken != address(0x0) && 
            _USDTToken != address(0x0) && 
            _RouterContract != address(0x0) &&
            _CommunityFundAddr != address(0x0) &&
            _TechnologyFundAddr != address(0x0), 
            "Contract address cannot be empty");
        cmmToken = IERC20(_CMMToken);
        usdtToken = IERC20(_USDTToken);
        routerContract = Router(_RouterContract);
        merchantSalesContract = IMerchantSales(_MerchantSales);
        usdtToken.approve(_RouterContract, type(uint256).max);
        communityFund = 100000000 * 10 ** 18;
        technologyFund = 100000000 * 10 ** 18;
        communityFundWithdraw[_CommunityFundAddr].startTime = block.timestamp;
        technologyFundWithdraw[_TechnologyFundAddr].startTime = block.timestamp;
        lianchuangAccountFund = 300000 * 10 ** 18;
        lianchuangWhitelistFund = 40000 * 10 ** 18;
        lianchuangAccountNum = 200;
        lianchuangWhitelistNum = 1000;
        lianchuangAccountPrice = 1500 * 10 ** 18;
        lianchuangWhitelistPrice = 400 * 10 ** 18;
        unlockTime = 3 days;//30 days;
        threeDays = 10800; //3 days;
        stageNum = 1653580800 / threeDays;// time / threeDays;
        startStage = stageNum;
    }

    receive() payable external{

    }

    fallback() payable external{

    }

    function addLianchuangAccount(address[] calldata _addrs, uint256[] calldata _recommenderIds) override external onlyOwner{
        Data storage _lianchuangAccount = lianchuangAccount;
        _addAddr(_addrs, _lianchuangAccount, 0);
        require( _lianchuangAccount.num <= lianchuangAccountNum,"The quantity cannot exceed the specified quantity");
        for (uint256 i = 0; i< _addrs.length; i++){
            require(merchantSalesContract.updateRecommender(_addrs[i], _recommenderIds[i]),"Error updating referral relationship");
        }
        emit AddLianchuangAccount(_addrs);
    }

    // function deleteLianchuangAccount(address[] calldata _addrs) external onlyOwner{
    //     Data storage _lianchuangAccount = lianchuangAccount;
    //     _deleteAddr(_addrs, _lianchuangAccount);
    //     emit DeleteLianchuangAccount(_addrs);
    // }

    function addLianchuangWhitelist(address[] calldata _addrs, uint256[] calldata _recommenderIds) override external onlyOwner{
        Data storage _lianchuangWhitelist = lianchuangWhitelist;
        _addAddr(_addrs, _lianchuangWhitelist, 1);
        require( _lianchuangWhitelist.num <= lianchuangWhitelistNum,"The quantity cannot exceed the specified quantity");
        for (uint256 i = 0; i< _addrs.length; i++){
            require(merchantSalesContract.updateRecommender(_addrs[i], _recommenderIds[i]),"Error updating referral relationship");
        }
        emit AddLianchuangWhitelist(_addrs);
    }

    // function deleteLianchuangWhitelist(address[] calldata _addrs) external onlyOwner{
    //     Data storage _lianchuangWhitelist = lianchuangWhitelist;
    //     _deleteAddr(_addrs, _lianchuangWhitelist);
    //     emit DeleteLianchuangWhitelist(_addrs);
    // }

    function buyLianchuangAccount() override external{
        require( usdtToken.transferFrom(msg.sender, address(this), lianchuangAccountPrice),"Token transfer failed");
        require( _burnToken(lianchuangAccountPrice),"Token burn failed");
        Data storage _lianchuangAccount = lianchuangAccount;
        address[] memory _addrs = new address[](1);
        _addrs[0] = msg.sender;
        _addAddr(_addrs, _lianchuangAccount, 0);
        require( _lianchuangAccount.num <= lianchuangAccountNum,"The quantity cannot exceed the specified quantity");
        emit AddLianchuangAccount(_addrs);
    }
    
    function buyLianchuangWhitelist() override external{
        require( usdtToken.transferFrom(msg.sender, address(this), lianchuangWhitelistPrice),"Token transfer failed");
        require( _burnToken(lianchuangWhitelistPrice),"Token burn failed");
        Data storage _lianchuangWhitelist = lianchuangWhitelist;
        address[] memory _addrs = new address[](1);
        _addrs[0] = msg.sender;
        _addAddr(_addrs, _lianchuangWhitelist, 1);
        require( _lianchuangWhitelist.num <= lianchuangWhitelistNum,"The quantity cannot exceed the specified quantity");
        emit AddLianchuangWhitelist(_addrs);
    }

    function recordHandlingFee(uint256 fee) override  external returns (bool) {//onlyCMMToken()
        uint256 _stage = block.timestamp.div(threeDays);
        uint256 _whitelistfee = fee.div(5);
        uint256 _accountfee = _whitelistfee.mul(2);
        uint256 _skillfulnessfee = fee.sub(_whitelistfee).sub(_accountfee);
        address _SkillfulnessAddr = file.queryStrAddr("SkillfulnessAddr");
        if(_SkillfulnessAddr == address(0x0)) _SkillfulnessAddr = owner();
        withdrawSkillfulnessFee[_SkillfulnessAddr] = withdrawSkillfulnessFee[_SkillfulnessAddr].add(_skillfulnessfee);
        stageAccountFee[_stage] = stageAccountFee[_stage].add(_accountfee);
        stageWhitelistFee[_stage] = stageWhitelistFee[_stage].add(_whitelistfee);
        uint256 _stageNum = stageNum;
        if(_stage > _stageNum){
            ComputingPowerData storage _computingPowerData;
            ComputingPowerWhitelistData storage _computingPowerWhitelistData;
            uint256 i = _stageNum;
            for (i; i< _stage; i++){
                uint256 amount = stageAccountFee[i];
                if(amount > 0){
                    _computingPowerData = computingPowerData[i];
                    if(_computingPowerData.sum == 0){
                        stageAccountFee[i] = 0;
                        stageAccountFee[i+1] = stageAccountFee[i+1].add(amount);
                    }else{
                        uint256 lastSum;
                        uint256 start = 191;
                        uint256 end = 200;
                        if(end > _computingPowerData.num){
                            end = _computingPowerData.num;
                        }
                        for (start; start <= end; start++){
                            address addr = _computingPowerData.indexAddr[start];
                            lastSum = lastSum.add(_computingPowerData.computingPower[addr]);
                        }
                        _computingPowerData.lastSum = lastSum;
                        _computingPowerData.averageShare = amount.div(_computingPowerData.sum.sub(lastSum));
                    }
                }

                amount = stageWhitelistFee[i];
                if(amount > 0){
                    _computingPowerWhitelistData = computingPowerWhitelistData[i];
                    if(_computingPowerWhitelistData.sum == 0){
                        stageWhitelistFee[i] = 0;
                        stageWhitelistFee[i+1] = stageWhitelistFee[i+1].add(amount);
                    }else{
                        _computingPowerWhitelistData.averageShare = amount.div(_computingPowerWhitelistData.sum);
                    }
                }
            }
            stageNum = i;
        }
        emit RecordHandlingFee(fee);
        return true;
    }

    function updateComputingPower(address _addr, uint256 _amount) override  external returns(bool){//onlyMerchantSalesContract()
        uint256 index = lianchuangAccount.addrIndex[_addr];
        if(index > 0){
            addComputingPower(_addr, _amount);
        }
        index = lianchuangWhitelist.addrIndex[_addr];
        if(index > 0){
            addWhitelistComputingPower(_addr, _amount);
        }
        return true;
    }

    function addWhitelistComputingPower(address _addr, uint256 _amount) internal {
        uint256 _stage = block.timestamp.div(threeDays);
        ComputingPowerWhitelistData storage _computingPowerWhitelistData = computingPowerWhitelistData[_stage];
        _computingPowerWhitelistData.computingPower[_addr] = _computingPowerWhitelistData.computingPower[_addr].add(_amount);
        _computingPowerWhitelistData.sum = _computingPowerWhitelistData.sum.add(_amount);
    }

    function addComputingPower(address _addr, uint256 _amount) internal {
        uint256 _stage = block.timestamp.div(threeDays);
        ComputingPowerData storage _computingPowerData = computingPowerData[_stage];
        uint256 _addrIndex = _computingPowerData.addrIndex[_addr];
        if(_addrIndex == 0){
            _addrIndex = ++_computingPowerData.num;
            _computingPowerData.addrIndex[_addr] = _addrIndex;
            _computingPowerData.indexAddr[_addrIndex] = _addr;
        }
        _computingPowerData.computingPower[_addr] = _computingPowerData.computingPower[_addr].add(_amount);
        _computingPowerData.sum = _computingPowerData.sum.add(_amount);
        for (uint256 i = _addrIndex; i > 1; i--) {
            address _currentAddr = _computingPowerData.indexAddr[i];
            uint256 _prefixIndex = i.sub(1);
            address _prefixAddr = _computingPowerData.indexAddr[_prefixIndex];
            uint256 _currentCP = _computingPowerData.computingPower[_currentAddr];
            uint256 _prefixCP = _computingPowerData.computingPower[_prefixAddr];
            if (_currentCP > _prefixCP){
                _computingPowerData.addrIndex[_currentAddr] = _prefixIndex;
                _computingPowerData.addrIndex[_prefixAddr] = i;
                _computingPowerData.indexAddr[_prefixIndex] = _currentAddr;
                _computingPowerData.indexAddr[i] = _prefixAddr;
            }else{
                break;
            }
        }
        emit AddComputingPower(_addr, _amount);
    }

    function lianchuangWithdrawFee(uint256 _day, uint256 _type) override external{
        address _sender = msg.sender;
        WithdrawFee storage _withdrawFee = withdrawAccountFee[_sender];
        (uint256 amount, uint256 num,,) = calcWithdrawFee(_sender, _withdrawFee, _day, _type);
        require(amount > 0,"The amount that can be withdrawn is 0");
        _withdrawFee.withdrawFee = _withdrawFee.withdrawFee.add(amount);
        _withdrawFee.withdrawStageNum = num;
        require(cmmToken.balanceOf(address(this)) >= amount,"Insufficient token balance");
        require(
            cmmToken.transfer(_sender, amount),
            "CmmToken transfer failed"
        );
        emit LianchuangWithdrawFee(_sender, amount);
    }

    function skillfulnessWithdrawFee() override external{
        address _sender = msg.sender;
        uint256 _amount = withdrawSkillfulnessFee[_sender];
        withdrawSkillfulnessFee[_sender] = 0;
        require(_amount > 0,"The amount that can be withdrawn is 0");
        require( cmmToken.transfer(_sender, _amount),"Token transfer failed");
    }

    function querySkillfulnessWithdrawFee(address addr) external view returns (uint256){
        return withdrawSkillfulnessFee[addr];
    }

    function queryWithdrawFee(address addr, uint256 _type) external view returns (uint256, uint256, uint256){
        WithdrawFee storage _withdrawFee = withdrawAccountFee[addr];
        (uint256 _amount,,uint256 _day, uint256 _withdrawNum) = calcWithdrawFee(addr, _withdrawFee, 0, _type);
        return (_amount, _day, _withdrawNum);
    }

    function calcWithdrawFee(
        address _sender, 
        WithdrawFee storage _withdrawFee, 
        uint256 _day,
        uint256 _type
    ) internal view returns (uint256 _amount, uint256 i, uint256 num, uint256 withdrawNum){
        uint256 _calcDay = _day / threeDays;
        uint256 _withdrawStageNum = _withdrawFee.withdrawStageNum;
        if (_withdrawStageNum == 0){
            _withdrawStageNum = startStage;
        }
        if ( _day == 0){
            _calcDay = stageNum;
        }else{
            _calcDay = _withdrawStageNum + _calcDay;
            if(_calcDay > stageNum) _calcDay= stageNum;
        }
        uint256 index;
        i = _withdrawStageNum;
        if(_type == 1){
            ComputingPowerData storage _computingPowerData;
            for(i; i< _calcDay; i++){
                _computingPowerData = computingPowerData[i];
                index = _computingPowerData.addrIndex[_sender];
                if( index >0 && index <191){
                    _amount = _amount.add(_computingPowerData.averageShare.mul(_computingPowerData.computingPower[_sender]));
                }
            }
        }else if (_type == 2){
            ComputingPowerWhitelistData storage _computingPowerWhitelistData;
            for(i; i< _calcDay; i++){
                _computingPowerWhitelistData = computingPowerWhitelistData[i];
                _amount = _amount.add(_computingPowerWhitelistData.averageShare.mul(_computingPowerWhitelistData.computingPower[_sender]));
            }
        }
        num =_calcDay.sub(_withdrawStageNum).mul(threeDays);
        if(_amount ==0) num =0;
        withdrawNum = _withdrawFee.withdrawFee;
    }

    function withdrawtoken(uint256 _type) override external{
        WithdrawData storage _withdrawData;
        uint256 amount;
        address _sender = msg.sender;
        if(_type == 1){
            require(lianchuangAccount.addrIndex[_sender] > 0,"This address is not a Lianchuang address");
            _withdrawData = lianchuangAccountWithdraw[_sender];
            amount = _calcWithdrawAmount(_withdrawData, lianchuangAccountFund);
        } else if(_type == 2) {
            require(lianchuangWhitelist.addrIndex[_sender] > 0,"This address is not a LianchuangWhitelist address");
            _withdrawData = lianchuangWhitelistWithdraw[_sender];
            amount = _calcWithdrawAmount(_withdrawData, lianchuangWhitelistFund);
        } else if(_type == 3) {
            require(communityFundWithdraw[_sender].startTime > 0,"This address is not a communityFund address");
            _withdrawData = communityFundWithdraw[_sender];
            amount = _calcWithdrawAmount(_withdrawData, communityFund);
        }else{
            require(technologyFundWithdraw[_sender].startTime > 0,"This address is not a technologyFund address");
            _withdrawData = technologyFundWithdraw[_sender];
            amount = _calcWithdrawAmount(_withdrawData, technologyFund);
        }
        uint256 withdrawAmount = amount.sub(_withdrawData.withdrawAmount);
        _withdrawData.withdrawAmount = amount;
        require(withdrawAmount > 0,"The amount that can be withdrawn is 0");
        require(cmmToken.balanceOf(address(this)) >= withdrawAmount,"Insufficient token balance");
        require(
            cmmToken.transfer(_sender, withdrawAmount),
            "CmmToken transfer failed"
        );
        emit Withdrawtoken(_sender, _type, withdrawAmount);
    }

    function _burnToken(uint256 _amount) internal returns (bool){
        address[] memory _addrs = new address[](2);
        _addrs[0] = address(usdtToken);
        _addrs[1] = address(cmmToken);
        uint[] memory amounts = routerContract.swapExactTokensForTokens(
                                    _amount, 
                                    0, 
                                    _addrs,
                                    address(this),
                                    block.timestamp+ 3600
                                );
        return cmmToken.burn(amounts[1]);
    }

    function _calcWithdrawAmount(WithdrawData storage _withdrawData, uint256 _award) view internal returns (uint256){
        uint256 time = block.timestamp.sub(_withdrawData.startTime).mul(24).div(unlockTime);
        if(time> 24){
            time = 24;
        }
        return _award.mul(time).div(24);
    }

    function _addAddr(address[] memory _addrs, Data storage _data, uint256 _type) internal{
        for (uint256 i = 0; i< _addrs.length; i++){
            address _addr = _addrs[i];
            if(_type == 0){
                lianchuangAccountWithdraw[_addr].startTime = block.timestamp;
            }else{
                lianchuangWhitelistWithdraw[_addr].startTime = block.timestamp;
            }
            require(!_data.addrSta[_addr], "The address has already been added");
            _data.addrSta[_addr] = true;
            uint256 _addrIndex = _data.addrIndex[_addr];
            if (_addrIndex == 0){
                _addrIndex = ++_data.num;
                _data.addrIndex[_addr] = _addrIndex;
                _data.indexAddr[_addrIndex] = _addr;
            }
        }
    }

    function _deleteAddr(address[] memory _addrs, Data storage _data) internal{
        for (uint256 i = 0; i< _addrs.length; i++){
            address _addr = _addrs[i];
            require(_data.addrSta[_addr], "This address not added");
            _data.addrSta[_addr] = false;
            uint256 _addrIndex = _data.addrIndex[_addr];
            if (_addrIndex > 0){
                uint256 _num = _data.num;
                address _lastAddr = _data.indexAddr[_num];
                _data.addrIndex[_lastAddr] = _addrIndex;
                _data.indexAddr[_addrIndex] = _lastAddr;
                _data.addrIndex[_addr] = 0;
                _data.indexAddr[_num] = address(0x0);
                _data.num--;
            }
        }
    }

    function queryWithdrawtoken(uint256 _type, address _addr) external view returns (bool, uint256, uint256, uint256) {
        WithdrawData storage _withdrawData;
        uint256 sum;
        if(_type == 1){
            if(lianchuangAccount.addrIndex[_addr] == 0){
                return (false, 0, 0, 0);
            }
            _withdrawData = lianchuangAccountWithdraw[_addr];
            sum = lianchuangAccountFund;
        } else if(_type == 2) {
            if(lianchuangWhitelist.addrIndex[_addr] == 0){
                return (false, 0, 0, 0);
            }
            _withdrawData = lianchuangWhitelistWithdraw[_addr];
            sum = lianchuangWhitelistFund;
        } else if(_type == 3) {
            if(communityFundWithdraw[_addr].startTime == 0){
                return (false, 0, 0, 0);
            }
            _withdrawData = communityFundWithdraw[_addr];
            sum = communityFund;
        }else{
            if(technologyFundWithdraw[_addr].startTime == 0){
                return (false, 0, 0, 0);
            }
            _withdrawData = technologyFundWithdraw[_addr];
            sum = technologyFund;
        }
        uint256 amount = _calcWithdrawAmount(_withdrawData, sum);
        uint256 withdrawAmount = amount.sub(_withdrawData.withdrawAmount);    
        return (true, withdrawAmount, _withdrawData.withdrawAmount, sum);
    }

    function queryLianchuangSta(address _lianchuang) external view returns(bool){
        Data storage _lianchuangAccount = lianchuangAccount;
        uint256 _index = _lianchuangAccount.addrIndex[_lianchuang];
        if(_index > 0){
            return true;
        }else{
            return false;
        }
    }

    function queryLianchuangRank(
        uint256 _page,
        uint256 _limit
    )
        external
        view
        returns(
            address[] memory,
            uint256[] memory,
            uint256 
        )
    {   
        uint256 _stage = block.timestamp.div(threeDays);
        ComputingPowerData storage _computingPowerData = computingPowerData[_stage];
        uint256 _num = _computingPowerData.num;
        if (_limit > _num){
            _limit = _num;
        }
        if (_page<2){
            _page = 1;
        }
        _page--;
        uint256 start = _page.mul(_limit);
        uint256 end = start.add(_limit);
        if (end > _num){
            end = _num;
            _limit = end.sub(start);
        }
        address[] memory addrs = new address[](_limit);
        uint256[] memory amounts = new uint256[](_limit);
        uint256 j;
        if (_num > 0){
            for (uint256 i = start; i < end; i++) {
                addrs[j] = _computingPowerData.indexAddr[i+1];
                amounts[j] = _computingPowerData.computingPower[addrs[j]];
                j++;
            }
        }
        return (addrs, amounts, _num);
    }

    function queryLianchuangMsg(
        bool _type,
        uint256 _page,
        uint256 _limit
    )
        external
        view
        returns(
            address[] memory,
            uint256 
        )
    {   
        Data storage _data;  
        if(_type){
            _data = lianchuangAccount;
        }else{
            _data = lianchuangWhitelist;
        }
        (address[] memory addrs, uint256 _num) = _obtainLianchuangMsg(_data, _page, _limit);
        return (addrs, _num);
    }

    function _obtainLianchuangMsg(Data storage _data, uint256 _page, uint256 _limit) internal view returns(address[] memory addrs, uint256 _num){
        _num = _data.num;
        if (_limit > _num){
            _limit = _num;
        }
        if (_page<2){
            _page = 1;
        }
        _page--;
        uint256 start = _page.mul(_limit);
        uint256 end = start.add(_limit);
        if (end > _num){
            end = _num;
            _limit = end.sub(start);
        }
        start = _num - start;
        end = _num - end; 
        addrs = new address[](_limit);
        if (_num > 0){
            uint256 j;
            for (uint256 i = start; i > end; i--) {
                addrs[j] = _data.indexAddr[i];
                j++;
            }
        }
    }
    
    
}
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}