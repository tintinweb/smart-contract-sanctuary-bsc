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

    mapping(address => crowdFunder) crowd;

    IBEP20 public busdAddress; // BUSD address
    IBEP20 public NRFX; // address of Nrafex
    INTokenSale public tokenSaleContract; // address of token-sale contract
    bool public lockedNarfex; // from this point users can not deposit busd in this pool
    uint constant WAD = 10 ** 18; // Decimal number with 18 digits of precision

    constructor(
        IBEP20 _busdAddress,
        IBEP20 _NRFX,
        INTokenSale _tokenSaleContract
        ) {
        busdAddress = _busdAddress;
        NRFX = _NRFX;
        tokenSaleContract = _tokenSaleContract;
    }

    /// @notice deposit BUSD tokens from crowdfunders for this pool
    /// @param amount of deposit in this pool in BUSD 
    function depositBUSD(uint256 amount) external {
        address _msgSender = msg.sender;

        require(!lockedNarfex, "crowdfunding in this pool is over");
        require(amount >= 0,"Deposit more than ZERO");
        
        crowd[_msgSender].busdDeposit += amount;
        crowd[_msgSender].deposited = true;
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

    /// @notice transfer BUSD to participate in token-sale
    /// @param amount amount of BUSD
    function buyNRFX(uint256 amount) external {
        require(amount <= getBUSDReserve(), "You don't have this amount of BUSD");
        lockedNarfex = true;
        busdAddress.approve(address(tokenSaleContract), amount);
        tokenSaleContract.buyTokens(amount);
    }

    /// @notice unlocking and transfering NRFX from NTokenSale contract to this contract
    /// @param _numberOfTokens amount NRFX to unlock and transfer
    function unlockNRFX(uint256 _numberOfTokens) external {
        require(lockedNarfex, "crowdfunding in this pool is over");
        tokenSaleContract.unlock();
        tokenSaleContract.withdraw(_numberOfTokens);
    }

    /// @notice distributes NRFX to each user
    function claimNRFX() external  {
        address _msgSender = msg.sender;

        require(lockedNarfex, "crowdfunding in this pool is over");
        require(crowd[_msgSender].deposited, "You are not crowdFunder");
        crowd[_msgSender].deposited = false;
        crowd[_msgSender].avialableBalance = getUserReserve(_msgSender);
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
    function getUserPercantage(address _user) public view returns(uint256){
        uint256 percantage = crowd[_user].busdDeposit * WAD / getBUSDReserve();
        return percantage;
    }

    /// @notice get avialable amount of NRFX for each user
    /// @param _user address of crowdfunder
    /// @return returns avialable amount of NRFX for each user
    function getUserReserve(address _user) public view returns(uint256){
        return getNRFXReserve() * WAD / getUserPercantage(_user);
    }

    /// @notice get address of this pool
    /// @return returns address of this pool
    function getPoolAddress() public view returns(address){
        return address(this);
    }

}