// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./file/SafeMath.sol";
import "./file/AccessControlEnumerable.sol";
import "./file/IERC20.sol";

import "./file/IUniswapV2Pair.sol";
import "./file/IUniswapV2Factory.sol";
import "./file/IUniswapV2Router02.sol";

import "./file/FullMath.sol";

interface IRaceLPLock {

    function lock(
        address owner,
        address token,       
        uint256 amount,
        uint256 unlockDate,
        string memory description
    ) external returns (uint256 id);

    function vestingLock(
        address owner,
        address token,   
        uint256 amount,
        uint256 tgeDate,
        uint256 tgeBps,
        uint256 cycle,
        uint256 cycleBps,
        string memory description
    ) external returns (uint256 id);

    function unlock(uint256 lockId) external;

}

interface IFactoryPresale {
    function changeProjectStatus(uint8 _status, address token) external;
}

contract PresaleRace is AccessControlEnumerable {
    using SafeMath for uint256;

    IERC20 public tokenERC20;
    IUniswapV2Router02 public uniswapRouter;
    IUniswapV2Factory public uniswapFactory;
    IRaceLPLock private raceLPlock;   
    IFactoryPresale private factoryPresale;

    bytes32 private constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 private constant PROJECT_ROLE = keccak256("PROJECT_ROLE");

    address internal ADMIN_ADDRESS = 0x46FCC7D4490E7d9416F50b2EbfeC5BA3d1BB5240;
    address internal UNISWAP_ROUTER_ADDRESS;
    address internal UNISWAP_FACTORY_ADDRESS; 
    address internal WBNB_TOKEN;    

    address public addressTokenProject;
    address public addressOwnerProject;
    uint256 public presaleRate; // No have 10 ** decimal
    uint256 public listingRate; // No have 10 ** decimal
    uint256 public softCap;
    uint256 public hardCap;
    uint256 public minimumBuy;
    uint256 public maximumBuy;
    uint256 public refundType;      

    uint256 public percentLP;
    uint256 public startTime;
    uint256 public endTime;

    uint256 public lockLPTime;
    uint256 public lockId;

    uint256 public isTGE; // 0-1 : 0 is not use TGE : 1 is use TGE
    uint256 public percentFirstRelease; //percent
    uint256 public vestingEachCycle; //Time
    uint256 public percentEachCycle; //percent
    uint256 public isWhitelist = 0; // 0-1 : 0 is not use whitelist : 1 is use whitelist

    string public logoURL;
    string public website;
    string public facebook;
    string public twitter;
    string public github;
    string public telegram;
    string public instagram;
    string public discord;
    string public reddit;
    string public youtubeLink;
    string public description;   

    // user address => pool name => number of slot.
    mapping(address => uint256) public whitelistAddress;
    address[] private whiteList;    

    uint256 private totalTokenForPresaleWithHardCap;    
    uint256 private totalFeeTokenForPresaleWithHardCap; // fee presale
    uint256 private totalTokenForLPWithHardCap;
    uint256 private maxBalanceAmountWithHardCap;

    uint256 public totalTokenUserBuy;
    uint256 public totalAmountUserBuy;
   
    // user address => amount 
    mapping(address => uint256) public listUserBuyPresale;
    mapping(address => uint256) public listUserReceiveTokenPresale;

    struct UserBuyPresale {
        address buyer;
        uint256 amount;
        uint256 tokenReceive;
        bool claim;
        uint256 unlockedToken;
    }    

    UserBuyPresale[] public userBuyPresales;

    uint256 public feeWithdrawEmergency = 10;  

    bool private cancelProject = false;
    bool private finallyProject = false;
    
    constructor(       
        uint256[] memory _saleInfo,
        address[] memory _addressInfo,
        string[] memory _projectInfo
    ) {
        tokenERC20 = IERC20(_addressInfo[1]);
        uniswapRouter = IUniswapV2Router02(_addressInfo[2]);
        uniswapFactory = IUniswapV2Factory(_addressInfo[3]);                
        WBNB_TOKEN = _addressInfo[5];
        UNISWAP_ROUTER_ADDRESS = _addressInfo[2];
        UNISWAP_FACTORY_ADDRESS = _addressInfo[3];    
        raceLPlock = IRaceLPLock(_addressInfo[4]);        
        factoryPresale = IFactoryPresale( _addressInfo[6]);
        _setupRole(ADMIN_ROLE, ADMIN_ADDRESS);
        _setupRole(ADMIN_ROLE, msg.sender);
        _setupRole(PROJECT_ROLE, _addressInfo[0]);      
        addressOwnerProject = _addressInfo[0];
        addressTokenProject = _addressInfo[1];       
        
        presaleRate = _saleInfo[0];
        listingRate = _saleInfo[1];
        softCap = _saleInfo[2];
        hardCap = _saleInfo[3];
        minimumBuy = _saleInfo[4];
        maximumBuy = _saleInfo[5];
        percentLP = _saleInfo[6];
        isWhitelist = _saleInfo[7];
        totalTokenForPresaleWithHardCap = _saleInfo[8]; // include fee 
        totalTokenForLPWithHardCap = _saleInfo[9]; // include fee        
        maxBalanceAmountWithHardCap = _saleInfo[10]; 
        totalFeeTokenForPresaleWithHardCap = _saleInfo[11];     
        
        refundType = _saleInfo[12];
        startTime = _saleInfo[13];
        endTime =_saleInfo[14];
        lockLPTime = _saleInfo[15];
        percentFirstRelease = _saleInfo[16];
        vestingEachCycle = _saleInfo[17];
        percentEachCycle =  _saleInfo[18];
        isTGE = _saleInfo[19]; 

        logoURL = _projectInfo[0];
        website = _projectInfo[1];
        facebook = _projectInfo[2];
        twitter = _projectInfo[3];
        github = _projectInfo[4];
        instagram = _projectInfo[5];
        telegram = _projectInfo[6];
        discord = _projectInfo[7];
        reddit = _projectInfo[8];
        youtubeLink = _projectInfo[9];
        description = _projectInfo[10];
    }


    function setInfoProject(
        string memory _logoURL,
        string memory _website,
        string memory _facebook,
        string memory _twitter,
        string memory _github,
        string memory _telegram,
        string memory _instagram,
        string memory _discord,
        string memory _reddit,
        string memory _youtubeLink,
        string memory _description
    ) external {
        require(
            bytes(_logoURL).length <= 512 ||
            bytes(_website).length <= 512 ||
            bytes(_facebook).length <= 512 ||
            bytes(_twitter).length <= 512 ||
            bytes(_github).length <= 512 ||
            bytes(_telegram).length <= 512 ||
            bytes(_instagram).length <= 512 ||
            bytes(_discord).length <= 512 ||
            bytes(_reddit).length <= 512 ||
            bytes(_youtubeLink).length <= 512 ||
            bytes(_description).length <= 512,
            "Description must be 512 characters or less"
        );
        require(
            hasRole(PROJECT_ROLE, msg.sender) ||
                hasRole(ADMIN_ROLE, msg.sender),
            "You are not the owner of this project"
        );
        logoURL = _logoURL;
        website = _website;
        facebook = _facebook;
        twitter = _twitter;
        github = _github;
        instagram = _instagram;
        telegram = _telegram;
        discord = _discord;
        reddit = _reddit;
        youtubeLink = _youtubeLink;
        description = _description;
    }

    receive() external payable {}

    function setNewAdmin(address _address) external {
        require(hasRole(ADMIN_ROLE, msg.sender), "You are not an admin");
        _setupRole(ADMIN_ROLE, _address);
    }

    function removeRole(address _address) external {
        require(hasRole(ADMIN_ROLE, msg.sender), "You are not an admin");
        revokeRole(ADMIN_ROLE, _address);
    }

    function setIsWhiteList(uint256 _isWhitelist) external {
        require(
            hasRole(PROJECT_ROLE, msg.sender) ||
                hasRole(ADMIN_ROLE, msg.sender),
            "You are not the owner of this project"
        ); 
        isWhitelist = _isWhitelist;
    }

    function setWhiteList(address[] memory _addresses) external {
        require(
            hasRole(PROJECT_ROLE, msg.sender) ||
                hasRole(ADMIN_ROLE, msg.sender),
            "You are not the owner of this project"
        );       
        require(isWhitelist == 1, "You must enable whitelist mode");
        require(block.timestamp < endTime, "Can not set after end time");
      

        if(whiteList.length == 0){ //first time add whitelist
            whiteList = _addresses;
        }else{  // more time add whitelist           
            for (uint256 index = 0; index < _addresses.length; index++) {
                if(whitelistAddress[_addresses[index]] == 0){
                    whiteList.push(_addresses[index]);
                }                
            }
        }

        for (uint256 index = 0; index < _addresses.length; index++) {
            if(whitelistAddress[_addresses[index]] == 0){
                whitelistAddress[_addresses[index]] = 1;
            }            
        }
        
    }    

    function removeWhiteList(address[] memory _addresses) external {
        require(
            hasRole(PROJECT_ROLE, msg.sender) ||
                hasRole(ADMIN_ROLE, msg.sender),
            "You are not the owner of this project"
        ); 
        require(isWhitelist == 1, "You must enable whitelist mode");
        require(block.timestamp < endTime, "Can not set after end time");        

        for (uint256 index = 0; index < _addresses.length; index++) {
            for (uint256 i = 0; i < whiteList.length; i++) {
                if (_addresses[index] == whiteList[i] && whitelistAddress[_addresses[index]] != 2) {
                    whiteList[i] = whiteList[whiteList.length - 1];
                    whiteList.pop();
                    // whitelistAddress[_addresses[index]] = 0;
                    delete whitelistAddress[_addresses[index]];                   
                }
            }
        }
    }

    function userPurchased() public view returns (uint256 ,uint256){       
        return (listUserBuyPresale[msg.sender], listUserReceiveTokenPresale[msg.sender]);
    }

    function buyPresale(uint256 _amount) public payable {     

        //check whitelist
        if(isWhitelist == 1){
            require(whitelistAddress[msg.sender] == 1, "You have to position in whitelist");  
        }

        //check validate
        require( _amount >= minimumBuy &&  _amount <= maximumBuy, "You only buy with correct amount");  
        require(_amount.add(totalAmountUserBuy) <= maxBalanceAmountWithHardCap, "Your amount is large");
        require( block.timestamp >= startTime && block.timestamp <= endTime, "You only buy while presale time"); 
        uint256 tokenReceive = _amount.mul(presaleRate);         
        require(tokenReceive.add(totalTokenUserBuy) <= totalTokenForPresaleWithHardCap.sub(totalFeeTokenForPresaleWithHardCap), "Your amount is large");

        if(listUserBuyPresale[msg.sender] > 0 && listUserReceiveTokenPresale[msg.sender] > 0){
            listUserBuyPresale[msg.sender] = listUserBuyPresale[msg.sender].add(_amount);
            listUserReceiveTokenPresale[msg.sender] = listUserReceiveTokenPresale[msg.sender].add(tokenReceive);
            for (uint256 i = 0; i < userBuyPresales.length; i++) {
                address buyer = userBuyPresales[i].buyer;    
                bool claim = userBuyPresales[i].claim;           
                if(buyer == msg.sender && claim == false){
                    userBuyPresales[i].amount = userBuyPresales[i].amount.add(_amount);
                    userBuyPresales[i].tokenReceive = userBuyPresales[i].tokenReceive.add(tokenReceive);            
                    break;
                }
            }
        }else{
            listUserBuyPresale[msg.sender] = _amount;
            listUserReceiveTokenPresale[msg.sender] = tokenReceive;
            userBuyPresales.push(UserBuyPresale(msg.sender, listUserBuyPresale[msg.sender], listUserReceiveTokenPresale[msg.sender], false ,0));
        }  

        totalTokenUserBuy = totalTokenUserBuy.add(tokenReceive);  
        totalAmountUserBuy = totalAmountUserBuy.add(_amount);

        //change done whitelist
        whitelistAddress[msg.sender] = 2;
           
        payable(address(this)).transfer(_amount);

    }   

    function withdrawEmergency() external {
        require(block.timestamp <= endTime, "You only withdraw in presale time"); 
        require(listUserBuyPresale[msg.sender] > 0 && listUserReceiveTokenPresale[msg.sender] > 0, "You must have balance greater than 0"); 
      
        uint256 feeWithdraw = listUserBuyPresale[msg.sender].mul(feeWithdrawEmergency).div(100);
        uint256 numberAmountUserReceive = listUserBuyPresale[msg.sender].sub(feeWithdraw);

        payable(msg.sender).transfer(numberAmountUserReceive);
        payable(ADMIN_ADDRESS).transfer(feeWithdraw);     

        totalAmountUserBuy = totalAmountUserBuy.sub(listUserBuyPresale[msg.sender]);
        totalTokenUserBuy = totalTokenUserBuy.sub(listUserReceiveTokenPresale[msg.sender]);

        delete listUserBuyPresale[msg.sender];
        delete listUserReceiveTokenPresale[msg.sender];

        for (uint256 i = 0; i < userBuyPresales.length; i++) {
            if(userBuyPresales[i].buyer == msg.sender){
                userBuyPresales[i] = userBuyPresales[userBuyPresales.length - 1];
                userBuyPresales.pop();
                break;
            }            
        }

        if(isWhitelist == 1){
           whitelistAddress[msg.sender] = 1;     
        }
    }

    function withrawAfterPresaleFail() external {
        require(block.timestamp > endTime, "You only withdraw after presale time");
        require(totalAmountUserBuy < softCap, "Can not withdraw with softcap enough");

        uint256 numberAmountUserReceive = listUserBuyPresale[msg.sender];
        payable(msg.sender).transfer(numberAmountUserReceive);

        delete listUserBuyPresale[msg.sender];
        delete listUserReceiveTokenPresale[msg.sender];

        for (uint256 i = 0; i < userBuyPresales.length; i++) {
            if(userBuyPresales[i].buyer == msg.sender){
                userBuyPresales[i] = userBuyPresales[userBuyPresales.length - 1];
                userBuyPresales.pop();
                break;
            }            
        }

        if(isWhitelist == 1){
           whitelistAddress[msg.sender] = 1;     
        }

    }

    function checkStatusClaim(address user) public view returns (bool){
        bool isClaim;
        for (uint256 i = 0; i < userBuyPresales.length; i++) {
            address buyer = userBuyPresales[i].buyer;    
            bool claim = userBuyPresales[i].claim;           
            if(buyer == user){
                if(claim == true){
                    isClaim = true;                 
                    break;
                }else{
                    isClaim = false;                 
                    break;
                }                
            }
        }   
        return isClaim;
    }

    function getUserBuyPresalesById(uint256 userId) public view returns (UserBuyPresale memory) {
        return userBuyPresales[userId];
    }

    function _withdrawableTokens(UserBuyPresale memory userBuyPresale)
        internal
        view
        returns (uint256)
    {
        if (userBuyPresale.tokenReceive == 0) return 0;
        if (userBuyPresale.unlockedToken >= userBuyPresale.tokenReceive) return 0;
        if (block.timestamp < endTime) return 0;
        if (vestingEachCycle == 0) return 0;

        uint256 tgeReleaseAmount = FullMath.mulDiv(
            userBuyPresale.tokenReceive,
            percentFirstRelease,
            10_000
        );
        uint256 cycleReleaseAmount = FullMath.mulDiv(
            userBuyPresale.tokenReceive,
            percentEachCycle,
            10_000
        );
        uint256 currentTotal = 0;
        if (block.timestamp >= endTime) {
            currentTotal =
                (((block.timestamp - endTime) / vestingEachCycle) *
                    cycleReleaseAmount) +
                tgeReleaseAmount; // Truncation is expected here
        }
        uint256 withdrawable = 0;
        if (currentTotal > userBuyPresale.tokenReceive) {
            withdrawable = userBuyPresale.tokenReceive - userBuyPresale.unlockedToken;
        } else {
            withdrawable = currentTotal - userBuyPresale.unlockedToken;
        }
        return withdrawable;
    }

    function withdrawableTokens(uint256 userId)
        external
        view
        returns (uint256)
    {
        UserBuyPresale memory userBuyPresale = getUserBuyPresalesById(userId);
        return _withdrawableTokens(userBuyPresale);
    }

    function claimTokenAfterPresaleSuccess() external {
        require(totalAmountUserBuy >= softCap, "Can not withdraw with softcap no enough");
        require(finallyProject == true, "Project must be finalize");
        require(listUserBuyPresale[msg.sender] > 0 && listUserReceiveTokenPresale[msg.sender] > 0, "You must have balance greater than 0"); 
        //check status claim       
        require(checkStatusClaim(msg.sender) == false, "You have already claimed the token"); 

        //get user buy presale
        uint256 indexUserBuyPresale;
        for (uint256 i = 0; i < userBuyPresales.length; i++) {
            address buyer = userBuyPresales[i].buyer;  
            if(buyer == msg.sender){
                indexUserBuyPresale = i;    
                break;           
            }
        }  
        //require(indexUserBuyPresale > 0, "You have already is buyer on list"); 

        if(isTGE == 1){
            uint256 withdrawable = _withdrawableTokens(userBuyPresales[indexUserBuyPresale]);
            uint256 newTotalUnlockAmount = userBuyPresales[indexUserBuyPresale].unlockedToken + withdrawable;
            require(
                    withdrawable > 0 && newTotalUnlockAmount <= userBuyPresales[indexUserBuyPresale].tokenReceive,
                    "Nothing to unlock"
            );
            
            if (userBuyPresales[indexUserBuyPresale].tokenReceive <= withdrawable) {
                userBuyPresales[indexUserBuyPresale].tokenReceive = 0;
            } else {
                userBuyPresales[indexUserBuyPresale].tokenReceive = userBuyPresales[indexUserBuyPresale].tokenReceive - withdrawable;
            }

            if(userBuyPresales[indexUserBuyPresale].tokenReceive == 0){
                userBuyPresales[indexUserBuyPresale].claim = true;
            }
            
            userBuyPresales[indexUserBuyPresale].unlockedToken = newTotalUnlockAmount;
            listUserReceiveTokenPresale[msg.sender] = listUserReceiveTokenPresale[msg.sender] - newTotalUnlockAmount;
            tokenERC20.transfer(userBuyPresales[indexUserBuyPresale].buyer, withdrawable);

        }else{                   

            userBuyPresales[indexUserBuyPresale].claim = true;
            userBuyPresales[indexUserBuyPresale].tokenReceive = 0;
            userBuyPresales[indexUserBuyPresale].unlockedToken = listUserReceiveTokenPresale[msg.sender];

            tokenERC20.transfer(msg.sender, listUserReceiveTokenPresale[msg.sender]);
            listUserReceiveTokenPresale[msg.sender] = 0;
        }        

    }

    function cancelPresale() external {
        require(
            hasRole(PROJECT_ROLE, msg.sender) ||
                hasRole(ADMIN_ROLE, msg.sender),
            "You are not the owner of this project"
        ); 
        require(finallyProject == false, "You can not cancel when presale is final"); 
        require(block.timestamp > endTime, "You only cancel after presale end"); 

        //change status
        cancelProject = true;

        //payback token
        uint256 allTokenPayBack = totalTokenForPresaleWithHardCap.add(totalTokenForLPWithHardCap);
        tokenERC20.transfer(addressOwnerProject, allTokenPayBack);
        totalTokenForPresaleWithHardCap = totalTokenForPresaleWithHardCap.sub(totalTokenForPresaleWithHardCap);
        totalTokenForLPWithHardCap = totalTokenForLPWithHardCap.sub(totalTokenForLPWithHardCap);

        //change status factory
        factoryPresale.changeProjectStatus(0, addressTokenProject);

    }
    

    function finalizePresale() external {
        require(
            hasRole(PROJECT_ROLE, msg.sender) ||
                hasRole(ADMIN_ROLE, msg.sender),
            "You are not the owner of this project"
        ); 
        require(cancelProject == false, "You can not finalize when presale is cancel"); 
        require(block.timestamp > endTime, "You only finalize after presale end"); 
        require(totalAmountUserBuy >= softCap, "Can not withdraw with softcap no enough");       

        IERC20(tokenERC20).approve(UNISWAP_ROUTER_ADDRESS, totalTokenForPresaleWithHardCap);

        //total BNB will be listed on DEX
        uint256 totalBNBList = totalAmountUserBuy.mul(percentLP).mul(98).div(10000);
        //total BNB owner project will receive
        uint256 totalBNBOwnerReceive = totalAmountUserBuy.mul(98).div(100).sub(totalBNBList);
        //total BNB admin receive
        uint256 totalBNBAdminReceive = maxBalanceAmountWithHardCap.sub(totalBNBList).sub(totalBNBOwnerReceive);

        //total token sell presale for user
        uint256 totalTokenForPresale = totalAmountUserBuy.mul(presaleRate);
        //total fee of token sell presale for user
        uint256 totalFeeTokenForPresale = totalTokenForPresale.mul(2).div(100);
        //total token remain
        uint256 totalTokenForPresaleRemain = totalTokenForPresaleWithHardCap.sub(totalTokenForPresale).sub(totalFeeTokenForPresale);
        

        uint256 totalTokenForLP = totalAmountUserBuy.mul(listingRate).mul(percentLP).mul(98).div(10000);
        uint256 totalTokenForLPRemain = totalTokenForLPWithHardCap.sub(totalTokenForLP);

        uint256 totalTokenOwnerRemain = totalTokenForPresaleRemain.add(totalTokenForLPRemain);      
        
        uint deadline = 10000000000;
        uniswapRouter.addLiquidityETH{ value: totalBNBList }(
            addressTokenProject,
            totalTokenForLP, // must be token for LP
            totalTokenForLP, // minimum token can be add LP (not exclude fee buy or sell of token contract)
            totalBNBList,
            ADMIN_ADDRESS,
            deadline
        );           
         

        //burn or refund token
        if(refundType == 0){ //burn
            tokenERC20.transfer(0x0000000000000000000000000000000000000000, totalTokenOwnerRemain);
        }
        if(refundType == 1){ //refund
            tokenERC20.transfer(addressOwnerProject, totalTokenOwnerRemain);
        }

        //transfer BNB to OwnerProject
        payable(addressOwnerProject).transfer(totalBNBOwnerReceive);
        //transfer BNB to Admin
        payable(ADMIN_ADDRESS).transfer(totalBNBAdminReceive);

        //transfer fee Token to Admin        
        tokenERC20.transfer(ADMIN_ADDRESS, totalFeeTokenForPresale);

        //lock token pair
        address pairLP = uniswapFactory.getPair(addressTokenProject, WBNB_TOKEN);  
        uint256 balancePairLP = IUniswapV2Pair(pairLP).balanceOf(ADMIN_ADDRESS);

        if(balancePairLP > 0){
            string memory descriptionLock = string(abi.encodePacked(tokenERC20.name(), ": LP Lock"));            
            (uint256 id) = raceLPlock.lock(addressOwnerProject, pairLP, balancePairLP, lockLPTime, descriptionLock);
            lockId = id;
        }            
        
        //change status factory
        factoryPresale.changeProjectStatus(2, addressTokenProject);
    } 

    function unLockLP() external {
        require(lockId > 0, "LockId must be greater than 0"); 
        raceLPlock.unlock(lockId);
    }
    
    function flushBNB(address payable _to, uint256 _amount) external {
        require(hasRole(ADMIN_ROLE, msg.sender), "You are not the admin"); 
        _to.transfer(_amount);
    }

    function rescueStuckErc20(address _token) external {
        require(hasRole(ADMIN_ROLE, msg.sender), "You are not the admin");
        uint256 _amount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(ADMIN_ADDRESS, _amount);
    }
   

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 * not same
 */
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
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   *
   * _Available since v2.4.0._
   */
  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b <= a, errorMessage);
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
    return div(a, b, "SafeMath: division by zero");
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   *
   * _Available since v2.4.0._
   */
  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./EnumerableSet.sol";
