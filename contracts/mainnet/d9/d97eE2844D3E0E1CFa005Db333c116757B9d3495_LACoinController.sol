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
abstract contract ContractOwner is Ownable
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
interface ILACoinController 
{

    /// ERC20 
    function transfer(address owner, address recipient, uint amount) external returns (bool);
    function approve(address owner,address spender, uint amount) external returns (bool);

    //// USER
    function register(uint referlaId) external;

    //// Deposite
    function deposite (uint amount)external returns(bool);
    function withdrawProfit() external;
    function withdrawAll() external;

    //// API
    function destroyToken(address acc, uint amount) external ;
    function addTokenforCoin(address acc, uint amount) external;
    function updateStatus(address acc)  external;

    //// Presale
    function buyPresaleToken(address acc, uint amount) external returns(bool, uint,uint);
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
contract LACoinController is ILACoinController,ContractOwner
{
    IWalletStorage walletStorage;
    IPresale presale;
    IUserStorage userStorage;
    ITermsStorage terms;
    IView View;
    IDepositeStorage depositeStorage;
    IFrozenStorage frozenStorage;
    ISupplyStorage supplyStorage;
    ITeam team;
    uint private _day =86400;
    uint private _twoWeek = 1209600;

        constructor(
        address wallet, address user, address presaleAdr, 
        address termsAdr, address depositeAdr, address frozen,
        address supply, address teamAdr)
    {
        userStorage = IUserStorage(user);
        walletStorage = IWalletStorage(wallet);
        presale = IPresale(presaleAdr);
        terms = ITermsStorage(termsAdr);
        depositeStorage = IDepositeStorage(depositeAdr);
        frozenStorage = IFrozenStorage(frozen);
        supplyStorage = ISupplyStorage(supply);
        team = ITeam(teamAdr);
    }

/// ERC20
    function transfer(address owner, address recipient, uint amount) isContractOwner public override returns (bool)
    {
        uint balance = View.balanceWithFrozen(owner);
        require(balance >= amount, "not enougth token");
        _trasfer(owner, recipient, amount);
        return true;
    }
    function approve(address owner, address spender, uint amount)isContractOwner public override returns (bool)
    {
        walletStorage.allow(owner, spender, amount);
        return true;
    } 
///

/// USER
    function register(uint refId)  public override
    {
        address acc = msg.sender;
        require(!View.isUserExist(acc), "Alredy register");
        if(!View.isUserExistById(refId))
        {
            refId = 1;
        }
        userStorage.addUser(acc, refId);
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
            refId = userStorage.getReferalById(refId);
            rewardLine++;
        }
    }
    function updateStatus(address acc) public override
    {
        uint id = userStorage.getUserIdByAddress(acc);
        require(View.checkUpdate(id));
        userStorage.updateUserStatus(id);
        team.clearTeameStatus(id);
        uint refId = userStorage.getReferalById(id);
        team.addTeameStatus(refId);
    }
///

/// Deposite
    function deposite (uint amount) public override returns(bool)
    {
        require(View.balanceOf(msg.sender) >= amount, "Not enought tokens");
        uint profit = View.getDepositeProfit(msg.sender);
        walletStorage.subBalance(msg.sender, amount);
        uint userId = userStorage.getUserIdByAddress(msg.sender);
        depositeStorage.addDep(msg.sender, amount + profit);
        depositeStorage.setDepDate(msg.sender, block.timestamp);
        addDepositeTeamAll(userId, amount);
       
        uint NextRefaralId = userStorage.getReferalById(userId);
        uint rewardLine = 0;
        bool isOwner = false;
        while (rewardLine < terms.getTermsLength()-1 && !isOwner)
        {
            if (NextRefaralId == 1)               
            {
                isOwner = true;
            }
            NextRefaralId = userStorage.getReferalById(NextRefaralId);
            rewardLine++;
        }
        return true;
    }
    function withdrawProfit()  public override
    {
        _withdrawProfit(msg.sender);
    }
    function withdrawAll()  public override
    {
        uint userId = userStorage.getUserIdByAddress(msg.sender);
        uint frozenDate = frozenStorage.getFrozenDate(userId);
        if (frozenDate != 0)
        { 
            require(block.timestamp >= frozenDate + _twoWeek , "wait two week");
        }
        uint userDeposite = depositeStorage.getDeposite(msg.sender);
        require(userDeposite > 0, "Not enought tokens");
        uint profit = View.getDepositeProfit(msg.sender);
        if (profit > 0)
        {
            _withdrawProfit(msg.sender);
        }
        walletStorage.addBalance(msg.sender, userDeposite);
        depositeStorage.setDepDate(msg.sender, block.timestamp);
        depositeStorage.subDep(msg.sender, userDeposite);
        frozenStorage.setFrozenDate(userId, block.timestamp);
        frozenStorage.setFrozenTokens(userId, userDeposite);
        subDepositeTeamAll(userId, userDeposite);
    }
///

/// API
    function destroyToken(address acc, uint amount) isContractOwner public override
    {
        walletStorage.subBalance(acc, amount);
        supplyStorage.subTokenSupply(amount);
    }
    function addTokenforCoin(address acc, uint amount) isContractOwner public override
    {
        walletStorage.addBalance(acc, amount);
        supplyStorage.addTokenSupply(amount);
    }

///

/// Presale
    function buyPresaleToken(address acc, uint amount) isContractOwner public override 
        returns(bool,uint,uint)
    {
        require(amount > 0, "No amount");
        require(View.getPresaleStart(),"Presale not started");
        require(block.timestamp < View.getPresaleEndDate(), "PresaleOver");
        uint etherPierToken  = View.getPrice();
        uint256 tokens = amount / etherPierToken * 10** 18; 
        require(View.getPresaleLimit(acc) + tokens <= View.getMaxToken(),"limit exceeded");   
        uint presaleCount = View.getPresaleCount();
        uint machValue = 0;
        if (tokens > presaleCount) 
        {
            tokens = presaleCount;
            machValue = amount - (tokens * etherPierToken / 10 * 18);
            amount -= machValue;
        }
        walletStorage.addBalance(acc,tokens);
        presale.subCount(tokens);  
        supplyStorage.addTokenSupply(tokens);
        presale.buyTokenOnPresale(acc, tokens);
        return (true, amount, machValue);
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
        while (lvl < terms.getTermsLength()-1 && !isOwner)
        {
            uint depositeTeam = userStorage.getUserDepositeTeam(refId);
            userStorage.updateUserDepositeTeam(refId, depositeTeam - amount);
            if (refId == 1)
            {
                isOwner = true;
            }
            refId = userStorage.getReferalById(refId);
        }
    }
    function _withdrawProfit(address acc) private
    {
        uint profit = View.getDepositeProfit(acc);
        require(profit > 0, "No profit");
        uint clearProfit = getClearPercent(profit);
        uint userId = userStorage.getUserIdByAddress(acc);
        uint NextReferalId = userStorage.getReferalById(userId);
        walletStorage.addBalance(acc, clearProfit);
        depositeStorage.setDepDate(acc, block.timestamp);
        for (uint8 rewardLine = 0; rewardLine < terms.getTermsLength()-1; rewardLine++ )
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
    function setPresale (address newAdr)onlyOwner public
    {
        presale = IPresale(newAdr);
    }
    function setView (address newAdr)onlyOwner public
    {
        View = IView(newAdr);
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
///
}