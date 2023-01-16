/**
 *Submitted for verification at BscScan.com on 2023-01-16
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract Ownable {
    address _owner;

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _owner = msg.sender;
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
        require(_owner == msg.sender , "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _owner = newOwner;
    }
}

interface MerchantInterface {
    function getPledgeStatus(address _address) external view returns(bool);

    function merchantApealPledge(uint _orderNo, uint _delegationNo, address _userAddr,address _merchantAddr,uint _coinCount) external;

    function userAppealPledge(uint _orderNo, uint _delegationNo, address _userAddr,address _merchantAddr,uint _coinCount) external;

    function handleAppealPledge(uint _orderNo, uint _result, uint appeal_type) external;

     function drawAppealPledge(uint _orderNo) external;
}

interface RecordInterface {
    function callMerchantRecord(address userAddr,uint coinCount) external;
}

contract DelegationOrder is Ownable {
    using SafeMath for uint256;
    address public usdtAddress;

    struct DelegationInfo {//委托单
        uint delegationNo; //单号
        address userAddr;
        uint totalCount; //总数量
        uint remainderCount; //剩余数量
        string pay_type; //支付类型
        uint max_money; //最大金额
        uint min_money; //最小金额
        uint price; //单价
        uint itype; //1买单,2卖单
        uint status; //1启用,0不起用2已撤销3已完成
        uint undoneOrderCount; //未完成的订单数量
        string terms; //交易条款
        //string legal_currency_name; //法币名称
        uint create_time;
        uint update_time;
    }

    mapping(uint256 => DelegationInfo) public records; //delegationNo ==> DelegationInfo
    mapping(uint256 => uint256) public recordIndex;
    DelegationInfo[] public recordList;    

    event RecordAdd(
        uint delegationNo, //单号
        address userAddr,
        uint total_money, //总数量
        string pay_type, //支付类型
        uint max_money, //最大金额
        uint min_money, //最小金额
        uint price, //单价
        uint itype, //1买单,2卖单
        string terms, //交易条款
        uint create_time
    );    

    event RecordUpdate(
        uint delegationNo, //单号
        address userAddr,
        uint total_money, //总数量
        string pay_type, //支付类型
        uint max_money, //最大金额
        uint min_money, //最小金额
        uint price, //单价
        uint itype, //1买单,2卖单
        string terms, //交易条款
        uint update_time
    );
    constructor() {
        usdtAddress = address(0x55d398326f99059fF775485246999027B3197955);
    }

    address _merchantAddr; 
    address _OrderAddr;
    address _recordAddr;

    function authFromContract(
        address __merchantAddr,
        address _orderAddr,
        address __recordAddr
    ) external onlyOwner {
        _merchantAddr = __merchantAddr;
        _OrderAddr = _orderAddr;    
        _recordAddr = __recordAddr;      
    }

    modifier onlyAuthFromOrderAddr() {
        require(_OrderAddr == msg.sender, "Invalid contract address");
        _;
    }

    function addBuyDelegation(
        uint _delegationNo,
        uint _total_money,
        string memory _pay_type,
        uint _max_money,
        uint _min_money,
        uint _price,
        string memory _terms     
    ) external payable{
        require(MerchantInterface(_merchantAddr).getPledgeStatus(msg.sender), 
            "Please become a merchant first");
        
        require(records[_delegationNo].delegationNo == uint256(0), "order exist");

        _payFee("addBuyDelegation");

        DelegationInfo memory _record = DelegationInfo({
            delegationNo: _delegationNo,
            userAddr: msg.sender,
            totalCount: _total_money,
            remainderCount: _total_money,
            pay_type: _pay_type,
            max_money: _max_money,
            min_money: _min_money,
            price: _price,
            itype: 1,
            status: 1,
            undoneOrderCount: 0,
            terms: _terms,
            create_time: block.timestamp,
            update_time: 0
        });

        records[_delegationNo] = _record;

        recordList.push(_record);
        recordIndex[_delegationNo] = recordList.length - 1;  
        emit RecordAdd(
            _delegationNo,
            msg.sender,
            _total_money,
            _pay_type, 
            _max_money, 
            _min_money, 
            _price,
            1, 
            _terms,
            block.timestamp
        );
    }

   function addSellDelegation(
        uint _delegationNo,
        uint _total_money,
        string memory _pay_type,
        uint _max_money,
        uint _min_money,
        uint _price,
        string memory _terms      
    ) external payable{
        require(MerchantInterface(_merchantAddr).getPledgeStatus(msg.sender), 
            "Please become a merchant first");
        
        require(records[_delegationNo].delegationNo == uint256(0), "order exist");

        _payFee("addSellDelegation");

        DelegationInfo memory _record = DelegationInfo({
            delegationNo: _delegationNo,
            userAddr: msg.sender,
            totalCount: _total_money,
            remainderCount: _total_money,
            pay_type: _pay_type,
            max_money: _max_money,
            min_money: _min_money,
            price: _price,
            itype: 2,
            status: 1,
            undoneOrderCount: 0,
            terms: _terms,
            create_time: block.timestamp,
            update_time: 0
        });

        records[_delegationNo] = _record;

        recordList.push(_record);
        recordIndex[_delegationNo] = recordList.length - 1;  
        //转账usdt到监管合约
        IERC20(usdtAddress).transferFrom(msg.sender, _recordAddr, _total_money);

        emit RecordAdd(
            _delegationNo,
            msg.sender,
            _total_money,
            _pay_type, 
            _max_money, 
            _min_money, 
            _price,
            2, 
            _terms, 
            block.timestamp
        );
    }

    function callBuyDelegation(
        uint _delegationNo
    ) external payable onlyDelegationOwner(_delegationNo){
        DelegationInfo memory _record = records[_delegationNo];
        require(_record.delegationNo != 0, "order does not exist");        
        require(_record.status != 3, "order completed");
        require(_record.userAddr == msg.sender, "You do not have permission");
        require(_record.undoneOrderCount == 0, "Has an open order");

        _payFee("callDelegation"); 

        _record.status = 2;
        _record.update_time = block.timestamp;  
        records[_delegationNo] = _record;
        recordList[recordIndex[_delegationNo]] = _record;        
    }

    function callSellDelegation(
        uint _delegationNo
    ) external payable onlyDelegationOwner(_delegationNo){
        DelegationInfo memory _record = records[_delegationNo];
        require(_record.delegationNo != 0, "order does not exist");        
        require(_record.status != 3, "order completed");
        require(_record.undoneOrderCount == 0, "Has an open order");

        _payFee("callSellDelegation"); 

        _record.status = 2;
        _record.update_time = block.timestamp;  
        records[_delegationNo] = _record;
        recordList[recordIndex[_delegationNo]] = _record;        
        //取回质押的USDT
        RecordInterface(_recordAddr).callMerchantRecord(msg.sender, _record.remainderCount);
    }  

    function setEnaleDelegation(
        uint _delegationNo,
        bool enable
    )external payable onlyDelegationOwner(_delegationNo){
        DelegationInfo memory _record = records[_delegationNo];
        require(_record.delegationNo != 0, "order does not exist");                  
        //1启用,0不起用2已撤销3已完成
        if (enable){
            require(_record.status == 0, "order status error"); 
            _record.status = 1;
        }else{
            require(_record.status == 1, "order status error"); 
            _record.status = 0;
        }
        
        _record.update_time = block.timestamp;   
        records[_delegationNo] = _record;
        recordList[recordIndex[_delegationNo]] = _record;              
    }

    function IncreaseUndoneOrderCount(
        uint256 _delegationNo
    )external onlyAuthFromOrderAddr{
        DelegationInfo memory _record = records[_delegationNo];
        require(_record.delegationNo != 0, "order does not exist");  

        _record.undoneOrderCount = _record.undoneOrderCount.add(1);  

        records[_delegationNo] = _record;
        recordList[recordIndex[_delegationNo]] = _record;        
    }

    function DecreaseUndoneOrderCount(
        uint256 _delegationNo
    )external onlyAuthFromOrderAddr{
        DelegationInfo memory _record = records[_delegationNo];
        require(_record.delegationNo != 0, "order does not exist");  

        _record.undoneOrderCount = _record.undoneOrderCount.sub(1);  

        records[_delegationNo] = _record;
        recordList[recordIndex[_delegationNo]] = _record;        
    }

    function updateRemainCount(
        uint256 _delegationNo, 
        uint256 _coinCount,
        uint256 _iType //0减少剩余数量 1增加剩余数量
    )external onlyAuthFromOrderAddr{
        DelegationInfo memory _record = records[_delegationNo];
        if(_iType == 0){
            require(
                _record.remainderCount >= _coinCount,
                "DelegationOrder:coin count error"
            );            
            _record.remainderCount = _record.remainderCount.sub(_coinCount); 
        }else{
            require(
                _record.remainderCount + _coinCount <= _record.totalCount,
                "DelegationOrder:coin count error 2"
            );             
            _record.remainderCount = _record.remainderCount.add(_coinCount); 
        }
        
        _record.update_time = block.timestamp;
        records[_delegationNo] = _record;
        recordList[recordIndex[_delegationNo]] = _record;        
    }    

    function getDelegationInfo(uint delegationNo) public view returns(DelegationInfo memory){
        return records[delegationNo];
    }

    modifier onlyDelegationOwner(uint256 _delegationNo) {
        require(_delegationNo != uint256(0), "orderNo null");
        require(
            records[_delegationNo].userAddr == msg.sender,
            "only delegation owner"
        );
        _;
    }

    //_payFee("pledge");
    mapping(string => address) public feeAddrSet;
    mapping(string => uint256) public feeAmountSet;
    function setFee(string calldata _method,address _addr,uint256 _amount) external onlyOwner {
        feeAddrSet[_method] = _addr;
        feeAmountSet[_method] = _amount;
    }

    function _payFee(string memory _method) internal {
        uint256 _amt = feeAmountSet[_method];
        address _addr = feeAddrSet[_method];

        if (_amt > 0) {
            require(_addr != address(0), "1");
            require(msg.value >= _amt, "2");
            payable(_addr).transfer(_amt);
        }
    }       
}