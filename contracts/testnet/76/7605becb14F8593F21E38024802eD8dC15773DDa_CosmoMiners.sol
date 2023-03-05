pragma solidity 0.8.17;

import "./Context.sol";
import "./Ownable.sol";

contract CosmoMiners is Context, Ownable {
    uint256 private ORE_TO_PRODUCE_1STARSHIPS = 600; //1080000;//for final version should be seconds in a day
    uint256 private TONS_IN_1STARSHIP = 1000;

    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;
    uint256 private devFeeVal = 4;
    
    bool private initialized = false;

    uint256 constant public MUL = 1e9;
    
    address payable private d1;
    address payable private d2;
    address payable private d3;

    mapping (address => uint256) public spaceport;
    mapping (address => uint256) public refOre;
    mapping (address => uint256) public lastSell;
    mapping (address => address) public referrals;
    
    uint256 public marketOre;
    
    constructor() {
        d3 = payable(msg.sender);
    }
    
    // constructor(address payable _d1, address payable _d2) {
    //     d1 = _d1;
    //     d2 = _d2;
    //     d3 = payable(msg.sender);
    // }
    
    function produceStarships() public {
        require(initialized);
                
        uint256 _oreUsed = getMyOre(msg.sender);
        uint256 _newStarships = _oreUsed / ORE_TO_PRODUCE_1STARSHIPS;
        spaceport[msg.sender] += _newStarships;
        updInfo(_oreUsed);
    }

    function updInfo(uint256 _oreUsed) internal {
        refOre[msg.sender] = 0;
        lastSell[msg.sender] = block.timestamp;
        
        uint256 _ore = _oreUsed * 285;  // / 35 * 10 / 1000 (TONS_IN_1STARSHIP) * MUL
        //marketOre += _oreUsed / 35000000;  // / 35 * 10 / 1000 (TONS_IN_1STARSHIP);
        marketOre += _ore; //_oreUsed / 35 * 10000;
        refOre[referrals[msg.sender]] += _ore / 8;
    }    

    function sellOre() public {
        require(initialized, "Not initialized yet");

        uint256 _hasOre = getMyOre(msg.sender);
        uint256 _oreValue = calculateOreSell(_hasOre);
        uint256 _fee = devFee(_oreValue);

        refOre[msg.sender] = 0;
        lastSell[msg.sender] = block.timestamp;

        marketOre += _hasOre;
        d1.transfer(_fee);
    
        payable(msg.sender).transfer(_oreValue - _fee);
    }
    
    function oreRewards(address _user) public view returns(uint256) {
        uint256 _hasOre = getMyOre(_user);
        uint256 _oreValue = calculateOreSell(_hasOre);
        return _oreValue;
    }
    
    function buyStarships(address _referrer) public payable {
        require(initialized);
        
        uint256 _starshipsBought = calculateStarshipBuy(msg.value, address(this).balance - msg.value) / MUL;
        _starshipsBought -= devFee(_starshipsBought);
        spaceport[msg.sender] += _starshipsBought;

        uint256 _fee = devFee(msg.value);
        d2.transfer(_fee);
    
        uint256 _ore = getMyOre(msg.sender);

        _checkRef(_referrer);
        updInfo(_ore);
    }

    function _checkRef(address _referrer) internal {
        address _ref = referrals[msg.sender];
        _referrer = _ref != address(0) ? _ref : _referrer;

        if(_referrer == address(0) || _referrer == msg.sender) {
            _referrer = owner();
        }
        
        if(_ref == address(0)) {
            referrals[msg.sender] = _referrer;
        }
    }
    
    function calculateTrade(uint256 _rt, uint256 _rs, uint256 _bs) public view returns(uint256) {
        return (PSN * _bs) / (PSNH + (((PSN * _rs) + (PSNH * _rt)) / _rt));
    }
    
    function calculateOreSell(uint256 _ore) public view returns(uint256) {
        return calculateTrade(_ore * MUL, marketOre * MUL, address(this).balance);
    }
    
    function calculateStarshipBuy(uint256 _amount, uint256 _contractBalance) public view returns(uint256) {
        return calculateTrade(_amount, _contractBalance, marketOre * MUL);
    }
    
    function calculateStarshipBuySimple(uint256 _amount) public view returns(uint256) {
        return calculateStarshipBuy(_amount, address(this).balance);
    }

    function devFee(uint256 _amount) private view returns(uint256) {
        return (_amount * devFeeVal) / 100;
    }
    
    function seedMarket() public payable onlyOwner {
        require(marketOre == 0);
        initialized = true;
        marketOre = 108;
    }
    
    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }
    
    function getMyStarships(address _user) public view returns(uint256) {
        return spaceport[_user];
    }
    
    function getMyOre(address _user) public view returns(uint256) {
        return refOre[_user] + getOreSinceLastSell(_user);
    }
    
    function getOreSinceLastSell(address _user) public view returns(uint256) {
        uint256 secondsPassed = min(ORE_TO_PRODUCE_1STARSHIPS, block.timestamp - lastSell[_user]);
        return secondsPassed * spaceport[_user] * TONS_IN_1STARSHIP;
    } 
    
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}

pragma solidity ^0.8.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */

import "./Context.sol";

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}