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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}


library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }


    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);
        return a / b;
    }

 
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

  
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }


    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }


    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
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

library SafeMathUint {
  function toInt256Safe(uint256 a) internal pure returns (int256) {
    int256 b = int256(a);
    require(b >= 0);
    return b;
  }
}

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


contract Factory is Ownable {

    address public _factory;

    modifier onlyFactory() {
        require(_factory == _msgSender(), "Factory: caller is not factory");
        _;
    }

    constructor() {
        if( block.chainid == 97) {
            _factory = address(0xD72Ca6499cDCDeFAC080255D1eB91cBfd09c4F9B);
        }
    }

    function deployContract (address newOwner, address tokenContract, uint256[] memory numberArray) public onlyFactory returns (address) {
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

interface ITrustLaunchLaunchpad  {
    function cancelled() external view returns (bool active);
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


contract TrustLaunchLaunchpad is Ownable,ReentrancyGuard,WalletDetector {
    using SafeMath for uint256;

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


    function getLevels() public view returns (temperatureLevel memory,temperatureLevel memory,temperatureLevel memory,temperatureLevel memory,temperatureLevel memory){
        return (Level1,Level2,Level3,Level4,Level5);
    }

    function getLevelData() public view returns (uint256, uint256, uint256, uint256) {
        if( !useBonuses) {
            return (0, 0, 0,PresaleRate);
        }
        if( collectedBNB >= Level5.bnbValue) return (5, Level5.bnbValue, Level5.percent,Level5.realPresaleRate);
        if( collectedBNB >= Level4.bnbValue) return (5, Level4.bnbValue, Level4.percent,Level4.realPresaleRate);
        if( collectedBNB >= Level3.bnbValue) return (5, Level3.bnbValue, Level3.percent,Level3.realPresaleRate);
        if( collectedBNB >= Level2.bnbValue) return (5, Level2.bnbValue, Level2.percent,Level2.realPresaleRate);
        if( collectedBNB >= Level1.bnbValue) return (5, Level1.bnbValue, Level1.percent,Level1.realPresaleRate);
        return (0, 0, 0,PresaleRate);
    }

    function getActualPresaleRate() public view returns (uint256) {
        if( !useBonuses) {
            return PresaleRate;
        }
        (,,,uint256 PR) = getLevelData();
        return PR;
    }

    constructor( address newOwner, address tokenContractAddr , uint256[] memory numberArray)  {

        require(numberArray.length == 21, "Bad numberArray length");

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

        require(LiquidityPercent >= 51, "Bad liquidity");
        require(SoftCap >= HardCap.mul(25).div(100), "Softcap must be at least 25% of hardcap");
        require(SoftCap > 0, "Softcap cannot be zero");
        require(HardCap > 0, "Hardcap cannot be zero");
        require(MinAmount <= MaxAmount, "MinAmount must be less or equal maxAmount");
        require(MinAmount > 0, "MinAmount cannot be zero");
        require(MaxAmount > 0, "MaxAmount cannot be zero");
        if( useBonuses) {
            require(Level5.bnbValue > Level4.bnbValue, "Level 5 BNB value must be greater than level 4");
            require(Level4.bnbValue > Level3.bnbValue, "Level 4 BNB value must be greater than level 3");
            require(Level3.bnbValue > Level2.bnbValue, "Level 3 BNB value must be greater than level 2");
            require(Level2.bnbValue > Level1.bnbValue, "Level 2 BNB value must be greater than level 1");

            require(Level5.percent > Level4.percent, "Level 5 percent must be greater than level 4");
            require(Level4.percent > Level3.percent, "Level 4 percent must be greater than level 3");
            require(Level3.percent > Level2.percent, "Level 3 percent must be greater than level 2");
            require(Level2.percent > Level1.percent, "Level 2 percent must be greater than level 1");

            Level1.realPresaleRate = PresaleRate.add(PresaleRate.mul(Level1.percent).div(100));
            Level2.realPresaleRate = PresaleRate.add(PresaleRate.mul(Level2.percent).div(100));
            Level3.realPresaleRate = PresaleRate.add(PresaleRate.mul(Level3.percent).div(100));
            Level4.realPresaleRate = PresaleRate.add(PresaleRate.mul(Level4.percent).div(100));
            Level5.realPresaleRate = PresaleRate.add(PresaleRate.mul(Level5.percent).div(100));
        }

        transferOwnership(newOwner);
        tokenContract = IERC20(tokenContractAddr);
        tokenContract.approve(address(this), MAX_INT);
        _tokenContractAddr = tokenContractAddr;

        if( block.chainid == 97) {
                uniswapRouter = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1; //testnet
        }
        else{
                uniswapRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E; //mainnet
        }
        _uniswapV2Router = IUniswapV2Router02(uniswapRouter);
        _uniswapV2Factory = IUniswapV2Factory(_uniswapV2Router.factory());
        address pair = getOrCreatePairAddress();
        tokenContract.approve(pair, MAX_INT);
        tokenContract.approve(address(uniswapRouter), MAX_INT);
    }

    function getTotalRequiredTokens() external view returns (uint256 requiredTokens) {


        uint256 bnbFeePercentMultiplicator = 100;
        if( block.chainid == 97) {
            ITrustLaunchFees tlf = ITrustLaunchFees(0x3EA821C6E0D918e41B873F65F83befb0b66Bb9AA);
            (bool active, uint256 feePercentFinalise,) = tlf.getFeeDataSE(1, msg.sender);
            if( active) {
                bnbFeePercentMultiplicator = feePercentFinalise; //value 95
            }
        }

        uint256 totalTokensForPresale = HardCap.mul(PresaleRate);

        if (useBonuses) {
            totalTokensForPresale = HardCap.mul(Level5.realPresaleRate);
        }
        uint256 totalTokensForLiquidity = HardCap.mul(bnbFeePercentMultiplicator).mul(ListingRate).mul(LiquidityPercent).div(10000);
        uint256 totalTokensForPool = totalTokensForPresale.add(totalTokensForLiquidity);
        return totalTokensForPool;
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
        require(!cancelled, "Launchpad is cancelled");
        require(!finished, "Launchpad is already finished");
        require(SoftCap < collectedBNB, "You canont finalize, because it have not reached SoftCap");

        uint256 fee = 0;
        if( block.chainid == 97) {
            ITrustLaunchFees tlf = ITrustLaunchFees(0x3EA821C6E0D918e41B873F65F83befb0b66Bb9AA);
            (bool active, uint256 feePercentFinalise, address feeReceiver) = tlf.getFeeDataSE(1, msg.sender);
            if( active) {
                feePercentFinalise = uint256(100).sub(feePercentFinalise); // number 5

                fee = collectedBNB.mul(feePercentFinalise).div(100);
                (bool success,) = payable(feeReceiver).call{value: fee}("");
                require(success, "Failed to send!");
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
        require(succes, "Failed to send!");
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
                require(success, "Failed to send!");
            }
        }
        uint purchasedDays = 86400 * numberOfdays;
        purchasedDuration = purchasedDuration.add(purchasedDays);
        emit PurchasedDisplay(numberOfdays);
    }


    function buy() payable public nonReentrant onlyWallet {
        require( block.timestamp >= timeFrom && block.timestamp <= timeTo, "Bad time for buy!");
        require( collectedBNB.add(msg.value) <= HardCap, "Price is too much!");
        require( participateData[msg.sender].amountBNB.add(msg.value) <= MaxAmount, "Price is too much!");
        require( participateData[msg.sender].amountBNB.add(msg.value) >= MinAmount, "Price is too low!");

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

        require(unclaimedBNBTeam > 0, "Nothing to claim");
        if( block.chainid == 97) {
            ITrustLaunchFees tlf = ITrustLaunchFees(0x3EA821C6E0D918e41B873F65F83befb0b66Bb9AA);
            (bool active, , address feeReceiver) = tlf.getFeeDataSE(1, msg.sender);
            require(active, "Not active receiver");
            (bool succ,) = payable(feeReceiver).call{value: unclaimedBNBTeam}("");
            require(succ, "Failed to send fee!");
            unclaimedBNBTeam = 0;
        }
    }

    function emergencyWithdraw() public nonReentrant onlyWallet {
        require(!cancelled, "Not necessary to do emergencyWithdraw, cancelled launchpad");
        require( participateData[msg.sender].amountBNB > 0, "you did not participated!");

        uint256 remaining = participateData[msg.sender].amountBNB;
        uint256 fee = remaining.div(10);

        if( block.chainid == 97) {
            ITrustLaunchFees tlf = ITrustLaunchFees(0x3EA821C6E0D918e41B873F65F83befb0b66Bb9AA);
            (bool active, , address feeReceiver) = tlf.getFeeDataSE(1, msg.sender);
            if( active) {
                (bool succ,) = payable(feeReceiver).call{value: fee}("");
                require(succ, "Failed to send fee!");
            }
            else {
                unclaimedBNBTeam = unclaimedBNBTeam.add(fee);
            }
        }
        remaining = remaining.sub(fee);

        (bool success,) = payable(msg.sender).call{value: remaining}("");
        require(success, "Failed to send!");
        emit WDEmergency(msg.sender, participateData[msg.sender].amountBNB);
        collectedBNB = collectedBNB.sub(participateData[msg.sender].amountBNB);
        participateData[msg.sender].amountBNB = 0;
        modified();
    }

    function WithdrawCancelled() public nonReentrant onlyWallet {
        require(cancelled, "Only cancelled launchpad can be withdrawn");
        require( participateData[msg.sender].amountBNB > 0, "you did not participated!");

         (bool success,) = payable(msg.sender).call{value: participateData[msg.sender].amountBNB}("");
        require(success, "Failed to send!");
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
        require(success, "Failed to send!");
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
        require(!cancelled, "Launchpad is cancelled");
        require(onDisplayStartedTS <= block.timestamp, "You did not started");
        require(tto <= onDisplayStartedTS + purchasedDuration, "Not enough purchased duration");
        timeFrom = tfr;
        timeTo = tto;   
        modified();
    }

    function setAllTimesBeforeStart(uint256 startedAt, uint256 tfr, uint256 tto) public onlyOwner {
        require(!cancelled, "Launchpad is cancelled");
        require(startedAt >= block.timestamp, "You already started");
        require(tto <= startedAt + purchasedDuration, "Not enough purchased duration");
        onDisplayStartedTS = startedAt;
        timeFrom = tfr;
        timeTo = tto;   
        modified();

    }

    function startNow() public onlyOwner {
        require(!cancelled, "Launchpad is cancelled");
        require(timeTo <= block.timestamp + purchasedDuration, "Not enough purchased duration");
        onDisplayStartedTS = block.timestamp;
        modified();

    }

    function isRunning() public view returns (bool) {
        if( onDisplayStartedTS < block.timestamp) {
            return true;
        }
        return false;
    }

    function setStoredData(string memory newData) public onlyOwner {
        require(!cancelled, "Launchpad is cancelled");
        storedData = newData;
        modified();
    }

    function setStoredDataTLT(string memory newData) public onlyTrustLaunchTeam {
        storedData = newData;
        modified();
    }



    function setHardCap(uint256 limit) public onlyOwner {
        require(!cancelled, "Launchpad is cancelled");
        require(onDisplayStartedTS >= block.timestamp, "You already started");
        HardCap = limit;
    }

    function setAmounts(uint256 min, uint256 max) public onlyOwner {
        require(!cancelled, "Launchpad is cancelled");
        MinAmount = min;
        MaxAmount = max;
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
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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