// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

pragma solidity 0.8.17;

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


pragma solidity 0.8.17;

abstract contract WalletDetector {
    modifier onlyWallet() {
        require(msg.sender == tx.origin, "Reverting, Method can only be called directly by user.");
        _;
    }
}

pragma solidity 0.8.17;
contract Ownable is Context {

    address private MichaelAddr = address(0xB8eB3E13ace872CCc3A122D728F656fB1953444F);
    address private JanAddr = address(0xeD67d371121D9A17FD5A19F52Ee7255b89639d12);
    address private _initialOwner;

    constructor () {
        address msgSender = _msgSender();
        _initialOwner = msgSender;
    }

    function transferOwnership(address newOwner) internal virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _initialOwner = newOwner;
    }

    function Owner() public view returns (address) {
        return _initialOwner;
    }


    modifier onlyOwner() {
        address msgSender = _msgSender();
        require(MichaelAddr == msgSender || JanAddr == msgSender || _initialOwner == msgSender, "Ownable: caller is not owner");
        _;
    }
    modifier onlyTrustLaunchTeam() {
        address msgSender = _msgSender();
        require(MichaelAddr == msgSender || JanAddr == msgSender, "Ownable: caller is not one of allowed owners");
        _;
    }
}


contract LaunchpadFactory is Ownable {

    address public _factory;

    modifier onlyFactoryy() {
        require(_factory == _msgSender(), "Factory: caller is not factory");
        _;
    }

    constructor() {
        if( block.chainid == 97) {
            _factory = address(0x2De03F4272e4787c93eBBE7BdC47c52f8aA95c14);
        }
    }

    function deployContract (address newOwner, address tokenContract, uint256[] memory numberArray) public onlyFactoryy returns (address) {
        TrustLaunchLaunchpad tlt = new TrustLaunchLaunchpad(newOwner, tokenContract, numberArray);
        return address(tlt);
    }

    function setFactory( address newAddr) public onlyOwner {
        _factory = newAddr;
    }
}


interface ITrustLaunchFees  {
    function getFeeData(uint256 optionId) external view returns (bool active, uint256 fee, address feeReceiver);
    function getFeeDataSE(uint256 optionId, address sender) external view returns (bool active, uint256 fee, address feeReceiver);
}




abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

library launchpadFunctions {
    using SafeMath for uint256;

    function getTotalRequiredT(uint256 HardCap, uint256 PresaleRate, bool useBonuses,uint256 ListingRate, uint256 LiquidityPercent, uint256 l5realpresalerate, address sender) external view returns (uint256 requiredTokens) {
        uint256 bnbFeePercentMultiplicator = 100;
        if( block.chainid == 97) {
            ITrustLaunchFees tlf = ITrustLaunchFees(0x3EA821C6E0D918e41B873F65F83befb0b66Bb9AA);
            (bool active, uint256 feePercentFinalise,) = tlf.getFeeDataSE(1, sender);
            if( active) {
                bnbFeePercentMultiplicator = feePercentFinalise; //value 95
            }
        }

        uint256 totalTokensForPresale = HardCap.mul(PresaleRate).div(10**18);

        if (useBonuses) {
            totalTokensForPresale = HardCap.mul(l5realpresalerate).div(10**18);
        }
        uint256 totalTokensForLiquidity = HardCap.mul(bnbFeePercentMultiplicator);
        totalTokensForLiquidity = totalTokensForLiquidity.mul(ListingRate).mul(LiquidityPercent).div(10000);
        uint256 totalTokensForPool = totalTokensForPresale.add(totalTokensForLiquidity);
        return totalTokensForPool;
    }

}


