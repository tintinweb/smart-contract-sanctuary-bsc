/**
 *Submitted for verification at BscScan.com on 2022-02-07
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
pragma solidity 0.8.7;
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol";

contract ABC_USDT {

    struct data {
        address swapTokenFrom;
        address swapTokenTo;
        address  specialPoolC;
        uint256  price;
        uint256  expectedLockFunds;
        uint256  lockedFunds;
        uint256  maxLock;
        uint256 distributionTime;
    }
    
    address  owner;
    bool    public saleActive;    
    address[] public users;
    mapping(address => bool) public isWhitelist;
    mapping(address => bool) public isAdminAddress;
    mapping(address => uint256) public userFunds;
    mapping(uint256 => data) private getData;
    
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
        require(inData.lockedFunds <= inData.expectedLockFunds,"kindly check the expected locked funds before locking your funds.");
        _;
    }
    
    // Only allow the owner to do specific tasks
    modifier onlyOwner() {
        require(_msgSender() == owner,"swapTokenTo TOKEN: YOU ARE NOT THE OWNER.");
        _;
    }
    
    modifier onlyAdmin() {
        require(isAdminAddress[_msgSender()]);
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
        uint256 expectedLockedValue, 
        uint256 _maxLock, 
        address _specialPoolC,
        uint256 _distributionTime) 
        {
            data storage inData = getData[0];
            owner =  _msgSender();
            isWhitelist[_msgSender()] = true;
            isAdminAddress[_msgSender()] = true;
            saleActive = true;
            inData.specialPoolC = _specialPoolC;
            inData.swapTokenFrom = _swapTokenFrom;
            inData.swapTokenTo = _swapTokenTo;
            inData.price = _price;
            inData.maxLock = _maxLock;
            inData.expectedLockFunds = expectedLockedValue;
            inData.distributionTime = _distributionTime;
    }
    
    // owner to set the expected locking amount
    function expectedLockfund(uint256 total) public onlyOwner {
        data storage inData = getData[0];
        inData.expectedLockFunds = total;
    }

    function updateDistributionTime(uint256 newTime) external onlyOwner {
        data storage inData = getData[0];
        inData.distributionTime = newTime;
    }
    
    
    // Change the token price
    // Note: Set the price respectively considering the decimals of busd
    // Example: If the intended price is 0.01 per token, call this function with the result of 0.01 * 10**18 (_price = intended price * 10**18; calc this in a calculator).
    function tokenPrice(uint _price) external onlyOwner {
        data storage inData = getData[0];
        inData.price = _price;
    }
    
    // this get the minimum amount to be staked on the special pool
    function getMinimum() public view returns (uint256 _min) {
        data memory inData = getData[0];
        (uint256 getMin) = rigelSpecialPool(inData.specialPoolC).getMinimumStakeAmount();
        _min = getMin;
        return _min;
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
    // Buy tokens function
    // Note: This function allows only purchases of "full" tokens, purchases of 0.1 tokens or 1.1 tokens for example are not possible
    function lockFund(uint256 _tokenAmount) public checkLocked{
        bool currentLocked = checkPoolBalance(_msgSender());
        data storage inData = getData[0];
        require(currentLocked == true, "user is require to stake using the special pool contract");
        require(isWhitelist[_msgSender()], "swapTokenTo: Address Not whitelisted");
        require(userFunds[_msgSender()] <= inData.maxLock, "Cant exceed the max amount of token to lock for this User.");
        
        // Check if sale is active and user tries to buy atleast 1 token
        require(saleActive == true, "swapTokenTo: SALE HAS ENDED.");
        require(_tokenAmount >= 1, "swapTokenTo: BUY ATLEAST 1 TOKEN.");
        
        // Transfer busd from _msgSender() to the contract
        // If it returns false/didn't work, the
        //  msg.sender may not have allowed the contract to spend busd or
        //  msg.sender or the contract may be frozen or
        //  msg.sender may not have enough busd to cover the transfer.
        IERC20(inData.swapTokenFrom).transferFrom(_msgSender(), address(this), _tokenAmount);
        
        // update user data on the contract..
        userFunds[_msgSender()] += _tokenAmount;
        
        // store user
        users.push(_msgSender());
        
        inData.lockedFunds = inData.lockedFunds + _tokenAmount;
        emit Sale(_msgSender(), inData.price, _tokenAmount);
    }
    
    // distribute users rewards
    // can only be called by the owner
    // it delete all the users store in the contract
    function distribute(uint256 _distPercent) public onlyOwner {
        data memory inData = getData[0];
        require(inData.expectedLockFunds <= inData.lockedFunds, "cant send value greater than the expected distribution, user disableSale function");

        dist(_distPercent);
        
    }
    
    // internal function to for distributions of rewards...
    function dist(uint256 _distPercent) internal {
        data storage inData = getData[0];
        require(block.timestamp > inData.distributionTime, "Cant distribute before Distribution time.");

        uint256 userLength = users.length; // for gas efficiency
        for(uint256 i = 0; i <= userLength; i++) {
            // get user wallet address..
            address wallet = users[i];
            // get current locked amount of user
            uint256 _locked = userFunds[wallet];
            // get user rewards in swapTokenTo
            (uint256 amount) = getUser(wallet);
            // calculate amount to transfer to user in %
            uint256 _amt = (_distPercent / 100E18) * amount;
            // update user locked funds
            userFunds[wallet] = userFunds[wallet] - _locked;
            // update total locked funds
            inData.lockedFunds = inData.lockedFunds -_locked;
            // transder from owner to all users
            IERC20(inData.swapTokenTo).transfer(wallet, _amt);
            if (amount == 0) {
                delete(wallet); // empty the users.length
            }
            emit distruted(owner, wallet, _amt);
        }       
        
    }
    
    function safelyDistribute(uint256 _num, uint256 _distPercent) external onlyOwner{
        data storage inData = getData[0];
        require(block.timestamp > inData.distributionTime, "Cant distribute before Distribution time.");

        for(uint256 i = 0; i <= _num; i++) {
            // get user wallet address..
            address wallet = users[i];
            // get current locked amount of user
            uint256 _locked = userFunds[wallet];
            // get user rewards in swapTokenTo
            (uint256 amount) = getUser(wallet);
            // calculate amount to transfer to user in %
            uint256 _amt = (_distPercent / 100E18) * amount;
            // update user locked funds
            userFunds[wallet] = userFunds[wallet] - _locked;
            // update total locked funds
            inData.lockedFunds = inData.lockedFunds -_locked;
            // transder from owner to all users
            IERC20(inData.swapTokenTo).transfer(wallet, _amt);
            if (amount == 0) {
                delete(wallet); // empty the users.length
            }
            emit distruted(owner, wallet, _amt);
        }
    }
    
    // get current user rewards in $swapTokenTo
    // _user: address of user to get the current rewards for.
    function getUser(address _user) public view returns(uint256 rewards) {
        data memory inData = getData[0];
        rewards = userFunds[_user] * inData.price;
        return ( rewards / 1E18);
    }

    function getOutPutAmount(uint256 _amount) public view returns(uint256 _rewards) {
        data memory inData = getData[0];
        _rewards = (_amount * inData.price) / 1E18;
        return _rewards;
    }

    function viewData() public view returns(
        address swapTokenFrom,
        address swapTokenTo,
        address  specialPoolC,
        uint256  price,
        uint256  expectedLockFunds,
        uint256  lockedFunds,
        uint256  maxLock,
        uint256 distributionTime
        ) {
        data memory inData = getData[0];
        
        return(
            inData.swapTokenFrom,
            inData.swapTokenTo,
            inData.specialPoolC,
            inData.price,
            inData.expectedLockFunds,
            inData.lockedFunds,
            inData.maxLock,
            inData.distributionTime
        );
    }
    
    // get the total numbers of addresses that exist on the rigelLaunchPad contract.
    function userLenghtArg() public view returns(uint256) {
        return users.length;
    }
    
    // End the sale, don't allow any purchases anymore and send remaining swapTokenTo to the owner
    function disableSale(uint256 _distPercent) external onlyOwner{
        data memory inData = getData[0];
        // End the sale
        saleActive = false;
        
        dist(_distPercent);
        
        // Send unsold tokens and remaining busd to the owner. Only ends the sale when both calls are successful
        IERC20(inData.swapTokenTo).transfer(owner, IERC20(inData.swapTokenTo).balanceOf(address(this)));
        
    }
    
    // Start the sale again - can be called anytime again
    // To enable the sale, send swapTokenTo tokens to this contract
    function enableSale() external onlyOwner{
        data memory inData = getData[0];
        // Enable the sale
        saleActive = true;
        
        // Check if the contract has any tokens to sell or cancel the enable
        require(IERC20(inData.swapTokenTo).balanceOf(address(this)) >= 1, "swapTokenTo: CONTRACT DOES NOT HAVE TOKENS TO SELL.");
    }
    
    // Withdraw busd to _recipient
    function withdrawswapTokenFrom() external onlyOwner {
        data memory inData = getData[0];
        uint _swapTokenFromdBalance = IERC20(inData.swapTokenFrom).balanceOf(address(this));
        require(_swapTokenFromdBalance >= 1, "swapTokenTo: NO BUSD TO WITHDRAW");
        IERC20(inData.swapTokenFrom).transfer(owner, _swapTokenFromdBalance);
    }
    
    // Withdraw (accidentally) to the contract sent eth
    function withdrawETH() external payable onlyOwner {
        payable(owner).transfer(payable(address(this)).balance);
    }
    
    // Withdraw (accidentally) to the contract sent ERC20 tokens except swapTokenTo
    function withdrawIERC20(address _token) external onlyOwner {
        data memory inData = getData[0];
        uint _tokenBalance = IERC20(_token).balanceOf(address(this));
        
        // Don't allow swapTokenTo to be withdrawn (use endSale() instead)
        require(_tokenBalance > 0 && _token != inData.swapTokenTo, "swapTokenTo: CONTRACT DOES NOT OWN THAT TOKEN OR TOKEN IS swapTokenTo.");
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
    function updateWhitelist(address[] calldata _adminAddress, bool status) external onlyAdmin {
        if (status == true) {
           for(uint256 i = 0; i < _adminAddress.length; i++) {
            isWhitelist[_adminAddress[i]] = status;
            } 
        } else{
            for(uint256 i = 0; i < _adminAddress.length; i++) {
               delete(isWhitelist[_adminAddress[i]]);
            } 
        }
    
    }
    
}