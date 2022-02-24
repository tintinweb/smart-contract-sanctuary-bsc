/**
 *Submitted for verification at BscScan.com on 2022-02-24
*/

// File: contracts\Interface\IRigelLaunchPadFactory.sol

// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

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
    ) external;
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

    function userFunds(address _user) external view returns (uint256);
    function isWhitelist(address _user) external view returns (bool);
    function getMinimum() external view returns (uint256);
    function checkPoolBalance(address _user) external view returns (bool);
    function lockFund(address staker, uint256 _amount) external;
    function getUser(address _user) external view returns (uint256);
    function getOutPutAmount(uint256 _amt) external view returns (uint256);
    function lengthOfPeriod() external view returns (uint256);
}

// File: contracts\Interface\Irouter.sol

interface Irouter {
    
    function owner() external view returns (address);
    function Factory() external view returns (address);
    function numbersOfDistributions(address swapFrom, address swapTo, uint256 _chkPeriod) external view returns (uint256 _prd, uint256 percent);
    function viewLaunchPadData(address swapFrom, address swapTo) external view returns (
        address swapTokenFrom, 
        address swapTokenTo, 
        address  specialPoolC,
        uint256  price,
        uint256  expectedLockFunds,
        uint256  lockedFunds,
        uint256  maxLock
    );

    function getUserLockedFund( address swapFrom, address swapTo, address _user) external view  returns (uint256);
    function checkIFuserIsWhitelisted(address swapFrom, address swapTo, address _user) external view returns(bool isWhitelisted) ;
    function getMinimumSpecialPool(address swapFrom, address swapTo) external view returns(uint256  min);
    function checkIfUserHasStaked(address swapFrom, address swapTo, address _user) external view returns (bool staked);
    function lockFunds(address swapFrom, address swapTo, uint256 amount) external;
    function getAmountOut( address swapFrom, address swapTo,  address _user) external view returns(uint256 _amount);
    function traderBalance(address swapFrom, address swapTo, uint256 _inPutAmount) external view returns(uint256 _outPutAmount);
    function getLengthOfPeriod(address swapFrom, address swapTo) external view returns(uint256  lnght);
}

// File: contracts\routerV1.sol


contract routerV1 is Irouter {    
    address public Factory;
    address public owner;   

    struct distributionPeriod {
        uint256 distributionTime;
        uint256 distributionPercentage;
    } 
            
    constructor(address _factory) {
        owner = msg.sender;
        Factory = _factory;
    }  
    
    function lockFunds(address swapFrom, address swapTo, uint256 amount) external  {        
        address pair = IRigelLaunchPadFactory(Factory).getPairedPad(swapFrom, swapTo);
        IrigelProtocolLanchPadPool(pair).lockFund(msg.sender, amount);
    }
    
    function numbersOfDistributions(address swapFrom, address swapTo, uint256 _i) external view returns(uint256 _prd, uint256 percent) {
        address pair = IRigelLaunchPadFactory(Factory).getPairedPad(swapFrom, swapTo);
        (_prd, percent) = IrigelProtocolLanchPadPool(pair).period(0, _i );
        return (_prd, percent);
    }
    
    function viewLaunchPadData(address swapFrom, address swapTo) external view returns(
        address swapTokenFrom, 
        address swapTokenTo, 
        address  specialPoolC,
        uint256  price,
        uint256  expectedLockFunds,
        uint256  lockedFunds,
        uint256  maxLock
        ) {
        address pair = IRigelLaunchPadFactory(Factory).getPairedPad(swapFrom, swapTo);
        (swapTokenFrom, swapTokenTo, specialPoolC, price, expectedLockFunds, lockedFunds, maxLock) = IrigelProtocolLanchPadPool(pair).viewData();
        return (swapTokenFrom, swapTokenTo, specialPoolC, price, expectedLockFunds, lockedFunds, maxLock);
    }
    
    function getUserLockedFund( address swapFrom, address swapTo, address _user) external view returns(uint256 _amount){
        address pair = IRigelLaunchPadFactory(Factory).getPairedPad(swapFrom, swapTo);
        _amount = IrigelProtocolLanchPadPool(pair).userFunds(_user);
        return _amount;
    }
    
    function checkIFuserIsWhitelisted(address swapFrom, address swapTo, address _user) external view returns(bool isWhitelisted) {
        address pair = IRigelLaunchPadFactory(Factory).getPairedPad(swapFrom, swapTo);
        return IrigelProtocolLanchPadPool(pair).isWhitelist(_user);
    }

    function checkIfUserHasStaked(address swapFrom, address swapTo, address _user) external view returns (bool staked) {
        address pair = IRigelLaunchPadFactory(Factory).getPairedPad(swapFrom, swapTo);
        staked = IrigelProtocolLanchPadPool(pair).checkPoolBalance(_user);
        return staked;
    }
    
    function getAmountOut( address swapFrom, address swapTo,  address _user) external view returns(uint256 _amount) {
        address pair = IRigelLaunchPadFactory(Factory).getPairedPad(swapFrom, swapTo);
        _amount = IrigelProtocolLanchPadPool(pair).getUser( _user);
        return _amount;
    }
    
    function traderBalance(address swapFrom, address swapTo, uint256 _inPutAmount) external view returns(uint256 _outPutAmount) {
        address pair = IRigelLaunchPadFactory(Factory).getPairedPad(swapFrom, swapTo);
        _outPutAmount = IrigelProtocolLanchPadPool(pair).getOutPutAmount(_inPutAmount);
        return _outPutAmount;
    }

    function getLengthOfPeriod(address swapFrom, address swapTo) external view returns(uint256  lnght) {
        address pair = IRigelLaunchPadFactory(Factory).getPairedPad(swapFrom, swapTo);
        lnght = IrigelProtocolLanchPadPool(pair).lengthOfPeriod();
        return lnght;
    }

    function getMinimumSpecialPool(address swapFrom, address swapTo) external view returns(uint256  min) {
        address pair = IRigelLaunchPadFactory(Factory).getPairedPad(swapFrom, swapTo);
        min = IrigelProtocolLanchPadPool(pair).getMinimum();
        return min;
    }
    
}