/**
 *Submitted for verification at BscScan.com on 2022-08-05
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-01
*/

// SPDX-License-Identifier: MIT
interface IERC20 {
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function distributeTokens(address to, uint tokens, uint256 lockingPeriod) external returns (bool);
}

interface rigelSpecialPool {
    function userInfo(address _addr) external view returns(address _staker, uint256 _amountStaked, uint256 _userReward, uint _timeStaked);
    function getMinimumStakeAmount() external view returns(uint256 min);
}

pragma solidity 0.8.12;


contract RigelPad_Oracula_BUSD {

    struct data {
        uint256  price;
        uint256  expectedTotalLockFunds;
        uint256  lockedFunds;
        uint256  maxLockForEachUser;
        uint256  minLockForEachUser;
    }

    struct UserFunds {
        uint256 lockedFunds;
        uint256 rewards;
        uint256 amountReceived;
    }

    struct distributionPeriod {
        uint256 distributionTime;
        uint256 distributionPercentage;
    }
    address private immutable owner;
    address private immutable swapTokenFrom;
    address private immutable swapTokenTo;
    address private immutable specialPoolC;

    uint256 public claimed;
    uint256 public referralPercent;
    uint256 public referredPercent;
    bool    public saleActive;  
    bool    public enableWhitelisting;  
    address[] public users;
    address[] public referralAddresses;
    address[] public withReferral;
    mapping (address => bool) public isWhitelist;
    mapping (address => bool) public isAdminAddress;
    mapping (address => UserFunds) public userFunds;
    mapping (uint256 => distributionPeriod[]) public period;  
    mapping (uint256 => data) public getData;
    mapping (address => uint256) public referredAndReferralRw;  
    mapping (address => bool) public hasBeenReferred;
    
    // Emitted when tokens are sold
    event Sale(address indexed account, uint indexed price, uint tokensGot);
    event distruted(address indexed sender, address indexed recipient, uint256 rewards);
    event referralsE(address indexed from, address indexed recipient, uint256 rewards);
    
    // emmitted when an address is whitelisted.....
    event Whitelist(
        address indexed userAddress,
        bool Status
    );
    
    
    modifier checkLocked() {
        data memory inData = getData[0];
        require(inData.lockedFunds <= inData.expectedTotalLockFunds,"kindly check the expected locked funds before locking your funds.");
        _;
    }
    
    // Only allow the owner to do specific tasks
    modifier onlyOwner() {
        require(msg.sender == owner,"swapTokenTo TOKEN: YOU ARE NOT THE OWNER.");
        _;
    }

    modifier onlyAdmin() {
        require(isAdminAddress[msg.sender], "Access Denied: Need Admin Accessibility");
        _;
    }

    modifier permission() {        
        require(msg.sender == owner, "Permission Denied");
        require(isAdminAddress[msg.sender], "Permission Denied");
        _;
    }
    
    // _swapTokenFrom: token address to swap for; 
    // _swapTokenTo: Rigel default token address;
    // _price: amount of $swapTokenTo (How much will one $swapTokenTo cost);
    // expectedLockedValue: amount of the swap token that is expected to be locked on the contract;
    // _specialPoolC: rigel special pool contract.
    constructor( 
            address _swapTokenFrom, 
            address _swapTokenTo,
            uint256 _price, 
            uint256 expectedTotalLockedValue, 
            uint256 _maxLockForEachUser, 
            uint256 _minLockForEachUser,
            address _specialPoolC,
            uint256[] memory _distTime,
            uint256[] memory _percent
        ) 
        {
            data storage inData = getData[0];
            owner =  msg.sender;
            isWhitelist[owner] = true;
            isAdminAddress[owner] = true;
            saleActive = true;
            enableWhitelisting = true;

            specialPoolC = _specialPoolC;
            swapTokenFrom = _swapTokenFrom;
            swapTokenTo = _swapTokenTo;

            inData.price = _price;
            inData.maxLockForEachUser = _maxLockForEachUser;
            inData.minLockForEachUser = _minLockForEachUser;
            inData.expectedTotalLockFunds = expectedTotalLockedValue;
            updateDistributionTime(_distTime, _percent);

    }

    function getLengthOfPeriod() public view returns(uint256) {
        return period[0].length;
    }
    
    // this get the minimum amount to be staked on the special pool
    function getMinimum() public view returns (uint256) {
        (uint256 getMin) = rigelSpecialPool(specialPoolC).getMinimumStakeAmount();
        return getMin;
    }
    
    // check if user have staked their $swapTokenTo on the special pool
    // return true if they have and returns false if otherwise.
   function checkPoolBalance(address user) public view returns(bool) {
       (, uint256 amt,,) = rigelSpecialPool(specialPoolC).userInfo(user);       
       if(amt > 0) {
           return true;
       } else {
           return false;
       }
       
   }

    // Buy tokens function
    // Note: This function allows only purchases of "full" tokens, purchases of 0.1 tokens or 1.1 tokens for example are not possible
    function lockFund(uint256 _tokenAmount, address _referral) public checkLocked{
        // Check if sale is active and user tries to buy atleast 1 token
        require(saleActive, "swapTokenTo: SALE HAS ENDED.");
        bool currentLocked = checkPoolBalance(msg.sender);
        require(currentLocked, "user is require to stake using the special pool contract");
        data storage inData = getData[0];
        UserFunds storage user = userFunds[msg.sender];
        uint256 userLocked = user.lockedFunds;
        if (user.lockedFunds == 0) {
            require(_tokenAmount >= inData.minLockForEachUser, "Can't lock below minimum amount");
        }
        if(enableWhitelisting) {
            require(isWhitelist[msg.sender], "swapTokenTo: Address Not whitelisted");
        }
        uint256 locked = inData.lockedFunds;
        require((userLocked + _tokenAmount) <= inData.maxLockForEachUser, "Cant exceed the max amount of token to lock for this User.");
        require(locked <= inData.expectedTotalLockFunds, "Rigel: Expected amount has been locked");
        IERC20(swapTokenFrom).transferFrom(msg.sender, address(this), _tokenAmount);
        // update user data on the contract..
        uint256 userDep = userLocked + _tokenAmount;
        user.lockedFunds = userDep;
        uint256 rwd = getRewardAmount(userDep);
        user.rewards =  rwd ;
        inData.lockedFunds = locked + _tokenAmount;
        allowReferral(_tokenAmount, _referral);
        userUpdate();
        emit Sale(msg.sender, inData.price, _tokenAmount);
    }
    
    function getRewardAmount(uint256 _amount) public view returns(uint256) {
        data storage inData = getData[0];
        return (_amount * 1E18)  / inData.price;
    }
    
    // distribute users rewards
    // can only be called by the owner
    // it delete all the users store in the contract
    function distribute(uint256 _distPercent) public permission {
        dist(_distPercent);
    }

    function disburseRefRewards() external permission {
        uint256 len = referralAddresses.length;
        for (uint256 i; i < len;) {
            address wallet = referralAddresses[i];
            uint256 uRew = referredAndReferralRw[wallet];
            IERC20(swapTokenTo).transfer(wallet, uRew);
            unchecked {
                i++;
            }
            emit referralsE(owner, wallet, uRew);
        }
    }

    function disburseReferRewards() external permission {
        uint256 len = withReferral.length;
        for (uint256 i; i < len; ) {
            address wallet = withReferral[i];
            uint256 uRew = referredAndReferralRw[wallet];
            IERC20(swapTokenTo).transfer(wallet, uRew); 
            unchecked {
                i++;
            }           
            emit referralsE(owner, wallet, uRew);
        }
    }

    function updateInfoData(
        uint256 _price, 
        uint256 expectedtotalLockedValue, 
        uint256 _maxLockForEachUser, 
        uint256 _minLockForEachUser
    ) external onlyOwner {

        data storage inData = getData[0];
        inData.price = _price;
        inData.maxLockForEachUser = _maxLockForEachUser;
        inData.minLockForEachUser = _minLockForEachUser;
        inData.expectedTotalLockFunds = expectedtotalLockedValue;
    }
    
    function safelyDistribute(uint256 _num, uint256 _distPercent) external permission {
        uint loops = claimed + _num;
        for(uint256 i = claimed; i <= loops; ) {
            // get user wallet address..
            address wallet = users[i];
            // get current locked amount of user
            // get user rewards in swapTokenTo
            UserFunds storage user = userFunds[wallet];
            uint256 received = user.amountReceived;
            if (received == user.rewards) {
                delete(users[i]); // empty the users.length
            } else {
                // calculate amount to transfer to user in %
                (uint256 _amt) = getOutPutAmount(_distPercent, user.rewards);
                // update user locked funds
                user.amountReceived = received + _amt;
                // transder from owner to all users
                IERC20(swapTokenTo).transfer(wallet, _amt);
                
                emit distruted(owner, wallet, _amt);
                claimed ++;
                if (claimed == users.length) {
                    claimed = 0;
                }
            }
            unchecked {
                i++;
            }            
        }
    }

    function getOutPutAmount(uint256 _distPercent, uint256 amountToRecieve) public view returns(uint256) {
        uint256 dec = 10 ** IERC20(swapTokenTo).decimals();
        uint256 _amt = ((amountToRecieve * (_distPercent * dec)) / 100E18);
        return (_amt);
    }

    // intentional not calling directly from struct.
    function viewData() public view returns(
        address _swapTokenFrom,
        address _swapTokenTo,
        address _specialPoolC,
        uint256  price,
        uint256  expectedTotalLockFunds,
        uint256  lockedFunds,
        uint256  maxLockForEachUser,
        uint256  minLockForEachUser
        ) {
        data memory inData = getData[0];
        
        return(
            _swapTokenFrom,
            _swapTokenTo,
            _specialPoolC,
            inData.price,
            inData.expectedTotalLockFunds,
            inData.lockedFunds,
            inData.maxLockForEachUser,
            inData.minLockForEachUser
        );
    }
    
    // get the total numbers of addresses that exist on the rigelLaunchPad contract.
    function userLenghtArg() public view returns(uint256) {
        return users.length;
    }
    
    // End the sale, don't allow any purchases anymore and send remaining swapTokenTo to the owner
    function salesStatus(bool status) external onlyOwner{
        if (!status) {
            // End the sale
            saleActive = false;
            // Send unsold tokens and remaining busd to the owner. Only ends the sale when both calls are successful
            IERC20(swapTokenTo).transfer(owner, IERC20(swapTokenTo).balanceOf(address(this)));
        } else {
            saleActive = true;
        }
        
    }
    
    // Withdraw busd to _recipient
    function withdrawswapTokenFrom(address _to) external onlyOwner {
        uint _swapTokenFromdBalance = IERC20(swapTokenFrom).balanceOf(address(this));
        require(_swapTokenFromdBalance >= 1, "swapTokenTo: NO Output TO WITHDRAW");
        IERC20(swapTokenFrom).transfer(_to, _swapTokenFromdBalance);
    }
    
    // Withdraw (accidentally) to the contract sent eth
    function withdrawETH() external onlyOwner {
        payable(owner).transfer((address(this)).balance);
    }
    
    // Withdraw (accidentally) to the contract sent ERC20 tokens except swapTokenTo
    function withdrawIERC20(address _token) external onlyOwner {
        uint _tokenBalance = IERC20(_token).balanceOf(address(this));        
        IERC20(_token).transfer(owner, _tokenBalance);
    }
    
    // use to add multiple address to perform an admin operation on the contract....
    function multipleAdmin(address[] calldata _adminAddress, bool status) external onlyOwner {
        uint256 lent = _adminAddress.length;
        if (status == true) {
           for(uint256 i = 0; i < lent;) {
                isAdminAddress[_adminAddress[i]] = status;
                unchecked {
                    i++;
                }
            } 
        } else{
            for(uint256 i = 0; i < lent;) {
                delete(isAdminAddress[_adminAddress[i]]);
                unchecked {
                    i++;
                }
            }
        }
    }
    
    // use to whitelist multiple address to perform transaction on the contract....
    function updateWhitelist(address[] calldata _users, bool status) external onlyAdmin {
        if (status == true) {
           for(uint256 i = 0; i < _users.length;) {
            isWhitelist[_users[i]] = status;
            unchecked {
                i++;
            }
            } 
        } else{
            for(uint256 i = 0; i < _users.length;) {
               delete(isWhitelist[_users[i]]);
               unchecked {
                    i++;
                }
            } 
        }    
    }

    function setReferralPercentage(uint256 _referred, uint256 _referral) external onlyOwner {
        referredPercent = _referred;
        referralPercent = _referral;
    }
    
    // owner to set the expected locking amount
    function expectedTotalLockfund(uint256 total) public onlyOwner {
        data storage inData = getData[0];
        inData.expectedTotalLockFunds = total;
    }

    function disableWhitelisting(bool status) external onlyOwner {
        enableWhitelisting = status;
    }

     function setMinAndMaxLockFund(uint256 newMinimum, uint256 newMaximum) external onlyOwner {
        data storage inData = getData[0];
        inData.maxLockForEachUser = newMaximum;
        inData.minLockForEachUser = newMinimum;
    }
    
    // Change the token price
    // Note: Set the price respectively considering the decimals of busd
    // Example: If the intended price is 0.01 per token, call this function with the result of 0.01 * 10**18 (_price = intended price * 10**18; calc this in a calculator).
    function tokenPrice(uint _price) external onlyOwner {
        data storage inData = getData[0];
        inData.price = _price;
    }

    function updateDistributionTime(uint256[] memory _time, uint256[] memory _percent) public onlyOwner {
        uint256 dec = 10 ** IERC20(swapTokenTo).decimals();
        uint256 lent = _time.length;
        uint256 pLent = _percent.length;
        if (lent == 1) {
            require(lent == pLent, "Invalid length of array");
            period[0].push(distributionPeriod(_time[0], _percent[0] * dec));
        }
        if (lent == 2) {
            require(lent == pLent, "Invalid length of array");
            period[0].push(distributionPeriod(_time[0], _percent[0] * dec));
            period[0].push(distributionPeriod(_time[1], _percent[1] * dec));
        }
        if (lent == 3) {
            require(lent == pLent, "Invalid length of array");
            period[0].push(distributionPeriod(_time[0], _percent[0] * dec));
            period[0].push(distributionPeriod(_time[1], _percent[1] * dec));
            period[0].push(distributionPeriod(_time[2], _percent[2] * dec));
        }
        if (lent == 4) {
            require(lent == pLent, "Invalid length of array");
            period[0].push(distributionPeriod(_time[0], _percent[0] * dec));
            period[0].push(distributionPeriod(_time[1], _percent[1] * dec));
            period[0].push(distributionPeriod(_time[2], _percent[2] * dec));
            period[0].push(distributionPeriod(_time[3], _percent[3] * dec));
        }
        if (lent == 5) {
            require(lent == pLent, "Invalid length of array");
            period[0].push(distributionPeriod(_time[0], _percent[0] * dec));
            period[0].push(distributionPeriod(_time[1], _percent[1] * dec));
            period[0].push(distributionPeriod(_time[2], _percent[2] * dec));
            period[0].push(distributionPeriod(_time[3], _percent[3] * dec));
            period[0].push(distributionPeriod(_time[4], _percent[4] * dec));
        }
        if (lent == 6) {
            require(lent == pLent, "Invalid length of array");
            period[0].push(distributionPeriod(_time[0], _percent[0] * dec));
            period[0].push(distributionPeriod(_time[1], _percent[1] * dec));
            period[0].push(distributionPeriod(_time[2], _percent[2] * dec));
            period[0].push(distributionPeriod(_time[3], _percent[3] * dec));
            period[0].push(distributionPeriod(_time[4], _percent[4] * dec));
            period[0].push(distributionPeriod(_time[5], _percent[5] * dec));
        }

    }

        // internal function to for distributions of rewards...
    function dist(uint256 _distPercent) internal {
        uint256 userLength = users.length; 
        for(uint256 i = 0; i <= (userLength - 1); ) {
            // get user wallet address..
            address wallet = users[i];
            // get current locked amount of user
            // get user rewards in swapTokenTo
            UserFunds storage user = userFunds[wallet];
            uint256 received = user.amountReceived;
            if (received == user.rewards) {
                delete(users[i]); // empty the users.length
            } else {
                // calculate amount to transfer to user in %                
                (uint256 _amt) = getOutPutAmount(_distPercent, user.rewards);
                // update user locked funds
                user.amountReceived = received + _amt;
                // transder from owner to all users
                IERC20(swapTokenTo).transfer(wallet, _amt);
                
                emit distruted(owner, wallet, _amt);
                claimed ++;
                if (claimed == users.length) {
                    claimed = 0;
                }
            }
            unchecked {
                i++;
            }  
        }       
        
    }
    
    function userUpdate() internal {
        uint256 lent = users.length;
        if (lent > 0) {
            for (uint256 i = 0; i < lent; ) {
                address aUser = users[i];
                if (aUser == msg.sender) {
                    break;
                }
                if (i == (users.length - 1)) {
                    users.push(msg.sender);
                }
                unchecked {
                    i++;
                }
            }
        } else {
            users.push(msg.sender);
        }
    }
    
    function allowReferral(uint256 _tokenAmount, address _referral) internal {
        if (_referral != address(0)) {
            require(msg.sender != _referral, "Rigel's Protocol: Self Referral is not allow.");
            if (!(hasBeenReferred[_referral])) {
                referralAddresses.push(_referral);
            }
            if (!(hasBeenReferred[msg.sender])) {
                withReferral.push(msg.sender);
            }
            hasBeenReferred[msg.sender] = true;
            hasBeenReferred[_referral] = true;
            uint256 oRew = getRewardAmount(_tokenAmount);            
            uint256 refRew = getRLPerc(oRew);
            uint256 myReward = getRFPerc(oRew);            
            referredAndReferralRw[_referral] += refRew;
            referredAndReferralRw[msg.sender] += myReward;
        }
    }

    function getRLPerc(uint256 amt) internal view returns(uint256 out) {
        out = (amt * referralPercent) / 100E18;
    }

    function getRFPerc(uint256 amt) internal view returns(uint256 out) {
        out = (amt * referredPercent) / 100E18;
    }
}