/**
 *Submitted for verification at BscScan.com on 2022-01-05
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
pragma abicoder v2;

import "./IBEP20.sol";
import "./SafeMath.sol";
import "./Address.sol";
import "./Context.sol";
import "./SafeBEP20.sol";
import "./Ownable.sol";
import "./Pausable.sol";
import "./ECDSA.sol";
import "./IBEP1271.sol";
import "./SignatureChecker.sol";
import "./SignerManager.sol";
import "./EnumerableSet.sol";
import "./ReentrancyGuard.sol";
import "./QubeLaunchPadLib.sol";
import "./QubeBalance.sol";


contract QubeLaunchPad is Ownable,Pausable,SignerManager,ReentrancyGuard{
    
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;
    using Address for address payable;
    using SignatureChecker for address;
    using EnumerableSet for EnumerableSet.UintSet;
    using QubeLaunchPadLib for QubeLaunchPadLib.dataStore;
    using QubeLaunchPadLib for QubeLaunchPadLib.vestingStore;
    using QubeLaunchPadLib for QubeLaunchPadLib.userData;

    uint256 public monthDuration = 2592000;
    uint256 public internalLockTickets; 
    uint256 public minimumVestingPeriod = 0;
    uint256 public maximumVestingPeriod = 12;
    bytes32 public constant SIGNATURE_PERMIT_TYPEHASH = keccak256("bytes signature,address user,uint256 amount,uint256 tier,uint256 slot,uint256 deadline");
    
    address public distributor; 

    QubeLaunchPadLib.dataStore[] private reserveInfo;
    QubeLaunchPadLib.vestingStore[] private vestingInfo;
   
    mapping (address => EnumerableSet.UintSet) private userLockIdInfo;
    mapping (uint256 => QubeLaunchPadLib.userData) public userLockInfo;
    mapping (bytes => bool) public isSigned;
    mapping (uint256 => uint256) public totalDelegates;
    mapping (uint256 => mapping (address => uint256)) public userDelegate;

    event _initICO(address indexed saleToken,address indexed quoteToken,uint256 idoId,uint256 time);
    event _ico(address indexed user,uint256 idoId,uint256 stakeId,uint256 amountOut,uint256 receivedToken,uint256 lockedToken,uint256 time);
    event _claim(address indexed user,uint256 idoId,uint256 stakeId,uint256 receivedToken,uint256 unlockCount,uint256 time);

    IBEP20 public qube;
    IQubeBalance public qubeBalanceContract;
    
    receive() external payable {}
    
    constructor(IBEP20 _qube, address signer, IQubeBalance _qubeBalanceContract) {
        setSignerInternal(signer);
        qube = _qube;
        qubeBalanceContract=_qubeBalanceContract;
        distributor = msg.sender;
    }    

    function pause() public onlyOwner{
      _pause();
    }

    function unpause() public onlyOwner{
      _unpause();
    }

    function setDistributor(address account) public onlyOwner {
        require(account != address(0), "Address can't be zero");

        distributor = account;
    }

    function vestingPeriodUpdate(uint256 minimum,uint256 maximum) public onlyOwner{
        minimumVestingPeriod = minimum;
        maximumVestingPeriod = maximum;
    }
    
    function bnbEmergencySafe(uint256 amount) public onlyOwner {
       (payable(owner())).sendValue(amount);
    }
    
    function tokenEmergencySafe(IBEP20 token,uint256 amount) public onlyOwner {
       token.safeTransfer(owner(),amount);
    }

    function monthDurationUpdate(uint256 time) public onlyOwner{
        monthDuration = time;
    }
    
    
    function initICO(QubeLaunchPadLib.inputStore memory vars) public onlyOwner {
        uint256 lastTierTime = block.timestamp;
        uint256 saleAmountIn;
        for(uint256 i;i<vars.startTime.length;i++){
            require(vars.startTime[i] >= lastTierTime,"startTime is invalid");
            require(vars.startTime[i] <= vars.endTime[i], "endtime is invalid");
            require(minimumVestingPeriod <= vars.vestingMonths[i] && vars.vestingMonths[i] <= maximumVestingPeriod, "Vesting Months Invalid");
            require(vars.instantRoi[i].add(vars.installmentRoi[i]) <= 100, "invalid roi");
            saleAmountIn = saleAmountIn.add(vars.saleAmountIn[i]);
            lastTierTime = vars.endTime[i];
        }

        reserveInfo.push(QubeLaunchPadLib.dataStore({
            saleToken: vars.saleToken,
            quoteToken: vars.quoteToken,
            currentTier: 0,
            normalSaleStartTier: vars.startTime.length - 2,
            totalSaleAmountIn: saleAmountIn,
            totalSaleAmountOut: 0,
            startTime: vars.startTime,
            endTime: vars.endTime,
            salePrice: vars.salePrice,
            quotePrice: vars.quotePrice,
            saleAmountIn: vars.saleAmountIn,
            saleAmountOut: new uint256[](vars.saleAmountIn.length),
            minimumRequire: vars.minimumRequire, 
            maximumRequire: vars.maximumRequire,
            minimumEligibleQuoteForTx: vars.minimumEligibleQuoteForTx,
            minimumEligibleQubeForTx: vars.minimumEligibleQubeForTx,
            tierStatus: false,
            signOff: true,
            delegateState: vars.delegateState
        }));

        vestingInfo.push(QubeLaunchPadLib.vestingStore({
            vestingMonths: vars.vestingMonths,
            instantRoi: vars.instantRoi,
            installmentRoi: vars.installmentRoi,   
            distributeROI: new uint256[](vars.vestingMonths.length),
            isLockEnabled: vars.isLockEnabled
        }));
        
        if(!vars.delegateState) {
            IBEP20(vars.saleToken).safeTransferFrom(_msgSender(),address(this),saleAmountIn);
        }
        
        emit _initICO(
            address(vars.saleToken),
            address(vars.quoteToken),
            reserveInfo.length - 1,
            block.timestamp
        );
    }

    function minimumQubeAmount(uint256 reserveInfoID, uint256 tierID) public view returns (uint256){
        QubeLaunchPadLib.dataStore storage vars = reserveInfo[reserveInfoID];
        return vars.minimumEligibleQubeForTx[tierID];
    }
    function minimumPurchaseAmount(uint256 reserveInfoID, uint256 tierID) public view returns (uint256){
        return reserveInfo[reserveInfoID].minimumPurchaseAmount(tierID);
    }
    function maximumPurchaseAmount(uint256 reserveInfoID, uint256 tierID) public view returns (uint256){
        return reserveInfo[reserveInfoID].maximumPurchaseAmount(tierID);
    }

    function saleCurrencyBalance(address walletAddress, uint256 reserveInfoID) public view returns (uint256){
        QubeLaunchPadLib.dataStore storage vars = reserveInfo[reserveInfoID];
        IBEP20 quoteToken = vars.quoteToken;
        return quoteToken.balanceOf(walletAddress);
    }

    function isEligibleWallet(address walletAddress, uint256 reserveInfoID, uint256 tierID) public view returns (bool){
        QubeLaunchPadLib.dataStore storage vars = reserveInfo[reserveInfoID]; //sale details and variables
        uint256 decimal = vars.quoteToken.decimals();
        uint256 price = getPrice(vars.salePrice[vars.currentTier],vars.quotePrice[vars.currentTier],decimal);
        bool minimumCubeCheck = qubeBalanceContract.qubeBalance(walletAddress)>=minimumQubeAmount(reserveInfoID, tierID)||qubeBalanceContract.qubeBalanceWithNFT(walletAddress)>=minimumQubeAmount(reserveInfoID, tierID); 
        bool minimumPurchaseCheck = vars.quoteToken.balanceOf(walletAddress)>=price;
        return minimumCubeCheck && minimumPurchaseCheck;
    }

    function setStateStore(
        uint256 _id,
        bool _tierStatus,
        bool _signOff,
        bool _delegateState
    ) public onlyOwner {
        reserveInfo[_id].tierStatus = _tierStatus;
        reserveInfo[_id].signOff = _signOff;
        reserveInfo[_id].delegateState = _delegateState;
    }

    function setTime( 
        uint256 _id,
        uint256[] memory _startTime,
        uint256[] memory _endTime
    ) public onlyOwner {
        reserveInfo[_id].startTime = _startTime;
        reserveInfo[_id].endTime = _endTime;
    }

    function setSalePrice(
        uint256 _id,
        uint256[] memory _salePrice,
        uint256[] memory _quotePrice
    ) public onlyOwner {
        reserveInfo[_id].salePrice = _salePrice;
        reserveInfo[_id].quotePrice = _quotePrice;
    }

    function setVestingStore(
        uint256 _id,
        uint256[] memory _vestingMonths,
        uint256[] memory _instantRoi,
        uint256[] memory _installmentRoi,
        bool _isLockEnabled
    ) public onlyOwner {
        vestingInfo[_id].vestingMonths = _vestingMonths;
        vestingInfo[_id].instantRoi = _instantRoi;
        vestingInfo[_id].installmentRoi = _installmentRoi;
        vestingInfo[_id].isLockEnabled = _isLockEnabled;
    }    

    function setOtherStore(
        uint256 _id,
        uint256[] memory _minimumRequire,
        uint256[] memory _maximumRequire,
        uint256 _minimumEligibleQuoteForTx,
        uint256[] memory _minimumEligibleQubeForTx
    ) public onlyOwner {
        reserveInfo[_id].minimumRequire = _minimumRequire;
        reserveInfo[_id].maximumRequire = _maximumRequire;
        reserveInfo[_id].minimumEligibleQuoteForTx = _minimumEligibleQuoteForTx;
        reserveInfo[_id].minimumEligibleQubeForTx = _minimumEligibleQubeForTx;
    }

    function setCurrentTier(
        uint256 _id,
        uint256 _currentTier
    ) public onlyOwner {
        reserveInfo[_id].currentTier = _currentTier;
    }
  
    
    function getPrice(uint256 salePrice,uint256 quotePrice,uint256 decimal) public pure returns (uint256) {
       return (10 ** decimal) * salePrice / quotePrice;
    }
    
    struct singParams{
        bytes signature;
        address user;
        uint256 amount;
        uint256 tier;
        uint256 slot;
        uint256 deadline;
    }
    
    function signDecodeParams(bytes memory params) public pure returns (singParams memory) {
    (
        bytes memory signature,
        address user,
        uint256 amount,
        uint256 tier,
        uint256 slot,
        uint256 deadline
    ) =
      abi.decode(
        params,
        (bytes,address, uint256,uint256, uint256, uint256)
    );

    return
      singParams(
        signature,
        user,
        amount,
        tier,
        slot,
        deadline
      );
    }

    function signVerify(singParams memory sign) internal {
        require(sign.user == msg.sender, "invalid user");
        require(block.timestamp < sign.deadline, "Time Expired");
        require(!isSigned[sign.signature], "already sign used");
            
        bytes32 hash_ = keccak256(abi.encodePacked(
                SIGNATURE_PERMIT_TYPEHASH,
                address(this),
                sign.user,                
                sign.amount,
                sign.tier,
                sign.slot,
                sign.deadline
        ));
            
        require(signValidition(ECDSA.toEthSignedMessageHash(hash_),sign.signature), "Sign Error");
        isSigned[sign.signature] = true;       
    }
    
    function buy(uint256 id,uint256 amount,bytes memory signStore) public payable nonReentrant {
        QubeLaunchPadLib.dataStore storage vars = reserveInfo[id];
        QubeLaunchPadLib.vestingStore storage vesting = vestingInfo[id];
        address user = _msgSender();
        uint256 getAmountOut;
        while(vars.endTime[vars.currentTier] < block.timestamp && !vars.tierStatus){
            if(vars.currentTier != vars.startTime.length) {
                vars.currentTier++;
                
                if(vars.startTime[vars.normalSaleStartTier + 1] <= block.timestamp){
                    vars.tierStatus = true;
                    vars.currentTier = vars.normalSaleStartTier + 1;
                } 
            }
            
            if(!vars.signOff && vars.endTime[vars.normalSaleStartTier] <= block.timestamp) {
                vars.signOff = true;
            }
        }
        require(vars.startTime[vars.currentTier] <= block.timestamp && vars.endTime[vars.currentTier] >= block.timestamp, "Time expired");
        
        if(!vars.signOff){
            signVerify(signDecodeParams(signStore));
        }
        
        if(address(vars.quoteToken) == address(0)){
           uint256 getAmountIn = msg.value;
           require(getAmountIn >= vars.minimumRequire[vars.currentTier] && getAmountIn <= vars.maximumRequire[vars.currentTier], "invalid amount passed");
           if(getAmountIn >= vars.minimumEligibleQuoteForTx){
               require(qubeBalanceContract.qubeBalance(user) >= vars.minimumEligibleQubeForTx[vars.currentTier]||qubeBalanceContract.qubeBalanceWithNFT(user) >= vars.minimumEligibleQubeForTx[vars.currentTier], "Not eligible to buy");
           }
           
           getAmountOut = getAmountIn.mul(getPrice(vars.salePrice[vars.currentTier],vars.quotePrice[vars.currentTier],18)).div(1e18);    
        }else {
           require(amount >= vars.minimumRequire[vars.currentTier] && amount <= vars.maximumRequire[vars.currentTier], "invalid amount passed");
           if(amount == vars.minimumEligibleQuoteForTx){
               require(qubeBalanceContract.qubeBalance(user) >= vars.minimumEligibleQubeForTx[vars.currentTier]||qubeBalanceContract.qubeBalanceWithNFT(user) >= vars.minimumEligibleQubeForTx[vars.currentTier],"Not eligible to buy");
           }
           
           vars.quoteToken.safeTransferFrom(user,address(this),amount);
           
           uint256 decimal = vars.quoteToken.decimals();
         
           getAmountOut = amount.mul(getPrice(vars.salePrice[vars.currentTier],vars.quotePrice[vars.currentTier],decimal)).div(10 ** decimal);
        }

        for(uint256 i=0;i<=vars.currentTier;i++){
            if(i != 0){
                vars.saleAmountIn[i] = vars.saleAmountIn[i].add(vars.saleAmountIn[i-1].sub(vars.saleAmountOut[i-1]));
                vars.saleAmountOut[i-1] = vars.saleAmountIn[i-1];
            }
        }
        vars.saleAmountOut[vars.currentTier] = vars.saleAmountOut[vars.currentTier].add(getAmountOut);
        require(vars.saleAmountOut[vars.currentTier] <= vars.saleAmountIn[vars.currentTier], "Reserved amount exceed");
        
        if(vesting.isLockEnabled){
            internalLockTickets++;
            if(vars.delegateState) {
                totalDelegates[id] = totalDelegates[id].add(getAmountOut.mul(vesting.instantRoi[vars.currentTier]).div(1e2));
                userDelegate[id][user] = userDelegate[id][user].add(getAmountOut.mul(vesting.instantRoi[vars.currentTier]).div(1e2));
            } else {
                vars.saleToken.safeTransfer(user,getAmountOut.mul(vesting.instantRoi[vars.currentTier]).div(1e2));
            }
            userLockIdInfo[user].add(internalLockTickets);
            userLockInfo[internalLockTickets] = QubeLaunchPadLib.userData({
                userAddress: user,
                saleToken: vars.saleToken,
                idoID: id,
                lockedAmount: getAmountOut.mul(vesting.installmentRoi[vars.currentTier]).div(1e2),
                releasedAmount: 0,
                lockedDuration: block.timestamp,
                lastClaimed: block.timestamp,
                unlockCount: 0,
                installmentMonths: vesting.vestingMonths[vars.currentTier],
                distributeROI: uint256(1e4).div(vesting.vestingMonths[vars.currentTier])     
            });

            emit _ico(
                user,
                id,
                internalLockTickets,
                getAmountOut,
                getAmountOut.mul(vesting.instantRoi[vars.currentTier]).div(1e2),
                getAmountOut.mul(vesting.installmentRoi[vars.currentTier]).div(1e2),
                block.timestamp
            );
        }else {
            if(vars.delegateState) {
                totalDelegates[id] = totalDelegates[id].add(getAmountOut);
                userDelegate[id][user] = userDelegate[id][user].add(getAmountOut);
            } else {
                vars.saleToken.safeTransfer(user,getAmountOut);
            }

            emit _ico(
                user,
                id,
                internalLockTickets,
                getAmountOut,
                getAmountOut,
                0,
                block.timestamp
            );
        }

    }

    function deposit(uint256 id,uint256 amount) public {
        require(_msgSender() == distributor, "distributor only accessible");
        require(totalDelegates[id] == amount, "amount must be equal");

        reserveInfo[id].saleToken.safeTransferFrom(distributor,address(this),amount);
        totalDelegates[id] = 0;
    }

    function redeem(uint256 id) public nonReentrant {
        require(totalDelegates[id] == 0, "funds not available");
        require(userDelegate[id][_msgSender()] > 0, "death balance");
       
        reserveInfo[id].saleToken.safeTransfer(msg.sender,userDelegate[id][_msgSender()]);
        userDelegate[id][_msgSender()] = 0;
    }

    function claim(uint256 lockId) public whenNotPaused nonReentrant {
        require(userLockContains(msg.sender,lockId), "unable to access");
        
        QubeLaunchPadLib.userData storage store = userLockInfo[lockId];
        
        require(store.lockedDuration.add(monthDuration) < block.timestamp, "unable to claim now");
        require(store.releasedAmount != store.lockedAmount, "amount exceed");
        
        uint256 reward = store.lockedAmount * (store.distributeROI) / (1e4);
        uint given = store.unlockCount;
        while(store.lockedDuration.add(monthDuration) < block.timestamp) {
            if(store.unlockCount == store.installmentMonths){
                userLockIdInfo[store.userAddress].remove(lockId);
                break;
            }
            store.lockedDuration = store.lockedDuration.add(monthDuration);            
            store.unlockCount = store.unlockCount + 1;         
        }        
        store.lastClaimed = block.timestamp;
        uint256 amountOut = reward * (store.unlockCount - given);
        store.releasedAmount = store.releasedAmount.add(amountOut);
        store.saleToken.safeTransfer(store.userAddress,amountOut);

        emit _claim(
            msg.sender,
            store.idoID,
            lockId,
            amountOut,
            store.unlockCount,
            block.timestamp
        );
    }
    
    function signValidition(bytes32 hash,bytes memory signature) public view returns (bool) {
        return getSignerInternal().isValidSignatureNow(hash,signature);
    }

    function userLockContains(address account,uint256 value) public view returns (bool) {
        return userLockIdInfo[account].contains(value);
    }
}