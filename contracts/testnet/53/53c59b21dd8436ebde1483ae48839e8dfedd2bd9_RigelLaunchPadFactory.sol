/**
 *Submitted for verification at BscScan.com on 2022-02-24
*/

// File: contracts\Interface\rigelSpecialPool.sol

// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

interface rigelSpecialPool {
    function userInfo(address _addr) external view returns(address _staker, uint256 _amountStaked, uint256 _userReward, uint _timeStaked);
    function getMinimumStakeAmount() external view returns(uint256 min);
}

// File: contracts\Interface\IERC20.sol

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

// File: contracts\Interface\IrigelProtocolLanchPadPool.sol


interface IrigelProtocolLanchPadPool {
    
    function owner() external view returns (address);
    function factory() external view returns (address);
    function period(uint256 _idZero, uint256 _chkPeriod) external view returns (uint256, uint256);
    function viewData() external view returns (
        address swapTokenFrom, 
        address swapTokenTo, 
        address  specialPoolC,
        uint256  price,
        uint256  expectedLockFunds,
        uint256  lockedFunds,
        uint256  maxLock
    );

    function userFunds(address _user) external returns (uint256);
    function isWhitelist(address _user) external returns (bool);
    function getMinimum() external returns (uint256);
    function checkPoolBalance(address _user) external returns (bool);
    function lockFund(address staker, uint256 _amount) external;
    function getUser(address _user) external returns (uint256);
    function getOutPutAmount(uint256 _amt) external returns (uint256);
    function lengthOfPeriod() external returns (uint256);
}

// File: contracts\rigelProtocolLanchPadPool.sol

/**
 *Submitted for verification at BscScan.com on 2021-11-17
*/


