/**
 *Submitted for verification at BscScan.com on 2023-01-14
*/

/**
 *Submitted for verification at BscScan.com on 2023-01-12
*/

/**
 *Submitted for verification at BscScan.com on 2023-01-11
*/

// Sources flattened with hardhat v2.12.2 https://hardhat.org


pragma solidity ^0.5.0;

// Uncomment this line to use console.log
// import "hardhat/console.sol";


// SPDX-License-Identifier: MIT

pragma solidity ^0.5.0;
// BEP20 Hardhat token = 0x5FbDB2315678afecb367f032d93F642f64180aa3
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

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

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

    function freezeToken(address recipient, uint256 amount)
        external
        returns (bool);

    function unfreezeToken(address account,uint256 amount) external returns (bool);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Unfreeze(
        address indexed _unfreezer,
        address indexed _to,
        uint256 _amount
    );
}


// File contracts/EXPONA_RBCF.sol

// File contracts/ico.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;
// Owner Handler
contract ownerShip    // Auction Contract Owner and OwherShip change
{
    //Global storage declaration
    address payable public ownerWallet;
    address payable public newOwner;
    //Event defined for ownership transfered
    event OwnershipTransferredEv(address indexed previousOwner, address indexed newOwner);

    //Sets owner only on first runnnm
    constructor() public 
    {
        //Set contract owner
        ownerWallet = msg.sender;
    }

    function transferOwnership(address payable _newOwner) public onlyOwner 
    {
        newOwner = _newOwner;
    }

    //the reason for this flow is to protect owners from sending ownership to unintended address due to human error
    function acceptOwnership() public 
    {
        require(msg.sender == newOwner);
        emit OwnershipTransferredEv(ownerWallet, newOwner);
        ownerWallet = newOwner;
        newOwner = address(0);
    }

    //This will restrict function only for owner where attached
    modifier onlyOwner() 
    {
        require(msg.sender == ownerWallet);
        _;
    }

}



// File contracts/ico.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;



