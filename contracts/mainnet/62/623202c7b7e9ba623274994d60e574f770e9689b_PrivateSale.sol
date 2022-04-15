/**
 *Submitted for verification at BscScan.com on 2022-04-15
*/

// SPDX-License-Identifier: GPL-v3.0

pragma solidity >=0.4.0;
library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, 'SafeMath: modulo by zero');
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

pragma solidity >=0.4.0;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, 'Address: insufficient balance');

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, 'Address: low-level call failed');
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, 'Address: insufficient balance for call');
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), 'Address: call to non-contract');

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
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




pragma solidity ^0.6.0;

library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            'SafeBEP20: approve from non-zero to non-zero allowance'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            'SafeBEP20: decreased allowance below zero'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IBEP20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, 'SafeBEP20: low-level call failed');
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), 'SafeBEP20: BEP20 operation did not succeed');
        }
    }
}




pragma solidity >=0.4.0;

contract Context {

    constructor() internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




pragma solidity >=0.4.0;

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

pragma solidity >=0.6.2;

interface ILookupReferral {

    function getTopLeader(address _user) external view returns (address);

    function getLeaderByUser(address _user) external view returns (address) ;
}

pragma solidity >=0.6.2;

interface IReferral {
/**
     * @dev Record referral.
     */
    function recordReferral(address user, address referrer) external;

    /**
     * @dev Get the referrer address that referred the user.
     */
    function getReferrer(address user) external view returns (address);
}

pragma solidity >=0.6.2;
pragma experimental ABIEncoderV2;

contract PrivateSale is Ownable {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    IBEP20 public xgToken;
    IBEP20 public usdtToken;
    IReferral public referral;
    ILookupReferral public ref;

    struct SaleInfo {
        uint256 amtAvl;
        uint256 price;
        uint256 startDate;
        uint256 endDate;
        uint256 initAmt;
    }

    struct UserInfo {
        uint256 amount1;
        uint256 amount2;
        uint256 amount3;
        uint256 amount4;
    }

    SaleInfo[] public saleInfo;
    uint256 public currentPhase = 1;
    uint256 public claimDate = 1735689600; // 1/1/2025 12:00 am

    mapping (address => UserInfo) userInfo;
    mapping(address=>uint256) public sales;
    uint256 public totalUsdt = 0;

    uint16 public topLeaderRate = 10;
    uint256 public leaderRate = 10;
    uint16 public referral1Rate = 5;
    uint16 public referral2Rate = 3;
    uint16 public referral3Rate = 2;
    

    event ReferralCommissionPaid(address indexed user, address indexed referrer, uint256 commissionAmount);
    event Buy(address indexed user, uint256 amount);

    address public admin = 0x185ED145623FE913c826036e49c39CEaD8E61Adb;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only Admin can call this function");
        _;
    }

    constructor(IBEP20 _usdtToken, IBEP20 _xgToken, IReferral _referral, address _ref) public {
        referral = _referral;
        ref = ILookupReferral(_ref);
        xgToken = _xgToken;
        usdtToken = _usdtToken;
        saleInfo.push(SaleInfo({
            amtAvl: 2220000000000000,
            price: 800000000,
            startDate: 0,
            endDate: 0,
            initAmt:2220000000000000
        }));
        saleInfo.push(SaleInfo({
            amtAvl: 2220000000000000,
            price: 1100000000,
            startDate: 0,
            endDate: 0,
            initAmt:2220000000000000
        }));
        saleInfo.push(SaleInfo({
            amtAvl: 2220000000000000,
            price: 1400000000,
            startDate: 0,
            endDate: 0,
            initAmt:2220000000000000
        }));
        saleInfo.push(SaleInfo({
            amtAvl: 2220000000000000,
            price: 1700000000,
            startDate: 0,
            endDate: 0,
            initAmt:2220000000000000
        }));
    }
    // Update top leader rate
    function setTopLeaderRate(uint16 _topLeaderRate) public onlyOwner {
        topLeaderRate = _topLeaderRate;
    }
    
     // Update leader rate
    function setLeaderRate(uint256 _leaderRate) public onlyOwner {
        leaderRate = _leaderRate;
    }
    
    // Update referral rate level 1
    function setReferral1Rate(uint16 _referral1Rate) public onlyOwner {
        referral1Rate = _referral1Rate;
    }
    
    // Update referral rate level 2
    function setReferral2Rate(uint16 _referral2Rate) public onlyOwner {
        referral2Rate = _referral2Rate;
    }
    
    // Update referral rate level 3
    function setReferral3Rate(uint16 _referral3Rate) public onlyOwner {
        referral3Rate = _referral3Rate;
    }

    function setClaimDate(uint256 _date) public onlyOwner{
        claimDate = _date;
    }

    function setAdmin(address _admin) public onlyOwner {
        admin = _admin;
    }

    function updateSaleInfo(uint256 _index,uint256 _amtAvl,uint256 _price) public onlyOwner{
        SaleInfo storage _saleInfo = saleInfo[_index];
        _saleInfo.amtAvl = _amtAvl;
        _saleInfo.price = _price;
    }

    function emergencyTokenWithdraw(IBEP20 token,uint256 _amount,address _to) public onlyAdmin {
        require(_amount < token.balanceOf(address(this)), 'not enough token');
        token.safeTransfer(address(_to), _amount);
    }

    function getUserInfo(address _sender) public view returns (UserInfo memory _userInfo){
        return userInfo[_sender];
    }

    function isClaim() public view returns (bool _isClaim){
        if(block.timestamp>claimDate){
            return true;
        }
        return false;
    }
    
    function claim() public{
        if(block.timestamp>claimDate){
            //transfer token and reset
            UserInfo storage _userInfo = userInfo[msg.sender];
            if(_userInfo.amount1>0){
                xgToken.safeTransfer(msg.sender,_userInfo.amount1);
                _userInfo.amount1 = 0;
            }
            if(_userInfo.amount2>0){
                xgToken.safeTransfer(msg.sender,_userInfo.amount2);
                _userInfo.amount2 = 0;
            }
            if(_userInfo.amount3>0){
                xgToken.safeTransfer(msg.sender,_userInfo.amount3);
                _userInfo.amount3 = 0;
            }
            if(_userInfo.amount4>0){
                xgToken.safeTransfer(msg.sender,_userInfo.amount4);
                _userInfo.amount4 = 0;
            }
        }
    }

    function buy(uint256 _amount,address _referrer) public{
        UserInfo storage user = userInfo[msg.sender];

        if (_amount > 0 && address(referral) != address(0) && _referrer != address(0) && _referrer != msg.sender) {
            referral.recordReferral(msg.sender, _referrer);
        }

        if (_amount > 0){
            SaleInfo storage saInfo = saleInfo[currentPhase-1];
            uint256 _amtInXG = _amount/saInfo.price;
            uint256 _amtInUSDT = _amount;
            
            if(saInfo.startDate == 0){
                saInfo.startDate = block.timestamp;
            }
            if(_amtInXG<=saInfo.amtAvl && _amtInXG>0){
                saInfo.amtAvl = saInfo.amtAvl - _amtInXG;
                if(currentPhase == 1){
                    user.amount1 = user.amount1 + _amtInXG;
                }else if(currentPhase == 2){
                    user.amount2 = user.amount2 + _amtInXG;
                }else if(currentPhase == 3){
                    user.amount3 = user.amount3 + _amtInXG;
                }else if(currentPhase == 4){
                    user.amount4 = user.amount4 + _amtInXG;
                }
            }else if(_amtInXG>saInfo.amtAvl && _amtInXG>0){
                _amtInUSDT = saInfo.amtAvl*saInfo.price;
                _amtInXG = saInfo.amtAvl;
                if(currentPhase == 1){
                    user.amount1 = user.amount1 + _amtInXG;
                }else if(currentPhase == 2){
                    user.amount2 = user.amount2 + _amtInXG;
                }else if(currentPhase == 3){
                    user.amount3 = user.amount3 + _amtInXG;
                }else if(currentPhase == 4){
                    user.amount4 = user.amount4 + _amtInXG;
                }
                saInfo.amtAvl = 0;
                saInfo.endDate = block.timestamp;
                currentPhase = currentPhase + 1;
            }

            if(_amtInUSDT>0){
                //transfer usdt
                usdtToken.safeTransferFrom(address(msg.sender),address(this), _amtInUSDT);

                //pay commission
                payReferralCommission(msg.sender,_amtInUSDT);
                updateSales(msg.sender,_amtInUSDT);

                totalUsdt = totalUsdt + _amtInUSDT*70/100;
            }
        }
        
    }

    // Pay referral commission to the referrer who referred this user.
    function payReferralCommission(address _user, uint256 _pending) internal {
        uint256 commissionAmount = _pending.mul(topLeaderRate).div(100);
        if(commissionAmount>0){
            //pay to top Leader
            address tpLeader = ref.getTopLeader(_user);
            if(tpLeader != address(0)){
                usdtToken.safeTransfer(tpLeader, commissionAmount);
                emit ReferralCommissionPaid(_user, tpLeader, commissionAmount);
            }
            
            //pay to Leader
            uint256 commissionAmountLead = _pending*leaderRate/100;
            address lowlead = ref.getLeaderByUser(_user);
            if(lowlead != address(0)){
                usdtToken.safeTransfer(lowlead, commissionAmountLead);
                emit ReferralCommissionPaid(_user, lowlead, commissionAmountLead);
            }
            
            if(address(referral) != address(0)){
                //pay to referral level 1
                //address _referrallevel1 = refer[_user];
                address _referrallevel1 = referral.getReferrer(_user);
                if(_referrallevel1 != address(0)){
                    uint256 commissionAmount1 = _pending.mul(referral1Rate).div(100);
                    usdtToken.safeTransfer(_referrallevel1, commissionAmount1);
                    emit ReferralCommissionPaid(_user, _referrallevel1, commissionAmount1);
                    
                    //pay to referral level 2
                    //address _referrallevel2 = refer[_referrallevel1];
                    address _referrallevel2 = referral.getReferrer(_referrallevel1);
                    if(_referrallevel2 != address(0)){
                        uint256 commissionAmount2 = _pending.mul(referral2Rate).div(100);
                        usdtToken.safeTransfer(_referrallevel2, commissionAmount2);
                        emit ReferralCommissionPaid(_user, _referrallevel2, commissionAmount2);
                        
                        //pay to referral level 3
                        //address _referrallevel3 = refer[_referrallevel2];
                        address _referrallevel3 = referral.getReferrer(_referrallevel2);
                        if(_referrallevel3 != address(0)){
                            uint256 commissionAmount3 = _pending.mul(referral3Rate).div(100);
                            usdtToken.safeTransfer(_referrallevel3, commissionAmount3);
                            emit ReferralCommissionPaid(_user, _referrallevel3, commissionAmount3);
                        }
                    }
                }
            }
        }
    }

    //update sales
    function updateSales(address _user,uint256 _amount) internal{
        address _refer = referral.getReferrer(_user);
        while(_refer != address(0)){
            sales[_refer] = sales[_refer] + _amount;
            _refer = referral.getReferrer(_refer);
        }
    }
}