contract rigelProtocolLanchPadPool is IrigelProtocolLanchPadPool {

    struct data {
        address swapTokenFrom;
        address swapTokenTo;
        address  specialPoolC;
        uint256  price;
        uint256  expectedLockFunds;
        uint256  lockedFunds;
        uint256  maxLock;
    }

    struct distributionPeriod {
        uint256 distributionTime;
        uint256 distributionPercentage;
    }
    
    address public owner;
    address public factory;
    bool    public saleActive;    
    address[] public users;
    mapping (uint256 => distributionPeriod[]) public period;    
    mapping(uint256 => data) private getData;
    mapping(address => bool) public isWhitelist;
    mapping(address => bool) public isAdminAddress;
    mapping(address => uint256) public userFunds;

    // Emitted when tokens are sold
    event Sale(address indexed account, uint indexed price, uint tokensGot);
    event distruted(address indexed sender, address indexed recipient, uint256 rewards);
    
    // emmitted when an address is whitelisted.....
    event initial(address contractAddress, address indexed factory, address indexed getOwner );   
    
    constructor() {           
        factory =  _msgSender();
    }

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

    function initialize(
        address _owner,
        address _swapTokenFrom, 
        address _swapTokenTo, 
        uint256 _price, 
        uint256 expectedLockedValue, 
        uint256 _maxLock, 
        address _specialPoolC,
        uint256[] memory _time, 
        uint256[] memory _percent
        ) external {
        getInit( _owner, _swapTokenFrom, _swapTokenTo, _price, expectedLockedValue, _maxLock, _specialPoolC);
        isWhitelist[_owner] = true;        
        isAdminAddress[_owner] = true;

        if (_time.length == 1) {
            require(_time.length == _percent.length, "Invalid length of array");
            period[0].push(distributionPeriod(_time[0], _percent[0]));
        }
        if (_time.length == 2) {
            require(_time.length == _percent.length, "Invalid length of array");
            period[0].push(distributionPeriod(_time[0], _percent[0]));
            period[0].push(distributionPeriod(_time[1], _percent[1]));
        }
        if (_time.length == 3) {
            require(_time.length == _percent.length, "Invalid length of array");
            period[0].push(distributionPeriod(_time[0], _percent[0]));
            period[0].push(distributionPeriod(_time[1], _percent[1]));
            period[0].push(distributionPeriod(_time[2], _percent[2]));
        }
        if (_time.length == 4) {
            require(_time.length == _percent.length, "Invalid length of array");
            period[0].push(distributionPeriod(_time[0], _percent[0]));
            period[0].push(distributionPeriod(_time[1], _percent[1]));
            period[0].push(distributionPeriod(_time[2], _percent[2]));
            period[0].push(distributionPeriod(_time[3], _percent[3]));
        }
        emit initial(address(this), factory, _owner);
    }

    function getInit(
        address _owner,
        address _swapTokenFrom, 
        address _swapTokenTo, 
        uint256 _price, 
        uint256 expectedLockedValue, 
        uint256 _maxLock, 
        address _specialPoolC
    ) internal {
        data storage inData = getData[0];
        owner = _owner;
        saleActive = true;
        inData.specialPoolC = _specialPoolC;
        inData.swapTokenFrom = _swapTokenFrom;
        inData.swapTokenTo = _swapTokenTo;
        inData.price = _price;
        inData.maxLock = _maxLock;
        inData.expectedLockFunds = expectedLockedValue;
    }

    function tokenPrice(uint256 _id, uint256 _price) external onlyOwner {
        data storage inData = getData[_id];
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
    function lockFund(address _for, uint256 _tokenAmount) public {
        bool currentLocked = checkPoolBalance(_for);
        data storage inData = getData[0];
        require(currentLocked == true, "user is require to stake using the special pool contract");
        require(isWhitelist[_for], "swapTokenTo: Address Not whitelisted");
        require(userFunds[_for] <= inData.maxLock, "Cant exceed the max amount of token to lock for this User.");
        require(inData.lockedFunds <= inData.expectedLockFunds, "Rigel: Expected amount has been locked");
        // Check if sale is active and user tries to buy atleast 1 token
        require(saleActive == true, "swapTokenTo: SALE HAS ENDED.");
        require(_tokenAmount >= 1, "swapTokenTo: BUY ATLEAST 1 TOKEN.");
        
        // Transfer busd from _for to the contract
        // If it returns false/didn't work, the
        //  msg.sender may not have allowed the contract to spend busd or
        //  msg.sender or the contract may be frozen or
        //  msg.sender may not have enough busd to cover the transfer.
        IERC20(inData.swapTokenFrom).transferFrom(_for, address(this), _tokenAmount);
        
        // update user data on the contract..
        userFunds[_for] += _tokenAmount;
        
        // store user
        users.push(_for);
        
        inData.lockedFunds = inData.lockedFunds + _tokenAmount;
        emit Sale(_for, inData.price, _tokenAmount);
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
        // require(block.timestamp >= inData.FirstDistributionTime, "Cant distribute before Distribution time.");

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
        // require(block.timestamp > inData.FirstDistributionTime, "Cant distribute before Distribution time.");

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
    function getUser(address _user) public view returns(uint256 reward) {
        data memory inData = getData[0];
        // distributionPeriod memory p = period[0];
        // uint256 lg = period[0].length;
        // , uint256 firstBatch, uint256 secondBatch, uint256 thirdBatch


        uint256 userDep = userFunds[_user];
        uint256 rwd = userDep * inData.price;
        reward = rwd / 1E18;
        // firstBatch = (inData.PercentageOnFirstDist / 100E18) * userDep;
        // secondBatch = (inData.PercentageOnSecondDist / 100E18) * userDep;
        // thirdBatch = (inData.PercentageOnThirdDist / 100E18) * userDep;
        // , firstBatch, secondBatch, thirdBatch 
        return ( reward);
    }

    function lengthOfPeriod() external view returns(uint) {
        uint256 lg = period[0].length;
        return(lg);
    }

    function getOutPutAmount(uint256 _amount) public view returns(uint256 amountOut) {
        data memory inData = getData[0];
        amountOut = (_amount * inData.price) / 1E18;
        return amountOut;
    }

    function viewData() public view returns(
        address swapTokenFrom,
        address swapTokenTo,
        address  specialPoolC,
        uint256  price,
        uint256  expectedLockFunds,
        uint256  lockedFunds,
        uint256  maxLock
        ) {
        data memory inData = getData[0];
        
        return(
            inData.swapTokenFrom,
            inData.swapTokenTo,
            inData.specialPoolC,
            inData.price,
            inData.expectedLockFunds,
            inData.lockedFunds,
            inData.maxLock
        );
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
        // Check if the contract has any tokens to sell or cancel the enable

        require(IERC20(inData.swapTokenTo).balanceOf(address(this)) >= 1, "swapTokenTo: CONTRACT DOES NOT HAVE TOKENS TO SELL.");
        // Enable the sale

        saleActive = true;
        
    }
    
    // Withdraw busd to _recipient
    function withdrawSwapTokenFrom() external onlyOwner {
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

// File: contracts\Interface\IRigelLaunchPadFactory.sol


interface IRigelLaunchPadFactory {
    
    function owner() external view returns (address);
    function specialPoolContract() external view returns (address);
    function getPairedPad(address _swapFrom, address _swapTo) external view returns (address);
    function allPairs(uint256 _id) external view returns (address);
    function allPairsLength() external returns (uint256);
    function creatingPair(
        address _swapTokenFrom, 
        address _swapTokenTo,
        uint256 _price, 
        uint256 expectedLockedValue, 
        uint256 _maxLock, 
        uint256[] memory _time, 
        uint256[] memory _percent
    ) external returns(address);
}

// File: contracts\RigelLaunchPadFactory.sol

contract RigelLaunchPadFactory is IRigelLaunchPadFactory {
    address public owner;
    address public specialPoolContract;

    mapping(address => mapping(address => address)) public getPairedPad;
    address[] public allPairs;


    constructor(address specialPool) {
        owner = msg.sender;
        specialPoolContract = specialPool;
    }

    event PairCreated(address swapFrom, address swapTo, address pair, uint256 lngth);

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function creatingPair(
        address _swapTokenFrom, 
        address _swapTokenTo,
        uint256 _price, 
        uint256 expectedLockedValue, 
        uint256 _maxLock, 
        uint256[] memory _time, 
        uint256[] memory _percent
        ) external returns (address pair) {
        require(_swapTokenFrom != _swapTokenTo, 'RGPFutrueExchange: IDENTICAL_ADDRESSES');
        
        // (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        
        require(_swapTokenFrom != address(0), 'RIGEL: ZERO_ADDRESS');
        require(getPairedPad[_swapTokenFrom][_swapTokenTo] == address(0), 'RGPFutrueExchange: PAIR_EXISTS'); // single check is sufficient

        bytes memory bytecode = type(rigelProtocolLanchPadPool).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(_swapTokenFrom, _swapTokenTo, _price, expectedLockedValue, _maxLock));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        rigelProtocolLanchPadPool(pair).initialize(
            msg.sender, 
            _swapTokenFrom, 
            _swapTokenTo, 
            _price, 
            expectedLockedValue,
            _maxLock,
            specialPoolContract,
            _time,
            _percent
        );

        getPairedPad[_swapTokenFrom][_swapTokenTo] = pair;
        getPairedPad[_swapTokenTo][_swapTokenFrom] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(_swapTokenFrom, _swapTokenTo, pair, allPairs.length);
    }

    function setSpecialPoolContract(address newSpecialPool) external {
        require(msg.sender == owner, "Access Denied: Caller not the owner");
        specialPoolContract = newSpecialPool;
    }
     
}