import "./IAccessControlEnumerable.sol";
import "./AccessControl.sol";

abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(bytes32 => EnumerableSet.AddressSet) private _roleMembers;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index) public view override returns (address) {
        return _roleMembers[role].at(index);
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) public view override returns (uint256) {
        return _roleMembers[role].length();
    }

    /**
     * @dev Overload {grantRole} to track enumerable memberships
     */
    function grantRole(bytes32 role, address account) public virtual override {
        super.grantRole(role, account);
        _roleMembers[role].add(account);
    }

    /**
     * @dev Overload {revokeRole} to track enumerable memberships
     */
    function revokeRole(bytes32 role, address account) public virtual override {
        super.revokeRole(role, account);
        _roleMembers[role].remove(account);
    }

    /**
     * @dev Overload {renounceRole} to track enumerable memberships
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        super.renounceRole(role, account);
        _roleMembers[role].remove(account);
    }

    /**
     * @dev Overload {_setupRole} to track enumerable memberships
     */
    function _setupRole(bytes32 role, address account) internal virtual override {
        super._setupRole(role, account);
        _roleMembers[role].add(account);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.4;

interface IUniswapV2Pair {
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);

  function name() external pure returns (string memory);

  function symbol() external pure returns (string memory);

  function decimals() external pure returns (uint8);

  function totalSupply() external view returns (uint256);

  function balanceOf(address owner) external view returns (uint256);

  function allowance(address owner, address spender)
    external
    view
    returns (uint256);

  function approve(address spender, uint256 value) external returns (bool);

  function transfer(address to, uint256 value) external returns (bool);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool);

  function DOMAIN_SEPARATOR() external view returns (bytes32);

  function PERMIT_TYPEHASH() external pure returns (bytes32);

  function nonces(address owner) external view returns (uint256);

  function permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;

  event Mint(address indexed sender, uint256 amount0, uint256 amount1);
  event Burn(
    address indexed sender,
    uint256 amount0,
    uint256 amount1,
    address indexed to
  );
  event Swap(
    address indexed sender,
    uint256 amount0In,
    uint256 amount1In,
    uint256 amount0Out,
    uint256 amount1Out,
    address indexed to
  );
  event Sync(uint112 reserve0, uint112 reserve1);

  function MINIMUM_LIQUIDITY() external pure returns (uint256);

  function factory() external view returns (address);

  function token0() external view returns (address);

  function token1() external view returns (address);

  function getReserves()
    external
    view
    returns (
      uint112 reserve0,
      uint112 reserve1,
      uint32 blockTimestampLast
    );

  function price0CumulativeLast() external view returns (uint256);

  function price1CumulativeLast() external view returns (uint256);

  function kLast() external view returns (uint256);

  function mint(address to) external returns (uint256 liquidity);

  function burn(address to) external returns (uint256 amount0, uint256 amount1);

  function swap(
    uint256 amount0Out,
    uint256 amount1Out,
    address to,
    bytes calldata data
  ) external;

  function skim(address to) external;

  function sync() external;

  function initialize(address, address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.4;

interface IUniswapV2Factory {
  event PairCreated(
    address indexed token0,
    address indexed token1,
    address pair,
    uint256
  );

  function feeTo() external view returns (address);

  function feeToSetter() external view returns (address);

  function getPair(address tokenA, address tokenB)
    external
    view
    returns (address pair);

  function allPairs(uint256) external view returns (address pair);

  function allPairsLength() external view returns (uint256);

  function createPair(address tokenA, address tokenB)
    external
    returns (address pair);

  function setFeeTo(address) external;

  function setFeeToSetter(address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity =0.8.4;

interface IUniswapV2Router01 {
  function factory() external pure returns (address);

  function WETH() external pure returns (address);

  function addLiquidity(
    address tokenA,
    address tokenB,
    uint256 amountADesired,
    uint256 amountBDesired,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  )
    external
    returns (
      uint256 amountA,
      uint256 amountB,
      uint256 liquidity
    );

  function addLiquidityETH(
    address token,
    uint256 amountTokenDesired,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  )
    external
    payable
    returns (
      uint256 amountToken,
      uint256 amountETH,
      uint256 liquidity
    );

  function removeLiquidity(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountA, uint256 amountB);

  function removeLiquidityETH(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountToken, uint256 amountETH);

  function removeLiquidityWithPermit(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountA, uint256 amountB);

  function removeLiquidityETHWithPermit(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountToken, uint256 amountETH);

  function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapTokensForExactTokens(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapExactETHForTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable returns (uint256[] memory amounts);

  function swapTokensForExactETH(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapExactTokensForETH(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapETHForExactTokens(
    uint256 amountOut,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable returns (uint256[] memory amounts);

  function quote(
    uint256 amountA,
    uint256 reserveA,
    uint256 reserveB
  ) external pure returns (uint256 amountB);

  function getAmountOut(
    uint256 amountIn,
    uint256 reserveIn,
    uint256 reserveOut
  ) external pure returns (uint256 amountOut);

  function getAmountIn(
    uint256 amountOut,
    uint256 reserveIn,
    uint256 reserveOut
  ) external pure returns (uint256 amountIn);

  function getAmountsOut(uint256 amountIn, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);

  function getAmountsIn(uint256 amountOut, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
  function removeLiquidityETHSupportingFeeOnTransferTokens(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountETH);

  function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountETH);

  function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;

  function swapExactETHForTokensSupportingFeeOnTransferTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable;

  function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.0;

/// @title Contains 512-bit math functions
/// @notice Facilitates multiplication and division that can have overflow of an intermediate value without any loss of precision
/// @dev Handles "phantom overflow" i.e., allows multiplication and division where an intermediate value overflows 256 bits
library FullMath {
  /// @notice Calculates floor(a×b÷denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
  /// @param a The multiplicand
  /// @param b The multiplier
  /// @param denominator The divisor
  /// @return result The 256-bit result
  /// @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv
  function mulDiv(
    uint256 a,
    uint256 b,
    uint256 denominator
  ) internal pure returns (uint256 result) {
    // 512-bit multiply [prod1 prod0] = a * b
    // Compute the product mod 2**256 and mod 2**256 - 1
    // then use the Chinese Remainder Theorem to reconstruct
    // the 512 bit result. The result is stored in two 256
    // variables such that product = prod1 * 2**256 + prod0
    uint256 prod0; // Least significant 256 bits of the product
    uint256 prod1; // Most significant 256 bits of the product
    assembly {
      let mm := mulmod(a, b, not(0))
      prod0 := mul(a, b)
      prod1 := sub(sub(mm, prod0), lt(mm, prod0))
    }

    // Handle non-overflow cases, 256 by 256 division
    if (prod1 == 0) {
      require(denominator > 0);
      assembly {
        result := div(prod0, denominator)
      }
      return result;
    }

    // Make sure the result is less than 2**256.
    // Also prevents denominator == 0
    require(denominator > prod1);

    ///////////////////////////////////////////////
    // 512 by 256 division.
    ///////////////////////////////////////////////

    // Make division exact by subtracting the remainder from [prod1 prod0]
    // Compute remainder using mulmod
    uint256 remainder;
    assembly {
      remainder := mulmod(a, b, denominator)
    }
    // Subtract 256 bit number from 512 bit number
    assembly {
      prod1 := sub(prod1, gt(remainder, prod0))
      prod0 := sub(prod0, remainder)
    }

    // Factor powers of two out of denominator
    // Compute largest power of two divisor of denominator.
    // Always >= 1.
    unchecked {
      uint256 twos = (type(uint256).max - denominator + 1) & denominator;
      // Divide denominator by power of two
      assembly {
        denominator := div(denominator, twos)
      }

      // Divide [prod1 prod0] by the factors of two
      assembly {
        prod0 := div(prod0, twos)
      }
      // Shift in bits from prod1 into prod0. For this we need
      // to flip `twos` such that it is 2**256 / twos.
      // If twos is zero, then it becomes one
      assembly {
        twos := add(div(sub(0, twos), twos), 1)
      }
      prod0 |= prod1 * twos;

      // Invert denominator mod 2**256
      // Now that denominator is an odd number, it has an inverse
      // modulo 2**256 such that denominator * inv = 1 mod 2**256.
      // Compute the inverse by starting with a seed that is correct
      // correct for four bits. That is, denominator * inv = 1 mod 2**4
      uint256 inv = (3 * denominator) ^ 2;
      // Now use Newton-Raphson iteration to improve the precision.
      // Thanks to Hensel's lifting lemma, this also works in modular
      // arithmetic, doubling the correct bits in each step.
      inv *= 2 - denominator * inv; // inverse mod 2**8
      inv *= 2 - denominator * inv; // inverse mod 2**16
      inv *= 2 - denominator * inv; // inverse mod 2**32
      inv *= 2 - denominator * inv; // inverse mod 2**64
      inv *= 2 - denominator * inv; // inverse mod 2**128
      inv *= 2 - denominator * inv; // inverse mod 2**256

      // Because the division is now exact we can divide by multiplying
      // with the modular inverse of denominator. This will give us the
      // correct result modulo 2**256. Since the precoditions guarantee
      // that the outcome is less than 2**256, this is the final result.
      // We don't need to compute the high bits of the result and prod1
      // is no longer required.
      result = prod0 * inv;
      return result;
    }
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastvalue;
                // Update the index for the moved value
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IAccessControlEnumerable {
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);

    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./String.sol";
import "./Context.sol";
import "./IAccessControl.sol";
import "./ERC165.sol";

abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{20}) is missing role (0x[0-9a-f]{32})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{20}) is missing role (0x[0-9a-f]{32})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IAccessControl {
    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./IERC165.sol";

abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}