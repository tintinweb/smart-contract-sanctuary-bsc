/**
 *Submitted for verification at BscScan.com on 2023-03-03
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
        this; 
        return msg.data;
    }
}
abstract contract OwnableV2 is Context
{
    address _owner;
    address public _newOwner;
    constructor()  
    {
        _owner = payable(msg.sender);
    }

    modifier onlyOwner() 
    {
        require(_msgSender() == _owner, "Only owner");
        _;
    }

    function changeOwner(address newOwner) onlyOwner public
    {
        _newOwner = newOwner;
    }
    function confirm() public
    {
        require(_newOwner == msg.sender);
        _owner = _newOwner;
    }
}
abstract contract ContractOwnerV2 is OwnableV2
{
    address _contractOwner;

    modifier isContractOwner()
    {
        require(msg.sender == _contractOwner, "no access");
        _;
    }
    function setContractOwner(address contractOwner) onlyOwner public 
    {
        _contractOwner = contractOwner;
    }
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
interface IReferalFirstLine
{
    function getReferalsCount(uint id) external view returns (uint);
    function getReferals(uint id) external view returns(uint[] memory);  
    function addReferal(uint id, uint refId ) external;  
}
interface ISupplyStorage
{
    function getSupply() external view returns(uint, uint);
    function subTokenSupply(uint amount)  external;
    function addTokenSupply(uint amount)  external;
}
interface ITeam
{
    function getTeamCountLVL(uint id, uint8 lvl) external view returns (uint);
    function getTeamCountStats(uint id) external view returns (uint);
    function addTeamer (uint id, uint8 lvl) external;
    function addTeameStatus (uint id) external;
    function clearTeameStatus (uint id)  external;
}
interface ITermsStorage
{
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
interface IUnfrozen
{
    function getCount() external view returns (uint);
    function getUnfrozenById(uint userId) external view returns (address);
    function getUnfrozenByAddress(address acc) external view returns (bool);
    function getExtra(uint balance) external view returns (uint8);
    function setUnfrozen (address acc) external;
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
    function addUser(address user, uint referalId) external;
    function addReferal (uint referalId) external;
    function updateUserDepositeTeam(uint userId,uint depositeTeam) external;
    function updateUserStatus(uint userId) external;
    function updateUserTeamCount(uint userId,uint team) external;
}
interface IWalletStorage
{
    function getBalance(address acc) external view returns(uint);
    function getAllow(address acc, address spender) external view returns (uint);
    function addBalance(address acc, uint amount) external;
    function subBalance(address acc, uint amount) external;
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
    function checkUpdate(uint id) external view returns(bool);
    function getLine (uint id) external view returns (uint[] memory);
    function totalSupply() external view returns (uint);
    function getEmission() external view returns(uint);
    function balanceOf(address account) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function getFrozenToken(address acc) external view returns(uint);
    function getFrozenDate(address acc) external view returns(uint);
    function balanceWithFrozen(address acc) external view returns(uint);
    function getDeposite(address acc) external view returns(uint);
    function getDepositeDate(address acc) external view returns(uint);
    function getDepositeProfit(address acc) external view returns(uint);
}
contract View is IView, OwnableV2
{

    /// OLD
    IUserStorage private userStorage;
    IWalletStorage private walletStorage; 
    IUnfrozen private unfrozen; 
    IDepositeStorage private depositeStorage; 
    IFrozenStorage private frozenStorage = IFrozenStorage(0x921A21547b394C2FA696BE8f81AE7CFf8c288e09);
    ISupplyStorage private supplyStorage = ISupplyStorage(0xb268C21642c455f2BA3C2B3c6A2692f28fa205CE);
    ITeam private team = ITeam(0xa316b11DEf2f93aDfD3C9CB404c88794c1704430);
    IReferalFirstLine private firstLine = IReferalFirstLine(0x512646bEef87433ab7F275f2bB62d1A6E62698fF);
    ITermsStorage private terms = ITermsStorage(0x75f1e7da1375bc77499314DE7971aC50d63320c4);
    


    uint private _day = 86400;
    uint private _twoWeek = 1209600;

    constructor (address _w, address _d, address _un, address _us)
    {
        walletStorage = IWalletStorage(_w);
        userStorage = IUserStorage(_us);
        depositeStorage = IDepositeStorage(_d);
        unfrozen = IUnfrozen(_un);
    }


/// USER
    function isUserExist(address acc) public   override view returns(bool)
    {
        return userStorage.getUserIdByAddress(acc) != 0;
    } 
    function isUserExistById(uint id) public   override view returns(bool) 
    {
        return userStorage.getUserAddressById(id) != address(0);
    } 
    function getReferalIdById(uint id) public   override view returns(uint)
    {
        return userStorage.getReferalById(id);
    }
    function getAddressById(uint id) public   override view returns (address)
    {
        return userStorage.getUserAddressById(id);
    }
    function getIdByAddress(address acc)public   override view returns(uint)
    {
        return userStorage.getUserIdByAddress(acc);
    }
    function getUser(uint id)public   override view returns(address,uint,uint,uint8,uint)
    {
        return userStorage.getUserById(id);
    }
///

/// TEAM   
    function getRefCount(uint id, uint8 lvl) public   override view returns (uint)
    {
        return team.getTeamCountLVL(id, lvl);
    }
    function getStatsCount(uint id) public   override view returns (uint)
    {
        uint8 statusLevel = userStorage.getUserStatusLVL(id);
        uint count = 0;
        uint[] memory inviters = firstLine.getReferals(id);
        for (uint u = 0; u < inviters.length;u++)
        {  
            if (userStorage.getUserStatusLVL(inviters[u]) >= statusLevel)
            {
                count ++;
            }
        }
        return count;
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
            uint firstLineStatusLevel = getStatsCount(id);
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
    function getLine (uint id) public override view returns (uint[] memory)
    {
        return firstLine.getReferals(id);
    }
///

/// WALLET
    function balanceOf(address account) public   override view returns (uint)
    {
        return balanceWithFrozen(account);
    }
    function allowance(address owner, address spender) public   override view returns (uint)
    {
        return walletStorage.getAllow(owner, spender);
    }
///

/// FROZEN
    function getFrozenToken(address acc) public   override view returns(uint)
    {
        uint id = userStorage.getUserIdByAddress(acc);
        if (frozenStorage.getFrozenDate(id)+ _twoWeek < block.timestamp )
        {
            return 0;
        }
        return frozenStorage.getFrozenTokens(id);
    }
    function getFrozenDate(address acc) public   override view returns(uint)
    {
        uint id = userStorage.getUserIdByAddress(acc);
        uint frozenDate = frozenStorage.getFrozenDate(id);
        if (frozenDate + _twoWeek < block.timestamp)
        {
            return 0;
        }
        return frozenDate;
    }
    function balanceWithFrozen(address acc) public   override view returns(uint)
    {
        uint balance = walletStorage.getBalance(acc);
        uint userId = userStorage.getUserIdByAddress(acc);
        if (frozenStorage.getFrozenDate(userId)+ _twoWeek > block.timestamp )
        {
            balance -= frozenStorage.getFrozenTokens(userId);
        }
        return balance; 
    }


/// Unfrozen
    function getCount() public  view returns (uint) {
        return unfrozen.getCount();
    }

    function getUnfrozenById(uint userId) public  view returns (address) {
        return unfrozen.getUnfrozenById(userId);
    }

    function getUnfrozenByAddress(address acc) public  view returns (bool) {
        return unfrozen.getUnfrozenByAddress(acc);
    }

    function getExtra(uint balance) public  view returns (uint8) {
        return unfrozen.getExtra(balance);
    }
///


/// SUPPLY
    function totalSupply() public   override view returns (uint)
    {
        (uint _totalSupply,  uint _totalEmmision) = supplyStorage.getSupply();
        return _totalSupply;
    }
    function getEmission() public   override view returns(uint)
    {
        (uint _totalSupply,  uint _totalEmmision) = supplyStorage.getSupply();
        return _totalEmmision;
    } 
///

/// DEPOSITE
    function getDeposite(address acc) public   override view returns(uint)
    {
        return depositeStorage.getDeposite(acc);
    }
    function getDepositeDate(address acc) public   override view returns(uint)
    {
        return depositeStorage.getDepDate(acc);
    }
    function getDepositeProfit(address acc) public   override view returns(uint)
    {
        uint userId = getIdByAddress(acc);
        uint depDate = getDepositeDate(acc);
        uint userDeposite = getDeposite(acc);
        uint8 userPercent = terms.getDepositePercent(userStorage.getUserStatusLVL(userId));
        if (unfrozen.getUnfrozenByAddress(acc))
        {
            userPercent += unfrozen.getExtra(getDeposite(acc));
        }
        uint secPassed = block.timestamp - depDate;
        return secPassed * ((userDeposite * userPercent / 100) / 30 / _day);
    }
///

/// ADMIN
    function setTime(uint day) onlyOwner public 
    {
        _day = day;
        _twoWeek = _day * 14;
    }
    function setUnfrozen(address newAdr) onlyOwner public {
        unfrozen = IUnfrozen(newAdr);
    }
    function setWallet(address newAdr) onlyOwner public 
    {
        walletStorage = IWalletStorage(newAdr);
    }
    function setUser (address newAdr) onlyOwner public
    {
        userStorage = IUserStorage(newAdr);
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
    function setFirstLine(address newAdr) onlyOwner public 
    {
        firstLine = IReferalFirstLine(newAdr);
    }
///
}
interface IController 
{

    /// ERC20 
    function transfer(address owner, address recipient, uint amount) external returns (bool);
    function approve(address owner,address spender, uint amount) external returns (bool);

    //// USER
    function register(address user, uint referlaId) external;
    function updateStatus(address acc)  external;

    //// Deposite
    function deposite (address user,uint amount)external returns(bool);
    function withdrawProfit(address user) external;
    function withdrawAll(address user) external;
    function reinvest(address user) external;

    /// unfrozen
    function setUnfrozenUser(address user) external;
    //// API
    function destroyToken(address acc, uint amount) external ;
    function addTokenforCoin(address acc, uint amount) external;
    function burn(uint amount) external;
    //// Presale
    function pay(address acc, uint amount) external returns(bool, uint,uint);
}

contract Controller is IController, ContractOwnerV2 
{
    /// OLD
    IWalletStorage walletStorage; 
    IUserStorage userStorage;
    View V; 
    IDepositeStorage depositeStorage;
    IUnfrozen unfrozen;
    IFrozenStorage frozenStorage = IFrozenStorage(0x921A21547b394C2FA696BE8f81AE7CFf8c288e09);
    ISupplyStorage supplyStorage = ISupplyStorage(0xb268C21642c455f2BA3C2B3c6A2692f28fa205CE);
    ITeam team = ITeam(0xa316b11DEf2f93aDfD3C9CB404c88794c1704430);
    IReferalFirstLine firstLine = IReferalFirstLine(0x512646bEef87433ab7F275f2bB62d1A6E62698fF);
    ITermsStorage terms = ITermsStorage(0x75f1e7da1375bc77499314DE7971aC50d63320c4);
    uint private _day = 86400;
    uint private _twoWeek = 1209600;
 

    constructor (address _w, address _d, address _un, address _us, address _v)
    {
        walletStorage = IWalletStorage(_w);
        userStorage = IUserStorage(_us);
        depositeStorage = IDepositeStorage(_d);
        V = View(_v);
        unfrozen = IUnfrozen(_un);
    }

    address EVOMG;
    address _proxy;
    modifier isProxy() 
    {
        require(msg.sender == _proxy, "no proxy");
        _;
    }
    modifier isEMG () 
    {
        require(msg.sender == EVOMG, "no app");
        _;
    }
    




/// TOKEN           
    function transfer(address owner, address recipient, uint amount) isContractOwner public returns (bool)
    {
        uint balance = V.balanceWithFrozen(owner);
        require(balance >= amount, "not enougth token");
        _trasfer(owner, recipient, amount);
        return true;
    }

    function approve(address owner, address spender, uint amount)isContractOwner public returns (bool)
    {
        walletStorage.allow(owner, spender, amount);
        return true;
    } 
    
    function burn(uint amount) isContractOwner public
    {
        _trasfer(msg.sender, address(0), amount);
        supplyStorage.subTokenSupply(amount);
    }
///

/// USER
    function register(address user, uint refId) isEMG() isEMG public
    {
        require(!V.isUserExist(user), "Alredy register");
        if(!V.isUserExistById(refId))
        {
            refId = 1;
        }
        userStorage.addUser(user, refId);
        uint id = V.getIdByAddress(user);
        firstLine.addReferal(id, refId);
        uint8 rewardLine = 0;
        bool isOwner = false;
        while(rewardLine < terms.getTermsLength() && !isOwner)
        {
            team.addTeamer(refId, rewardLine); 
            userStorage.addReferal(refId);     
            if (refId == 1)
            {
                isOwner = true;
            }
            refId = V.getReferalIdById(refId);
            rewardLine++;
        }
    }

    function updateStatus(address acc) public
    {
        uint id = V.getIdByAddress(acc);
        require(V.checkUpdate(id));
        userStorage.updateUserStatus(id);
    }
///
/// Deposite
    function deposite (address user, uint amount) isEMG public returns(bool)
    {
        require(V.balanceOf(user) >= amount, "Not enought tokens");
        uint profit = V.getDepositeProfit(user);
        walletStorage.subBalance(user, amount);
        uint userId = V.getIdByAddress(user);
        depositeStorage.addDep(user, amount + profit);
        depositeStorage.setDepDate(user, block.timestamp);
        addDepositeTeamAll(userId, amount);
        return true;
    }
    function withdrawProfit(address user) isEMG  public 
    {
        _withdrawProfit(user);
    }
    function withdrawAll(address user) isEMG public 
    {
        require(!V.getUnfrozenByAddress(user), "User unfrozened");
        uint userId = V.getIdByAddress(user);    
        uint frozenDate = frozenStorage.getFrozenDate(userId);
        if (frozenDate != 0)
        { 
            require(block.timestamp >= frozenDate + _twoWeek , "wait two week");
        }
        uint userDeposite = V.getDeposite(user);
        require(userDeposite > 0, "Not enought tokens");
        uint profit = V.getDepositeProfit(user);
        if (profit > 0)
        {
            _withdrawProfit(user);
        }
        walletStorage.addBalance(user, userDeposite);
        depositeStorage.setDepDate(user, block.timestamp);
        depositeStorage.subDep(user, userDeposite);
        frozenStorage.setFrozenDate(userId, block.timestamp);
        frozenStorage.setFrozenTokens(userId, userDeposite);
        subDepositeTeamAll(userId, userDeposite);
    }

    function reinvest(address user) isEMG public 
    {
        uint id = V.getIdByAddress(user);
        uint profit = V.getDepositeProfit(user);
        depositeStorage.addDep(user, profit);
        depositeStorage.setDepDate(user, block.timestamp);
        addDepositeTeamAll(id, profit);
        supplyStorage.addTokenSupply(profit);
    }
///
/// UNFROZEN
    function setUnfrozenUser(address user) isEMG public 
    {
        require(!V.getUnfrozenByAddress(user));
        _withdrawProfit(user);
        unfrozen.setUnfrozen(user);
    }
///   
/// Presale
    function pay(address acc, uint amount) public override returns(bool, uint,uint) 
    {
        return (false, 0,amount);
    }
///
/// API
    function destroyToken(address acc, uint amount) isProxy public
    {
        walletStorage.subBalance(acc, amount);
        supplyStorage.subTokenSupply(amount);
    }
    function addTokenforCoin(address acc, uint amount) isProxy public
    {
        walletStorage.addBalance(acc, amount);
        supplyStorage.addTokenSupply(amount);
    }
///
/// PRIVATE
    function _trasfer(address owner, address repicient, uint amount) private
    {
        walletStorage.subBalance(owner, amount);
        walletStorage.addBalance(repicient, amount);
    }
    function getClearPercent(uint amount) private view returns(uint)
    {
        return amount - (amount /100 * terms.getFullReferalPercent());
    }
    function addDepositeTeamAll(uint id, uint amount) private 
    {
        uint refId = userStorage.getReferalById(id);
        uint8 lvl = 0;
        bool isOwner = false;
        while (lvl < terms.getTermsLength() && !isOwner)
        {
            uint depositeTeam = userStorage.getUserDepositeTeam(refId);
            userStorage.updateUserDepositeTeam(refId, depositeTeam+amount);
            if (refId == 1)
            {
                isOwner = true;
            }
            refId = userStorage.getReferalById(refId);
            lvl++;
        }
    }
    function rewardPass(uint userId, uint8 lvl)private view returns(bool)
    {
        uint8 userStatusLvl = userStorage.getUserStatusLVL(userId);
        uint8 linesOpened = terms.getOpenedLevel(userStatusLvl);
        if (linesOpened >= lvl)
        {
            return true;
        }
        return false;
    }
    function findReferalReward(uint amount, uint8 line) private view returns (uint)
    {
        uint percent =  terms.getReferalPercent(line);
        return ((amount * percent) / 100);
    }
    function subDepositeTeamAll(uint id, uint amount) private 
    {
        uint refId = userStorage.getReferalById(id);
        uint lvl = 0;
        bool isOwner = false;
        while (lvl < terms.getTermsLength() && !isOwner)
        {
            uint depositeTeam = userStorage.getUserDepositeTeam(refId);
            if (depositeTeam >= amount)
            {
                userStorage.updateUserDepositeTeam(refId, depositeTeam - amount);
            } 
            else 
            {
                userStorage.updateUserDepositeTeam(refId, 0);
            }
            
            if (refId == 1)
            {
                isOwner = true;
            }
            refId = userStorage.getReferalById(refId);
            lvl++;
        }
    }
    function _withdrawProfit(address acc) private
    {
        uint profit = V.getDepositeProfit(acc);
        require(profit > 0, "No profit");
        uint clearProfit = getClearPercent(profit);
        uint userId = userStorage.getUserIdByAddress(acc);
        uint NextReferalId = userStorage.getReferalById(userId);
        walletStorage.addBalance(acc, clearProfit);
        depositeStorage.setDepDate(acc, block.timestamp);
        for (uint8 rewardLine = 0; rewardLine < terms.getTermsLength(); rewardLine++ )
        {
            address rewardAddress; 
            if (rewardPass(NextReferalId, rewardLine))
            {
                rewardAddress =  userStorage.getUserAddressById(NextReferalId);
            }
            else
            {
                rewardAddress =  userStorage.getUserAddressById(1);
            }
            uint reward = findReferalReward(profit,rewardLine);
            walletStorage.addBalance(rewardAddress, reward);
            NextReferalId = userStorage.getReferalById(NextReferalId);
        }
        supplyStorage.addTokenSupply(profit);
    }
///
/// ADMIN
    function setWallet(address newAdr) onlyOwner public 
    {
        walletStorage = IWalletStorage(newAdr);
    }
    function setUser (address newAdr) onlyOwner public
    {
        userStorage = IUserStorage(newAdr);
    }
    function setView (address newAdr)onlyOwner public
    {
        V = View(newAdr);
    }
    function setFirstLine(address newAdr) onlyOwner public
    {
        firstLine = IReferalFirstLine(newAdr);
    }
    function setTime(uint time) onlyOwner public
    {
       _day = time;
       _twoWeek = time * 14;
    }
    function setTerms(address termsAdr) onlyOwner public 
    {
        terms = ITermsStorage(termsAdr);
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
    function setUnfrozen(address newAdr) onlyOwner public
    {
        unfrozen = IUnfrozen(newAdr);
    }
    function setProxy(address proxy) onlyOwner public
    {
        _proxy = proxy;
    }
    function setEVO(address evo) onlyOwner public
    {
        EVOMG = evo;
    }
///
}