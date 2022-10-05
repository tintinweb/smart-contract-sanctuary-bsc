/**
 *Submitted for verification at BscScan.com on 2022-10-05
*/

/**
 *Submitted for verification at BscScan.com on 2022-97-03
*/


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

//import "contracts/Libraries.sol";

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
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

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
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

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev Initializes the contract setting the deployer as the initial owner.
    */
    constructor () {
      address msgSender = _msgSender();
      _owner = msgSender;
      emit OwnershipTransferred(address(0), msgSender);
    }

    /**
    * @dev Returns the address of the current owner.
    */
    function owner() public view returns (address) {
      return _owner;
    }

    
    modifier onlyOwner() {
      require(_owner == _msgSender(), "Ownable: caller is not the owner");
      _;
    }

    function renounceOwnership() public onlyOwner {
      emit OwnershipTransferred(_owner, address(0));
      _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
      _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
      require(newOwner != address(0), "Ownable: new owner is the zero address");
      emit OwnershipTransferred(_owner, newOwner);
      _owner = newOwner;
    }
}

/**
 * BEP20 standard interface.
 */
interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function burn(uint256 amount) external;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract NastyPuta is Context, Ownable {
    using SafeMath for uint256;

    event Hire(address indexed adr, uint256 milks, uint256 amount);
    event Drink(address indexed adr, uint256 milks, uint256 amount, uint256 penalty);

    /*
    *   Those are the fees for the miner
    *   They cannot be modified once the contract is deployed
    */
    uint256 private rewardsPercentage = 15;
    uint256 private devFeeVal = 1;
    uint256 private sellTaxVal = 4;

    uint256 private MILKS_TO_HATCH_1MILKER = 576000; //for final version should be seconds in a day
    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;
    bool private initialized = false;
    address payable private recAdd;
    mapping (address => uint256) private investments;
    mapping (address => uint256) private withdrawals;

    mapping (address => uint256) private hiredMilkers;
    mapping (address => uint256) private claimedMilks;
    mapping (address => uint256) private lastHire;
    mapping (address => uint256) private sellsTimestamps;
    mapping (address => uint256) private customSellTaxes;
    mapping (address => address) private referrals;
    uint256 private marketMilks;

    //AIRDROP//
    address public airdropToken = address(0); //will be use for performing old miner airdrops/presale
    bool public claimEnabled = false;
    bool public openPublic = false;

    function enableClaim(bool _enableClaim) public onlyOwner {
        claimEnabled = _enableClaim;
    }

    function openToPublic(bool _openPublic) public onlyOwner {
        openPublic = _openPublic;
    }

    event ClaimMilkers(address _sender, uint256 _milkersToClaim, uint256 _mmBNB);
    function claimMilkers(address ref) public {
        require(initialized);
        require(claimEnabled, 'Claim still not available');
        //uint256 airdropTokensSupply = IBEP20(airdropToken).totalSupply(); //Claimeable miners
        //uint256 airdropTokensDecimals = IBEP20(airdropToken).decimals();
        uint256 airdropTokens = IBEP20(airdropToken).balanceOf(msg.sender);
        IBEP20(airdropToken).transferFrom(msg.sender, address(this), airdropTokens); //The token has to be approved first
        IBEP20(airdropToken).burn(airdropTokens); //Tokens burned

        //MMBNB is used to buy miners
        uint256 milkersClaimed = calculateHireMilkers(airdropTokens, address(this).balance);

        claimedMilks[msg.sender] = SafeMath.add(claimedMilks[msg.sender], milkersClaimed);
        rehireMilkers(msg.sender, ref, true);

        emit ClaimMilkers(msg.sender, milkersClaimed, airdropTokens);
    }

    function setAirdropToken(address _airdropToken) public onlyOwner {
        airdropToken =_airdropToken;
    }

    //AUTO EXE//
    uint256 public nInvestors = 0;
    mapping(uint256 => address) private investors;
    uint256 private investorsNextIndex = 0;
    uint256 public nSnapshots = 0;
    mapping(uint256 => uint256) investmentsAcumSnapshot;
    mapping(uint256 => uint256) withdrawalsAcumSnapshot;
    uint256 private timestampLastSnapshot = 0; //One daily
    uint256 private minDaysSell = 7;
    uint256 private maxDaysSell = 14;
    uint256 public autoFeeTax = 1;
    uint256 private executionHour = 1200; //12:00
    bool enabledSingleMode = false;
    address payable private autoAdd;
    
    event Execute(address _sender, uint256 _totalInvestors, uint256 daysForSelling, uint256 nSells, uint256 nSellsMax, uint256 _snapSizeIV, uint256 _snapSizeWD);
    function execute() public {
        require(initialized);
        require(msg.sender == autoAdd, 'Only auto account can trigger this');       
        takeSnapshotInvestmentsWithdrawals();
        uint256 _daysForSelling = daysForSelling();
        uint256 _nSells = totalSoldsToday();
        uint256 _nSellsMax = 1;
        if(nInvestors >= _daysForSelling){
            _nSellsMax = nInvestors.div(_daysForSelling);  
        }      

        for(uint i = 0; i < nInvestors; i++) {
            bool _canSell = canSell(investors[i], _daysForSelling);
            if(_canSell == false || _nSells >= _nSellsMax || i < investorsNextIndex){
                rehireMilkers(investors[i], address(0), false);
            }else{
                _nSells++;
                investorsNextIndex++; //Next iteration we begin on first rehire or zero
                if(investorsNextIndex == nInvestors){
                    investorsNextIndex = 0;
                }
                drinkMilks(investors[i]);
            }
        }

        emit Execute(msg.sender, nInvestors, _daysForSelling, _nSells, _nSellsMax, nSnapshots, nSnapshots);
    }

    event ExecuteSingle(address _sender, bool _rehire);
    function executeSingle() public {
        require(initialized);
        require(enabledSingleMode, 'Single mode not enabled');
        takeSnapshotInvestmentsWithdrawals();
        uint256 _daysForSelling = daysForSelling();
        uint256 _nSellsMax = nInvestors.div(_daysForSelling);
        uint256 _nSells = totalSoldsToday(); //How much investors sold today?
        bool _canSell = canSell(msg.sender, _daysForSelling);

        if(_canSell == false || _nSells >= _nSellsMax){
            rehireMilkers(msg.sender, address(0), false);
        }else{
            drinkMilks(msg.sender);
        }

        emit ExecuteSingle(msg.sender, _canSell == false || _nSells >= _nSellsMax);
    }

    function getExecutionHour() public view returns(uint256){
        return executionHour;
    }

    function setExecutionHour(uint256 exeHour) public onlyOwner {
        executionHour = exeHour;
    }

    function canSell(address _sender, uint256 _daysForSelling) public view returns (bool) {
        uint256 _lastSellTimestamp = 0;
        if(sellsTimestamps[_sender] > 0){
            _lastSellTimestamp = sellsTimestamps[_sender];
        }
        else{
            return false;            
        }
        return block.timestamp > _lastSellTimestamp && block.timestamp.sub(_lastSellTimestamp) > _daysForSelling.mul(1 days);
    }

    function daysForSelling() public view returns (uint256) {

        uint256 [7] memory investmentsDiff;
        uint256 [7] memory withdrawalsDiff;
        uint256 posRatio = 0;
        uint256 negRatio = 0;     
        uint256 _nSnapshots = nSnapshots;   
        uint256 daysSell = minDaysSell.add(maxDaysSell.sub(minDaysSell).div(2)); //We begin in the middle
        uint256 globalDiff = 0;

        //We need 2 days of data or more        
        if(_nSnapshots < 2){
            return daysSell;
        }

        //We only take 7 last snapshots
        if(_nSnapshots > investmentsDiff.length){
            _nSnapshots = investmentsDiff.length;
        }

        //We storage the snapshots BNB diff to storage how much BNB was withdraw/invest on the miner each dat
        uint256 currPos = _nSnapshots;
        for(uint256 i = 0; i < _nSnapshots-1; i++){            
            investmentsDiff[i] = investmentsAcumSnapshot[currPos.sub(1)].sub(investmentsAcumSnapshot[currPos.sub(2)]);
            withdrawalsDiff[i] = withdrawalsAcumSnapshot[currPos.sub(1)].sub(withdrawalsAcumSnapshot[currPos.sub(2)]);
            currPos--;
        }

        //BNB investing diff along the days vs withdraws
        (posRatio, negRatio) = getRatiosFromInvWitDiff(investmentsDiff, withdrawalsDiff);

        //We take the ratio diff, and get the amount of days to add/substract to daysSell
        if(negRatio > posRatio){
            globalDiff = (negRatio.sub(posRatio)).div(100);
        }
        else{
            globalDiff = (posRatio.sub(negRatio)).div(100);
        }

        //We adjust daysSell taking into acount the limits
        if(negRatio > posRatio){
            daysSell = daysSell.add(globalDiff);
            if(daysSell > maxDaysSell){
                daysSell = maxDaysSell;
            }
        }else{
            if(globalDiff < daysSell && daysSell.sub(globalDiff) > minDaysSell){
                daysSell = daysSell.sub(globalDiff);
            }
            else{
                daysSell = minDaysSell;
            }
        }

        return daysSell;        
    }

    function estimateSellAddressTime(address adr) public view returns (uint256) {
        uint256 sellsAdr = getSellsByAddress(adr);
        if(sellsAdr == 0){
            return 0;
        }
        uint256 _sellTime = sellsAdr;
        uint256 _daysForSelling = daysForSelling();
        uint256 _nSellsMax = 1;
        uint256 _posInv = 0;
        uint256 _nDaysBeforeSell = 0;

        //Investor position
        for(uint i = 0; i < nInvestors; i++) {
            if(investors[i] == adr){
                _posInv = i;
                break;
            }
        }

        //Sells per day
        if(nInvestors >= _daysForSelling){
            _nSellsMax = nInvestors.div(_daysForSelling);  
        }

        //Days before sell taking into account his position and next index
        if(_posInv >= investorsNextIndex){
            _nDaysBeforeSell = (_posInv.sub(investorsNextIndex)).div(_nSellsMax);
        }
        else{
            _nDaysBeforeSell = ((nInvestors.sub(investorsNextIndex)).add(_posInv)).div(_nSellsMax);
        }

        return _sellTime.add(_daysForSelling.mul(1 days)).add(_nDaysBeforeSell.mul(1 days));
    }

    function estimateSellAddresTimeET(address adr) public view returns (uint256) {
        uint256 eSAT = estimateSellAddressTime(adr);

        uint256 exeHour = getExecutionHour();
        uint256 exeHH = 0;
        uint256 exeMM = 0;

        if(exeHour > 100){
            exeHH = exeHour.div(100);
            exeMM = exeHour % exeHH;
        }
        else{
            exeHH = 0;
            exeMM = exeHour;
        }

        return eSAT.add(exeHH.mul(3600)).add(exeMM.mul(60));
    }

    function getRatiosFromInvWitDiff(uint256 [7] memory investmentsDiff, uint256 [7] memory withdrawalsDiff) private pure returns (uint256, uint256){
        uint256 posRatio = 0;
        uint256 negRatio = 0;
        uint256 ratioPosAdd = 0;
        uint256 ratioNegAdd = 0;

        //We storage the ratio, how much times BNB was invested respect the withdraws and vice versa
        for(uint256 i = 0; i < investmentsDiff.length; i++){
            if(investmentsDiff[i] != 0 || withdrawalsDiff[i] != 0){
                if(investmentsDiff[i] > withdrawalsDiff[i]){
                    if(withdrawalsDiff[i] > 0){
                        ratioPosAdd = investmentsDiff[i].mul(100).div(withdrawalsDiff[i]);
                        if(ratioPosAdd > 200){
                            posRatio += 200;
                        }
                        else{
                            posRatio += ratioPosAdd;
                        }
                    }else{
                        posRatio += 100;
                    }
                }
                else{
                    if(investmentsDiff[i] > 0){
                        ratioNegAdd = withdrawalsDiff[i].mul(100).div(investmentsDiff[i]);
                        if(ratioNegAdd > 200){
                            negRatio += 200;
                        }
                        else{
                            negRatio += ratioNegAdd;
                        }
                    }else{
                        negRatio += 100;
                    }
                }
            }
        }

        return (posRatio, negRatio);
    }

    function totalSoldsToday() private view returns (uint256){
        uint256 _totalSoldsToday = 0;
        for(uint i = 0 ; i < nInvestors; i++) {
            uint256 _lastSellTimestamp = 0;
            if(sellsTimestamps[investors[i]] > 0){
                _lastSellTimestamp = sellsTimestamps[investors[i]];
            }
            if(block.timestamp.sub(_lastSellTimestamp) < (1 days)){
                _totalSoldsToday++;
            }
        }
        return _totalSoldsToday;
    }

    function calculateAutoTax(uint256 amount) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount,autoFeeTax),100);
    }

    event TakeSnapshotInvestmentsWithdrawals(uint256 investmentsAcum, uint256 withdrawalsAcum);
    function takeSnapshotInvestmentsWithdrawals() private {
        if(block.timestamp > timestampLastSnapshot.add((1200 minutes))){ //A bit less than one day to ensure each day snapshot is taken
            uint256 acumInvestments = 0;
            uint256 acumWithdrawals = 0;

            for(uint i = 0 ; i < nInvestors; i++) {
                acumInvestments += investments[investors[i]];
                acumWithdrawals += withdrawals[investors[i]];
            }

            investmentsAcumSnapshot[nSnapshots] = acumInvestments;
            withdrawalsAcumSnapshot[nSnapshots] = acumWithdrawals;
            nSnapshots++;

            timestampLastSnapshot = block.timestamp;

            emit TakeSnapshotInvestmentsWithdrawals(acumInvestments, acumWithdrawals);
        }
    }


    function setAutotax(uint256 pcTaxAuto, address _autoAdd) public onlyOwner {
        require(pcTaxAuto <= 5);
        autoFeeTax = pcTaxAuto;
        autoAdd = payable(_autoAdd);
    }
    
    function setDevTax(uint256 _devFeeVal, uint256 _sellTaxVal, address _devAdd) public onlyOwner {
        require(_devFeeVal <= 5);
        require(_sellTaxVal <= 15);
        devFeeVal = _devFeeVal;
        sellTaxVal = _sellTaxVal;
        recAdd = payable(_devAdd);
    }

    function enableSingleMode(bool _enable) public onlyOwner {
        enabledSingleMode = _enable;
    }

    //CUSTOM (Emergency withdraw)//
    uint256 public emergencyWithdrawPenalty = 25;

    function setEmergencyWithdrawPenalty(uint256 _penalty) public onlyOwner {
        require(_penalty < 100);
        emergencyWithdrawPenalty = _penalty;
    }

    event EmergencyWithdraw(uint256 _investments, uint256 _withdrawals, uint256 _amountToWithdraw, uint256 _amountToWithdrawAfterTax, uint256 _amountToWithdrawTaxed);
    function emergencyWithdraw() public {
        require(initialized);        
        require(withdrawals[msg.sender] < investments[msg.sender], 'You already recovered your investment');
        require(hiredMilkers[msg.sender] > 1, 'You cant use this function');
        uint256 amountToWithdraw = investments[msg.sender].sub(withdrawals[msg.sender]);
        uint256 amountToWithdrawAfterTax = amountToWithdraw.mul(uint256(100).sub(emergencyWithdrawPenalty)).div(100);
        require(amountToWithdrawAfterTax > 0, 'There is nothing to withdraw');
        uint256 amountToWithdrawTaxed = amountToWithdraw.sub(amountToWithdrawAfterTax);

        withdrawals[msg.sender] += amountToWithdraw;
        hiredMilkers[msg.sender] = 1; //Burn

        if(amountToWithdrawTaxed > 0){
            recAdd.transfer(amountToWithdrawTaxed);
        }

        payable (msg.sender).transfer(amountToWithdrawAfterTax);

        emit EmergencyWithdraw(investments[msg.sender], withdrawals[msg.sender], amountToWithdraw, amountToWithdrawAfterTax, amountToWithdrawTaxed);
    }

    //CUSTOM (ROI events)//
    //One time event

    //Max sell
    uint256 public maxSellPcTVL = 2;
    function capToMaxSell(uint256 milksValue, uint256 milks) public view returns(uint256, uint256){
        uint256 maxSell = address(this).balance.mul(maxSellPcTVL).div(100);
        if(maxSell >= milksValue){
            return (milksValue, 0);
        }
        else{
            uint256 nMilksHire = calculateHireMilkersSimpleNoEvent(milksValue.sub(maxSell));
            if(nMilksHire <= milks){
                return (maxSell, milks.sub(nMilksHire));
            }
            else{
                return (maxSell, 0);
            }
        }     
    }

    function setMaxSellPc(uint256 _maxSellPcTVL) public onlyOwner {
        require(_maxSellPcTVL >= 1);
        maxSellPcTVL = _maxSellPcTVL;
    }

    //Weekly withdraw
    // uint256 public daysAdminWithdrawMarketing = 7;
    // uint256 public timestampAdminWithdraw = 0;
    // function executeAdminWithdraw(uint256 _bnb) public onlyOwner {
    //     require(_bnb < 2 wei);
    //     if(block.timestamp > timestampAdminWithdraw.add((7 days))){
    //         payable (msg.sender).transfer(_bnb);
    //         timestampAdminWithdraw = block.timestamp;
    //     }
    // }

    ////////////

    constructor(address _airdropToken, address _autoAdd) {
        recAdd = payable(msg.sender);
        autoAdd = payable(_autoAdd);
        airdropToken = _airdropToken;
    }

    // This function is called by anyone who want to contribute to TVL
    function ContributeToTVL() public payable {

    }

    event RehireMilkers(address _investor, uint256 _newMilkers, uint256 _hiredMilkers, uint256 _nInvestors, uint256 _referralMilks, uint256 _marketMilks, uint256 _milksUsed);
    function rehireMilkers(address _sender, address ref, bool isClaim) private {
        require(initialized);
        takeSnapshotInvestmentsWithdrawals();

        if(ref == _sender) {
            ref = address(0);
        }
        
        if(referrals[_sender] == address(0) && referrals[_sender] != _sender) {
            referrals[_sender] = ref;
        }
        
        uint256 milksUsed = getMyMilks(_sender);
        uint256 newMilkers = SafeMath.div(milksUsed,MILKS_TO_HATCH_1MILKER);

        //We need this to iterate later on auto executions
        if(newMilkers > 0 && hiredMilkers[_sender] == 0){            
            investors[nInvestors] = _sender;
            nInvestors++;
        }
        //Initialization
        if(sellsTimestamps[_sender] == 0){
            sellsTimestamps[_sender] = block.timestamp;
        }

        hiredMilkers[_sender] = SafeMath.add(hiredMilkers[_sender],newMilkers);
        claimedMilks[_sender] = 0;
        lastHire[_sender] = block.timestamp;
        
        //send referral milks
        claimedMilks[referrals[_sender]] = SafeMath.add(claimedMilks[referrals[_sender]],SafeMath.div(milksUsed,8));
        
        //boost market to nerf miners hoarding
        if(isClaim == false){
            marketMilks=SafeMath.add(marketMilks,SafeMath.div(milksUsed,5));
        }

        emit RehireMilkers(_sender, newMilkers, hiredMilkers[_sender], nInvestors, claimedMilks[referrals[_sender]], marketMilks, milksUsed);
    }
    
    function drinkMilks(address _sender) private {
        require(initialized);

        uint256 milksLeft = 0;
        uint256 hasMilks = getMyMilks(_sender);
        uint256 milksValue = calculateMilkSell(hasMilks);
        (milksValue, milksLeft) = capToMaxSell(milksValue, hasMilks);
        uint256 sellTax = calculateSellTax(milksValue);
        uint256 penalty = getSellPenalty();

        claimedMilks[_sender] = milksLeft;
        lastHire[_sender] = block.timestamp;
        marketMilks = SafeMath.add(marketMilks,hasMilks);
        recAdd.transfer(sellTax);
        withdrawals[_sender] += SafeMath.sub(milksValue,sellTax);
        payable (_sender).transfer(SafeMath.sub(milksValue,sellTax));

        // Push the timestamp
        sellsTimestamps[_sender] = block.timestamp;

        emit Drink(_sender, milksValue, SafeMath.sub(milksValue,sellTax), penalty);
    }

    function setRewardsPercentage(uint256 _percentage) public onlyOwner {
        require(_percentage >= 15, 'Percentage cannot be less than 15');
        rewardsPercentage = _percentage;
    }

    function getRewardsPercentage() public view returns (uint256) {
        return rewardsPercentage;
    }

    function getMarketMilks() public view returns (uint256) {
        return marketMilks;
    }
    
    function milksRewards(address adr) public view returns(uint256) {
        uint256 hasMilks = getMyMilks(adr);
        uint256 milksValue = calculateMilkSell(hasMilks);
        return milksValue;
    }

    function milksRewardsIncludingTaxes(address adr) public view returns(uint256) {
        uint256 hasMilks = getMyMilks(adr);
        (uint256 milksValue,) = calculateMilkSellIncludingTaxes(hasMilks);
        return milksValue;
    }

    function hireMilkers(address ref) public payable {
        require(initialized);
        require(openPublic, 'Miner still not opened');

        _hireMilkers(ref, msg.sender, msg.value);
    }

    function _hireMilkers(address _ref, address _sender, uint256 _amount) private {
        uint256 milksBought = calculateHireMilkers(_amount,SafeMath.sub(address(this).balance,_amount));

   

        uint256 milksBoughtFee = calculateBuyTax(milksBought);
        uint256 milksBoughtAutoFee = calculateAutoTax(milksBought);
        milksBought = SafeMath.sub(milksBought,milksBoughtFee).sub(milksBoughtAutoFee);
        uint256 fee = calculateBuyTax(_amount);
        uint256 autoTaxfee = calculateAutoTax(_amount);
        recAdd.transfer(fee);
        autoAdd.transfer(autoTaxfee);
        claimedMilks[_sender] = SafeMath.add(claimedMilks[_sender],milksBought);
        investments[_sender] += _amount;
        rehireMilkers(_sender, _ref, false);

        emit Hire(_sender, milksBought, _amount);
    }

    function getSellPenalty() public view returns (uint256) {
        return SafeMath.add(autoFeeTax, devFeeVal);
    }

    function getSellsByAddress(address addr) public view returns (uint256 timestamps) {
        return sellsTimestamps[addr];
    }

    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256) {
        uint256 valueTrade = SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
        if(rewardsPercentage > 15) {
            return SafeMath.div(SafeMath.mul(valueTrade,rewardsPercentage), 15);
        }

        return valueTrade;
    }
    
    function calculateMilkSell(uint256 milks) public view returns(uint256) {
        if(milks > 0){
            return calculateTrade(milks,marketMilks,address(this).balance);
        }
        else{
            return 0;
        }
    }

    function calculateMilkSellIncludingTaxes(uint256 milks) public view returns(uint256, uint256) {
        uint256 totalTrade = calculateTrade(milks,marketMilks,address(this).balance);
        uint256 penalty = getSellPenalty();
        uint256 sellTax = calculateSellTax(totalTrade);

        return (
            SafeMath.sub(totalTrade, sellTax),
            penalty
        );
    }
    
    function calculateHireMilkers(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateHireMilkersNoEvent(eth,contractBalance);
    }

    function calculateHireMilkersNoEvent(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketMilks);
    }
    
    function calculateHireMilkersSimple(uint256 eth) public view returns(uint256) {
        return calculateHireMilkers(eth,address(this).balance);
    }

    function calculateHireMilkersSimpleNoEvent(uint256 eth) public view returns(uint256) {
        return calculateHireMilkersNoEvent(eth,address(this).balance);
    }
    
    function calculateBuyTax(uint256 amount) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount,devFeeVal),100);
    }

    function calculateSellTax(uint256 amount) private view returns(uint256) {
        uint256 tax = getSellPenalty();
        return SafeMath.div(SafeMath.mul(amount,tax),100);
    }
    
    function seedMarket() public payable onlyOwner {
        require(marketMilks == 0);
        initialized = true;
        marketMilks = 108000000000;
    }

    function isInitialized() public view returns (bool) {
        return initialized;
    }
    
    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }
    
    function getMyMilkers(address adr) public view returns(uint256) {
        return hiredMilkers[adr];
    }
    
    function getMyMilks(address adr) public view returns(uint256) {
        return SafeMath.add(claimedMilks[adr],getMilksSinceLastHire(adr));
    }
    
    function getMilksSinceLastHire(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(MILKS_TO_HATCH_1MILKER,SafeMath.sub(block.timestamp,lastHire[adr]));
        return SafeMath.mul(secondsPassed,hiredMilkers[adr]);
    }

    function getTotalInvestmentByAddress(address adr) public view returns(uint256) {
        return investments[adr];
    }

    function getTotalWithdrawal(address adr) public view returns(uint256) {
        return withdrawals[adr];
    }
    
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}