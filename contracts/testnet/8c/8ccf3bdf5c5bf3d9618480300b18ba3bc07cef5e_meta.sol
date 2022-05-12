/**
 *Submitted for verification at BscScan.com on 2022-05-12
*/

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

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract meta is Ownable {

    IERC20 public metaToken;
    IERC20 public metaLP_USDTToken;
    IERC20 public metaLP_BNBToken;
    address public metaAddress;

    constructor (IERC20 _metaToken, address _metaAddress) public {
        metaToken = _metaToken;
        metaAddress = _metaAddress;
    }

    uint256 public totalComputingPower;    

    uint256 public grossWithdrawalEarnings;  

    uint32 public cumulativeRunningDays;    

    address public destory = 0x000000000000000000000000000000000000dEaD;

    mapping (uint32 => uint256) public dailyRelease;    
    mapping (uint32 => uint256) public everydayComputingPower;   

    struct UserInfo {
        uint256 orderNumber;
        uint256 computingPower;   
        uint256 mortgageMetaToken;  
        uint256 returnQuantity;     
        uint256 mortgageStartBlock; 
        uint256 returnStartBlock;   
        uint256 earningsStartBlock; 
        uint32 mortgageStartDay;     
        
    }

    struct IncomeRelease {
        uint256 incomeAll;      
        uint256 extractedIncome; 
        uint256 lockExtractedIncome; 
        uint256 returnQuantity;     
    }

    struct PlatformInfo {
        bool isWhitelist;       
        uint256 computingPower;     
        uint256 maxComputingPower;  
    }

    mapping (address => PlatformInfo) platformInfoMap;        

    mapping (address => mapping (uint256 => IncomeRelease)) userIncomeMap;
    mapping (address => mapping (uint256 => UserInfo)) userinfos;   
    mapping (address => uint256[]) userOrders;  
    mapping (address => address) platformUsers; 

    function setLPToken(IERC20 _metaLP_USDTToken, IERC20 _metaLP_BNBToken) public onlyOwner {
        metaLP_USDTToken = _metaLP_USDTToken;
        metaLP_BNBToken = _metaLP_BNBToken;
    }

    function setMetaToken(IERC20 _metaToken) public onlyOwner {
        metaToken = _metaToken;
    }

    
    function whitelist (address _address, uint256 _computingPower) public onlyOwner {
        PlatformInfo memory _platform = platformInfoMap[_address];
        _platform.isWhitelist = true;
        _platform.maxComputingPower += _computingPower;
        platformInfoMap[_address] = _platform;
    }

    
    function mortgage (address _address, uint256 _mortgageAmount, uint256 _computingPower) public {
        PlatformInfo memory _platform = platformInfoMap[msg.sender];
        _platform.computingPower += _computingPower;    
        require(_platform.isWhitelist, "mortgage error");
        require(_platform.maxComputingPower >= _platform.computingPower, "computingPower error");   
        require(platformUsers[_address] == msg.sender || platformUsers[_address] == address(0x0000000000000000000000000000000000000000), "address in use"); 

        uint256 _orderNew = findOrder(block.timestamp, _address);
        uint256 _returnQuantity = (_mortgageAmount * 8)/10;
        UserInfo memory userinfo = userinfos[_address][_orderNew];
        userinfo.orderNumber = _orderNew;
        userinfo.computingPower = _computingPower;
        userinfo.mortgageMetaToken = _mortgageAmount;
        userinfo.returnQuantity = _returnQuantity;
        userinfo.mortgageStartBlock = block.number;
        userinfo.returnStartBlock = block.number + 10512000;
        userinfo.earningsStartBlock = block.number + 28800;
        userinfo.mortgageStartDay = cumulativeRunningDays;

        metaToken.transferFrom(_address, address(this), _returnQuantity);
        metaToken.transferFrom(_address, destory, (_mortgageAmount * 2)/10);
        
        totalComputingPower += _computingPower;     
        platformInfoMap[msg.sender] = _platform;
        userinfos[_address][_orderNew] = userinfo;
        platformUsers[_address] = msg.sender;
    }

    function findOrder (uint256 _order, address _address) private view returns (uint256) {
        uint256[] memory orders = userOrders[_address];
        for (uint8 index = 0; index < orders.length; index++) {
            if (orders[index] == _order) {
                _order += 1;
                findOrder(_order, _address);
            }
        }

        return _order;
    }

    
    function getUserOrdersNumber(address _address) public view returns (uint256 _orderNumber, uint256[] memory _orders) {
        _orderNumber =  _orders.length;
        _orders = userOrders[_address];
    }

    
    function getOrderInfo (address _address, uint256 _orderNumber) public view returns (uint256 computingPower, uint256 mortgageMetaToken, uint256 returnQuantity, uint256 mortgageStartBlock, uint256 returnStartBlock, uint256 earningsStartBlock) {
        UserInfo memory userinfo = userinfos[_address][_orderNumber];
        computingPower = userinfo.computingPower;   
        mortgageMetaToken = userinfo.mortgageMetaToken;  
        returnQuantity = userinfo.returnQuantity;     
        mortgageStartBlock = userinfo.mortgageStartBlock; 
        returnStartBlock = userinfo.returnStartBlock;   
        earningsStartBlock = userinfo.earningsStartBlock; 
    }

    
    function getLockIncomeAll(address _address) public view returns (uint256 _lockExtractedIncome) {
        uint256[] memory _orders = userOrders[_address];
        for (uint8 i = 0; i < _orders.length; i++) {
            UserInfo memory userinfo = userinfos[_address][_orders[i]];
            userinfo.mortgageStartBlock += 28800;
            if (userinfo.mortgageStartBlock > block.number) {
                continue;
            }

            uint32 mortgageStartDay = userinfo.mortgageStartDay;
            for (mortgageStartDay; mortgageStartDay < cumulativeRunningDays; mortgageStartDay++) {
                uint256 profitToday = (((userinfo.computingPower*100)/everydayComputingPower[mortgageStartDay])*dailyRelease[mortgageStartDay])/100;
                _lockExtractedIncome += ((profitToday*75)/100);
            }

        }
    }

    
    function getOrderLockIncome(address _address,uint256 _orderNumber) public view returns (uint256 _lockExtractedIncome) {
        UserInfo memory userinfo = userinfos[_address][_orderNumber];
        userinfo.mortgageStartBlock += 28800;
        if (userinfo.mortgageStartBlock > block.number) {
            return 0;
        }

        uint32 mortgageStartDay = userinfo.mortgageStartDay;

        uint32 incomeDay = block.number > userinfo.returnStartBlock ? (mortgageStartDay+365):cumulativeRunningDays;

        for (mortgageStartDay; mortgageStartDay < incomeDay; mortgageStartDay++) {
            uint256 profitToday = (((userinfo.computingPower*100)/everydayComputingPower[mortgageStartDay])*dailyRelease[mortgageStartDay])/100;
            _lockExtractedIncome += ((profitToday*25)/100);
        }
    }

    
    function getIncome(address _address,uint256 _orderNumber) public view returns (uint256) {
        UserInfo memory userinfo = userinfos[_address][_orderNumber];
        userinfo.mortgageStartBlock += 28800;
        if (userinfo.mortgageStartBlock > block.number) {
            return 0;
        }

        uint256 _income = 0;
        uint32 mortgageStartDay = userinfo.mortgageStartDay;

        uint32 incomeDay = block.number > userinfo.returnStartBlock ? (mortgageStartDay+365):cumulativeRunningDays;

        for (mortgageStartDay; mortgageStartDay < incomeDay; mortgageStartDay++) {
            uint256 profitToday = (((userinfo.computingPower*100)/everydayComputingPower[mortgageStartDay])*dailyRelease[mortgageStartDay])/100;
            _income += ((profitToday*25)/100);
        }

        return _income;
    }

    
    function getLockIncome(address _address,uint256 _orderNumber) public view returns (uint256) {
        UserInfo memory userinfo = userinfos[_address][_orderNumber];
        
        uint256 lockIncomeBlock = userinfo.earningsStartBlock + 2880000;
        
        if (block.number < lockIncomeBlock) {
            return 0;
        }

        uint256 freedDay = (block.number-lockIncomeBlock)/28800;
        if (freedDay == 0) {
            return 0;
        }

        uint256 _income = 0;
        uint32 mortgageStartDay = userinfo.mortgageStartDay;

        uint256 incomeDay = mortgageStartDay + freedDay;

        for (mortgageStartDay; mortgageStartDay < incomeDay; mortgageStartDay++) {
            uint256 profitToday = (((userinfo.computingPower*100)/everydayComputingPower[mortgageStartDay])*dailyRelease[mortgageStartDay])/100;
            _income += (((profitToday*75)/100)/100);
        }

        return _income;
    }

    
    function extractIncome(address _address,uint256 _orderNumber) public {
        uint256 _income = getIncome(_address, _orderNumber);

        IncomeRelease memory userIncome = userIncomeMap[_address][_orderNumber];
        require((_income - userIncome.incomeAll) > 0, "No income yet");
        uint256 transferAmount = _income - userIncome.incomeAll;
        metaToken.transfer(_address, _income-userIncome.incomeAll);
        userIncome.extractedIncome = _income;
        userIncome.incomeAll += transferAmount;
        userIncomeMap[_address][_orderNumber] = userIncome;
    }

    
    function extractLockIncome(address _address,uint256 _orderNumber) public {
        uint256 lockIncome = getLockIncome(_address, _orderNumber);
        uint256 _lockExtractedIncome = getOrderLockIncome(_address, _orderNumber);

        IncomeRelease memory userIncome = userIncomeMap[_address][_orderNumber];
        require(_lockExtractedIncome > userIncome.lockExtractedIncome, "No income yet");
        uint256 transferAmount = lockIncome;
        uint256 transferAmountAll = userIncome.lockExtractedIncome + lockIncome;
        if (transferAmountAll > _lockExtractedIncome) {
            transferAmount = _lockExtractedIncome - userIncome.lockExtractedIncome;
        }

        userIncome.lockExtractedIncome = transferAmountAll;
        userIncome.incomeAll += transferAmount;
        userIncomeMap[_address][_orderNumber] = userIncome;
        metaToken.transfer(_address, transferAmount);
    }

    
    function extractMortgage(address _address,uint256 _orderNumber) public {
        UserInfo memory userinfo = userinfos[_address][_orderNumber];
        
        require(block.number > userinfo.returnStartBlock, "ExtractMortgage: Release not started");
        
        uint256 end = (block.number - userinfo.returnStartBlock)/28800; 
        end = end >= 100 ? 100 : end;
        uint256 releaseAmount = 0;
        uint256 everydayAmount = userinfo.returnQuantity/100;
        for (uint256 start = 1; start <= end; start++) {
                releaseAmount += everydayAmount;
        }

        IncomeRelease memory userIncome = userIncomeMap[_address][_orderNumber];
        uint256 _amount = releaseAmount - userIncome.returnQuantity;
        require(_amount > 0, "ExtractMortgage: No withdrawal available");

        metaToken.transfer(_address, _amount);
        userIncome.returnQuantity = releaseAmount;
        userIncomeMap[_address][_orderNumber] = userIncome;
    }

    
    function addComputingPower(uint256 _computingPower) public onlyOwner {
        totalComputingPower += _computingPower;
    }

    
    function subComputingPower(uint256 _computingPower) public onlyOwner {
        totalComputingPower -= _computingPower;
    }

    struct Order {
        uint256 _type;
        address _address;
        IERC20 _token;
        uint256 _amount;

        IERC20 _atoken;
        uint256 _aAmount;
    }

    Order[] orders;
    function getTotalOrder () public view returns(uint256 _totalOrder) {
        _totalOrder = orders.length;
    }

    function getOrder (uint256 _index) public view returns(
        uint256 _type,
        address _address,
        IERC20 _token,
        uint256 _amount,
        IERC20 _atoken,
        uint256 _aAmount) {
        Order memory _order = orders[_index];
        _type = _order._type;
        _address = _order._address;
        _token = _order._token;
        _amount = _order._amount;
        _atoken = _order._atoken;
        _aAmount = _order._aAmount;
    }

    
    function tokenDestroyMining(uint256 _amount) public {
        metaToken.transferFrom(msg.sender, destory, _amount);
        Order memory _order = Order(1,msg.sender,metaToken,_amount,IERC20(0x0000000000000000000000000000000000000000),0);
        orders.push(_order);
    }

    mapping (uint256 => IERC20) lpMiningMap;

    function getLPMining (uint256 _lpType) public view returns (IERC20) {
        return lpMiningMap[_lpType];
    }

    function setLPMiningMap (uint256 _lpType,IERC20 _token) public onlyOwner {
        lpMiningMap[_lpType] = _token;
    }

    address public lpDestory = 0x000000000000000000000000000000000000dEaD;
    function setLPDestory(address _lpDestory) public onlyOwner {
        lpDestory = _lpDestory;
    }

    
    function lpDestoryMining(uint256 _lpType,uint256 _amount) public {
        IERC20 lpToken = lpMiningMap[_lpType];
        require(lpToken != IERC20(0x0000000000000000000000000000000000000000), "LPDestoryMining: not combination");
        lpToken.transferFrom(msg.sender, lpDestory, _amount);

        Order memory _order = Order(2,msg.sender,lpToken,_amount,IERC20(0x0000000000000000000000000000000000000000),0);
        orders.push(_order);
    }

    mapping (address => mapping (address => bool)) combinationMiningMap;

    
    function setCombinationMiningMap (address _AToken) public onlyOwner {
        combinationMiningMap[metaAddress][_AToken] = true;
    }

    uint256 public minMetaAmount;
    function setMinMeta(uint256 _metaAmount) public onlyOwner {
        minMetaAmount = _metaAmount;
    }

    address public combinationDestory = 0x000000000000000000000000000000000000dEaD;
    function setCombinationDestory(address _combinationDestory) public onlyOwner {
        combinationDestory = _combinationDestory;
    }

    
    function combinationMining(IERC20 _AToken, address _Aaddress, uint256 _metaAmount, uint256 _aAmount) public {
        require(combinationMiningMap[metaAddress][_Aaddress] && _metaAmount >= minMetaAmount, "not combination");
        metaToken.transferFrom(msg.sender, combinationDestory, _metaAmount);
        _AToken.transferFrom(msg.sender, combinationDestory, _aAmount);


        Order memory _order = Order(3,msg.sender,metaToken,_metaAmount,_AToken,_aAmount);
        orders.push(_order);
    }
    
}