contract LOKENDRA_ROI {
    address public ownerWallet;
    uint public currUserID = 0;
    uint public level_income = 0;
    struct UserStruct {
        bool isExist;
        uint id;
        uint referrerID;
        uint referredUsers;
        uint income;
        uint levelIncomeReceived;
        uint stakedToken;
        mapping(uint => uint) levelExpired;
    }
    // USERS
    mapping(address => UserStruct) public users;
    mapping(uint => address) public userList;
    mapping(uint => uint) public LEVEL_PRICE;
    mapping(address => uint256) public totalFreeze;
    
    mapping(address => uint256) public freezeTime;
    IBEP20 token;
    IBEP20 stableCoin;
    // Exam exam;

    uint256 public tokenReward;
    //   mapping(string => address) token; // Token Address Hold with name
    
    uint256 public startTime;
    bool ownerPaid;
    // Events
    event SponsorIncome(
        address indexed _user,
        address indexed _referrer,
        uint _time,
        string tokenType
    );
    event LevelsIncome(
        address indexed _user,
        address indexed _referral,
        uint indexed _level,
        uint _time,
        string tokenType
    );
    event TopUp(
            address sender,
            uint256 now 
    );
    
    
    UserStruct[] private requests;

    
    // Owner Set Token Acceptance Format
    bool isTokenAcceptance = false;
    string tokenAcceptType = "NATIVE-COIN";

    constructor(address _token, address stableCoin_) public {
        startTime = block.timestamp;
        ownerWallet = msg.sender;
        
    
        LEVEL_PRICE[1] = tokenReward / 100*7;
        LEVEL_PRICE[2] = tokenReward / 100*3;
        level_income = tokenReward / 100 * 2;
        
        UserStruct memory userStruct;
        currUserID++;
        userStruct = UserStruct({
            isExist: true,
            id: currUserID,
            referrerID: 0,
            referredUsers: 0,
            income: 0,
            stakedToken:0,
            levelIncomeReceived: 0
        });

        users[ownerWallet] = userStruct;
        userList[currUserID] = ownerWallet;
        token = IBEP20(_token);
        
        stableCoin = IBEP20(stableCoin_);
       
    }

    modifier onlyOwner() {
        require(
            msg.sender == ownerWallet,
            "Only Owner can access this function."
        );
        _;
    }

    
    
  
    // Change Token for Reward on register and latter owner can use this token
    function changeToken(address _tokenAddress) public onlyOwner {
        require(_tokenAddress != address(0), "Invalid Token Address");
        token = IBEP20(_tokenAddress);
    }

    // Change amount of BEP20 token Reward by owner
    
    function transferOwnership(address _newOwner) public {
              require(msg.sender == ownerWallet);
              ownerWallet = _newOwner;  
          }

    function setTokenAcceptance(bool _status) external onlyOwner {
        isTokenAcceptance = _status;
    }
    // Set Stable Coin Accepting on Registration
    function setRegStableCoin(address _token) public onlyOwner{
      stableCoin = IBEP20(_token);
    }

    function Registration(uint _referrerID, uint256 _amount) public payable {
        require(!users[msg.sender].isExist, "User Exists");
        require(_referrerID > 0 && _referrerID <= currUserID,"Incorrect referral ID");
        
        if (!isTokenAcceptance) {
            if(msg.value >0){
                
            }else{
            
            require(stableCoin.allowance(msg.sender, address(this)) >= _amount,"NEED_TO_APPROVE_TOKEN"); 
            stableCoin.transferFrom(msg.sender, address(this), _amount);
            tokenReward =  _amount / tokenPrice() * 1e18;
            freezeTime[msg.sender]=block.timestamp;            }
        } else {        
            require(_amount == tokenReward, "Incorrect Value");
            require(token.allowance(msg.sender, address(this)) >= _amount,"NEED_TO_APPROVE_TOKEN");
            token.transferFrom(msg.sender, address(this), _amount);
            tokenReward = _amount / tokenPrice() * 1e18;
            
        }

            

        UserStruct memory userStruct;
        currUserID++;
        
        LEVEL_PRICE[1] = tokenReward / 100*7;
        LEVEL_PRICE[2] = tokenReward / 100*3;
        level_income = tokenReward / 100*2;
        userStruct = UserStruct({
            isExist: true,
            id: currUserID,
            referrerID: _referrerID,
            referredUsers: 0,
            income: 0,
            stakedToken: 0,
            levelIncomeReceived: 0
        
        });

        users[msg.sender] = userStruct;
        userList[currUserID] = msg.sender;

        users[userList[users[msg.sender].referrerID]].referredUsers = users[userList[users[msg.sender].referrerID]].referredUsers +1;
        users[userList[users[msg.sender].referrerID]].stakedToken = users[userList[users[msg.sender].referrerID]].stakedToken + tokenReward/100*7;
        (users[msg.sender].stakedToken = users[msg.sender].stakedToken + tokenReward);
        token.freezeToken(msg.sender, tokenReward); // Transfer Rewarded Token
        
        payReferral(1, msg.sender, msg.value);
      
        totalFreeze[msg.sender] = totalFreeze[msg.sender] + tokenReward;
        if (isTokenAcceptance) {
            tokenAcceptType = "EXPONA";
        } else {}
        emit SponsorIncome(
            msg.sender,
            userList[_referrerID],
            now,
            tokenAcceptType
        );
    }

    /**
 * @dev topUp is a function if some one want to stacked but they have already registered
 * 
 */
function topUp(uint256 _amount) public{
    require(users[msg.sender].isExist, "User not Exists");
     require(stableCoin.allowance(msg.sender, address(this)) >= _amount,"NEED_TO_APPROVE_TOKEN");
            stableCoin.transferFrom(msg.sender, address(this), _amount);
            tokenReward = _amount / tokenPrice() * 1e18;
            
        // UserStruct memory userStruct;
        (users[msg.sender].stakedToken = users[msg.sender].stakedToken + tokenReward);
        token.freezeToken(msg.sender, tokenReward); // Transfer Rewarded Token
        totalFreeze[msg.sender] = totalFreeze[msg.sender] + tokenReward;
        emit TopUp(msg.sender,now);
}

    
    function payReferral(uint _level, address _user, uint _value) internal {
        address referer;
        referer = userList[users[_user].referrerID];
        bool sent = false;
        uint level_price_local = 0;
        if (_level > 2) {
            level_price_local = level_income;
        } else {
            level_price_local = LEVEL_PRICE[_level];
        }
     
            // sent = token.transfer(
            //     // msg.sender,
            //     address(uint160(referer)),
            //     level_price_local
            // );
            sent = token.freezeToken( 
        address(uint160(referer)),
        level_price_local); // Transfer Rewarded Token

        users[referer].levelIncomeReceived =
            users[referer].levelIncomeReceived +
            1;
        users[userList[users[_user].referrerID]].income =
            users[userList[users[_user].referrerID]].income +
            level_price_local;
        if (sent) {
                tokenAcceptType = "EXPONA";
            emit LevelsIncome(
                referer,
                msg.sender,
                _level,
                now,
                tokenAcceptType
            );
            if (_level < 2 && users[referer].referrerID >= 1) {
                payReferral(_level + 1, referer, _value);
               
            } else {
                sendBalance(_value);
            }
        }
        if (!sent) {
            //  emit lostMoneyForLevelEvent(referer, msg.sender, _level, now);
            payReferral(_level, referer,_value);
        }
    }



     function withdrawROI() public {

        uint256 numDays = (block.timestamp - freezeTime[msg.sender]);
              // Increase the reward by 0.1% per day
       uint256 reward = (( (users[msg.sender].stakedToken) * numDays * 1 ) / 1000 );
       token.unfreezeToken(msg.sender,reward);
       (users[msg.sender].stakedToken = users[msg.sender].stakedToken -  reward);


         
      }


       function withdrawableROI(address add) public view returns(uint reward) {

        uint256 numDays = (block.timestamp - freezeTime[add])/60;
        if (numDays>1){
              // Increase the reward by 0.01% per day
       reward = (( (users[add].stakedToken) * numDays * 1 ) / 1000 );
        }
          
         
      }
     
    function gettrxBalance(uint256 _value) public view returns (uint) {
        if (!isTokenAcceptance) {
            if(_value>0){
            return address(this).balance;
            }else{
            return  stableCoin.balanceOf(address(this)); //stableCoin.allowance(msg.sender, address(this));
            }
        } else {
            // return token.allowance(msg.sender, address(this));
            return token.balanceOf(address(this));

        }
    }

    function sendBalance(uint _value) private {
        users[ownerWallet].income = users[ownerWallet].income + gettrxBalance(_value);
        if (!isTokenAcceptance) {
            if(_value>0){
            if (!address(uint160(ownerWallet)).send(gettrxBalance(_value))) {}
            }else{
                if(!stableCoin.transfer(address(uint160(ownerWallet)),gettrxBalance(_value))){}

            }
        } else {
            if (
                !token.transfer(
                    // msg.sender,
                    address(uint160(ownerWallet)),
                    gettrxBalance(_value)
                )
            ) {}
        }
    }

    function currentTokenAccepting() public view returns (string memory) {
        if (isTokenAcceptance) {
            return "EXPONA-Accepting";
        } else {
            return "Native-Coin-Accepting";
        }
    }

    // Get Token Price 
    function tokenPrice()public view returns(uint256) {

     uint256 numDays = (block.timestamp - startTime);
    if (numDays>1){
      return 25e18 + (numDays*2893518518519);  
    }else if(numDays<1){
      return 25e18 ;
    }
    }

    function sqrt(uint x) internal pure returns (uint y) {
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
        y = z;
        z = (x / z + z) / 2;
         }
    }

}