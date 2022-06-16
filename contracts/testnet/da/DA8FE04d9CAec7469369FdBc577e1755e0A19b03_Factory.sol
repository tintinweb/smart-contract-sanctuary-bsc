//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "./Pool.sol";

contract Factory {

    struct Pools{
        address poolAddress;
        address poolOwner;
        uint256 id;
    }

    IBEP20 public busdAddress; // BUSD address
    IBEP20 public NRFX; // address of Nrafex
    INTokenSale public tokenSaleContract; // address of token-sale contract
    uint256 public pid; // pool id
    address public factoryOwner;

    mapping(uint256 => Pools) public pools;

    constructor(
        IBEP20 _busdAddress,
        IBEP20 _NRFX,
        INTokenSale _tokenSaleContract
        ) {
        busdAddress = _busdAddress;
        NRFX = _NRFX;
        tokenSaleContract = _tokenSaleContract;
        factoryOwner = msg.sender;
    }

    /// @notice creating pool for crowdfunding
    /// @param _maxAmount maximum of crowdfunding amount
    function createPool(uint256 _maxAmount) public {
        require(_maxAmount > 0,"_maxAmount can not be zero");
        pid += 1;
        Pool pool = new Pool(busdAddress, NRFX, tokenSaleContract, factoryOwner, _maxAmount);
        pools[pid].poolAddress = address(pool);
        pools[pid].id = pid;
        
    }

    /// @notice changes owner address of factory
    /// @param _owner the address of new owner
    function changeOwner(address _owner) public {
        require(msg.sender == factoryOwner);
        factoryOwner = _owner;
    }

}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;


interface IBEP20 {
    function transfer(address recipient, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);
}

interface INTokenSale {
    function buyTokens(uint256 amount) external;

    function unlock() external;

    function withdraw(uint256 _numberOfTokens) external;
}

contract Pool {
    
    struct crowdFunder{
        uint256 busdDeposit; // user's deposit in BUSD
        uint256 avialableBalance; // balance of NRFX to withdraw
        bool deposited; // user is crowdFunder 
    }

    mapping(address => crowdFunder) crowd; // array address to struct
    
    address[] users; // array of users addresses

    IBEP20 public busdAddress; // BUSD address
    IBEP20 public NRFX; // address of Nrafex
    address public _owner; //owner of this pool
    address public factoryOwner; //
    INTokenSale public tokenSaleContract; // address of token-sale contract
    bool public lockedNarfex; // from this point users can not deposit busd in this pool
    uint256 public maxPoolAmount; // maximum of crowdfunding amount
    uint256 public maxUserAmount; // maximum deposi for user
    uint256 public minUserAmount; // minimum deposi for user
    uint256 public BUSDReserve; // all BUSD in contract before participate in token-sale
    uint constant WAD = 10 ** 18; // Decimal number with 18 digits of precision

    constructor(
        IBEP20 _busdAddress,
        IBEP20 _NRFX,
        INTokenSale _tokenSaleContract,
        address _factoryOwner,
        uint256 _maxPoolAmount
        ) {
        busdAddress = _busdAddress;
        NRFX = _NRFX;
        tokenSaleContract = _tokenSaleContract;
        factoryOwner = _factoryOwner;
        maxPoolAmount = _maxPoolAmount;
        maxUserAmount = WAD * 5;
        minUserAmount = WAD * 1;
        _owner = msg.sender;
    }

    /// @notice deposit BUSD tokens from crowdfunders for this pool
    /// @param amount of deposit in this pool in BUSD 
    function depositBUSD(uint256 amount) external {
        address _msgSender = msg.sender;
        require(maxPoolAmount - amount >= 0, "You can not deposit this amount");
        require(!lockedNarfex, "crowdfunding in this pool is over");
        require(amount >= minUserAmount, "Deposit should be more than minUserAmount");
        require(amount + crowd[_msgSender].busdDeposit <= maxUserAmount, "Deposit should be less than maxUserAmount");

        if (!crowd[_msgSender].deposited) {
            crowd[_msgSender].deposited = true;
            users.push(_msgSender);
        } 

        maxPoolAmount -= amount;
        crowd[_msgSender].busdDeposit += amount;
        
        busdAddress.transferFrom(_msgSender, address(this), amount);
    }

    /// @notice withdraw for crowdfunder NRFX from this pool
    /// @param _numberOfTokens amount NRFX to withdraw
    function withdrawNRFX(uint256 _numberOfTokens) external {
       address _msgSender = msg.sender;

       require(
           _numberOfTokens <= crowd[_msgSender].avialableBalance,
           "You don't have enough NRFX to withdraw"
        );
       crowd[_msgSender].avialableBalance -= _numberOfTokens; 
    }

    /// @notice transfer BUSD to token-sale contract for participate in token-sale
    function buyNRFX() external {
        BUSDReserve = getBUSDReserve();
        lockedNarfex = true;
        busdAddress.approve(address(tokenSaleContract), BUSDReserve);
        tokenSaleContract.buyTokens(BUSDReserve);
    }

    /// @notice unlocking NRFX in INTokenSale contract
    function unlockNRFX() external {
        require(lockedNarfex, "crowdfunding in this pool is over");
        tokenSaleContract.unlock();
    }

    /// @notice transfering NRFX from INTokenSale contract to this contract
    /// @param _numberOfTokens amount NRFX to transfer
    function transferNRFXtoThis(uint256 _numberOfTokens) external {
        tokenSaleContract.withdraw(_numberOfTokens);
    }

    /// @notice distributes NRFX to each user
    function claimNRFX() external  {
        require(lockedNarfex, "crowdfunding in this pool is over");
        for(uint256 i = 0; i < users.length; i++){
            crowd[users[i]].avialableBalance = getUserReserve(users[i]);
            crowd[users[i]].deposited = false;
        }
        
    }

    /// @notice withdraw BUSD deposit for all users (for some issues)
    function emergencyWithdrawBUSD() public {
        require(
            msg.sender == _owner || msg.sender == factoryOwner,
            "Only owner of pool or factory owner can use this function");
        require(!lockedNarfex, "crowdfunding in this pool is over");
        for(uint256 i = 0; i < users.length; i++){
            busdAddress.transfer(users[i], crowd[users[i]].busdDeposit);
            crowd[users[i]].busdDeposit = 0;
            crowd[users[i]].deposited = false;
        }
    }

    /// @notice get balance of BUSD tokens in this pool
    function getBUSDReserve() public view returns (uint256) {
        return busdAddress.balanceOf(address(this));
    }

    /// @notice get balance of NRFX tokens in this pool
    function getNRFXReserve() public view returns (uint256) {
        return NRFX.balanceOf(address(this));
    }    

    /// @notice get percentage of BUSD in this pool for each user
    /// @param _user address of crowdfunder
    /// @return returns percentage of BUSD in this pool for each user
    function getUsersPiece(address _user) public view returns(uint256){
        uint256 percantage = crowd[_user].busdDeposit * WAD / BUSDReserve;
        return percantage;
    }

    /// @notice get avialable amount of NRFX for each user
    /// @param _user address of crowdfunder
    /// @return returns avialable amount of NRFX for each user
    function getUserReserve(address _user) public view returns(uint256){
        return getNRFXReserve() * WAD / getUsersPiece(_user);
    }

    /// @notice get address of this pool
    /// @return returns address of this pool
    function getPoolAddress() public view returns(address){
        return address(this);
    }

}