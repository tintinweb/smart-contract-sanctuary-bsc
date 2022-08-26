/**
 *Submitted for verification at BscScan.com on 2022-08-25
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: @chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol


pragma solidity ^0.8.0;

interface KeeperCompatibleInterface {
  /**
   * @notice method that is simulated by the keepers to see if any work actually
   * needs to be performed. This method does does not actually need to be
   * executable, and since it is only ever simulated it can consume lots of gas.
   * @dev To ensure that it is never called, you may want to add the
   * cannotExecute modifier from KeeperBase to your implementation of this
   * method.
   * @param checkData specified in the upkeep registration so it is always the
   * same for a registered upkeep. This can easilly be broken down into specific
   * arguments using `abi.decode`, so multiple upkeeps can be registered on the
   * same contract and easily differentiated by the contract.
   * @return upkeepNeeded boolean to indicate whether the keeper should call
   * performUpkeep or not.
   * @return performData bytes that the keeper should call performUpkeep with, if
   * upkeep is needed. If you would like to encode data to decode later, try
   * `abi.encode`.
   */
  function checkUpkeep(bytes calldata checkData) external returns (bool upkeepNeeded, bytes memory performData);

  /**
   * @notice method that is actually executed by the keepers, via the registry.
   * The data returned by the checkUpkeep simulation will be passed into
   * this method to actually be executed.
   * @dev The input to this method should not be trusted, and the caller of the
   * method should not even be restricted to any single registry. Anyone should
   * be able call it, and the input should be validated, there is no guarantee
   * that the data passed in is the performData returned from checkUpkeep. This
   * could happen due to malicious keepers, racing keepers, or simply a state
   * change while the performUpkeep transaction is waiting for confirmation.
   * Always validate the data passed in.
   * @param performData is the data which was passed back from the checkData
   * simulation. If it is encoded, it can easily be decoded into other types by
   * calling `abi.decode`. This data should not be trusted, and should be
   * validated against the contract's current state.
   */
  function performUpkeep(bytes calldata performData) external;
}

// File: @chainlink/contracts/src/v0.8/KeeperBase.sol


pragma solidity ^0.8.0;

contract KeeperBase {
  error OnlySimulatedBackend();

  /**
   * @notice method that allows it to be simulated via eth_call by checking that
   * the sender is the zero address.
   */
  function preventExecution() internal view {
    if (tx.origin != address(0)) {
      revert OnlySimulatedBackend();
    }
  }

  /**
   * @notice modifier that allows it to be simulated via eth_call by checking
   * that the sender is the zero address.
   */
  modifier cannotExecute() {
    preventExecution();
    _;
  }
}

// File: @chainlink/contracts/src/v0.8/KeeperCompatible.sol


pragma solidity ^0.8.0;



abstract contract KeeperCompatible is KeeperBase, KeeperCompatibleInterface {}

// File: Keeper.sol


pragma solidity ^0.8.0;

// Farmageddon Lottery Keeper Automation 

// KeeperCompatible.sol imports the functions from both ./KeeperBase.sol and
// ./interfaces/KeeperCompatibleInterface.sol



interface Flottery {
    function startLottery(uint256, uint256, uint256, uint256[6] calldata, uint256) external;
    function closeLottery(uint256) external;
    function drawFinalNumberAndMakeLotteryClaimable(uint256, bool) external;
    function viewCurrentLotteryId() external returns (uint256);
}
interface ChainLink {
    function addFunds(uint256 id, uint96 amount) external;
}
interface PegSwap {
    function swap(uint256 amount, address source, address target ) external;
}
interface Router {
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
}
interface token {
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
     function approve(address spender, uint256 amount) external returns (bool);
     function transfer(address recipient, uint256 amount) external returns (bool);
}

// 

