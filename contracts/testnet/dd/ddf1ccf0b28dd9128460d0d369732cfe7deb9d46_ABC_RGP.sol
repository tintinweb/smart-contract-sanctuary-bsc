/**
 *Submitted for verification at BscScan.com on 2022-03-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-05
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-21
*/

/**
 *Submitted for verification at BscScan.com on 2021-11-17
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

// @dev using 0.8.0.
pragma solidity 0.8.12;
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol";



contract ABC_RGP {

    struct data {
        address swapTokenFrom;
        address swapTokenTo;
        address  specialPoolC;
        uint256  price;
        uint256  expectedTotalLockFunds;
        uint256  lockedFunds;
        uint256  maxLockForEachUser;
        uint256  minLockForEachUser;
    }

    struct distributionPeriod {
        uint256 distributionTime;
        uint256 distributionPercentage;
    }
    uint256 public claimed;
    address  owner;
    bool    public saleActive;  
    bool public enableWhitelisting;  
    address[] public users;
    mapping(address => bool) public isWhitelist;
    mapping(address => bool) public isAdminAddress;
    mapping(address => uint256) public userFunds;
    mapping (uint256 => distributionPeriod[]) public period;  
    mapping(uint256 => data) public getData;
    
    // Emitted when tokens are sold
    event Sale(address indexed account, uint indexed price, uint tokensGot);
    event distruted(address indexed sender, address indexed recipient, uint256 rewards);
    
    // emmitted when an address is whitelisted.....
    event Whitelist(
        address indexed userAddress,
        bool Status
    );
    
    
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    
    
    modifier checkLocked() {
        data memory inData = getData[0];
        require(inData.lockedFunds <= inData.expectedTotalLockFunds,"kindly check the expected locked funds before locking your funds.");
        _;
    }
    
    // Only allow the owner to do specific tasks
    modifier onlyOwner() {
        require(_msgSender() == owner,"swapTokenTo TOKEN: YOU ARE NOT THE OWNER.");
        _;
    }

    modifier onlyAdmin() {
        require(isAdminAddress[_msgSender()], "Access Denied: Need Admin Accessibility");
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
            owner =  _msgSender();
            isWhitelist[_msgSender()] = true;
            isAdminAddress[_msgSender()] = true;
            saleActive = true;
            enableWhitelisting = true;
            inData.specialPoolC = _specialPoolC;
            inData.swapTokenFrom = _swapTokenFrom;
            inData.swapTokenTo = _swapTokenTo;
            inData.price = _price;
            inData.maxLockForEachUser = _maxLockForEachUser;
            inData.minLockForEachUser = _minLockForEachUser;
            inData.expectedTotalLockFunds = expectedTotalLockedValue;
            updateDistributionTime(_distTime, _percent);

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

    function updateDistributionTime(
        uint256[] memory _time,
        uint256[] memory _percent
    ) public onlyOwner {
        uint256 percentage = 1E18;
        if (_time.length == 1) {
            require(_time.length == _percent.length, "Invalid length of array");
            period[0].push(distributionPeriod(_time[0], _percent[0] * percentage));
        }
        if (_time.length == 2) {
            require(_time.length == _percent.length, "Invalid length of array");
            period[0].push(distributionPeriod(_time[0], _percent[0] * percentage));
            period[0].push(distributionPeriod(_time[1], _percent[1] * percentage));
        }
        if (_time.length == 3) {
            require(_time.length == _percent.length, "Invalid length of array");
            period[0].push(distributionPeriod(_time[0], _percent[0] * percentage));
            period[0].push(distributionPeriod(_time[1], _percent[1] * percentage));
            period[0].push(distributionPeriod(_time[2], _percent[2] * percentage));
        }
        if (_time.length == 4) {
            require(_time.length == _percent.length, "Invalid length of array");
            period[0].push(distributionPeriod(_time[0], _percent[0] * percentage));
            period[0].push(distributionPeriod(_time[1], _percent[1] * percentage));
            period[0].push(distributionPeriod(_time[2], _percent[2] * percentage));
            period[0].push(distributionPeriod(_time[3], _percent[3] * percentage));
        }
        if (_time.length == 5) {
            require(_time.length == _percent.length, "Invalid length of array");
            period[0].push(distributionPeriod(_time[0], _percent[0] * percentage));
            period[0].push(distributionPeriod(_time[1], _percent[1] * percentage));
            period[0].push(distributionPeriod(_time[2], _percent[2] * percentage));
            period[0].push(distributionPeriod(_time[3], _percent[3] * percentage));
            period[0].push(distributionPeriod(_time[4], _percent[4] * percentage));
        }
        if (_time.length == 6) {
            require(_time.length == _percent.length, "Invalid length of array");
            period[0].push(distributionPeriod(_time[0], _percent[0] * percentage));
            period[0].push(distributionPeriod(_time[1], _percent[1] * percentage));
            period[0].push(distributionPeriod(_time[2], _percent[2] * percentage));
            period[0].push(distributionPeriod(_time[3], _percent[3] * percentage));
            period[0].push(distributionPeriod(_time[4], _percent[4] * percentage));
            period[0].push(distributionPeriod(_time[5], _percent[5] * percentage));
        }

    }

    function getLengthOfPeriod() public view returns(uint256) {
        return period[0].length;
    }

    // Change the token price
    // Note: Set the price respectively considering the decimals of busd
    // Example: If the intended price is 0.01 per token, call this function with the result of 0.01 * 10**18 (_price = intended price * 10**18; calc this in a calculator).
    function tokenPrice(uint _price) external onlyOwner {
        data storage inData = getData[0];
        inData.price = _price;
    }
    
    // this get the minimum amount to be staked on the special pool
    function getMinimum() public view returns (uint256) {
        data memory inData = getData[0];
        (uint256 getMin) = rigelSpecialPool(inData.specialPoolC).getMinimumStakeAmount();
        return getMin;
    }
    
    // check if user have staked their $swapTokenTo on the special pool
    // return true if they have and returns false if otherwise.
   function checkPoolBalance(address user) public view returns(bool) {
       data memory inData = getData[0];
       (, uint256 amt,,) = rigelSpecialPool(inData.specialPoolC).userInfo(user);
       
       if(amt > 0) {
           return true;
       } else {
           return false;
       }
       
   }

   function updateInfoData(
            address _swapTokenFrom, 
            address _swapTokenTo, 
            uint256 _price, 
            uint256 expectedtotalLockedValue, 
            uint256 _maxLockForEachUser, 
            uint256 _minLockForEachUser,
            address _specialPoolC
        ) external onlyOwner {

       data storage inData = getData[0];
       inData.specialPoolC = _specialPoolC;
        inData.swapTokenFrom = _swapTokenFrom;
        inData.swapTokenTo = _swapTokenTo;
        inData.price = _price;
        inData.maxLockForEachUser = _maxLockForEachUser;
        inData.minLockForEachUser = _minLockForEachUser;
        inData.expectedTotalLockFunds = expectedtotalLockedValue;
   }
    // Buy tokens function
    // Note: This function allows only purchases of "full" tokens, purchases of 0.1 tokens or 1.1 tokens for example are not possible
    function lockFund(uint256 _tokenAmount) public checkLocked{
        bool currentLocked = checkPoolBalance(_msgSender());
        data storage inData = getData[0];
        if (userFunds[_msgSender()] == 0) {
            require(_tokenAmount >= inData.minLockForEachUser, "Can't lock below minimum amount");
        }
        if(enableWhitelisting == true) {
            require(isWhitelist[_msgSender()], "swapTokenTo: Address Not whitelisted");
        }
        require(currentLocked == true, "user is require to stake using the special pool contract");
        require((userFunds[_msgSender()] + _tokenAmount) <= inData.maxLockForEachUser, "Cant exceed the max amount of token to lock for this User.");
        require(inData.lockedFunds <= inData.expectedTotalLockFunds, "Rigel: Expected amount has been locked");
        // Check if sale is active and user tries to buy atleast 1 token
        require(saleActive == true, "swapTokenTo: SALE HAS ENDED.");
        
        IERC20(inData.swapTokenFrom).transferFrom(_msgSender(), address(this), _tokenAmount);        
        // update user data on the contract..
        userFunds[_msgSender()] = userFunds[_msgSender()] + _tokenAmount; 
        inData.lockedFunds = inData.lockedFunds + _tokenAmount;
       
        // store user
        // if (users.length > 0) {
        //     for (uint256 i = 0; i <= users.length; i++) {
        //         address aUser = users[i];
        //         if (aUser != _msgSender()) {
        //             break;
        //         } else {
        //             users.push(_msgSender());
        //         }
        //     }
        // } else {
            users.push(_msgSender());
        // }        
        emit Sale(_msgSender(), inData.price, _tokenAmount);
    }
    
    // distribute users rewards
    // can only be called by the owner
    // it delete all the users store in the contract
    function distribute(uint256 _distPercent) public {
        require(_msgSender() == owner || (isAdminAddress[_msgSender()] == true), "Permission Denied");
        dist(_distPercent);        
    }
    
    // internal function to for distributions of rewards...
    function dist(uint256 _distPercent) internal {
        data storage inData = getData[0];
        uint256 userLength = users.length; 
        for(uint256 i = 0; i <= (userLength - 1); i++) {
            // get user wallet address..
            address wallet = users[i];
            // get current locked amount of user
            // get user rewards in swapTokenTo
            (uint256 amount) = getUser(wallet);
            // calculate amount to transfer to user in %
            uint256 _amt = getOutPutAmount(_distPercent, amount);
            // update user locked funds
            // userFunds[wallet] = userFunds[wallet] - _locked;
            // transder from owner to all users
            IERC20(inData.swapTokenTo).transfer(wallet, _amt);
            if (amount == 0) {
                delete(wallet); // empty the users.length
            }
            emit distruted(owner, wallet, _amt);
        }       
        
    }
    
    function safelyDistribute(uint256 _num, uint256 _distPercent) external {
        require(_msgSender() == owner || (isAdminAddress[_msgSender()] == true), "Permission Denied");
        data storage inData = getData[0];
        uint loops = claimed + _num;
        for(uint256 i = claimed; i <= loops; i++) {
            // get user wallet address..
            address wallet = users[i];
            // get current locked amount of user
            // get user rewards in swapTokenTo
            (uint256 amount) = getUser(wallet);
            // calculate amount to transfer to user in %
            uint256 _amt = getOutPutAmount(_distPercent, amount);
            // update user locked funds
            // userFunds[wallet] = userFunds[wallet] - _locked;
            // transder from owner to all users
            IERC20(inData.swapTokenTo).transfer(wallet, _amt);
            if (amount == 0) {
                delete(wallet); // empty the users.length
            }
            emit distruted(owner, wallet, _amt);
            claimed ++;
            if (claimed == users.length) {
                claimed = 0;
            }
        }
    }

    
    // get current user rewards in $swapTokenTo
    // _user: address of user to get the current rewards for.
    function getUser(address _user) public view returns(uint256 reward) {
        data memory inData = getData[0];
        uint256 userDep = userFunds[_user];
        uint256 rwd = userDep * inData.price;
        reward = rwd / 1E18;
        return ( reward);
    }

    function getOutPutAmount(uint256 _distPercent, uint256 amount) public view returns(uint256 amountOut) {
        data memory inData = getData[0];
        uint256 percentage = IERC20(inData.swapTokenTo).decimals();
        uint256 _amt = (amount * (_distPercent * percentage)) / (100 * percentage);
        return _amt ;
    }

    function viewData() public view returns(
        address swapTokenFrom,
        address swapTokenTo,
        address  specialPoolC,
        uint256  price,
        uint256  expectedTotalLockFunds,
        uint256  lockedFunds,
        uint256  maxLockForEachUser,
        uint256  minLockForEachUser
        ) {
        data memory inData = getData[0];
        
        return(
            inData.swapTokenFrom,
            inData.swapTokenTo,
            inData.specialPoolC,
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
            data memory inData = getData[0];
            // End the sale
            saleActive = false;       
            // Send unsold tokens and remaining busd to the owner. Only ends the sale when both calls are successful
            IERC20(inData.swapTokenTo).transfer(owner, IERC20(inData.swapTokenTo).balanceOf(address(this)));
        } else {
            saleActive = true;        
        }
        
    }
    
    // Withdraw busd to _recipient
    function withdrawswapTokenFrom(address _to) external onlyOwner {
        data memory inData = getData[0];
        uint _swapTokenFromdBalance = IERC20(inData.swapTokenFrom).balanceOf(address(this));
        require(_swapTokenFromdBalance >= 1, "swapTokenTo: NO Output TO WITHDRAW");
        IERC20(inData.swapTokenFrom).transfer(_to, _swapTokenFromdBalance);
    }
    
    // Withdraw (accidentally) to the contract sent eth
    function withdrawETH() external payable onlyOwner {
        payable(owner).transfer(payable(address(this)).balance);
    }
    
    // Withdraw (accidentally) to the contract sent ERC20 tokens except swapTokenTo
    function withdrawIERC20(address _token) external onlyOwner {
        uint _tokenBalance = IERC20(_token).balanceOf(address(this));        
        // Don't allow swapTokenTo to be withdrawn (use endSale() instead)
        IERC20(_token).transfer(owner, _tokenBalance);
    }
    
    // use to add multiple address to perform an admin operation on the contract....
    function multipleAdmin(address[] calldata _adminAddress, bool status) external onlyOwner {
        if (status == true) {
           for(uint256 i = 0; i < _adminAddress.length; i++) {
            isAdminAddress[_adminAddress[i]] = status;
            } 
        } else{
            for(uint256 i = 0; i < _adminAddress.length; i++) {
                delete(isAdminAddress[_adminAddress[i]]);
            }
        }
    }
    
    // use to whitelist multiple address to perform transaction on the contract....
    function updateWhitelist(address[] calldata _users, bool status) external onlyAdmin {
        if (status == true) {
           for(uint256 i = 0; i < _users.length; i++) {
            isWhitelist[_users[i]] = status;
            } 
        } else{
            for(uint256 i = 0; i < _users.length; i++) {
               delete(isWhitelist[_users[i]]);
            } 
        }    
    }    
}