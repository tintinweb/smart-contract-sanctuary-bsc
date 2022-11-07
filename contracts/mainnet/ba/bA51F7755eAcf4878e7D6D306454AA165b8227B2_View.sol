/**
 *Submitted for verification at BscScan.com on 2022-11-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
abstract contract Context 
{
    function _msgSender() internal view virtual returns (address) 
    {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) 
    {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
abstract contract Ownable is Context
{
    address _owner;

    constructor()  
    {
        _owner = payable(msg.sender);
    }

    modifier onlyOwner() 
    {
        require(_msgSender() == msg.sender, "Only owner");
        _;
    }
}
interface IWalletStorage
{
    // view
    function getBalance(address acc) external view returns(uint);
    function getAllow(address acc, address spender) external view returns (uint);
    // bal
    function addBalance(address acc, uint amount) external;
    function subBalance(address acc, uint amount) external;
    // allow
    function allow(address acc, address rec, uint amount) external;
}

interface IView 
{
    function isUserExist(address acc) external view returns(bool);
    function isUserExistById(uint id) external view returns(bool);
    function getReferalIdById(uint id) external view returns(uint);
    function getAddressById(uint id) external view returns (address);
    function getIdByAddress(address acc)external view returns(uint);
    function getUser(uint id)external view returns(address,uint,uint,uint8,uint);
    function getRefCount(uint id, uint8 lvl) external view returns (uint);
    function getStatsCount(uint id) external view returns (uint);
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function getEmission() external view returns(uint);
    function getFrozenToken(address acc) external view returns(uint);
    function getFrozenDate(address acc) external view returns(uint);
    function balanceWithFrozen(address acc) external view returns(uint);
    function getDeposite(address acc) external view returns(uint);
    function getDepositeDate(address acc) external view returns(uint);
    function getDepositeProfit(address acc) external view returns(uint);
    function getPresaleCount() external view returns(uint);
    function getPrice() external view returns(uint);
    function getPresaleStart() external view returns (bool);
    function getPresaleStartDate() external view returns(uint);
    function getPresaleEndDate() external view returns(uint);
    function getPresaleLimit(address acc)external view returns(uint);
    function getMaxToken() external view returns(uint);
    function checkUpdate(uint id) external view returns(bool);
}
interface IUserStorage
{
    function isUserExistByAddress(address user) external view returns(bool);
    function isUserExistById(uint id) external view returns(bool);
    function getReferalByAddress(address userAddress) external view returns(uint);
    function getReferalById(uint id) external view returns(uint);
    function getUserByAddress(address userAddress) external view returns(uint,uint,uint,uint8,uint);
    function getUserById(uint id) external view returns(address,uint,uint,uint8,uint);
    function getUserIdByAddress(address acc) external view returns(uint);
    function getUserAddressById(uint id) external view returns(address);
    function getUserDepositeTeam(uint id) external view returns(uint);
    function getUserStatusLVL(uint id) external view returns(uint8);

    //// UPDATE
    function addUser(address user, uint referalId) external;
    function addReferal (uint referalId) external;
    function updateUserDepositeTeam(uint userId,uint depositeTeam) external;
    function updateUserStatus(uint userId) external;
    function updateUserTeamCount(uint userId,uint team) external;
}
interface ITermsStorage
{
   
    /// VIEW 
    function getTermsLength() external view returns(uint);

    function getDepositePercent(uint8 lvl) external view returns(uint8);

    function getFullReferalPercent() external view returns(uint);

    function getOpenedLevel(uint lvl) external view returns(uint8);

    function getReferalPercent(uint lvl) external view returns(uint);

    function getFirstLineCount(uint lvl) external view returns(uint);

    function getPersonalStacking(uint lvl) external view returns(uint);

    function getTeamStacking(uint lvl) external view returns(uint);

    function getFirstLineStatusLevelCount(uint lvl) external view returns(uint);
  

}
interface ITeam
{

    function getTeamCountLVL(uint id, uint8 lvl) external view returns (uint);
    function getTeamCountStats(uint id) external view returns (uint);
    function addTeamer (uint id, uint8 lvl) external;
    function addTeameStatus (uint id) external;
    function clearTeameStatus (uint id)  external;

}
interface ISupplyStorage
{
 /// VIEW
    function getSupply() external view returns(uint, uint);
 ///

/// FUNC
    function subTokenSupply(uint amount)  external;
    function addTokenSupply(uint amount)  external;
///  
}
interface IPresale
{
    function getPresaleCount() external view returns(uint);
    function getPrice() external view returns(uint);
    function getPresaleStart() external view returns (bool);
    function getPresaleStartDate() external view returns(uint);
    function getPresaleEndDate() external view returns(uint);
    function subCount(uint amount) external;
    function getPresaleNumber() external view returns(uint8);
    function getUserLimit(address acc) external view returns(uint);
    function getMaxToken() external view returns(uint);
    function buyTokenOnPresale(address acc, uint amount) external;
}
interface IDepositeStorage
{
    function getDeposite(address acc) external view returns (uint);
    function getDepDate (address acc) external view returns(uint);
    function addDep(address acc, uint amount) external;
    function subDep(address acc, uint amount) external;
    function setDepDate(address acc, uint date) external;
}
interface IFrozenStorage
{
    function getFrozenDate(uint id) external view returns(uint);
    function getFrozenTokens(uint id) external view returns (uint);
    function setFrozenDate(uint id,uint date) external;
    function setFrozenTokens(uint id, uint tokens) external;
}
contract View is IView, Ownable
{
    IUserStorage userStorage;
    IWalletStorage walletStorage;
    ITermsStorage terms;
    IPresale presale;
    IDepositeStorage depositeStorage;
    IFrozenStorage frozenStorage;
    ISupplyStorage supplyStorage;
    ITeam team;


    uint private _day =86400;
    uint private _twoWeek = 1209600;

   
    constructor(
        address wallet, address user, address presaleAdr, 
        address termsAdr, address deposite, address frozen,
        address supply, address teamAdr)
    {
        userStorage = IUserStorage(user);
        walletStorage = IWalletStorage(wallet);
        presale = IPresale(presaleAdr);
        terms = ITermsStorage(termsAdr);
        depositeStorage = IDepositeStorage(deposite);
        frozenStorage = IFrozenStorage(frozen);
        supplyStorage = ISupplyStorage(supply);
        team = ITeam(teamAdr);
    }


/// USER
    function isUserExist(address acc) public override view returns(bool)
    {
        return userStorage.getUserIdByAddress(acc) != 0;
    } 
    function isUserExistById(uint id) public override view returns(bool) 
    {
        return userStorage.getUserAddressById(id) != address(0);
    } 
    function getReferalIdById(uint id) public override view returns(uint)
    {
        return userStorage.getReferalById(id);
    }
    function getAddressById(uint id) public override view returns (address)
    {
        return userStorage.getUserAddressById(id);
    }
    function getIdByAddress(address acc)public override view returns(uint)
    {
        return userStorage.getUserIdByAddress(acc);
    }
    function getUser(uint id)public override view returns(address,uint,uint,uint8,uint)
    {
        return userStorage.getUserById(id);
    }
///

/// TEAM   
    function getRefCount(uint id, uint8 lvl) public override view returns (uint)
    {
        return team.getTeamCountLVL(id, lvl);
    }
    function getStatsCount(uint id) public override view returns (uint)
    {
        return team.getTeamCountStats(id);
    }
    function checkUpdate(uint id) public override view returns(bool)
    {
        uint8 statusLevel = userStorage.getUserStatusLVL(id);
        if (statusLevel < terms.getTermsLength()-1)
        {
            address userAddress = userStorage.getUserAddressById(id);
            uint personalStacking = depositeStorage.getDeposite(userAddress);
            uint teamStacking = userStorage.getUserDepositeTeam(id);
            uint firstLineCount = team.getTeamCountLVL(id, statusLevel);
            uint firstLineStatusLevel = team.getTeamCountStats(id);
            if (firstLineCount >= terms.getFirstLineCount(statusLevel+1) &&
                personalStacking >= terms.getPersonalStacking(statusLevel+1) &&
                teamStacking >= terms.getTeamStacking(statusLevel+1) &&
                firstLineStatusLevel >= terms.getFirstLineStatusLevelCount(statusLevel+1)
                )
            {
               return true;
            }
        }
        return false;
    }
///


/// WALLET
    function balanceOf(address account) public override view returns (uint)
    {
        return balanceWithFrozen(account);
    }
    function allowance(address owner, address spender) public override view returns (uint)
    {
        return walletStorage.getAllow(owner, spender);
    }
///

/// FROZEN
    function getFrozenToken(address acc) public override view returns(uint)
    {
        uint id = userStorage.getUserIdByAddress(acc);
        if (frozenStorage.getFrozenDate(id)+ _twoWeek < block.timestamp )
        {
            return 0;
        }
        return frozenStorage.getFrozenTokens(id);
    }
    function getFrozenDate(address acc) public override view returns(uint)
    {
        uint id = userStorage.getUserIdByAddress(acc);
        uint frozenDate = frozenStorage.getFrozenDate(id);
        if (frozenDate + _twoWeek < block.timestamp)
        {
            return 0;
        }
        return frozenDate;
    }
    function balanceWithFrozen(address acc) public override view returns(uint)
    {
        uint balance = walletStorage.getBalance(acc);
        uint userId = userStorage.getUserIdByAddress(acc);
        if (frozenStorage.getFrozenDate(userId)+ _twoWeek > block.timestamp )
        {
            balance -= frozenStorage.getFrozenTokens(userId);
        }
        return balance; 
    }
///

/// SUPPLY
    function totalSupply() public override view returns (uint)
    {
        (uint _totalSupply,  uint _totalEmmision) = supplyStorage.getSupply();
        return _totalSupply;
    }
    function getEmission() public override view returns(uint)
    {
        (uint _totalSupply,  uint _totalEmmision) = supplyStorage.getSupply();
        return _totalEmmision;
    } 
///

/// DEPOSITE
    function getDeposite(address acc) public override view returns(uint)
    {
        return depositeStorage.getDeposite(acc);
    }
    function getDepositeDate(address acc) public override view returns(uint)
    {
        return depositeStorage.getDepDate(acc);
    }
    function getDepositeProfit(address acc) public override view returns(uint)
    {
        uint userId = userStorage.getUserIdByAddress(acc);
        uint depDate = depositeStorage.getDepDate(acc);
        uint userDeposite = depositeStorage.getDeposite(acc);
        uint8 userPercent = terms.getDepositePercent(userStorage.getUserStatusLVL(userId));
        uint secPassed = block.timestamp - depDate;
        return secPassed * ((userDeposite * userPercent / 100) / 30 / 86400);
    }
///

/// Presale
    function getPresaleCount() public override view returns(uint)
    {
        return presale.getPresaleCount();
    }
    function getPrice() public override view returns(uint)
    {
        return presale.getPrice();
    }
    function getPresaleStart() public override view returns (bool)
    {
        return presale.getPresaleStart();
    }
    function getPresaleStartDate() public override view returns(uint)
    {
        return presale.getPresaleStartDate();
    }
    function getPresaleEndDate() public override view returns(uint)
    {
        return presale.getPresaleEndDate();
    }
    function getPresaleLimit(address acc)public override view returns(uint)
    {
        return presale.getUserLimit(acc);
    } 
    function getMaxToken() public override view returns(uint)
    {
        return presale.getMaxToken();
    }
///

/// ADMIN
    function setTime(uint day) onlyOwner public 
    {
        _day = day;
        _twoWeek = _day * 14;
    }
    function setWallet(address newAdr) onlyOwner public 
    {
        walletStorage = IWalletStorage(newAdr);
    }
    function setUser (address newAdr) onlyOwner public
    {
        userStorage = IUserStorage(newAdr);
    }
    function setPresale (address newAdr)onlyOwner public
    {
        presale = IPresale(newAdr);
    }
    function setTerms(address newAdr) onlyOwner public 
    {
        terms = ITermsStorage(newAdr);
    }
    function setDeposite(address newAdr) onlyOwner public 
    {
        depositeStorage = IDepositeStorage(newAdr);
    }    
    function setFrozen(address newAdr) onlyOwner public 
    {
        frozenStorage = IFrozenStorage(newAdr);
    }
    function setSupply(address newAdr) onlyOwner public 
    {
        supplyStorage = ISupplyStorage(newAdr);
    }
    function setTeam(address newAdr) onlyOwner public 
    {
        team = ITeam(newAdr);
    }
///
}