contract FarmageddonLottoKeeper is KeeperCompatibleInterface, Ownable {

    address bnb = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address linkPeg = 0xF8A0BF9cF54Bb92F17374d9e9A321E6a111a51bD;
    address LINK = 0x404460C6A5EdE2D891e8297795264fDe62ADBB75;
    address pegSwap = 0x1FCc3B22955e76Ca48bF025f1A6993685975Bb9e;

    Router router = Router(0x85CD4913537eC4d187fc85150d28A40892304Fe1);
    PegSwap pegswap = PegSwap(pegSwap);
    ChainLink oracle;
    address oracleAddress;
    address treasury = 0x9ac1A7751335656C44723B5E9Ed62571fc763c11;
    uint256 bnbToCL = 10000000000000000;
    uint256 keeper;
    // initialize variables for lottery
    struct Lottery {
        Flottery LotteryAddress;
        uint256 fticketPrice;
        uint256 fdiscount;
        uint256[6] frewardsBreakdown;
        uint256 ftreasuryFee;
        uint256 intervalSeconds; // how long should the lottery last before drawing
        uint256 upKeepTime;
        uint256 drawTime;         // Time of next upkeep
        uint256 step; 
        bool Pause;
        bool isLive;
        uint256 fcurrentLotteryId;
        uint256 numberOfDraws;
        uint256 bnbFee;
    }
    mapping(address => Lottery) public lotteries;
    mapping(address => bool) public isLottery;
    address[] public lotteryList;
    
    function ASetKeeper(uint256 id, address _oracle) external onlyOwner {
        keeper = id;
        oracle = ChainLink(_oracle);
        oracleAddress = _oracle;
    }
    

    function setStep(address lottery, uint _step)external onlyOwner{
        lotteries[lottery].step = _step;
    }
    function changeRouter(address newRouter) external onlyOwner {
        router = Router(newRouter);
    }
    function changeBNBToClFee(uint256 _bnbToCL) external onlyOwner {
        bnbToCL = _bnbToCL;
    }
    function changeTreasury(address _treasury) external onlyOwner {
        treasury = _treasury;
    }

    function fundCLAdmin(address lottery, uint256 _numberOfDrawsToAdd) external payable {
        require(msg.value >= lotteries[lottery].bnbFee * _numberOfDrawsToAdd, "not enough bnb");
        lotteries[lottery].numberOfDraws += _numberOfDrawsToAdd;
        
        address[] memory path1 = new address[](2);
            path1[0] = bnb;
            path1[1] = linkPeg;
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: (bnbToCL*_numberOfDrawsToAdd)}(0,path1,address(this),block.timestamp);
            uint256 peggedAmount = token(linkPeg).balanceOf(address(this));
        checkAllowance(linkPeg, peggedAmount, pegSwap);
        pegswap.swap(peggedAmount,linkPeg,LINK);
            uint96 link = uint96(token(LINK).balanceOf(address(this)));
        checkAllowance(LINK, link, oracleAddress);
        oracle.addFunds(keeper, link);
        payable(treasury).transfer(address(this).balance);
    }
    function extendLottery() external payable onlyOwner {
        address[] memory path1 = new address[](2);
            path1[0] = bnb;
            path1[1] = linkPeg;
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(0,path1,address(this),block.timestamp);
            uint256 peggedAmount = token(linkPeg).balanceOf(address(this));
        checkAllowance(linkPeg, peggedAmount, pegSwap);
        pegswap.swap(peggedAmount,linkPeg,LINK);
            uint96 link = uint96(token(LINK).balanceOf(address(this)));
        checkAllowance(LINK, link, oracleAddress);
        oracle.addFunds(keeper, link);
        payable(treasury).transfer(address(this).balance);
    }

    function addToNumberOfDrawsAdmin(address lottery, uint256 _numberOfDrawsToAdd) external onlyOwner {
        lotteries[lottery].numberOfDraws += _numberOfDrawsToAdd;
    }
    function changeLotteryTicketPrice(address lottery, uint256 _priceTicketInToken) external onlyOwner {
        lotteries[lottery].fticketPrice = _priceTicketInToken;
    }
    function changeLotteryBNBFee(address lottery, uint256 newFee) external onlyOwner {
        lotteries[lottery].bnbFee = newFee;
    }

    function removeLottery(address lottery) external onlyOwner {
        require(isLottery[lottery], "not a lottery");
        for(uint i=0; i<lotteryList.length; i++) {
            if(lotteryList[i] == lottery) {
                lotteryList[i] = lotteryList[lotteryList.length -1];
                lotteryList.pop();
                isLottery[lottery] = false;
            }
        }
    }

    function editLotteryInfo(
        address _lotteryAddress,
        uint256 _intervalSeconds,
        uint256 _priceTicketInToken,
        uint256 _discountDivisor,
        uint256[6] calldata _rewardsBreakdown,
        uint256 _treasuryFee
    ) external onlyOwner {
        require(
            (_rewardsBreakdown[0] +
                _rewardsBreakdown[1] +
                _rewardsBreakdown[2] +
                _rewardsBreakdown[3] +
                _rewardsBreakdown[4] +
                _rewardsBreakdown[5]) == 10000,
            "Rewards must equal 10000"
        );
        lotteries[_lotteryAddress].intervalSeconds = _intervalSeconds;
        lotteries[_lotteryAddress].fticketPrice = _priceTicketInToken;
        lotteries[_lotteryAddress].fdiscount = _discountDivisor;
        lotteries[_lotteryAddress].frewardsBreakdown = _rewardsBreakdown;
        lotteries[_lotteryAddress].ftreasuryFee = _treasuryFee;
    } 
    function addStartedLottery(
        address _lotteryAddress,
        uint256 _intervalSeconds,
        uint256 _priceTicketInToken,
        uint256 _discountDivisor,
        uint256[6] calldata _rewardsBreakdown,
        uint256 _treasuryFee,
        uint256 _step,
        uint256 _numberOfDraws,
        uint256 _upKeepTime
    ) external onlyOwner {
        require(!isLottery[_lotteryAddress], "already added");
        lotteryList.push(_lotteryAddress);
        isLottery[_lotteryAddress] = true;
        lotteries[_lotteryAddress].LotteryAddress = Flottery(_lotteryAddress);
        require(
            (_rewardsBreakdown[0] +
                _rewardsBreakdown[1] +
                _rewardsBreakdown[2] +
                _rewardsBreakdown[3] +
                _rewardsBreakdown[4] +
                _rewardsBreakdown[5]) == 10000,
            "Rewards must equal 10000"
        );
        lotteries[_lotteryAddress].intervalSeconds = _intervalSeconds;
        lotteries[_lotteryAddress].fticketPrice = _priceTicketInToken;
        lotteries[_lotteryAddress].fdiscount = _discountDivisor;
        lotteries[_lotteryAddress].frewardsBreakdown = _rewardsBreakdown;
        lotteries[_lotteryAddress].ftreasuryFee = _treasuryFee;
        lotteries[_lotteryAddress].step = _step;
        lotteries[_lotteryAddress].isLive = true;
        lotteries[_lotteryAddress].Pause = false;
        lotteries[_lotteryAddress].numberOfDraws = _numberOfDraws;
        lotteries[_lotteryAddress].bnbFee = 62500000000000000;
        lotteries[_lotteryAddress].upKeepTime = _upKeepTime;
        lotteries[_lotteryAddress].drawTime = _upKeepTime;
    } 

    function addLottery(
        address _lotteryAddress,
        uint256 _intervalSeconds,
        uint256 _priceTicketInToken,
        uint256 _discountDivisor,
        uint256[6] calldata _rewardsBreakdown,
        uint256 _treasuryFee
    ) external onlyOwner {
        require(!isLottery[_lotteryAddress], "already added");
        lotteryList.push(_lotteryAddress);
        isLottery[_lotteryAddress] = true;
        lotteries[_lotteryAddress].LotteryAddress = Flottery(_lotteryAddress);
        require(
            (_rewardsBreakdown[0] +
                _rewardsBreakdown[1] +
                _rewardsBreakdown[2] +
                _rewardsBreakdown[3] +
                _rewardsBreakdown[4] +
                _rewardsBreakdown[5]) == 10000,
            "Rewards must equal 10000"
        );
        lotteries[_lotteryAddress].intervalSeconds = _intervalSeconds;
        lotteries[_lotteryAddress].fticketPrice = _priceTicketInToken;
        lotteries[_lotteryAddress].fdiscount = _discountDivisor;
        lotteries[_lotteryAddress].frewardsBreakdown = _rewardsBreakdown;
        lotteries[_lotteryAddress].ftreasuryFee = _treasuryFee;
        lotteries[_lotteryAddress].step = 0;
        lotteries[_lotteryAddress].isLive = true;
        lotteries[_lotteryAddress].Pause = true;
        lotteries[_lotteryAddress].numberOfDraws = 0;
        lotteries[_lotteryAddress].bnbFee = 62500000000000000;
    } 

    // Set lottery to not restart after drawing next lottery
    function pauseLotteryAfterNextDraw(address lottery) external onlyOwner {
        require(lotteries[lottery].step > 0, "Lottery Already Paused");
        lotteries[lottery].Pause = true;
    }

    function cancelLottery(address lottery) external onlyOwner {
        require(lotteries[lottery].step > 0, "Lottery Already Paused");
        lotteries[lottery].Pause = true;
        lotteries[lottery].isLive = false;
    }

    // resume lottery 
    function UnpauseAndStartNextLottery(address lottery, uint256 _NextLotteryEndTime, uint256 addHowManyDraws) external onlyOwner {
        require(lotteries[lottery].step == 0, "Lottery Not Paused, Or has not Ended yet");
        lotteries[lottery].Pause = false;
        lotteries[lottery].LotteryAddress.startLottery(_NextLotteryEndTime, lotteries[lottery].fticketPrice, lotteries[lottery].fdiscount, lotteries[lottery].frewardsBreakdown, lotteries[lottery].ftreasuryFee);
        lotteries[lottery].fcurrentLotteryId = lotteries[lottery].LotteryAddress.viewCurrentLotteryId();
        lotteries[lottery].upKeepTime = _NextLotteryEndTime;
        lotteries[lottery].drawTime = _NextLotteryEndTime;
        lotteries[lottery].step = 1;
        lotteries[lottery].numberOfDraws += addHowManyDraws;
        lotteries[lottery].isLive = true;
    }

    function upKeepDue() public view returns (address lottery, bool upkeepNeeded) {
        for(uint i=0; i < lotteryList.length; i++) {
            bool isNeeded = block.timestamp >= lotteries[lotteryList[i]].upKeepTime && lotteries[lotteryList[i]].step > 0;
            if (isNeeded) return(lotteryList[i],isNeeded);
        }
    }

    function checkUpkeep(bytes calldata) view external override returns (bool upkeepNeeded, bytes memory) {
        // perform upkeep when timestamp is equal or more than upkeepTime
        (,upkeepNeeded) = upKeepDue();
    }

    // Function for Chainlink Keeper calls to perfrom lottery actiona
    function performUpkeep(bytes calldata /* performData */) external override {
        (address lottery,bool upkeepNeeded) = upKeepDue();
        require (upkeepNeeded, "UpKeep not needed, or has been Stopped");
        if (lotteries[lottery].step == 1) {
            lotteries[lottery].LotteryAddress.closeLottery(lotteries[lottery].fcurrentLotteryId);
            lotteries[lottery].step = 2;
            lotteries[lottery].upKeepTime = block.timestamp + 300;
            
            }

        else if (lotteries[lottery].step == 2) {
            lotteries[lottery].LotteryAddress.drawFinalNumberAndMakeLotteryClaimable(lotteries[lottery].fcurrentLotteryId, lotteries[lottery].isLive);
            lotteries[lottery].step = 3;
            lotteries[lottery].numberOfDraws -= 1; 
            lotteries[lottery].upKeepTime = block.timestamp + 300;
                if (lotteries[lottery].numberOfDraws == 0) lotteries[lottery].Pause = true;
                if (lotteries[lottery].Pause) lotteries[lottery].step = 0;    
        }
        
        else if (lotteries[lottery].step == 3) {
                    lotteries[lottery].upKeepTime = lotteries[lottery].intervalSeconds + lotteries[lottery].drawTime;
                    lotteries[lottery].LotteryAddress.startLottery(lotteries[lottery].upKeepTime, lotteries[lottery].fticketPrice, lotteries[lottery].fdiscount, lotteries[lottery].frewardsBreakdown, lotteries[lottery].ftreasuryFee);
                    lotteries[lottery].step = 1;
                    lotteries[lottery].fcurrentLotteryId = lotteries[lottery].LotteryAddress.viewCurrentLotteryId();
                    lotteries[lottery].drawTime = lotteries[lottery].upKeepTime;
                    }
        
    }    


    // Function to manually call the lottery steps
    function manualUpkeep(address lottery) external onlyOwner {
        if (lotteries[lottery].step == 1) {
            lotteries[lottery].LotteryAddress.closeLottery(lotteries[lottery].fcurrentLotteryId);
            lotteries[lottery].step = 2;
            lotteries[lottery].upKeepTime = block.timestamp + 300;
            
            }

        else if (lotteries[lottery].step == 2) {
            lotteries[lottery].LotteryAddress.drawFinalNumberAndMakeLotteryClaimable(lotteries[lottery].fcurrentLotteryId, lotteries[lottery].isLive);
            lotteries[lottery].step = 3;
            lotteries[lottery].numberOfDraws -= 1; 
            lotteries[lottery].upKeepTime = block.timestamp + 300;
                if (lotteries[lottery].numberOfDraws == 0) lotteries[lottery].Pause = true;
                if (lotteries[lottery].Pause) lotteries[lottery].step = 0;
            }
        
        else if (lotteries[lottery].step == 3) {
                    lotteries[lottery].upKeepTime = lotteries[lottery].intervalSeconds + lotteries[lottery].drawTime;
                    lotteries[lottery].LotteryAddress.startLottery(lotteries[lottery].upKeepTime, lotteries[lottery].fticketPrice, lotteries[lottery].fdiscount, lotteries[lottery].frewardsBreakdown, lotteries[lottery].ftreasuryFee);
                    lotteries[lottery].step = 1;
                    lotteries[lottery].fcurrentLotteryId = lotteries[lottery].LotteryAddress.viewCurrentLotteryId();
                    lotteries[lottery].drawTime = lotteries[lottery].upKeepTime;
                    }
        
    }


    uint256 MAX_INT = 2**256 - 1;
    function checkAllowance(address _Token, uint256 _amount, address _router) private {
            if (token(_Token).allowance(address(this),_router) < _amount){
                    token(_Token).approve(_router, MAX_INT);
                }
        }

        function withdawlBNB() external onlyOwner {
            payable(msg.sender).transfer(address(this).balance);
        }


        function withdrawlToken(address _tokenAddress) external onlyOwner {
            uint256 _tokenAmount = token(_tokenAddress).balanceOf(address(this));
            token(_tokenAddress).transfer(address(msg.sender), _tokenAmount);
        }  

    // to receive Eth From Router when Swapping
    receive() external payable {}
}