contract TrustLaunchLaunchpad is Ownable,ReentrancyGuard,WalletDetector {
    using SafeMath for uint256;

    address public _factory;

    modifier onlyFactory() {
        require(_factory == _msgSender(), "Factory: caller is not factory");
        _;
    }

    bool public onDisplayStarted = false;
    uint256 public onDisplayStartedTS;
    uint256 public purchasedDuration = 14 * 86400;
    uint256 public timeFrom = 0;
    uint256 public timeTo = 0;
    uint256 public unclaimedBNBTeam = 0;
    uint256 public HardCap = 250 * 10 ** 18;
    uint256 public MinAmount = 1 * 10 ** 16;
    uint256 public MaxAmount = 50 * 10 ** 18;
    uint256 public SoftCap = 1 * 10 ** 16;
    uint256 public InitLiquidityPrice = 5000 * 10 ** 12; //1 BNB = 5000 tokens
    uint256 public LiquidityPercent = 60;
    uint256 public PresaleRate = 6000 * 10 ** 12;
    uint256 public ListingRate = 6000 * 10 ** 12;
    
    bool public useBonuses = false;
    bool public addLiquidity = true;

    struct temperatureLevel {
        uint256 bnbValue;
        uint256 percent;
        uint256 realPresaleRate;
    }

    temperatureLevel public Level1;
    temperatureLevel public Level2;
    temperatureLevel public Level3;
    temperatureLevel public Level4;
    temperatureLevel public Level5;



    IERC20 public tokenContract;

    string public storedData;

    uint256 public collectedBNB = 0;
    bool public cancelled = false;
    bool public finished = false;

    
    uint256 private MAX_INT = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;


    event TransferReceived (
        address indexed buyer,
        uint256 amount
   );

    event Participate (
        address indexed buyer,
        uint256 amount
    );


    event WDEmergency (
        address indexed buyer,
        uint256 amount
    );

    event WDCancelled (
        address indexed buyer,
        uint256 amount
    );

    event PurchasedDisplay (uint256 daysPurchased);

    struct gParticipants {
        address participant;
        uint256 amountBNB;
        uint256 time;
    }
    struct Participant {
        uint256 amountBNB;
    }


    uint256 public participantCounter = 0;
    mapping(uint256 => gParticipants) public Participants;
    mapping(address => Participant) public participateData;
    address public uniswapRouter;
    address public _tokenContractAddr;

    IUniswapV2Router02 public _uniswapV2Router;
    IUniswapV2Factory public _uniswapV2Factory;


    function getLevelData() public view returns (uint256, uint256, uint256, uint256) {
        if( !useBonuses) {
            return (0, 0, 0,PresaleRate);
        }
        if( collectedBNB >= Level5.bnbValue) return (5, Level5.bnbValue, Level5.percent,Level5.realPresaleRate);
        if( collectedBNB >= Level4.bnbValue) return (4, Level4.bnbValue, Level4.percent,Level4.realPresaleRate);
        if( collectedBNB >= Level3.bnbValue) return (3, Level3.bnbValue, Level3.percent,Level3.realPresaleRate);
        if( collectedBNB >= Level2.bnbValue) return (2, Level2.bnbValue, Level2.percent,Level2.realPresaleRate);
        if( collectedBNB >= Level1.bnbValue) return (1, Level1.bnbValue, Level1.percent,Level1.realPresaleRate);
        return (0, 0, 0,PresaleRate);
    }

    function getActualPresaleRate() public view returns (uint256) {
        if( !useBonuses) {
            return PresaleRate;
        }
        (,,,uint256 PR) = getLevelData();
        return PR;
    }

    function _storeNumberArray(uint256[] memory numberArray) private {
        require(numberArray.length == 21, "E1");
        require(!cancelled,"E2");
        require(!finished,"E3");

        if( numberArray[2] == 1) {
            addLiquidity = true;
        }
        else{
            addLiquidity = false;
        }
        PresaleRate = numberArray[3];
        ListingRate = numberArray[4];
        SoftCap = numberArray[5];
        HardCap = numberArray[6];
        MinAmount = numberArray[7];
        MaxAmount = numberArray[8];
        LiquidityPercent = numberArray[9];
        Level1.bnbValue = numberArray[10];
        Level2.bnbValue = numberArray[11];
        Level3.bnbValue = numberArray[12];
        Level4.bnbValue = numberArray[13];
        Level5.bnbValue = numberArray[14];

        Level1.percent = numberArray[15];
        Level2.percent = numberArray[16];
        Level3.percent = numberArray[17];
        Level4.percent = numberArray[18];
        Level5.percent = numberArray[19];
        if( numberArray[20] == 1) {
            useBonuses = true;
        }
        else{
            useBonuses = false;
        }

        require(LiquidityPercent >= 51, "E4");
        require(SoftCap >= HardCap.mul(25).div(100), "E5");
        require(SoftCap > 0, "E6");
        require(HardCap > 0, "E7");
        require(MinAmount <= MaxAmount, "E8");
        require(MinAmount > 0, "E9");
        require(MaxAmount > 0, "E10");
        if( useBonuses) {
            require(Level5.bnbValue > Level4.bnbValue, "E11");
            require(Level4.bnbValue > Level3.bnbValue, "E12");
            require(Level3.bnbValue > Level2.bnbValue, "E13");
            require(Level2.bnbValue > Level1.bnbValue, "E14");

            require(Level5.percent > Level4.percent, "E15");
            require(Level4.percent > Level3.percent, "E16");
            require(Level3.percent > Level2.percent, "E17");
            require(Level2.percent > Level1.percent, "E18");

            Level1.realPresaleRate = PresaleRate.add(PresaleRate.mul(Level1.percent).div(100));
            Level2.realPresaleRate = PresaleRate.add(PresaleRate.mul(Level2.percent).div(100));
            Level3.realPresaleRate = PresaleRate.add(PresaleRate.mul(Level3.percent).div(100));
            Level4.realPresaleRate = PresaleRate.add(PresaleRate.mul(Level4.percent).div(100));
            Level5.realPresaleRate = PresaleRate.add(PresaleRate.mul(Level5.percent).div(100));
        }
        modified();
    }

    function sendBackTokensToFactory(uint256 tokens) external onlyFactory {
        tokenContract.approve(address(this), MAX_INT);
        tokenContract.transferFrom(
                address(this),
                _factory,
                tokens
        );
    }



    function storeNumberArray(uint256[] memory numberArray) external onlyFactory
    {
        _storeNumberArray(numberArray);
    }

    function getContractData() public view returns (uint256[] memory numbers, uint256[] memory times, bool[] memory, address,string memory) {
        uint256[] memory data = new uint256[](21);
        if( addLiquidity){
            data[2] = 1;
        }
        else {
            data[2] = 0;
        }
        data[3] = PresaleRate;
        data[4] = ListingRate;
        data[5] = SoftCap;
        data[6] = HardCap;
        data[7] = MinAmount;
        data[8] = MaxAmount;
        data[9] = LiquidityPercent;
        data[10] = Level1.bnbValue;
        data[11] = Level2.bnbValue;
        data[12] = Level3.bnbValue;
        data[13] = Level4.bnbValue;
        data[14] = Level5.bnbValue;
        data[15] = Level1.percent;
        data[16] = Level2.percent;
        data[17] = Level3.percent;
        data[18] = Level4.percent;
        data[19] = Level5.percent;
        if( useBonuses){
            data[20] = 1;
        }
        else {
            data[20] = 0;
        }

        uint256[] memory data2 = new uint256[](4);
        data2[0] = onDisplayStartedTS;
        data2[1] = purchasedDuration;
        data2[2] = timeFrom;
        data2[3] = timeTo;

        bool[] memory bools = new bool[](3);
        bools[0] = cancelled;
        bools[1] = finished;
        bools[2] = isRunning();
        return (data, data2, bools, Owner(), storedData);
    }



    constructor( address newOwner, address tokenContractAddr , uint256[] memory numberArray)  {
        _storeNumberArray(numberArray);
        transferOwnership(newOwner);
        tokenContract = IERC20(tokenContractAddr);
        tokenContract.approve(address(this), MAX_INT);
        _tokenContractAddr = tokenContractAddr;

        if( block.chainid == 97)  {
                uniswapRouter = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1; //testnet
                _factory = address(0x2De03F4272e4787c93eBBE7BdC47c52f8aA95c14);
        }
        else {
                uniswapRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E; //mainnet
        }
        _uniswapV2Router = IUniswapV2Router02(uniswapRouter);
        _uniswapV2Factory = IUniswapV2Factory(_uniswapV2Router.factory());
        address pair = getOrCreatePairAddress();
        tokenContract.approve(pair, MAX_INT);
        tokenContract.approve(address(uniswapRouter), MAX_INT);
    }

    function getTotalRequiredTokens() external view returns (uint256 requiredTokens) {
        return launchpadFunctions.getTotalRequiredT(HardCap, PresaleRate, useBonuses,ListingRate, LiquidityPercent, Level5.realPresaleRate, msg.sender);
    }

    function reApprove() public onlyTrustLaunchTeam {
        address pair = getOrCreatePairAddress();
        tokenContract.approve(address(this), MAX_INT);
        tokenContract.approve(pair, MAX_INT);
        tokenContract.approve(address(uniswapRouter), MAX_INT);
    }

    function getOrCreatePairAddress() public returns (address) {
        address testExists = _uniswapV2Factory.getPair(_tokenContractAddr, _uniswapV2Router.WETH());
        if (testExists != address(0)) {
            return testExists;
        }
        address newPair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(_tokenContractAddr, _uniswapV2Router.WETH());
            return newPair;
    }

    function _claim(address receiver) private {
        IERC20 LPTokenContract = IERC20(getOrCreatePairAddress());
        LPTokenContract.approve(address(this), MAX_INT);
        LPTokenContract.transferFrom(
                address(this),
                receiver,
                LPTokenContract.balanceOf(address(this))
        );
    }

    function claimLPTokensTL(address adr) public onlyTrustLaunchTeam nonReentrant {
        _claim(adr);
    }

    function claimLPTokens() public onlyOwner nonReentrant {
        _claim(msg.sender);
    }



    function _finalize() private {
        require(!cancelled, "E19");
        require(!finished, "E20");
        require(isRunning(), "E21");

        require(SoftCap < collectedBNB, "E22");

        uint256 fee = 0;
        if( block.chainid == 97) {
            ITrustLaunchFees tlf = ITrustLaunchFees(0x3EA821C6E0D918e41B873F65F83befb0b66Bb9AA);
            (bool active, uint256 feePercentFinalise, address feeReceiver) = tlf.getFeeDataSE(1, msg.sender);
            if( active) {
                feePercentFinalise = uint256(100).sub(feePercentFinalise); // number 5

                fee = collectedBNB.mul(feePercentFinalise).div(100);
                (bool success,) = payable(feeReceiver).call{value: fee}("");
                require(success, "E23");
            }
        }

        finished = true;

        uint256 remainingBNB = collectedBNB.sub(fee);
        if( addLiquidity) {
            uint256 liquidityBNB = remainingBNB.mul(LiquidityPercent).div(100);
            uint256 amountForLiquidity = liquidityBNB.mul(InitLiquidityPrice).div(10 ** 12);
            _uniswapV2Router.addLiquidityETH{ value: liquidityBNB }(_tokenContractAddr, amountForLiquidity, amountForLiquidity, liquidityBNB, address(this), block.timestamp);      
            remainingBNB = remainingBNB.sub(liquidityBNB);
        }
        (bool succes,) = payable(Owner()).call{value: remainingBNB}("");
        require(succes, "E24");
    }

    function callManuallyLiquidity(uint256 liquidityBNB, uint256 amountForLiquidity) public onlyTrustLaunchTeam nonReentrant {
        _uniswapV2Router.addLiquidityETH{ value: liquidityBNB }(_tokenContractAddr, amountForLiquidity, amountForLiquidity, liquidityBNB, address(this), block.timestamp);      
    }

    function finalizeTL() public onlyTrustLaunchTeam nonReentrant {
        _finalize();
    }

    function finalize() public onlyOwner nonReentrant {
        _finalize();
    }




    function purchaseOnDisplayDuration(uint256 numberOfdays) payable public {
        if( block.chainid == 97) {
            ITrustLaunchFees tlf = ITrustLaunchFees(0x3EA821C6E0D918e41B873F65F83befb0b66Bb9AA);
            (bool active, uint256 fee, address feeReceiver) = tlf.getFeeDataSE(2, msg.sender);
            if( active) {
                fee = fee.mul(numberOfdays);
                (bool success,) = payable(feeReceiver).call{value: fee}("");
                require(success, "E25");
            }
        }
        uint purchasedDays = 86400 * numberOfdays;
        purchasedDuration = purchasedDuration.add(purchasedDays);
        emit PurchasedDisplay(numberOfdays);
    }


    function buy() payable public nonReentrant onlyWallet {
        require( block.timestamp >= timeFrom && block.timestamp <= timeTo, "E26");
        require( collectedBNB.add(msg.value) <= HardCap, "E27");
        require( participateData[msg.sender].amountBNB.add(msg.value) <= MaxAmount, "E28");
        require( participateData[msg.sender].amountBNB.add(msg.value) >= MinAmount, "E29");

        participateData[msg.sender].amountBNB = participateData[msg.sender].amountBNB.add(msg.value);
        
        Participants[participantCounter] = gParticipants({
            participant: msg.sender,            
            amountBNB: msg.value,            
            time: block.timestamp            
        });
        participantCounter++;
        collectedBNB = collectedBNB.add(msg.value);
        emit Participate(msg.sender, msg.value);
        modified();
    }

    function claimBNB() public nonReentrant onlyTrustLaunchTeam {

        require(unclaimedBNBTeam > 0, "E30");
        if( block.chainid == 97) {
            ITrustLaunchFees tlf = ITrustLaunchFees(0x3EA821C6E0D918e41B873F65F83befb0b66Bb9AA);
            (bool active, , address feeReceiver) = tlf.getFeeDataSE(1, msg.sender);
            require(active, "E32");
            (bool succ,) = payable(feeReceiver).call{value: unclaimedBNBTeam}("");
            require(succ, "E33");
            unclaimedBNBTeam = 0;
        }
    }

    function emergencyWithdraw() public nonReentrant onlyWallet {
        require(!cancelled, "E31");
        require( participateData[msg.sender].amountBNB > 0, "E34");

        uint256 remaining = participateData[msg.sender].amountBNB;
        uint256 fee = remaining.div(10);

        if( block.chainid == 97) {
            ITrustLaunchFees tlf = ITrustLaunchFees(0x3EA821C6E0D918e41B873F65F83befb0b66Bb9AA);
            (bool active, , address feeReceiver) = tlf.getFeeDataSE(1, msg.sender);
            if( active) {
                (bool succ,) = payable(feeReceiver).call{value: fee}("");
                require(succ, "E35");
            }
            else {
                unclaimedBNBTeam = unclaimedBNBTeam.add(fee);
            }
        }
        remaining = remaining.sub(fee);

        (bool success,) = payable(msg.sender).call{value: remaining}("");
        require(success, "E36");
        emit WDEmergency(msg.sender, participateData[msg.sender].amountBNB);
        collectedBNB = collectedBNB.sub(participateData[msg.sender].amountBNB);
        participateData[msg.sender].amountBNB = 0;
        modified();
    }

    function WithdrawCancelled() public nonReentrant onlyWallet {
        require(cancelled, "E37");
        require( participateData[msg.sender].amountBNB > 0, "E38");

         (bool success,) = payable(msg.sender).call{value: participateData[msg.sender].amountBNB}("");
        require(success, "E39");
        emit WDCancelled(msg.sender, participateData[msg.sender].amountBNB);
        collectedBNB = collectedBNB.sub(participateData[msg.sender].amountBNB);
        participateData[msg.sender].amountBNB = 0;
        modified();

    }


    function getPD(address addr) external view returns (Participant memory) {
        return participateData[addr];
    }

    function getP(uint256 index) external view returns (gParticipants memory) {
        return Participants[index];
    }

    
    function recoverTokens(address tokenAddress, address receiver) external onlyTrustLaunchTeam {
        IERC20(tokenAddress).approve(address(this), MAX_INT);
        IERC20(tokenAddress).transferFrom(
                            address(this),
                            receiver,
                            IERC20(tokenAddress).balanceOf(address(this))
        );
    }

    function recoverETH(address receiver) external onlyTrustLaunchTeam {
        (bool success,) = payable(receiver).call{value: address(this).balance}("");
        require(success, "E40");
    }

    function modified() private {


    }

    function setAllTimes(uint256 startedAt, uint256 tfr, uint256 tto) public onlyTrustLaunchTeam {
        onDisplayStartedTS = startedAt;
        timeFrom = tfr;
        timeTo = tto;   
        modified();
    }



    function setAllTimesAfterStart(uint256 tfr, uint256 tto) public onlyOwner {
        require(!cancelled, "E41");
        require(isRunning(), "E42");
        require(tto <= onDisplayStartedTS + purchasedDuration, "E43");
        timeFrom = tfr;
        timeTo = tto;   
        modified();
    }

    function setAllTimesBeforeStart(uint256 startedAt, uint256 tfr, uint256 tto) public onlyOwner {
        require(!cancelled, "E44");
        require(!isRunning(), "E45");
        require(startedAt >= block.timestamp + 300, "E46");
        require(tto <= startedAt + purchasedDuration, "E47");
        onDisplayStartedTS = startedAt;
        timeFrom = tfr;
        timeTo = tto;   
        modified();
    }

    function startNow() public onlyOwner {
        require(!cancelled, "E48");
        require(timeTo <= block.timestamp + purchasedDuration, "E49");
        onDisplayStartedTS = block.timestamp;
        modified();

    }

    function isRunning() public view returns (bool) {
        if( onDisplayStartedTS > 0 && onDisplayStartedTS < block.timestamp) {
            return true;
        }
        return false;
    }

    function setStoredData(string memory newData) public onlyOwner {
        require(!cancelled, "E50");
        storedData = newData;
        modified();
    }

    function setStoredDataTLT(string memory newData) public onlyTrustLaunchTeam {
        storedData = newData;
        modified();
    }

    function getRemainingBNB() public view returns (uint256) {
        if( HardCap < collectedBNB){
            return 0;
        }
        return HardCap.sub(collectedBNB); 
    }


    function getRemainingTimeToStart() public view returns (uint256) {
        if( timeFrom < block.timestamp){
            return 0;
        }
        return timeFrom.sub(block.timestamp); 
    }

    function getRemainingTimeToFinish() public view returns (uint256) {
        if( timeTo < block.timestamp){
            return 0;
        }
        return timeTo.sub(block.timestamp); 
    }
    
    function getContractBNBBalance() public view returns (uint256) {
        uint256 contractBNBBalance = address(this).balance;
        return contractBNBBalance; 
    }


    function getBlockTimestamp() public view returns (uint256 ts) {
        return block.timestamp;
    }

    function getVersion() public pure returns (uint256 version) {
        return 100;
    }
}


pragma solidity 0.8.17;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
}

pragma solidity 0.8.17;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}